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
        /d:sonar.cs.vstest.reportsPaths="${RESULT_PATH}*.trx" /d:sonar.cs.opencover.reportsPaths="${COVERAGE_PATH}**/coverage.opencover.xml" || true;
fi


#necessário rodar o dotnet build entre o begin e end do sonarqube
echo ""
echo "--------------Iniciando dotnet build $SOLUTION_NAME"
dotnet build $SOLUTION_NAME -v m --no-restore

echo ""
echo "--------------Iniciando dotnet test $SOLUTION_NAME"
DOTNET_TEST="dotnet test $SOLUTION_NAME --no-build --no-restore -v m --logger \"trx;LogFileName=TestResults.trx\" --results-directory $RESULT_PATH \
		/p:CollectCoverage=true /p:CoverletOutput=$COVERAGE_PATH /p:CoverletOutputFormat=\"$CoverletOutputFormat\""

#https://github.com/tonerdo/coverlet/issues/37  => Coverage report is not generated if there are any failing tests
#Para gerar covertura de código mesmo com teste falhando, usar coverlet, mas ai precisa rodar dotnet test por csproj
#https://github.com/tonerdo/coverlet
#https://www.nuget.org/packages/coverlet.console/
$DOTNET_TEST || true;


#https://danielpalme.github.io/ReportGenerator/usage.html
echo ""
echo "--------------Iniciando reportgenerator"
reportgenerator "-reports:${COVERAGE_PATH}coverage.cobertura.xml" "-targetdir:$COVERAGE_REPORT_PATH" -reporttypes:"HTMLInline" -verbosity:Error || true;

if [[ ${RUN_SONARQUBE} = "true" ]]; then
    dotnet sonarscanner end /d:sonar.password=$SONARQUBE_PASSWORD /d:sonar.login=$SONARQUBE_LOGIN || true;
fi