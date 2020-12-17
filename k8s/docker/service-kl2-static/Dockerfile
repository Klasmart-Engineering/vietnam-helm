FROM node:alpine AS build

COPY ./cms-frontend-web /src

RUN cd /src &&\
    yarn install &&\
    yarn build

FROM nginx:alpine

COPY ./default.conf /etc/nginx/conf.d

COPY --from=build /src/build /usr/share/nginx/html

