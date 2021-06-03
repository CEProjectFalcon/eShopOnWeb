using OpenQA.Selenium;

namespace UITests.PageObjects
{
    public class LoginPage
    {
        private static IWebElement elemento;

        public static IWebElement username(IWebDriver driver)
        {
            elemento = driver.FindElement(By.XPath("//*[@id='Input_Email']"));

            return elemento;
        }

        public static IWebElement password(IWebDriver driver)
        {
            elemento = driver.FindElement(By.XPath("//*[@id='Input_Password']"));

            return elemento;
        }

        public static IWebElement btn_login(IWebDriver driver)
        {
            elemento = driver.FindElement(By.XPath("/html/body/div/div/div/div/section/form/div[5]/button"));

            return elemento;
        }
    }
}
