#!/usr/bin/env bash
# Script to install all of Frank's ssh and gpg keys 
# tested in Ubuntu 20.04 ,fedora 31, wsl2
# Function to print in specified color
colorprintf () {
  case $1 in
      "red") tput setaf 1;;
      "green") tput setaf 2;;
      "orange") tput setaf 3;;
      "blue") tput setaf 4;;
      "purple") tput setaf 5;;
      "cyan") tput setaf 6;;
      "gray" | "grey") tput setaf 8;;
      "white") tput setaf 7;;
  esac
  echo "$2";
  tput sgr0
}

SetTime (){
# set time 
start_time=$(date +%s.%N)
current_time=$(date +'%T-%d/%m/%Y')
}

check_dependencies () {
  colorprintf red "Checking Dependencies"
  for dep in ${dependencies[@]}; do 
    if ! type "${dep}" > /dev/null; then
      colorprintf red "${dep} does not exist in your system ,script will now exit"
      exit 0 
    fi 
  done
}

ssh_auth_keys () {
colorprintf red "Installing SSH Auth Keys"
# create ssh folder 
mkdir -p $HOME/.ssh
# touch the key file
touch $HOME/.ssh/authorized_keys
# append keys
colorprintf white "$(curl -sSL https://gitlab.com/frankper/public-keys/-/raw/main/authorized_keys | xargs -0 echo | grep -i "ssh-ed25519" -B 1 | grep -vE 'ssh-ed25519|^--$')"
colorprintf white "$(curl -sSL https://gitlab.com/frankper/public-keys/-/raw/main/authorized_keys | xargs -0 echo | grep -i "ssh-rsa" -B 1 | grep -vE 'ssh-rsa|^--$')"
curl -sSL https://gitlab.com/frankper/public-keys/-/raw/main/authorized_keys >> $HOME/.ssh/authorized_keys
}

gpg_keys () {
  unset $key
  colorprintf red "Installing from gitlab"
  for key in ${gpgKeyNames[@]}; do 
    curl -sSL https://gitlab.com/frankper/public-keys/-/raw/main/keyfiles/frank.perrakis.${key}.asc | gpg --import - 
  done 
}

gpg_keys_ubuntu () {
  unset $ubuntu
  colorprintf red "Installing from ubuntu keyservers"
  for ubuntu in ${gpgKeyUbuntu[@]}; do 
    gpg --keyserver keyserver.ubuntu.com --recv $ubuntu
  done 
}

display_help() {
  echo "Usage: $0 [option...] " >&2
  echo
  echo "   -a, --all        install all gpp and ssh keys "
  echo "   -s, --ssh        install only ssh keys "
  echo "   -g, --gpg        install only gpg keys from gitlab repo "
  echo "   -u, --ubuntu     Install only gpg keys from keyservers "
  echo
  # echo some stuff here for the -a or --add-options 
  exit 1
}

ExitMessage () {
duration=$(echo "$(date +%s.%N) - $start_time" | bc)
# execution_time=`colorprintf  "%.2f seconds" $duration`
colorprintf purple "${pick_name} Done in $(colorprintf  "%.2f seconds" ${duration})"
colorprintf green "Completed $pick_name"
}

SetTime
# set script name below 
pick_name="Script to install Frank's ssh/gpg keys"
colorprintf orange "Running $pick_name"
# declare dependencies
declare -a dependencies=(curl wget gpg)
# declare gpg key names from gitlab
declare -a gpgKeyNames=(main)
# declare gpg key names from ubuntu servers
declare -a gpgKeyUbuntu=(0x1e7b5fe0ee3d960301366e161e81e951285219b0)

while [ ! $# -eq 0 ]
do
  case "$1" in
    --ssh | -s)
      check_dependencies
      ssh_auth_keys
      exit
      ;;
    --gpg | -g)
      check_dependencies
      gpg_keys
      exit
      ;;
    --all | -a)
      check_dependencies
      ssh_auth_keys
      gpg_keys
      exit
      ;;
    --ubuntu | -u)
      check_dependencies
      gpg_keys_ubuntu
      exit
      ;;
    --help | -h)
      display_help
      exit
      ;;
  esac
shift
done 

ExitMessage
