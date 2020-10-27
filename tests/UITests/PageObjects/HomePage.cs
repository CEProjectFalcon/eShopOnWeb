using OpenQA.Selenium;

namespace UITests.PageObjects
{
    public class HomePage
    {

        private static IWebElement elemento;
        private static string texto;

        public static IWebElement meuLogin(IWebDriver driver)
        {
            elemento = driver.FindElement(By.XPath("/html/body/div/header/div/article/section[2]/div/section/div/a"));

            return elemento;
        }

        public static string verificaTextoBotao(IWebDriver driver)
        {
            texto = driver.FindElement(By.XPath("//*[@id='Next']")).Text;

            return texto;
        }
    }
}
