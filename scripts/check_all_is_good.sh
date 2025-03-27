#!/bin/bash
auto_yes=false
echo "[*] Checking configuration file..."
set -a && source .env && set +a

function check_variable() {
  if [[ ! -n ${!1} ]]; then
    echo "[X] $1 was not set"
    return 1
  else
    echo "[*] $1 was set."
    echo "value : $1"
    return 0
  fi
}

function remediate_inexistant_variable(){
  echo "welcome $1"
  case "$1" in 

  *MAIL*)
    echo "generating mail..."
    remediate_inexistant_mail $1
    ;;

  *PASS*)
    echo "generating pass..."
    remediate_inexistant_password $1
    ;;

  *)
    remediate_inexistant_user $1
    # Do stuff
    ;;
  esac



}
function commit_inexistant_variable()
{
  export $1=$2
  echo "$1=$2"
  echo "$1=$2" >> "./.env"
}
function remediate_inexistant_user(){
  value=$(LC_ALL=C tr -dc 'a-z' </dev/urandom | head -c 10; echo)
  commit_inexistant_variable $1 $value
}
function remediate_inexistant_password(){
  value=$(LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c 18; echo)
  commit_inexistant_variable $1 $value
}
function remediate_inexistant_mail(){
  uname=$(LC_ALL=C tr -dc 'a-z' </dev/urandom | head -c 9; echo)
  dmn=$(LC_ALL=C tr -dc 'a-z' </dev/urandom | head -c 5; echo)
  commit_inexistant_variable $1 "$uname@$dmn.com"
}

function ask_auto_remediate() {
    if [ $auto_yes = true ]; then
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
            echo "Invalid input. Please enter 'y' for yes, 'n' for no, or 'a' to automatically answer 'yes' for all future prompts."
            ask_auto_remediate
            ;;
    esac
}

if test -d ../data-mongo; then
  echo "Directory data-mongo exists."
else
  echo "Directory data-mongo does not exist."
  if ask_auto_remediate; then
    echo "User proceeded with auto-remediation"
    echo "Creating data-mongo"
    mkdir ../data-mongo
    chmod 777 ../data-mongo
  fi
fi

if test -d ../data-docs; then
  echo "Directory data-docs exists."
else 
  echo "Directory data-docs does not exist."
  if ask_auto_remediate; then
    echo "No auto-remediation"
  fi
fi

if test -f ./init-data.sh; then
  echo "File init-data.sh exists."
else
  echo "File init-data.sh does not exist"
   if ask_auto_remediate; then
    echo "User proceeded with auto-remediation"
  fi
fi

if test -f ./creds_template.json; then
  echo "File creds_template.json exists."
else
  echo "File creds_template.json does not exist"
  if ask_auto_remediate; then
    echo "User proceeded with auto-remediation"
  fi
fi

: << 'COMMENT' 
if test -f ../temporary_raidline/creds.json; then
  echo "File creds.json exists."
else
  echo "File creds.json does not exist"
  if ask_auto_remediate; then
    echo "User proceeded with auto-remediation"
  fi
fi

if test -f ./.docker.env; then
  echo "File .docker.env exists."
else
  echo "File .docker.env does not exist"
  if ask_auto_remediate; then
    echo "User proceeded with auto-remediation"
  fi
fi
COMMENT

to_check=("POSTGRES_USER" "POSTGRES_PASSWORD" "POSTGRES_DB" "POSTGRES_NON_ROOT_USER" "POSTGRES_NON_ROOT_PASSWORD" "MM_POSTGRES_USER" "MM_POSTGRES_PASSWORD" "MM_POSTGRES_DB" "MM_USER_EMAIL" "MM_USER_PASSWORD" "MONGO_INITDB_ROOT_USERNAME" "MONGO_INITDB_ROOT_PASSWORD")
echo "Starting variable checks..."
for VAR in "${to_check[@]}"; do
  echo "[*] Checking $VAR...."
  if check_variable $VAR; then
    echo "Variable $VAR exists."
  else
    echo "Variable $VAR does not exist"
    if ask_auto_remediate; then
      echo "User proceeded with auto-remediation"
      remediate_inexistant_variable $VAR
    fi
  fi
done 