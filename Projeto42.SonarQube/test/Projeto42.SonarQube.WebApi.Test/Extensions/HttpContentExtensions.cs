using System.Net.Http;
using System.Threading.Tasks;
using Newtonsoft.Json;

namespace Projeto42.SonarQube.WebApi.Test.Extensions
{
    public static class HttpContentExtensions
    {
        public static async Task<T> ReadAsJsonAsync<T>(this HttpContent content)
        {
            string json = await content.ReadAsStringAsync();
            return json.ReadAsJsonAsync<T>();
        }

        public static T ReadAsJsonAsync<T>(this string json)
        {
            T value = JsonConvert.DeserializeObject<T>(json);
            return value;
        }
    }
}