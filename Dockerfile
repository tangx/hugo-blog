FROM ghcr.io/tangx/httpserve:v0.0.1
# FROM nginx:alpine
# WORKDIR /go/bin/dist
WORKDIR /usr/share/nginx/html

# ENV ROOT_DIR=/usr/share/nginx/html

# ADD attachments attachments
# ADD assets assets
ADD public .

