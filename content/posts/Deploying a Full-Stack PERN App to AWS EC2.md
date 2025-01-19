---
title: "Deploying a Full-Stack PERN App to AWS EC2"
date: "2024-08-16"
summary: "A full walkthrough for manual deployment."
description: "A full walkthrough for manual deployment."
toc: false
readTime: true
autonumber: false
math: true
tags: ["postgres", "react", "aws", "node"]
showTags: true
hideBackToTop: false
draft: false
devto: true
---

Roast is officially live! And you can visit it at the following link!

[Roast: Know Your Home Roasts](https://roast.nolanmiller.me/)

In this post, I’m going to go over, broadly how I deployed my full stack application on an AWS EC2 Instance.

## Deploying a Full-Stack PERN App to EC2

So, the code for my project was ready to ship, and I had to decide on a hosting solution. II like EC2, because it's just a virtual Linux machine in one of AWS’s datacenters! You have complete customization ability, but that also means the configuration can be a bit of a bear if you’re not used to working with the command line.

If you have a project that you’re looking to host, grab your code and follow along!

### 1. Spin Up an EC2 Instance

- If you don’t already have an AWS account, create one now, and navigate to the EC2 product.
- From the dashboard, hit **“Launch Instance.”** Provide a name for your server and then select an image. I went with Ubuntu for this because its easy to work with and its still free teir eligible.
- Create a key pair, and save the key pair to somewhere on your computer. You’ll need this to SSH into your EC2 instance later.
- In the Network settings tab, create a new security group that allows SSH traffic from your IP and allows HTTP and HTTPS traffic from the internet! (If you click Edit, you can name this security group whatever you’d like. The “launch-wizard” name can get a little confusing.)
- The rest of the settings can be left at default and then you can launch your instance!

### 2. Install Your Dependencies and Code

To host your project here, you’ll have to find a way to get your project onto the EC2 instance. But, first that means you’ll have to connect via SSH.

- Using your preferred shell on your local computer, navigate to the directory that you saved your key pair to from earlier. Then, in your browser, on AWS’s EC2 instances page, click on “Connect” in the upper right. From here, you can click on “SSH client” and it will give you a list of instructions on how to connect to your EC2 Instance. It involves running the following commands

```
chmod 400 "<yourkey>.pem"
ssh -i "<yourkey>.pem" ubuntu@<your-instance>.compute.amazonaws.com
```

- Once you’re in, you'll want to update and upgrade the built-in package manager apt

```
sudo apt update
sudo apt upgrade
```

- My project runs on node, so I needed to install node and npm as dependencies for my project

```
sudo apt install nodejs
sudo apt install npm
```

- Then, make sure that node, npm and git are installed. If they are, these commands will give a version number

```
node -v
npm -v
git -v
```

- Now, to get code onto this machine, perform a git clone on your github repo. This snipped is my repo, you’ll get the URL by just copy and pasting it from your browser. I like to use git for this rather than other command line tools, because with a personal-access token I can push any changes back to github (because trust me, you’ll make changes).

```
git clone https://github.com/nmiller15/roast.git
```

- Install your dependencies with an install command, and build your application if needed. I have a React application stored in a directory called frontend, and an api stored in a directory called backend.

```
cd roast/frontend     # get to my React app
sudo npm i            # install dependencies
npm run build         # create the production build
cd ../backend         # navigate to my api directory
sudo npm i            # install dependencies
```

- At this point, it's a good thing to check to see if your application(s) are running as expected. You can run the start command in the terminal. To see if it's working, go to your Security Group settings in AWS and create a custom inbound rule that allows traffic on the port your app runs on. Then you should be able to access the IP in this format from your web browser 19.168.1.0:3000. The IP address of your server is located on the dashboard for your instance!
- If everything is working normally, go ahead and shut it down. If it’s not then debug until it is! It feels good to have your application accessible over the internet, but we still need to daemonize the application, give it a domain name and serve it securely.
- Don’t forget to close the security rule you opened up for testing!

### 3. Set Up Your Database

I chose Postgres for my database for this application. But, the same general steps would apply for MySQL or SQLite. Essentially, you have to walk through everything that you did to create your database on your local machine in the cloud. If you set your database up on a third party service, then go ahead and skip this step!

- Install postgress, start it and enable it so that it will launch on an instance reboot.

```
sudo apt install postgresql postgresql-contrib

sudo systemctl start postgresql@16-main
sudo systemctl enable postgresql@16-main
```

- You may have to access the database configuration files to ensure that you can access it locally.
- Figure out where your conf file is using the command:

```
sudo -u postgres psql -c 'SHOW config_file'
```

- Then, using that command, open up your configuration file with the command

```
sudo nano /etc/postgresql/16/main/postgresql.conf
# Replace my path with the path to your conf file
```

In this file, we’re just checking a couple of things:

- See where your hba_file is located, it should be in the same directory as this file. You'll find this under FILE LOCATIONS
- Then under CONNECTIONS AND AUTHENTCATION, ensure that you have ‘localhost’ listed as a value for `listen_addresses`
- You should also set the port that you would like the database to listen on from here.
- To exit, hit ctrl+X. You will be propted to hit Y and Enter if you’ve made any changes to save them.

Then let’s make sure the hba file is set up properly:  

```
sudo nano /etc/postgresql/16/main/pg_hba.conf
```

If you’re planning to access your database from this EC2 instance only (an api calling it), then make sure that you have the following listed:  

```
local all all trust
```

Do a little bit of Googling on the permissions you’ll need to set if you’re planning on exposing the database to the Internet.

Now, it’s time to start creating your database, so we’ll do that from psql, the postgresql CLI.  

```
psql -U postgres

# You'll know you have it when you see
postgres=#
```

I’m not going to walk through how to create a database here, that’s for another blog post. But, make sure that you go through all these things:

- Create a database
- Create your tables with the same columns and keys
- Create any sequences that you will need on those tables
- Create any users that you’re planning on using with the database
- Grant all of the needed permissions to those users
- Test the users by quitting psql (`\q`) and connecting as the role you created, is there any action that you cannot perform that you need to?

Just as a note here, I would not allow your app to connect to the database as `postgres` . This is a superuser, and its not a great idea to have your application accessing your database as a superuser in production. You'll miss some permissions when you're testing, sure, but its better than having your database dropped!

### 4. Create Your Environment Variables

To connect to the database, or to access an api with a key, you’ll be using environment variables. You can create them in a file that you put in the /etc/ directory  

```
touch /etc/app.env
sudo nano /etc/app.env
```

Inside this file, create the variables that you need in the following format:  

```
KEY=value
SOME_OTHER_KEY=thismuchlongervalue
```

Once you’ve saved these, we will lock down the file, so that its only accessible to the ubuntu user, who will be runninng our services.  

```
sudo chmod 600 /etc/app.env
sudo chown ubuntu:ubuntu /etc/roast.env  # Name this file whatever you'd like
```

### 5. Daemonize Your Application

We’re going to now run the application as a service, so that it runs in the background of our computer. I had to do this twice, once for my api and a second time for my react application.  

```
sudo nano /etc/systemd/system/roast-api.service  # You can name the service file anything you'd like
```

```
[Unit]
Description=Roast API                        # Replace with your app name
After=network.target multi-user.target

[Service]
User=ubuntu                                  # The user running the service
WorkingDirectory=/home/ubuntu/roast/backend  # The root of your app
ExecStart=/usr/bin/npm start                 # Execute command for app
Restart=always                               # Service restarts after crash 
Environment=NODE_ENV=production
EnvironmentFile=/etc/roast.env               # The name of your env file
StandardOutput=syslog                        # Console logs
SyslogIdentifier=roast-api                   # An identifier for the logs

[Install]
WantedBy=multi-user.target
```

I had to do this a second time for my React application  

```
sudo nano /etc/systemd/system/roast-ui.service
```

```
[Unit]
Description=Roast UI App
After=network.target multi-user.target

[User]
User=ubuntu                                  
WorkingDirectory=/home/ubuntu/roast/frontend/
ExecStart=/usr/bin/serve -s build    # React is served from build
Restart=always                       # in production
Environment=NODE_ENV=production
EnvironmentFile=/etc/roast.env
StandardOutput=syslog
SyslogIdentifier=roast-ui

[Install]
WantedBy=multi-user.target
```

Then to make sure that systemd has the proper configurations for these services, and to start the service and make sure they run on boot:  

```
sudo systemctl daemon-reload

sudo systemctl start roast-api.service
sudo systemctl start roast-ui.service

sudo systemctl enable roast-api.service
sudo systemctl enable roast-ui.service
```

To check to see that a service is running, you can use the following commands:  

```
# Check current status of service
sudo systemctl status roast-api               # Use SyslogIdentifier

# Check logs of the service
sudo journalctl -u roast-api

# Live logs
sudo journalctl -f -u roast-api
```

Once you reach this point, if everything is working properly, you’ll be able to open up the security rules on the appropriate ports in AWS, and check that your app is accessible using the IP address and port number.

If you’re running into a 404 error, double check that you’re serving from the correct directory. Remeber that WorkingDirectory in your service file should be the directory that you must be in to run your start command.

### 6. Point a Domain Name to Your EC2 Instance

I used AWS Route 53 to do this, but you can use just about any DNS provider with a domain name that you own. The general steps are:

1. Provision a subdomain (if you're using one)
2. Connect your DNS provider to your domain provider (all the major services have walkthroughs for this).
3. Point the subdomain to the IP address of your EC2 instance using an A record.
4. Wait anwhere from 2 minutes to 48 hours for DNS to propogate. (Mine actually took in about five minutes, but this is not typical)

### 7. Set up Caddy as a Reverse Proxy to Serve the App over HTTPS

I’ve used NGINX for this before, but the amount of configuration and managing SSLs on your own can be kind of a pain. Caddy is **way** better if you don't need a ton of configuration.

I did have to go back in and add some extra bits to my configuration to make sure that cookies were allowed to be sent over the proxy. But, 10/10, would caddy again.

- Install Caddy

```
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https curl
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update
sudo apt install caddy
```

- Edit the configurations in the Caddyfile

```
sudo nano /etc/caddy/Caddyfile
```

```
:80 {
  reverse_proxy localhost:3000
}
```

```
sudo systemctl restart caddy
```

So, this will serve my React application over port 80, but I’d still have to go to the IP address directly. Plus, I have an api that I need to expose as well.

Here’s the best part about caddy, all I have to do to serve both of these applications over HTTPS on my subdomains is edit the Caddyfile again to the following:  

```
roast-api.nolanmiller.me {
   reverse_proxy localhost:8080
}

roast.nolanmiller.me {
    reverse_proxy localhost:3000
}
```

```
sudo systemctl restart caddy
```

Done!

My SSL certs will be manually updated, and I didn’t even have to worry about installing them. It’s a 7 line config file! (Like I said, mine did get a _tiny_ bit longer when I was troubleshooting cookies).

## Deployed!

That’s it! Now, don’t let me fool you, this process took me a while, and it was not as smooth as this blog post made it look. I got stuck in so many places: permissions with my database users, misnaming environment files, figuring out the execute command for my react application, debugging random fetch request and cors issues that I wasn’t having on my localhost.

But, this is the basic process!

And to prove that it’s done! Head on over to [roast.nolanmiller.me](https://roast.nolanmiller.me/) and make an account, roast a some coffee beans and let me know what you think!

(FYI, Add the site to your mobile home screen to see the app how it was intended!)