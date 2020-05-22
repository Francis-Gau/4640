#! /bin/bash

SETUP_DIR="setup"
VM_USER="admin"
VM_HOST="todoapp"

for MODULE in "mongodb-org-4.2.repo" "database.js" "install_script.sh" "nginx.conf" "todoapp.service"
do
    scp "./$SETUP_DIR/$MODULE" "$VM_USER@$VM_HOST:$MODULE"
done

echo "sudo chmod +x install_script.sh && sudo ./install_script.sh" | ssh todoapp /bin/bash
