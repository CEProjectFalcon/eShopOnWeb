using System;
using System.Collections.Generic;
using System.Text;

namespace Microsoft.eShopWeb.Infrastructure.Data.Config
{
    public class StorageConfiguration
    {
        public const string  StorageConfigSection = "Storage";
        public string ConnectionString { get; set; }
        public string Container { get; set; }
    }
}
