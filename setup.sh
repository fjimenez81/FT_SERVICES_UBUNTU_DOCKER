#!/bin/bash

RED="\e[91m"
GREEN="\e[92m"
YELLOW="\e[93m"
BLUE="\e[94m"
PURPLE="\e[95m"
CYAN="\e[96m"
WHITE="\e[97m"

minikube delete
minikube config unset vm-driver

# Detect the platform (similar to $OSTYPE)
OS="`uname`"

case $OS in
	"Linux")
		minikube start --driver=docker --cpus=2
		sed -i "s/xxxx-xxxx/172.17.0.10-172.17.0.19/g" srcs/metallb.yaml
		sed -i "s/zzzz-zzzz/172.17.0.20-172.17.0.20/g" srcs/metallb.yaml
		sed -i "s/WP_IP/172.17.0.20:5050/g" srcs/mysql/wordpress.sql
		sed -i "s/yyyy-yyyy/172.17.0.21-172.17.0.21/g" srcs/metallb.yaml
		sed -i "s/FTPS_IP/172.17.0.21/g" srcs/ftps/vsftpd.conf
	;;
	"Darwin")
		minikube start --driver=virtualbox
		sed -i '' "s/xxxx-xxxx/192.168.99.110-192.168.99.119/g" srcs/metallb.yaml
		sed -i '' "s/zzzz-zzzz/192.168.99.120-192.168.99.120/g" srcs/metallb.yaml
		sed -i '' "s/WP_IP/192.168.99.120:5050/g" srcs/mysql/wordpress.sql
		sed -i '' "s/yyyy-yyyy/192.168.99.121-192.168.99.121/g" srcs/metallb.yaml
		sed -i '' "s/FTPS_IP/192.168.99.121/g" srcs/ftps/vsftpd.conf
	;;
	*) ;;
esac

echo -en $YELLOW
echo "MINIKUBE STARTING..."

#minikube start --driver=docker --cpus=2
minikube addons enable metrics-server
minikube addons enable dashboard &> /dev/null
minikube addons enable metallb
kubectl apply -f srcs/metallb.yaml

eval $(minikube docker-env)

echo -en $GREEN
echo "IMAGES BUILDING..."

docker build -t my-nginx srcs/nginx/ | grep "Step"
kubectl apply -f srcs/nginx.yaml

docker build -t my-mysql srcs/mysql/ | grep "Step"
kubectl apply -f srcs/mysql.yaml

docker build -t my-phpmyadmin srcs/phpmyadmin/ | grep "Step"
kubectl apply -f srcs/phpmyadmin.yaml

docker build -t my-wordpress srcs/wordpress/ | grep "Step"
kubectl apply -f srcs/wordpress.yaml

docker build -t my-ftps srcs/ftps/ | grep "Step"
kubectl apply -f srcs/ftps.yaml

docker build -t my-influxdb srcs/influxdb/ | grep "Step"
kubectl apply -f srcs/influxdb.yaml

docker build -t my-grafana srcs/grafana/ | grep "Step"
kubectl apply -f srcs/grafana.yaml

echo -en $WHITE

echo "GET SERVICES!!"
kubectl get svc

echo -en $CYAN

echo "=======COMMANDS======="
echo "ssh -p 22 ssh_admin@ip_svc"
echo "ssh: ssh_admin--9090"
echo "-----------------------"
echo "ftp -p 172.17.0.21"
echo "ftp: ftp_admin--01010"
echo "-----------------------"
echo "nginx"
#echo "http://172.17.0.2"
echo "-----------------------"
echo "wordpress"
#echo "http://172.17.0.3:5050"
echo "wordpress: ferfox_1--ferfox_1"
echo "wordpress: user_1--2020"
echo "wordpress: user_2--2121"
echo "-----------------------"
echo "phpmyadmin"
#echo "http://172.17.0.4:5000"
echo "phpmyadmin: ferfox--1234"
echo "-----------------------"
echo "grafana"
#echo "http://172.17.0.6:3000"
echo "grafana: admin--admin"
echo "-----------------------"

case $OS in
	"Linux")
		sed -i "s/172.17.0.10-172.17.0.19/xxxx-xxxx/g" srcs/metallb.yaml
        sed -i "s/172.17.0.20-172.17.0.20/zzzz-zzzz/g" srcs/metallb.yaml
        sed -i "s/172.17.0.20:5050/WP_IP/g" srcs/mysql/wordpress.sql
        sed -i "s/172.17.0.21-172.17.0.21/yyyy-yyyy/g" srcs/metallb.yaml
        sed -i "s/172.17.0.21/FTPS_IP/g" srcs/ftps/vsftpd.conf
	;;
	"Darwin")
		minikube start --driver=virtualbox
		sed -i '' "s/192.168.99.110-192.168.99.119/xxxx-xxxx/g" srcs/metallb.yaml
		sed -i '' "s/192.168.99.120-192.168.99.120/zzzz-zzzz/g" srcs/metallb.yaml
		sed -i '' "s/192.168.99.120:5050/WP_IP/g" srcs/mysql/wordpress.sql
		sed -i '' "s/192.168.99.121-192.168.99.121/yyyy-yyyy/g" srcs/metallb.yaml
		sed -i '' "s/192.168.99.121/FTPS_IP/g" srcs/ftps/vsftpd.conf
	;;
	*) ;;
esac


