FROM ubuntu:18.04

USER root
COPY . .
RUN apt-get update && apt-get install -y wget curl build-essential
RUN ./cmake_install.sh 
