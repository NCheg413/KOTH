This is an exploit that will attempt to create a backdoor user for a system and work on Linux systems with permissions and internet access by poisoning PAM.
The backdoor makes a user named lacucaracha, the cockroach in Spanish, which can SSH into the system without a valid password.
It will also store the user name and password credentials that other users use to SSH and broadcast it on an HTTP server with this URL: "http://<ipaddr>:49160"
Read the Homework 13 PDF file for installation instructions and a more in-depth look at how it works. The PDF file has the user set to nihargayam. Ignore this and replace all instances of nihargayam with lacucaracha
Please use this responsibly.
