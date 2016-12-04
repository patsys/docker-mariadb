FROM patsys/alpine-mybase
MAINTAINER Patrick Weber <pat.weber91@gmail.com>
COPY 25_mariadb_test.sh /etc/my_init.d/
RUN chmod u+x /etc/my_init.d/25_mariadb_test.sh
RUN apk update && apk upgrade && apk add mysql-client && rm -rf /var/cache/apk/*
CMD ["/etc/start"]
