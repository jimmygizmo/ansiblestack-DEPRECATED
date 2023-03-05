#!/usr/bin/env bash

# ansiblestack-managed-alpine - Docker entrypoint script.
#
# After the Dockerfile has created the image and run it, this script is run as the entry point
# and continues the setup of the host in the running context.


# I an error occurs in any command along the way, exit the entire script.
# If a command in this script exits with a non-zero status, immediately exit this script and
# return the same non-zero status as the component command returned from its error.
set -e


# -x enables the bash debugging feature
[ "$DEBUG" == 'true' ] && set -x


# Installing and starting the sshd service is the main goal of setting up this managed-alpine
# managed node, because at that point, ansible can connect over ssh and then manage the node.
DAEMON=sshd


# Copy the default sshd configuration from the ssh cache.
if [ ! "$(ls -A /etc/ssh)" ]; then
    cp -a /etc/ssh.cache/* /etc/ssh/
fi


# The first argument to 'set' is the key of the Shell Attribute to set.
# The second argument is the value.
# Environment variables and shell attributes are similar. Env vars are inherited by all shells.
# Shell attributes only exist for the current shell, unless they are exported.
# Below we are effectively setting env vars with some long names which only exist in this shell.
# Additionally, such attributes can be enabled and disabled with set. + = disable. - = enable.
set_hostkeys() {
    printf '%s\n' \
        'set /files/etc/ssh/sshd_config/HostKey[1] /etc/ssh/keys/ssh_host_rsa_key' \
        'set /files/etc/ssh/sshd_config/HostKey[2] /etc/ssh/keys/ssh_host_dsa_key' \
        'set /files/etc/ssh/sshd_config/HostKey[3] /etc/ssh/keys/ssh_host_ecdsa_key' \
        'set /files/etc/ssh/sshd_config/HostKey[4] /etc/ssh/keys/ssh_host_ed25519_key' \
    | augtool -s
}


# Print Authentication Key Fingerprints
# For 4 different encryption algorithms available in this host, print the fingerprint for that key.
# ssh-keygen options:
# -E  Specify the hash algorithm to use when printing fingerprints
# -l  Print the fingerprint
# -f  The key file for which to print the fingerprint
print_fingerprints() {
    local BASE_DIR=${1-'/etc/ssh'}
    for item in dsa rsa ecdsa ed25519; do
        echo ">>> Fingerprints for ${item} host key"
        ssh-keygen -E md5 -lf ${BASE_DIR}/ssh_host_${item}_key
        ssh-keygen -E sha256 -lf ${BASE_DIR}/ssh_host_${item}_key
        ssh-keygen -E sha512 -lf ${BASE_DIR}/ssh_host_${item}_key
    done
}


# Generate Host keys, if required
if ls /etc/ssh/keys/ssh_host_* 1> /dev/null 2>&1; then
    echo ">> Host keys in keys directory"
    # Call our set_hostkeys function in this file
    set_hostkeys
    print_fingerprints /etc/ssh/keys
elif ls /etc/ssh/ssh_host_* 1> /dev/null 2>&1; then
    echo ">> Host keys exist in default location"
    # Don't do anything
    print_fingerprints
else
    echo ">> Generating new host keys"
    mkdir -p /etc/ssh/keys
    ssh-keygen -A
    mv /etc/ssh/ssh_host_* /etc/ssh/keys/
    set_hostkeys
    print_fingerprints /etc/ssh/keys
fi


# Secure the permissions of ssh directories and files to prevent malicious overwriting of the keys
if [ -w ~/.ssh ]; then
    chown root:root ~/.ssh && chmod 700 ~/.ssh/
fi
if [ -w ~/.ssh/authorized_keys ]; then
    chown root:root ~/.ssh/authorized_keys
    chmod 600 ~/.ssh/authorized_keys
fi
if [ -w /etc/authorized_keys ]; then
    chown root:root /etc/authorized_keys
    chmod 755 /etc/authorized_keys
    find /etc/authorized_keys/ -type f -exec chmod 644 {} \;
fi


# Add users if SSH_USERS=user:uid:gid set
if [ -n "${SSH_USERS}" ]; then
    USERS=$(echo $SSH_USERS | tr "," "\n")
    for U in $USERS; do
        IFS=':' read -ra UA <<< "$U"
        _NAME=${UA[0]}
        _UID=${UA[1]}
        _GID=${UA[2]}

        echo ">> Adding user ${_NAME} with uid: ${_UID}, gid: ${_GID}."
        if [ ! -e "/etc/authorized_keys/${_NAME}" ]; then
            echo "WARNING: No SSH authorized_keys found for ${_NAME}!"
        fi
        getent group ${_NAME} >/dev/null 2>&1 || groupadd -g ${_GID} ${_NAME}
        getent passwd ${_NAME} >/dev/null 2>&1 || useradd -r -m -p '' -u ${_UID} -g ${_GID} -s '' -c 'SSHD User' ${_NAME}
    done
else
    # Warn if no authorized_keys
    if [ ! -e ~/.ssh/authorized_keys ] && [ ! $(ls -A /etc/authorized_keys) ]; then
        echo "WARNING: No SSH authorized_keys found!"
    fi
fi


# Unlock root account, if enabled
if [[ "${SSH_ENABLE_ROOT}" == "true" ]]; then
    usermod -p '' root
else
    echo "WARNING: root account is now locked by default. Set SSH_USERS to unlock the account."
fi


# Update Message of the Day (MOTD)
if [ -v MOTD ]; then
    echo -e "$MOTD" > /etc/motd
fi


if [[ "${SFTP_MODE}" == "true" ]]; then
    : ${SFTP_CHROOT:='/data'}
    chown 0:0 ${SFTP_CHROOT}
    chmod 755 ${SFTP_CHROOT}

    printf '%s\n' \
        'set /files/etc/ssh/sshd_config/Subsystem/sftp "internal-sftp"' \
        'set /files/etc/ssh/sshd_config/AllowTCPForwarding no' \
        'set /files/etc/ssh/sshd_config/X11Forwarding no' \
        'set /files/etc/ssh/sshd_config/ForceCommand internal-sftp' \
        "set /files/etc/ssh/sshd_config/ChrootDirectory ${SFTP_CHROOT}" \
    | augtool -s
fi


stop() {
    echo "Received SIGINT or SIGTERM. Shutting down $DAEMON"
    # Get PID
    pid=$(cat /var/run/$DAEMON/$DAEMON.pid)
    # Set TERM
    kill -SIGTERM "${pid}"
    # Wait for exit
    wait "${pid}"
    # All done.
    echo "Done."
}


echo "Running $@"
if [ "$(basename $1)" == "$DAEMON" ]; then
    trap stop SIGINT SIGTERM
    $@ &
    pid="$!"
    mkdir -p /var/run/$DAEMON && echo "${pid}" > /var/run/$DAEMON/$DAEMON.pid
    wait "${pid}" && exit $?
else
    exec "$@"
fi

