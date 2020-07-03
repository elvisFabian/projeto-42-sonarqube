using System.Net.Http;
using Xunit;

namespace Projeto42.SonarQube.WebApi.Test.Server
{
    public class IntegrationTestBase : IClassFixture<ServerFixture>
    {
        public readonly HttpClient HttpClient;

        public IntegrationTestBase(ServerFixture factory)
        {
            HttpClient = factory.CreateDefaultClient();
        }
    }
}