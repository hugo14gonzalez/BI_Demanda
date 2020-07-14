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
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - Start script: A04Table_UtilCube.sql'
PRINT '------------------------------------------------------------------------'
GO

USE [$(DATABASE_NAME_DW)];

/* ========================================================================== 
UTILIDADES CUBOS
========================================================================== */
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[QuerySQL]') AND type in (N'U'))
BEGIN
CREATE TABLE [Utility].[QuerySQL](
	[QueryId] [nvarchar](12) NOT NULL,
	[Name] [nvarchar](128) NOT NULL,
	[Type] [nchar](1) NOT NULL CONSTRAINT [DF_QuerySQL_Type] DEFAULT ('T')
	 CONSTRAINT [CK_QuerySQL_Type] CHECK ([Type] IN ('F', 'S', 'T', 'X')),
	[DatabaseId] [nvarchar](12) NOT NULL,
	[QuerySQL] [nvarchar](max) NOT NULL,
	[Parameters] [nvarchar](4000) NULL,
	[Description] [nvarchar](500) NULL,
 CONSTRAINT [PK_QuerySQL] PRIMARY KEY CLUSTERED 
(
	[QueryId] ASC
) 
) 
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Utility].[QuerySQL]') AND name = N'UX_QuerySQL_1')
CREATE UNIQUE NONCLUSTERED INDEX [UX_QuerySQL_1] ON [Utility].[QuerySQL] 
(
	[Name] ASC
) 
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'QuerySQL', N'COLUMN',N'QueryId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código de consulta.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'QuerySQL', @level2type=N'COLUMN',@level2name=N'QueryId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'QuerySQL', N'COLUMN',N'Name'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de consulta.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'QuerySQL', @level2type=N'COLUMN',@level2name=N'Name'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'QuerySQL', N'COLUMN',N'Type'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tipo de consulta de seleccion de datos: F: Funcion, S: Procedimiento almacenado, T: Texto (consulta a tabla o vista), X: XML.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'QuerySQL', @level2type=N'COLUMN',@level2name=N'Type'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'QuerySQL', N'COLUMN',N'DatabaseId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código de base de datos contra la cual ejecutar la consulta. Ejemplo: DW, SA, Cubo.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'QuerySQL', @level2type=N'COLUMN',@level2name=N'DatabaseId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'QuerySQL', N'COLUMN',N'QuerySQL'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Texto de consulta de seleccion de datos. si utiliza parametros, estos deben iniciar con @.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'QuerySQL', @level2type=N'COLUMN',@level2name=N'QuerySQL'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'QuerySQL', N'COLUMN',N'Parameters'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Lista de parámetros en formato de query string. Ejemplo: @value=nvarchar(max)&@length=int&@caracterPad=nchar(1). Consulte la funcion: [Utility].[GetParameters_SPFunction].' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'QuerySQL', @level2type=N'COLUMN',@level2name=N'Parameters'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'QuerySQL', N'COLUMN',N'Description'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Descripcion de la consulta.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'QuerySQL', @level2type=N'COLUMN',@level2name=N'Description'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'QuerySQL', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Almacena consultas de seleccion de datos.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'QuerySQL'
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[CubePartition]') AND type in (N'U'))
BEGIN
CREATE TABLE [Utility].[CubePartition](
	[CubeId] [nvarchar](12) NOT NULL,
	[ModelId] [nvarchar](12) NOT NULL,
	[Partitioned] [bit] NOT NULL CONSTRAINT [DF_CubePartition_Partitioned] DEFAULT (0),
	[Period] [nvarchar](12) NOT NULL CONSTRAINT [DF_CubePartition_Periodo] DEFAULT ('Ninguna')
	 CONSTRAINT [CK_CubePartition_Periodo] CHECK ([Period] IN ('Ninguna', 'Dia', 'Semana', 'Mes', 'Bimestre', 'Trimestre', 'Semestre', 'Año')),
	[PrefixPartition] [nvarchar](128) NOT NULL,
	[DataSource] [nvarchar](128) NOT NULL,
	[QueryId] [nvarchar](12) NOT NULL,
	[PartitionField] [nvarchar](128) NOT NULL,
	[UsePathBefore] [bit] NULL CONSTRAINT [DF_CubePartition_UsePathBefore] DEFAULT (1),
	[StoragePath] [nvarchar](500) NOT NULL,
 CONSTRAINT [PK_CubePartition] PRIMARY KEY CLUSTERED 
(
	[CubeId] ASC,
	[ModelId] ASC
) 
) 
END
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'CubePartition', N'COLUMN',N'CubeId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código de cubo. FK a [Utility].[CubeSystem].' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'CubePartition', @level2type=N'COLUMN',@level2name=N'CubeId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'CubePartition', N'COLUMN',N'ModelId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código de modelo. FK a [Utility].[ModelSystem].' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'CubePartition', @level2type=N'COLUMN',@level2name=N'ModelId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'CubePartition', N'COLUMN',N'Partitioned'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Indica si el grupo de medidas esta Partitioned.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'CubePartition', @level2type=N'COLUMN',@level2name=N'Partitioned'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'CubePartition', N'COLUMN',N'Period'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Periodo de tiempo para partir los datos: Ninguna, Dia, Semana, Mes, Bimestre, Trimestre, Semestre, Año.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'CubePartition', @level2type=N'COLUMN',@level2name=N'Period'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'CubePartition', N'COLUMN',N'PrefixPartition'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Prefijo para Create nombre de particiones.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'CubePartition', @level2type=N'COLUMN',@level2name=N'PrefixPartition'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'CubePartition', N'COLUMN',N'DataSource'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Origen de datos del modelo. Por ejemplo la propiedad id data source de un grupo de metricas de un cubo de datos.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'CubePartition', @level2type=N'COLUMN',@level2name=N'DataSource'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'CubePartition', N'COLUMN',N'QueryId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código de consulta de selección de datos. FK a [Utility].[QuerySQL].' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'CubePartition', @level2type=N'COLUMN',@level2name=N'QueryId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'CubePartition', N'COLUMN',N'PartitionField'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre del campo de la consulta de selección de datos por la cual realizar la partición de los datos.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'CubePartition', @level2type=N'COLUMN',@level2name=N'PartitionField'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'CubePartition', N'COLUMN',N'UsePathBefore'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Si es verdadero utilizar la ruta de la particion anterior, de lo contrario utiliza la ruta especificada en el campo: StoragePath.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'CubePartition', @level2type=N'COLUMN',@level2name=N'UsePathBefore'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'CubePartition', N'COLUMN',N'StoragePath'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Ruta de almacenamiento en disco. Si no es especificada utiliza la ruta por defecto en las carpetas de instalación del servidor.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'CubePartition', @level2type=N'COLUMN',@level2name=N'StoragePath'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'CubePartition', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Almacena la forma de partir los datos de grupos de medidas de los cubos de datos.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'CubePartition'
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[CubePartitionDetail]') AND type in (N'U'))
BEGIN
CREATE TABLE [Utility].[CubePartitionDetail](
	[CubeId] [nvarchar](12) NOT NULL,
	[ModelId] [nvarchar](12) NOT NULL,
	[PartitionId] [nvarchar](12) NOT NULL,
	[PartitionName] [nvarchar](200) NOT NULL,
	[PartitionNameBefore] [nvarchar](200) NOT NULL,
	[DatePartition] [date] NOT NULL,
	[DateStart] [date] NOT NULL,
	[DateEnd] [date] NULL,
	[UsePathBefore] [bit] NOT NULL CONSTRAINT [DF_CubePartitionDetail_UsePathBefore] DEFAULT (1),
	[StoragePath] [nvarchar](500) NULL,
	[IsFirstPartition] [bit] NOT NULL CONSTRAINT [DF_CubePartitionDetail_IsFirstPartition] DEFAULT (0),
	[IsLastPartition] [bit] NOT NULL CONSTRAINT [DF_CubePartitionDetail_IsLastPartition] DEFAULT (0),
	[Create] [bit] NOT NULL CONSTRAINT [DF_CubePartitionDetail_Create] DEFAULT (1),
	[Update] [bit] NOT NULL CONSTRAINT [DF_CubePartitionDetail_Actualizar] DEFAULT (0),
	[Process] [bit] NOT NULL CONSTRAINT [DF_CubePartitionDetail_Procesar] DEFAULT (1),
	[CreateBitacoraId] [bigint] NULL,
	[ProcessBitacoraId] [bigint] NULL,
 CONSTRAINT [PK_CubePartitionDetail] PRIMARY KEY CLUSTERED 
(
	[CubeId] ASC,
	[ModelId] ASC,
	[PartitionId] ASC
) 
) 
END
GO

IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[Utility].[CK_CubePartitionDetail_DateStart_DateEnd]') AND parent_object_id = OBJECT_ID(N'[Utility].[CubePartitionDetail]'))
ALTER TABLE [Utility].[CubePartitionDetail]  WITH CHECK ADD  CONSTRAINT [CK_CubePartitionDetail_DateStart_DateEnd] CHECK  ([DateEnd] IS NULL OR [DateEnd] >= [DateStart])
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[Utility].[CK_CubePartitionDetail_DateStart_DateEnd]') AND parent_object_id = OBJECT_ID(N'[Utility].[CubePartitionDetail]'))
ALTER TABLE [Utility].[CubePartitionDetail] CHECK CONSTRAINT [CK_CubePartitionDetail_DateStart_DateEnd]
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'CubePartitionDetail', N'COLUMN',N'CubeId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código de cubo. FK a [Utility].[CubePartition].' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'CubePartitionDetail', @level2type=N'COLUMN',@level2name=N'CubeId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'CubePartitionDetail', N'COLUMN',N'ModelId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código de modelo. FK a [Utility].[CubePartition].' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'CubePartitionDetail', @level2type=N'COLUMN',@level2name=N'ModelId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'CubePartitionDetail', N'COLUMN',N'PartitionId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código de partición.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'CubePartitionDetail', @level2type=N'COLUMN',@level2name=N'PartitionId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'CubePartitionDetail', N'COLUMN',N'PartitionName'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de partición, propiedad id de partición en el cubo.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'CubePartitionDetail', @level2type=N'COLUMN',@level2name=N'PartitionName'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'CubePartitionDetail', N'COLUMN',N'PartitionNameBefore'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de partición anterior, propiedad id de partición en el cubo.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'CubePartitionDetail', @level2type=N'COLUMN',@level2name=N'PartitionNameBefore'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'CubePartitionDetail', N'COLUMN',N'DatePartition'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha que representa la partición, generalmente es igual a [DateStart], pero para la primera particion es un periodo menor.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'CubePartitionDetail', @level2type=N'COLUMN',@level2name=N'DatePartition'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'CubePartitionDetail', N'COLUMN',N'DateStart'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha inicio de seleccion de datos de partición. El valor es igual para la primera y segunda particion.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'CubePartitionDetail', @level2type=N'COLUMN',@level2name=N'DateStart'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'CubePartitionDetail', N'COLUMN',N'DateEnd'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha fin de seleccion de datos de partición. Para la ultima particion es nulo.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'CubePartitionDetail', @level2type=N'COLUMN',@level2name=N'DateEnd'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'CubePartitionDetail', N'COLUMN',N'UsePathBefore'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Si es verdadero utilizar la ruta de la particion anterior, de lo contrario utiliza la ruta especificada en el campo: StoragePath.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'CubePartitionDetail', @level2type=N'COLUMN',@level2name=N'UsePathBefore'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'CubePartitionDetail', N'COLUMN',N'StoragePath'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Ruta de almacenamiento en disco. Si no es especificada utiliza la ruta por defecto en las carpetas de instalación del servidor.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'CubePartitionDetail', @level2type=N'COLUMN',@level2name=N'StoragePath'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'CubePartitionDetail', N'COLUMN',N'IsFirstPartition'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Inidica si esta es la primera partición. Utilizado para Create el filtro de la consulta de particionamiento.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'CubePartitionDetail', @level2type=N'COLUMN',@level2name=N'IsFirstPartition'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'CubePartitionDetail', N'COLUMN',N'IsLastPartition'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Inidica si esta es la ultima partición.  Utilizado para Create el filtro de la consulta de particionamiento.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'CubePartitionDetail', @level2type=N'COLUMN',@level2name=N'IsLastPartition'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'CubePartitionDetail', N'COLUMN',N'Create'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Inidica si la partición requiere ser creada.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'CubePartitionDetail', @level2type=N'COLUMN',@level2name=N'Create'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'CubePartitionDetail', N'COLUMN',N'Update'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Inidica si la partición ya fue creada y requiere actualizacion.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'CubePartitionDetail', @level2type=N'COLUMN',@level2name=N'Update'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'CubePartitionDetail', N'COLUMN',N'Process'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Inidica si la partición requiere procesar.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'CubePartitionDetail', @level2type=N'COLUMN',@level2name=N'Process'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'CubePartitionDetail', N'COLUMN',N'CreateBitacoraId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código de bitacora de creacion de la partición o el registro en la tabla.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'CubePartitionDetail', @level2type=N'COLUMN',@level2name=N'CreateBitacoraId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'CubePartitionDetail', N'COLUMN',N'ProcessBitacoraId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código de bitacora de procesamiento de la partición.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'CubePartitionDetail', @level2type=N'COLUMN',@level2name=N'ProcessBitacoraId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'CubePartitionDetail', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Almacena los rangos de fecha de las particiones de los grupos de medidas de modelos.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'CubePartitionDetail'
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[CubeSystem]') AND type in (N'U'))
BEGIN
CREATE TABLE [Utility].[CubeSystem](
	[CubeId] [nvarchar](12) NOT NULL,
	[Name] [nvarchar](128) NOT NULL,
	[AppName] [nvarchar](128) NOT NULL,
	[Database] [nvarchar](128) NOT NULL,
	[Description] [nvarchar](500) NOT NULL,
 CONSTRAINT [PK_CubeSystem] PRIMARY KEY CLUSTERED 
(
	[CubeId] ASC
) 
) 
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Utility].[CubeSystem]') AND name = N'UX_CubeSystem_1')
CREATE UNIQUE NONCLUSTERED INDEX [UX_CubeSystem_1] ON [Utility].[CubeSystem] 
(
	[Name] ASC
) 
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'CubeSystem', N'COLUMN',N'CubeId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código de cubo de datos.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'CubeSystem', @level2type=N'COLUMN',@level2name=N'CubeId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'CubeSystem', N'COLUMN',N'Name'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de cubo de datos.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'CubeSystem', @level2type=N'COLUMN',@level2name=N'Name'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'CubeSystem', N'COLUMN',N'AppName'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre (propiedad id) para identificar el cubo en el código de la aplicación.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'CubeSystem', @level2type=N'COLUMN',@level2name=N'AppName'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'CubeSystem', N'COLUMN',N'Database'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre (propiedad id) de la basae de datos OLAP.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'CubeSystem', @level2type=N'COLUMN',@level2name=N'Database'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'CubeSystem', N'COLUMN',N'Description'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Descripción.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'CubeSystem', @level2type=N'COLUMN',@level2name=N'Description'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'CubeSystem', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Almacena los cubos de datos del sistema. Un cubo esta formado por modelos, los cuales contiene metricas.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'CubeSystem'
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[MetricSystem]') AND type in (N'U'))
BEGIN
CREATE TABLE [Utility].[MetricSystem](
	[MetricId] [int] NOT NULL,
	[Name] [nvarchar](128) NOT NULL,
	[AppName] [nvarchar](128) NOT NULL,
	[ModelId] [nvarchar](12) NOT NULL,
	[DatabaseId] [nvarchar](12) NOT NULL,
	[Table] [nvarchar](128) NOT NULL,
	[Field] [nvarchar](128) NOT NULL,
	[QueryId] [nvarchar](12) NULL,
	[DateStart] [date] NULL,
	[DateEnd] [date] NULL,
	[CalculationType] [nvarchar](10) NOT NULL,
	[UnityId] [nvarchar](12) NOT NULL,
	[BusinessRule] [nvarchar](4000) NULL,
	[Formula] [nvarchar](4000) NULL,
	[Group1Id] [nvarchar](12) NULL,
	[Group2Id] [nvarchar](12) NULL,
	[Group3Id] [nvarchar](12) NULL,
	[MetadataId] [int] NULL,
	[Description] [nvarchar](500) NOT NULL,
	[BitacoraId] [bigint] NULL,
 CONSTRAINT [PK_MetricSystem] PRIMARY KEY CLUSTERED 
(
	[MetricId] ASC
) 
) 
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Utility].[MetricSystem]') AND name = N'UX_MetricSystem_1')
CREATE UNIQUE NONCLUSTERED INDEX [UX_MetricSystem_1] ON [Utility].[MetricSystem] 
(
	[Name] ASC,
	[ModelId] ASC
) 
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Utility].[MetricSystem]') AND name = N'IX_MetricSystem_1')
CREATE NONCLUSTERED INDEX [IX_MetricSystem_1] ON [Utility].[MetricSystem] 
(
	[AppName] ASC
) 
GO

IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[Utility].[CK_MetricSystem_DateStart_DateEnd]') AND parent_object_id = OBJECT_ID(N'[Utility].[MetricSystem]'))
ALTER TABLE [Utility].[MetricSystem]  WITH CHECK ADD  CONSTRAINT [CK_MetricSystem_DateStart_DateEnd] CHECK  ([DateEnd] IS NULL OR [DateEnd] >= [DateStart])
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[Utility].[CK_MetricSystem_DateStart_DateEnd]') AND parent_object_id = OBJECT_ID(N'[Utility].[MetricSystem]'))
ALTER TABLE [Utility].[MetricSystem] CHECK CONSTRAINT [CK_MetricSystem_DateStart_DateEnd]
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'MetricSystem', N'COLUMN',N'MetricId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código de métrica.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'MetricSystem', @level2type=N'COLUMN',@level2name=N'MetricId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'MetricSystem', N'COLUMN',N'Name'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de métrica.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'MetricSystem', @level2type=N'COLUMN',@level2name=N'Name'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'MetricSystem', N'COLUMN',N'AppName'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre o código para identificar la métrica en el código de la aplicación. Por el ejemplo la propiedad id de una metrica de un grupo de medidas de un cubo.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'MetricSystem', @level2type=N'COLUMN',@level2name=N'AppName'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'MetricSystem', N'COLUMN',N'ModelId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código de modelo. Por ejemplo un grupo de metricas. FK a [Utility].[ModelSystem].' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'MetricSystem', @level2type=N'COLUMN',@level2name=N'ModelId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'MetricSystem', N'COLUMN',N'DatabaseId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código de base de datos contra la cual ejecutar la consulta. Ejemplo: DW, SA.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'MetricSystem', @level2type=N'COLUMN',@level2name=N'DatabaseId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'MetricSystem', N'COLUMN',N'Table'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de tabla destino.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'MetricSystem', @level2type=N'COLUMN',@level2name=N'Table'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'MetricSystem', N'COLUMN',N'Field'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de campo de la tabla destino.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'MetricSystem', @level2type=N'COLUMN',@level2name=N'Field'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'MetricSystem', N'COLUMN',N'QueryId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código de consulta de selección de datos. FK a [Utility].[QuerySQL].' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'MetricSystem', @level2type=N'COLUMN',@level2name=N'QueryId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'MetricSystem', N'COLUMN',N'DateStart'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha del primer registro de datos.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'MetricSystem', @level2type=N'COLUMN',@level2name=N'DateStart'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'MetricSystem', N'COLUMN',N'DateEnd'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha del último registro de datos.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'MetricSystem', @level2type=N'COLUMN',@level2name=N'DateEnd'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'MetricSystem', N'COLUMN',N'CalculationType'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tipo de calculo. Por ejemplo: Calculada, Dimension, Natural, Variable.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'MetricSystem', @level2type=N'COLUMN',@level2name=N'CalculationType'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'MetricSystem', N'COLUMN',N'UnityId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código de unidad de medida. FK a [Utility].[UnidadMedida].' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'MetricSystem', @level2type=N'COLUMN',@level2name=N'UnityId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'MetricSystem', N'COLUMN',N'BusinessRule'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Regla de negocio.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'MetricSystem', @level2type=N'COLUMN',@level2name=N'BusinessRule'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'MetricSystem', N'COLUMN',N'Formula'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Descripción de la fórmula de cálculo.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'MetricSystem', @level2type=N'COLUMN',@level2name=N'Formula'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'MetricSystem', N'COLUMN',N'Group1Id'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Grupo 1 al cual pertenece la variable.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'MetricSystem', @level2type=N'COLUMN',@level2name=N'Group1Id'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'MetricSystem', N'COLUMN',N'Group2Id'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Grupo 2 al cual pertenece la variable.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'MetricSystem', @level2type=N'COLUMN',@level2name=N'Group2Id'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'MetricSystem', N'COLUMN',N'Group3Id'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Grupo 3 al cual pertenece la variable.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'MetricSystem', @level2type=N'COLUMN',@level2name=N'Group3Id'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'MetricSystem', N'COLUMN',N'MetadataId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código de metadata en la lista que presenta datos de metricas. Por ejemplo el Id en una lista Sharepoint.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'MetricSystem', @level2type=N'COLUMN',@level2name=N'MetadataId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'MetricSystem', N'COLUMN',N'Description'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Descripción de la métrica.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'MetricSystem', @level2type=N'COLUMN',@level2name=N'Description'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'MetricSystem', N'COLUMN',N'BitacoraId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código de bitacora de ejecución.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'MetricSystem', @level2type=N'COLUMN',@level2name=N'BitacoraId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'MetricSystem', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Almacena metricas o variables del sistema, las cuales estan asociadas a un grupo de medidas (modelo).' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'MetricSystem'
GO


/* ========================================================================== 
MODELO DE SEGURIDAD CONDUCIDO POR DATOS
Analysis Services – Data Driven Security Model: https://gavinrussell.wordpress.com/2010/05/07/analysis-services-–-data-driven-security-model/
========================================================================== */
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[UserDomain]') AND type in (N'U'))
BEGIN
CREATE TABLE [Utility].[UserDomain](
	[UserSKId] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NOT NULL,
	[FirstName] [nvarchar](100) NOT NULL,
	[LastName] [nvarchar](100) NOT NULL,
	[DomainUser] [nvarchar](100) NOT NULL,
	[DomainGroup] [nvarchar](100) NULL,
	[CreateUserId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL CONSTRAINT [DF_UserDomain_CreateDate] DEFAULT (GetDate()),
	[UpdateUserId] [int] NOT NULL,
	[UpdateDate] [datetime] NOT NULL CONSTRAINT [DF_UserDomain_UpdateDate] DEFAULT (GetDate()),
 CONSTRAINT [PK_UserDomain] PRIMARY KEY CLUSTERED 
(
	[UserSKId] ASC
) 
) 
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Utility].[UserDomain]') AND name = N'UX_UserDomain_1')
CREATE UNIQUE NONCLUSTERED INDEX [UX_UserDomain_1] ON [Utility].[UserDomain] 
(
	[UserId] ASC
) 
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Utility].[UserDomain]') AND name = N'IX_UserDomain_1')
CREATE NONCLUSTERED INDEX [IX_UserDomain_1] ON [Utility].[UserDomain] 
(
	[FirstName] ASC,
	[LastName] ASC
) 
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Utility].[UserDomain]') AND name = N'IX_UserDomain_2')
CREATE NONCLUSTERED INDEX [IX_UserDomain_2] ON [Utility].[UserDomain] 
(
	[DomainUser] ASC
) 
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'UserDomain', N'COLUMN',N'UserSKId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Clave subrogada usuario, autonumérico para identificar un registro.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'UserDomain', @level2type=N'COLUMN',@level2name=N'UserSKId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'UserDomain', N'COLUMN',N'UserId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código de usuario.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'UserDomain', @level2type=N'COLUMN',@level2name=N'UserId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'UserDomain', N'COLUMN',N'FirstName'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre del usuario.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'UserDomain', @level2type=N'COLUMN',@level2name=N'FirstName'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'UserDomain', N'COLUMN',N'LastName'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Apellidos del usuario.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'UserDomain', @level2type=N'COLUMN',@level2name=N'LastName'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'UserDomain', N'COLUMN',N'DomainUser'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario dentro del dominio del sistema operativo. Ejemplo: MiDominio\MiUsuario.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'UserDomain', @level2type=N'COLUMN',@level2name=N'DomainUser'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'UserDomain', N'COLUMN',N'DomainGroup'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Grupo dentro del dominio del sistema operativo, al cual pertenece el usuario de dominio.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'UserDomain', @level2type=N'COLUMN',@level2name=N'DomainGroup'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'UserDomain', N'COLUMN',N'CreateUserId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código de usuario que creó el registro.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'UserDomain', @level2type=N'COLUMN',@level2name=N'CreateUserId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'UserDomain', N'COLUMN',N'CreateDate'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creacion del registro.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'UserDomain', @level2type=N'COLUMN',@level2name=N'CreateDate'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'UserDomain', N'COLUMN',N'UpdateUserId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código de usuario que modifico el registro.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'UserDomain', @level2type=N'COLUMN',@level2name=N'UpdateUserId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'UserDomain', N'COLUMN',N'UpdateDate'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de modificación del registro.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'UserDomain', @level2type=N'COLUMN',@level2name=N'UpdateDate'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'UserDomain', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Almacena usuario de dominio del sistema operativo al cual esta asociado un usuario del sistema.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'UserDomain'
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[UserAgent]') AND type in (N'U'))
BEGIN
CREATE TABLE [Utility].[UserAgent](
	[AgentSKId] [int] NOT NULL,
	[UserSKId] [int] NOT NULL,
	[Enabled] [bit] NOT NULL CONSTRAINT [DF_UserAgent_Active]  DEFAULT (1),
	[CreateUserId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL CONSTRAINT [DF_UserAgent_CreateDate] DEFAULT (GetDate()),
	[UpdateUserId] [int] NOT NULL,
	[UpdateDate] [datetime] NOT NULL CONSTRAINT [DF_UserAgent_UpdateDate] DEFAULT (GetDate()),
 CONSTRAINT [PK_UserAgent] PRIMARY KEY CLUSTERED 
(
	[AgentSKId] ASC,
	[UserSKId] ASC
) 
) 
END
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'UserAgent', N'COLUMN',N'AgentSKId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Clave subrogada Agente.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'UserAgent', @level2type=N'COLUMN',@level2name=N'AgentSKId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'UserAgent', N'COLUMN',N'UserSKId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Clave subrogada usuario. FK a [Utility].[UserDomain].' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'UserAgent', @level2type=N'COLUMN',@level2name=N'UserSKId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'UserAgent', N'COLUMN',N'Enabled'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Indica si el usuario esta activo o no.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'UserAgent', @level2type=N'COLUMN',@level2name=N'Enabled'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'UserAgent', N'COLUMN',N'CreateUserId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código de usuario que creó el registro.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'UserAgent', @level2type=N'COLUMN',@level2name=N'CreateUserId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'UserAgent', N'COLUMN',N'CreateDate'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creacion del registro.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'UserAgent', @level2type=N'COLUMN',@level2name=N'CreateDate'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'UserAgent', N'COLUMN',N'UpdateUserId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código de usuario que modifico el registro.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'UserAgent', @level2type=N'COLUMN',@level2name=N'UpdateUserId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'UserAgent', N'COLUMN',N'UpdateDate'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de modificación del registro.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'UserAgent', @level2type=N'COLUMN',@level2name=N'UpdateDate'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'UserAgent', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Almacena usuarios asociados a un agente. La informacion puede ser utilizada para definir permisos por usuario.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'UserAgent'
GO

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - End script: A04Table_UtilCube.sql'
PRINT '------------------------------------------------------------------------'
GO