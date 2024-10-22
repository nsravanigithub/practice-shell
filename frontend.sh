#!/bin/bash
source ./common.sh

check_root()

dnf install nginx -y &>>$LOGFILE
Validate $? "Installing nginx"

systemctl enable nginx &>>$LOGFILE
Validate $? "Enabling nginx"

systemctl start nginx &>>$LOGFILE
Validate $? "Starting nginx"

rm -rf /usr/share/nginx/html/*

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOGFILE

cd /usr/share/nginx/html

unzip /tmp/frontend.zip

cp /home/ec2-user/expenses-with-shell1/expense.conf /etc/nginx/default.d/expense.conf

systemctl restart nginx &>>$LOGFILE
Validate $? "Restarting nginx"