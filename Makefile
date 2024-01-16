ping-all: ## ping server
	ansible -i hosts.yml all -m ping

dump-host:
	@read -p "Hosts Pattern: " HOSTPATTERN; \
	ansible-playbook -i hosts.yml dumpall.yml -e "env=$$HOSTPATTERN"

dump-host-staging:
	ansible-playbook -i hosts.yml dumpall.yml -e "env=staging"

dump-host-prod:
	ansible-playbook -i hosts.yml dumpall.yml -e "env=prod"

deploy-server:
	ansible-playbook -i hosts.yml server.yml