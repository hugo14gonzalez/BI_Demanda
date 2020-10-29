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

$(DATABASE_OWNER): Propietario de la base de datos.
 Usualmente es el usuario SQL: SA, de lo contario utilice la cuenta tecnica de red para administar servicios SQL. 
 Ejemplo: SA, MiDominio\MiUsuarioAdminSQL
========================================================================== */

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - Start script: A04BrokerCLR.sql'
PRINT '------------------------------------------------------------------------'
GO

/* ========================================================================== 
Habilitar CLR, a nivel de servidor
========================================================================== */
USE [master];
IF  EXISTS (SELECT * FROM sys.configurations WHERE name = N'clr enabled' AND value_in_use = 0)
BEGIN
 EXECUTE sys.sp_configure @configname = 'clr enabled', @configvalue = 1;         
 RECONFIGURE;
END;
GO

/* ========================================================================== 
Habilitar Service Broker y trustworthy, a nivel de base de datos
========================================================================== */
USE [master];

IF EXISTS (SELECT * FROM sys.databases WHERE name = '$(DATABASE_NAME_DW)')
BEGIN
 IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = '$(DATABASE_NAME_DW)' AND is_trustworthy_on = 0)
 BEGIN
  ALTER DATABASE [$(DATABASE_NAME_DW)] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
  ALTER DATABASE [$(DATABASE_NAME_DW)] SET TRUSTWORTHY ON WITH ROLLBACK AFTER 20 SECONDS;
  ALTER DATABASE [$(DATABASE_NAME_DW)] SET MULTI_USER;
 END
END;
GO

IF EXISTS (SELECT * FROM sys.databases WHERE name = '$(DATABASE_NAME_DW)')
BEGIN
 IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = '$(DATABASE_NAME_DW)' AND is_broker_enabled = 0)
 BEGIN
  ALTER DATABASE [$(DATABASE_NAME_DW)] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

  BEGIN TRY
   ALTER DATABASE [$(DATABASE_NAME_DW)] SET ENABLE_BROKER WITH ROLLBACK AFTER 20 SECONDS;
  END TRY
  BEGIN CATCH
   ALTER DATABASE [$(DATABASE_NAME_DW)] SET NEW_BROKER WITH ROLLBACK AFTER 20 SECONDS;
  END CATCH

  ALTER DATABASE [$(DATABASE_NAME_DW)] SET MULTI_USER;
 END
END
GO

/* ========================================================
Cuando restaura una base de datos puede no funcionar objetos como CLR o Service Broker, por el owner de la base de datos.
En este caso es necesario cambiarlo por el usuario SA o una cuenta tecnica (cuenta de dominio).
======================================================== */
ALTER AUTHORIZATION ON DATABASE::[$(DATABASE_NAME_DW)] TO [$(DATABASE_OWNER)];
GO

/* ========================================================================== 
Validar que la base de datos tiene habilitado Service Broker y trustworthy
========================================================================== */
SELECT database_id, name, user_access_desc, is_broker_enabled, is_trustworthy_on 
FROM sys.databases 
WHERE name = N'$(DATABASE_NAME_DW)' and is_trustworthy_on = 1 and is_broker_enabled = 1;
IF (@@ROWCOUNT = 0)
BEGIN
 Print 'No habilitado service broker ni trustworthy. Es posible que la base de datos no este en simple uso';
END;
GO

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - End script: A04BrokerCLR.sql'
PRINT '------------------------------------------------------------------------'
GO