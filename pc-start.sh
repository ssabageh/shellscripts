#!/bin/bash

ACTION=$1
USER_NAME=petclinic
START_ORDER="config-server:8888 discovery-server:8761 api-gateway:8080 vets-service:8080 visits-service:8080 customers-service:8080"
STOP_ORDER="customers-service:8080 visits-service:8080 vets-service:8080 api-gateway:8080 discovery-server:8761 config-server:8888"

START_TIMEOUT=300

## Color Codes
G="\e[32m"
R="\e[31m"
N="\e[0m"
## Start Function
START_F() {

for service in $START_ORDER; 
    SERVICE=$(echo $service | awk -F : '{print $1}')
    PORT_NO=$(echo $service | awk -F : '{print $2}')
    echo -n "Starting $SERVICE service"
    su - $USER_NAME -c "nohup java -jar /home/$USER_NAME/spring-petclinic-$SERVICE.jar &>/home/$USER_NAME/$SERVICE.log &"
local i=0
while [ $1 -lt $START_TIMEOUT ]; do
    netstat -lntp | grep $PORT_NO &>/dev/null
    if [ $? -eq 0 ]; then
    echo -e "${G} - STARTED${N}"  
    break
    else
    i=$(($i+15))
    if [ $i -gt $STARTED_TIMEOUT ]; then
    echo -e "${R} - FAILED${N}"
    exit 1
  fi
  sleep 15 
fi   
done
}



## Main Program
case $ACTION in
   start)
   START_F
   ;;
   stop)
   STOP_F
   ;;
   restart
   STOP_F
   START_F
   ;;
esac