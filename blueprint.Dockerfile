FROM node:7.5

ENV WORKSPACE /blueprint

RUN apt-get update

RUN mkdir $WORKSPACE
WORKDIR $WORKSPACE

RUN npm init -y
RUN npm install gulp -g --no-optional
RUN npm install gulp gulp-aglio --no-optional

COPY ./docker/blueprint/entrypoint.sh entrypoint.sh
COPY ./docker/blueprint/gulpfile.js gulpfile.js
COPY ./docker/blueprint/aglioconfig.json aglioconfig.json

RUN chmod +x ./entrypoint.sh

CMD ["/bin/sh", "./entrypoint.sh"]