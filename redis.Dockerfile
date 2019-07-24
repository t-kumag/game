FROM redis

ADD ./docker/redis/redis.conf /usr/local/etc/redis/redis.conf
RUN chmod 644 /usr/local/etc/redis/redis.conf