USE master
GO
CREATE LOGIN [eshopweb] WITH PASSWORD=N'Senh4supersecre+a'
GO

USE [Microsoft.eShopOnWeb.CatalogDb]
GO
CREATE USER [eshopweb] FOR LOGIN [eshopweb] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [eshopweb]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [eshopweb]
GO

USE [Microsoft.eShopOnWeb.Identity]
GO
CREATE USER [eshopweb] FOR LOGIN [eshopweb] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [eshopweb]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [eshopweb]
GO
