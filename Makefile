ping-all: ## ping server
	ansible -i inventories all -m ping

dump-host:
	@read -p "Hosts Pattern: " HOSTPATTERN; \
	ansible-playbook -i inventories dumpall.yml -e "env=$$HOSTPATTERN"

dump-host-staging:
	ansible-playbook -i inventories dumpall.yml -e "env=staging"

dump-host-prod:
	ansible-playbook -i inventories dumpall.yml -e "env=prod"