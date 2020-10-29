/* ========================================================================== 
Proyecto: DemandaBI
Empresa:  
Desarrollador: Hugo Gonzalez Olaya 
Fecha: 2020-07-15
Fecha actualizacion: 2020-07-15
========================================================================== */ 

/* ========================================================================== 
VARIABLES PARA INSTALAR:
$(DATABASE_OPERATORMAILBOX): Buzón de correo para recibir notificaciones. Ejemplo: MiUsuario1@MiDominio.com.co;MiUsuario2@MiDominio.com.co
========================================================================== */

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - Start script: D03Operator.sql'
PRINT '------------------------------------------------------------------------'
GO

/* ========================================================================== 
 CREAR OPERADOR
 ========================================================================== */
USE [msdb];
IF NOT EXISTS (SELECT name FROM [msdb].[dbo].[sysoperators] WHERE name = N'OperatorDemandaDW')
EXEC [msdb].[dbo].[sp_add_operator] @name=N'OperatorDemandaDW', 
 	 @enabled=1, 
	 @email_address=N'$(DATABASE_OPERATORMAILBOX)'; 
GO

/* Actualizar cuenta de correo */
--EXEC [msdb].[dbo].[sp_update_operator] @name = N'OperatorDemandaDW',  @email_address = N'$(DATABASE_OPERATORMAILBOX)';

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - End script: D03Operator.sql'
PRINT '------------------------------------------------------------------------'
GO