#!/bin/bash 

## Purpose : Setup Student Application with Web + App + DB Componenets 
## Project : StudentApp Monolithic
## Author : Blah Blah 

## Description: This script installs and configures all web components, app components and db components.
##              Complete application setup will be taken care by this script. 



### Global Variables
LOG=/tmp/student.log 
rm -f $LOG 
G="\e[32m"
R="\e[31m"
N="\e[0m"
FUSERNAME=student
TOMCAT_VERSION=8.5.47
TOMCAT_URL=http://apachemirror.wuchna.com/tomcat/tomcat-8/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz
TOMCAT_HOME=/home/$FUSERNAME/apache-tomcat-${TOMCAT_VERSION}

### Functions
Head() {
  echo -e "\n\t\t\t\e[1;4;35m $1 \e[0m\n"
}

Print() {
  echo -e "\n\n#--------- $1 ---------#" >>$LOG 
  echo -e -n "  $1\t\t "
}

STAT_CHECK() {
  if [ $1 -eq 0 ]; then 
    echo -e " - ${G}SUCCESS${N}" 
  else 
    echo -e " - ${R}FAILURE${N}"
    echo -e "Refer Log :: $LOG for more info"
    exit 1 
  fi 
}


## Main Program 

USER_ID=$(id -u)
if [ $USER_ID -ne 0 ]; then 
  echo -e "You should be root user to proceed!!"
  exit 1
fi 

Head "WEB SERVER SETUP"
Print "Install Web Server\t"
yum install nginx -y &>>$LOG 
STAT_CHECK $?

Print "Clean old Index files\t"
rm -rf /usr/share/nginx/html/* &>>$LOG 
STAT_CHECK $? 

cd /usr/share/nginx/html/

Print "Download Index files\t"
curl -s https://studentapi-cit.s3-us-west-2.amazonaws.com/studentapp-frontend.tar.gz | tar -xz 
STAT_CHECK $? 

Print "Update nginx proxy config"
LINE_NO=$(cat -n /etc/nginx/nginx.conf | grep 'error_page 404' | grep -v '#' |awk '{print $1}')
sed -i -e "/^#STARTPROXYCONFIG/,/^#STOPPROXYCONFIG/ d" /etc/nginx/nginx.conf
sed -i  -e "$LINE_NO i #STARTPROXYCONFIG\n\tlocation /student {\n\t\tproxy_pass http://localhost:8080/student;\n\t}\n#STOPPROXYCONFIG" /etc/nginx/nginx.conf
STAT_CHECK $? 

Print "Starting Nginx Service"
systemctl enable nginx &>>$LOG 
systemctl restart nginx &>>$LOG 
STAT_CHECK $? 


Head "APPLICATION SERVER SETUP"
Print "Adding Functional User"
id $FUSERNAME &>>$LOG
if [ $? -eq 0 ]; then 
  STAT_CHECK 0 
else 
  useradd $FUSERNAME &>>$LOG 
  STAT_CHECK $? 
fi 

Print "Install Java\t\t" 
yum install java -y &>>$LOG 
STAT_CHECK $? 

Print "Download Tomcat\t"
cd /home/$FUSERNAME
curl -s $TOMCAT_URL | tar -xz
STAT_CHECK $? 

Print "Download Student Application"
cd $TOMCAT_HOME 
curl -s https://s3-us-west-2.amazonaws.com/studentapi-cit/student.war -o webapps/student.war
STAT_CHECK $? 

Print "Download JDBC Driver\t"
cd $TOMCAT_HOME 
curl -s https://s3-us-west-2.amazonaws.com/studentapi-cit/mysql-connector.jar -o lib/mysql-connector.jar
STAT_CHECK $? 

Print "Update JDBC Parameters"
cd $TOMCAT_HOME 
sed -i -e '/TestDB/ d' -e '$ i <Resource name="jdbc/TestDB" auth="Container" type="javax.sql.DataSource" maxTotal="100" maxIdle="30" maxWaitMillis="10000" username="student" password="student@1" driverClassName="com.mysql.jdbc.Driver" url="jdbc:mysql://localhost:3306/studentapp"/>' conf/context.xml 
STAT_CHECK $? 

chown $FUSERNAME:$FUSERNAME /home/$FUSERNAME -R 

Print "Downlaod Tomcat init script"
curl -s https://s3-us-west-2.amazonaws.com/studentapi-cit/tomcat-init -o /etc/init.d/tomcat
STAT_CHECK $? 

Print "Load Tomcat Script to Systemd"
chmod +x /etc/init.d/tomcat
systemctl daemon-reload &>>$LOG 
STAT_CHECK $? 

Print "Start Tomcat Service\t"
systemctl enable tomcat &>>$LOG 
systemctl restart tomcat &>>$LOG 
STAT_CHECK $? 

Head "DATABASE SERVER SETUP"
Print "Install MariaDB Server"
yum install mariadb-server -y &>>$LOG 
STAT_CHECK $? 

Print "Start MariaDB Service\t"
systemctl enable mariadb &>>$LOG 
systemctl start mariadb &>>$LOG 
STAT_CHECK $? 

Print "Load Schema\t\t"
curl -s https://s3-us-west-2.amazonaws.com/studentapi-cit/studentapp-ui-proj1.sql  -o /tmp/schema.sql 
mysql </tmp/schema.sql 
STAT_CHECK $?
