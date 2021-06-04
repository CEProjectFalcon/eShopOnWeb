using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Microsoft.eShopWeb.Web.Configuration
{
    public class DataProtectionConfig
    {
        public const string CONFIG_NAME = "DataProtection";

        public string StorageAccountConnectionString { get; set; }

        public string KeyVaultUri { get; set; }
    }
}
