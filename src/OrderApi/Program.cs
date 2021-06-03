using System;
using System.Linq;
using Azure.Identity;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Configuration.AzureAppConfiguration;

namespace OrderApi
{
    public class Program
    {
        public static void Main(string[] args)
        {
            CreateHostBuilder(args).Build().Run();
        }

        public static IHostBuilder CreateHostBuilder(string[] args) =>
            Host.CreateDefaultBuilder(args)
                .ConfigureWebHostDefaults(webBuilder =>
                    webBuilder.ConfigureAppConfiguration(config =>
                    {
                        var settings = config.Build();
                        config.AddAzureAppConfiguration(options =>
                            options
                                .Connect(Environment.GetEnvironmentVariable("APPCONFIG_CONNECTIONSTRING"))
                                .ConfigureKeyVault(kv =>
                                {
                                    kv.SetCredential(new DefaultAzureCredential());
                                })
                                .Select(KeyFilter.Any, LabelFilter.Null)
                                .Select(KeyFilter.Any, "OrderApi")
                        );
                    }).UseStartup<Startup>());
    }
}
