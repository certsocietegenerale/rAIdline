# Migrating requirements checkup in Python

## Check current OS (Windows vs. Linux vs. Mac)

import platform
import os
import sys

print("You are currently running rAIdline on the following platform", print(os.name), ",", print(sys.platform))

if os.name == 'windows':
    print("It is not currently possible to run rAIdline on this OS, please try and use Linux or Mac instead")

###########
#Env Setup
###########

print("[*] Checking configuration file...")

def check_variable(variable) :
  if not variable:
    print("[X]", variable, "was not set")
    return 1
  else
    print( "[*]", variable, "was already set.")
    print( "value :", variable)
    return 0


def remediate_inexistant_variable():
  print( "welcome $1"
  case "$1" in 

  *MAIL*)
    print( "generating mail..."
    remediate_inexistant_mail $1
    ;;

  *PASS*)
    print( "generating pass..."
    remediate_inexistant_password $1
    ;;

  *)
    remediate_inexistant_user $1
    
    ;;
  esac


def commit_inexistant_variable()
:
  export $1=$2
  print( "$1=$2"
  print( "$1=$2" >> "./.env"


def remediate_inexistant_user():
  value=$(LC_ALL=C tr -dc 'a-z' </dev/urandom | head -c 10; echo)
  commit_inexistant_variable $1 $value

def remediate_inexistant_password():
  value=$(LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c 18; echo)
  commit_inexistant_variable $1 $value

def remediate_inexistant_mail():
  uname=$(LC_ALL=C tr -dc 'a-z' </dev/urandom | head -c 9; echo)
  dmn=$(LC_ALL=C tr -dc 'a-z' </dev/urandom | head -c 5; echo)
  commit_inexistant_variable $1 "$uname@$dmn.com"


def ask_auto_remediate() :
    if [ $auto_yes = true ]:
        return 0  # Automatically return true if auto-yes is enabled
    fi
    
    read -p "Do you want to proceed with auto-remediation? [y/n/a]: " response
    case "$response" in
        y|Y|yes|YES|Yes)
            return 0
            ;;
        n|N|no|NO|No)
            return 1
            ;;
        a|A|any|ANY|Any)
            auto_yes=true
            return 0
            ;;
        *)
            print( "Invalid input. Please enter 'y' for yes, 'n' for no, or 'a' to automatically answer 'yes' for all future prompts."
            ask_auto_remediate
            ;;
    esac



## At then end of the setup, redirect to the correct setup bash script (or launch it directly for all I know)

if os.name == 'mac':
    print("You should use now the following setup script : mac_setup_raidline_response.sh")
else:
    print("You should use now the following setup script : linux_setup_raidline_response.sh")
