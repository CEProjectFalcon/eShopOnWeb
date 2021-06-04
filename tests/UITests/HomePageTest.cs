using System;
using Xunit;
using OpenQA.Selenium;
using OpenQA.Selenium.Chrome;
using UITests.PageObjects;

namespace UITests
{
    public class HomePageTest
    {
        IWebDriver driver = new ChromeDriver(Environment.CurrentDirectory);
        String textoBotao;

        [Fact]
        public void testaBotao()
        {
            driver.Navigate().GoToUrl("https://localhost:44315/");

            textoBotao = HomePage.verificaTextoBotao(driver);

            /* Verifica se o texto do botão é igual a Next; como isto é verdadeiro, 
             * o resultado será true*/
            Assert.Equal("Next", textoBotao);

            /* Assert com resultado false, pois texto passado como verificação é diferente
             * do texto do botão*/
            //Assert.Equal("Próximo", textoBotao);
        }
    }
}
