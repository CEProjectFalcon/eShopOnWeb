using OpenQA.Selenium;

namespace UITests.PageObjects
{
    public class CheckoutPage
    {
        private static IWebElement elemento;

        public static IWebElement fazerCheckout(IWebDriver driver)
        {
            elemento = driver.FindElement(By.XPath("/html/body/div/div/form/div/div[3]/section[2]/a"));

            return elemento;
        }

        public static IWebElement efetuarCompra(IWebDriver driver)
        {
            elemento = driver.FindElement(By.XPath("/html/body/div/div/form/div/div[3]/section[2]/input"));

            return elemento;
        }
    }
}

