#!/bin/bash

    sudo yum update -y

    #install epel release 7
    rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
    rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm

    sudo yum clean all

    PACKAGES="httpd mariadb mariadb-server php56w php56w-opcache php56w-mcrypt php56w-mysql php56w-pear php56w-pdo php56w-mbstring php56w-common curl tree vim unzip"
    PACKAGES="$PACKAGES policycoreutils policycoreutils-python selinux-policy selinux-policy-targeted"
    PACKAGES="$PACKAGES libselinux-utils setroubleshoot-server setools setools-console mcstrans wget git tree curl postfix openssh-server epel-release"
    PACKAGES="$PACKAGES nodejs npm"

    sudo yum -y install $PACKAGES;

    sudo yum clean all

    db_password=""
    #init mysql
    sudo systemctl enable mariadb.service
    sudo systemctl start mariadb.service
    ##Mysql secure instalation
    sudo mysqladmin -u root password "$db_password"
    sudo mysql -u root -p"$db_password" -e "UPDATE mysql.user SET Password=PASSWORD('$db_password') WHERE User='root'"
    mysql -u root -p"$db_password" -e "DELETE FROM mysql.user WHERE User=''"
    mysql -u root -p"$db_password" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'"
    mysql -u root -p"$db_password" -e "FLUSH PRIVILEGES"


    #ENABLE HTTPD service
    sudo systemctl enable hhtpd.service
    sudo cp -f ./templates/httpd.conf /etc/httpd/conf/
    sudo cp -f ./templates/userdir.conf /etc/httpd/conf.d/
    sudo systemctl start httpd.service

    #PRE GITLAB
    sudo systemctl enable sshd
    sudo systemctl start sshd
    sudo systemctl enable postfix
    sudo systemctl start postfix
    sudo firewall-cmd --permanent --add-service=http
    sudo systemctl reload firewalld

    # INSTALL GITLAB
    curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.rpm.sh | sudo bash
    sudo yum install gitlab-ce -y
    sudo gitlab-ctl reconfigure
