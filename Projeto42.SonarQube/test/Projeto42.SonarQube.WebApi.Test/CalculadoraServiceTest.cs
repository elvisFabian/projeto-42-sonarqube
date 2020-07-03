using System;
using Projeto42.SonarQube.Core;
using Xunit;

namespace Projeto42.SonarQube.WebApi.Test
{
    public class CalculadoraServiceTest
    {
        private readonly CalculadoraService _calculadoraService;

        public CalculadoraServiceTest()
        {
            _calculadoraService = new CalculadoraService();
        }

        [Fact]
        public void Deve_somar_corretamente()
        {
            var result = _calculadoraService.Somar(1, 1);

            Assert.Equal(2, result);
        }
        
        //[Fact]
        public void Quebrar_pra_ver_comportamento()
        {
            var result = _calculadoraService.Somar(1, 1);

            Assert.Equal(99, result);
        }
    }
}