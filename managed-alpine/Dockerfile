
FROM alpine:3.9 as managed-alpine-systemd

RUN apk --update --no-cache add openrc python

RUN ln -sf /sbin/openrc-init /sbin/init

ENTRYPOINT ["/sbin/init"]


FROM managed-alpine-systemd as managed-alpine-sshd

RUN apk update

RUN apk add bash git openssh rsync augeas shadow

RUN deluser $(getent passwd 33 | cut -d: -f1)

RUN delgroup $(getent group 33 | cut -d: -f1) 2>/dev/null || true

RUN mkdir -p ~root/.ssh /etc/authorized_keys && chmod 700 ~root/.ssh/

RUN augtool 'set /files/etc/ssh/sshd_config/AuthorizedKeysFile ".ssh/authorized_keys /etc/authorized_keys/%u"'

RUN echo -e "Port 22\n" >> /etc/ssh/sshd_config

RUN cp -a /etc/ssh /etc/ssh.cache

RUN rm -rf /var/cache/apk/*



EXPOSE 22

COPY docker-entrypoint.sh /entry.sh
RUN chmod a+x /entry.sh
ENTRYPOINT ["/entry.sh"]

CMD ["/usr/sbin/sshd", "-D", "-e", "-f", "/etc/ssh/sshd_config"]


#RUN apk update && \
#    apk add bash git openssh rsync augeas shadow && \
#    deluser $(getent passwd 33 | cut -d: -f1) && \
#    delgroup $(getent group 33 | cut -d: -f1) 2>/dev/null || true && \
#    mkdir -p ~root/.ssh /etc/authorized_keys && chmod 700 ~root/.ssh/ && \
#    augtool 'set /files/etc/ssh/sshd_config/AuthorizedKeysFile ".ssh/authorized_keys /etc/authorized_keys/%u"' && \
#    echo -e "Port 22\n" >> /etc/ssh/sshd_config && \
#    cp -a /etc/ssh /etc/ssh.cache && \
#    rm -rf /var/cache/apk/*



