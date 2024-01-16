#### 0. Devops ?

---

- The great Donovan Brown's Quote

  > DevOps is the union of people, process, and products to enable continuous delivery of value to our end users.
  >
  > > Donovan Brown

  https://medium.com/@DonovanBrown_41367/dissecting-the-definition-69151da0435f

- RedHat definition
  https://www.redhat.com/fr/topics/devops

- Le livre : Découvrir DevOps - 2e édition - L'essentiel pour tous les métiers
  Stéphane Goudeau, Samuel Metias
  https://www.dunod.com/sciences-techniques/decouvrir-devops-essentiel-pour-tous-metiers-0

- Listes des DevOps Tools:
  [p-table-v3](media/p-table-v3.jpeg)

- DevOps <-> OpsDev
  - https://www.zdnet.fr/actualites/noops-est-il-le-futur-de-devops-39830996.htm
  - Une Vidéo de Quentin Adam de Clever Cloud sur le DevOps or Dev + Ops ?
    https://www.youtube.com/watch?v=pqKPGP06vqs

#### 1. Basic content organization of Ansible

---

Ansible can have many different organizations...
Check the documentation and particularly ["Best Practices - content-organization"](https://docs.ansible.com/ansible/2.9/user_guide/playbooks_best_practices.html#content-organization)

There's standards but keep in mind you can organized it as you wish, key is to keep it organized AND comprehensible by you and your fellow workers !

```
├── ansible.cfg                   # Certain settings in Ansible are adjustable via this configuration file.
├── bin                           # Not a convention, but you can keep in there some custom mandatory binaries (utilities)
│   ├── list_tags.py
│   ├── vault-backup.py
│   └── vault-restore.py
├── CHANGELOG.md                  # Still a nice to have in EVERY project
├── collections                   # Where to store Galaxy collections
│   ├── ansible_collections
│   └── requirements.yml          # Where to put collections requirements
├── docs                          # Never underestimate the need of a good documentation
│   ├── benchmarks
│   ├── everyday
│   ├── ...
├── filter_plugins                # Custom filters, usefull
│   ├── manala.py
│   ├── __pycache__
│   └── rix.py
├── group_vars                    # Allow to assign variables to a group of hosts
│   ├── all.yml
│   ├── host_web_prod.yml
│   ├── host_web_staging.yml
├── host_vars                    # Allow to assign variables specifics to a host
│   ├── host_web-01.prod.yml
│   ├── host_mysql-01.prod.yml
├── inventories                  # Where to define our hosts
│   ├── host-web-01.prod.yml
│   ├── host-web-02.prod.yml
│   ├── host-web.staging.yml
├── lookup_plugins               # Lookup plugins are an Ansible-specific extension to the Jinja2 templating language.
│   ├── manala_vault.py
│   └── rix_merge.py
├── Makefile
├── playbook_vault.yml           # Blueprint of automation tasks
├── playbook.yml                 # Blueprint of automation tasks
├── README.md                    # MANDATORY to quickly explain to your teams how your project is working and what he's doing.
├── scripts
│   ├── db-sync.sh
│   ├── dedicated_post_install.sh
│   ├── migrate_ids.sh
│   ├── openstack
│   └── sensu
├── templates
│   ├── all
│   ├── iut_website_prod
│   ├── iut_website_staging
└── vars
    └── ssh_keys.yml
```

#### 2. Inventories configuration

---

First, let's have look of some parameters keys for inventories configuration

- `ansible_connection: smart`
  Generally, we use SSH connection to connect to the host. SSH protocol types are `smart`, `ssh` or `paramiko`
  Ansible can use non-SSH connection, the other connector available is : `local`, `docker` usefull when provisionning localhost (as we did for the VM with the init script).

- `ansible_host: `
  The name og the host or ip to connect to

- `ansible_port: 22`
  The ssh port number to connect to

- `ansible_user: `
  The ssh user name to connect to

##### _- Specific to the SSH connection:_

- `ansible_ssh_pass: `
  The ssh password, if needed, to connect to (in real life we don't want to use it AND if we need to, we won't go store it in there !)

- `ansible_ssh_private_key_file: `
  The ssh private key file, if needed, to connect to

- `ansible_ssh_extra_args: `
  The ssh extra arguments, if needed, to connect to

##### _- Specific to privilege escalation:_

- `ansible_become: `
  Decides if privilege escalation is used or not. Values can be `yes` or `no` (need to have privilege escalation tool available on yout target host)

- `ansible_become_method: sudo`
  Which privilege escalation method to use, valid choices: `[ sudo | su | pbrun | pfexec | doas | dzdo | ksu | runas | machinectl ]`

- `ansible_become_user: root`
  Run operations as this user

- `ansible_become_pass: `
  Set the privilege escalation password. It's recommended to use [ansible vault](https://docs.ansible.com/ansible/latest/vault_guide/index.html) or better an external vault tool as [Hashicorp vault](https://www.vaultproject.io/)

##### _- Complete list_

You can find complete list here:
https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html#connecting-to-hosts-behavioral-inventory-parameters

#### 3. Working with inventory

---

An inventory in the Ansible world is simply a file build up with hosts and groups

Write a host file configuration in hosts.yml.
In this example, we have 2 remote hosts on OpenStack

```yaml
# in file example-hosts-01.yml
all:
  hosts:
    debian_vm-01:
      ansible_host: your.debian.vm.01.ip
      ansible_user: debian
    debian_vm-02:
      ansible_host: your.debian.vm.02.ip
      ansible_user: debian
```

If you're using Ansible from inside a VM on OpenStack, you can replace the corresponding host configuration like this example:

```yaml
all:
  hosts:
    debian_vm-01:
      ansible_host: 127.0.0.1
      ansible_connection: local
```

##### _- Discover the `ansible-inventory` commands_

Use the following command to check your inventory:

```bash
ansible-inventory --list -i inventories
```

Ansible can handle a folder of inventories in entry or a file therefore you can also use: `ansible-inventory --list -i inventories/example-hosts-01.yml`

The result is displayed on json format. Try with the option `-y` to display it on yaml format

You can check the documentation:
https://docs.ansible.com/ansible/latest/cli/ansible-inventory.html

##### _- Our first group of hosts_

Now, add a `webservers` group of hosts like:

```yaml
# in file example-hosts-02.yml
all:
  hosts:
    debian_vm-01:
      ansible_host: your.debian.vm.01.ip
      ansible_user: debian
    debian_vm-02:
      ansible_host: your.debian.vm.02.ip
      ansible_user: debian
  children:
    webservers:
      hosts:
        debian_vm-01:
        debian_vm-02:
```

Check again your inventory with the command

```bash
ansible-inventory --list -i inventories
```

Try it with the `--graph` action instead of `--list`

##### _- Inventories load order_

Hosts enumeration order is very important. Let's add a property on `debian_vm-02` as following (in the file `example-hosts-01.yml`):

```yaml
all:
  hosts:
    debian_vm-01:
      ansible_host: your.debian.vm.01.ip
      ansible_user: debian
    debian_vm-02:
      ansible_host: your.debian.vm.02.ip
      ansible_user: debian
      ansible_port: 22
  children:
    webservers:
      hosts:
        debian_vm-01:
        debian_vm-02:
```

And try again the inventory command, what is happening ?
Now try to modify an existing key !

##### _- Two other groups of hosts_

Add two other groups like:

```yaml
# in file example-hosts-03.yml
all:
  children:
    staging:
      hosts:
        debian_vm-01:
    prod:
      hosts:
        debian_vm-02:
```

And play with the `ansible-inventory` command.

##### _- Exercise 1:_

Transform `example-hosts-03.yml` by compiling all informations in one single file.

You can test your inventory by specifying a specific file instead of a folder:

```bash
ansible-inventory --list -i inventories/example-hosts-03.yml
```

Answer in the file: [`inventories/example-hosts-03.yml`](inventories/example-hosts-03.yml)

You don't need `example-hosts-01.yml` and `example-hosts-02.yml` anymore.

##### _- Exercise 2:_

Transform this last inventory in non-Yaml file
(Help, can be find, on documentation: https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html#inventory-basics-formats-hosts-and-groups)
Answer in the file: [`inventories/example-hosts-03`](inventories/example-hosts-03)

##### _- Groups of groups_

The inventory hierarchy can have many levels. And have groups on groups...
You can check the documentation:
https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html#inheriting-variable-values-group-variables-for-groups-of-groups

#### 4. Working with patterns

---

Now that we have a little infrastructure, let's go to play with patterns.

We can use some patterns to decide which hosts to connect and manage
We have already see some simple patterns:

`all` the equivalent is `*`
`hostname` or `ip` (Example: `debian`)

Wildcards can be use on `ip` or `hostname` (Example: `192.168.140.*` or `*.example.com`)

However, the most important patterns are `:`, `:&`, `:!` because we can play with ours inventories and groups

##### _- `:` equivalent to OR_

This means the host may be in either one group **or** the other

Try to ping `staging` **OR** `prod` group

```bash
ansible 'staging:prod' -i inventories/example-hosts-03.yml -m ping
```

##### _- `:&` equivalent to AND_

This means the hosts must be in a group **and** also in the other group

Try to ping `webservers` **AND** `staging` group

```bash
ansible 'webservers:&staging' -i inventories/example-hosts-03.yml -m ping
```

You can also try the `--host=` action of `ansible-inventory`

```bash
ansible-inventory --host='webservers:&staging' -i inventories/example-hosts-03.yml
```

##### _- `:!` equivalent to EXCLUDE_

This means the hosts must be in a group **but not** in the other group

Try to ping `webservers` **BUT NOT** `prod` group

```bash
ansible 'webservers:!prod' -i inventories/example-hosts-03.yml -m ping
```

You can also try the `--host=` action of `ansible-inventory`

```bash
ansible-inventory --host='webservers:!prod' -i inventories/example-hosts-03.yml
```

##### _- Multiple combinations_

Try to ping `webservers` **OR** `staging` **BUT NOT** `prod` group (this is not significant here but it's to play)

```bash
ansible 'webservers:staging:!prod' -i inventories/example-hosts-03.yml -m ping
```

You can also try the `--host=` action of `ansible-inventory`

```bash
ansible-inventory --host='webservers:staging:!prod' -i inventories/example-hosts-03.yml
```

Note: you can mix patterns

```bash
ansible-inventory --host='webservers:staging:!debian_vm-02' -i inventories/example-hosts-03.yml
```

##### _- The complete documentation of patterns_

https://docs.ansible.com/ansible/latest/inventory_guide/intro_patterns.html

#### 5. Working with host and group variables

---

It's possible de define variables for each host and group directly on inventory file, however this is not a good practice.
And we will see later, what is the others possibilities

```yaml
# in file example-hosts-04.yml
all:
  hosts:
    debian_vm-01:
      ansible_host: your.debian.vm01.ip
      ansible_user: debian
      custom_hostname: lppro.debian.staging
    debian_vm-02:
      ansible_host: your.debian.vm02.ip
      ansible_user: debian
      custom_hostname: lppro.debian.prod
  children:
    webservers:
      hosts:
        debian_vm-01:
        debian_vm-02:
    staging:
      hosts:
        debian_vm-01:
      vars:
        env: staging
    prod:
      hosts:
        debian_vm-02:
      vars:
        env: prod
```

Check your inventory with `--graph` action and `--vars` option

```bash
ansible-inventory --graph -i inventories/example-hosts-04.yml --vars
```

#### 6. Working with `host_vars` and `group_vars` folder

---

The best way and practice to use variables on Ansible is to splitting out them on specific files

##### _- `host_vars` files_

These files can contains any variables relative to hostname.
These files must be in a `host_vars` directory and the file name need to be the **name of hostname** (with extension .yml/.yaml for yaml file type)

Example for **debian_vm-01** hostname:

```
host_vars/debian_vm-01.yml
```

```yaml
# in host_vars/debian_vm-01.yml
custom_hostname: lppro.debian.staging
```

```yaml
# in host_vars/debian_vm-02.yml
custom_hostname: lppro.debian.prod
```

So our inventory file can be simplified, youc can delete files `example-hosts-03.yml` and `example-hosts-04.yml` and create:

```yaml
# in example-hosts-05.yml
all:
  hosts:
    debian_vm-01:
      ansible_host: your.debian.vm.01.ip
      ansible_user: debian
    debian_vm-02:
      ansible_host: your.debian.vm.02.ip
      ansible_user: debian
      ansible_port: 22
  children:
    webservers:
      hosts:
        debian_vm-01:
        debian_vm-02:
    staging:
      hosts:
        debian_vm-01:
      vars:
        env: staging
    prod:
      hosts:
        debian_vm-02:
      vars:
        env: prod
```

Let's have a look: `ansible-inventory --graph -i inventories/example-hosts-04.yml --vars`

##### _- `group_vars` files_

As `host_vars`, group of hosts can have a specific file too

The `group_vars` files must be store on a `group_vars` directory.

So for the group `staging`, we will have

```
group_vars/staging.yml
```

This file can contains any variables relative to this group

```yaml
#in group_vars/staging.yml
env: staging
```

Note: This work as well with a subdirectory who have the group name, example with

```
group_vars/prod/main.yml
```

contening:

```yaml
#in group_vars/prod/main.yml
env: prod
```

And let's simplify again our inventory

```yaml
# in example-hosts-05.yml
all:
  hosts:
    debian_vm-01:
      ansible_host: your.debian.vm.01.ip
      ansible_user: debian
    debian_vm-02:
      ansible_host: your.debian.vm.02.ip
      ansible_user: debian
      ansible_port: 22
  children:
    webservers:
      hosts:
        debian_vm-01:
        debian_vm-02:
    staging:
      hosts:
        debian_vm-01:
    prod:
      hosts:
        debian_vm-02:
```

Don't forget `all` is a group too. So you can have variables for all group and host

Let's create a file `all.yml` inside the `group_vars` folder with the following content:

```yaml
#in group_vars/all.yml
workshop: ansible
```

And let's give a last run to: `ansible-inventory --graph -i inventories/example-hosts-04.yml --vars`

You can check the documentation:

- https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html#assigning-a-variable-to-one-machine-host-variables
- https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html#assigning-a-variable-to-many-machines-group-variables

##### _- Variables merged_

Ansible have a strategy to merge variables from inventory, host, group files.
The order/precedence is (from lowest to highest):

- all group (because it is the ‘parent’ of all other groups)
- parent group
- child group
- host

You can check the documentation:

- https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html#how-variables-are-merged
- https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_variables.html#variable-precedence-where-should-i-put-a-variable

And of course the complete documentation for Working with inventory
https://docs.ansible.com/ansible/latest/inventory_guide/index.html

#### 7. Last but not least, the facts !

Facts are at the heart to Ansible, they expose target environment's configuration exposed as special variables.
Before going further let's talk about the setup module https://docs.ansible.com/ansible/latest/collections/ansible/builtin/setup_module.html:

```
ansible -i inventories/example-hosts-05.yml debian_vm-01 -m setup
```

Lots of values isn't it ? Fortunately there's filters...

```
ansible -i inventories/example-hosts-05.yml debian_vm-01 -m setup -a "filter=ansible_default_ipv4"
```

And we have some logical operators available as:

```
ansible -i inventories/example-hosts-05.yml debian_vm-01 -m setup -a "filter=ansible_*_version"
```

#### 8. Bonus: Playbook of dump

---

This is a playbook to show/dump all variables for hosts.

Inside the playbook [`dumpall.yml`](dumpall.yml), we can find this following line who define hosts (one or more groups or host patterns) of which machines in your infrastructure to target

```yaml

---
hosts: "{{ env }}"
```

The option `-e` is for extra variables (`--extra-vars`). In this case, we use it to define dynamically hosts value

```bash
ansible-playbook dumpall.yml -i inventories -e "env=staging"
```

#### 8. Exercise 2: Our infrastructure

---

Build the inventory infrastructure and spread parameters values accordingly.

Let's start with a web oriented architecture with 3 components:

- Web server
- Database
- Application

**Infra** : 2 VM

- example: (hostname: ip)
  debian_vm-01: 192.168.140.XX
  debian_vm-02: 192.168.140.XX

**Server Type** :

- web => deployed on 2 VM
- db => deployed on 2 VM
- app => deployed on 2 VM

**Server Environment** :

- staging => 1 VM
- prod => 1 VM

There's no mistake, 1 VM can be several things at once ;)

**Split the following variables accross files** :

- Common for all hosts, the name of the workshop
  - workshop: ansible (could be « project » as well)
- Environnement
  - env: production or staging
- Nginx server version:
  - nginx_version: X.X.X
- Databases:
  - mariadb_version: X.X.X
  - mariadb_username: myUsername (Can be the same for both env, or not)
  - mariadb_password: myPassword (Can't be the same for both env)
- Application:
  - app_version: X.X.X

One solution on git:
Part2-infra
