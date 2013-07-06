#!/bin/bash
#
# Plesk Migration Launcher Script Ver 0.1
# https://github.com/cypx/pleskmigrationlauncher
# Copyright (c) 2013 Cyprien Devillez info<AT>cytek.fr
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

LANG=C
LC_MESSAGES=C

LOG_INFO=/tmp/pleskmigrationlauncher.log
LOG_ERROR=/tmp/pleskmigrationlauncher.err

#PATH to your PSA install folder
#ex: /opt/psa
PSA_FOLDER= _HERE_THE_PATH_TO_PSA_FOLDER_ 
#first create & run task with Plesk Panel 
#and look into _PSA_FOLDER_/PMM/msessions/
#to find the session ID
PSA_MIGRATION_SESSION=_PSA_MIGRATION_SESSION_ID

#email address to send log
ADMIN_EMAIL=_YOUR_EMAIL_
EMAIL_SUBJECT="Plesk migration task"

# check if we are the only local instance
myPID=$(pidof -x $(basename $0) -o %PPID)
if  [ -n "$myPID" ] ; then
   echo "This script is already running with PID ($myPID)"
   exit
fi

[ -s $LOG_INFO ] && > $LOG_INFO
[ -s $LOG_ERROR ] && > $LOG_ERROR

NEW_SESSION=`date '+%Y%m%d%H%M%s' | cut -b1-17`

TS=`date '+%Y%m%d-%H%M'`
echo -e "\n######### $TS Start of Plesk migration task   ##########" >> $LOG_INFO
$PSA_FOLDER/admin/bin/pmmcli --migration-start $PSA_MIGRATION_SESSION >> $LOG_INFO 2>> $LOG_ERROR

TS=`date '+%Y%m%d-%H%M'`
echo -e "\n#### $TS  End OF PLESK migration task  ####" >> $LOG_INFO


if [ -s $LOG_ERROR ]
then
        MAIL_REPORT=/tmp/pleskmigrationlauncher.tmp
        cat $LOG_INFO > $MAIL_REPORT
        echo -e "\n############   ERROR DETAIL   #############" >> $MAIL_REPORT
        cat $LOG_ERROR >> $MAIL_REPORT
        mail -s "[ERROR] EMAIL_SUBJECT" $ADMIN_EMAIL < $MAIL_REPORT
else
        mail -s "[info] $EMAIL_SUBJECT" $ADMIN_EMAIL < $LOG_INFO
fi