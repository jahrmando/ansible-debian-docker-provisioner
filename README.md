# ansible-debian-docker-provisioner

A Linux Debian docker container for Testing Ansible Playbooks. 
This container is based on the official Debian image and includes Ansible, Python, and SSH.

# Pre-requisites

You have to install Docker on your machine. Please use the following link to install Docker on your machine.

- [Docker Installation](https://docs.docker.com/engine/install/)

# Usage

To create the container, you can use the following command:

```bash
make start_container
```

To access the container, you can use the following command:

```bash
make connect_container
```

To run an Ansible playbook test, you can use the following command:

```bash
make run_playbook
```

or pass the playbook path as an argument:

```bash
make run_playbook playbook=/path/to/playbook.yml
```
