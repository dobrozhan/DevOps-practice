### Hi👋👋👋 Welcome to my notes for Telco DevOps Basecamp Spring GlobalLogic!

- ⚡ Initial selection task

  Docker Hub repository containing [build](https://hub.docker.com/repository/docker/dobrozhan/onelinewebserver) image.

- ⚡ Homework 1 - "Ansible"

   1 main host, WSL2 on Windows 10 with IPv4 \
   `IP_0 = 93.170.67.131`\
   3 hosts deployed as instances on GCP (Linux 20.04 LTS) with IPv4\
   `IP_1 = 35.222.77.210`\
   `IP_2 = 34.67.2.54`\
   `IP_3 = 35.225.77.31`\
   Established password-less connection using ssh key-pair generated on main machine and public key injected into instance setting on GCP console.\
   To fetch infromation about distro, I have used the following combination of commands:\
   `lsb_release -d | cut -d":" -f2 | awk '{$1=$1};1'`

   For optional task, please switch branch to **optional**. **Main** branch is the solution for core task.\
   Please, note that instances are shutdown, request me to go this task live (dobrozhan.a@gmail.com).

- ⚡ Homework 2 - "Security hardening"
    
    All testing results are enclosed on [Google Doc](https://docs.google.com/document/d/1j6QeDBlXAxQKk2I4ZHPzLU5qgVu6py67pnz97jmd870/edit?usp=sharing).
    
    Task 1. Prerequisites\
    Two hosts:\
    local WSL2 host - Ubuntu 20.04.2 LTS (`93.170.71.195`) 	          as Debian-based Linux distribution\
    remote GCP host -  CentOS Linux 7 (Core) (`34.134.139.89`)        as RedHat-based Linux distribution\
    The connection has been established by ssh authentication with private-public keys. Public key has been injected to GCP instance using Google console on remote host as           well as added to `~.ssh/authorized_keys` on local host. For the first part, I will use PAM plugin which is part of the community.general collection.\
    The main module to configure - `pam_pwquality.so`. The required parameters for rejecting passwords containing username - `usercheck=1`. To enforce for root, we can apply -       `enforce_for_root` parameter. The main configuration files for Debian (Ubuntu 20.04) - `/etc/pam.d/common-password`. For RedHat (Centos 7) - `/etc/pam.d/system-auth`. It         should be noted that pam_pwquality.so module has been already installed on the hosts by default. Configuration files were found by simple grep command. Also, as                 configuration files are belonging to root, sudoers file has been modified on local machine to allow user modify files with no password.
    
    Task 2. Prerequisites\
    Additional 3rd host (35.226.212.101) for testing purposes.
     
    ...

<!--
**dobrozhan/dobrozhan** is a ✨ _special_ ✨ repository because its `README.md` (this file) appears on your GitHub profile.

Here are some ideas to get you started:

- 🔭 I’m currently working on ...
- 🌱 I’m currently learning ...
- 👯 I’m looking to collaborate on ...
- 🤔 I’m looking for help with ...
- 💬 Ask me about ...
- 📫 How to reach me: ...
- 😄 Pronouns: ...
- ⚡ Fun fact: ...
-->
