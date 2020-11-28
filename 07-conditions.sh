#!/bin/bash

## Two conditional statements are available in bash shell: 1.IF, 2.CASE

ACTION=$1
SERVICE_NAME=DEMO

START_FUNC() {
    echo "Starting $SERVICE_NAME Service"
}

STOP FUNC() {
    echo "Stopping $SERVICE_NAME Service"
}

USAGE() {
    echo -e "\n\e[33mUsage: $0 action(start/stop/restart)"
exit 1
}

if [ $# -ne 1 ]; then
    echo -e "\e[33m Arguement missing!!\e[0m"
USAGE
fi 
case $ACTION in
start)
STOP_FUNC
;;
stop)
STOP_FUNC
;;
restart)
STOP_FUNC
START_FUNC
;;
*)
USAGE
;;
    echo -e "\e[31m Invalid Input!!"
esac

## IF statement has three forms:
# 1. Simple IF

# if [ expression ]; then
# commands
# fi

# 2. If-Else

# if [ expression ]; then
# commands
# else
# commands
# fi

## 3. Else-If

# If [ expr1 ]; then
# commands
# elif [ expr2 ]; then
# commands
# fi

## Expressions are categorized into three:
# 1. String Expressions - OP: =, !=, -z
# 2. Numerical Expressions - OP: -eq, -ne, -gt, -ge, -lt, -le
# 3. File Expressions - OP: <Refer to internet>
## https://www.gnu.org/software/bash/manual/html_node/Bash-Conditional-Expressions.html

If [ "$ACTION" = "start" ]; then
START_FUNC
elif [ "$ACTION" = "stop" ]; then
STOP_FUNC
elif [ "$ACTION" = "restart" ]; then
STOP_FUNC
START_FUNC
else

USAGE
fi
    echo -e "\e[31m Invalid Input!!"