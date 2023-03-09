# ansiblestack-DEPRECATED

## UPDATE:

I've decided to design my own Ansible container as I think I have a better strategy that what is used currently in this project. It makes sense to start a fresh repo since the structure will be very different. The new AnsibleStack will start around March 10th, 2023.
I like lean images when possible and the Ansible Python libraries are already of a substantial size, so I will begin, with a lean Python image like a Bitnami and build out a sweet containerized Anisble control node. Many design patterns of the project will parallel the standalone Ansible I have designed in my GitHub Project: AnsiblyMyEC2. Clean and simple is the theme of the day, so I follow such design patterns for containerization which I have developed with my Nucleus Stack and companion stacks.

Jim

----
----
DEPRECATED BELOW HERE:
----


Ansible on a lean Debian 9 image orchestrated with Docker Compose and packaged for ease of use. A clean implementation great for independent deployment or use with The Nucleus Stack full stack ecosystem.

----

Use the ansible control node container manually:

     docker-compose run -it ansiblestack-ansible bash

----

The Ansible control node container currently has an entry point which will run the specified playbook when the stack comes up. You might not want this as you might want to work in a shell in the control node without
that playbook having been run. You can disable that entrypoint. But if you want that, then all you have to do
is bring up the stack and the playbook defined in the environment variables of the control node in the docker-compose.yml file will be run. Simply do:

     docker-compose up

----

Let's say you don't want to use the managed nodes inside this stack and instead want to do real work on
real nodes outside the stack, but you don't want any sensitive information added to the repository as
a result of putting some real host addresses, configurations or secrets into your working files or
directories. I use a standard method to address this.

Add "-real" to the end of the the filename and/or directories involved, then make a matching entry in
.gitignore to prevent this file or directory from being added to the repository. I've added a few entries
already but make sure to check your "git add" or "git status" results to make sure do not need to add
a new "-real" exclusion.

Then you can switch between using these sensitive resources, mostly all within the docker-compose.yml
file. As the project evolves, I will further develop mechanisms to make it easy to work within this stack
with all the demo stuff and then easily develop a real playbook for doing work on real hosts outside this stack.

----

My plans are to use this project to automate deployments of my Nucleus Stack and/or FlaskStack and other companion Nucleus projects of mine. I currently run 4 VMs and there are still a few manual steps  to automate for the complete setup of a freshly-instantiated VM (AWS EC2 currently). I want to develop AnsibleStack simultaneously to work in a standalone, lab/demo mode all within the Docker Compose stack, while also developing it for dual capability to do real external work, using a clean way to separate and switch between those operating modes.

I think this will make AnsibleStack the most valuable to my own projects as well as for everyone else, in its a role as both a learning and development tool as well as a self-contained, dockerized Ansible control node to automate Nucleus deployments or whatever you like.

----

