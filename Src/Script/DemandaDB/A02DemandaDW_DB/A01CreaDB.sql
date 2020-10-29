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

/* ========================================================================== 
VARIABLES PARA INSTALAR:
$(DATABASE_NAME_DW): Nombre de la base de datos. Ejemplo: DemandaDW
$(DATABASE_PATH_LOG_DW): Ruta archivo log de transacciones *.ldf. Ejemplo: C:\MSDB\DemandaDW
$(DATABASE_PATH_PRIMARY_DW): Ruta archivo principal de base datos *.mdf. Ejemplo: C:\MSDB\DemandaDW
$(DATABASE_PATH_DEMANDADW_DAT): Ruta file group tablas no particionadas (datos e indice clusterado) *.ndf. Ejemplo: C:\MSDB\DemandaDW
$(DATABASE_PATH_DEMANDADW_IND): Ruta file group tablas no particionadas (indices) *.ndf. Ejemplo: C:\MSDB\DemandaDW

$(DATABASE_PATH_DEMANDA_DAT): Ruta file group demanda particion (datos e indice clusterado) *.ndf. Ejemplo: C:\MSDB\DemandaDW
$(DATABASE_PATH_DEMANDA_IND): Ruta file group demanda particion (indices) *.ndf. Ejemplo: C:\MSDB\DemandaDW
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
 Adicionar FileGroup: 
==================================================================================== */
USE [$(DATABASE_NAME_DW)]
GO

IF NOT EXISTS (SELECT * FROM sys.filegroups WHERE [Name] = 'fgDemandaDW_dat')
 ALTER DATABASE [$(DATABASE_NAME_DW)] ADD FILEGROUP [fgDemandaDW_dat];
GO
IF NOT EXISTS (SELECT * FROM sys.database_files WHERE [Name] = 'DemandaDW_dat')
 ALTER DATABASE [$(DATABASE_NAME_DW)] 
 ADD FILE 
 (
   NAME = 'DemandaDW_dat',
   FILENAME = '$(DATABASE_PATH_DEMANDADW_DAT)\$(DATABASE_NAME_DW)_DemandaDW_dat.ndf',
   SIZE = 5MB,
   MAXSIZE = UNLIMITED,
   FILEGROWTH = 10MB
 ) TO FILEGROUP [fgDemandaDW_dat];
GO

IF NOT EXISTS (SELECT * FROM sys.filegroups WHERE [Name] = 'fgDemandaDW_ind')
 ALTER DATABASE [$(DATABASE_NAME_DW)] ADD FILEGROUP [fgDemandaDW_ind];
GO
IF NOT EXISTS (SELECT * FROM sys.database_files WHERE [Name] = 'DemandaDW_ind')
 ALTER DATABASE [$(DATABASE_NAME_DW)] 
 ADD FILE 
 (
   NAME = 'DemandaDW_ind',
   FILENAME = '$(DATABASE_PATH_DEMANDADW_IND)\$(DATABASE_NAME_DW)_DemandaDW_ind.ndf',
   SIZE = 5MB,
   MAXSIZE = UNLIMITED,
   FILEGROWTH = 10MB
 ) TO FILEGROUP [fgDemandaDW_ind];
GO

IF NOT EXISTS (SELECT * FROM sys.filegroups WHERE [Name] = 'fgMaster')
 ALTER DATABASE [$(DATABASE_NAME_DW)] ADD FILEGROUP [fgMaster];
GO
IF NOT EXISTS (SELECT * FROM sys.database_files WHERE [Name] = 'Master')
 ALTER DATABASE [$(DATABASE_NAME_DW)] 
 ADD FILE 
 (
   NAME = 'Master',
   FILENAME = '$(DATABASE_PATH_DEMANDADW_DAT)\$(DATABASE_NAME_DW)_Master.ndf',
   SIZE = 5MB,
   MAXSIZE = UNLIMITED,
   FILEGROWTH = 10%
 ) TO FILEGROUP [fgMaster];
GO

-- Filegroups para almacaner particiones
PRINT 'Creando file groups espere ...';
GO
Declare @sql varchar(8000), @month int, @t int, @s int, @maxFileGroupSequence int, @maxFileGroupMonths int, @table nvarchar(128), @maxTables int;
Declare @path_Dat nvarchar(500), @path_Ind nvarchar(500), @message nvarchar(max);

set @maxFileGroupSequence = 1; 
set @maxFileGroupMonths = 12; 
set @t = 1;
set @maxTables = 1;

while (@t <= @maxTables)
Begin
 select @table = case 
  when @t = 1 then 'FactDemandaPerdida'
 end;

 set @message = Convert(nvarchar(30), GetDate(), 121) + ' - Creando file groups (' + convert(varchar, @t) + '/' + convert(varchar, @maxTables) + '): ' + @table + ' ...';
 RAISERROR(@message, 0, 1) WITH NOWAIT;

 select @path_Dat = case 
  when @t = 1 then '$(DATABASE_PATH_DEMANDA_DAT)'
 end;
 
 select @path_Ind = case 
  when @t = 1 then '$(DATABASE_PATH_DEMANDA_IND)'
 end;

 select @maxFileGroupSequence = case 
  when @t = 1 then 10
 end;
 
 set @s = 1;
 while (@s <= @maxFileGroupSequence)
 Begin
  set @month = 1;
  
  while (@month <= @maxFileGroupMonths)
  Begin
   set @sql = 
   'IF NOT EXISTS (SELECT * FROM [$(DATABASE_NAME_DW)].sys.filegroups WHERE [Name] = ''fg' + @table + '_' + convert(nvarchar, @s) + '_' + convert(nvarchar, @month) + '_dat'')
    ALTER DATABASE [$(DATABASE_NAME_DW)] ADD FILEGROUP [fg' + @table + '_' + convert(nvarchar, @s) + '_' + convert(nvarchar, @month) + '_dat];'
   Execute(@sql);

   set @sql = 
   'IF NOT EXISTS (SELECT * FROM [$(DATABASE_NAME_DW)].sys.database_files WHERE [Name] = ''$(DATABASE_NAME_DW)_' + @table + '_' + convert(nvarchar, @s) + '_' + convert(nvarchar, @month) + '_dat'')
   ALTER DATABASE [$(DATABASE_NAME_DW)] 
   ADD FILE 
   (
    NAME = ''$(DATABASE_NAME_DW)_' + @table + '_' + convert(nvarchar, @s) + '_' + convert(nvarchar, @month) + '_dat'',
    FILENAME = ''' + @path_Dat + '\$(DATABASE_NAME_DW)_' + @table + '_' + convert(nvarchar, @s) + '_' + convert(nvarchar, @month) + '_dat.ndf'',
    SIZE = 1024KB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 10240KB
   ) TO FILEGROUP [fg' + @table + '_' + convert(nvarchar, @s) + '_' + convert(nvarchar, @month) + '_dat];'
   Execute(@sql);
 
   set @sql = 
   'IF NOT EXISTS (SELECT * FROM [$(DATABASE_NAME_DW)].sys.filegroups WHERE [Name] = ''fg' + @table + '_' + convert(nvarchar, @s) + '_' + convert(nvarchar, @month) + '_ind'')
    ALTER DATABASE [$(DATABASE_NAME_DW)] ADD FILEGROUP [fg' + @table + '_' + convert(nvarchar, @s) + '_' + convert(nvarchar, @month) + '_ind];'
   Execute(@sql);

   set @sql = 
   'IF NOT EXISTS (SELECT * FROM [$(DATABASE_NAME_DW)].sys.database_files WHERE [Name] = ''$(DATABASE_NAME_DW)_' + @table + '_' + convert(nvarchar, @s) + '_' + convert(nvarchar, @month) + '_ind'')
    ALTER DATABASE [$(DATABASE_NAME_DW)] 
    ADD FILE 
    (
     NAME = ''$(DATABASE_NAME_DW)_' + @table + '_' + convert(nvarchar, @s) + '_' + convert(nvarchar, @month) + '_ind'',
     FILENAME = ''' + @path_Ind + '\$(DATABASE_NAME_DW)_' + @table + '_' + convert(nvarchar, @s) + '_' + convert(nvarchar, @month) + '_ind.ndf'',
     SIZE = 1024KB,
     MAXSIZE = UNLIMITED,
     FILEGROWTH = 10240KB
    ) TO FILEGROUP [fg' + @table + '_' + convert(nvarchar, @s) + '_' + convert(nvarchar, @month) + '_ind];'
   Execute(@sql);

   set @month = @month  + 1;
  End; /* loop @month */
  
  set @s = @s  + 1;
 End; /* loop @s */
 
 set @t = @t  + 1;
End; /* loop @t */
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
