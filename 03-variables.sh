#!/bin/bash

## To declare a variable, use VAR=DATA
a=10
## In bash, there's node data types by default
## a=10, 10 is not a number for intepreter. It is a string for the system and a number for the user - for bash, it is a data
## a=true, not a boolean, it is a string

## a=abc, not a character but a string

## When data contains special characters, provide input in quotes...double quote is preferred

## To access a variable, you need to add a prefix "$" character to the variable
echo a = $a 


b="Raghu K"
echo B = $b 
##
DATE=2019-11-02
echo Hello, Good Morning. Today date is $DATE

## The above statement is only true for one day...DATE is the only value making the statement wrong
## To obtain the date dynamically when the script is executed, then we need to use command substitution

## Syntax, VAR=$(command) or VAR='command'
DATE=$(date +%F)
echo Hello, Good Morning. Today date is $DATE

## Access a variable from CLI
echo COURSE_NAME=$COURSE_NAME
