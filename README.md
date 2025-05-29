This is an exploit that will attempt to create a backdoor user for a system and work on Linux systems with permissions and internet access by poisoning PAM.
The backdoor makes a user named lacucaracha, the cockroach in Spanish, which can ssh into the system without a valid password.
It will also store the user name and password credentials that other users use to ssh and broadcast it on an HTTP server with this URL: "http://<ipaddr>:49160"
Read the Homework 13 pdf file for installation instructions and a more in-depth look at how it works.
Please use this responsibly.
