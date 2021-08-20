FROM ubuntu:18.04
RUN apt-get clean
RUN apt-get update -y
USER root
COPY . .
RUN ./cmake_install.sh 
