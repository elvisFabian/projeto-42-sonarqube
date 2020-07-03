using System;
using System.Net.Http;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Extensions.Configuration;

namespace Projeto42.SonarQube.WebApi.Test.Server
{
    public class ServerFixture : WebApplicationFactory<Startup>
    {
        protected override void ConfigureClient(HttpClient client)
        {
            base.ConfigureClient(client);
            ConfigBaseAdress(client);
        }

        private static void ConfigBaseAdress(HttpClient client)
        {
            var config = new ConfigurationBuilder()
                .AddEnvironmentVariables()
                .Build();

            string baseAdress = "http://localhost";
            client.BaseAddress = new Uri(baseAdress);
        }
    }
}