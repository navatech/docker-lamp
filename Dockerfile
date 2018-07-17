FROM tutum/lamp:latest
MAINTAINER Le Phuong <phuong17889@gmail.com>

# Install packages
ENV DEBIAN_FRONTEND noninteractive
RUN echo "192.168.1.202 navademo.com" >> /etc/hosts
