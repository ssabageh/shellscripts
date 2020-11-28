#!/bin/bash

## To print a message on the screen, use either "print f" or "echo command". 

## We will use echo command

echo Hello

## To print multiple lines

echo Hello\nBYe

## \n is an escape sequence which prints in a new line

## To enable the "escape sequence", an option "-e" must be used in the echo command

echo -e Hello\nBYe

## When "escape sequence" is enabled in echo command, the input must be in double quotes

echo -e "Hello\nBYe"

## To print tab space, use \t escape sequence in double quotes
echo -e "Hello\t\t\tBYe"

## If colors are required to be printed while printing a text to grab the user's attention
## Use \e to enable colors

## There are 2 types: Foreground(Font color) and Background(Terminal color)
#Color           Foreground           Background
#Red                31                   41
#Green              32                   42
#Yellow             33                   43
#Blue               34                   44
#Magenta            35                   45
#Cyan               36                   46

## Syntax to enable color: echo -e "\e[COLmHello" => COL is one of the numbers listed above

echo -e "\e[31mRed Color"
echo -e "\e[33mYellow Color"

echo -e "\e[44mBlue Background Color\e[ 0m"

#Color always follows because color is enabled and not disabled. To disable, use zero(0) in place of color
