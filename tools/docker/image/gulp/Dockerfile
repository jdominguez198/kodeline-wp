FROM node:latest

ARG TOOLSET_VERSION
ARG BROWSERSYNC_PORT

RUN mkdir -p /usr/src/app

WORKDIR /usr/src/app

RUN set -ex; \
    wget https://github.com/jdominguez198/kodeline-toolset/archive/$TOOLSET_VERSION.tar.gz -O theme.tar.gz; \
    tar -xzvf theme.tar.gz --strip-components 1;

RUN npm install

COPY cnf/config.json /usr/src/app/cnf/config.json
RUN sed -i 's#${BROWSERSYNC_PORT}#'"$BROWSERSYNC_PORT"'#g' /usr/src/app/cnf/config.json

EXPOSE $BROWSERSYNC_PORT
EXPOSE 3001

CMD ["npm", "start"]