#!/bin/bash
source ./common.sh

check_root

echo "Please enter DB Password:"
read mysql_root_password

dnf module disable nodejs -y &>>$LOGFILE
Validate $? "Disabling Nodejs"

dnf module enable nodejs:20 -y &>>$LOGFILE
Validate $? "Enabling Nodejs"

dnf install nodejs -y &>>$LOGFILE
Validate $? "Installing Nodejs"

id expense &>>$LOGFILE

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

cp /home/ec2-user/practice-shell1/backend.service /etc/systemd/system/backend.service

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