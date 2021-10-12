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
colorprintf white "$(curl -sSL https://gitlab.com/frankper/public-keys/-/raw/master/authorized_keys | xargs -0 echo | grep -i "ssh-ed25519" -B 1 | grep -vE 'ssh-ed25519|^--$')"
colorprintf white "$(curl -sSL https://gitlab.com/frankper/public-keys/-/raw/master/authorized_keys | xargs -0 echo | grep -i "ssh-rsa" -B 1 | grep -vE 'ssh-rsa|^--$')"
curl -sSL https://gitlab.com/frankper/public-keys/-/raw/master/authorized_keys >> $HOME/.ssh/authorized_keys
}

gpg_keys () {
colorprintf red "Installing All GPG Keys from github"
for key in ${gpgKeyNames[@]}; do 
  curl -sSL https://gitlab.com/frankper/public-keys/-/raw/master/keyfiles/frank.perrakis.${key}.asc | gpg --import - 
done 
}

gpg_keys_ubuntu () {
colorprintf red "Installing All GPG Keys from ubuntu keyservers"
for ubuntu in ${gpgKeyUbuntu[@]}; do 
  curl -sSL https://keyserver.ubuntu.com/pks/lookup?op=get&search=${ubuntu} | gpg --import -
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

# set script name below 
pick_name="Script to install Frank's ssh/gpg keys"
colorprintf orange "Running $pick_name"
# declare dependencies
declare -a dependencies=(curl wget gpg)
# declare gpg key names
declare -a gpgKeyNames=(main)
# revoked 
# declare -a gpgKeyNames=(gpg001 gpg002 yubikey gpg003.v2-v3)
# declare gpg key names from ubuntu servers
declare -a gpgKeyUbuntu=(0x026df53d6b7c0b00732d555cf8e3ef51cf4f4f51)
# revoced keys 
# declare -a gpgKeyUbuntu=(0x1e81e951285219b0 0x5faddad63d31b26a 0x1e81e951285219b0 0x1ebbdb2a2fe0dc7d)

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
      output="$(gpg_keys_ubuntu)"
      echo "$output"
      exit
      ;;
    --help | -h)
      display_help
      exit
      ;;
  esac
shift
done
colorprintf green "$pick_name Done"