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
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - Start script: A07Table_Stg.sql'
PRINT '------------------------------------------------------------------------'
GO

USE [$(DATABASE_NAME_DW)];
GO

/*====================================================================================
TABLA CON LISTA DE TABLAS QUE PUEDEN SER TRUNCADAS EN LAS ETLs
==================================================================================== */
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Staging].[TruncateList]') AND type in (N'U'))
BEGIN
CREATE TABLE [Staging].[TruncateList](
	[SchemaName] [nvarchar](128) NOT NULL,
	[TableName] [nvarchar](128) NOT NULL
 CONSTRAINT [PK_TruncateList] PRIMARY KEY CLUSTERED 
(
	[SchemaName] ASC,
	[TableName] ASC
) ON [PRIMARY]
) ON [PRIMARY];
END
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TruncateList', N'COLUMN',N'SchemaName'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de esquema. Ejemplo: TMP.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TruncateList', @level2type=N'COLUMN',@level2name=N'SchemaName'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TruncateList', N'COLUMN',N'TableName'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de tabla' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TruncateList', @level2type=N'COLUMN',@level2name=N'TableName'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TruncateList', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Almacena tablas que pueden ser truncadas mediante el SP: [Staging].[spTruncateTable]. El objetivo es evitar errores por permisos en la instrucción TRUNCATE TABLE.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TruncateList'
GO


/* ========================================================================== 
DIMENSIONES
========================================================================== */
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Staging].[TmpDimAgente]') AND type in (N'U'))
BEGIN
CREATE TABLE [Staging].[TmpDimAgente](
	[TmpSKId] [int] IDENTITY(1,1) NOT NULL,
	[AgenteId] [varchar](20) NOT NULL,
	[AgenteMemId] [varchar](20) NOT NULL,
	[Nombre] [varchar](100) NOT NULL,
	[Actividad] [varchar](20) NOT NULL,
	[CompaniaId] [varchar](20) NOT NULL,
	[CompaniaSKId] [int] NULL,
	[Activo] [bit] NOT NULL,
	[FechaIni] [date] NOT NULL,
	[FechaIniSKId] [int] NULL,
	[FechaFin] [date] NULL,
	[FechaFinSKId] [int] NULL,
	[Inconsistent] [bit] NULL CONSTRAINT [DF_TmpDimAgente_Inconsistent] DEFAULT (0),
	[Row] [int] NULL,
	[BitacoraId] [bigint] NULL
) ON [PRIMARY];
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Staging].[TmpDimAgente]') AND name = N'PK_TmpDimAgente')
ALTER TABLE [Staging].[TmpDimAgente] ADD CONSTRAINT [PK_TmpDimAgente] PRIMARY KEY CLUSTERED
(
	[TmpSKId] ASC
) ON [PRIMARY];
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Staging].[TmpDimAgente]') AND name = N'IX_TmpDimAgente_1')
CREATE NONCLUSTERED INDEX [IX_TmpDimAgente_1] ON [Staging].[TmpDimAgente] 
(
	[AgenteId] ASC
) ON [PRIMARY];
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpDimAgente', N'COLUMN',N'TmpSKId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Clave subrogada agente, para identificar un registro.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpDimAgente', @level2type=N'COLUMN',@level2name=N'TmpSKId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpDimAgente', N'COLUMN',N'AgenteId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de agente.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpDimAgente', @level2type=N'COLUMN',@level2name=N'AgenteId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpDimAgente', N'COLUMN',N'AgenteMemId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de agente en el MEM (mercado de energia mayorista).' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpDimAgente', @level2type=N'COLUMN',@level2name=N'AgenteMemId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpDimAgente', N'COLUMN',N'Nombre'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de agente.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpDimAgente', @level2type=N'COLUMN',@level2name=N'Nombre'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpDimAgente', N'COLUMN',N'Actividad'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Actividad economica, por ejemplo: generacion, distribucion, transmision.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpDimAgente', @level2type=N'COLUMN',@level2name=N'Actividad'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpDimAgente', N'COLUMN',N'CompaniaId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de compañia a la cual pertenece el agente.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpDimAgente', @level2type=N'COLUMN',@level2name=N'CompaniaId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpDimAgente', N'COLUMN',N'CompaniaSKId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo SK de compañia a la cual pertenece el agente.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpDimAgente', @level2type=N'COLUMN',@level2name=N'CompaniaSKId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpDimAgente', N'COLUMN',N'Activo'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Indica si el agente esta activo o no.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpDimAgente', @level2type=N'COLUMN',@level2name=N'Activo'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpDimAgente', N'COLUMN',N'FechaIni'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha inicio de vigencia.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpDimAgente', @level2type=N'COLUMN',@level2name=N'FechaIni'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpDimAgente', N'COLUMN',N'FechaIniSKId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha SK inicio de vigencia. FK a [DW].[DimFecha].' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpDimAgente', @level2type=N'COLUMN',@level2name=N'FechaIniSKId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpDimAgente', N'COLUMN',N'FechaFin'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha fin de vigencia.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpDimAgente', @level2type=N'COLUMN',@level2name=N'FechaFin'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpDimAgente', N'COLUMN',N'FechaFinSKId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha SK fin de vigencia. FK a [DW].[DimFecha].' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpDimAgente', @level2type=N'COLUMN',@level2name=N'FechaFinSKId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpDimAgente', N'COLUMN',N'Inconsistent'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Indica si una fila es inconsistente, utilizado para procesar datos.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpDimAgente', @level2type=N'COLUMN',@level2name=N'Inconsistent'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpDimAgente', N'COLUMN',N'Row'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Numero de fila, utilizado para procesar datos.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpDimAgente', @level2type=N'COLUMN',@level2name=N'Row'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpDimAgente', N'COLUMN',N'BitacoraId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de bitacora de proceso.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpDimAgente', @level2type=N'COLUMN',@level2name=N'BitacoraId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpDimAgente', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Almacena en forma temporal los datos maestros de agentes.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpDimAgente'
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Staging].[TmpDimCompania]') AND type in (N'U'))
BEGIN
CREATE TABLE [Staging].[TmpDimCompania](
	[TmpSKId] [int] IDENTITY(1,1) NOT NULL,
	[CompaniaId] [varchar](20) NOT NULL,
	[Nombre] [varchar](100) NOT NULL,
	[Sigla] [varchar](100) NOT NULL,
	[Nit] [varchar](20) NOT NULL,
	[TipoPropiedad] [varchar](50) NOT NULL,
	[Activa] [bit] NOT NULL,
	[FechaIni] [date] NOT NULL,
	[FechaIniSKId] [int] NULL,
	[FechaFin] [date] NULL,
	[FechaFinSKId] [int] NULL,
	[Inconsistent] [bit] NULL CONSTRAINT [DF_TmpDimCompania_Inconsistent] DEFAULT (0),
	[Row] [int] NULL,
	[BitacoraId] [bigint] NULL
) ON [PRIMARY];
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Staging].[TmpDimCompania]') AND name = N'PK_TmpDimCompania')
ALTER TABLE [Staging].[TmpDimCompania] ADD CONSTRAINT [PK_TmpDimCompania] PRIMARY KEY CLUSTERED
(
	[TmpSKId] ASC
) ON [PRIMARY];
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Staging].[TmpDimCompania]') AND name = N'IX_TmpDimCompania_1')
CREATE NONCLUSTERED INDEX [IX_TmpDimCompania_1] ON [Staging].[TmpDimCompania] 
(
	[CompaniaId] ASC
) ON [PRIMARY];
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpDimCompania', N'COLUMN',N'TmpSKId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Clave subrogada compañia, para identificar un registro.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpDimCompania', @level2type=N'COLUMN',@level2name=N'TmpSKId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpDimCompania', N'COLUMN',N'CompaniaId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de compañia.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpDimCompania', @level2type=N'COLUMN',@level2name=N'CompaniaId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpDimCompania', N'COLUMN',N'Nombre'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de compañia.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpDimCompania', @level2type=N'COLUMN',@level2name=N'Nombre'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpDimCompania', N'COLUMN',N'Sigla'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Siglas de la compañia.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpDimCompania', @level2type=N'COLUMN',@level2name=N'Sigla'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpDimCompania', N'COLUMN',N'Nit'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nit de la compañia.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpDimCompania', @level2type=N'COLUMN',@level2name=N'Nit'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpDimCompania', N'COLUMN',N'TipoPropiedad'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tipo de compañia, por ejemplo, publica, privada.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpDimCompania', @level2type=N'COLUMN',@level2name=N'TipoPropiedad'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpDimCompania', N'COLUMN',N'Activa'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Indica si la compañia esta activa o no.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpDimCompania', @level2type=N'COLUMN',@level2name=N'Activa'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpDimCompania', N'COLUMN',N'FechaIni'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha inicio de vigencia.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpDimCompania', @level2type=N'COLUMN',@level2name=N'FechaIni'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpDimCompania', N'COLUMN',N'FechaIniSKId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha SK inicio de vigencia. FK a [Staging].[DimFecha].' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpDimCompania', @level2type=N'COLUMN',@level2name=N'FechaIniSKId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpDimCompania', N'COLUMN',N'FechaFin'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha fin de vigencia.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpDimCompania', @level2type=N'COLUMN',@level2name=N'FechaFin'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpDimCompania', N'COLUMN',N'FechaFinSKId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha SK fin de vigencia. FK a [Staging].[DimFecha].' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpDimCompania', @level2type=N'COLUMN',@level2name=N'FechaFinSKId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpDimCompania', N'COLUMN',N'Inconsistent'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Indica si una fila es inconsistente, utilizado para procesar datos.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpDimCompania', @level2type=N'COLUMN',@level2name=N'Inconsistent'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpDimCompania', N'COLUMN',N'Row'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Numero de fila, utilizado para procesar datos.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpDimCompania', @level2type=N'COLUMN',@level2name=N'Row'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpDimCompania', N'COLUMN',N'BitacoraId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de bitacora de proceso.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpDimCompania', @level2type=N'COLUMN',@level2name=N'BitacoraId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpDimCompania', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Almacena en forma temporal los datos maestros de compañias.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpDimCompania'
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Staging].[TmpDimGeografia]') AND type in (N'U'))
BEGIN
CREATE TABLE [Staging].[TmpDimGeografia](
	[TmpSKId] [int] IDENTITY(1,1) NOT NULL,
	[PaisId] [varchar](10) NOT NULL,
	[Pais] [varchar](150) NOT NULL,
	[DepartamentoId] [varchar](10) NOT NULL,
	[Departamento] [varchar](150) NOT NULL,
	[MunicipioId] [varchar](10) NOT NULL,
	[Municipio] [varchar](150) NOT NULL,
	[AreaId] [varchar](10) NOT NULL,
	[Area] [varchar](150) NOT NULL,
	[SubAreaId] [varchar](10) NOT NULL,
	[SubArea] [varchar](150) NOT NULL,
	[Inconsistent] [bit] NULL CONSTRAINT [DF_TmpDimGeografia_Inconsistent] DEFAULT (0),
	[BitacoraId] [bigint] NULL
) ON [PRIMARY];
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Staging].[TmpDimGeografia]') AND name = N'PK_TmpDimGeografia')
ALTER TABLE [Staging].[TmpDimGeografia] ADD CONSTRAINT [PK_TmpDimGeografia] PRIMARY KEY CLUSTERED
(
	[TmpSKId] ASC
) ON [PRIMARY];
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpDimGeografia', N'COLUMN',N'TmpSKId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Clave subrogada geografia, para identificar un registro.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpDimGeografia', @level2type=N'COLUMN',@level2name=N'TmpSKId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpDimGeografia', N'COLUMN',N'PaisId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de pais.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpDimGeografia', @level2type=N'COLUMN',@level2name=N'PaisId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpDimGeografia', N'COLUMN',N'Pais'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de pais.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpDimGeografia', @level2type=N'COLUMN',@level2name=N'Pais'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpDimGeografia', N'COLUMN',N'DepartamentoId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de departamento.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpDimGeografia', @level2type=N'COLUMN',@level2name=N'DepartamentoId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpDimGeografia', N'COLUMN',N'Departamento'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de departamento.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpDimGeografia', @level2type=N'COLUMN',@level2name=N'Departamento'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpDimGeografia', N'COLUMN',N'MunicipioId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de municipio.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpDimGeografia', @level2type=N'COLUMN',@level2name=N'MunicipioId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpDimGeografia', N'COLUMN',N'Municipio'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de municipio.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpDimGeografia', @level2type=N'COLUMN',@level2name=N'Municipio'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpDimGeografia', N'COLUMN',N'AreaId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de area.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpDimGeografia', @level2type=N'COLUMN',@level2name=N'AreaId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpDimGeografia', N'COLUMN',N'Area'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de area.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpDimGeografia', @level2type=N'COLUMN',@level2name=N'Area'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpDimGeografia', N'COLUMN',N'SubAreaId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de subarea.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpDimGeografia', @level2type=N'COLUMN',@level2name=N'SubAreaId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpDimGeografia', N'COLUMN',N'SubArea'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de subarea.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpDimGeografia', @level2type=N'COLUMN',@level2name=N'SubArea'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpDimGeografia', N'COLUMN',N'Inconsistent'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Indica si una fila es inconsistente, utilizado para procesar datos.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpDimGeografia', @level2type=N'COLUMN',@level2name=N'Inconsistent'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpDimGeografia', N'COLUMN',N'BitacoraId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de bitacora de proceso.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpDimGeografia', @level2type=N'COLUMN',@level2name=N'BitacoraId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpDimGeografia', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Almacena en forma temporal los datos maestros de areas responsables.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpDimGeografia'
GO


/*====================================================================================
TABLAS FACT
==================================================================================== */
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Staging].[TmpFactDemandaPerdida]') AND type in (N'U'))
BEGIN
CREATE TABLE [Staging].[TmpFactDemandaPerdida](
	[TmpSKId] [int] IDENTITY(1,1) NOT NULL,
	[Fecha] [date] NOT NULL,
	[FechaSKId] [int] NULL,
	[PeriodoSKId] [smallint] NOT NULL,
	[AgenteMemDisId] [varchar](20) NOT NULL,
	[AgenteMemDisSKId] [int] NULL,
	[Mercado] [varchar](50) NOT NULL,
	[MercadoSKId] [smallint] NULL,
	[PaisId] [varchar](10) NULL,
	[DepartamentoId] [varchar](10) NULL,
	[MunicipioId] [varchar](10) NULL,
	[GeografiaSKId] [smallint] NULL,
	[DemandaReal] [numeric](24, 10) NULL,
	[PerdidaEnergia] [numeric](24, 10) NULL,
	[Inconsistent] [bit] NULL CONSTRAINT [DF_TmpFactDemandaPerdida_Inconsistent] DEFAULT (0),
) ON [PRIMARY];
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Staging].[TmpFactDemandaPerdida]') AND name = N'PK_TmpFactDemandaPerdida')
ALTER TABLE [Staging].[TmpFactDemandaPerdida] ADD  CONSTRAINT [PK_TmpFactDemandaPerdida] PRIMARY KEY NONCLUSTERED 
(
	[TmpSKId] ASC
) ON [PRIMARY];
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Staging].[TmpFactDemandaPerdida]') AND name = N'IX_TmpFactDemandaPerdida_1')
CREATE CLUSTERED INDEX [IX_TmpFactDemandaPerdida_1] ON [Staging].[TmpFactDemandaPerdida]
(
	[Fecha] ASC
) ON [PRIMARY];
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpFactDemandaPerdida', N'COLUMN',N'TmpSKId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Clave subrogada tabla temporal, para identificar un registro.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpFactDemandaPerdida', @level2type=N'COLUMN',@level2name=N'TmpSKId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpFactDemandaPerdida', N'COLUMN',N'Fecha'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpFactDemandaPerdida', @level2type=N'COLUMN',@level2name=N'Fecha'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpFactDemandaPerdida', N'COLUMN',N'FechaSKId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha SK.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpFactDemandaPerdida', @level2type=N'COLUMN',@level2name=N'FechaSKId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpFactDemandaPerdida', N'COLUMN',N'PeriodoSKId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Periodo SK.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpFactDemandaPerdida', @level2type=N'COLUMN',@level2name=N'PeriodoSKId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpFactDemandaPerdida', N'COLUMN',N'AgenteMemDisId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de agente MEM distribuidor.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpFactDemandaPerdida', @level2type=N'COLUMN',@level2name=N'AgenteMemDisId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpFactDemandaPerdida', N'COLUMN',N'AgenteMemDisSKId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo SK de agente MEM distribuidor.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpFactDemandaPerdida', @level2type=N'COLUMN',@level2name=N'AgenteMemDisSKId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpFactDemandaPerdida', N'COLUMN',N'Mercado'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de mercado.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpFactDemandaPerdida', @level2type=N'COLUMN',@level2name=N'Mercado'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpFactDemandaPerdida', N'COLUMN',N'MercadoSKId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo SK de mercado.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpFactDemandaPerdida', @level2type=N'COLUMN',@level2name=N'MercadoSKId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpFactDemandaPerdida', N'COLUMN',N'PaisId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de pais.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpFactDemandaPerdida', @level2type=N'COLUMN',@level2name=N'PaisId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpFactDemandaPerdida', N'COLUMN',N'DepartamentoId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de departamento.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpFactDemandaPerdida', @level2type=N'COLUMN',@level2name=N'DepartamentoId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpFactDemandaPerdida', N'COLUMN',N'MunicipioId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de municipio.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpFactDemandaPerdida', @level2type=N'COLUMN',@level2name=N'MunicipioId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpFactDemandaPerdida', N'COLUMN',N'GeografiaSKId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo SK de geografia.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpFactDemandaPerdida', @level2type=N'COLUMN',@level2name=N'GeografiaSKId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpFactDemandaPerdida', N'COLUMN',N'DemandaReal'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Valor demanda de energia real en kWh.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpFactDemandaPerdida', @level2type=N'COLUMN',@level2name=N'DemandaReal'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpFactDemandaPerdida', N'COLUMN',N'PerdidaEnergia'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Valor perdidas de energia en kWh.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpFactDemandaPerdida', @level2type=N'COLUMN',@level2name=N'PerdidaEnergia'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpFactDemandaPerdida', N'COLUMN',N'Inconsistent'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Indica si una fila es inconsistente, utilizado para procesar datos.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpFactDemandaPerdida', @level2type=N'COLUMN',@level2name=N'Inconsistent'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpFactDemandaPerdida', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Almacena en forma temporal datos trasaccionales de demandas y perdidas de energia.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpFactDemandaPerdida'
GO

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - End script: A07Table_Stg.sql'
PRINT '------------------------------------------------------------------------'
GO
