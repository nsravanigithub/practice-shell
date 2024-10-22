#!/bin/bash

#set -e
#trap 'failure ${Line no} "BASH_COMMAND"' ERR

source ./common.sh

check_root()

echo "Please enter DB Password:"
read mysql_root_password

dnf install mysql-server -y &>>$LOGFILE
Validate $? "Installing Mysql server"

systemctl enable mysqld &>>$LOGFILE
Validate $? "Enabling Mysql server"

systemctl start mysqld &>>$LOGFILE
Validate $? "Starting Mysql server"

#mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
#Validate $? "Setting Mysql server root password"

#Below code will be useful for idempotent nature
mysql -h db.devops4srav.online -uroot -p${mysql_root_password} -e 'show databases;' &>>$LOGFILE

if [ $? -ne 0 ]
then
mysql_secure_installation --set-root-pass ${mysql_root_password} &>>$LOGFILE
Validate $? "Setting Mysql server root password"
else
echo -e "DB root password already set...$Y Skipping $N"
fi
