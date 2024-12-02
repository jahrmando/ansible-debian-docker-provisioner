USERNAME = $(shell whoami)
TEMP_DIR = nullstring
base_dir = $(shell pwd)
NAME = debian-node-ssh
playbook := $(base_dir)/test-playbook.yml

setup_temp_dir:
	$(eval TEMP_DIR := $(shell mktemp -d))
	@echo "Hello, $(USERNAME)! Your temporary directory is $(TEMP_DIR) on identifier $(NAME)"

sshkey_create: setup_temp_dir
	ssh-keygen -t rsa -b 4096 -C "$(USERNAME)@$(shell hostname)" -f $(TEMP_DIR)/id_rsa -N ""
	chmod 600 "$(TEMP_DIR)/id_rsa"
	chmod 644 "$(TEMP_DIR)/id_rsa.pub"
	cp "$(TEMP_DIR)/id_rsa" "$(base_dir)/id_rsa_$(NAME)"
	@echo "Your SSH key pair has been created in $(TEMP_DIR)"

start_container: remove_container sshkey_create
	docker build --tag "$(NAME)-last" \
		--build-arg USER=$(USERNAME) \
		--file "$(base_dir)/Dockerfile" $(TEMP_DIR)
	docker run -d -P --name "$(NAME)" "$(NAME)-last"

connect_container:
	$(eval node_port := $(shell docker inspect --format='{{(index (index .NetworkSettings.Ports "22/tcp") 0).HostPort}}' $(NAME)))
	@echo "Connecting to container $(NAME) on port $(node_port)"
	ssh -i "$(base_dir)/id_rsa_$(NAME)" -p $(node_port) $(USERNAME)@localhost

setup_inventory:
	$(eval node_port := $(shell docker inspect --format='{{(index (index .NetworkSettings.Ports "22/tcp") 0).HostPort}}' $(NAME)))
	@echo "[target_group]\nlocalhost ansible_ssh_port=$(node_port) ansible_ssh_user=$(USERNAME) ansible_ssh_private_key_file=$(base_dir)/id_rsa_$(NAME)" > $(base_dir)/hosts

run_playbook: setup_inventory
	ansible-playbook -i $(base_dir)/hosts $(playbook)

remove_container:
	docker stop $(NAME) || true
	docker rm $(NAME) || true

clean: remove_container
	rm -rf $(TEMP_DIR)
	docker rmi "$(NAME)-last" || true
	rm -f "$(base_dir)/id_rsa_$(NAME)"
