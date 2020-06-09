FROM wordpress:cli-2.1.0-php7.3

USER root

RUN apk add ansible git rsync
ADD . /var/local/ansible
ENV ANSIBLE_CONFIG /var/local/ansible/ansible.cfg

# Chown the files to the Debian www-data user, because that's the only WP
# container that runs Apache too.
RUN chown -R 33:33 /var/local/ansible; \
    mkdir /etc/ansible; \
    echo 'localhost ansible_connection=local ansible_python_interpreter=/usr/bin/python3' > /etc/ansible/hosts

WORKDIR /var/local/ansible

USER www-data

CMD ["ansible-playbook", "wpdeploy.yml", "-e", "@secrets/secret-vars.yaml"]
