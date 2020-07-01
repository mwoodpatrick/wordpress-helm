FROM wordpress:cli-2.4-php7.3

USER root

RUN apk add ansible git rsync openssh
ADD . /var/local/ansible
ENV ANSIBLE_CONFIG /var/local/ansible/ansible.cfg

# This is the homedir of user 33 in the alpine container and needs to exist and
# be writable for ssh to work.
RUN mkdir -p /etc/X11/fs && chown -R 33:33 /etc/X11/fs

# SSH Identity file location for backup playbook
RUN mkdir -p /etc/ssh/ && echo "IdentityFile /var/local/ssh-private-key/ssh-private-key" > /etc/ssh/ssh_config

# Chown the files to the Debian www-data user, because that's the only WP
# container that runs Apache too.
RUN chown -R 33:33 /var/local/ansible; \
    mkdir /etc/ansible; \
    echo 'localhost ansible_connection=local ansible_python_interpreter=/usr/bin/python3' > /etc/ansible/hosts

WORKDIR /var/local/ansible

USER www-data

CMD ["ansible-playbook", "wpdeploy.yml", "-e", "@secrets/secret-vars.yaml"]
