FROM node:alpine AS build

COPY ./cms-frontend-web /src
COPY ./env.vn.production /src/.env.production

RUN cd /src &&\
    yarn install &&\
    ENV=production yarn build

FROM nginx:alpine

COPY ./default.conf /etc/nginx/conf.d

COPY --from=build /src/build /usr/share/nginx/html

