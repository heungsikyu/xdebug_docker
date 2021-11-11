FROM centos:7

# Install Apache
RUN yum -y update
RUN yum -y install httpd httpd-tools

# Install EPEL Repo
RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
 && rpm -Uvh http://rpms.remirepo.net/enterprise/remi-release-7.rpm

# Install PHP
RUN yum --enablerepo=remi-php73 -y install php php-bcmath php-cli php-common php-gd php-intl php-ldap php-mbstring \
    php-mysqlnd php-pear php-soap php-xml php-xmlrpc php-zip php-devel

# Update Apache Configuration
RUN sed -E -i -e '/<Directory "\/var\/www\/html">/,/<\/Directory>/s/AllowOverride None/AllowOverride All/' /etc/httpd/conf/httpd.conf
RUN sed -E -i -e 's/DirectoryIndex (.*)$/DirectoryIndex index.php \1/g' /etc/httpd/conf/httpd.conf

# Required for Xdebug compilation
RUN yum -y install make

# Install Xdebug
RUN pecl install xdebug

# Add Xdebug to PHP configuration
RUN echo "" >> /etc/php.ini \
 && echo "[xdebug]" >> /etc/php.ini \
 && echo "; xdebug version 3.*" >> /etc/php.ini \
 && echo "zend_extension = /usr/lib64/php/modules/xdebug.so" >> /etc/php.ini \
 && echo "xdebug.mode = debug" >> /etc/php.ini \
 && echo "xdebug.start_with_request=yes" >> /etc/php.ini \
 && echo "xdebug.client_host=host.docker.internal" >> /etc/php.ini \
 && echo "xdebug.log=/tmp/xdebug.log" >> /etc/php.ini \
 && echo "; 9003 is now the default " >> /etc/php.ini \ 
 && echo "xdebug.client_port = 9003" >> /etc/php.ini \

EXPOSE 80

# Start Apache
CMD ["/usr/sbin/httpd","-D","FOREGROUND"]
