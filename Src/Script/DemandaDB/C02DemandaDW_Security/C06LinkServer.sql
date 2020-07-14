/* ========================================================================== 
Proyecto: DemandaBI
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya 
Fecha: 2020-07-15
Fecha actualizacion: 2020-07-15
========================================================================== */ 

/* ========================================================================== 
VARIABLES PARA INSTALAR:
$(LINKSERVER_NAME_Demanda_OLAP): Nombre del servidor vinculado a la base de datos SQL Server Analysis Services. Ejemplo: Demanda_OLAP
$(DATABASEOLAP_SERVERNAME_Demanda_OLAP): Nombre de la instancia del servidor SQL Server Analysis Services. Ejemplo: MISERVIDOR\SQL2019
$(DATABASEOLAP_NAME_DEMANDA_OLAP): Nombre de la base de datos SQL Server Analysis Services. Ejemplo: Demanda_OLAP
$(DATABASE_PROXYWINDOWSUSER): Usuario de Windows usado para crear cuenta proxy. Ejemplo: MiDominio\MiUsuario
$(DATABASE_PROXYPASSWORD): Contraseña del usuario de Windows usado para crear cuenta proxy.
========================================================================== */

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - Start script: C06LinkServer.sql'
PRINT '------------------------------------------------------------------------'
GO

/* ========================================================================== 
SERVIDOR VINCULADO A LOS CUBOS
========================================================================== */
USE [master]
GO
IF  EXISTS (SELECT srv.name FROM sys.servers srv WHERE srv.server_id != 0 AND srv.name = N'$(LINKSERVER_NAME_Demanda_OLAP)')
 EXEC master.dbo.sp_dropserver @server=N'$(LINKSERVER_NAME_Demanda_OLAP)', @droplogins='droplogins';
GO

EXEC master.dbo.sp_addlinkedserver @server = N'$(LINKSERVER_NAME_Demanda_OLAP)', @srvproduct=N'MSOLAP', @provider=N'MSOLAP', 
 @datasrc=N'$(DATABASEOLAP_SERVERNAME_Demanda_OLAP)', @catalog=N'$(DATABASEOLAP_NAME_DEMANDA_OLAP)';
GO

EXEC master.dbo.sp_serveroption @server=N'$(LINKSERVER_NAME_Demanda_OLAP)', @optname=N'collation compatible', @optvalue=N'false'
GO
EXEC master.dbo.sp_serveroption @server=N'$(LINKSERVER_NAME_Demanda_OLAP)', @optname=N'data access', @optvalue=N'true'
GO
EXEC master.dbo.sp_serveroption @server=N'$(LINKSERVER_NAME_Demanda_OLAP)', @optname=N'dist', @optvalue=N'false'
GO
EXEC master.dbo.sp_serveroption @server=N'$(LINKSERVER_NAME_Demanda_OLAP)', @optname=N'pub', @optvalue=N'false'
GO
EXEC master.dbo.sp_serveroption @server=N'$(LINKSERVER_NAME_Demanda_OLAP)', @optname=N'rpc', @optvalue=N'true'
GO
EXEC master.dbo.sp_serveroption @server=N'$(LINKSERVER_NAME_Demanda_OLAP)', @optname=N'rpc out', @optvalue=N'true'
GO
EXEC master.dbo.sp_serveroption @server=N'$(LINKSERVER_NAME_Demanda_OLAP)', @optname=N'sub', @optvalue=N'false'
GO
EXEC master.dbo.sp_serveroption @server=N'$(LINKSERVER_NAME_Demanda_OLAP)', @optname=N'connect timeout', @optvalue=N'0'
GO
EXEC master.dbo.sp_serveroption @server=N'$(LINKSERVER_NAME_Demanda_OLAP)', @optname=N'collation name', @optvalue=null
GO
EXEC master.dbo.sp_serveroption @server=N'$(LINKSERVER_NAME_Demanda_OLAP)', @optname=N'lazy schema validation', @optvalue=N'false'
GO
EXEC master.dbo.sp_serveroption @server=N'$(LINKSERVER_NAME_Demanda_OLAP)', @optname=N'query timeout', @optvalue=N'0'
GO
EXEC master.dbo.sp_serveroption @server=N'$(LINKSERVER_NAME_Demanda_OLAP)', @optname=N'use remote collation', @optvalue=N'true'
GO
EXEC master.dbo.sp_serveroption @server=N'$(LINKSERVER_NAME_Demanda_OLAP)', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO
USE [master]
GO
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'$(LINKSERVER_NAME_Demanda_OLAP)', @locallogin=NULL, @useself=N'False',
 @rmtuser=N'$(DATABASE_PROXYWINDOWSUSER)', @rmtpassword='$(DATABASE_PROXYPASSWORD)';
GO

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - End script: C06LinkServer.sql'
PRINT '------------------------------------------------------------------------'
GO