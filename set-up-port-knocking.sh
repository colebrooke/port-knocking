#!/bin/bash

# simple bash script to set up port knocking on an Ubuntu Linux machine using ufw

command -v ufw >/dev/null 2>&1 || { echo >&2 "Requires 'ufw' firewall, but it's not installed.  Exiting."; exit 1; }

ufw disable
ufw reset

# add your rules here, these are typical for a webserver for example

ufw allow 80 # http
ufw allow 443 # ssl
ufw allow 5666 # nagios nrpe

apt-get install knockd -y

# create knockd.conf
cat "
[options]
       	logfile = /var/log/knockd.log

[openSSH]
       	sequence    = $PORT1,$PORT2,$PORT3
       	seq_timeout = 15
       	command     = ufw allow from %IP% to any port $SSH_PORT
       	cmd_timeout = 300
       	stop_command = ufw delete allow from %IP% to any port $SSH_PORT
       	tcpflags    = syn

[closeSSH]
       	sequence    = $PORT4,$PORT5,$PORT6
       	seq_timeout = 15
       	command     = ufw delete allow from %IP% to any port $SSH_PORT
       	tcpflags    = syn

" > /etc/knockd.conf


