using System;
using Xunit;
using OpenQA.Selenium;
using OpenQA.Selenium.Chrome;
using UITests.PageObjects;

namespace UITests
{
    public class Tests
    {
        IWebDriver driver = new ChromeDriver(Environment.CurrentDirectory);

        [Fact]
        public void testarNavegacao()
        {
            //Acessar URL
            driver.Navigate().GoToUrl("https://localhost:44315/");

            //Maximizar tela
            driver.Manage().Window.Maximize();

            //Login
            HomePage.meuLogin(driver).Click();
            LoginPage.username(driver).SendKeys("demouser@microsoft.com");
            LoginPage.password(driver).SendKeys("Pass@word1");
            LoginPage.btn_login(driver).Click();

            //Adicionar produto ao carrinho
            BasketPage.adicionarProdutoAoCarrinho(driver).Click();

            //Fazer checkout
            CheckoutPage.fazerCheckout(driver).Click();

            //Efetuar compra (pagar)
            CheckoutPage.efetuarCompra(driver).Click();

            //Fechar navegador
            driver.Quit();
        }
    }
}
