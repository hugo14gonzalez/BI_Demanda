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
========================================================================== */

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - Start script: C03Rol.sql'
PRINT '------------------------------------------------------------------------'
GO

/* ========================================================================== 
 CREAR ROLES
 ========================================================================== */
USE [$(DATABASE_NAME_DW)];
GO
IF NOT EXISTS(SELECT * FROM sys.database_principals WHERE [name] = N'R_DemandaDW' AND [type] = 'R')
BEGIN
 CREATE ROLE [R_DemandaDW] AUTHORIZATION [dbo];
END
GO

/* ========================================================================== 
 ADICIONAR USUARIOS A ROLES DE BASE DE DATOS
 ========================================================================== */
IF EXISTS(SELECT * FROM sys.database_principals WHERE [name] = N'R_DemandaDW' AND [type] = 'R')
   AND EXISTS (SELECT * FROM sys.database_principals WHERE [name] = N'USR_DemandaDW')
 EXEC sp_addrolemember N'R_DemandaDW', N'USR_DemandaDW';
GO

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - End script: C03Rol.sql'
PRINT '------------------------------------------------------------------------'
GO