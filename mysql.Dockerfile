
FROM mysql:5.7

ADD ./docker/db/my.cnf /etc/mysql/my.cnf
RUN chmod 644 /etc/mysql/my.cnf
