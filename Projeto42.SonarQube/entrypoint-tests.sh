#!/bin/bash

# Necessário instalar esses pacotes nos projetos de teste
#https://gunnarpeipman.com/aspnet/code-coverage/
# coverlet.msbuild
# Microsoft.CodeCoverage
# XunitXml.TestLogger

echo ""
echo "-------------------------------------------------------"
echo "Iniciando entrypoint - entrypoint-tests.sh"

#code coverage para testes de integraçao
#https://github.com/OpenCover/opencover/issues/668
#https://github.com/tonerdo/coverlet/issues/161 => multiple CoverletOutputFormat
CoverletOutputFormat="cobertura,opencover"

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
    echo "SONARQUBE_LOGIN: $SONARQUBE_LOGIN"
    echo "SONARQUBE_PASSWORD: $SONARQUBE_PASSWORD"
    echo "-------------------------------------------------------"

    dotnet sonarscanner begin /k:"$SONARQUBE_PROJECT" /v:"$SONARQUBE_PROJECT_VERSION" /d:sonar.password=$SONARQUBE_PASSWORD /d:sonar.login=$SONARQUBE_LOGIN /d:sonar.host.url=${SONARQUBE_URL} \
        /d:sonar.cs.vstest.reportsPaths="${RESULT_PATH}*.trx" \
        /d:sonar.cs.opencover.reportsPaths="${COVERAGE_PATH}**/coverage.opencover.xml" || true;

        #/d:sonar.cs.xunit.reportsPaths="${RESULT_PATH}*.xml" \
fi


#necessário rodar o dotnet build entre o begin e end do sonarqube
echo ""
echo "--------------Iniciando dotnet build $SOLUTION_NAME"
dotnet build $SOLUTION_NAME -v m --no-restore

echo ""
echo "--------------Iniciando dotnet test"
#https://github.com/tonerdo/coverlet/issues/37  => Coverage report is not generated if there are any failing tests
#Para gerar covertura de código mesmo com teste falhando, usar coverlet, mas ai precisa rodar dotnet test por projeto
#https://github.com/tonerdo/coverlet
#https://www.nuget.org/packages/coverlet.console/

#DOTNET_TEST="dotnet test $SOLUTION_NAME --no-build --no-restore -v m --logger \"trx;LogFileName=TestResults.trx\" --results-directory $RESULT_PATH /p:CollectCoverage=true /p:CoverletOutput=$COVERAGE_PATH /p:CoverletOutputFormat=\"$CoverletOutputFormat\""
#$DOTNET_TEST || true;

reportgenerator_reports=""

for testFolder in $(ls test); do \
    echo $testFolder

    echo '------dotnet test------' & \
    dotnet test test/$testFolder --no-build --no-restore -v m -c ${CONFIGURATION} \
        --results-directory "${RESULT_PATH}/" \
        --logger "trx;LogFileName=${testFolder}.trx" \
        #--logger "xunit;LogFilePath=${RESULT_PATH}${testFolder}.xml"; \
        exit 0 & \

    echo '------coverlet test------' & \
    COVERLET_OUTPUT="${COVERAGE_PATH}${testFolder}"
    coverlet test/${testFolder}/bin/${CONFIGURATION}/*/${testFolder}.dll --target "dotnet" --targetargs "test test/${testFolder} --no-build -c ${CONFIGURATION}" --format opencover --format cobertura --output "${COVERLET_OUTPUT}/"; \

    echo COVERLET_OUTPUT
    reportgenerator_reports="$reportgenerator_reports;${COVERLET_OUTPUT}/coverage.cobertura.xml"
done;


#https://danielpalme.github.io/ReportGenerator/usage.html
reporttypes="HTMLInline"
echo ""
echo "--------------Iniciando reportgenerator"
echo "reportgenerator_reports: $reportgenerator_reports"
echo "COVERAGE_REPORT_PATH: $COVERAGE_REPORT_PATH"
echo "reporttypes: $reporttypes"

reportgenerator "-reports:${reportgenerator_reports}" "-targetdir:$COVERAGE_REPORT_PATH" -reporttypes:"${reporttypes}" -verbosity:Info || true;

echo "-------------------------------------------------------"

if [[ ${RUN_SONARQUBE} = "true" ]]; then
    dotnet sonarscanner end /d:sonar.password=$SONARQUBE_PASSWORD /d:sonar.login=$SONARQUBE_LOGIN || true;
fi