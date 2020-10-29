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
$(DATABASE_USR_DEMANDADW_PASSWORD_DW): Contraseña para el usuario: USR_DemandaDW. Ejemplo: USR_DemandaDW00*
========================================================================== */

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - Start script: C01Login.sql'
PRINT '------------------------------------------------------------------------'
GO

/* ========================================================================== 
 LOGINES
 ========================================================================== */
if not exists (select * from master.sys.server_principals where sid = SUSER_SID(N'USR_DemandaDW'))
BEGIN
 declare @logindb nvarchar(132), @sql nvarchar(2000) 
 select @logindb = N'$(DATABASE_NAME_DW)'
 if (@logindb IS NULL OR LTrim(@logindb) = '') OR NOT EXISTS (select * from master.dbo.sysdatabases where name = @logindb)
	select @logindb = N'master'
 set @sql = 'CREATE LOGIN [USR_DemandaDW] WITH PASSWORD=N''$(DATABASE_USR_DEMANDADW_PASSWORD_DW)'', DEFAULT_DATABASE = ' + @logindb + ', CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF'
 EXECUTE(@sql);
END
GO

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - End script: C01Login.sql'
PRINT '------------------------------------------------------------------------'
GO