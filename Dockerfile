FROM busybox:latest

WORKDIR /var/www

COPY . .

EXPOSE 8080

CMD ["httpd", "-f", "-p", "8080", "-h", "/var/www"]
