/* ========================================================================== 
Proyecto: DemandaBI
Empresa:  
Desarrollador: Hugo Gonzalez Olaya 
Fecha: 2020-07-15
Fecha actualizacion: 2020-07-15
========================================================================== */ 

/* ========================================================================== 
VARIABLES PARA INSTALAR:
$(DATABASE_NAME_DW): Nombre de la base de datos. Ejemplo: DemandaDW
========================================================================== */

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - Start script: A02Schema.sql'
PRINT '------------------------------------------------------------------------'
GO

USE [$(DATABASE_NAME_DW)];

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'Audit')
 EXEC sys.sp_executesql N'CREATE SCHEMA [Audit] AUTHORIZATION [dbo]'
GO
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'Utility')
 EXEC sys.sp_executesql N'CREATE SCHEMA [Utility] AUTHORIZATION [dbo]'
GO
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'Staging')
 EXEC sys.sp_executesql N'CREATE SCHEMA [Staging] AUTHORIZATION [dbo]'
GO

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - End script: A02Schema.sql'
PRINT '------------------------------------------------------------------------'
GO