#!/bin/bash

## Purpose: Setup Student Application with Web + App + DB Components
## Project: StudentApp Monolithic
## Author: Sam

## Description: This script installs and configures all web components, app components and db components.
##              Complete application setup will be taken care of by this script

### Global Variables

LOG=/tmp/student.LOG
rm -f $LOG
G="\e[32m"
R="\e[31m"
N="\e[0m"

FUSERNAME=student
TOMCAT_VERSION=8.5.47
TOMCAT_URL=http//:apachemirror.wuchna.com/tomcat/tomcat-8/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz
TOMCAT_HOME=/home/$FUSERNAME/apache-tomcat-${TOMCAT_VERSION}
### Functions
Head() {
    echo - e "\n\t\t\t\e[ 1;4;35m $1 \e[0m\n"
}


Print() {
    echo -e "\n\n#........... $1 ...........# " >>$LOG
}

STAT_CHECK() {
    if [ $1 -eq 0 ]; then
    echo -e "- ${G}SUCCESS${N}"
  else
    echo -e "- ${R}FAILURE${N}"
    exit 1
    echo -e "Refer Log:: $LOG for more info"
  fi 
}

## Main Program
Head "WEB SERVER SETUP"
echo "WEB SERVER SETUP"
echo -n "Install Web Server"

USER_ID=$(id -u)
if [ $USER_ID -ne 0 ]; then
   echo -e "You should be root user to proceed!!"
   exit 1
   fi 
yum install nginx -y &>>$LOG 
Print "Install Web Server\t"



Print "Clean old Index files\t"
rm -rf /usr/share/nginx/html/* &>>$LOG

cd /usr/share/nginx/html


Print "Download Index Files\t"
curl -s https://studentapi-cit.s3-us-west-2.amazonaws.com/studentapp-frontend.tar.gz | tar -xz
STAT_CHECK $?
if [ $? -eq 0 ]; then
Print "Update nginx proxy config"
LINE_NO=$(cat -n /etc/nginx/nginx.conf | grep 'error_page 404' | grep -v '#' |awk '{print $1}')
sed -i -e "/^#STARTPROXYCONFIG/,/^#STOPPROXYCONFIG/ d" /etc/nginx/nginx.config
sed -i -e "$LINE_NO i #STARTPROXYCONFIG\n\tlocation /student {\n\t\tproxy_pass http://localhost:8080/student;\n\t}\n#STOPPROXYCONFIG" /etc/nginx/nginx.conf 
STAT_CHECK $?


Print "Starting Nginx Service"
systemctl enable nginx &>>$LOG
systemctl start nginx &>>$LOG
STAT_CHECK $?

Head "APPLICATION SERVER SETUP"
Print "Adding Functional User"
id $FUSERNAME-&>>$LOG
if [ $? -eq 0 ]; then
   STAT_CHECK 0
else
   useradd $FUSERNAME &>>$LOG
   STAT_CHECK
fi 
Print "Install Java\t\t"
yum install java -y &>>$LOG
STAT_CHECK


Print "Download Tomcat\t"
cd /home/$FUSERNAME
curl -s $TOMCAT_URL | tar -xz
STAT-CHECK $?

Print "Download Student Application"
cd $TOMCAT_HOME
curl -s https://s3-us-west-2.amazonaws.com/studentapi-cit/student.war -O webapps/student.war

STAT_CHECK
Print "Download JDBC Driver\t"
cd $TOMCAT_HOME
curl -s https://s3-us-west-2.amazonaws.com/studentapi-cit/mysql-connector.jar -O lib/mysql-connector.jar
STAT_CHECK $?

Print "Update JDBC Parameters"
cd $TOMCAT_HOME
sed -i -e '/TestDB/ d' -e '$ i <Resource name="jdbc/TestDB" auth="Container" type="javax.sql.DataSource" maxTotal="100" maxIdle="30" maxWaitMillis="10000" username="admin" password="admin123" driverClassName="com.mysql.jdbc.Driver" url="jdbc:mysql://database-1.canezjyjgu1i.us-east-1.rds.amazonaws.com:3306/studentapp"/>' conf/context.xml 
STAT_CHECK $?

chown $FUSERNAME:$FUSERNAME /home/$FUSERNAME -R

Print "Download Tomcat init script"
curl -s https://s3-us-west-2.amazonaws.com/studentapi-cit/tomcat-init -O /etc/init.d/tomcat
STAT_CHECK $?

Print "Load Tomcat Script to Systemd"
chmod +x /etc/init.d/tomcat
systemctl daemon-reload &>>$LOG
STAT_CHECK

Print "Start Tomcat Service\t"
systemctl enable tomcat &>>$LOG
systemctl restart tomcat &>>$LOG
STAT_CHECK $?

Head "DATABASE SERVER SETUP"
Print "Install MariaDB Server"
yum install mariadb-server -y &>>$LOG
STAT_CHECK $?

Pint "Start MariaDB Service\t"
systemctl enable mariadb &>>$LOG
systemctl start mariadb &>>$LOG
STAT_CHECK $?

Print "Load Schema\t\t"
curl -s https://s3-us-west-2.amazonaws.com/studentapi-cit/studentapp-ui-proj1.sql -O /tmp/studentapp.sql
mysql <?tmp/schema.sql
STAT_CHECK $?
