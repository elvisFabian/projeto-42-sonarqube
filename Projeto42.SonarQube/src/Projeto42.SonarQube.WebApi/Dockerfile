ARG DOT_NET_CORE_SDK_VERSION="3.1"
FROM mcr.microsoft.com/dotnet/core/sdk:$DOT_NET_CORE_SDK_VERSION as base
ARG OPENJDK_VERSION="default-jre"

#--------------------------------------Instalar o java-----------------------------------------#
#Necessário para o sonarqube
#https://community.sonarsource.com/t/sonarscanner-fails-with-error-permission-denied/1897
#https://community.sonarsource.com/t/c-sonarscanner-net-core-version-permission-denied-error-in-docker/8354
RUN apt-get update && apt-get install -y $OPENJDK_VERSION
#----------------------------------------------------------------------------------------------#

ARG SONAR_SCANNER_NUGET_VERSION="4.9.0"
ARG SONAR_SCANNER_BIN_VERSION="4.3.0.2102"
ARG SONAR_SCANNER_NETCORE_VERSION="netcoreapp3.0"
ARG REPORTGENERATOR_NUGET_VERSION="4.6.1"
ARG COVERLET_CONSOLE_NUGET_VERSION="1.7.2"

#--------------------------------------Instalando ferramentas globalmente----------------------#
RUN dotnet tool install --global dotnet-sonarscanner --version ${SONAR_SCANNER_NUGET_VERSION} && \
    dotnet tool install --global dotnet-reportgenerator-globaltool --version ${REPORTGENERATOR_NUGET_VERSION} && \
    dotnet tool install --global coverlet.console --version ${COVERLET_CONSOLE_NUGET_VERSION}

ENV PATH "$PATH:/root/.dotnet/tools/"
RUN chmod +x /root/.dotnet/tools/.store/dotnet-sonarscanner/${SONAR_SCANNER_NUGET_VERSION}/dotnet-sonarscanner/${SONAR_SCANNER_NUGET_VERSION}/tools/${SONAR_SCANNER_NETCORE_VERSION}/any/sonar-scanner-${SONAR_SCANNER_BIN_VERSION}/bin/sonar-scanner
#----------------------------------------------------------------------------------------------#

ARG CONFIGURATION="Release"

ENV CONFIGURATION=$CONFIGURATION
ENV RESULT_PATH="/TestResults/result/vsTest/"
ENV COVERAGE_PATH="/TestResults/codecoverage/"
ENV COVERAGE_REPORT_PATH="/TestResults/codecoverage/Report/"
ENV SOLUTION_NAME="Projeto42.SonarQube.sln"
#----------------------------------------------------------------------------------------------#

#Copia os csproj e restaura (cache only)
FROM base as restore

COPY ./*.sln ./NuGet.Config ./

COPY src/*/*.csproj ./
RUN for file in $(ls *.csproj); do mkdir -p src/${file%.*}/ && mv $file src/${file%.*}/; done

COPY test/*/*.csproj ./
RUN for file in $(ls *.csproj); do mkdir -p test/${file%.*}/ && mv $file test/${file%.*}/; done

RUN dotnet restore ${SOLUTION_NAME} -v m

#Target: Testes
FROM restore as tests
COPY . .

COPY ./entrypoint-tests.sh ./entrypoint-tests.sh
RUN chmod +x ./entrypoint-tests.sh
ENTRYPOINT ./entrypoint-tests.sh

#Target: Build
FROM restore as build
RUN dotnet build ${SOLUTION_NAME} -c  ${CONFIGURATION} -v m
RUN dotnet publish src/Projeto42.SonarQube.WebApi -c  ${CONFIGURATION} --no-build -o /app/www -v m

#Target: runtime
FROM mcr.microsoft.com/dotnet/core/aspnet:3.1 as runtime
COPY --from=build /app/www /app/www
WORKDIR /app/www
ENTRYPOINT dotnet Projeto42.SonarQube.WebApi.dll