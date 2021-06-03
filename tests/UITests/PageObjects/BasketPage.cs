using OpenQA.Selenium;

namespace UITests.PageObjects
{
    public class BasketPage
    {
        private static IWebElement elemento;

        public static IWebElement adicionarProdutoAoCarrinho(IWebDriver driver)
        {
            elemento = driver.FindElement(By.XPath("/html/body/div/div/div[2]/div[2]/form/input[1]"));

            return elemento;
        }
    }
}
