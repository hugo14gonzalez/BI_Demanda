/* ========================================================================== 
Proyecto: DemandaBI
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya 
Fecha: 2020-07-15
Fecha actualizacion: 2020-07-15
========================================================================== */ 

/* ========================================================================== 
VARIABLES PARA INSTALAR:
$(SSISDB_FOLDER): Carpeta de despliegue de paquetes en el catálogo SSISDB. Ejemplo: Demanda
========================================================================== */

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - Start script: A01SSIS_Folder.sql'
PRINT '------------------------------------------------------------------------'
GO

/* ====================================================================================
 CREAR FOLDER 
==================================================================================== */
USE [SSISDB];
DECLARE @folder sysname, @folder_id bigint, @folder_description nvarchar(1024), @returnCode int = 0;

 SET @folder = '$(SSISDB_FOLDER)';
 SET @folder_description = 'Carga data Warehouse DemandaDW.';


BEGIN TRANSACTION;
 IF NOT EXISTS (SELECT 1 FROM [SSISDB].[catalog].[folders] WHERE [name] = @folder)
 BEGIN
  RAISERROR('Creando folder: %s', 10, 1, @folder) WITH NOWAIT;
  EXEC @returnCode = [SSISDB].[catalog].[create_folder] @folder_name = @folder, @folder_id = @folder_id OUTPUT;
  IF (@@ERROR <> 0 OR @returnCode <> 0) GOTO QuitWithRollback;
  EXEC @returnCode = [SSISDB].[catalog].[set_folder_description] @folder_name= @folder, @folder_description = @folder_description;
  IF (@@ERROR <> 0 OR @returnCode <> 0) GOTO QuitWithRollback;
 END;

COMMIT TRANSACTION;
RAISERROR(N'Terminado en forma satisfactoria SSISDB creacion de folder!', 10, 1) WITH NOWAIT;
GOTO EndSave;

QuitWithRollback:
IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION;
RAISERROR(N'Error SSISDB creacion de folder', 16, 1) WITH NOWAIT;

EndSave:
GO

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - End script: A01SSIS_Folder.sql'
PRINT '------------------------------------------------------------------------'
GO