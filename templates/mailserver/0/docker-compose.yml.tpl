version: '2'
services:
  mailserver:
    image: hardware/mailserver:1.1-stable
    domainname: ${MAILSERVER_DOMAIN}
    hostname: ${MAILSERVER_HOSTNAME}
    labels:
      - traefik.port: '11334'
      - traefik.frontend.rule: "Host:spam.${MAILSERVER_DOMAIN}"
      - traefik.enable: 'true'
      - io.rancher.container.pull_image: always
    ports:
      - "${BIND_ADDRESS}:25:25/tcp"
    {{- if eq .Values.ENABLE_POP3 "true"}}
      - "${BIND_ADDRESS}:110:110/tcp"
    {{- end}}
      - "${BIND_ADDRESS}:143:143/tcp"
      - "${BIND_ADDRESS}:465:465/tcp"
      - "${BIND_ADDRESS}:587:587/tcp"
      - "${BIND_ADDRESS}:993:993/tcp"
    {{- if eq .Values.ENABLE_POP3 "true"}}
      - "${BIND_ADDRESS}:995:995/tcp"
    {{- end}}
    {{- if eq .Values.DISABLE_SIEVE "false"}}
      - "${BIND_ADDRESS}:4190:4190/tcp"
    {{- end}}
    environment:
      - DBPASS: ${DBPASS}
      - DBUSER: ${DBUSER}
      - DBNAME: ${DBNAME}
      - FQDN: ${MAILSERVER_FQDN}
      - DOMAIN: ${MAILSERVER_DOMAIN}
      - RSPAMD_PASSWORD: ${RSPAMD_PASSWORD}
      - RELAY_NETWORKS: ${RELAY_NETWORKS}
      - OPENDKIM_KEY_LENGTH: ${OPENDKIM_KEY_LENGTH}
      - PASSWORD_SCHEME: ${PASSWORD_SCHEME}
      - ADD_DOMAINS: ${MAILSERVER_ADD_DOMAIN}
      - DISABLE_RSPAMD_MODULE: ${DISABLE_RSPAMD_MODULE}
      - DISABLE_CLAMAV: ${DISABLE_CLAMAV}
      - DISABLE_DNS_RESOLVER: ${DISABLE_DNS_RESOLVER}
      - DISABLE_GREYLISTING: ${DISABLE_GREYLISTING}
      - DISABLE_RATELIMITING: ${DISABLE_RATELIMITING}
      - DISABLE_SIGNING: ${DISABLE_SIGNING}
      - ENABLE_POP3: ${ENABLE_POP3}
      - ENABLE_ENCRYPTION: ${ENABLE_ENCRYPTION}
      - ENABLE_FETCHMAIL: ${ENABLE_FETCHMAIL}
      - FETCHMAIL_INTERVAL: ${FETCHMAIL_INTERVAL}
    volumes:
      - "${VOLUMES_ROOT_PATH}/mail:/var/mail"
    links:
      - mariadb:mariadb
      - redis:redis

  postfixadmin:
    image: hardware/postfixadmin
    domainname: ${MAILSERVER_DOMAIN}
    hostname: ${MAILSERVER_HOSTNAME}
    labels:
      - traefik.port: '8888'
      - traefik.frontend.rule: "Host:postfixadmin.${MAILSERVER_DOMAIN}"
      - traefik.enable: 'true'
      - io.rancher.container.pull_image: always
    environment:
      - DBPASS: ${DBPASS}
      - DBUSER: ${DBUSER}
      - DBNAME: ${DBNAME}
      - ENCRYPTION: "dovecot:${PASSWORD_SCHEME}"
    links:
      - mariadb:mariadb
      - mailserver:mailserver

  rainloop:
    image: hardware/rainloop
    labels:
      - traefik.port: '8888'
      - traefik.frontend.rule: "Host:webmail.${MAILSERVER_DOMAIN}"
      - traefik.enable: 'true'
      - io.rancher.container.pull_image: always
    volumes:
      - ${VOLUMES_ROOT_PATH}/rainloop:/rainloop/data
    links:
      - mariadb:mariadb
      - mailserver:mailserver

  mariadb:
    image: mariadb:10.2
    labels:
      - io.rancher.container.pull_image: always
    environment:
      - MYSQL_DATABASE: ${DBNAME}
      - MYSQL_PASSWORD: ${DBPASS}
      - MYSQL_ROOT_PASSWORD: ${DBROOT}
      - MYSQL_USER: ${DBUSER}
    volumes:
      - "${VOLUMES_ROOT_PATH}/mysql/db:/var/lib/mysql"

  redis:
    image: redis:4.0-alpine
    labels:
      - io.rancher.container.pull_image: always
    command:
      - redis-server
      - --appendonly
      - 'yes'
    volumes:
      - "${VOLUMES_ROOT_PATH}/redis:/data"

volumes:
  rainloop:
    external: true
    driver: ${STORAGE_DRIVER}
  mailserver:
    external: true
    driver: ${STORAGE_DRIVER}
  redis:
    external: true
    driver: ${STORAGE_DRIVER}
  mariadb:
    external: true
    driver: ${STORAGE_DRIVER}
