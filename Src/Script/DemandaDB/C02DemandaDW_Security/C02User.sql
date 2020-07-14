/* ========================================================================== 
Proyecto: DemandaBI
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya 
Fecha: 2020-07-15
Fecha actualizacion: 2020-07-15
========================================================================== */ 

/* ========================================================================== 
VARIABLES PARA INSTALAR:
$(DATABASE_NAME_DW): Nombre de la base de datos. Ejemplo: DemandaDW
$(DATABASE_PROXYWINDOWSUSER): Usuario de Windows usado para crear cuenta proxy. Ejemplo: MiDominio\MiUsuario
========================================================================== */

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - Start script: C02User.sql'
PRINT '------------------------------------------------------------------------'
GO

USE [$(DATABASE_NAME_DW)];

/* ========================================================================== 
 CAMBIAR OWNER DE BASE DE DATOS
 ========================================================================== */
/*
Utilizar una de las dos instrucciones siguientes

-- Cambiar ownwer: SA
ALTER AUTHORIZATION ON DATABASE::$(DATABASE_NAME_DW) TO SA;

-- Cambiar ownwer: Usuario actual
Declare @login nvarchar(128), @sql nvarchar (1000)
set @login = SYSTEM_USER
SET @sql = 'ALTER AUTHORIZATION ON DATABASE::$(DATABASE_NAME_DW) TO ' + Quotename(@login);
EXECUTE (@sql)
*/

/* ========================================================================== 
 ADICIONAR USUARIOS A BASE DE DATOS
 ========================================================================== */
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE sid = SUSER_SID(N'USR_DemandaDW'))
   AND EXISTS (SELECT * FROM master.sys.server_principals where sid = SUSER_SID(N'USR_DemandaDW'))
 CREATE USER [USR_DemandaDW] FOR LOGIN [USR_DemandaDW] WITH DEFAULT_SCHEMA=[dbo];
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE sid = SUSER_SID(N'$(DATABASE_PROXYWINDOWSUSER)'))
   AND EXISTS (SELECT * FROM master.sys.server_principals where sid = SUSER_SID(N'$(DATABASE_PROXYWINDOWSUSER)'))
 CREATE USER [$(DATABASE_PROXYWINDOWSUSER)] FOR LOGIN [$(DATABASE_PROXYWINDOWSUSER)] WITH DEFAULT_SCHEMA=[dbo];
GO

USE [msdb];
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE sid = SUSER_SID(N'USR_DemandaDW'))
   AND EXISTS (SELECT * FROM master.sys.server_principals where sid = SUSER_SID(N'USR_DemandaDW'))
 CREATE USER [USR_DemandaDW] FOR LOGIN [USR_DemandaDW] WITH DEFAULT_SCHEMA=[dbo];
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE sid = SUSER_SID(N'$(DATABASE_PROXYWINDOWSUSER)'))
   AND EXISTS (SELECT * FROM master.sys.server_principals where sid = SUSER_SID(N'DATABASE_PROXYWINDOWSUSER'))
 CREATE USER [$(DATABASE_PROXYWINDOWSUSER)] FOR LOGIN [$(DATABASE_PROXYWINDOWSUSER)] WITH DEFAULT_SCHEMA=[dbo]
GO

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - End script: C02User.sql'
PRINT '------------------------------------------------------------------------'
GO