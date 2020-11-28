#!?bin/bash

## Define a function
function func_name() {}
# func_name() {}

SAMPLE() {
    echo This is a sample function 
}
### Access the function in MAIN PROGRAM
SAMPLE1() {
    echo First Arguement = $1
}

SAMPLE2() {
    A=100
    local a=200
}

SAMPLE3() {
    echo Hi
    return 1
    echo Bye
}
SAMPLE1
## Function is a type of command
## There are four types of commands: 1.BINARIES, 2.SHELL BUILTIN, 3.ALIAS, 4.FUNCTION
SAMPLE2
echo "A = $A, a = $a"
# If you define variables in Main Program, you can access them in function and vice-versa
# Function is as simple as command and it has exit status as well
SAMPLE3
echo EXIT status of SAMPLE3 = $? 

# In some cases, we can define variables inside the function and should not be accessed outside of the function. In such cases, we choose to use local command to define variables
## local VAR=DATA