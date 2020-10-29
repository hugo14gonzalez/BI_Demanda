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

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - Start script: A05Table_Audi.sql'
PRINT '------------------------------------------------------------------------'
GO

USE [$(DATABASE_NAME_DW)];

/* ========================================================================== 
TABLAS DE BITACORA
========================================================================== */
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Audit].[Bitacora]') AND type in (N'U'))
BEGIN
CREATE TABLE [Audit].[Bitacora](
	[BitacoraId] [bigint] IDENTITY(1,1) NOT NULL,
	[ParentId] [bigint] NULL,
	[AppId] [nvarchar](12) NOT NULL,
	[ModuleId] [int] NOT NULL,
	[Name] [nvarchar](128) NOT NULL,
	[StateId] [tinyint] NOT NULL,
	[DateStart] [datetime] NOT NULL CONSTRAINT [DF_Bitacora_DateStart] DEFAULT (GetDate()),
	[DateEnd] [datetime] NULL,
	[DateWorkStart] [datetime] NULL,
	[DateWorkEnd] [datetime] NULL,
	[ProcessId] [bigint] NULL,
	[ProcessStringId] [nvarchar](20) NULL,
	[UserId] [int] NULL,
	[MachineId] [nvarchar](100) NULL,
	[FailureTask] [nvarchar](128) NULL,
	[Message] [nvarchar](max) NULL,
 CONSTRAINT [PK_Bitacora] PRIMARY KEY CLUSTERED 
(
	[BitacoraId] ASC
) 
) 
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Audit].[Bitacora]') AND name = N'IX_Bitacora_1')
CREATE NONCLUSTERED INDEX [IX_Bitacora_1] ON [Audit].[Bitacora] 
(
	[ParentId] ASC
)
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Audit].[Bitacora]') AND name = N'IX_Bitacora_2')
CREATE NONCLUSTERED INDEX [IX_Bitacora_2] ON [Audit].[Bitacora] 
(
	[DateStart] ASC,
	[AppId] ASC,
	[ModuleId] ASC
)
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Audit].[Bitacora]') AND name = N'IX_Bitacora_3')
CREATE NONCLUSTERED INDEX [IX_Bitacora_3] ON [Audit].[Bitacora] 
(
	[DateStart] ASC,
	[Name] ASC
)
GO

IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[Audit].[CK_Bitacora_DateStart_DateEnd]') AND parent_object_id = OBJECT_ID(N'[Audit].[Bitacora]'))
ALTER TABLE [Audit].[Bitacora]  WITH CHECK ADD  CONSTRAINT [CK_Bitacora_DateStart_DateEnd] CHECK  ([DateEnd] IS NULL OR [DateEnd] >= [DateStart])
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[Audit].[CK_Bitacora_DateStart_DateEnd]') AND parent_object_id = OBJECT_ID(N'[Audit].[Bitacora]'))
ALTER TABLE [Audit].[Bitacora] CHECK CONSTRAINT [CK_Bitacora_DateStart_DateEnd]
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'Bitacora', N'COLUMN',N'BitacoraId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código de bitacora, autonumérico para identificar un registro.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'Bitacora', @level2type=N'COLUMN',@level2name=N'BitacoraId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'Bitacora', N'COLUMN',N'ParentId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código de bitacora de proceso padre (puede ser nulo).' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'Bitacora', @level2type=N'COLUMN',@level2name=N'ParentId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'Bitacora', N'COLUMN',N'AppId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código de aplicación. FK a [App].[AppSistema].' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'Bitacora', @level2type=N'COLUMN',@level2name=N'AppId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'Bitacora', N'COLUMN',N'ModuleId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código de módulo. FK a [App].[ModuleSystem].' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'Bitacora', @level2type=N'COLUMN',@level2name=N'ModuleId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'Bitacora', N'COLUMN',N'Name'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de tarea (paquete, programa, etc.).' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'Bitacora', @level2type=N'COLUMN',@level2name=N'Name'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'Bitacora', N'COLUMN',N'StateId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código de estado de bitacora.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'Bitacora', @level2type=N'COLUMN',@level2name=N'StateId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'Bitacora', N'COLUMN',N'DateStart'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha y hora de inicio de ejecucion.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'Bitacora', @level2type=N'COLUMN',@level2name=N'DateStart'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'Bitacora', N'COLUMN',N'DateEnd'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha y hora de fin de la ejecucion.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'Bitacora', @level2type=N'COLUMN',@level2name=N'DateEnd'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'Bitacora', N'COLUMN',N'DateWorkStart'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de trabajo o negocio inicio.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'Bitacora', @level2type=N'COLUMN',@level2name=N'DateWorkStart'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'Bitacora', N'COLUMN',N'DateWorkEnd'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de trabajo o negocio fin.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'Bitacora', @level2type=N'COLUMN',@level2name=N'DateWorkEnd'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'Bitacora', N'COLUMN',N'ProcessId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código de proceso, por ejemplo el código de una carga de datos.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'Bitacora', @level2type=N'COLUMN',@level2name=N'ProcessId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'Bitacora', N'COLUMN',N'ProcessStringId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código de proceso como texto, por ejemplo Guid de ejecucion de una ETL.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'Bitacora', @level2type=N'COLUMN',@level2name=N'ProcessStringId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'Bitacora', N'COLUMN',N'UserId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código del usuario que ejecuta el proceso. FK a [Security].[SecurityUser].' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'Bitacora', @level2type=N'COLUMN',@level2name=N'UserId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'Bitacora', N'COLUMN',N'MachineId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Computador desde el cual es ejecutado el proceso.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'Bitacora', @level2type=N'COLUMN',@level2name=N'MachineId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'Bitacora', N'COLUMN',N'FailureTask'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Name de la tarea donde falló la ejecucion.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'Bitacora', @level2type=N'COLUMN',@level2name=N'FailureTask'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'Bitacora', N'COLUMN',N'Message'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Mensaje de bitacora.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'Bitacora', @level2type=N'COLUMN',@level2name=N'Message'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'Bitacora', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Almacena la bitacora de ejecucion de procesos del sistema.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'Bitacora'
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Audit].[BitacoraFile]') AND type in (N'U'))
BEGIN
 CREATE TABLE [Audit].[BitacoraFile](
	[BitacoraId] [bigint] NOT NULL,
	[FileId] [bigint] IDENTITY(1,1) NOT NULL,
	[StateId] [tinyint] NOT NULL,
	[DateStart] [datetime] NOT NULL,
	[DateEnd] [datetime] NULL,
	[DateWork] [datetime] NULL,
	[DateDelete] [datetime] NULL,
	[ProcessId] [bigint] NULL,
	[Name] [nvarchar](400) NOT NULL,
	[PathSource] [nvarchar](500) NULL,
	[PathTarget] [nvarchar](500) NULL,
	[PathWithoutProcessing] [nvarchar](500) NULL,
	[PathError] [nvarchar](500) NULL,
	[PathProcessed] [nvarchar](500) NULL,
	[PathProcessed2] [nvarchar](500) NULL,
	[PathEncrypted] [nvarchar](500) NULL,
	[Message] [nvarchar](4000) NULL,
 CONSTRAINT [PK_BitacoraFile] PRIMARY KEY CLUSTERED 
(
	[BitacoraId] ASC, 
	[FileId] ASC
) 
) 
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Audit].[BitacoraFile]') AND name = N'IX_BitacoraFile_1')
CREATE NONCLUSTERED INDEX [IX_BitacoraFile_1] ON [Audit].[BitacoraFile] 
(
	[Name] ASC
) 
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Audit].[BitacoraFile]') AND name = N'IX_BitacoraFile_2')
CREATE NONCLUSTERED INDEX [IX_BitacoraFile_2] ON [Audit].[BitacoraFile] 
(
	[DateWork] ASC
)
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraFile', N'COLUMN',N'BitacoraId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo del registro de bitacora. FK a [Audit].[Bitacora].' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraFile', @level2type=N'COLUMN',@level2name=N'BitacoraId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraFile', N'COLUMN',N'FileId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código de archivo (autonumérico).' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraFile', @level2type=N'COLUMN',@level2name=N'FileId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraFile', N'COLUMN',N'StateId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código de estado de ejecucion (Exito, fallo, existente, ...). FK a [Audit].[BitacoraState].' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraFile', @level2type=N'COLUMN',@level2name=N'StateId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraFile', N'COLUMN',N'DateStart'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha y hora de inicio de ejecucion.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraFile', @level2type=N'COLUMN',@level2name=N'DateStart'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraFile', N'COLUMN',N'DateEnd'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha y hora de fin de la ejecucion.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraFile', @level2type=N'COLUMN',@level2name=N'DateEnd'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraFile', N'COLUMN',N'DateWork'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de trabajo o negocio.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraFile', @level2type=N'COLUMN',@level2name=N'DateWork'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraFile', N'COLUMN',N'DateDelete'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de borrado del archivo.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraFile', @level2type=N'COLUMN',@level2name=N'DateDelete'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraFile', N'COLUMN',N'ProcessId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código de proceso, por ejemplo el código de una carga de datos.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraFile', @level2type=N'COLUMN',@level2name=N'ProcessId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraFile', N'COLUMN',N'Name'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de archivo.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraFile', @level2type=N'COLUMN',@level2name=N'Name'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraFile', N'COLUMN',N'PathSource'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Ruta origen del archivo en disco, donde el usuario toma el archivo.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraFile', @level2type=N'COLUMN',@level2name=N'PathSource'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraFile', N'COLUMN',N'PathTarget'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Ruta destino del archivo en disco, donde descarga el archivo.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraFile', @level2type=N'COLUMN',@level2name=N'PathTarget'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraFile', N'COLUMN',N'PathWithoutProcessing'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Ruta sin procesar del archivo en disco, donde son tomados para ser procesados.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraFile', @level2type=N'COLUMN',@level2name=N'PathWithoutProcessing'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraFile', N'COLUMN',N'PathError'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Ruta error del archivo en disco, donde dejar el archivo en caso de error.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraFile', @level2type=N'COLUMN',@level2name=N'PathError'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraFile', N'COLUMN',N'PathProcessed'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Ruta procesado del archivo en disco, donde dejar el archivo después de ser procesado.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraFile', @level2type=N'COLUMN',@level2name=N'PathProcessed'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraFile', N'COLUMN',N'PathProcessed2'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Ruta 2 procesado del archivo en disco, donde dejar el archivo después de ser procesado (opcional por ejemplo como backup para auditoria).' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraFile', @level2type=N'COLUMN',@level2name=N'PathProcessed2'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraFile', N'COLUMN',N'PathEncrypted'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Ruta cifrado del archivo en disco.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraFile', @level2type=N'COLUMN',@level2name=N'PathEncrypted'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraFile', N'COLUMN',N'Message'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Mensaje de bitacora.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraFile', @level2type=N'COLUMN',@level2name=N'Message'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraFile', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Almacena informacion de auditoría de archivos. Los archivos son tomados de PathSource, pasan luego a PathTarget, si está cifrado pasa a PathEncrypted y el archivos descifrado pasa a PathWithoutProcessing, si no esta cifrado pasa a PathWithoutProcessing, si el procesamiento es exitoso pasa a PathProcessed y opcionalmente a PathProcessed2, pero si falla pasa a PathError.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraFile'
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Audit].[BitacoraDetail]') AND type in (N'U'))
BEGIN
CREATE TABLE [Audit].[BitacoraDetail](
	[BitacoraId] [bigint] NOT NULL,
	[Item] [bigint] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](128) NOT NULL,
	[StateId] [tinyint] NOT NULL,
	[SeverityId] [tinyint] NOT NULL
	 CONSTRAINT [CK_BitacoraDetail_SeverityId] CHECK ([SeverityId] <= 5),
	[TypeId] [smallint] NOT NULL,
	[DateRun] [datetime] NOT NULL,
	[DateWork] [datetime] NULL,
	[Message] [nvarchar](4000) NULL,
 CONSTRAINT [PK_BitacoraDetail] PRIMARY KEY CLUSTERED 
(
	[BitacoraId] ASC,
	[Item] ASC
) 
) 
END
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraDetail', N'COLUMN',N'BitacoraId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo del registro de bitacora. FK a [Audit].[Bitacora].' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraDetail', @level2type=N'COLUMN',@level2name=N'BitacoraId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraDetail', N'COLUMN',N'Item'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código autonumerico de inconsistencia.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraDetail', @level2type=N'COLUMN',@level2name=N'Item'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraDetail', N'COLUMN',N'Name'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre del subproceso, tabla de datos o entidad.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraDetail', @level2type=N'COLUMN',@level2name=N'Name'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraDetail', N'COLUMN',N'StateId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código de estado de ejecucion (Exito, fallo, existente, ...). FK a [Audit].[BitacoraState].' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraDetail', @level2type=N'COLUMN',@level2name=N'StateId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraDetail', N'COLUMN',N'SeverityId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nivel de severidad. 0: Informativo, 1: Advertencia, 2: Error bajo, 3: Error medio, 4: Error alto, 5: Error critico.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraDetail', @level2type=N'COLUMN',@level2name=N'SeverityId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraDetail', N'COLUMN',N'TypeId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código de tipo de inconsistencia. FK a [Audit].[BitacoraType].' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraDetail', @level2type=N'COLUMN',@level2name=N'TypeId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraDetail', N'COLUMN',N'DateRun'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de ejecucion del proceso.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraDetail', @level2type=N'COLUMN',@level2name=N'DateRun'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraDetail', N'COLUMN',N'DateWork'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de trabajo.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraDetail', @level2type=N'COLUMN',@level2name=N'DateWork'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraDetail', N'COLUMN',N'Message'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Mensaje.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraDetail', @level2type=N'COLUMN',@level2name=N'Message'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraDetail', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Almacena informacion de ejecucion de procesos.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraDetail'
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Audit].[BitacoraStatistic]') AND type in (N'U'))
BEGIN
CREATE TABLE [Audit].[BitacoraStatistic](
	[BitacoraId] [bigint] NOT NULL,
	[Item] [bigint] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](128) NOT NULL,
	[DateStart] [datetime] NOT NULL,
	[DateEnd] [datetime] NULL,
	[DateWork] [datetime] NULL,
	[RowsConsulted] [bigint] NULL,
	[RowsError] [bigint] NULL,
	[RowsInserted] [bigint] NULL,
	[RowsUpdated] [bigint] NULL,
	[RowsDeleted] [bigint] NULL,
 CONSTRAINT [PK_BitacoraStatistic] PRIMARY KEY CLUSTERED 
(
	[BitacoraId] ASC,
	[Item] ASC
) 
) 
END
GO

IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[Audit].[CK_BitacoraStatistic_DateStart_DateEnd]') AND parent_object_id = OBJECT_ID(N'[Audit].[BitacoraStatistic]'))
ALTER TABLE [Audit].[BitacoraStatistic]  WITH CHECK ADD  CONSTRAINT [CK_BitacoraStatistic_DateStart_DateEnd] CHECK  ([DateEnd] IS NULL OR [DateEnd] >= [DateStart])
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[Audit].[CK_BitacoraStatistic_DateStart_DateEnd]') AND parent_object_id = OBJECT_ID(N'[Audit].[BitacoraStatistic]'))
ALTER TABLE [Audit].[BitacoraStatistic] CHECK CONSTRAINT [CK_BitacoraStatistic_DateStart_DateEnd]
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraStatistic', N'COLUMN',N'BitacoraId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo del registro de bitacora. FK a [Audit].[Bitacora].' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraStatistic', @level2type=N'COLUMN',@level2name=N'BitacoraId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraStatistic', N'COLUMN',N'Item'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código autonumerico del registro de estadisticas.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraStatistic', @level2type=N'COLUMN',@level2name=N'Item'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraStatistic', N'COLUMN',N'Name'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre del subproceso, por ejemplo: nombre de tabla o nombre de metodo.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraStatistic', @level2type=N'COLUMN',@level2name=N'Name'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraStatistic', N'COLUMN',N'DateStart'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha y hora de inicio de ejecucion.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraStatistic', @level2type=N'COLUMN',@level2name=N'DateStart'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraStatistic', N'COLUMN',N'DateEnd'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha y hora de fin de la ejecucion.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraStatistic', @level2type=N'COLUMN',@level2name=N'DateEnd'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraStatistic', N'COLUMN',N'DateWork'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de trabajo o negocio.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraStatistic', @level2type=N'COLUMN',@level2name=N'DateWork'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraStatistic', N'COLUMN',N'RowsConsulted'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Número de filas consultadas.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraStatistic', @level2type=N'COLUMN',@level2name=N'RowsConsulted'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraStatistic', N'COLUMN',N'RowsError'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Número de filas con error.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraStatistic', @level2type=N'COLUMN',@level2name=N'RowsError'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraStatistic', N'COLUMN',N'RowsInserted'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Número de filas insertadas.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraStatistic', @level2type=N'COLUMN',@level2name=N'RowsInserted'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraStatistic', N'COLUMN',N'RowsUpdated'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Número de filas actualizadas.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraStatistic', @level2type=N'COLUMN',@level2name=N'RowsUpdated'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraStatistic', N'COLUMN',N'RowsDeleted'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Número de filas borradas.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraStatistic', @level2type=N'COLUMN',@level2name=N'RowsDeleted'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraStatistic', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Almacena estadisticas de ejecucion como tiempo de ejecucion, filas procesadas y filas con error.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraStatistic'
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Audit].[BitacoraState]') AND type in (N'U'))
BEGIN
CREATE TABLE [Audit].[BitacoraState](
	[StateId] [tinyint] NOT NULL,
	[Name] [nvarchar](50) NOT NULL
 CONSTRAINT [PK_BitacoraState] PRIMARY KEY CLUSTERED 
(
	[StateId] ASC
) 
) 
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Audit].[BitacoraState]') AND name = N'UX_BitacoraState_1')
CREATE UNIQUE NONCLUSTERED INDEX [UX_BitacoraState_1] ON [Audit].[BitacoraState] 
(
	[Name] ASC
) 
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraState', N'COLUMN',N'StateId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código de estado.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraState', @level2type=N'COLUMN',@level2name=N'StateId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraState', N'COLUMN',N'Name'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de estado.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraState', @level2type=N'COLUMN',@level2name=N'Name'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraState', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Almacena estados para las tablas de bitacora.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraState'
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Audit].[BitacoraTable]') AND type in (N'U'))
BEGIN
CREATE TABLE [Audit].[BitacoraTable](
	[BitacoraId] [bigint] NOT NULL,
	[Item] [bigint] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](128) NOT NULL,
	[StateId] [tinyint] NOT NULL,
	[SeverityId] [tinyint] NOT NULL
	 CONSTRAINT [CK_BitacoraTable_SeverityId] CHECK ([SeverityId] <= 5),
	[TypeId] [smallint] NOT NULL,
	[DateRun] [datetime] NOT NULL,
	[DateWork] [datetime] NULL,
	[TableTarget] [nvarchar](128) NULL,
	[FieldTarget] [nvarchar](50) NULL,
	[ValueTarget] [nvarchar](128) NULL,
	[TableSource] [nvarchar](128) NULL,
	[FieldSource] [nvarchar](50) NULL,
	[ValueSource] [nvarchar](128) NULL,
	[PKField1] [nvarchar](50) NULL,
	[PKValue1] [nvarchar](128) NULL,
	[PKField2] [nvarchar](50) NULL,
	[PKValue2] [nvarchar](128) NULL,
	[PKField3] [nvarchar](50) NULL,
	[PKValue3] [nvarchar](128) NULL,
	[PKField4] [nvarchar](50) NULL,
	[PKValue4] [nvarchar](128) NULL,
	[PKField5] [nvarchar](50) NULL,
	[PKValue5] [nvarchar](128) NULL,
	[Message] [nvarchar](4000) NULL,
 CONSTRAINT [PK_BitacoraTable] PRIMARY KEY CLUSTERED 
(
	[BitacoraId] ASC,
	[Item] ASC
) 
) 
END
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraTable', N'COLUMN',N'BitacoraId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo del registro de bitacora. FK a [Audit].[Bitacora].' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraTable', @level2type=N'COLUMN',@level2name=N'BitacoraId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraTable', N'COLUMN',N'Item'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código autonumerico de inconsistencia.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraTable', @level2type=N'COLUMN',@level2name=N'Item'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraTable', N'COLUMN',N'Name'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre del subproceso, tabla de datos o entidad.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraTable', @level2type=N'COLUMN',@level2name=N'Name'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraTable', N'COLUMN',N'StateId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código de estado de ejecucion (Exito, fallo, existente, ...). FK a [Audit].[BitacoraState].' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraTable', @level2type=N'COLUMN',@level2name=N'StateId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraTable', N'COLUMN',N'SeverityId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nivel de severidad. 0: Informativo, 1: Advertencia, 2: Error bajo, 3: Error medio, 4: Error alto, 5: Error critico.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraTable', @level2type=N'COLUMN',@level2name=N'SeverityId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraTable', N'COLUMN',N'TypeId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código de tipo de inconsistencia. FK a [Audit].[BitacoraType].' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraTable', @level2type=N'COLUMN',@level2name=N'TypeId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraTable', N'COLUMN',N'DateRun'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de ejecucion del proceso.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraTable', @level2type=N'COLUMN',@level2name=N'DateRun'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraTable', N'COLUMN',N'DateWork'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de trabajo.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraTable', @level2type=N'COLUMN',@level2name=N'DateWork'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraTable', N'COLUMN',N'TableTarget'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabla destino.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraTable', @level2type=N'COLUMN',@level2name=N'TableTarget'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraTable', N'COLUMN',N'FieldTarget'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Campo destino.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraTable', @level2type=N'COLUMN',@level2name=N'FieldTarget'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraTable', N'COLUMN',N'ValueTarget'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Valor del campo destino.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraTable', @level2type=N'COLUMN',@level2name=N'ValueTarget'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraTable', N'COLUMN',N'TableSource'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabla origen.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraTable', @level2type=N'COLUMN',@level2name=N'TableSource'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraTable', N'COLUMN',N'FieldSource'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Campo origen.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraTable', @level2type=N'COLUMN',@level2name=N'FieldSource'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraTable', N'COLUMN',N'ValueSource'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Valor del campo origen.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraTable', @level2type=N'COLUMN',@level2name=N'ValueSource'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraTable', N'COLUMN',N'PKField1'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de campo clave primaria origen 1.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraTable', @level2type=N'COLUMN',@level2name=N'PKField1'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraTable', N'COLUMN',N'PKValue1'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Valor de campo clave primaria origen 1.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraTable', @level2type=N'COLUMN',@level2name=N'PKValue1'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraTable', N'COLUMN',N'PKField2'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de campo clave primaria origen 2.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraTable', @level2type=N'COLUMN',@level2name=N'PKField2'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraTable', N'COLUMN',N'PKValue2'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Valor de campo clave primaria origen 2.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraTable', @level2type=N'COLUMN',@level2name=N'PKValue2'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraTable', N'COLUMN',N'PKField3'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de campo clave primaria origen 3.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraTable', @level2type=N'COLUMN',@level2name=N'PKField3'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraTable', N'COLUMN',N'PKValue3'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Valor de campo clave primaria origen 3.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraTable', @level2type=N'COLUMN',@level2name=N'PKValue3'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraTable', N'COLUMN',N'PKField4'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de campo clave primaria origen 4.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraTable', @level2type=N'COLUMN',@level2name=N'PKField4'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraTable', N'COLUMN',N'PKValue4'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Valor de campo clave primaria origen 4.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraTable', @level2type=N'COLUMN',@level2name=N'PKValue4'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraTable', N'COLUMN',N'PKField5'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de campo clave primaria origen 5.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraTable', @level2type=N'COLUMN',@level2name=N'PKField5'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraTable', N'COLUMN',N'PKValue5'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Valor de campo clave primaria origen 5.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraTable', @level2type=N'COLUMN',@level2name=N'PKValue5'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraTable', N'COLUMN',N'Message'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Mensaje.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraTable', @level2type=N'COLUMN',@level2name=N'Message'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraTable', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Almacena informacion de ejecucion de procesos detallando las tablas involucradas y 5 valores de las columnas origen principales.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraTable'
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Audit].[BitacoraType]') AND type in (N'U'))
BEGIN
CREATE TABLE [Audit].[BitacoraType](
	[TypeId] [smallint] NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[Group] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](200) NOT NULL
 CONSTRAINT [PK_BitacoraType] PRIMARY KEY CLUSTERED 
(
	[TypeId] ASC
) 
) 
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Audit].[BitacoraType]') AND name = N'UX_BitacoraType_1')
CREATE UNIQUE NONCLUSTERED INDEX [UX_BitacoraType_1] ON [Audit].[BitacoraType] 
(
	[Name] ASC
)
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraType', N'COLUMN',N'TypeId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código de tipo de inconsistencia.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraType', @level2type=N'COLUMN',@level2name=N'TypeId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraType', N'COLUMN',N'Name'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de inconsistencia.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraType', @level2type=N'COLUMN',@level2name=N'Name'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraType', N'COLUMN',N'Group'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Grupo de inconsistencia, utilizado para agupar tipos.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraType', @level2type=N'COLUMN',@level2name=N'Group'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraType', N'COLUMN',N'Description'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Descripcion del tipo de inconsistencia.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraType', @level2type=N'COLUMN',@level2name=N'Description'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Audit', N'TABLE',N'BitacoraType', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Almacena tipos de inconsistencias de bitacora.' , @level0type=N'SCHEMA',@level0name=N'Audit', @level1type=N'TABLE',@level1name=N'BitacoraType'
GO

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - End script: A05Table_Audi.sql'
PRINT '------------------------------------------------------------------------'
GO