#!/bin/bash

TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
userid=$(id -u)
Validate ()
{
    if [ $1 -eq 0 ]
    then
    echo -e "$2 is:: $G Success $N"
    else
    echo -e "$2 is:: $R Failure $N"
    exit 1
    fi
}

if [ $userid -eq 0 ]
then
echo "User have root previlages"
else
echo "Run with root access"
exit 1
fi

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