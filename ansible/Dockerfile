FROM williamyeh/ansible:master-debian9-onbuild
# 400 MB


# ==> Specify requirements filename;  default = "requirements.yml"
#ENV REQUIREMENTS  requirements.yml

# ==> Specify playbook filename;      default = "playbook.yml"
#ENV PLAYBOOK      playbook.yml

# ==> Specify inventory filename;     default = "/etc/ansible/hosts"
#ENV INVENTORY     inventory.ini

# ==> Executing Ansible (with a simple wrapper)...
RUN ansible-playbook-wrapper

