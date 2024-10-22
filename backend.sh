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

dnf module disable nodejs -y &>>$LOGFILE
Validate $? "Disabling Nodejs"

dnf module enable nodejs:20 -y &>>$LOGFILE
Validate $? "Enabling Nodejs"

dnf install nodejs -y &>>$LOGFILE
Validate $? "Installing Nodejs"

id expense

if [ $? -ne 0 ]
then
useradd expense
else
echo "User is already added"
fi
mkdir -p /app
rm -rf /tmp/*
curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip
cd /app
unzip /tmp/backend.zip
npm install &>>$LOGFILE

cp /home/ec2-user/expenses-with-shell1/backend.service /etc/systemd/system/backend.service

systemctl daemon-reload &>>$LOGFILE
Validate $? "Daemon reloading"

systemctl start backend &>>$LOGFILE
Validate $? "Starting backend"

systemctl enable backend &>>$LOGFILE
Validate $? "Enabling backend"

dnf install mysql -y &>>$LOGFILE
Validate $? "Installing mysql"

mysql -h db.devops4srav.online -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$LOGFILE
Validate $? "Loading Schema"

systemctl restart backend &>>$LOGFILE
Validate $? "Restarting backend"