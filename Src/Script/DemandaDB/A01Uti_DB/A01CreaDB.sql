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
$(DATABASE_PATH_LOG_DW): Ruta archivo log de transacciones *.ldf. Ejemplo: C:\MSDB\DemandaDW
$(DATABASE_PATH_PRIMARY_DW): Ruta archivo principal de base datos *.mdf. Ejemplo: C:\MSDB\DemandaDW
========================================================================== */

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - Start script: A01CreaDB.sql'
PRINT '------------------------------------------------------------------------'
GO

/* ====================================================================================
 Create BD
 ==================================================================================== */
USE [Master]
GO
IF NOT EXISTS(select * from sys.databases where name = '$(DATABASE_NAME_DW)')
Begin
CREATE DATABASE [$(DATABASE_NAME_DW)] ON (
  NAME = N'$(DATABASE_NAME_DW)_Data', 
  FILENAME = N'$(DATABASE_PATH_PRIMARY_DW)\$(DATABASE_NAME_DW)_Data.MDF' , 
  SIZE = 10MB, 
  MAXSIZE = UNLIMITED,
  FILEGROWTH = 10%) 
 LOG ON (
  NAME = N'$(DATABASE_NAME_DW)_Log', 
  FILENAME = N'$(DATABASE_PATH_LOG_DW)\$(DATABASE_NAME_DW)_Log.LDF' , 
  MAXSIZE = UNLIMITED,
  SIZE = 1MB, 
  FILEGROWTH = 10%)
end
GO

ALTER DATABASE [$(DATABASE_NAME_DW)] SET AUTO_CREATE_STATISTICS ON;
ALTER DATABASE [$(DATABASE_NAME_DW)] SET AUTO_UPDATE_STATISTICS ON;
ALTER DATABASE [$(DATABASE_NAME_DW)] SET AUTO_SHRINK OFF;
ALTER DATABASE [$(DATABASE_NAME_DW)] SET RECOVERY SIMPLE WITH NO_WAIT;  
ALTER DATABASE [$(DATABASE_NAME_DW)] SET TRUSTWORTHY ON;
GO 

/* ====================================================================================
 Verificar files y filegroups
==================================================================================== */
/*
USE [$(DATABASE_NAME_DW)]
EXEC sp_helpdb [$(DATABASE_NAME_DW)];
*/

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - End script: A01CreaDB.sql'
PRINT '------------------------------------------------------------------------'
GO
