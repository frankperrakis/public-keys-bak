#!/usr/bin/env bash
# sync gpg and ssh keys between repos
# tested in Ubuntu 20.04 ,fedora 31
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

SyncRun () {
    for folder in ${TargetFolderForDeletion[@]};do
        sudo rsync -xavh --exclude .git --delete-before $source_folder/* $folder
    done
}

ExitMessage () {
duration=$(echo "$(date +%s.%N) - $start_time" | bc)
# execution_time=`colorprintf  "%.2f seconds" $duration`
colorprintf purple "${pick_name} Done in $(colorprintf  "%.2f seconds" ${duration})"
colorprintf green "Completed $pick_name"
}

SetTime (){
# set time 
start_time=$(date +%s.%N)
current_time=$(date +'%T-%d/%m/%Y')
}

GitCommitGithub (){
for tar in ${TargetFolderForDeletion[@]}; do 
    cd $tar
    git add . 
    git commit -m "Automated Sync ${current_time}"
    git push 
    colorprintf green "Commited to Github"
done
}

GitCommitGitlab (){
cd $source_folder
git add . 
git commit -m "Automated Sync ${current_time}"
git push 
colorprintf green "Commited to Gitlab"
}

SetTime
# set local location
local_location="$(echo $(pwd))"
# set script name below
pick_name="Sync Public gpg/ssh Keys Script"
colorprintf green "Running $pick_name"
# unset variables
unset TargetFolderForDeletion
unset FilesForDeletion
# define main source of truth 
source_folder="$HOME/projects/personal/public-keys"
colorprintf purple "Source of trust is $source_folder"
# define folder targets for replication 
declare -a TargetFolderForDeletion=("$HOME/projects/personal/public-keys-frankperrakis/" "$HOME/projects/personal/public-keys-frankper/")

SyncRun
GitCommitGithub
GitCommitGitlab
ExitMessage
