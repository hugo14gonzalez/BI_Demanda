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
$(DATABASE_SERVERNAME_SSIS): Nombre de la instancia del servidor SQL Server donde está el catalogo SSIS. Ejemplo: MISERVIDOR\SQL2019
$(SSISDB_FOLDER): Carpeta de despliegue de paquetes (ETLs) en el catalogo SSISDB. Ejemplo: Demanda
$(SSISDB_PROJECT): Nombre de proyecto que contiene los paquetes (ETLs). Ejemplo: DemandaBI_SSIS
$(SSISDB_ENVIRONMENT): Ambiente de despliegue, en el cual configurar variables de paquetes (ETLs). Ejemplo: Produccion, Pruebas, Desarrollo.
$(DATABASE_PROXYWINDOWSUSER): Usuario de Windows usado para crear cuenta proxy. Ejemplo: MiDominio\MiUsuario
========================================================================== */

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - Start script: D04Jobs.sql'
PRINT '------------------------------------------------------------------------'
GO

/*
SELECT E.[environment_id]
FROM [SSISDB].[catalog].[environments] E 
INNER JOIN  [SSISDB].[catalog].[folders] F ON E.[folder_id] = F.[folder_id]
WHERE F.[name] = 'Demanda' AND E.[name] = 'Produccion';
*/

/* ========================================================================== 
JOB: JobDemandaBI_CargaDiaria
========================================================================== */
RAISERROR(N'Creando job: JobDemandaBI_CargaDiaria ...', 0, 0) WITH NOWAIT;

USE [msdb];
GO

IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'JobDemandaBI_CargaDiaria')
begin
 Print 'Ya existe el job: JobDemandaBI_CargaDiaria, debe borrar el job antes de ejecutar !!'
 GOTO EndSave;
end;

/*
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'JobDemandaBI_CargaDiaria')
begin
 EXEC msdb.dbo.sp_delete_job @job_name= N'JobDemandaBI_CargaDiaria', @delete_unused_schedule=1;
end;
*/

DECLARE @folder sysname, @environment sysname, @project sysname, @instanceName sysname, @port nvarchar(10), @fullInstanceName sysname;
DECLARE @environment_id bigint, @cmdStep1 nvarchar(4000), @serverName sysname;
DECLARE @userOwner sysname, @operatorName sysname, @prxName sysname;

SET @serverName = '$(DATABASE_SERVERNAME_SSIS)';
SET @folder = '$(SSISDB_FOLDER)';
SET @environment = '$(SSISDB_ENVIRONMENT)';
SET @project = '$(SSISDB_PROJECT)';
SET @userOwner = '$(DATABASE_PROXYWINDOWSUSER)';
SET @prxName = 'PrxDemandaDW';
SET @operatorName = 'OperatorDemandaDW';

SELECT @environment_id = E.[environment_id]
FROM [SSISDB].[catalog].[environments] E 
INNER JOIN  [SSISDB].[catalog].[folders] F ON E.[folder_id] = F.[folder_id]
WHERE F.[name] = @folder AND E.[name] = @environment;

SELECT @instanceName = @@SERVERNAME;
SELECT @port = Convert(nvarchar(10), local_tcp_port) FROM sys.dm_exec_connections WHERE session_id = @@SPID;

if (@port IS NOT NULL AND @port NOT IN ('1433', '1605') )
begin
 set @fullInstanceName = @instanceName + ',' + @port;
end
else
begin
 set @fullInstanceName = @instanceName;
end;

if (@serverName IS NULL OR @serverName = '')
begin
 set @serverName = @fullInstanceName;
end;

if (@environment_id IS NULL) 
begin
 set @cmdStep1 = N'/ISSERVER "\"\SSISDB\' + @folder + '\' + @project + '\pkgFull.dtsx\"" /SERVER "\"' + @serverName 
	 + '\"" /Par "\"$ServerOption::LOGGING_LEVEL(Int16)\"";1 /Par "\"$ServerOption::SYNCHRONIZED(Boolean)\"";True /CALLERINFO SQLAGENT /REPORTING E';
end
else
begin
 set @cmdStep1 = N'/ISSERVER "\"\SSISDB\' + @folder + '\' + @project + '\pkgFull.dtsx\"" /SERVER "\"' + @serverName + '\"" /ENVREFERENCE '
  + Convert(varchar, @environment_id) + ' /Par "\"$ServerOption::LOGGING_LEVEL(Int16)\"";1 /Par "\"$ServerOption::SYNCHRONIZED(Boolean)\"";True /CALLERINFO SQLAGENT /REPORTING E';
end;

BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
select @jobId = job_id from msdb.dbo.sysjobs where (name = N'JobDemandaBI_CargaDiaria')
if (@jobId is NULL)
BEGIN
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'JobDemandaBI_CargaDiaria', 
		@enabled=0, 
		@notify_level_eventlog=2, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Ejecuta ETL: pkgFull.dtsx, para procesar todas los paquetes del DW del sistema DemandaBI', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name = @userOwner, 
		@notify_email_operator_name = @operatorName, @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

IF NOT EXISTS (SELECT * FROM msdb.dbo.sysjobsteps WHERE job_id = @jobId and step_id = 1)
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'ValidarEstadoNodo', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'BEGIN TRY  
 IF (sys.fn_hadr_is_primary_replica(''$(DATABASE_NAME_DW)'') = 1 OR sys.fn_hadr_is_primary_replica(''$(DATABASE_NAME_DW)'') IS NULL)
 BEGIN
  PRINT ''PrimaryRole.Continue'';
 END
 ELSE
 BEGIN
  RAISERROR (''Ejecución en nodo Secundario'', 16, 1);
 END; 
END TRY  
BEGIN CATCH  
 PRINT ERROR_MESSAGE();
 PRINT ''El proceso continua sin validar si es nodo primario'';  
END CATCH;', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
IF NOT EXISTS (SELECT * FROM msdb.dbo.sysjobsteps WHERE job_id = @jobId and step_id = 2)
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'pkgFull.dtsx', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command = @cmdStep1, 
		@database_name=N'master', 
		@flags=32, 
		@proxy_name = @prxName
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Diario 3:00 am.', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20160511, 
		@active_end_date=99991231, 
		@active_start_time=30000, 
		@active_end_time=235959 
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - End script: D04Jobs.sql'
PRINT '------------------------------------------------------------------------'
GO