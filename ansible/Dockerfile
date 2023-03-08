FROM williamyeh/ansible:master-debian9-onbuild
# 400 MB


# ==> Specify requirements filename;  default = "requirements.yml"
#ENV REQUIREMENTS  requirements.yml

# ==> Specify playbook filename;      default = "playbook.yml"
#ENV PLAYBOOK      playbook.yml

# ==> Specify inventory filename;     default = "/etc/ansible/hosts"
#ENV INVENTORY     inventory.ini

# Create vault
RUN ansible-vault create cred.yml


# ==> Executing Ansible (with a simple wrapper)...
# ** This has been moved to compose as have the env vars.
#RUN ansible-playbook-wrapper

COPY ./run-playbook.sh .

RUN pwd
# It is /tmp

RUN chmod 755 run-playbook.sh

# To execute it from the outside, trying /tmp/run-playbook.sh

