
ping-all: ## ping server
	ansible -i hosts all -m ping

command-hello-word: ## ansible-doc shell
	ansible -i hosts.yml all -m shell -a "touch hello-word.txt && echo 'hello word' > hello-word.txt" -vvv