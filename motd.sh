#!/bin/bash
################################################################################
#
# Creates the MOTD displayed when connecting to the server. Save as 
# /etc/cron.hourly/motd.sh or where ever you feel suitable define the filename 
# to use as output.
#
# Copyright (C) 2011 Jonathan Gillett, Computer Science Club at DC & UOIT
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
################################################################################
export TERM=xterm
MOTD="/etc/motd"

# Collect useful information about your system
# $USER is automtically defined
#HOST=`uname -n` 
HOSTNAME=`figlet -c 'CS-CLUB  Server'`
KERNEL=`uname -r`
CPU=`uname -p`
ARCH=`uname -m`

# The different colours as variables
W="\033[01;37m"
B="\033[01;34m"
R="\033[01;31m" 
X="\033[00;37m"

# Remove the existing motd
rm -f $MOTD

# Generate the new motd
clear > $MOTD # to clear the screen when showing up
echo -e "$R#=============================================================================#" >> $MOTD
echo -e "	$W Welcome $B $USER $W to" >> $MOTD
echo -e "$B$HOSTNAME" >> $MOTD
echo -e "	$R ARCH   $W= $ARCH                                   " >> $MOTD
echo -e "	$R KERNEL $W= $KERNEL                                 " >> $MOTD
echo -e "	$R CPU    $W= $CPU                                    " >> $MOTD
echo -e "$R#=============================================================================#" >> $MOTD
echo -e "$X" >> $MOTD

main() {

echo
echo -e '\E[0;31m'"\033[1mLatest Logins: \033[0m"
last | head -n 3

echo
echo -e '\E[0;31m'"\033[1mLatest SSH Failures: Total Count:\033[0m $(grep sshd /var/log/auth.log |  awk '/failure/' | wc -l)"
grep sshd /var/log/auth.log | awk '/failure/ {print $1,$2,$3,$10,$11,$12,$15,$14}' /var/log/auth.log | tail -n 5

echo
echo -e '\E[0;31m'"\033[1mLatest 5 /var/log/messages entries: \033[0m"
tail -n 5 /var/log/messages

echo
echo -e '\E[0;31m'"\033[1mLatest Hardware Errors: \033[0m"
dmesg | grep -i error | tail -n 3
echo
echo -e '\E[0;31m'"\033[1mLatest DMESG Messages: \033[0m"
dmesg | tail -n 3
echo -e
echo -ne '\E[0;31m'"\033[1mUptime: \033[0m $(uptime | cut -d " " -f 4-18)"
echo
echo
echo -e '\E[0;34m'"\033[1m       Welcome to $(hostname) - The above info is generated every minute\033[0m"
echo -e '\E[0;34m'"\033[1m                   Have a fun stay and play nice...\033[0m"
echo
}
main >> $MOTD

