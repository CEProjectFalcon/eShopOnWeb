using System;
using Xunit;
using OpenQA.Selenium;
using OpenQA.Selenium.Chrome;
using UITests.PageObjects;

namespace UITests
{
    public class BasketTest
    {
        IWebDriver driver = new ChromeDriver(Environment.CurrentDirectory);

        [Fact]
        public void testaCarrinho()
        {
            driver.Navigate().GoToUrl("https://localhost:44315/");

            BasketPage.adicionarProdutoAoCarrinho(driver).Click();

            //CheckoutPage.fazerCheckout(driver).Click();

            //CheckoutPage.efetuarCompra(driver).Click();
        }
    }
}