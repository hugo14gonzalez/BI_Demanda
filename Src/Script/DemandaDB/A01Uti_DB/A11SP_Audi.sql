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
========================================================================== */

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - Start script: A11SP_Audi.sql'
PRINT '------------------------------------------------------------------------'
GO

USE [$(DATABASE_NAME_DW)];

/* ========================================================================== 
PROCEDIMIENTOS PARA AUDITORIA DE PROCESOS
========================================================================== */
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Audit].[spBitacora_Cancel]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_EXECUTEsql @statement = N'CREATE PROCEDURE [Audit].[spBitacora_Cancel] AS' 
END
GO
ALTER procedure [Audit].[spBitacora_Cancel]
  @bitacoraId bigint,
  @message nvarchar(max) = NULL
as
/* ============================================================================================
Proposito: Actualiza la tabla de auditoria de bitacora indicando que fue cancelado.
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2015-04-01
Fecha actualizacion: 2020-07-15

Parametros:
 @bitacoraId: Código de bitacora.
 @message: Mensaje opcional

Ejemplo:
 EXECUTE [Audit].[spBitacora_Cancel] 1;

 SELECT E.[StateId], E.[Name], B.* 
 FROM [Audit].[Bitacora] B INNER JOIN [Audit].[BitacoraState] E ON B.[StateId] = E.[StateId]
 WHERE B.BitacoraId = 1;
============================================================================================ */
begin
 set nocount on
  
 set @message = Coalesce(@message, 'Cancelado.')
 update [Audit].[Bitacora] set
  [DateEnd] = Getdate()
  ,[StateId] = 3 /* Cancelado */
  ,[Message] = Case When [Message] IS NULL OR [Message] = '' Then @message Else 
     Case When @message IS NULL OR @message = '' then [Message] Else @message + ' ' + [Message] end end
 where [BitacoraId] = @bitacoraId;
end
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Audit].[spBitacora_Error]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_EXECUTEsql @statement = N'CREATE PROCEDURE [Audit].[spBitacora_Error] AS' 
END
GO
ALTER procedure [Audit].[spBitacora_Error]
 @bitacoraId int
 ,@FailureTask nvarchar(128) = NULL
 ,@message nvarchar(max) = NULL
as
/* ============================================================================================
Proposito: Registra un error en la tabla de auditoria de bitacora.
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2015-04-01
Fecha actualizacion: 2020-07-15

Parametros:
 @bitacoraId: Código de ejecucion de proceso
 @FailureTask: Tarea en la cual se presentó el error
 @message: Mensaje de error
 
 Ejemplo:
 EXECUTE [Audit].[spBitacora_Error] 2, 'Tarea fallo prueba', 'Mensaje error prueba';
 EXECUTE [Audit].[spBitacora_Error] 2, 'Tarea fallo prueba 2', 'Mensaje error prueba';

 SELECT E.[StateId], E.[Name], B.* 
 FROM [Audit].[Bitacora] B INNER JOIN [Audit].[BitacoraState] E ON B.[StateId] = E.[StateId]
 WHERE [BitacoraId] = 2;
============================================================================================ */
begin
 declare @messagePrevious nvarchar(max); 
 
 if exists(Select * From [Audit].[Bitacora] Where [BitacoraId] = @bitacoraId)
 Begin
  -- Mensaje anterior
  select @messagePrevious = [Message] From [Audit].[Bitacora] where [BitacoraId] = @bitacoraId;
  set @messagePrevious = Coalesce(@messagePrevious, '');

  -- Si el mensaje ya fue adicionado ignorarlo
  if ( @message IS NOT NULL AND @message <> '' AND PATINDEX ('%' + @message + '%', @messagePrevious) > 0 )
  begin
   set @message = '';
  end; 
 
  update [Audit].[Bitacora] set 
   [DateEnd] = GetDate() 
   ,[StateId] = 1 /* 'Error' */
   ,[FailureTask] = @FailureTask
   ,[Message] = Case When [Message] IS NULL OR [Message] = '' Then @message Else 
     Case When @message IS NULL OR @message = '' then [Message] Else @message + ' ' + [Message] end end
  where [BitacoraId] = @bitacoraId;
 end;
end;
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Audit].[spBitacora_End]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_EXECUTEsql @statement = N'CREATE PROCEDURE [Audit].[spBitacora_End] AS' 
END
GO
ALTER procedure [Audit].[spBitacora_End]
  @bitacoraId bigint
 ,@StateId tinyint = 0
 ,@message nvarchar(max) = NULL
as
/* ============================================================================================
Proposito: Actualiza la tabla de auditoria de bitacora. 
 Si el estado es cancelado o error no actualiza este estado, de lo contrario utiliza el estado establecido, por defecto es 0: Exitoso.
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2015-04-01
Fecha actualizacion: 2020-07-15

Parametros:
 @bitacoraId: Código de bitacora.
 @StateId: Codigo de estado, es opcional, por defecto es igual a 0: Exitoso.
 @message: Mensaje opcional.
 
Ejemplo:
 EXECUTE [Audit].[spBitacora_End] 3;
 EXECUTE [Audit].[spBitacora_End] 4, 10, 'Publicado';

 SELECT E.[StateId], E.[Name], B.* 
 FROM [Audit].[Bitacora] B INNER JOIN [Audit].[BitacoraState] E ON B.[StateId] = E.[StateId]
 WHERE [BitacoraId] <= 5;
============================================================================================ */
begin
 declare @messagePrevious nvarchar(max); 
 
 if exists(Select * From [Audit].[Bitacora] Where [BitacoraId] = @bitacoraId)
 Begin
  -- Mensaje anterior
  select @messagePrevious = [Message] From [Audit].[Bitacora] where [BitacoraId] = @bitacoraId;
  set @messagePrevious = Coalesce(@messagePrevious, '');

  -- Si el mensaje ya fue adicionado ignorarlo
  if ( @message IS NOT NULL AND @message <> '' AND PATINDEX ('%' + @message + '%', @messagePrevious) > 0 )
  begin
   set @message = '';
  end; 

  update [Audit].[Bitacora] set
   [DateEnd] = GetDate()
   ,[StateId] = case when [StateId] IN (1, 3) then [StateId] else @StateId end  /* 1: Error, 3: Cancelado */    
   ,[Message] = Case When [Message] IS NULL OR [Message] = '' Then @message Else 
     Case When @message IS NULL OR @message = '' then [Message] Else @message + ' ' + [Message] end end
  where [BitacoraId] = @bitacoraId;
 end 
end
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Audit].[spBitacora_Start]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_EXECUTEsql @statement = N'CREATE PROCEDURE [Audit].[spBitacora_Start] AS' 
END
GO
ALTER procedure [Audit].[spBitacora_Start]
 @bitacoraId bigint OUTPUT
 ,@ParentId bigint = NULL 
 ,@appId nvarchar(12)
 ,@ModuleId int
 ,@name nvarchar(128)
 ,@DateWorkStart nvarchar(23) = NULL
 ,@DateWorkEnd nvarchar(23) = NULL
 ,@ProcessId bigint = NULL
 ,@ProcessStringId nvarchar(20) = NULL
 ,@userId int = NULL
 ,@MachineId nvarchar(100) = NULL
as
/* ============================================================================================
Proposito: Registra el evento incio de ejecucion en la tabla de auditoria de bitacora.
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2015-04-01
Fecha actualizacion: 2020-07-15

Parametros:
 @bitacoraId: Parámetro de retorno con el código de bitacora
 @ParentId: Código de bitacora de proceso padre (puede ser nulo).
 @appId: Código de aplicación.
 @ModuleId: Código de módulo.
 @name: Nombre de tarea (paquete, programa, etc.).
 @DateWorkStart: Fecha de trabajo o negocio inicio. Formato: YYYY-MM-DD ó YYYY-MM-DD HH:mm:ss ó YYYY-MM-DD HH:mm:ss.ttt.
 @DateWorkEnd: Fecha de trabajo o negocio fin. Formato: YYYY-MM-DD ó YYYY-MM-DD HH:mm:ss ó YYYY-MM-DD HH:mm:ss.ttt.
 @ProcessId: Código de proceso, por ejemplo el código de una carga de datos.
 @ProcessStringId: Código de proceso como texto, por ejemplo Guid de ejecucion de una ETL.
 @userId: Código del usuario que ejecuta el proceso.
 @MachineId: Computador desde el cual es ejecutado el proceso.

Codigos de estado:
0: Exitoso 
1, 'Error
2, 'Iniciado
3, 'Cancelado
 
Ejemplo:
declare @bitacoraId bigint, @f datetime;
set @f = GetDate();
EXECUTE [Audit].[spBitacora_Start] @bitacoraId OUTPUT, 1, 'NA', 1, 'Mi proceso', @f, NULL, 0, NULL, 0, 'ETL';
 
SELECT E.[StateId], E.[Name], B.* 
FROM [Audit].[Bitacora] B INNER JOIN [Audit].[BitacoraState] E ON B.[StateId] = E.[StateId]
WHERE B.[BitacoraId] = (SELECT Max(B2.[BitacoraId]) FROM [Audit].[Bitacora] B2);
============================================================================================ */
begin
 set nocount on
 Declare @dtDateWorkStart dateTime, @dtDateWorkEnd dateTime;

 BEGIN TRY
  if (@DateWorkStart IS NULL OR RTRIM(@DateWorkStart) = '')
  begin
   set @DateWorkStart = NULL;
  end
  else
  begin
   set @dtDateWorkStart = Convert(dateTime, @DateWorkStart, 120);
  end; 

  if (@DateWorkEnd IS NULL OR RTRIM(@DateWorkEnd) = '')
  begin
   set @DateWorkEnd = NULL;
  end
  else
  begin
   set @dtDateWorkEnd = Convert(dateTime, @DateWorkEnd, 120);
  end; 
 END TRY 
 BEGIN CATCH
  --No hacer nada en caso de fallo
 END CATCH  

 --Nivel raiz nodos pueden tener un padre nulo 
 if @ParentId <= 0
 begin
  set @ParentId = NULL;
 end;

 --Nivel raiz nodos no pueden tener una descripción nula
 if (@name IS NULL OR RTRIM(@name) = '')
 begin
  set @name = 'Bitacora';
 end; 

 INSERT INTO [Audit].[Bitacora] ([ParentId],[AppId],[ModuleId],[Name],[StateId],[DateStart],[DateEnd],[DateWorkStart],[DateWorkEnd]
  ,[ProcessId],[ProcessStringId],[UserId],[MachineId],[FailureTask],[Message])
 VALUES (@ParentId, @appId, @ModuleId, @name, 2 /* Iniciado */, GetDate(), NULL, @dtDateWorkStart, @dtDateWorkEnd
  ,@ProcessId, @ProcessStringId, @userId, @MachineId, NULL, NULL);

 set @bitacoraId = SCOPE_IDENTITY()
end 
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Audit].[spBitacoraFile_Cancel]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_EXECUTEsql @statement = N'CREATE PROCEDURE [Audit].[spBitacoraFile_Cancel] AS' 
END
GO
ALTER procedure [Audit].[spBitacoraFile_Cancel]
  @FileId bigint,
  @message nvarchar(4000) = NULL
as
/* ============================================================================================
Proposito: Actualiza la tabla de auditoria de bitacora de archivo indicando que fue cancelado.
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2015-04-01
Fecha actualizacion: 2020-07-15

Parametros:
 @FileId: Código del archivo
 @message: Mensaje opcional

Ejemplo:
EXECUTE [Audit].[spBitacoraFile_Cancel] 1;

SELECT E.[StateId], E.[Name], A.* 
From [Audit].[BitacoraFile] A INNER JOIN [Audit].[BitacoraState] E ON A.[StateId] = E.[StateId]
WHERE A.[BitacoraId] = (SELECT Max(B2.[BitacoraId]) FROM [Audit].[Bitacora] B2);

SELECT E.[StateId], E.[Name], A.* 
From [Audit].[BitacoraFile] A INNER JOIN [Audit].[BitacoraState] E ON A.[StateId] = E.[StateId]
WHERE A.[FileId] = 1; 
============================================================================================ */
begin
 set nocount on
  
 set @message = Coalesce(@message, 'Cancelado.')
 UPDATE [Audit].[BitacoraFile] set
  [DateEnd] = Getdate()
  ,[StateId] = 3 /* Cancelado */
  ,[Message] = Case When [Message] IS NULL OR [Message] = '' Then @message Else 
     Case When @message IS NULL OR @message = '' then [Message] Else @message + ' ' + [Message] end end
 WHERE [FileId] = @FileId;
end
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Audit].[spBitacoraFile_Error]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_EXECUTEsql @statement = N'CREATE PROCEDURE [Audit].[spBitacoraFile_Error] AS' 
END
GO
ALTER PROCEDURE [Audit].[spBitacoraFile_Error] 
 @FileId bigint OUTPUT
 ,@message nvarchar(4000) = NULL
 ,@StateId tinyint = 1 /* 1: Error */
 ,@bitacoraId bigint = NULL OUTPUT
 ,@DateWork nvarchar(23) = NULL
 ,@name nvarchar(400) = NULL
 ,@PathSource nvarchar(500) = NULL
 ,@PathTarget nvarchar(500) = NULL
 ,@PathWithoutProcessing nvarchar(500) = NULL
 ,@PathError nvarchar(500) = NULL
 ,@PathProcessed nvarchar(500) = NULL
 ,@PathProcessed2 nvarchar(500) = NULL
 ,@PathEncrypted nvarchar(500)= NULL
 ,@ProcessId bigint = NULL
As
/* ============================================================================================
Proposito: Actualiza en la tabla BitacoraFile el estado = Error.
 Los archivos son tomados de PathSource, pasan luego a PathTarget, si está cifrado pasa a PathEncrypted y el archivos descifrado pasa a PathWithoutProcessing, 
 si no esta cifrado pasa a PathWithoutProcessing, si el procesamiento es exitoso pasa a PathProcessed y opcionalmente a PathProcessed2, pero si falla pasa a PathError.
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2015-04-01
Fecha actualizacion: 2020-07-15

Parametros:  
 @FileId: Código del archivo.
 @message: Mensaje opcional.
 @StateId: Codigo de estado, es opcional, por defecto es igual a 1: Error.
 @bitacoraId: Código de bitacora.
 @DateWork: Fecha de trabajo o negocio. Formato: YYYY-MM-DD ó YYYY-MM-DD HH:mm:ss ó YYYY-MM-DD HH:mm:ss.ttt.
 @name: Nombre de archivo.
 @PathSource: Ruta origen del archivo en disco, donde el usuario toma el archivo.
 @PathTarget: Ruta destino del archivo en disco, donde descarga el archivo.
 @PathWithoutProcessing: Ruta sin procesar del archivo en disco, donde son tomados para ser procesados.
 @PathError: Ruta error del archivo en disco, donde dejar el archivo en caso de error.
 @PathProcessed: Ruta sin procesar del archivo en disco, donde son tomados para ser procesados.
 @PathProcessed2: Ruta 2 procesado del archivo en disco, donde dejar el archivo después de ser procesado (opcional por ejemplo como backup para auditoria).
 @FileId: Parámetro de retorno con el código de procesamiento del archivo
 @PathEncrypted: Ruta cifrado del archivo en disco.
 @ProcessId: Código de proceso, por ejemplo el código de una carga de datos.

Ejemplo:
EXECUTE [Audit].[spBitacoraFile_Error] 2, 'Error al procesar archivo.';

SELECT E.[StateId], E.[Name], A.* 
From [Audit].[BitacoraFile] A INNER JOIN [Audit].[BitacoraState] E ON A.[StateId] = E.[StateId]
WHERE A.[BitacoraId] = (SELECT Max(B2.[BitacoraId]) FROM [Audit].[Bitacora] B2);

SELECT E.[StateId], E.[Name], A.* 
From [Audit].[BitacoraFile] A INNER JOIN [Audit].[BitacoraState] E ON A.[StateId] = E.[StateId]
WHERE A.[FileId] = 2; 
============================================================================================ */
Begin
 declare @messagePrevious nvarchar(4000);  
 Declare @dtDateWork dateTime;
 
 BEGIN TRY
  if (@DateWork IS NULL OR RTRIM(@DateWork) = '')
  begin
   set @DateWork = NULL;
  end
  else
  begin
   set @dtDateWork = Convert(dateTime, @DateWork, 120);
  end; 
 END TRY 
 BEGIN CATCH
  --No hacer nada en caso de fallo
 END CATCH  

 if exists(Select * FROM [Audit].[BitacoraFile] WHERE [FileId] = @FileId)
 Begin
  -- Mensaje anterior
  select @messagePrevious = [Message] FROM [Audit].[BitacoraFile] WHERE [FileId] = @FileId;
  set @messagePrevious = Coalesce(@messagePrevious, '');

  -- Si el mensaje ya fue adicionado ignorarlo
  if ( @message IS NOT NULL AND @message <> '' AND PATINDEX ('%' + @message + '%', @messagePrevious) > 0 )
  begin
   set @message = '';
  end; 

  UPDATE [Audit].[BitacoraFile] set
   [DateEnd] = GetDate() 
   ,[StateId] = @StateId /* Error */
   ,[Message] = Convert(nvarchar(4000), Case When [Message] IS NULL OR [Message] = '' Then @message Else 
     Case When @message IS NULL OR @message = '' then [Message] Else @message + ' ' + [Message] end end)
  WHERE [FileId] = @FileId;
 end;
 else /* No existe registro inicial, por ejemplo cuando faltan datos o el nombre del archivo no existe en disco */
 begin
  if not exists(Select * From [Audit].[Bitacora] Where [BitacoraId] = @bitacoraId)
  Begin
   INSERT INTO [Audit].[Bitacora] ([ParentId],[AppId],[ModuleId],[Name],[StateId],[DateStart],[DateEnd],[DateWorkStart],[DateWorkEnd]
    ,[ProcessId],[ProcessStringId],[UserId],[MachineId],[FailureTask],[Message])
   VALUES (NULL, 'NA', 0, 'spBitacoraFile_Error',  @StateId, GetDate(), GetDate(), @dtDateWork, @dtDateWork
   ,@ProcessId, NULL, 0 , 'SQL', NULL, @message);

   set @bitacoraId = SCOPE_IDENTITY()
  end;

  INSERT INTO [Audit].[BitacoraFile]([BitacoraId],[DateStart],[DateEnd],[DateWork],[DateDelete],[StateId],[ProcessId],[Name]
   ,[PathSource],[PathTarget],[PathWithoutProcessing],[PathError],[PathProcessed],[PathProcessed2],[PathEncrypted],[Message])     
  VALUES(@bitacoraId,GetDate(),GetDate(),@dtDateWork,NULL, @StateId, @ProcessId, @name
   ,@PathSource,@PathTarget,@PathWithoutProcessing,@PathError,@PathProcessed,@PathProcessed2,@PathEncrypted,@message);

  SET @FileId = SCOPE_IDENTITY();
 end;
End
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Audit].[spBitacoraFile_End]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_EXECUTEsql @statement = N'CREATE PROCEDURE [Audit].[spBitacoraFile_End] AS' 
END
GO
ALTER PROCEDURE [Audit].[spBitacoraFile_End] 
 @FileId bigint
 ,@StateId tinyint = 0
 ,@message nvarchar(4000) = NULL
As
/* ============================================================================================
Proposito: Actualiza la tabla de BitacoraFile.
 Si el estado es cancelado o error no actualiza este estado, de lo contrario utiliza el estado establecido, por defecto es 0: Exitoso.
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2015-04-01
Fecha actualizacion: 2020-07-15

Parametros:  
 @FileId: Código de archivo.
 @StateId: Codigo de estado, es opcional, por defecto es igual a 0: Exitoso.
 @message: Mensaje opcional.

Ejemplo:
EXECUTE [Audit].[spBitacoraFile_End] 0;

SELECT E.[StateId], E.[Name], A.* 
From [Audit].[BitacoraFile] A INNER JOIN [Audit].[BitacoraState] E ON A.[StateId] = E.[StateId]
WHERE A.[BitacoraId] = (SELECT Max(B2.[BitacoraId]) FROM [Audit].[Bitacora] B2);
============================================================================================ */
Begin
 declare @messagePrevious nvarchar(4000); 
 
 if Exists(Select * From [Audit].[BitacoraFile] Where [FileId] = @FileId)
 begin
  -- Mensaje anterior
  select @messagePrevious = [Message] FROM [Audit].[BitacoraFile] WHERE [FileId] = @FileId;
  set @messagePrevious = Coalesce(@messagePrevious, '');

  -- Si el mensaje ya fue adicionado ignorarlo
  if ( @message IS NOT NULL AND @message <> '' AND PATINDEX ('%' + @message + '%', @messagePrevious) > 0 )
  begin
   set @message = '';
  end; 

  UPDATE [Audit].[BitacoraFile] SET 
   [DateEnd] = GetDate()
   ,[StateId] = case when [StateId] IN (1, 3) then [StateId] else @StateId end  /* 0: Exitoso, 1: Error, 3: Cancelado */    
   ,[Message] = Convert(nvarchar(4000), Case When [Message] IS NULL OR [Message] = '' Then @message Else 
     Case When @message IS NULL OR @message = '' then [Message] Else @message + ' ' + [Message] end end)
  WHERE [FileId] = @FileId;
 end; 
End;
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Audit].[spBitacoraFile_Start]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_EXECUTEsql @statement = N'CREATE PROCEDURE [Audit].[spBitacoraFile_Start] AS' 
END
GO
ALTER PROCEDURE [Audit].[spBitacoraFile_Start] 
 @bitacoraId bigint OUTPUT
 ,@FileId bigint OUTPUT
 ,@DateWork nvarchar(23) = NULL
 ,@name nvarchar(400)
 ,@PathSource nvarchar(500)
 ,@PathTarget nvarchar(500)
 ,@PathWithoutProcessing nvarchar(500)
 ,@PathError nvarchar(500)
 ,@PathProcessed nvarchar(500)
 ,@PathProcessed2 nvarchar(500) = NULL
 ,@PathEncrypted nvarchar(500)= NULL
 ,@ProcessId bigint = NULL
As
/* ============================================================================================
Proposito: Registra el evento incio de procesamiento de archivo en la tabla BitacoraFile.
 Los archivos son tomados de PathSource, pasan luego a PathTarget, si está cifrado pasa a PathEncrypted y el archivos descifrado pasa a PathWithoutProcessing, 
 si no esta cifrado pasa a PathWithoutProcessing, si el procesamiento es exitoso pasa a PathProcessed y opcionalmente a PathProcessed2, pero si falla pasa a PathError.
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2015-04-01
Fecha actualizacion: 2020-07-15

Parametros:  
 @bitacoraId: Código de bitacora.
 @FileId: Código de archivo, parámetro retornado.
 @DateWork: Fecha de trabajo o negocio. Formato: YYYY-MM-DD ó YYYY-MM-DD HH:mm:ss ó YYYY-MM-DD HH:mm:ss.ttt.
 @name: Nombre de archivo.
 @PathSource: Ruta origen del archivo en disco, donde el usuario toma el archivo.
 @PathTarget: Ruta destino del archivo en disco, donde descarga el archivo.
 @PathWithoutProcessing: Ruta sin procesar del archivo en disco, donde son tomados para ser procesados.
 @PathError: Ruta error del archivo en disco, donde dejar el archivo en caso de error.
 @PathProcessed: Ruta sin procesar del archivo en disco, donde son tomados para ser procesados.
 @PathProcessed2: Ruta 2 procesado del archivo en disco, donde dejar el archivo después de ser procesado (opcional por ejemplo como backup para auditoria).
 @FileId: Parámetro de retorno con el código de procesamiento del archivo
 @PathEncrypted: Ruta cifrado del archivo en disco.
 @ProcessId: Código de proceso, por ejemplo el código de una carga de datos.

Ejemplo:
Declare @FileId bigint, @bitacoraId bigint;
SET @bitacoraId = NULL
EXECUTE [Audit].[spBitacoraFile_Start] @bitacoraId OUTPUT, @FileId OUTPUT, '2015-04-01', 'Datos1.txt', 'C:\Temp\Origen', 'C:\Temp\Destino', 
  'C:\Temp\SinProcesar', 'C:\Temp\Error', 'C:\Temp\Procesado', NULL, 'C:\Temp\Cifrado';
Print @bitacoraId;
Print @FileId;

EXECUTE [Audit].[spBitacoraFile_Start] 1, @FileId OUTPUT, '2015-04-01', 'Datos2.txt', 'C:\Temp\Origen', 'C:\Temp\Destino', 
 'C:\Temp\SinProcesar', 'C:\Temp\Error', 'C:\Temp\Procesado', NULL, NULL;

SELECT E.[StateId], E.[Name], A.* 
From [Audit].[BitacoraFile] A INNER JOIN [Audit].[BitacoraState] E ON A.[StateId] = E.[StateId]
WHERE A.[BitacoraId] = (SELECT Max(B2.[BitacoraId]) FROM [Audit].[Bitacora] B2);
============================================================================================ */
Begin 
 Declare @dtDateWork dateTime;
 
 BEGIN TRY
  if (@DateWork IS NULL OR RTRIM(@DateWork) = '')
  begin
   set @DateWork = NULL;
  end
  else
  begin
   set @dtDateWork = Convert(dateTime, @DateWork, 120);
  end; 
 END TRY 
 BEGIN CATCH
  --No hacer nada en caso de fallo
 END CATCH  

 if not exists(Select * From [Audit].[Bitacora] Where [BitacoraId] = @bitacoraId)
 Begin
  INSERT INTO [Audit].[Bitacora] ([ParentId],[AppId],[ModuleId],[Name],[StateId],[DateStart],[DateEnd],[DateWorkStart],[DateWorkEnd]
   ,[ProcessId],[ProcessStringId],[UserId],[MachineId],[FailureTask],[Message])
  VALUES (NULL, 'NA', 0, 'spBitacoraFile_Start',  2 /* Iniciado */, GetDate(), GetDate(), @dtDateWork, @dtDateWork
  ,@ProcessId, NULL, 0 , 'SQL', NULL, NULL);

  set @bitacoraId = SCOPE_IDENTITY()
 end;
 
 INSERT INTO [Audit].[BitacoraFile]([BitacoraId],[DateStart],[DateEnd],[DateWork],[DateDelete],[StateId],[ProcessId],[Name]
  ,[PathSource],[PathTarget],[PathWithoutProcessing],[PathError],[PathProcessed],[PathProcessed2],[PathEncrypted])     
 VALUES(@bitacoraId, GetDate(), NULL, @dtDateWork, NULL, 2 /* Iniciado */, @ProcessId, @name
  ,@PathSource, @PathTarget, @PathWithoutProcessing, @PathError, @PathProcessed, @PathProcessed2, @PathEncrypted);

 SET @FileId = SCOPE_IDENTITY();
End
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Audit].[spBitacoraFile_Validate]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_EXECUTEsql @statement = N'CREATE PROCEDURE [Audit].[spBitacoraFile_Validate] AS' 
END
GO
ALTER PROCEDURE [Audit].[spBitacoraFile_Validate]  
 @FileId int = NULL,
 @name nvarchar(400), 
 @fileProcessed bit OUTPUT
As
/* ============================================================================================
Proposito: Indica si un archivo fue procesado.
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2015-04-01
Fecha actualizacion: 2020-07-15

Parametros:  
 @FileId: Código del archivo, si es nulo utiliza el nombre del archivo para validar.
 @name: Nombre del archivo a validar, si suministra el código de archivo no utiliza el nombre de archivo.
 @fileProcessed: Parámetro de salida que indica si el archivo fue procesado, para ello valida que el estado sea:
  0, 'Exitoso', 1: 'Error', 3: 'Cancelado', 8: 'Generado', 9: 'Definitivo', 10: 'Publicado', 11: 'Existente', 12: 'Eliminando'.   
  0: Indica que el archivo no sido procesado.
  1: Indica que el archivo ya fue procesado.

Ejemplo:
Declare @fileProcessed bit;
EXECUTE [Audit].[spBitacoraFile_Validate] 1, 'Datos1.txt', @fileProcessed OUTPUT;
Print @fileProcessed

Declare @fileProcessed bit;
EXECUTE [Audit].[spBitacoraFile_Validate] NULL, 'XXX.txt', @fileProcessed OUTPUT;
Print @fileProcessed

SELECT E.[StateId], E.[Name], A.* 
From [Audit].[BitacoraFile] A INNER JOIN [Audit].[BitacoraState] E ON A.[StateId] = E.[StateId]
WHERE A.[BitacoraId] = (SELECT Max(B2.[BitacoraId]) FROM [Audit].[Bitacora] B2);
============================================================================================ */
Begin
 If  @FileId is NULL
  SELECT @fileProcessed = Case When Count(*) = 0 Then 0 Else 1 End   
  FROM [Audit].[BitacoraFile]
  WHERE [Name] = @name And [StateId] IN (0, 1, 3, 8, 9, 10, 11, 12);
 else
  SELECT @fileProcessed = Case When Count(*) = 0 Then 0 Else 1 End  
  FROM [Audit].[BitacoraFile]
  WHERE [FileId] = @FileId And [StateId] IN (0, 1, 3, 8, 9, 10, 11, 12);  
End;
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Audit].[spBitacoraFile_GetFileId]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_EXECUTEsql @statement = N'CREATE PROCEDURE [Audit].[spBitacoraFile_GetFileId] AS' 
END
GO
ALTER PROCEDURE [Audit].[spBitacoraFile_GetFileId]  
  @bitacoraId bigint
 ,@name nvarchar(400) 
 ,@FileId int OUTPUT
As
/* ============================================================================================
Proposito: Retorna el código del archivo
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2015-04-01
Fecha actualizacion: 2020-07-15

Parametros:  
 @bitacoraId: Código de bitacora.
 @name: Nombre del archivo a validar.
 @FileId: Código del archivo a ser retornado

Ejemplo:
Declare @FileId int
EXECUTE [Audit].[spBitacoraFile_GetFileId] 1, 'Datos1.txt', @FileId OUTPUT;
Print @FileId;

SELECT E.[StateId], E.[Name], A.* 
From [Audit].[BitacoraFile] A INNER JOIN [Audit].[BitacoraState] E ON A.[StateId] = E.[StateId]
WHERE A.[BitacoraId] = (SELECT Max(B2.[BitacoraId]) FROM [Audit].[Bitacora] B2);
============================================================================================ */
Begin
 set @FileId = NULL;
  SELECT @FileId = [FileId]  
  FROM [Audit].[BitacoraFile]
  WHERE [BitacoraId] = @bitacoraId And [Name] = @name;
End
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Audit].[spBitacoraFile_IsErrorCanceled]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_EXECUTEsql @statement = N'CREATE PROCEDURE [Audit].[spBitacoraFile_IsErrorCanceled] AS' 
END
GO
ALTER procedure [Audit].[spBitacoraFile_IsErrorCanceled]
  @FileId int = NULL
 ,@name nvarchar(400) 
 ,@isError bit OUTPUT
as
/* ============================================================================================
Proposito: Retorna un valor booleano que indica si el archivo fue: 1: 'Error', 3: 'Cancelado', 12: 'Eliminando'
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2015-04-01
Fecha actualizacion: 2020-07-15

Parametros:  
 @FileId: Código del archivo, si es nulo utiliza el nombre del archivo para validar.
 @name: Nombre del archivo a validar, si suministra el código de archivo no utiliza el nombre de archivo.
 @isError: Parametro de retorno que indica si debe detener la ejecucion de paquetes

Ejemplo:
Declare @isError bit
EXECUTE [Audit].[spBitacoraFile_IsErrorCanceled] 3, '', @isError OUTPUT;
Print @isError;

SELECT E.[StateId], E.[Name], A.* 
From [Audit].[BitacoraFile] A INNER JOIN [Audit].[BitacoraState] E ON A.[StateId] = E.[StateId]
WHERE A.[BitacoraId] = (SELECT Max(B2.[BitacoraId]) FROM [Audit].[Bitacora] B2);
============================================================================================ */
begin
 set nocount on
 If  (@FileId is NULL)
 begin
  if exists (select * from [Audit].[BitacoraFile] where [Name] = @name and [StateId] IN (1, 3, 12))
   set @isError = 1
  else 
   set @isError = 0
 end
 else 
 begin
  if exists (select * from [Audit].[BitacoraFile] where [FileId] = @FileId and [StateId] IN (1, 3, 12))
   set @isError = 1
  else 
   set @isError = 0
 end
end 
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Audit].[spBitacoraDetail_Insert]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_EXECUTEsql @statement = N'CREATE PROCEDURE [Audit].[spBitacoraDetail_Insert] AS' 
END
GO
ALTER procedure [Audit].[spBitacoraDetail_Insert]
 @bitacoraId bigint OUTPUT
 ,@item bigint = NULL OUTPUT
 ,@name nvarchar(128)
 ,@message nvarchar(4000) = NULL
 ,@StateId tinyint = 1 /* 1: Error */
 ,@SeverityId tinyint = 0 /* 0: Informativo */
 ,@TypeId smallint = 1 /* 1: General */
 ,@DateWork nvarchar(23) = NULL
as
/* ============================================================================================
Proposito: Adiciona filas a la taba detalle de bitacora.
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2015-04-01
Fecha actualizacion: 2020-07-15

Parametros:
 @bitacoraId: Código de bitacora.
 @item: Parámetro de retorno con el código de inconsistencia.
 @name: Nombre del subproceso, tabla de datos o entidad.
 @message: Mensaje.
 @StateId: Código de estado de ejecucion (Exito, fallo, existente, ...). FK a [Audit].[BitacoraState].
 @SeverityId: Nivel de severidad. 0: Informativo, 1: Advertencia, 2: Error bajo, 3: Error medio, 4: Error alto, 5: Error critico.
 @TypeId: Código de tipo de inconsistencia. FK a [Audit].[BitacoraType].
 @DateWork: Fecha de trabajo. Formato: YYYY-MM-DD ó YYYY-MM-DD HH:mm:ss ó YYYY-MM-DD HH:mm:ss.ttt.
 
Ejemplo:
declare @item bigint;
EXECUTE [Audit].[spBitacoraDetail_Insert] 1, @item OUTPUT, 'MiSP', 'Mensaje de prueba';

SELECT * FROM [Audit].[BitacoraDetail] where [Item] = @item; 

SELECT D.* 
FROM [Audit].[BitacoraDetail] D 
WHERE D.[BitacoraId] = (SELECT Max(B2.[BitacoraId]) FROM [Audit].[Bitacora] B2);
============================================================================================ */
begin
 Declare @dtDateWork dateTime;
 
 BEGIN TRY
  if (@DateWork IS NULL OR RTRIM(@DateWork) = '')
  begin
   set @DateWork = NULL;
  end
  else
  begin
   set @dtDateWork = Convert(dateTime, @DateWork, 120);
  end; 
 END TRY 
 BEGIN CATCH
  --No hacer nada en caso de fallo
 END CATCH  

 if (@SeverityId IS NULL OR @SeverityId > 5)
 begin
  set @SeverityId = 5;
 end;

 if not exists(Select * From [Audit].[Bitacora] Where [BitacoraId] = @bitacoraId)
 Begin
  INSERT INTO [Audit].[Bitacora] ([ParentId],[AppId],[ModuleId],[Name],[StateId],[DateStart],[DateEnd],[DateWorkStart],[DateWorkEnd]
   ,[ProcessId],[ProcessStringId],[UserId],[MachineId],[FailureTask],[Message])
  VALUES (NULL, 'NA', 0, 'spBitacoraDetail_Insert',  @StateId, GetDate(), GetDate(), @dtDateWork, @dtDateWork
  ,NULL, NULL, 0 , 'SQL', NULL, @message);

  set @bitacoraId = SCOPE_IDENTITY()
 end;

 INSERT INTO [Audit].[BitacoraDetail]([BitacoraId],[Name],[StateId],[SeverityId],[TypeId],[DateRun],[DateWork],[Message])
 VALUES (@bitacoraId, @name, @StateId, @SeverityId, @TypeId, GetDate(), @dtDateWork, @message);
 
 set @item = SCOPE_IDENTITY();
end 
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Audit].[spBitacoraStatistic_End]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_EXECUTEsql @statement = N'CREATE PROCEDURE [Audit].[spBitacoraStatistic_End] AS' 
END
GO
ALTER PROCEDURE [Audit].[spBitacoraStatistic_End] 
  @item bigint
 ,@DateWork nvarchar(23) = NULL
 ,@name nvarchar(128) = NULL
 ,@rowsConsulted bigint = NULL
 ,@rowsError bigint = NULL
 ,@rowsInserted bigint = NULL
 ,@rowsUpdated bigint = NULL
 ,@rowsDeleted bigint = NULL
As
/* ============================================================================================
Proposito: Actualiza la tabla de BitacoraStatistic.
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2016-07-25
Fecha actualizacion: 2016-07-25

Parametros:  
 @item: Código del registro de estadisticas.
 @DateWork: Fecha de trabajo o negocio. Formato: YYYY-MM-DD ó YYYY-MM-DD HH:mm:ss ó YYYY-MM-DD HH:mm:ss.ttt.
 @name: Nombre del subproceso, por ejemplo: nombre de tabla o nombre de metodo.
 @rowsConsulted: Número de filas consultadas.
 @rowsError: Número de filas con error.
 @rowsInserted: Número de filas insertadas.
 @rowsUpdated: Número de filas actualizadas.
 @rowsDeleted: Número de filas borradas.

Ejemplo:
EXECUTE [Audit].[spBitacoraStatistic_End] 1;
EXECUTE [Audit].[spBitacoraStatistic_End] 1, 'Test', '2016-07-01', 200, 20;

SELECT E.* From [Audit].[BitacoraStatistic] E
WHERE E.[BitacoraId] = (SELECT Max(B2.[BitacoraId]) FROM [Audit].[Bitacora] B2);
============================================================================================ */
Begin
 Declare @dtDateWork dateTime;

 if EXISTS(SELECT * FROM [Audit].[BitacoraStatistic] WHERE [Item] = @item)
 begin 
  BEGIN TRY
   if (@DateWork IS NULL OR RTRIM(@DateWork) = '')
   begin
    set @DateWork = NULL;
   end
   else
   begin
    set @dtDateWork = Convert(dateTime, @DateWork, 120);
   end; 
  END TRY 
  BEGIN CATCH
   --No hacer nada en caso de fallo
  END CATCH  

  UPDATE [Audit].[BitacoraStatistic] SET 
     [DateEnd] = GetDate()
    ,[DateWork] = IsNull(@dtDateWork, [DateWork])
	,[Name] = IsNull(@name, [Name])
	,[RowsConsulted] = IsNull(@rowsConsulted, [RowsConsulted])
	,[RowsError] = IsNull(@rowsError, [RowsError])
	,[RowsInserted] = IsNull(@rowsInserted, [RowsInserted])
	,[RowsUpdated] = IsNull(@rowsUpdated, [RowsUpdated])
	,[RowsDeleted] = IsNull(@rowsDeleted, [RowsDeleted])
  WHERE [Item] = @item;
 end; 
End;
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Audit].[spBitacoraStatistic_Start]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_EXECUTEsql @statement = N'CREATE PROCEDURE [Audit].[spBitacoraStatistic_Start] AS' 
END
GO
ALTER PROCEDURE [Audit].[spBitacoraStatistic_Start] 
  @bitacoraId bigint OUTPUT
 ,@item bigint OUTPUT
 ,@DateWork nvarchar(23) = NULL
 ,@name nvarchar(128) = NULL
 ,@rowsConsulted bigint = NULL
 ,@rowsError bigint = NULL
 ,@rowsInserted bigint = NULL
 ,@rowsUpdated bigint = NULL
 ,@rowsDeleted bigint = NULL
 ,@ProcessId bigint = NULL
As
/* ============================================================================================
Proposito: Registra el evento incio en la tabla BitacoraStatistic.
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2016-07-25
Fecha actualizacion: 2016-07-25

Parametros:  
 @bitacoraId: Código de bitacora.
 @item: Código del registro de estadisticas, parámetro retornado.
 @DateWork: Fecha de trabajo o negocio. Formato: YYYY-MM-DD ó YYYY-MM-DD HH:mm:ss ó YYYY-MM-DD HH:mm:ss.ttt.
 @name: Nombre del subproceso, por ejemplo: nombre de tabla o nombre de metodo.
 @rowsConsulted: Número de filas consultadas.
 @rowsError: Número de filas con error.
 @rowsInserted: Número de filas insertadas.
 @rowsUpdated: Número de filas actualizadas.
 @rowsDeleted: Número de filas borradas.
 @ProcessId: Código de proceso, por ejemplo el código de una carga de datos.

Ejemplo:
Declare @item bigint, @bitacoraId bigint;
SET @bitacoraId = NULL
EXECUTE [Audit].[spBitacoraStatistic_Start] @bitacoraId OUTPUT, @item OUTPUT, 0, 'Test', NULL, 100, 10, 50, 40, 5;
Print @bitacoraId;
Print @item;

SELECT E.* From [Audit].[BitacoraStatistic] E
WHERE E.[BitacoraId] = (SELECT Max(B2.[BitacoraId]) FROM [Audit].[Bitacora] B2);
============================================================================================ */
Begin 
 Declare @dtDateWork dateTime;
 
 BEGIN TRY
  if (@DateWork IS NULL OR RTRIM(@DateWork) = '')
  begin
   set @DateWork = NULL;
  end
  else
  begin
   set @dtDateWork = Convert(dateTime, @DateWork, 120);
  end; 
 END TRY 
 BEGIN CATCH
  --No hacer nada en caso de fallo
 END CATCH  

 if NOT EXISTS(SELECT * FROM [Audit].[Bitacora] WHERE [BitacoraId] = @bitacoraId)
 Begin
  INSERT INTO [Audit].[Bitacora] ([ParentId],[AppId],[ModuleId],[Name],[StateId],[DateStart],[DateEnd],[DateWorkStart],[DateWorkEnd]
   ,[ProcessId],[ProcessStringId],[UserId],[MachineId],[FailureTask],[Message])
  VALUES (NULL, 'NA', 0, 'spBitacoraStatistic_Start',  2 /* Iniciado */, GetDate(), GetDate(), @dtDateWork, @dtDateWork
  ,@ProcessId, NULL, 0 , 'SQL', NULL, NULL);

  set @bitacoraId = SCOPE_IDENTITY()
 end;
 
 INSERT INTO [Audit].[BitacoraStatistic] ([BitacoraId], [Name], [DateStart], [DateEnd], [DateWork]
  ,[RowsConsulted], [RowsError], [RowsInserted], [RowsUpdated], [RowsDeleted])
 VALUES(@bitacoraId, @name, GetDate(), NULL, @dtDateWork, @rowsConsulted, @rowsError, @rowsInserted, @rowsUpdated, @rowsDeleted);

 SET @item = SCOPE_IDENTITY();
End
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Audit].[spBitacoraTable_Insert]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_EXECUTEsql @statement = N'CREATE PROCEDURE [Audit].[spBitacoraTable_Insert] AS' 
END
GO
ALTER procedure [Audit].[spBitacoraTable_Insert]
  @bitacoraId bigint OUTPUT
 ,@item bigint = NULL OUTPUT
 ,@name nvarchar(128)
 ,@message nvarchar(4000) = NULL
 ,@StateId tinyint = 1 /* 1: Error */
 ,@SeverityId tinyint = 0 /* 0: Informativo, 2: Error bajo */
 ,@TypeId smallint = 1 /* 1: General */
 ,@DateWork nvarchar(23) = NULL
 ,@tableTarget nvarchar(128) = NULL
 ,@FieldTarget nvarchar(50) = NULL
 ,@ValueTarget nvarchar(128) = NULL
 ,@TableSource nvarchar(128) = NULL
 ,@FieldSource nvarchar(50) = NULL
 ,@ValueSource nvarchar(128) = NULL
 ,@PKField1 nvarchar(50) = NULL
 ,@PKValue1 nvarchar(128) = NULL
 ,@PKField2 nvarchar(50) = NULL
 ,@PKValue2 nvarchar(128) = NULL
 ,@PKField3 nvarchar(50) = NULL
 ,@PKValue3 nvarchar(128) = NULL
 ,@PKField4 nvarchar(50) = NULL
 ,@PKValue4 nvarchar(128) = NULL
 ,@PKField5 nvarchar(50) = NULL
 ,@PKValue5 nvarchar(128) = NULL
as
/* ============================================================================================
Proposito: Adiciona filas a la taba detalle de bitacora.
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2015-04-01
Fecha actualizacion: 2020-07-15

Parametros:
 @bitacoraId: Código de bitacora.
 @item: Parámetro de retorno con el código de inconsistencia.
 @name: Nombre del subproceso, tabla de datos o entidad.
 @message: Mensaje.
 @StateId: Código de estado de ejecucion (Exito, fallo, existente, ...). FK a [Audit].[BitacoraState].
 @SeverityId: Nivel de severidad. 0: Informativo, 1: Advertencia, 2: Error bajo, 3: Error medio, 4: Error alto, 5: Error critico.
 @TypeId: Código de tipo de inconsistencia. FK a [Audit].[BitacoraType].
 @DateWork: Fecha de trabajo o negocio. Formato: YYYY-MM-DD ó YYYY-MM-DD HH:mm:ss ó YYYY-MM-DD HH:mm:ss.ttt.
 @tableTarget: Tabla destino.
 @FieldTarget: Campo destino.
 @ValueTarget: Valor del campo destino.
 @TableSource: Tabla origen.
 @FieldSource: Campo origen.
 @ValueSource: Valor del campo origen.
 @PKField1: Nombre de campo clave primaria origen 1.
 @PKValue1: Valor de campo clave primaria origen 1.
 @PKField2: Nombre de campo clave primaria origen 2.
 @PKValue2: Valor de campo clave primaria origen 2.
 @PKField3: Nombre de campo clave primaria origen 3.
 @PKValue3: Valor de campo clave primaria origen 3.
 @PKField4: Nombre de campo clave primaria origen 4.
 @PKValue4: Valor de campo clave primaria origen 4.
 @PKField5: Nombre de campo clave primaria origen 5.
 @PKValue5: Valor de campo clave primaria origen 1.
 
Ejemplo:
declare @item bigint;
EXECUTE [Audit].[spBitacoraTable_Insert] 1, @item OUTPUT, 'MiSP', 'Mensaje de prueba';

SELECT T.* 
FROM [Audit].[BitacoraTable] T
WHERE T.[BitacoraId] = (SELECT Max(B2.[BitacoraId]) FROM [Audit].[Bitacora] B2);
============================================================================================ */
begin
 Declare @dtDateWork dateTime;
 
 BEGIN TRY
  if (@DateWork IS NULL OR RTRIM(@DateWork) = '')
  begin
   set @DateWork = NULL;
  end
  else
  begin
   set @dtDateWork = Convert(dateTime, @DateWork, 120);
  end; 
 END TRY 
 BEGIN CATCH
  --No hacer nada en caso de fallo
 END CATCH  

 if (@SeverityId IS NULL OR @SeverityId > 5 OR @SeverityId < 0)
 begin
  set @SeverityId = 5;
 end;

 if not exists(Select * From [Audit].[Bitacora] Where [BitacoraId] = @bitacoraId)
 Begin
  INSERT INTO [Audit].[Bitacora] ([ParentId],[AppId],[ModuleId],[Name],[StateId],[DateStart],[DateEnd],[DateWorkStart],[DateWorkEnd]
   ,[ProcessId],[ProcessStringId],[UserId],[MachineId],[FailureTask],[Message])
  VALUES (NULL, 'NA', 0, 'spBitacoraTable_Insert', @StateId, GetDate(), GetDate(), @dtDateWork, @dtDateWork
  ,NULL, NULL, 0 , 'SQL', NULL, @message);
 
  set @bitacoraId = SCOPE_IDENTITY()
 end;

 INSERT INTO [Audit].[BitacoraTable]([BitacoraId],[Name],[StateId],[SeverityId],[TypeId],[DateRun],[DateWork],[TableTarget],[FieldTarget],[ValueTarget]
  , [TableSource],[FieldSource],[ValueSource],[PKField1],[PKValue1],[PKField2],[PKValue2],[PKField3],[PKValue3],[PKField4],[PKValue4],[PKField5],[PKValue5],[Message])
 VALUES (@bitacoraId, @name, @StateId, @SeverityId, @TypeId, GetDate(), @dtDateWork, @tableTarget, @FieldTarget, @ValueTarget
  , @TableSource, @FieldSource, @ValueSource, @PKField1, @PKValue1, @PKField2, @PKValue2, @PKField3, @PKValue3, @PKField4, @PKValue4, @PKField5, @PKValue5, @message);
 
 set @item = SCOPE_IDENTITY();
end 
GO


/*====================================================================================
CONSULTAS ARBOL DE AUDITORIA DE ejecucion
http://thesqlgeek.com/2009/11/ssis-logging-framework/
==================================================================================== */
IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Audit].[GetBitacoraRoot]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
 EXEC('CREATE FUNCTION [Audit].[GetBitacoraRoot] (@bitacoraId bigint)
RETURNS bigint
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN
 RETURN(0);
END');
GO

ALTER FUNCTION [Audit].[GetBitacoraRoot] (@bitacoraId bigint)
RETURNS bigint
WITH RETURNS NULL ON NULL INPUT
AS
/* ============================================================================================
Proposito: Retorna el código raíz del arbol de ejecucion debajo del nodo especificado, en la tabla: [Audit].[Bitacora]. 
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2016-04-01
Fecha actualizacion: 2016-06-24

Parametros:
 @bitacoraId: Código de bitacora.

Ejemplo:
SELECT [Audit].[GetBitacoraRoot](0);
SELECT [Audit].[GetBitacoraRoot](1);
SELECT [Audit].[GetBitacoraRoot](31);

SELECT * FROM [Audit].[Bitacora] ORDER BY [BitacoraId] DESC;
============================================================================================ */
begin
 Declare @rootId bigint;

 ;WITH [CTE_Graph] As (
  -- Ancla del nodo
  SELECT [BitacoraId], [ParentId] 
  FROM [Audit].[Bitacora] WITH (NOLOCK) 
  WHERE [BitacoraId] = @bitacoraId
  UNION ALL
  -- Nodo padre
  SELECT Node.[BitacoraId], Node.[ParentId] 
  FROM [Audit].[Bitacora] as node WITH (NOLOCK) 
  INNER JOIN [CTE_Graph] as leaf ON Node.[BitacoraId] = leaf.[ParentId]
 )
 SELECT TOP 1 @rootId = [BitacoraId] 
 FROM [CTE_Graph] 
 WHERE [ParentId] IS NULL
 ORDER BY [BitacoraId];

 RETURN isnull(@rootId, @bitacoraId);
end 
GO


IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Audit].[GetBitacoraDetailTree]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
 EXEC('CREATE FUNCTION [Audit].[GetBitacoraDetailTree](@bitacoraId bigint, @fromRoot bit = 0)
RETURNS @tableResult TABLE 
(
     [Id] [int] IDENTITY(1, 1) PRIMARY KEY
	,[Level] [int]
	,[ParentId] [bigint]
	,[BitacoraId] [bigint]
	,[Item] [bigint]
	,[Name] [nvarchar](128)
	,[StateId] [tinyint]
	,[State] [nvarchar](50)
	,[SeverityId] [tinyint]
	,[TypeId] [smallint]
	,[Type] [nvarchar](50)
	,[DateRun] [datetime]
	,[DateWork] [datetime]
	,[Message] [nvarchar](4000)
) 
AS
BEGIN
 RETURN;
END');
GO

ALTER FUNCTION [Audit].[GetBitacoraDetailTree](
 @bitacoraId bigint
,@fromRoot bit = 0
)
RETURNS @tableResult TABLE 
(
     [Id] [int] IDENTITY(1, 1) PRIMARY KEY
	,[Level] [int]
	,[ParentId] [bigint]
	,[BitacoraId] [bigint]
	,[Item] [bigint]
	,[Name] [nvarchar](128)
	,[StateId] [tinyint]
	,[State] [nvarchar](50)
	,[SeverityId] [tinyint]
	,[TypeId] [smallint]
	,[Type] [nvarchar](50)
	,[DateRun] [datetime]
	,[DateWork] [datetime]
	,[Message] [nvarchar](4000)
) 
As
/* ============================================================================================
Proposito: Retorna arbol de ejecucion debajo del nodo especificado: subarbol desde el nodo actual (nodo actual y sus hijos) o el arbol completo,
 de la tabla: [Audit].[BitacoraDetail].
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2016-04-01
Fecha actualizacion: 2016-06-24

Parametros:
 @bitacoraId: Código de bitacora.
 @fromRoot: Indica si retorna una parte o el arbol completo:
  0: Retorna el subarbol desde el nodo actual (nodo actual y sus hijos).
  1: Retorna el arbol completo.

Ejemplo:
SELECT * FROM [Audit].[GetBitacoraDetailTree]((SELECT Max([BitacoraId]) FROM [Audit].[Bitacora]), 1);

SELECT * FROM [Audit].[GetBitacoraDetailTree](5, 0);
SELECT * FROM [Audit].[GetBitacoraDetailTree](5, 1);

SELECT E.[StateId], E.[Name], A.* 
From [Audit].[BitacoraDetail] A INNER JOIN [Audit].[BitacoraState] E ON A.[StateId] = E.[StateId]
WHERE A.[BitacoraId] = (SELECT Max(B2.[BitacoraId]) FROM [Audit].[Bitacora] B2);
============================================================================================ */
begin
 Declare @b bigint;
 set @b = case @fromRoot when 1 then [Audit].[GetBitacoraRoot] (@bitacoraId) else @bitacoraId end;

 WITH [CTE_Graph] As (
  -- Ancla del nodo
 SELECT 0 as [Level],B.[ParentId],B.[BitacoraId]
 FROM [Audit].[Bitacora] B WITH (NOLOCK) 
 WHERE B.[BitacoraId] = @b
 -- Nodos hijo
 UNION ALL
 SELECT [Level] + 1,B.[ParentId],B.[BitacoraId]
 FROM [Audit].[Bitacora] B WITH (NOLOCK) 
 INNER JOIN [CTE_Graph] As Node ON Node.[BitacoraId] = B.[ParentId]
 )
 INSERT INTO @tableResult ([Level],[ParentId],[BitacoraId],[Item],[Name],[StateId],[State],[SeverityId],[TypeId],[Type],[DateRun],[DateWork],[Message])
 SELECT TOP (100) PERCENT B.[Level],ISNULL(B.[ParentId],B.[BitacoraId]),B.[BitacoraId],D.[Item],D.[Name],D.[StateId],E.[Name] [State]
  ,D.[SeverityId],D.[TypeId],BT.[Name] [Type],D.[DateRun],D.[DateWork],D.[Message]
 from [CTE_Graph] B
 INNER JOIN [Audit].[BitacoraDetail] D WITH (NOLOCK) ON D.[BitacoraId] = B.[BitacoraId]
 LEFT JOIN [Audit].[BitacoraState] E WITH (NOLOCK) ON E.[StateId] = D.[StateId]
 LEFT JOIN [Audit].[BitacoraType] BT WITH (NOLOCK) ON BT.[TypeId] = D.[TypeId]
 ORDER BY CASE WHEN B.[ParentId] IS NULL THEN B.[BitacoraId] ELSE B.[ParentId] END, B.[Level], B.[BitacoraId], D.[Item];

 RETURN;
END;
GO


IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Audit].[GetBitacoraDetailTree_ByDate]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
 EXEC('CREATE FUNCTION [Audit].[GetBitacoraDetailTree_ByDate](@dateStart nvarchar(10), @dateEnd nvarchar(10))
RETURNS @tableResult TABLE 
(
     [Id] [int] IDENTITY(1, 1) PRIMARY KEY
	,[Level] [int]
	,[ParentId] [bigint]
	,[BitacoraId] [bigint]
	,[Item] [bigint]
	,[Name] [nvarchar](128)
	,[StateId] [tinyint]
	,[State] [nvarchar](50)
	,[SeverityId] [tinyint]
	,[TypeId] [smallint]
	,[Type] [nvarchar](50)
	,[DateRun] [datetime]
	,[DateWork] [datetime]
	,[Message] [nvarchar](4000)
) 
AS
BEGIN
 RETURN;
END');
GO

ALTER FUNCTION [Audit].[GetBitacoraDetailTree_ByDate](@dateStart nvarchar(10), @dateEnd nvarchar(10))
RETURNS @tableResult TABLE 
(
     [Id] [int] IDENTITY(1, 1) PRIMARY KEY
	,[Level] [int]
	,[ParentId] [bigint]
	,[BitacoraId] [bigint]
	,[Item] [bigint]
	,[Name] [nvarchar](128)
	,[StateId] [tinyint]
	,[State] [nvarchar](50)
	,[SeverityId] [tinyint]
	,[TypeId] [smallint]
	,[Type] [nvarchar](50)
	,[DateRun] [datetime]
	,[DateWork] [datetime]
	,[Message] [nvarchar](4000)
) 
As
/* ============================================================================================
Proposito: Retorna arbol de ejecucion en un rango de fechas, de la tabla: [Audit].[BitacoraDetail].
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2016-04-01
Fecha actualizacion: 2016-06-24

Parametros:
 @dateStart: Fecha inicial en formato: YYYY-MM-DD.
 @dateEnd: Fecha final en formato: YYYY-MM-DD.

Ejemplo:
SELECT * FROM [Audit].[GetBitacoraDetailTree_ByDate]('2018-01-01', '2018-02-01');

SELECT E.[StateId], E.[Name], A.* 
From [Audit].[BitacoraDetail] A INNER JOIN [Audit].[BitacoraState] E ON A.[StateId] = E.[StateId]
WHERE A.[BitacoraId] = (SELECT Max(B2.[BitacoraId]) FROM [Audit].[Bitacora] B2);
============================================================================================ */
begin
 Declare @dtDateStart date, @dtDateEnd date, @dtTempo date;

 if ( (@dateStart IS NULL OR RTrim(@dateStart) = '') OR (@dateEnd IS NULL OR RTrim(@dateEnd) = '') )
 begin
  RETURN; 
 end
 else
 begin
  set @dtDateStart = convert(date, @dateStart, 120);
  set @dtDateEnd = convert(date, @dateEnd, 120);

  if (@dtDateEnd < @dtDateStart)
  begin
   set @dtTempo = @dtDateStart;
   set @dtDateStart = @dtDateEnd;
   set @dtDateEnd = @dtTempo;
  end; 
 end;

 WITH [CTE_Graph] as (
  -- Ancla del nodo
 SELECT 0 as [Level],B.[ParentId],B.[BitacoraId]
 FROM [Audit].[Bitacora] B WITH (NOLOCK) 
 WHERE (B.[DateStart] >= @dtDateStart AND B.[DateStart] < @dtDateEnd)
 -- Nodos hijo
 UNION ALL
 SELECT [Level] + 1,B.[ParentId],B.[BitacoraId]
 FROM [Audit].[Bitacora] B WITH (NOLOCK) 
 INNER JOIN [CTE_Graph] As Node ON Node.[BitacoraId] = B.[ParentId]
 )
 INSERT INTO @tableResult ([Level],[ParentId],[BitacoraId],[Item],[Name],[StateId],[State],[SeverityId],[TypeId],[Type],[DateRun],[DateWork],[Message])
 SELECT TOP (100) PERCENT B.[Level],ISNULL(B.[ParentId],B.[BitacoraId]),B.[BitacoraId],D.[Item],D.[Name],D.[StateId],E.[Name] [State]
  ,D.[SeverityId],D.[TypeId],BT.[Name] [Type],D.[DateRun],D.[DateWork],D.[Message]
 from [CTE_Graph] B
 INNER JOIN [Audit].[BitacoraDetail] D WITH (NOLOCK) ON D.[BitacoraId] = B.[BitacoraId]
 LEFT JOIN [Audit].[BitacoraState] E WITH (NOLOCK) ON E.[StateId] = D.[StateId]
 LEFT JOIN [Audit].[BitacoraType] BT WITH (NOLOCK) ON BT.[TypeId] = D.[TypeId]
 ORDER BY CASE WHEN B.[ParentId] IS NULL THEN B.[BitacoraId] ELSE B.[ParentId] END, B.[Level], B.[BitacoraId], D.[Item];

 RETURN;
END;
GO


IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Audit].[GetBitacoraFileTree]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
 EXEC('CREATE FUNCTION [Audit].[GetBitacoraFileTree](@bitacoraId bigint, @fromRoot bit = 0)
RETURNS @tableResult TABLE 
(
     [Id] [int] IDENTITY(1, 1) PRIMARY KEY
	,[Level] [int]
	,[ParentId] [bigint]
	,[BitacoraId] [bigint]
	,[FileId] [bigint]
	,[StateId] [tinyint]
	,[State] [nvarchar](50)
	,[DateStart] [datetime]
	,[DateEnd] [datetime]
    ,[TimeDuration] [nvarchar](30)
	,[DateWork] [datetime]
	,[DateDelete] [datetime]
	,[ProcessId] [bigint]
	,[Name] [nvarchar](400)
	,[PathSource] [nvarchar](500)
	,[PathTarget] [nvarchar](500)
	,[PathWithoutProcessing] [nvarchar](500)
	,[PathError] [nvarchar](500)
	,[PathProcessed] [nvarchar](500)
	,[PathProcessed2] [nvarchar](500)
	,[PathEncrypted] [nvarchar](500)
	,[Message] [nvarchar](4000)
) 
AS
BEGIN
 RETURN;
END');
GO

ALTER FUNCTION [Audit].[GetBitacoraFileTree](
 @bitacoraId bigint
,@fromRoot bit = 0
)
RETURNS @tableResult TABLE 
(
     [Id] [int] IDENTITY(1, 1) PRIMARY KEY
	,[Level] [int]
	,[ParentId] [bigint]
	,[BitacoraId] [bigint]
	,[FileId] [bigint]
	,[StateId] [tinyint]
	,[State] [nvarchar](50)
	,[DateStart] [datetime]
	,[DateEnd] [datetime]
    ,[TimeDuration] [nvarchar](30)
	,[DateWork] [datetime]
	,[DateDelete] [datetime]
	,[ProcessId] [bigint]
	,[Name] [nvarchar](400)
	,[PathSource] [nvarchar](500)
	,[PathTarget] [nvarchar](500)
	,[PathWithoutProcessing] [nvarchar](500)
	,[PathError] [nvarchar](500)
	,[PathProcessed] [nvarchar](500)
	,[PathProcessed2] [nvarchar](500)
	,[PathEncrypted] [nvarchar](500)
	,[Message] [nvarchar](4000)
) 
As
/* ============================================================================================
Proposito: Retorna arbol de ejecucion debajo del nodo especificado: subarbol desde el nodo actual (nodo actual y sus hijos) o el arbol completo,
 de la tabla: [Audit].[BitacoraFile].
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2016-04-01
Fecha actualizacion: 2016-06-24

Parametros:
 @bitacoraId: Código de bitacora.
 @fromRoot: Indica si retorna una parte o el arbol completo:
  0: Retorna el subarbol desde el nodo actual (nodo actual y sus hijos).
  1: Retorna el arbol completo.

Ejemplo:
SELECT * FROM [Audit].[GetBitacoraFileTree]((SELECT Max([BitacoraId]) FROM [Audit].[Bitacora]), 1);

SELECT * FROM [Audit].[GetBitacoraFileTree](5, 0);
SELECT * FROM [Audit].[GetBitacoraFileTree](5, 1);

SELECT E.[StateId], E.[Name], A.* 
From [Audit].[BitacoraFile] A INNER JOIN [Audit].[BitacoraState] E ON A.[StateId] = E.[StateId]
WHERE A.[BitacoraId] = (SELECT Max(B2.[BitacoraId]) FROM [Audit].[Bitacora] B2);
============================================================================================ */
begin
 Declare @b bigint;
 set @b = case @fromRoot when 1 then [Audit].[GetBitacoraRoot] (@bitacoraId) else @bitacoraId end;

 WITH [CTE_Graph] As (
  -- Ancla del nodo
 SELECT 0 as [Level],B.[ParentId],B.[BitacoraId] 
 FROM [Audit].[Bitacora] B WITH (NOLOCK) 
 WHERE B.[BitacoraId] = @b
 -- Nodos hijo
 UNION ALL
 SELECT [Level] + 1,B.[ParentId],B.[BitacoraId] 
 FROM [Audit].[Bitacora] B WITH (NOLOCK) 
 INNER JOIN [CTE_Graph] As Node ON Node.[BitacoraId] = B.[ParentId]
 )
 INSERT INTO @tableResult ([Level],[ParentId],[BitacoraId],[FileId],[StateId],[State],[DateStart],[DateEnd],[TimeDuration],[DateWork]
  ,[DateDelete],[ProcessId],[Name],[PathSource],[PathTarget],[PathWithoutProcessing],[PathError],[PathProcessed],[PathProcessed2],[PathEncrypted],[Message]) 
 SELECT TOP (100) PERCENT B.[Level],ISNULL(B.[ParentId],B.[BitacoraId]),B.[BitacoraId],D.[FileId],D.[StateId],E.[Name] [State],D.[DateStart],D.[DateEnd]
  ,[Utility].[GetDurationBetweenDates] (D.[DateStart], D.[DateEnd]) [TimeDuration],D.[DateWork],D.[DateDelete]
  ,D.[ProcessId],D.[Name],D.[PathSource],D.[PathTarget],D.[PathWithoutProcessing],D.[PathError],D.[PathProcessed],D.[PathProcessed2],D.[PathEncrypted],D.[Message]  
 from [CTE_Graph] B
 INNER JOIN [Audit].[BitacoraFile] D WITH (NOLOCK) ON D.[BitacoraId] = B.[BitacoraId]
 LEFT JOIN [Audit].[BitacoraState] E WITH (NOLOCK) ON E.[StateId] = D.[StateId]
 ORDER BY CASE WHEN B.[ParentId] IS NULL THEN B.[BitacoraId] ELSE B.[ParentId] END, B.[Level], B.[BitacoraId], D.[FileId];

 RETURN;
END;
GO


IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Audit].[GetBitacoraFileTree_ByDate]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
 EXEC('CREATE FUNCTION [Audit].[GetBitacoraFileTree_ByDate](@dateStart nvarchar(10), @dateEnd nvarchar(10))
RETURNS @tableResult TABLE 
(
     [Id] [int] IDENTITY(1, 1) PRIMARY KEY
	,[Level] [int]
	,[ParentId] [bigint]
	,[BitacoraId] [bigint]
	,[FileId] [bigint]
	,[StateId] [tinyint]
	,[State] [nvarchar](50)
	,[DateStart] [datetime]
	,[DateEnd] [datetime]
    ,[TimeDuration] [nvarchar](30)
	,[DateWork] [datetime]
	,[DateDelete] [datetime]
	,[ProcessId] [bigint]
	,[Name] [nvarchar](400)
	,[PathSource] [nvarchar](500)
	,[PathTarget] [nvarchar](500)
	,[PathWithoutProcessing] [nvarchar](500)
	,[PathError] [nvarchar](500)
	,[PathProcessed] [nvarchar](500)
	,[PathProcessed2] [nvarchar](500)
	,[PathEncrypted] [nvarchar](500)
	,[Message] [nvarchar](4000)
) 
AS
BEGIN
 RETURN;
END');
GO

ALTER FUNCTION [Audit].[GetBitacoraFileTree_ByDate](@dateStart nvarchar(10), @dateEnd nvarchar(10))
RETURNS @tableResult TABLE 
(
     [Id] [int] IDENTITY(1, 1) PRIMARY KEY
	,[Level] [int]
	,[ParentId] [bigint]
	,[BitacoraId] [bigint]
	,[FileId] [bigint]
	,[StateId] [tinyint]
	,[State] [nvarchar](50)
	,[DateStart] [datetime]
	,[DateEnd] [datetime]
    ,[TimeDuration] [nvarchar](30)
	,[DateWork] [datetime]
	,[DateDelete] [datetime]
	,[ProcessId] [bigint]
	,[Name] [nvarchar](400)
	,[PathSource] [nvarchar](500)
	,[PathTarget] [nvarchar](500)
	,[PathWithoutProcessing] [nvarchar](500)
	,[PathError] [nvarchar](500)
	,[PathProcessed] [nvarchar](500)
	,[PathProcessed2] [nvarchar](500)
	,[PathEncrypted] [nvarchar](500)
	,[Message] [nvarchar](4000)
) 
As
/* ============================================================================================
Proposito: Retorna arbol de ejecucion en un rango de fechas, de la tabla: [Audit].[BitacoraFile].
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2016-04-01
Fecha actualizacion: 2016-06-24

Parametros:
 @dateStart: Fecha inicial en formato: YYYY-MM-DD.
 @dateEnd: Fecha final en formato: YYYY-MM-DD.

Ejemplo:
SELECT * FROM [Audit].[GetBitacoraFileTree_ByDate]('2018-01-01', '2018-02-01');

SELECT E.[StateId], E.[Name], A.* 
From [Audit].[BitacoraFile] A INNER JOIN [Audit].[BitacoraState] E ON A.[StateId] = E.[StateId]
WHERE A.[BitacoraId] = (SELECT Max(B2.[BitacoraId]) FROM [Audit].[Bitacora] B2);
============================================================================================ */
begin
 Declare @dtDateStart date, @dtDateEnd date, @dtTempo date;

 if ( (@dateStart IS NULL OR RTrim(@dateStart) = '') OR (@dateEnd IS NULL OR RTrim(@dateEnd) = '') )
 begin
  RETURN; 
 end
 else
 begin
  set @dtDateStart = convert(date, @dateStart, 120);
  set @dtDateEnd = convert(date, @dateEnd, 120);

  if (@dtDateEnd < @dtDateStart)
  begin
   set @dtTempo = @dtDateStart;
   set @dtDateStart = @dtDateEnd;
   set @dtDateEnd = @dtTempo;
  end; 
 end;

 WITH [CTE_Graph] as (
  -- Ancla del nodo
 SELECT 0 as [Level],B.[ParentId],B.[BitacoraId]
 FROM [Audit].[Bitacora] B WITH (NOLOCK) 
 WHERE (B.[DateStart] >= @dtDateStart AND B.[DateStart] < @dtDateEnd)
 -- Nodos hijo
 UNION ALL
 SELECT [Level] + 1,B.[ParentId],B.[BitacoraId]
 FROM [Audit].[Bitacora] B WITH (NOLOCK) 
 INNER JOIN [CTE_Graph] As Node ON Node.[BitacoraId] = B.[ParentId]
 )
 INSERT INTO @tableResult ([Level],[ParentId],[BitacoraId],[FileId],[StateId],[State],[DateStart],[DateEnd],[TimeDuration],[DateWork]
  ,[DateDelete],[ProcessId],[Name],[PathSource],[PathTarget],[PathWithoutProcessing],[PathError],[PathProcessed],[PathProcessed2],[PathEncrypted],[Message]) 
 SELECT TOP (100) PERCENT B.[Level],ISNULL(B.[ParentId],B.[BitacoraId]),B.[BitacoraId],D.[FileId],D.[StateId],E.[Name] [State]
  ,D.[DateStart],D.[DateEnd],[Utility].[GetDurationBetweenDates] (D.[DateStart], D.[DateEnd]) [TimeDuration]
  ,D.[DateWork],D.[DateDelete]  ,D.[ProcessId],D.[Name],D.[PathSource],D.[PathTarget],D.[PathWithoutProcessing],D.[PathError],D.[PathProcessed],D.[PathProcessed2],D.[PathEncrypted],D.[Message]  
 from [CTE_Graph] B
 INNER JOIN [Audit].[BitacoraFile] D WITH (NOLOCK) ON D.[BitacoraId] = B.[BitacoraId]
 LEFT JOIN [Audit].[BitacoraState] E WITH (NOLOCK) ON E.[StateId] = D.[StateId]
 ORDER BY CASE WHEN B.[ParentId] IS NULL THEN B.[BitacoraId] ELSE B.[ParentId] END, B.[Level], B.[BitacoraId], D.[FileId];

 RETURN;
END;
GO


IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Audit].[GetBitacoraStatisticTree]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
 EXEC('CREATE FUNCTION [Audit].[GetBitacoraStatisticTree](@bitacoraId bigint, @fromRoot bit = 0)
RETURNS @tableResult TABLE 
(
     [Id] [int] IDENTITY(1, 1) PRIMARY KEY
	,[Level] [int]
	,[ParentId] [bigint]
	,[BitacoraId] [bigint]
	,[Item] [bigint]
	,[Name] [nvarchar](128)
	,[DateStart] [datetime]
	,[DateEnd] [datetime]
    ,[TimeDuration] [nvarchar](30)
	,[DateWork] [datetime]
	,[RowsConsulted] [bigint]
	,[RowsError] [bigint]
	,[RowsInserted] [bigint]
	,[RowsUpdated] [bigint] 
	,[RowsDeleted] [bigint]
) 
AS
BEGIN
 RETURN;
END');
GO

ALTER FUNCTION [Audit].[GetBitacoraStatisticTree](
 @bitacoraId bigint
,@fromRoot bit = 0
)
RETURNS @tableResult TABLE 
(
     [Id] [int] IDENTITY(1, 1) PRIMARY KEY
	,[Level] [int]
	,[ParentId] [bigint]
	,[BitacoraId] [bigint]
	,[Item] [bigint]
	,[Name] [nvarchar](128)
	,[DateStart] [datetime]
	,[DateEnd] [datetime]
    ,[TimeDuration] [nvarchar](30)
	,[DateWork] [datetime]
	,[RowsConsulted] [bigint]
	,[RowsError] [bigint]
	,[RowsInserted] [bigint]
	,[RowsUpdated] [bigint] 
	,[RowsDeleted] [bigint]
) 
As
/* ============================================================================================
Proposito: Retorna arbol de ejecucion debajo del nodo especificado: subarbol desde el nodo actual (nodo actual y sus hijos) o el arbol completo,
 de la tabla: [Audit].[BitacoraStatistic].
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2016-07-25
Fecha actualizacion: 2016-07-25

Parametros:
 @bitacoraId: Código de bitacora.
 @fromRoot: Indica si retorna una parte o el arbol completo:
  0: Retorna el subarbol desde el nodo actual (nodo actual y sus hijos).
  1: Retorna el arbol completo.

Ejemplo:
SELECT * FROM [Audit].[GetBitacoraStatisticTree]((SELECT Max([BitacoraId]) FROM [Audit].[Bitacora]), 1);

SELECT * FROM [Audit].[GetBitacoraStatisticTree](64, 0);
SELECT * FROM [Audit].[GetBitacoraStatisticTree](64, 1);

SELECT E.* From [Audit].[BitacoraStatistic] E
WHERE E.[BitacoraId] = (SELECT Max(B2.[BitacoraId]) FROM [Audit].[Bitacora] B2);
============================================================================================ */
begin
 Declare @b bigint;
 set @b = case @fromRoot when 1 then [Audit].[GetBitacoraRoot] (@bitacoraId) else @bitacoraId end;

 WITH [CTE_Graph] As (
  -- Ancla del nodo
 SELECT 0 as [Level],B.[ParentId] ,B.[BitacoraId]
 FROM [Audit].[Bitacora] B WITH (NOLOCK) 
 WHERE B.[BitacoraId] = @b
 -- Nodos hijo
 UNION ALL
 SELECT [Level] + 1,B.[ParentId],B.[BitacoraId]
 FROM [Audit].[Bitacora] B WITH (NOLOCK) 
 INNER JOIN [CTE_Graph] As Node ON Node.[BitacoraId] = B.[ParentId]
 )
 INSERT INTO @tableResult ([Level],[ParentId],[BitacoraId],[Item],[Name],[DateStart],[DateEnd],[TimeDuration],[DateWork]
  ,[RowsConsulted],[RowsError],[RowsInserted],[RowsUpdated] ,[RowsDeleted])
 SELECT TOP (100) PERCENT B.[Level],ISNULL(B.[ParentId],B.[BitacoraId]),B.[BitacoraId],D.[Item],D.[Name]
  ,D.[DateStart],D.[DateEnd],[Utility].[GetDurationBetweenDates] (D.[DateStart], D.[DateEnd]) [TimeDuration],D.[DateWork]
  ,D.[RowsConsulted],D.[RowsError],D.[RowsInserted],D.[RowsUpdated],D.[RowsDeleted]   
 FROM [CTE_Graph] B
 INNER JOIN [Audit].[BitacoraStatistic] D WITH (NOLOCK) ON D.[BitacoraId] = B.[BitacoraId]
 ORDER BY CASE WHEN B.[ParentId] IS NULL THEN B.[BitacoraId] ELSE B.[ParentId] END, B.[Level], B.[BitacoraId], D.[Item];

 RETURN;
END;
GO


IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Audit].[GetBitacoraStatisticTree_ByDate]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
 EXEC('CREATE FUNCTION [Audit].[GetBitacoraStatisticTree_ByDate](@dateStart nvarchar(10), @dateEnd nvarchar(10))
RETURNS @tableResult TABLE 
(
     [Id] [int] IDENTITY(1, 1) PRIMARY KEY
	,[Level] [int]
	,[ParentId] [bigint]
	,[BitacoraId] [bigint]
	,[Item] [bigint]
	,[Name] [nvarchar](128)
	,[DateStart] [datetime]
	,[DateEnd] [datetime]
    ,[TimeDuration] [nvarchar](30)
	,[DateWork] [datetime]
	,[RowsConsulted] [bigint]
	,[RowsError] [bigint]
	,[RowsInserted] [bigint]
	,[RowsUpdated] [bigint] 
	,[RowsDeleted] [bigint]
) 
AS
BEGIN
 RETURN;
END');
GO

ALTER FUNCTION [Audit].[GetBitacoraStatisticTree_ByDate](@dateStart nvarchar(10), @dateEnd nvarchar(10))
RETURNS @tableResult TABLE 
(
     [Id] [int] IDENTITY(1, 1) PRIMARY KEY
	,[Level] [int]
	,[ParentId] [bigint]
	,[BitacoraId] [bigint]
	,[Item] [bigint]
	,[Name] [nvarchar](128)
	,[DateStart] [datetime]
	,[DateEnd] [datetime]
    ,[TimeDuration] [nvarchar](30)
	,[DateWork] [datetime]
	,[RowsConsulted] [bigint]
	,[RowsError] [bigint]
	,[RowsInserted] [bigint]
	,[RowsUpdated] [bigint] 
	,[RowsDeleted] [bigint]
) 
As
/* ============================================================================================
Proposito: Retorna arbol de ejecucion en un rango de fechas, de la tabla: [Audit].[BitacoraStatistic].
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2016-07-25
Fecha actualizacion: 2016-07-25

Parametros:
 @dateStart: Fecha inicial en formato: YYYY-MM-DD.
 @dateEnd: Fecha final en formato: YYYY-MM-DD.

Ejemplo:
SELECT * FROM [Audit].[GetBitacoraStatisticTree_ByDate]('2018-01-01', '2018-02-01');

SELECT E.* From [Audit].[BitacoraStatistic] E
WHERE E.[BitacoraId] = (SELECT Max(B2.[BitacoraId]) FROM [Audit].[Bitacora] B2);
============================================================================================ */
begin
 Declare @dtDateStart date, @dtDateEnd date, @dtTempo date;

 if ( (@dateStart IS NULL OR RTrim(@dateStart) = '') OR (@dateEnd IS NULL OR RTrim(@dateEnd) = '') )
 begin
  RETURN; 
 end
 else
 begin
  set @dtDateStart = convert(date, @dateStart, 120);
  set @dtDateEnd = convert(date, @dateEnd, 120);

  if (@dtDateEnd < @dtDateStart)
  begin
   set @dtTempo = @dtDateStart;
   set @dtDateStart = @dtDateEnd;
   set @dtDateEnd = @dtTempo;
  end; 
 end;

 WITH [CTE_Graph] as (
  -- Ancla del nodo
 SELECT 0 as [Level],B.[ParentId],B.[BitacoraId]
 FROM [Audit].[Bitacora] B WITH (NOLOCK) 
 WHERE (B.[DateStart] >= @dtDateStart AND B.[DateStart] < @dtDateEnd)
 -- Nodos hijo
 UNION ALL
 SELECT [Level] + 1,B.[ParentId],B.[BitacoraId]
 FROM [Audit].[Bitacora] B WITH (NOLOCK) 
 INNER JOIN [CTE_Graph] As Node ON Node.[BitacoraId] = B.[ParentId]
 )
 INSERT INTO @tableResult ([Level],[ParentId],[BitacoraId],[Item],[Name],[DateStart],[DateEnd],[TimeDuration],[DateWork]
  ,[RowsConsulted],[RowsError],[RowsInserted],[RowsUpdated] ,[RowsDeleted])
 SELECT TOP (100) PERCENT B.[Level],ISNULL(B.[ParentId],B.[BitacoraId]),B.[BitacoraId],D.[Item],D.[Name]
  ,D.[DateStart],D.[DateEnd],[Utility].[GetDurationBetweenDates] (D.[DateStart], D.[DateEnd]) [TimeDuration]
  ,D.[DateWork],D.[RowsConsulted],D.[RowsError],D.[RowsInserted],D.[RowsUpdated],D.[RowsDeleted]   
 FROM [CTE_Graph] B
 INNER JOIN [Audit].[BitacoraStatistic] D WITH (NOLOCK) ON D.[BitacoraId] = B.[BitacoraId]
 ORDER BY CASE WHEN B.[ParentId] IS NULL THEN B.[BitacoraId] ELSE B.[ParentId] END, B.[Level], B.[BitacoraId], D.[Item];

 RETURN;
END;
GO


IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Audit].[GetBitacoraTableTree]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
 EXEC('CREATE FUNCTION [Audit].[GetBitacoraTableTree](@bitacoraId bigint, @fromRoot bit = 0)
RETURNS @tableResult TABLE 
(
     [Id] [int] IDENTITY(1, 1) PRIMARY KEY
	,[Level] [int]
	,[ParentId] [bigint]
	,[BitacoraId] [bigint]
	,[Item] [bigint]
	,[Name] [nvarchar](128)
	,[StateId] [tinyint]
	,[State] [nvarchar](50)
	,[SeverityId] [tinyint]
	,[TypeId] [smallint]
	,[Type] [nvarchar](50)
	,[DateRun] [datetime]
	,[DateWork] [datetime]
	,[TableTarget] [nvarchar](128)
	,[FieldTarget] [nvarchar](50)
	,[ValueTarget] [nvarchar](128)
	,[TableSource] [nvarchar](128)
	,[FieldSource] [nvarchar](50)
	,[ValueSource] [nvarchar](128)
	,[PKField1] [nvarchar](50)
	,[PKValue1] [nvarchar](128)
	,[PKField2] [nvarchar](50)
	,[PKValue2] [nvarchar](128)
	,[PKField3] [nvarchar](50)
	,[PKValue3] [nvarchar](128)
	,[PKField4] [nvarchar](50)
	,[PKValue4] [nvarchar](128)
	,[PKField5] [nvarchar](50)
	,[PKValue5] [nvarchar](128)
	,[Message] [nvarchar](4000)
) 
AS
BEGIN
 RETURN;
END');
GO

ALTER FUNCTION [Audit].[GetBitacoraTableTree](
 @bitacoraId bigint
,@fromRoot bit = 0
)
RETURNS @tableResult TABLE 
(
     [Id] [int] IDENTITY(1, 1) PRIMARY KEY
	,[Level] [int]
	,[ParentId] [bigint]
	,[BitacoraId] [bigint]
	,[Item] [bigint]
	,[Name] [nvarchar](128)
	,[StateId] [tinyint]
	,[State] [nvarchar](50)
	,[SeverityId] [tinyint]
	,[TypeId] [smallint]
	,[Type] [nvarchar](50)
	,[DateRun] [datetime]
	,[DateWork] [datetime]
	,[TableTarget] [nvarchar](128)
	,[FieldTarget] [nvarchar](50)
	,[ValueTarget] [nvarchar](128)
	,[TableSource] [nvarchar](128)
	,[FieldSource] [nvarchar](50)
	,[ValueSource] [nvarchar](128)
	,[PKField1] [nvarchar](50)
	,[PKValue1] [nvarchar](128)
	,[PKField2] [nvarchar](50)
	,[PKValue2] [nvarchar](128)
	,[PKField3] [nvarchar](50)
	,[PKValue3] [nvarchar](128)
	,[PKField4] [nvarchar](50)
	,[PKValue4] [nvarchar](128)
	,[PKField5] [nvarchar](50)
	,[PKValue5] [nvarchar](128)
	,[Message] [nvarchar](4000)
) 
As
/* ============================================================================================
Proposito: Retorna arbol de ejecucion debajo del nodo especificado: subarbol desde el nodo actual (nodo actual y sus hijos) o el arbol completo,
 de la tabla: [Audit].[BitacoraTable].
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2016-04-01
Fecha actualizacion: 2016-06-24

Parametros:
 @bitacoraId: Código de bitacora.
 @fromRoot: Indica si retorna una parte o el arbol completo:
  0: Retorna el subarbol desde el nodo actual (nodo actual y sus hijos).
  1: Retorna el arbol completo.

Ejemplo:
SELECT * FROM [Audit].[GetBitacoraTableTree]((SELECT Max([BitacoraId]) FROM [Audit].[Bitacora]), 1);

SELECT * FROM [Audit].[GetBitacoraTableTree](5, 0);
SELECT * FROM [Audit].[GetBitacoraTableTree](5, 1);

SELECT E.[StateId], E.[Name], T.* 
FROM [Audit].[BitacoraTable] T
INNER JOIN [Audit].[BitacoraState] E ON T.[StateId] = E.[StateId]
WHERE T.[BitacoraId] > 21
WHERE T.[BitacoraId] = (SELECT Max(B2.[BitacoraId]) FROM [Audit].[Bitacora] B2);
============================================================================================ */
begin
 Declare @b bigint;
 set @b = case @fromRoot when 1 then [Audit].[GetBitacoraRoot] (@bitacoraId) else @bitacoraId end;

 WITH [CTE_Graph] As (
  -- Ancla del nodo
 SELECT 0 as [Level],B.[ParentId],B.[BitacoraId]
 FROM [Audit].[Bitacora] B WITH (NOLOCK) 
 WHERE B.[BitacoraId] = @b
 -- Nodos hijo
 UNION ALL
 SELECT [Level] + 1,B.[ParentId],B.[BitacoraId] 
 FROM [Audit].[Bitacora] B WITH (NOLOCK) 
 INNER JOIN [CTE_Graph] As Node ON Node.[BitacoraId] = B.[ParentId]
 )
 INSERT INTO @tableResult ([Level],[ParentId],[BitacoraId],[Item],[Name],[StateId],[State],[SeverityId],[TypeId],[Type],[DateRun],[DateWork]
  ,[TableTarget],[FieldTarget],[ValueTarget],[TableSource],[FieldSource],[ValueSource],[PKField1],[PKValue1]
  ,[PKField2],[PKValue2],[PKField3],[PKValue3],[PKField4],[PKValue4],[PKField5],[PKValue5],[Message])
 SELECT TOP (100) PERCENT B.[Level],ISNULL(B.[ParentId],B.[BitacoraId]),B.[BitacoraId],D.[Item],D.[Name],D.[StateId],E.[Name] [State],D.[SeverityId]
 ,D.[TypeId], BT.[Name] [Type]
 ,D.[DateRun],D.[DateWork],D.[TableTarget],D.[FieldTarget],D.[ValueTarget],D.[TableSource],D.[FieldSource],D.[ValueSource],D.[PKField1],D.[PKValue1]
 ,D.[PKField2],D.[PKValue2],D.[PKField3],D.[PKValue3],D.[PKField4],D.[PKValue4],D.[PKField5],D.[PKValue5],D.[Message]
 FROM [CTE_Graph] B
 INNER JOIN [Audit].[BitacoraTable] D WITH (NOLOCK) ON D.[BitacoraId] = B.[BitacoraId]
 LEFT JOIN [Audit].[BitacoraState] E WITH (NOLOCK) ON E.[StateId] = D.[StateId]
 LEFT JOIN [Audit].[BitacoraType] BT WITH (NOLOCK) ON BT.[TypeId] = D.[TypeId]
 ORDER BY CASE WHEN B.[ParentId] IS NULL THEN B.[BitacoraId] ELSE B.[ParentId] END, B.[Level], B.[BitacoraId], D.[Item];

 RETURN;
END;
GO


IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Audit].[GetBitacoraTableTree_ByDate]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
 EXEC('CREATE FUNCTION [Audit].[GetBitacoraTableTree_ByDate](@dateStart nvarchar(10), @dateEnd nvarchar(10))
RETURNS @tableResult TABLE 
(
     [Id] [int] IDENTITY(1, 1) PRIMARY KEY
	,[Level] [int]
	,[ParentId] [bigint]
	,[BitacoraId] [bigint]
	,[Item] [bigint]
	,[Name] [nvarchar](128)
	,[StateId] [tinyint]
	,[State] [nvarchar](50)
	,[SeverityId] [tinyint]
	,[TypeId] [smallint]
	,[Type] [nvarchar](50)
	,[DateRun] [datetime]
	,[DateWork] [datetime]
	,[TableTarget] [nvarchar](128)
	,[FieldTarget] [nvarchar](50)
	,[ValueTarget] [nvarchar](128)
	,[TableSource] [nvarchar](128)
	,[FieldSource] [nvarchar](50)
	,[ValueSource] [nvarchar](128)
	,[PKField1] [nvarchar](50)
	,[PKValue1] [nvarchar](128)
	,[PKField2] [nvarchar](50)
	,[PKValue2] [nvarchar](128)
	,[PKField3] [nvarchar](50)
	,[PKValue3] [nvarchar](128)
	,[PKField4] [nvarchar](50)
	,[PKValue4] [nvarchar](128)
	,[PKField5] [nvarchar](50)
	,[PKValue5] [nvarchar](128)
	,[Message] [nvarchar](4000)
) 
AS
BEGIN
 RETURN;
END');
GO

ALTER FUNCTION [Audit].[GetBitacoraTableTree_ByDate](@dateStart nvarchar(10), @dateEnd nvarchar(10))
RETURNS @tableResult TABLE 
(
     [Id] [int] IDENTITY(1, 1) PRIMARY KEY
	,[Level] [int]
	,[ParentId] [bigint]
	,[BitacoraId] [bigint]
	,[Item] [bigint]
	,[Name] [nvarchar](128)
	,[StateId] [tinyint]
	,[State] [nvarchar](50)
	,[SeverityId] [tinyint]
	,[TypeId] [smallint]
	,[Type] [nvarchar](50)
	,[DateRun] [datetime]
	,[DateWork] [datetime]
	,[TableTarget] [nvarchar](128)
	,[FieldTarget] [nvarchar](50)
	,[ValueTarget] [nvarchar](128)
	,[TableSource] [nvarchar](128)
	,[FieldSource] [nvarchar](50)
	,[ValueSource] [nvarchar](128)
	,[PKField1] [nvarchar](50)
	,[PKValue1] [nvarchar](128)
	,[PKField2] [nvarchar](50)
	,[PKValue2] [nvarchar](128)
	,[PKField3] [nvarchar](50)
	,[PKValue3] [nvarchar](128)
	,[PKField4] [nvarchar](50)
	,[PKValue4] [nvarchar](128)
	,[PKField5] [nvarchar](50)
	,[PKValue5] [nvarchar](128)
	,[Message] [nvarchar](4000)
) 
As
/* ============================================================================================
Proposito: Retorna arbol de ejecucion en un rango de fechas, de la tabla: [Audit].[BitacoraTable].
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2016-04-01
Fecha actualizacion: 2016-06-24

Parametros:
 @dateStart: Fecha inicial en formato: YYYY-MM-DD.
 @dateEnd: Fecha final en formato: YYYY-MM-DD.

Ejemplo:
SELECT * FROM [Audit].[GetBitacoraTableTree_ByDate]('2018-01-01', '2018-02-01');

SELECT E.[StateId], E.[Name], T.* 
FROM [Audit].[BitacoraTable] T
INNER JOIN [Audit].[BitacoraState] E ON T.[StateId] = E.[StateId]
WHERE T.[BitacoraId] > 21
WHERE T.[BitacoraId] = (SELECT Max(B2.[BitacoraId]) FROM [Audit].[Bitacora] B2);
============================================================================================ */
begin
 Declare @dtDateStart date, @dtDateEnd date, @dtTempo date;

 if ( (@dateStart IS NULL OR RTrim(@dateStart) = '') OR (@dateEnd IS NULL OR RTrim(@dateEnd) = '') )
 begin
  RETURN; 
 end
 else
 begin
  set @dtDateStart = convert(date, @dateStart, 120);
  set @dtDateEnd = convert(date, @dateEnd, 120);

  if (@dtDateEnd < @dtDateStart)
  begin
   set @dtTempo = @dtDateStart;
   set @dtDateStart = @dtDateEnd;
   set @dtDateEnd = @dtTempo;
  end; 
 end;

 WITH [CTE_Graph] as (
  -- Ancla del nodo
 SELECT 0 as [Level],B.[ParentId],B.[BitacoraId]
 FROM [Audit].[Bitacora] B WITH (NOLOCK) 
 WHERE (B.[DateStart] >= @dtDateStart AND B.[DateStart] < @dtDateEnd)
 -- Nodos hijo
 UNION ALL
 SELECT [Level] + 1,B.[ParentId],B.[BitacoraId]
 FROM [Audit].[Bitacora] B WITH (NOLOCK) 
 INNER JOIN [CTE_Graph] As Node ON Node.[BitacoraId] = B.[ParentId]
 )
 INSERT INTO @tableResult ([Level],[ParentId],[BitacoraId],[Item],[Name],[StateId],[State],[SeverityId],[TypeId],[Type],[DateRun],[DateWork]
  ,[TableTarget],[FieldTarget],[ValueTarget],[TableSource],[FieldSource],[ValueSource],[PKField1],[PKValue1]
  ,[PKField2],[PKValue2],[PKField3],[PKValue3],[PKField4],[PKValue4],[PKField5],[PKValue5],[Message])
 SELECT TOP (100) PERCENT B.[Level],ISNULL(B.[ParentId],B.[BitacoraId]),B.[BitacoraId],D.[Item],D.[Name],D.[StateId],E.[Name] [State]
 ,D.[SeverityId],D.[TypeId], BT.[Name] [Type]
 ,D.[DateRun],D.[DateWork],D.[TableTarget],D.[FieldTarget],D.[ValueTarget],D.[TableSource],D.[FieldSource],D.[ValueSource],D.[PKField1],D.[PKValue1]
 ,D.[PKField2],D.[PKValue2],D.[PKField3],D.[PKValue3],D.[PKField4],D.[PKValue4],D.[PKField5],D.[PKValue5],D.[Message]
 FROM [CTE_Graph] B
 INNER JOIN [Audit].[BitacoraTable] D WITH (NOLOCK) ON D.[BitacoraId] = B.[BitacoraId]
 LEFT JOIN [Audit].[BitacoraState] E WITH (NOLOCK) ON E.[StateId] = D.[StateId]
 LEFT JOIN [Audit].[BitacoraType] BT WITH (NOLOCK) ON BT.[TypeId] = D.[TypeId]
 ORDER BY CASE WHEN B.[ParentId] IS NULL THEN B.[BitacoraId] ELSE B.[ParentId] END, B.[Level], B.[BitacoraId], D.[Item];

 RETURN;
END;
GO


IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Audit].[GetBitacoraTree]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
 EXEC('CREATE FUNCTION [Audit].[GetBitacoraTree](@bitacoraId bigint, @fromRoot bit = 0)
RETURNS @tableResult TABLE 
(
     [Id] [int] IDENTITY(1, 1) PRIMARY KEY
	,[Level] [int]
	,[ParentId] [bigint]
	,[BitacoraId] [bigint]
	,[AppId] [nvarchar](12)
	,[ModuleId] [int]
	,[Name] [nvarchar](128)
	,[StateId] [tinyint]
	,[State] [nvarchar](50)
	,[DateStart] [datetime]
	,[DateEnd] [datetime]
    ,[TimeDuration] [nvarchar](30)
	,[DateWorkStart] [datetime]
	,[DateWorkEnd] [datetime]
	,[ProcessId] [bigint]
	,[ProcessStringId] [nvarchar](20)
	,[UserId] [int]
	,[MachineId] [nvarchar](100)
	,[FailureTask] [nvarchar](128)
	,[Message] [nvarchar](max)
) 
AS
BEGIN
 RETURN;
END');
GO

ALTER FUNCTION [Audit].[GetBitacoraTree](
 @bitacoraId bigint
,@fromRoot bit = 0
)
RETURNS @tableResult TABLE 
(
     [Id] [int] IDENTITY(1, 1) PRIMARY KEY
	,[Level] [int]
	,[ParentId] [bigint]
	,[BitacoraId] [bigint]
	,[AppId] [nvarchar](12)
	,[ModuleId] [int]
	,[Name] [nvarchar](128)
	,[StateId] [tinyint]
	,[State] [nvarchar](50)
	,[DateStart] [datetime]
	,[DateEnd] [datetime]
    ,[TimeDuration] [nvarchar](30)
	,[DateWorkStart] [datetime]
	,[DateWorkEnd] [datetime]
	,[ProcessId] [bigint]
	,[ProcessStringId] [nvarchar](20)
	,[UserId] [int]
	,[MachineId] [nvarchar](100)
	,[FailureTask] [nvarchar](128)
	,[Message] [nvarchar](max)
) 
As
/* ============================================================================================
Proposito: Retorna arbol de ejecucion debajo del nodo especificado: subarbol desde el nodo actual (nodo actual y sus hijos) o el arbol completo,
 de la tabla: [Audit].[Bitacora].
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2016-04-01
Fecha actualizacion: 2016-06-24

Parametros:
 @bitacoraId: Código de bitacora.
 @fromRoot: Indica si retorna una parte o el arbol completo:
  0: Retorna el subarbol desde el nodo actual (nodo actual y sus hijos).
  1: Retorna el arbol completo.

Ejemplo:
SELECT * FROM [Audit].[GetBitacoraTree]((SELECT Max([BitacoraId]) FROM [Audit].[Bitacora]), 1);

SELECT * FROM [Audit].[GetBitacoraTree](5, 0);
SELECT * FROM [Audit].[GetBitacoraTree](5, 1);

SELECT * FROM [Audit].[Bitacora] ORDER BY [BitacoraId] DESC;
============================================================================================ */
begin
 Declare @b bigint;
 set @b = case @fromRoot when 1 then [Audit].[GetBitacoraRoot] (@bitacoraId) else @bitacoraId end;

 WITH [CTE_Graph] As (
  -- Ancla del nodo
 SELECT 0 as [Level],[ParentId],[BitacoraId],[AppId],[ModuleId],[Name],[StateId],[DateStart],[DateEnd],[DateWorkStart],[DateWorkEnd]
 ,[ProcessId],[ProcessStringId],[UserId],[MachineId],[FailureTask],[Message] 
 FROM [Audit].[Bitacora] WITH (NOLOCK) 
 WHERE [BitacoraId] = @b
 -- Nodos hijo
 UNION ALL
 SELECT [Level] + 1, leaf.[ParentId],leaf.[BitacoraId],leaf.[AppId],leaf.[ModuleId],leaf.[Name],leaf.[StateId],leaf.[DateStart],leaf.[DateEnd],leaf.[DateWorkStart],leaf.[DateWorkEnd]
 ,leaf.[ProcessId],leaf.[ProcessStringId],leaf.[UserId],leaf.[MachineId],leaf.[FailureTask],leaf.[Message] 
 FROM [Audit].[Bitacora] as leaf WITH (NOLOCK) 
 INNER JOIN [CTE_Graph] As Node ON Node.[BitacoraId] = leaf.[ParentId]
 )
 INSERT INTO @tableResult ([Level],[ParentId],[BitacoraId],[AppId],[ModuleId],[Name],[StateId],[State],[DateStart],[DateEnd],[TimeDuration]
  ,[DateWorkStart],[DateWorkEnd],[ProcessId],[ProcessStringId],[UserId],[MachineId],[FailureTask],[Message])
 SELECT TOP (100) PERCENT B.[Level],ISNULL(B.[ParentId],B.[BitacoraId]),B.[BitacoraId],B.[AppId],B.[ModuleId],B.[Name],B.[StateId],E.[Name] [State]
  ,B.[DateStart],B.[DateEnd],[Utility].[GetDurationBetweenDates] (B.[DateStart], B.[DateEnd]) [TimeDuration]
  ,B.[DateWorkStart],B.[DateWorkEnd],B.[ProcessId],B.[ProcessStringId],B.[UserId],B.[MachineId],B.[FailureTask],B.[Message]
 FROM [CTE_Graph] B
 LEFT JOIN [Audit].[BitacoraState] E WITH (NOLOCK) ON E.[StateId] = B.[StateId]
 ORDER BY CASE WHEN B.[ParentId] IS NULL THEN B.[BitacoraId] ELSE B.[ParentId] END, B.[Level], B.[BitacoraId];

 RETURN;
END;
GO


IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Audit].[GetBitacoraTree_ByDate]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
 EXEC('CREATE FUNCTION [Audit].[GetBitacoraTree_ByDate](@dateStart nvarchar(10), @dateEnd nvarchar(10))
RETURNS @tableResult TABLE 
(
     [Id] [int] IDENTITY(1, 1) PRIMARY KEY
	,[Level] [int]
	,[ParentId] [bigint]
	,[BitacoraId] [bigint]
	,[AppId] [nvarchar](12)
	,[ModuleId] [int]
	,[Name] [nvarchar](128)
	,[StateId] [tinyint]
	,[State] [nvarchar](50)
	,[DateStart] [datetime]
	,[DateEnd] [datetime]
    ,[TimeDuration] [nvarchar](30)
	,[DateWorkStart] [datetime]
	,[DateWorkEnd] [datetime]
	,[ProcessId] [bigint]
	,[ProcessStringId] [nvarchar](20)
	,[UserId] [int]
	,[MachineId] [nvarchar](100)
	,[FailureTask] [nvarchar](128)
	,[Message] [nvarchar](max)
) 
AS
BEGIN
 RETURN;
END');
GO

ALTER FUNCTION [Audit].[GetBitacoraTree_ByDate](@dateStart nvarchar(10), @dateEnd nvarchar(10))
RETURNS @tableResult TABLE 
(
     [Id] [int] IDENTITY(1, 1) PRIMARY KEY
	,[Level] [int]
	,[ParentId] [bigint]
	,[BitacoraId] [bigint]
	,[AppId] [nvarchar](12)
	,[ModuleId] [int]
	,[Name] [nvarchar](128)
	,[StateId] [tinyint]
	,[State] [nvarchar](50)
	,[DateStart] [datetime]
	,[DateEnd] [datetime]
    ,[TimeDuration] [nvarchar](30)
	,[DateWorkStart] [datetime]
	,[DateWorkEnd] [datetime]
	,[ProcessId] [bigint]
	,[ProcessStringId] [nvarchar](20)
	,[UserId] [int]
	,[MachineId] [nvarchar](100)
	,[FailureTask] [nvarchar](128)
	,[Message] [nvarchar](max)
) 
AS
/* ============================================================================================
Proposito: Retorna arbol de ejecucion en un rango de fechas, de la tabla: [Audit].[Bitacora].
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2016-04-01
Fecha actualizacion: 2016-06-24

Parametros:
 @dateStart: Fecha inicial en formato: YYYY-MM-DD.
 @dateEnd: Fecha final en formato: YYYY-MM-DD.

Ejemplo:
SELECT * FROM [Audit].[GetBitacoraTree_ByDate]('2016-07-01', '2016-08-01');
SELECT * FROM [Audit].[GetBitacoraTree_ByDate]('2016-08-01', '2016-09-01');

SELECT * FROM [Audit].[Bitacora] ORDER BY [BitacoraId] DESC;
============================================================================================ */
begin
 Declare @dtDateStart date, @dtDateEnd date, @dtTempo date;

 if ( (@dateStart IS NULL OR RTrim(@dateStart) = '') OR (@dateEnd IS NULL OR RTrim(@dateEnd) = '') )
 begin
  RETURN; 
 end
 else
 begin
  set @dtDateStart = convert(date, @dateStart, 120);
  set @dtDateEnd = convert(date, @dateEnd, 120);

  if (@dtDateEnd < @dtDateStart)
  begin
   set @dtTempo = @dtDateStart;
   set @dtDateStart = @dtDateEnd;
   set @dtDateEnd = @dtTempo;
  end; 
 end;

 WITH [CTE_Graph] As (
	SELECT DISTINCT BT.[Level],BT.[ParentId],BT.[BitacoraId],BT.[AppId],BT.[ModuleId]
	,BT.[Name],BT.[StateId],BT.[State],BT.[DateStart],BT.[DateEnd],BT.[TimeDuration]
	,BT.[DateWorkStart],BT.[DateWorkEnd],BT.[ProcessId],BT.[ProcessStringId],BT.[UserId],BT.[MachineId],BT.[FailureTask],BT.[Message]
	FROM [Audit].[Bitacora] B WITH (NOLOCK) 
	CROSS APPLY [Audit].[GetBitacoraTree](B.[BitacoraId], 0) BT
	WHERE (B.[ParentId] IS NULL OR B.[BitacoraId] = B.[ParentId])
	AND (B.[DateStart] >= @dtDateStart AND B.[DateStart] < @dtDateEnd)
 )
 INSERT INTO @tableResult ([Level],[ParentId],[BitacoraId],[AppId],[ModuleId],[Name],[StateId],[State],[DateStart],[DateEnd],[TimeDuration]
  ,[DateWorkStart],[DateWorkEnd],[ProcessId],[ProcessStringId],[UserId],[MachineId],[FailureTask],[Message])
 SELECT TOP (100) PERCENT B.[Level],ISNULL(B.[ParentId],B.[BitacoraId]),B.[BitacoraId],B.[AppId],B.[ModuleId],B.[Name],B.[StateId],B.[State],B.[DateStart],B.[DateEnd]
  ,B.[TimeDuration],B.[DateWorkStart],B.[DateWorkEnd],B.[ProcessId],B.[ProcessStringId],B.[UserId],B.[MachineId],B.[FailureTask],B.[Message]
 FROM [CTE_Graph] B
 ORDER BY CASE WHEN B.[ParentId] IS NULL THEN B.[BitacoraId] ELSE B.[ParentId] END, B.[Level], B.[BitacoraId];

 RETURN;
END;
GO

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - End script: A11SP_Audi.sql'
PRINT '------------------------------------------------------------------------'
GO