#!/bin/bash

clear

echo "---------------Iniciando run-ci.sh---------------"

export ARTIFACT_STAGING_DIRECTORY=${ARTIFACT_STAGING_DIRECTORY:-./docker-extract}
rm -rf ${ARTIFACT_STAGING_DIRECTORY}
mkdir ${ARTIFACT_STAGING_DIRECTORY}

export GIT_SHORT_SHA=$(git rev-parse --short=10 $(git log -n1 --format=format:"%H" ))
export GIT_BRANCH=$(echo ${BRANCH:-$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')} | sed 's/refs\/heads\///g' | sed 's/refs\/tags\///g' | sed 's/\//-/g' | sed 's/\./-/g')
export GIT_REPO_NAME=$(echo $(basename -s .git `git config --get remote.origin.url`))

export DOCKER_REGISTRY=${DOCKER_REGISTRY:-}
export VERSION=${VERSION:-$(date '+%Y%m%d%H%M%S')}
export RUN_SONARQUBE=${RUN_SONARQUBE:-true}
export SONARQUBE_URL=${SONARQUBE_URL:-http://172.17.0.1:9000}
export SONARQUBE_TOKEN=${SONARQUBE_TOKEN:-f97ab034893971cb8ad80990fd77e8a829ac842a}
export SONARQUBE_PROJECT=${GIT_REPO_NAME}
export SONARQUBE_PROJECT_VERSION=${VERSION}
export CONTAINER_NAME="ci-tests-artifacts-${VERSION}"
export TAG="$GIT_BRANCH-$GIT_SHORT_SHA"


echo 'Iniciando docker-compose build'
docker-compose -f Projeto42.SonarQube/docker-compose.ci.yml up --build --force-recreate --abort-on-container-exit

echo 'Extraindo artefatos dos testes'
docker cp ${CONTAINER_NAME}:/TestResults ${ARTIFACT_STAGING_DIRECTORY}/TestResults

echo 'Removendo container temporário'
docker rm ${CONTAINER_NAME}
