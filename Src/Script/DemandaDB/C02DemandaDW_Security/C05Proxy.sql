/* ========================================================================== 
Proyecto: DemandaBI
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya 
Fecha: 2020-07-15
Fecha actualizacion: 2020-07-15
========================================================================== */ 

/* ========================================================================== 
VARIABLES PARA INSTALAR:
$(DATABASE_PROXYWINDOWSUSER): Usuario de Windows usado para crear cuenta proxy. Ejemplo: MiDominio\MiUsuario
$(DATABASE_PROXYPASSWORD): Contraseña del usuario de Windows usado para crear cuenta proxy.
========================================================================== */

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - Start script: C05Proxy.sql'
PRINT '------------------------------------------------------------------------'
GO

/* ========================================================================== 
 1. CREAR CREDENCIALES
 ========================================================================== */
-- Credenciales permiten mapear logines SQL Server a cuentas Windows, para tener acceso a recursos fuera del alcance
-- de SQL Server como: servidores vinculados, archivos, ensamblados con permisos EXTERNAL_ACCESS

USE [master];
IF NOT EXISTS (SELECT 1 FROM sys.credentials WHERE name = N'CreDemandaDW') 
BEGIN 
 CREATE CREDENTIAL [CreDemandaDW] WITH IDENTITY = '$(DATABASE_PROXYWINDOWSUSER)', secret = '$(DATABASE_PROXYPASSWORD)';
END
GO

-- Modificar Password de credenciales
--ALTER CREDENTIAL [CreDemandaDW] WITH IDENTITY = N'$(DATABASE_PROXYWINDOWSUSER)', SECRET = N'$(DATABASE_PROXYPASSWORD)';

/* ========================================================================== 
 2. CREAR CUENTA PROXY
 ========================================================================== */
USE [msdb];
IF NOT EXISTS (SELECT 1 FROM msdb.dbo.sysproxies WHERE name = N'PrxDemandaDW') 
BEGIN 
 Execute msdb.dbo.sp_add_proxy 
         @proxy_name='PrxDemandaDW', 
         @credential_name='CreDemandaDW', 
         @enabled = 1,
         @description=N'Proxy para ejecución de procesos como jobs';
END 
GO

-- Modificar proxy
--EXEC msdb.dbo.sp_update_proxy @proxy_name = N'PrxDemandaDW', @enabled = 1 --@enabled = 0 

-- Lista de subsistemas
-- EXEC msdb.dbo.sp_enum_sqlagent_subsystems 

/* ========================================================================== 
 3. ASOCIAR PROXY CON SUBSISTEMA
 ========================================================================== */
IF NOT EXISTS(SELECT * FROM [msdb].[dbo].[sysproxysubsystem] PS 
              INNER JOIN msdb.dbo.sysproxies P ON PS.[proxy_id] = P.[proxy_id]
              INNER JOIN msdb.dbo.syssubsystems S ON PS.[subsystem_id] = S.[subsystem_id]
              WHERE P.[Name] = 'PrxDemandaDW' AND S.[subsystem] = 'SSIS')
Execute msdb.dbo.sp_grant_proxy_to_subsystem @proxy_name='PrxDemandaDW', @subsystem_name='SSIS';
GO

IF NOT EXISTS(SELECT * FROM [msdb].[dbo].[sysproxysubsystem] PS 
              INNER JOIN msdb.dbo.sysproxies P ON PS.[proxy_id] = P.[proxy_id]
              INNER JOIN msdb.dbo.syssubsystems S ON PS.[subsystem_id] = S.[subsystem_id]
              WHERE P.[Name] = 'PrxDemandaDW' AND S.[subsystem] = 'CmdExec')
Execute msdb.dbo.sp_grant_proxy_to_subsystem @proxy_name='PrxDemandaDW', @subsystem_name='CmdExec';
GO

/* ========================================================================== 
 4. ADICIONAR LOGIN A CUENTA PROXY
 El login debe ser usuario de la BD: msdb y miembro del rol SQLAgentUserRole en la BD: msdb
 ========================================================================== */
USE [msdb];
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE sid = SUSER_SID(N'USR_DemandaDW'))
   AND EXISTS (SELECT * FROM sys.database_principals WHERE sid = SUSER_SID(N'USR_DemandaDW'))
 CREATE USER [USR_DemandaDW] FOR LOGIN [USR_DemandaDW] WITH DEFAULT_SCHEMA=[dbo]
GO

IF NOT EXISTS(SELECT 1 FROM sys.database_role_members AS S
              INNER JOIN sys.database_principals AS P1 ON S.role_principal_id = P1.principal_id AND P1.type = 'R'
              INNER JOIN sys.database_principals AS P2 ON S.member_principal_id = P2.principal_id AND P2.type IN ('S', 'U')
              WHERE P1.name = N'SQLAgentUserRole' AND P2.sid = SUSER_SID(N'USR_DemandaDW'))
 EXEC msdb.dbo.sp_addrolemember N'SQLAgentUserRole', N'USR_DemandaDW'
GO

IF NOT EXISTS(SELECT 1 FROM [msdb].[dbo].[sysproxylogin] PL
              INNER JOIN msdb.dbo.sysproxies P ON PL.[proxy_id] = P.[proxy_id]
              INNER JOIN master.dbo.syslogins L ON L.[sid] = PL.[sid]
              WHERE P.[Name] = 'PrxDemandaDW' AND L.[Name] = 'USR_DemandaDW')
Execute msdb.dbo.sp_grant_login_to_proxy @login_name='USR_DemandaDW', @proxy_name='PrxDemandaDW';
GO

-- Ver logines con acceso al proxy
-- EXEC msdb.dbo.sp_enum_login_for_proxy 

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - End script: C05Proxy.sql'
PRINT '------------------------------------------------------------------------'
GO