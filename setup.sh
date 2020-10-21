#!/bin/bash

RED="\e[91m"
GREEN="\e[92m"
YELLOW="\e[93m"
BLUE="\e[94m"
PURPLE="\e[95m"
CYAN="\e[96m"
WHITE="\e[97m"

echo -en $YELLOW
echo "MINIKUBE STARTING..."

minikube start --driver=docker --cpus=2
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
echo "ssh -p 22 ssh_admin@172.17.0.2"
echo "ssh: ssh_admin--9090"
echo "-----------------------"
echo "ftp -p 172.17.0.5"
echo "ftp: ftp_admin--01010"
echo "-----------------------"
echo "nginx"
echo "http://172.17.0.2"
echo "-----------------------"
echo "wordpress"
echo "http://172.17.0.3:5050"
echo "wordpress: ferfox_1--ferfox_1"
echo "wordpress: user_1--2020"
echo "wordpress: user_2--2121"
echo "-----------------------"
echo "phpmyadmin"
echo "http://172.17.0.4:5000"
echo "phpmyadmin: ferfox--1234"
echo "-----------------------"
echo "grafana"
echo "http://172.17.0.6:3000"
echo "grafana: admin--admin"
echo "-----------------------"
