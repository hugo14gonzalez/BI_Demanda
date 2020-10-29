/* ========================================================================== 
Proyecto: DemandaBI
Empresa:  
Desarrollador: Hugo Gonzalez Olaya 
Fecha: 2020-07-15
Fecha actualizacion: 2020-07-15
========================================================================== */ 

/* ========================================================================== 
VARIABLES PARA INSTALAR:
$(DATABASE_MAILPROFILENAME): Nombre de perfil de correo, recomendado nombre de instancia SQL Server. Ejemplo: NotificacionesSQL, MISERVIDOR\SQL2019
$(DATABASE_MAILBOX): Buzón de correo para configurar servicio mail. Ejemplo: MiUsuario1@MiDominio.com.co;MiUsuario2@MiDominio.com.co
$(DATABASE_MAILIP): Dirección IP del servidor de correo. Ejemplo: 172.10.1.2
========================================================================== */

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - Start script: D02Mail.sql'
PRINT '------------------------------------------------------------------------'
GO

/* ========================================================================== 
 1. HABILITAR NOTIFICACIONES EN SERVER AGENT
 ========================================================================== */
-- Después de ejecutar suba y baje los servicio del Server Agent
USE [msdb];
EXEC msdb.[dbo].sp_set_sqlagent_properties @email_save_in_sent_folder=1
GO
EXEC master.[dbo].xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent', N'UseDatabaseMail', N'REG_DWORD', 1
GO
EXEC master.[dbo].xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent', N'DatabaseMailProfile', N'REG_SZ', N'$(DATABASE_MAILPROFILENAME)'
GO

/* ========================================================================== 
 2. HABILITAR DATABASE MAIL
 ========================================================================== */
use [msdb]
GO
sp_CONFIGURE 'show advanced', 1
GO
RECONFIGURE
GO
sp_CONFIGURE 'Database Mail XPs', 1
GO
RECONFIGURE
GO 
sp_CONFIGURE 'show advanced', 0
GO
RECONFIGURE
GO

/* ========================================================================== 
 3. CREAR PERFIL DE CORREO
 ========================================================================== */
use [msdb]
GO
declare @profile_id smallint
If not exists(Select * from msdb.[dbo].sysmail_profile where name = '$(DATABASE_MAILPROFILENAME)')
Begin
 exec msdb.[dbo].sysmail_add_profile_sp
  @profile_name = '$(DATABASE_MAILPROFILENAME)',
  @description = 'Perfil de correo: $(DATABASE_MAILPROFILENAME)',
  @profile_id = @profile_id output;
End
GO

-- Lista de periles de correo
-- select * from msdb.[dbo].sysmail_profile

/* ========================================================================== 
 4. CREAR CUENTA DE CORREO
 ========================================================================== */
declare @account_id int
If not exists(select * from sysmail_account where name = '$(DATABASE_MAILPROFILENAME)')
Begin
 execute msdb.[dbo].sysmail_add_account_sp
  @account_name='$(DATABASE_MAILPROFILENAME)',
  @description='Cuenta de correo: $(DATABASE_MAILPROFILENAME)',
  @email_address='$(DATABASE_MAILBOX)',
  @display_name='$(DATABASE_MAILPROFILENAME)',
  @mailserver_name='$(DATABASE_MAILIP)',
  @mailserver_type='SMTP',
  @port=25,
  @username=null,
  @password=null,
  @use_default_credentials=1,
  @enable_ssl=0,
  @account_id=@account_id output;
End
GO
-- Lista de cuentas de correo
-- select * from sysmail_account 

/* Para actualizar la cuenta de correo
declare @account_id int
execute msdb.[dbo].sysmail_update_account_sp
 @account_id=1,
 @account_name='$(DATABASE_MAILPROFILENAME)',
 @email_address='$(DATABASE_MAILBOX)',
 @display_name='$(DATABASE_MAILPROFILENAME)',
 @description='Cuenta $(DATABASE_MAILPROFILENAME)',
 @mailserver_name='$(DATABASE_MAILIP)',
 @mailserver_type='SMTP',
 @port=25,
 @username=null,
 @password=null,
 @use_default_credentials=1,
 @enable_ssl=0;
*/

/* ========================================================================== 
 5. ADICIONAR CUENTA DE CORREO AL PERFIL, CON PRIORIDAD 1
 ========================================================================== */
IF NOT EXISTS(SELECT * FROM msdb.dbo.sysmail_profileaccount pa 
              JOIN msdb.dbo.sysmail_profile p ON pa.profile_id = p.profile_id  
              JOIN msdb.dbo.sysmail_account a ON pa.account_id = a.account_id  
              WHERE p.name = '$(DATABASE_MAILPROFILENAME)' AND a.name = '$(DATABASE_MAILPROFILENAME)')  
BEGIN 
exec msdb.[dbo].sysmail_add_profileaccount_sp
 @profile_name = '$(DATABASE_MAILPROFILENAME)',
 @account_name = '$(DATABASE_MAILPROFILENAME)',
 @sequence_number=1;
END 

-- Lista de cuentas de un perfil
-- exec msdb.[dbo].sysmail_help_profileaccount_sp

/* ========================================================================== 
 6. HACER EL PERFIL PUBLICO, ESTABLECER COMO EL PERFIL POR DEFECTO 
 ========================================================================== */
IF NOT EXISTS(SELECT * FROM msdb.dbo.sysmail_principalprofile pp 
              JOIN msdb.dbo.sysmail_profile p ON pp.profile_id = p.profile_id  
              WHERE p.name = '$(DATABASE_MAILPROFILENAME)')  
BEGIN 
exec msdb.[dbo].sysmail_add_principalprofile_sp
 @profile_name = '$(DATABASE_MAILPROFILENAME)',
 @is_default = 1,
 @principal_name = 'public';
END
GO

-- Consultar perfil por defecto
--select * from msdb.dbo.sysmail_principalprofile 

/* ========================================================================== 
 7. TEST ENVIO DE CORREO
 ========================================================================== */
EXEC msdb.[dbo].sp_send_dbmail -- @profile_name='$(DATABASE_MAILPROFILENAME)',
 @recipients='$(DATABASE_MAILBOX)',
 @subject='Prueba mail SQL Server',
 @body='¡Este es un mensaje de prueba de configuración de data mail SQL Server, ignorelo!' 

/* ========================================================================== 
 8. REVISIÓN DE CORREO
 ========================================================================== */
/*
-- Revisar State de correos enviados
SELECT * FROM sysmail_allitems

-- Revisar el State de Database Mail 
SELECT * FROM msdb.dbo.sysmail_server  
SELECT * FROM msdb.dbo.sysmail_servertype  
SELECT * FROM msdb.dbo.sysmail_configuration  

--Email Sent Status  
SELECT * FROM msdb.dbo.sysmail_allitems  
SELECT * FROM msdb.dbo.sysmail_sentitems  
SELECT * FROM msdb.dbo.sysmail_unsentitems  
SELECT * FROM msdb.dbo.sysmail_faileditems  

--Email Status  
SELECT SUBSTRING(fail.subject,1,25) AS 'Subject',  fail.mailitem_id,  LOG.description  
FROM msdb.dbo.sysmail_event_log LOG  
join msdb.dbo.sysmail_faileditems fail  ON fail.mailitem_id = LOG.mailitem_id  
WHERE event_type = 'error' 

--Mail Queues  
EXEC msdb.dbo.sysmail_help_queue_sp  

--DB Mail Status  
EXEC msdb.dbo.sysmail_help_status_sp 

-- Si el servicio está detenido
--EXECUTE msdb.[dbo].sysmail_start_sp;
*/

/* ========================================================================== 
 BORRAR PERFILES DE CORREO
 ========================================================================== */
--IF EXISTS(SELECT * FROM msdb.dbo.sysmail_profileaccount pa  
--          JOIN msdb.dbo.sysmail_profile p ON pa.profile_id = p.profile_id  
--          JOIN msdb.dbo.sysmail_account a ON pa.account_id = a.account_id  
--          WHERE p.name = '$(DATABASE_MAILPROFILENAME)' AND a.name = '$(DATABASE_MAILPROFILENAME)')  
--BEGIN 
-- EXECUTE msdb.[dbo].sysmail_delete_profileaccount_sp  @profile_name = '$(DATABASE_MAILPROFILENAME)',  @account_name = '$(DATABASE_MAILPROFILENAME)'  
--END 

--IF EXISTS(SELECT * FROM msdb.dbo.sysmail_profile p  WHERE p.name = '$(DATABASE_MAILPROFILENAME)')  
--BEGIN 
-- EXECUTE msdb.[dbo].sysmail_delete_profile_sp  @profile_name = '$(DATABASE_MAILPROFILENAME)'  
--END 

--IF EXISTS(SELECT * FROM msdb.dbo.sysmail_account a  WHERE a.name = '$(DATABASE_MAILPROFILENAME)')  
--BEGIN 
-- EXECUTE msdb.[dbo].sysmail_delete_account_sp  @account_name = '$(DATABASE_MAILPROFILENAME)'  
--END 

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - End script: D02Mail.sql'
PRINT '------------------------------------------------------------------------'
GO