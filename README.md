# Projeto 42 - SonarQube

## [SonarQube](https://www.sonarqube.org)
- SonarQube is an open source quality management platform, dedicated to continuously analyze and measure technical quality, from project portfolio to method
- Precisa ter o [java](https://www.oracle.com/java/technologies/javase-jdk13-downloads.html) instalado

## [Documentação](https://docs.sonarqube.org/latest/)
- [languages](https://docs.sonarqube.org/latest/analysis/languages/overview/)
- [sonarscanner](https://docs.sonarqube.org/latest/analysis/scan/sonarscanner/)
    - The SonarScanner is the scanner to use when there is no specific scanner for your build system.
- [parameters](https://docs.sonarqube.org/latest/analysis/analysis-parameters/)
- [coverage](https://docs.sonarqube.org/latest/analysis/coverage/)

## Ambiente
- [bitnami/sonarqube](https://hub.docker.com/r/bitnami/sonarqube/)

```sh
docker-compose up -d docker.compose.yml up -d
```

## sonarscanner - NetCore
Necessário instalar os seguintes pacotes nos projetos de teste
- [coverlet.msbuild](https://www.nuget.org/packages/coverlet.msbuild/)
  - Coverlet is a cross platform code coverage library for .NET, with support for line, branch and method coverage.
- [Microsoft.CodeCoverage](https://www.nuget.org/packages/Microsoft.CodeCoverage/16.7.0-preview-20200519-01)
  - Microsoft.CodeCoverage package brings infra for collecting code coverage from vstest.console.exe and "dotnet test".
- [XunitXml.TestLogger](https://www.nuget.org/packages/XunitXml.TestLogger/)
  - Xml logger for xunit when test is running with "dotnet test" or "dotnet vstest".

Ferramentas globais
- [dotnet-sonarscanner](https://www.nuget.org/packages/dotnet-sonarscanner)
- [dotnet-reportgenerator-globaltool](https://www.nuget.org/packages/dotnet-reportgenerator-globaltool/)
  - ReportGenerator converts coverage reports generated by OpenCover, dotCover, Visual Studio, NCover, Cobertura, JaCoCo, Clover, gcov or lcov into human readable reports in various formats.
- [coverlet.console](https://www.nuget.org/packages/coverlet.console/)

```sh
dotnet sonarscanner begin \
/k:"$SONARQUBE_PROJECT" \
/v:"$SONARQUBE_PROJECT_VERSION" \
/d:sonar.login=$SONARQUBE_LOGIN \
/d:sonar.host.url=$SONARQUBE_URL \
/d:sonar.cs.vstest.reportsPaths="$RESULT_PATH*.trx" \
/d:sonar.cs.opencover.reportsPaths="$COVERAGE_PATH**/coverage.opencover.xml"

dotnet build

dotnet test --logger "trx;LogFileName=TestResults.trx" --results-directory $RESULT_PATH \
/p:CollectCoverage=true \
/p:CoverletOutput=$COVERAGE_PATH \
/p:CoverletOutputFormat=\"$CoverletOutputFormat\"

dotnet sonarscanner end \
/d:sonar.login=$SONARQUBE_LOGIN \
/d:sonar.password=$SONARQUBE_PASSWORD
```


## sonarscanner - Javascript
- [sonarqube-scanner](https://www.npmjs.com/package/sonarqube-scanner)
  - npm install -g sonarqube-scanner

```sh
sonar-scanner \
-Dsonar.projectKey="$SONARQUBE_PROJECT" \
-Dsonar.projectVersion="$SONARQUBE_PROJECT_VERSION" \
-Dsonar.projectName="$SONARQUBE_PROJECT" \
-Dsonar.host.url="$SONARQUBE_URL" \
-Dsonar.login=$SONARQUBE_LOGIN \
-Dsonar.password=$SONARQUBE_PASSWORD
```

## sonarscanner - Genérico
- [Docker - SonarScanner CLI](https://hub.docker.com/r/sonarsource/sonar-scanner-cli)

```
sonar.projectKey=motorista.android
sonar.projectName=motorista.android
sonar.projectVersion=1.0
sonar.sources=app/src/main/
sonar.login=admin
sonar.password=bitnami
```

```sh
docker run --rm -e SONAR_HOST_URL=http://172.17.0.1:9000 -v "/Users/elvis/repo/carguero/motorista.android:/usr/src" sonarsource/sonar-scanner-cli
```

# [Sonar](http://localhost:9000/)
- [Quality Gates](http://localhost:9000/quality_gates/show/1)
- [Quality Profiles](http://localhost:9000/profiles)
- [Coding Rules](http://localhost:9000/coding_rules)
- [marketplace](http://localhost:9000/admin/marketplace)