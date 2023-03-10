#! /bin/sh

#
# Simple wrapper for executing ansible-galaxy and ansible-playbook
# with local connection.
#
# USAGE:
#    ansible-playbook-wrapper  [other ansible-playbook arguments]
#
# ENVIRONMENT VARIABLES:
#
#    - REQUIREMENTS: requirements filename; default = "requirements.yml"
#    - PLAYBOOK:     playbook filename;     default = "playbook.yml"
#    - INVENTORY:    inventory filename;    default = "/etc/ansible/hosts"
#


#
# install Galaxy roles, if any
#

if [ -z "$REQUIREMENTS" ]; then
    REQUIREMENTS=requirements.yml
fi

if [ -f "$REQUIREMENTS" ]; then
    apk --update add git
    ansible-galaxy install -r $REQUIREMENTS
fi


#
# execute playbook
#

if [ -z "$PLAYBOOK" ]; then
    PLAYBOOK=playbook.yml
fi


if [ -z "$INVENTORY" ]; then
    exec ansible-playbook        \
       $PLAYBOOK                 \
       --connection=smart        \
       -vvvv                     \
       "$@"
else
    exec ansible-playbook        \
       -i $INVENTORY  $PLAYBOOK  \
       --connection=smart        \
       -vvvv                     \
       "$@"
fi
