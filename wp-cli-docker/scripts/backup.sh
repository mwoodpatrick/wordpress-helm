#!/bin/bash

backupCommand="ansible-playbook backup.yml -e @secrets/secret-vars.yaml"

while true
do
    date
    echo "Waiting for $BACKUP_INTERVAL_SECONDS seconds before starting next backup."
    sleep $BACKUP_INTERVAL_SECONDS
    $backupCommand
    exitCode=$?
    if [ $exitCode -ne 0 ]
    then
        echo "Backup failed, exiting!"
        exit $exitCode
    fi
done
