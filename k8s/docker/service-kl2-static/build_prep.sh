#!/bin/bash
source ../../../scripts/bash/functions.sh

ENV=$1
env_validate $ENV

BASE_URL_USER=$(../../../scripts/python/env_var.py $ENV "base_url_user")
[ -z "$BASE_URL_USER" ] && echo "Missing variable,'base_url_user', in $ENV" && exit 1
BASE_URL_H5P=$(../../../scripts/python/env_var.py $ENV "base_url_h5p")
[ -z "$BASE_URL_H5P" ] && echo "Missing variable,'base_url_h5p', in $ENV" && exit 1

echo -e "\n\nUPDATING CMS-FRONTEND-WEB" && echo_line
git submodule deinit -f cms-frontend-web
git submodule update --init -- cms-frontend-web

pushd cms-frontend-web

echo "\
PUBLIC_URL=.
REACT_APP_KO_BASE_API=$BASE_URL_USER
REACT_APP_BASE_API=\"v1\"
REACT_APP_H5P_API=$BASE_URL_H5P" > .env.production

echo -e "\n\nYARN INSTALL" && echo_line
yarn install

echo -e "\n\nYARN BUILD" && echo_line
ENV=build yarn build

rm .env.production
popd
    
