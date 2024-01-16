#### Intro - Video & Deploy pattern

---

##### One video to up a webserver with Ansile:

- https://www.youtube.com/watch?v=DwNapBHypE8

##### Deploy with Zero Downtime Deployment & Pattern

- https://blog.octo.com/zero-downtime-deployment/

##### A piece of DevOps Culture

- The pdf on this repository

#### 1. Yaml Syntax

---

YAML (YAML Ain't Markup Language) is a human-readable data serialization language.

You can find more information on following links:

- https://docs.ansible.com/ansible/2.9/reference_appendices/YAMLSyntax.html
- https://yaml.org/
- http://lzone.de/cheat-sheet/YAML

#### 2. Basic on Playbook

---

##### _- A simple playbook_

```yaml
# in file ping.yml
---
- hosts: web

  tasks:
    - name: Check if host is alive # Description of the task
      ansible.builtin.ping:
```

To execute a playbook call `ansible-playbook` command with inventory

```shell
ansible-playbook ping.yml -i inventories
```

A playbook can contain multiple plays

```yaml
# in file ping.yml
---
- hosts: web

  tasks:
    - name: Check if host is alive # Description of the task
      ansible.builtin.ping:

- hosts: db

  tasks:
    - name: Get stats of a file
      ansible.builtin.stat:
        path: /etc/hosts
```

Playbook are run on a specific group or all the hosts:

```yaml
- hosts: prod

  tasks:
    - name: Check if host is alive # Description of the task
      ansible.builtin.ping:
```

Try it with:

```yaml
- hosts: all

  tasks:
    - name: Check if host is alive # Description of the task
      ansible.builtin.ping:
```

_Bonus:_
_- you can display what hosts would be affected by a playbook before run it with:_

```shell
ansible-playbook ping.yml -i inventories --list-host
```

_- you can list tasks on a playbooks:_

```shell
ansible-playbook ping.yml -i inventories --list-tasks
```

_- you can combine options:_

```shell
ansible-playbook ping.yml -i inventories --list-tasks --list-hosts
```

##### _- Hosts and Users_

Each playbook need to know on which machines, and with which remote user, it will be executed.

If remote user is not specified on host definition (into the inventory) you can add it into the playbook:

```yaml
---
- hosts: web
  remote_user: root # This is optional, because by default, the remote user is equal to the ansible user define for remote host connect: ansible_user
```

Remember ! `hosts` value can use [Patterns](https://github.com/moukmessie/ansible-courses/part-2#5-working-with-patterns)

##### _- Privileges Escalation Users_

Playbook can be run with privileges Escalation like `sudo` or just another user

```yaml
---
- hosts: web
  remote_user: debian
  become: yes
  become_user: root # This is the default value, so it is not needed here
  become_method: sudo # This is the default value, so it is not needed here
```

This can also be done on one task

```yaml
# in file nginx.yml
---
- hosts: web
  remote_user: debian

  tasks:
    - name: Ensure Nginx service is started
      service:
        name: nginx
        state: started
      become: yes
      become_user: root # This is the default value, so it is not needed here
```

You can check the complete documentation about Privileges Escalation:
https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_privilege_escalation.html

##### _- Tasks list_

Each play on playbook can contain a list of tasks. Tasks are executed in order and against all machines matching patterns.
**The goal of each task is to execute a module.**
Example: `ping` is a module.
**Modules should be idempotent, that is, running a module multiple times in a sequence should have the same effect as running it just once.**
Every task should have a `name` entry, to provide good descriptions.

Variables can be used, from `group_vars`, `host_vars`, `inventories`,...

```yaml
# in file git.yml
- hosts: app
  vars:
    git_repo: https://github.com/WordPress/WordPress.git
    git_project_name: wordpress
    git_dest: ~/ansible/{{ git_project_name }}
  tasks:
    - name: "Clone git repository - {{ git_project_name }}"
      ansible.builtin.git:
        repo: "{{ git_repo }}"
        dest: "{{ git_dest }}"
        accept_hostkey: yes
      become: no
```

A play on playbook can have four other sections.

- `pre_tasks` A list of tasks to execute before roles.
- `roles` List of roles to be imported into the play.
- `post_tasks` A list of tasks to execute after the tasks section.
- `handlers` A list of tasks who are execute at the end of each block/section of tasks.

##### _- Pre-tasks_

Ansible pretask is a conditional execution block that runs before running the play. It can be a task with some prerequisites check (or) validation.

Let's go back to `nginx.yml`, we want to be sure that apt database index is up to date **before** installing any package.

```yaml
# in file nginx.yml
---
- hosts: web

  pre_tasks:
    - name: APT index update
      apt:
        update_cache: yes

  tasks:
    - name: Ensure Nginx service is started
      service:
        name: nginx
        state: started
```

##### _- Handlers_

Imagine, now we want to change nginx configuration and activate status page.

Let's have a file call `status.conf` inside `files/nginx/` (we need to create this folder) with following content:

```nginx
server {
    listen *:8080;
    root /usr/share/nginx/html;
    access_log off;
    location / {
        return 404;
    }
    location = /nginx/status {
        stub_status on;
    }
}
```

And add the configuration block to our playbook:

```yaml
# in file nginx.yml
---
- hosts: web

  pre_tasks:
    - name: APT index update
      apt:
        update_cache: yes

  tasks:
    - name: Ensure Nginx service is started
      service:
        name: nginx
        state: started
    - name: Copy Nginx configuration file
      copy:
        src: nginx/status.conf
        dest: /etc/nginx/conf.d/status.conf
```

Let's try to hit the page: http://192.168.140.XX:8080/nginx/status
What's going on ?

**Using `notify`**

```yaml
# in file nginx.yml
---
- hosts: web

...
    - name: Copy Nginx configuration file
      copy:
        src: nginx/status.conf
        dest: /etc/nginx/conf.d/status.conf
      notify:
          - restart_nginx
  handlers:
    - name: restart_nginx
      service:
        name: nginx
        state: restarted
```

These `notify` actions are triggered at the end of each block/section of tasks in a play, and will only be triggered once even if notified by multiple different tasks.

The `notify` keyword can be added on any task to indicate to launch a `handler`

```yaml
handlers:
  - name: "restart cron"
    become: yes
    service:
      name: cron
      state: restarted
    listen: "restart cron" #optional, this is for regroup many handlers
```

`listen` can be use to regroup many handlers. So a task can trigger multiple handlers

More information about handlers: https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_handlers.html#handlers

##### _- Modules list_

Ansible comes with a lot of modules.
We have already use some of them: `ping`, `shell`, `debug`...

Modules can be use from command line or in playbook

- Command line

```bash
ansible -i inventories all -m ping
```

- Playbook

```yaml
- hosts: all

  tasks:
    - name: ping host
      ansible.builtin.ping:
```

You can find the complete list of modules on documentation:
https://docs.ansible.com/ansible/latest/collections/index_module.html

#### 3. Exercice 1 : Start to build our infrastructure

---

Base on the [exercise on part-2](https://github.com/moukmessie/ansible-courses/part-2#8-exercise-our-infrastructure)

But, you can rebuild the architecture with the number of VM you want.
You only need to have 2 environments (staging, prod)

Inventory example:

```yaml
all:
  hosts:
    debian_vm-01:
      ansible_host: 192.168.140.XX
      ansible_user: debian
    debian_vm-02:
      ansible_host: 192.168.140.XX
      ansible_user: debian
  children:
    web:
      hosts:
        debian_vm-01:
        debian_vm-02:
    db:
      hosts:
        debian_vm-01:
        debian_vm-02:
    app:
      hosts:
        debian_vm-01:
        debian_vm-02:
    prod:
      hosts:
        debian_vm-01:
    staging:
      hosts:
        debian_vm-02:
```

Now, start to build servers

##### _- On web server:_

- Update APT (as pre task)
- Install nginx
- Check service is up
- Add a custom configuration file (to get status of server over http for example)
- Trigger service restart handler

##### _- On db server:_

- Update APT (as pre task)
- Install mysql
- Check service is up

##### _- On app server:_

- Update APT (as pre task)
- Install git
- Install php7.4-fpm
- Check service is up
- Handle PHP configuration file (`/etc/php/7.4/fpm/php.ini`)
- Trigger service restart handler

One solution on git:
Part-3-infra exercice 2

#### 4. Including and Importing

---

As we can have very large files of playbooks, we would reuse some part of them. Ansible have three differents way to do this: `import`, `include`, `role`

##### _- Import (static) and Include (dynamic)_

- All `import*` statements are pre-processed at the time playbooks are parsed.
  (Ansible pre-processes all static imports during Playbook parsing time.)
  For static imports, the parent task options will be copied to all child tasks contained within the import.
- All `include*` statements are processed as they are encountered during the execution of the playbook.
  (Dynamic includes are processed during runtime at the point in which that task is encountered.)
  For dynamic includes, the task options will only apply to the dynamic task as it is evaluated, and will not be copied to child tasks.

##### _- Importing Playbooks_

It is possible to include playbooks inside a master playbook. For example:

```yaml
- ansible.builtin.import_playbook: webservers.yml
- ansible.builtin.import_playbook: databases.yml
```

##### _- Including and Importing Task Files_

We can also include or import tasks from files. This an excellent way to organize complex sets of tasks or reuse them.

```yaml
# in common_tasks.yml
- name: Ping host # Description of the task
  ansible.builtin.ping:
- name: List home directory
  ansible.builtin.shell: ls -l
```

Then, we can use `import_tasks` or `include_tasks`

```yaml
tasks:
  - ansible.builtin.import_tasks: common_tasks.yml
  # or
  - ansible.builtin.include_tasks: common_tasks.yml
```

This works with the handlers section too.

```yaml
# in handlers.yml
- name: restart nginx
  ansible.builtin.service:
    name: nginx
    state: restarted
```

And in your main playbook file:

```yaml
handlers:
  - ansible.builtin.include_tasks: handlers.yml
  # or
  - ansible.builtin.import_tasks: handlers.yml
```

#### 5. Exercice 2 : Rebuild our infrastructure with `Include*` and/or `Import*`

One solution on git:
part-3 exercice 3

#### 6. `roles`

##### Role directory Structure

```
roles/
   common/
     tasks/
     handlers/
     files/
     templates/
     vars/
     defaults/
     meta/
```

Roles must include at least one of these directories.
Each directory must contain a main.yml file.

- `tasks` - contains the main list of tasks to be executed by the role.
- `handlers` - contains handlers, which may be used by this role or even anywhere outside this role.
- `defaults` - default variables for the role
- `vars` - other variables for the role
- `files` - contains files which can be deployed via this role.
- `templates` - contains templates which can be deployed via this role.
- `meta` - defines some meta data for this role. See below for more details.

It's possible to initialise a directory structure for one role with the following command from roles directory:

```shell script
ansible-galaxy init myRoleName
```

##### How to use a role on playbook

- Basic use:

```yaml
- hosts: webservers
  roles:
    - myRoleName
```

Or/and

```yaml
- hosts: webservers
  tasks:
    - ansible.builtin.import_role:
        name: myRoleName
    - ansible.builtin.include_role:
        name: myRoleName-2
```

You can check the documentation for more details on:
https://docs.ansible.com/ansible/2.9/user_guide/playbooks_reuse_roles.html#using-roles

Exemple complet avec :

- le playbook : [playbook-php.yml](./playbook-php.yml)
- le role : [php](roles/php)

#### 7. Exercice 3: Rebuild our infrastructure with `roles`

Put `nginx`, `mysql` and `php` in roles

One solution on git:
part-3-infra exercice-3

#### 8. Exercice 4: Collections

Collections are a distribution format for Ansible content that can include playbooks, roles, modules, and plugins.
For details informations: https://docs.ansible.com/ansible/latest/collections_guide

Starting with Ansible 2.10, related modules should be developed in a collection.

Installing a collection is done as below

```
ansible-galaxy collection install manala.roles
```

Ansible Galaxy: https://galaxy.ansible.com/

It's also possible to manage « local » collection without the need to use Galaxy (which is, honestly, a pain in the ass)

Let's create the following tree structure inside your working dir:

```
collections/
`-- ansible_collections
    `-- labdevops
        `-- workshop
            `-- roles
```

And move your roles inside `roles` folder.

```yaml
# In playbook.yml
---
- hosts: all

  tasks:
    - import_role:
        name: labdevops.workshop.php
    - import_role:
        name: devops.workshop.nginx
    - import_role:
        name: labdevops.workshop.mariadb
```

#### 9. Exercice 4: Going further

Now we have a web based servers deployed, great !
Why not using some variables ?

Remember the last part ?
Let's copy the group_vars files `prod.yml` and `staging.yml` and use the concept of templates !

Create the folder `templates/nginx/` and inside, the file `index.j2`. Our goal now is to used defined `env` variable to have 2 differents `index.html` served by Nginx depending of the environment (production and staging).

N.B: The Nginx folder used for default page is `/var/www/html/index.html`

### 10. Exercice 5: Using Facts in Playbooks

Facts can be used in a Playbook like variables, using the proper naming, of course. Create this Playbook as `facts.yml`:

```yaml
# in facts.yml
---
- name: Output facts within a playbook
  hosts: all
  tasks:
    - name: Prints Ansible facts
      debug:
        msg: The default IPv4 address of {{ ansible_fqdn }} is {{ ansible_default_ipv4.address }}
```

### 11. Catching variables

It's possible to store result of a task into variable as following:

```yaml
# in ping.yml
---
- hosts: webservers

  tasks:
    - name: Check if host is alive
      ansible.builtin.ping:
      register: capture

    - name: display var
      ansible.builtin.debug:
        msg: "{{ capture.ping }}"

- hosts: databases

  tasks:
    - name: Gest stats of a file
      ansible.builtin.stat:
        path: /etc/hosts

    - name: Collect only specific facts
      ansible.builtin.setup:
        filter:
          - "*distribution"
      register: setup

    - ansible.builtin.debug:
        var: setup

    - ansible.builtin.debug:
        msg: "{{ setup.ansible_facts.ansible_distribution }}"
```
