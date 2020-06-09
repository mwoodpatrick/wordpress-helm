#!/bin/bash

backupCommand="ansible-playbook backup.yml -e @secrets/secret-vars.yaml"
# A day's worth of seconds.
interval=86400

while true
do
    date
    echo "Waiting for $interval seconds before starting next backup."
    sleep $interval
    $backupCommand
    exitCode=$?
    if [ $exitCode -ne 0 ]
    then
        echo "Backup failed, exiting!"
        exit $exitCode
    fi
done
