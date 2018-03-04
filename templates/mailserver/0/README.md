## hardware/mailserver Rancher Catalog

### Description

This catalog provides a basic template to easily deploy an email server based on [hardware/mailserver](https://github.com/hardware/mailserver). To use it, just add this repository to your Rancher system as a catalog in `Admin > Settings` page.

### Prerequisites

* Linux host with at least 2GB of memory and 20GB of local disk
* Supported version of Docker
* Rancher server
* Basic understanding of e-mail ecosystem and standards

And you **MUST** read this :

* https://github.com/hardware/mailserver#system-requirements
* https://github.com/hardware/mailserver#prerequisites


### How to setup

1. Add this catalog in `Admin > Settings` page : https://github.com/hardware/mailserver-rancher.git

2. Select 'mailserver' from the catalog menu.

3. Fill in all required fields and adapt to your needs. For more information, read the [documentation](https://github.com/hardware/mailserver).

4. Lauch the mailserver stack. At first launch, the container takes few minutes to generate SSL certificates, DKIM keypair and update clamav database, all of this takes some time (1/2 minutes). You can check the startup logs with Rancher admin panel.

5. Now, you must setup a reverse proxy to access your administration, webmail and spam WebUIs. Add a label in the host instance configuration, in `Infrastructure > Hosts` page, named `traefik_lb` with a value equal to `true`. Traefik will be deployed in all hosts with this label.

6. Select 'traefik' load balancer from the community catalog. Fill in all required fields and adapt to your needs. If you choose API integration method, don't forget to create an API key for Traefik in `API > Keys` page.

7. Once traefik is started, you can setup Postfixadmin and Rainloop configuration :
    * Postfixadmin : [Postfixadmin initial configuration](https://github.com/hardware/mailserver/wiki/Postfixadmin-initial-configuration). The setup can be used from the Rancher web console :
    ![](https://i.imgur.com/9fVKVPd.png)
    * Rainloop : [Rainloop initial configuration](https://github.com/hardware/mailserver/wiki/Rainloop-initial-configuration)

8. Done, congratulation !

### List of all webservices available after installation :

* Traefik dashboard : https://mail.domain.tld/
* Rspamd dashboard : https://spam.domain.tld/
* Administration : https://postfixadmin.domain.tld/
* Webmail : https://webmail.domain.tld/

### Email client settings :

* IMAP/SMTP username : user@domain.tld
* Incoming IMAP server : mail.domain.tld
* Outgoing SMTP server : mail.domain.tld
* IMAP port : 993
* SMTP port : 587
* SIEVE port : 4190
* IMAP Encryption protocol : SSL/TLS
* SMTP Encryption protocol : STARTTLS
* SIEVE Encryption protocol : STARTTLS
