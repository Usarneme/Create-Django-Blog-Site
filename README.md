# Create-Django-Blog-Site

Script for generating a Python+Django blogging site; includes boilerplate folders and files for site administration, venv, and blog posts CRUD.

---

## Instructions for use

You can clone this github repo but all you need is what is in the setup_script.sh file. Other requirements are MacOSX or Linux (this is not tested on Windows)

0. Be in a directory where you want to start a Python+Django blog web application
1. Create a file called setup_script.sh
2. Copy the contents of setup_script.sh from this repo to your file [link to file](https://raw.githubusercontent.com/Usarneme/Create-Django-Blog-Site/main/setup_script.sh)
3. Run the script with `sh setup_script.sh` and follow the instructions:

- a. Input a name of the project which should contain only upper and lower case letters, no spaces, no numbers, no special characters and hit enter
- b. Input a name of the python environment you want created for this project and hit enter, see [https://docs.python.org/3/tutorial/venv.html](https://docs.python.org/3/tutorial/venv.html) for more info about venv in Python
- c. Input a username for the administrator of your new blog and hit enter
- d. Input an email address for the administrator of the blog and hit enter
- e. Input a password and hit enter
- f. Confirm the password by typing it again and hit enter
- g. OPTIONAL: If your password is not secure enough this will warn you but you can bypass the warning by accepting the risk (Hit Y and enter)

4. Your app is now installed and ready to be run; follow the final instructions on the screen to start a local webserver to view your blog

- a. Type `source MYVENV/bin/activate` and hit enter, where MYVENV is what you entered in step 3b. above
- b. Type `python manage.py runserver` and hit enter
- c. Go to localhost:8000 in your browser of choice

---

## Requirements

- Mac OSX or Linux
- Bash at least version 3
- Folder and file creation privileges for where you are trying to run the script
- Execute privileges for the script

NOTE: Not tested on Windows; this is a POSIX-compliant script but your mileage may vary if you try and run it via git-bash or another POSIX-similar Windows terminal client.

---

## LICENSE

### GPLv3

Feel free to share and use this as you'd like. No warranty. As is. No copyright. This was a learning project for me to work with Django and tinker with scripting project setups.

---

Thanks!
