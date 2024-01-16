#### 1. Connect to your OpenStack
----


You can follow instructions on the [pdf file](Openstack%20Horizon%20interface%20web%20cliente.pdf) and below

#### 2. Create a security group and open ssh ports
----

The  name of this security group can be something like ```ansible-grpLPDevops-1``` (ex: abcd0123456-grpLPDevops-1)

#### 3. Create a key pairs
----

The name of this key pairs can be like ```yourName-keys```.
**NOTE**: In the professional (as personal) world, the private key is __personal__ and __BY NO MEANS__ should be shared with __ANYONE__ !

#### 4. Init 2 VM/instance on openStack
----

- name: ```ansible-VM-01``` (ex: abcd0123456-VM-01)
- OS: Debian 11
- Volume: 8 Gio
- Gabarit: 1-RAM1Go
- Add your security group and default group
- Add your key pairs
- Add the custom script file provide from this git [```custom-file.sh```](custom-file.sh).

#### 5. Connecting with SSH client
----
## SSH Client configuration

We can change how the SSH client tries to connect by editing the file: `~/.ssh/config`. (See: https://www.rix.fr/blog/cours/utiliser-la-configuration-ssh-client/)

Online documentation:
- **Vscode**: https://code.visualstudio.com/blogs/2019/10/03/remote-ssh-tips-and-tricks#_ssh-configuration-file
- **PhpStorm**: https://www.jetbrains.com/help/phpstorm/create-ssh-configurations.html

Try to add this code block:

```ssh
Host 192.168.*.*
  Port 22
  User debian
  IdentityFile /home/nickname/.ssh/makey.pem
  IdentitiesOnly yes
  ForwardAgent yes
```

Replace the entry `IdentityFile` by your own path's key :
- Windows: `C:\Users\MonNomUtilisateur\.ssh\Makey.pem`
- MacOs/Linux: `~/.ssh/Makey.pem`

Replacing `Makey.pem` by the name of the **PRIVATE** key you downloaded via [OpenStack](https://iutdoua-os.univ-lyon1.fr/).
Following this, you can move the key file in this same folder.

#### 6. Connection
----
- Connect with ssh client (cf file: [`config`](config) on this repo):
    - Your remote host ip: ```ex: 192.168.140.XX```
    - Username: (The username depends of OS (debian / ubuntu).)

#### 9. Init this project on your VM - OpenStack
----
- Connect with ssh to your Debian VM (the first one)

- Create a new ssh key on the VM
Enter the command :
```shell script
ssh-keygen
```
And leave default response for all.

This key will be generated into ssh default user folder (like /home/debian/.ssh)
Get the value of the ssh public key generated
```shell script
cat /home/debian/.ssh/id_rsa.pub
```

- Add you key on gitlab (forge)
  https://forge.univ-lyon1.fr/help/user/ssh.md#add-an-ssh-key-to-your-gitlab-account

- Use git clone command to get this repo

    ```git clone git@******/part-1.git```

- Remove git: Delete .git folder

    ```cd part-1 && rm -rf .git```

#### 10. Ping the second VM with Ansible ping module ```-m ping```
----

- Fix your parameters on hosts and hosts.yml files with the information of the second VM
    - ansible_host
    - ansible_ssh_private_key_file

- Transfer your private_key_file (created on OpenStack) on `part-1` inside `/home/debian/.ssh` folder
- Change permissions if necessary : `chmod 0600 /path/to/public/key`

You can check the official documentation:
- https://docs.ansible.com/ansible/2.10/collections/ansible/builtin/ping_module.html
- https://docs.ansible.com/ansible/2.10/user_guide/intro_getting_started.html#action-run-your-first-ansible-commands

- With hosts.yml file
```bash
ansible -i hosts.yml all -m ping
```
- With hosts file
```bash
ansible -i hosts all -m ping
```

Your can use [verbose](https://fr.wiktionary.org/wiki/verbose) mode with adding ```-v or -vv or -vvv or -vvvv```, depending of the level of verbose.
```bash
ansible -i hosts.yml all -m ping -vvv
```

#### 11. Bonus: Try the shell module (```-m shell```) of Ansible
----

- This next command create a text file and write ```hello word``` on it
```bash
ansible -i hosts.yml all -m shell -a "touch hello-word.txt && echo 'hello word' > hello-word.txt" -vvv
```

You can access to the documentation from shell command for a ansible module
```bash
ansible-doc shell
```
Or online:
- https://docs.ansible.com/ansible/2.10/collections/ansible/builtin/shell_module.html

List for all ansible collections
- https://docs.ansible.com/ansible/latest/collections/index.html
