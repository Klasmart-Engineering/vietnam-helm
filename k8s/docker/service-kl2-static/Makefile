BASE_URL_USER := $(shell ../../../scripts/python/env_var.py "$(ENV)" "base_url_user")
BASE_URL_H5P := $(shell ../../../scripts/python/env_var.py "$(ENV)" "base_url_h5p")

all: output

output: cms-frontend-web/build
	source ../../../scripts/bash/functions.sh && env_validate $(ENV)
	mkdir -p output/cms-frontend-web
	cp -r cms-frontend-web/build output/cms-frontend-web
	cp Dockerfile output
	cp default.conf output
	echo "$(shell git rev-parse --short HEAD)-$(ENV)" > output/version.txt

clean:
	git submodule deinit -f cms-frontend-web &&\
	git submodule update --init -- cms-frontend-web
	rm -rf output

cms-frontend-web/.yarnrc:
	echo "registry \"https://yarn.npmjs.org\"" > cms-frontend-web/.yarnrc

cms-frontend-web/.env.production:
	test -z "$(BASE_URL_USER)" || echo "Missing variable, 'base_url_user', in $(ENV)"
	echo "PUBLIC_URL=." > cms-frontend-web/.env.production
	echo "REACT_APP_KO_BASE_API=$(BASE_URL_USER)" >> cms-frontend-web/.env.production
	echo "REACT_APP_BASE_API=v1" >> cms-frontend-web/.env.production
	echo "REACT_APP_H5P_API=$(BASE_URL_H5P)" >> cms-frontend-web/.env.production

cms-frontend-web/node_modules: cms-frontend-web/.yarnrc
	cd cms-frontend-web && yarn install

cms-frontend-web/build: cms-frontend-web/node_modules cms-frontend-web/.env.production
	source ../../../scripts/bash/functions.sh &&\
	env_validate $(ENV) &&\
	cd cms-frontend-web &&\
	yarn build

.PHONY: all
