FROM busybox:latest

WORKDIR /var/www

COPY . .

EXPOSE 3000

CMD ["httpd", "-f", "-p", "3000", "-h", "/var/www"]
