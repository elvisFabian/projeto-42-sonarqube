#!/bin/bash

# Necessário instalar esses pacotes nos projetos de teste
#https://gunnarpeipman.com/aspnet/code-coverage/
# coverlet.msbuild
# Microsoft.CodeCoverage
# XunitXml.TestLogger

CoverletOutputFormat="cobertura,opencover"
REPORT_GENERATOR_REPORTS=""
REPORT_GENERATOR_REPORT_TYPES="HTMLInline"


echo ""
echo "-------------------------------------------------------"
echo "Iniciando entrypoint - entrypoint-tests.sh"

echo ""
echo "-------------------------------------------------------"
echo "dotnet properties"
echo "SOLUTION_NAME: $SOLUTION_NAME"
echo "RESULT_PATH: $RESULT_PATH"
echo "COVERAGE_PATH: $COVERAGE_PATH"
echo "COVERLET_OUTPUT_FORMAT: $CoverletOutputFormat"
echo "COVERAGE_REPORT_PATH: $COVERAGE_REPORT_PATH"
echo "-------------------------------------------------------"


if [[ ${RUN_SONARQUBE} = "true" ]]; then
    echo ""
    echo "-------------------------------------------------------"
    echo "Sonar properties"
    echo "SONARQUBE_PROJECT: $SONARQUBE_PROJECT"
    echo "SONARQUBE_PROJECT_VERSION: $SONARQUBE_PROJECT_VERSION"
    echo "SONARQUBE_URL: $SONARQUBE_URL"
    echo "-------------------------------------------------------"

    dotnet sonarscanner begin \
        /k:"$SONARQUBE_PROJECT" \
        /v:"$SONARQUBE_PROJECT_VERSION" \
        /d:sonar.verbose=false \
        /d:sonar.login=$SONARQUBE_TOKEN \
        /d:sonar.host.url=${SONARQUBE_URL} \
        /d:sonar.cs.vstest.reportsPaths="${RESULT_PATH}*.trx" \
        /d:sonar.cs.opencover.reportsPaths="${COVERAGE_PATH}**/coverage.opencover.xml" || true;
fi

echo ""
echo "--------------Iniciando dotnet build $SOLUTION_NAME"
dotnet build $SOLUTION_NAME -v q --no-restore

echo ""
echo "--------------Iniciando dotnet test"
#https://github.com/tonerdo/coverlet/issues/37  => Coverage report is not generated if there are any failing tests
#Para gerar covertura de código mesmo com teste falhando, usar coverlet, mas ai precisa rodar dotnet test por projeto
#https://github.com/tonerdo/coverlet
#https://www.nuget.org/packages/coverlet.console/

#dotnet test $SOLUTION_NAME --no-build --no-restore -v m --logger \"trx;LogFileName=TestResults.trx\" --results-directory $RESULT_PATH /p:CollectCoverage=true /p:CoverletOutput=$COVERAGE_PATH /p:CoverletOutputFormat=\"$CoverletOutputFormat\""


for testFolder in $(ls test); do \
    echo ""
    echo " - $testFolder"
    echo ""

    CURRENT_COVERLET_OUTPUT_PATH="${COVERAGE_PATH}${testFolder}"
    REPORT_GENERATOR_REPORTS="${CURRENT_COVERLET_OUTPUT_PATH}/coverage.cobertura.xml;$REPORT_GENERATOR_REPORTS"

    dotnet test test/$testFolder --no-build --no-restore -v q -c ${CONFIGURATION} \
        --results-directory "${RESULT_PATH}/" \
        --logger "trx;LogFileName=${testFolder}.trx" \
        --logger "xunit;LogFilePath=${RESULT_PATH}${testFolder}.xml"; \
        exit 0 & \

    coverlet test/${testFolder}/bin/${CONFIGURATION}/*/${testFolder}.dll \
        --target "dotnet" \
        --targetargs "test test/${testFolder} --no-build -c ${CONFIGURATION}" \
        --format opencover \
        --format cobertura \
        --output "${CURRENT_COVERLET_OUTPUT_PATH}/"; \
done;


echo ""
echo "-------------------------------------------------------"
echo "reportgenerator properties"
echo "REPORT_GENERATOR_REPORTS: $REPORT_GENERATOR_REPORTS"
echo "COVERAGE_REPORT_PATH: $COVERAGE_REPORT_PATH"
echo "REPORT_GENERATOR_REPORT_TYPES: $REPORT_GENERATOR_REPORT_TYPES"
echo "-------------------------------------------------------"

reportgenerator "-reports:${REPORT_GENERATOR_REPORTS}" "-targetdir:$COVERAGE_REPORT_PATH" -reporttypes:"${REPORT_GENERATOR_REPORT_TYPES}" -verbosity:Error || true;


if [[ ${RUN_SONARQUBE} = "true" ]]; then
    dotnet sonarscanner end /d:sonar.login=$SONARQUBE_TOKEN || true;
fi