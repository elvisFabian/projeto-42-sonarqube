using System.Collections.Generic;
using System.Threading.Tasks;
using Projeto42.SonarQube.WebApi.Test.Extensions;
using Projeto42.SonarQube.WebApi.Test.Server;
using RestEase;
using Xunit;

namespace Projeto42.SonarQube.WebApi.Test
{
    [AllowAnyStatusCode]
    public interface IWeatherForecastControllerTestApi
    {
        [Get("WeatherForecast")]
        Task<Response<IEnumerable<WeatherForecast>>> Get();
    }

    public class WeatherForecastControllerTest : IntegrationTestBase
    {
        private IWeatherForecastControllerTestApi _weatherForecastControllerTestApi;

        public WeatherForecastControllerTest(ServerFixture factory) : base(factory)
        {
            _weatherForecastControllerTestApi = RestClient.For<IWeatherForecastControllerTestApi>(base.HttpClient);
        }

        [Fact]
        public async Task Ao_obter_todos_os_dados_retorno_nao_deve_ser_vazio()
        {
            var response = await _weatherForecastControllerTestApi.Get();
            var isSuccessStatusCode = response.ResponseMessage.IsSuccessStatusCode;
            Assert.True(isSuccessStatusCode);

            if (isSuccessStatusCode)
            {
                var values = response.StringContent.ReadAsJsonAsync<IEnumerable<WeatherForecast>>();
                Assert.NotNull(values);
                Assert.NotEmpty(values);
            }
        }
    }
}