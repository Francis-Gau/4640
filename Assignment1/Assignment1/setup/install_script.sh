#! /bin/bash

ADMIN_USER="admin"
TODO_USER="todoapp"

if [ "$(firewall-cmd --zone=public --query-service=http)" = "no" ]
then firewall-cmd --zone=public --add-service=http
fi

for TCP_PORT in "80/tcp" "27017/tcp"
do
    if [ "$(firewall-cmd --zone=public --query-port $TCP_PORT)" = "no" ]
    then firewall-cmd --zone=public --add-port=$TCP_PORT
    fi
done

firewall-cmd --runtime-to-permanent && echo "Firewall rules updated"

LANG=en_US.utf8

if ! yum repolist | grep -q "nodesource"
then
    curl -sL https://rpm.nodesource.com/setup_12.x | bash -
fi

cp /home/$ADMIN_USER/mongodb-org-4.2.repo /etc/yum.repos.d/mongodb-org.repo

for PACKAGE in "gcc-c++" "make" "nodejs" "git" "mongodb-org" "nginx"
do
    if [ ! "$(rpm -q installed $PACKAGE)" ]
    then
        yum install -y -e 0 $PACKAGE
    fi
done

systemctl enable mongod && systemctl start mongod && echo "mongod success!"

if [ "$(id -u $TODO_USER)" ]
then
    userdel -r $TODO_USER
fi

adduser $TODO_USER && sudo passwd -l $TODO_USER && sudo chage -E0 $TODO_USER && "$TODO_USER added!"
chmod 755 /home/$TODO_USER

git clone https://github.com/timoguic/ACIT4640-todo-app.git /home/$TODO_USER/app
cp /home/$ADMIN_USER/database.js /home/$TODO_USER/app/config/database.js
chown -R $TODO_USER:$TODO_USER /home/$TODO_USER/app
cd /home/$TODO_USER/app || exit
npm install


systemctl enable nginx && systemctl start nginx && echo "nginx success!"
cp /home/$ADMIN_USER/nginx.conf /etc/nginx/nginx.conf
systemctl restart nginx

cp /home/$ADMIN_USER/todoapp.service /etc/systemd/system/todoapp.service
systemctl daemon-reload
systemctl enable todoapp && systemctl start todoapp && echo "todoapp success!"
exit 0