#!/bin/bash

clear
rm -rf ./docker-extract/
mkdir ./docker-extract/
export ARTIFACT_STAGING_DIRECTORY=${ARTIFACT_STAGING_DIRECTORY:-./docker-extract}

export BRANCH=$(echo ${BRANCH:-$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')} | sed 's/refs\/heads\///g' | sed 's/refs\/tags\///g' | sed 's/\//-/g' | sed 's/\./-/g')
export DOCKER_REGISTRY=${DOCKER_REGISTRY:-}
export VERSION=${VERSION:-$(date '+%Y%m%d%H%M%S')}

export RUN_SONARQUBE=${RUN_SONARQUBE:-true}
export SONARQUBE_URL=${SONARQUBE_URL:-http://172.17.0.1:4000}
export SONARQUBE_LOGIN=${SONARQUBE_LOGIN:-admin}
export SONARQUBE_PASSWORD=${SONARQUBE_PASSWORD:-bitnami}
export SONARQUBE_PROJECT=${SONARQUBE_PROJECT:-projeto42.sonarqube.com.br}
export SONARQUBE_PROJECT_VERSION=${VERSION}

export CONTAINER_NAME="ci-tests-artifacts-${VERSION}"

echo 'Iniciando docker-compose build'
docker-compose -f Projeto42.SonarQube/docker-compose.ci.yml up --build --force-recreate --abort-on-container-exit

echo 'Extraindo artefatos dos testes'
docker cp ${CONTAINER_NAME}:/TestResults ${ARTIFACT_STAGING_DIRECTORY}/TestResults

echo 'Removendo container temporário'
docker rm ${CONTAINER_NAME}