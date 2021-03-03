FROM nginx:alpine

COPY ./default.conf /etc/nginx/conf.d
COPY ./dist /usr/share/nginx/html

# https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2020-28928
RUN apk --no-cache upgrade musl