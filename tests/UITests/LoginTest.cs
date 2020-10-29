using System;
using Xunit;
using OpenQA.Selenium;
using OpenQA.Selenium.Chrome;
using UITests.PageObjects;

namespace UITests
{
    public class LoginTest
    {
        IWebDriver driver = new ChromeDriver(Environment.CurrentDirectory);

        [Fact]
        public void testeLogin()
        {
            driver.Navigate().GoToUrl("https://localhost:44315/");

            HomePage.meuLogin(driver).Click();

            LoginPage.username(driver).SendKeys("demouser@microsoft.com");

            LoginPage.password(driver).SendKeys("Pass@word1");

            LoginPage.btn_login(driver).Click();
        }
    }
}
