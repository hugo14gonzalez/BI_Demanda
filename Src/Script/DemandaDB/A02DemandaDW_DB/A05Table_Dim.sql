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
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - Start script: A05Table_Dim.sql'
PRINT '------------------------------------------------------------------------'
GO

USE [$(DATABASE_NAME_DW)];

/* ========================================================================== 
DIMENSIONES FECHA Y TIEMPO
========================================================================== */
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DW].[DimFecha]') AND type in (N'U'))
BEGIN
CREATE TABLE [DW].[DimFecha](
	[FechaSKId] [int] NOT NULL,
	[Fecha] [date] NOT NULL,
	[FechaDesc] [nvarchar](10) NOT NULL,
	[Anio] [smallint] NOT NULL,
	[Semestre] [smallint] NOT NULL,
	[SemestreDesc] [nvarchar](15) NOT NULL,
	[Trimestre] [smallint] NOT NULL,
	[TrimestreDesc] [nvarchar](15) NOT NULL,
	[Mes] [smallint] NOT NULL,
	[MesNombre] [nvarchar](10) NOT NULL,
	[MesNombreCorto] [nchar](3) NOT NULL,
	[MesDesc] [nvarchar](15) NOT NULL,
	[MesDescCorto] [nvarchar](8) NOT NULL,
	[SemanaAnio] [smallint] NOT NULL,
	[SemanaAnioDesc] [nvarchar](15) NOT NULL,
	[Dia] [smallint] NOT NULL,
	[DiaAnio] [smallint] NOT NULL,
	[DiaSemana] [smallint] NOT NULL,
	[DiaNombre] [nvarchar](10) NOT NULL,
	[DiaNombreCorto] [char](3) NOT NULL,
	[DiaTipo] [nvarchar](10) NOT NULL
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[DW].[DimFecha]') AND name = N'CX_DimFecha')
CREATE CLUSTERED COLUMNSTORE INDEX [CX_DimFecha] ON [DW].[DimFecha]
ON [PRIMARY];
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[DW].[DimFecha]') AND name = N'PK_DimFecha')
ALTER TABLE [DW].[DimFecha] ADD CONSTRAINT [PK_DimFecha] PRIMARY KEY NONCLUSTERED
(
	[FechaSKId] ASC
) ON [PRIMARY];
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[DW].[DimFecha]') AND name = N'UX_DimFecha_1')
CREATE UNIQUE NONCLUSTERED INDEX [UX_DimFecha_1] ON [DW].[DimFecha] 
(
	[Fecha] ASC
) ON [PRIMARY];
GO

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimFecha', N'COLUMN',N'FechaSKId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Clave subrogada de fecha en formato: AAAAMMDD.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimFecha', @level2type=N'COLUMN',@level2name=N'FechaSKId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimFecha', N'COLUMN',N'Fecha'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimFecha', @level2type=N'COLUMN',@level2name=N'Fecha'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimFecha', N'COLUMN',N'FechaDesc'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Descripción fecha en formato (AAAA-MM-DD).' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimFecha', @level2type=N'COLUMN',@level2name=N'FechaDesc'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimFecha', N'COLUMN',N'Anio'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Año.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimFecha', @level2type=N'COLUMN',@level2name=N'Anio'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimFecha', N'COLUMN',N'Semestre'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Número de semestre (1 ó 2).' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimFecha', @level2type=N'COLUMN',@level2name=N'Semestre'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimFecha', N'COLUMN',N'SemestreDesc'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Descripción semestre (2011-Semestre1).' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimFecha', @level2type=N'COLUMN',@level2name=N'SemestreDesc'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimFecha', N'COLUMN',N'Trimestre'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Número de trimestre o cuatrenio (1 a 4).' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimFecha', @level2type=N'COLUMN',@level2name=N'Trimestre'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimFecha', N'COLUMN',N'TrimestreDesc'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Descripción trimestre o cuatrenio (2011-Trim1)' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimFecha', @level2type=N'COLUMN',@level2name=N'TrimestreDesc'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimFecha', N'COLUMN',N'Mes'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Número de mes (1 a 12).' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimFecha', @level2type=N'COLUMN',@level2name=N'Mes'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimFecha', N'COLUMN',N'MesNombre'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre del mes (Junio).' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimFecha', @level2type=N'COLUMN',@level2name=N'MesNombre'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimFecha', N'COLUMN',N'MesNombreCorto'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre del mes abreviado a 3 caracteres (Jun).' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimFecha', @level2type=N'COLUMN',@level2name=N'MesNombreCorto'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimFecha', N'COLUMN',N'MesDesc'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Descripción mes (2011-Junio).' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimFecha', @level2type=N'COLUMN',@level2name=N'MesDesc'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimFecha', N'COLUMN',N'MesDescCorto'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Descripción mes, con el mes abreviado a 3 caracteres (2011-Jun).' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimFecha', @level2type=N'COLUMN',@level2name=N'MesDescCorto'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimFecha', N'COLUMN',N'SemanaAnio'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Número de semana del año (1 a 54).' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimFecha', @level2type=N'COLUMN',@level2name=N'SemanaAnio'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimFecha', N'COLUMN',N'SemanaAnioDesc'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Descripción semana del año (2011-S01).' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimFecha', @level2type=N'COLUMN',@level2name=N'SemanaAnioDesc'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimFecha', N'COLUMN',N'Dia'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Número de día (1 a 31).' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimFecha', @level2type=N'COLUMN',@level2name=N'Dia'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimFecha', N'COLUMN',N'DiaAnio'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Número de día del año (1 al 366).' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimFecha', @level2type=N'COLUMN',@level2name=N'DiaAnio'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimFecha', N'COLUMN',N'DiaSemana'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Número de día de semana (1 al 7).' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimFecha', @level2type=N'COLUMN',@level2name=N'DiaSemana'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimFecha', N'COLUMN',N'DiaNombre'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre del día de semana (Lunes, Martes, ...).' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimFecha', @level2type=N'COLUMN',@level2name=N'DiaNombre'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimFecha', N'COLUMN',N'DiaNombreCorto'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre del día de semana abreviado a 3 caracteres (Lun, Mar, ...).' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimFecha', @level2type=N'COLUMN',@level2name=N'DiaNombreCorto'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimFecha', N'COLUMN',N'DiaTipo'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tipo de día (Habil, No habil, Festivo).' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimFecha', @level2type=N'COLUMN',@level2name=N'DiaTipo'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimFecha', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Almacena datos de fecha.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimFecha'
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DW].[DimPeriodo]') AND type in (N'U'))
BEGIN
CREATE TABLE [DW].[DimPeriodo](
	[PeriodoSKId] [smallint] NOT NULL,
	[Hora] [smallint] NOT NULL,
	[Tiempo] [time](0) NOT NULL,
 CONSTRAINT [PK_DimPeriodo] PRIMARY KEY CLUSTERED 
(
	[PeriodoSKId] ASC
) ON [PRIMARY] 
) ON [PRIMARY];
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[DW].[DimPeriodo]') AND name = N'UX_DimPeriodo_1')
CREATE UNIQUE NONCLUSTERED INDEX [UX_DimPeriodo_1] ON [DW].[DimPeriodo] 
(
	[Hora] ASC
) ON [PRIMARY];
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[DW].[DimPeriodo]') AND name = N'UX_DimPeriodo_2')
CREATE UNIQUE NONCLUSTERED INDEX [UX_DimPeriodo_2] ON [DW].[DimPeriodo] 
(
	[Tiempo] ASC
) ON [PRIMARY];
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimPeriodo', N'COLUMN',N'PeriodoSKId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Clave subrogada periodo para identificar un registro, de 1 a 24.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimPeriodo', @level2type=N'COLUMN',@level2name=N'PeriodoSKId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimPeriodo', N'COLUMN',N'Hora'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Hora como número en formato de 24 horas, de 0 a 23.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimPeriodo', @level2type=N'COLUMN',@level2name=N'Hora'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimPeriodo', N'COLUMN',N'Tiempo'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tiempo como tipo de datos: Time, solo la hora, sin minutos o segundos.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimPeriodo', @level2type=N'COLUMN',@level2name=N'Tiempo'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimPeriodo', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Almacena periodo con granularidad de hora. Numero de miembros: 24.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimPeriodo'
GO

/* ========================================================================== 
DIMENSIONES
========================================================================== */
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DW].[DimAgente]') AND type in (N'U'))
BEGIN
CREATE TABLE [DW].[DimAgente](
	[AgenteSKId] [int] IDENTITY(1,1) NOT NULL,
	[AgenteId] [varchar](20) NOT NULL,
	[AgenteMemId] [varchar](20) NOT NULL,
	[Nombre] [varchar](100) NOT NULL,
	[Actividad] [varchar](20) NOT NULL,
	[CompaniaSKId] [int] NOT NULL,
	[Activo] [bit] NOT NULL,
	[EsActual] [bit] NOT NULL CONSTRAINT [DF_DimAgente_EsActual] DEFAULT (1),
	[FechaIniSKId] [int] NOT NULL,
	[FechaFinSKId] [int] NULL,
	[BitacoraId] [bigint] NULL
) ON [PRIMARY];
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[DW].[DimAgente]') AND name = N'CX_DimAgente')
CREATE CLUSTERED COLUMNSTORE INDEX [CX_DimAgente] ON [DW].[DimAgente]
ON [PRIMARY];
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[DW].[DimAgente]') AND name = N'PK_DimAgente')
ALTER TABLE [DW].[DimAgente] ADD CONSTRAINT [PK_DimAgente] PRIMARY KEY NONCLUSTERED
(
	[AgenteSKId] ASC
) ON [PRIMARY];
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[DW].[DimAgente]') AND name = N'UX_DimAgente_1')
CREATE UNIQUE NONCLUSTERED INDEX [UX_DimAgente_1] ON [DW].[DimAgente] 
(
	[AgenteId] ASC,
	[FechaIniSKId] ASC
) ON [PRIMARY];
GO

IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DW].[CK_DimAgente_FechaIni_FechaFin]') AND parent_object_id = OBJECT_ID(N'[DW].[DimAgente]'))
ALTER TABLE [DW].[DimAgente]  WITH CHECK ADD  CONSTRAINT [CK_DimAgente_FechaIni_FechaFin] CHECK  ([FechaFinSKId] IS NULL OR [FechaFinSKId] >= [FechaIniSKId])
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DW].[CK_DimAgente_FechaIni_FechaFin]') AND parent_object_id = OBJECT_ID(N'[DW].[DimAgente]'))
ALTER TABLE [DW].[DimAgente] CHECK CONSTRAINT [CK_DimAgente_FechaIni_FechaFin]
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimAgente', N'COLUMN',N'AgenteSKId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Clave subrogada agente, para identificar un registro.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimAgente', @level2type=N'COLUMN',@level2name=N'AgenteSKId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimAgente', N'COLUMN',N'AgenteId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de agente.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimAgente', @level2type=N'COLUMN',@level2name=N'AgenteId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimAgente', N'COLUMN',N'AgenteMemId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de agente en el MEM (mercado de energia mayorista).' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimAgente', @level2type=N'COLUMN',@level2name=N'AgenteMemId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimAgente', N'COLUMN',N'Nombre'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de agente.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimAgente', @level2type=N'COLUMN',@level2name=N'Nombre'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimAgente', N'COLUMN',N'Actividad'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Actividad economica, por ejemplo: generacion, distribucion, transmision.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimAgente', @level2type=N'COLUMN',@level2name=N'Actividad'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimAgente', N'COLUMN',N'CompaniaSKId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo SK de compañia a la cual pertenece el agente.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimAgente', @level2type=N'COLUMN',@level2name=N'CompaniaSKId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimAgente', N'COLUMN',N'Activo'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Indica si el agente esta activo o no.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimAgente', @level2type=N'COLUMN',@level2name=N'Activo'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimAgente', N'COLUMN',N'EsActual'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Indica si es el registro de la vigencia actual.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimAgente', @level2type=N'COLUMN',@level2name=N'EsActual'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimAgente', N'COLUMN',N'FechaIniSKId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha SK inicio de vigencia. FK a [DW].[DimFecha].' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimAgente', @level2type=N'COLUMN',@level2name=N'FechaIniSKId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimAgente', N'COLUMN',N'FechaFinSKId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha SK fin de vigencia. FK a [DW].[DimFecha].' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimAgente', @level2type=N'COLUMN',@level2name=N'FechaFinSKId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimAgente', N'COLUMN',N'BitacoraId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de bitacora de proceso.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimAgente', @level2type=N'COLUMN',@level2name=N'BitacoraId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimAgente', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Almacena los datos maestros de agentes.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimAgente'
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DW].[DimCompania]') AND type in (N'U'))
BEGIN
CREATE TABLE [DW].[DimCompania](
	[CompaniaSKId] [int] IDENTITY(1,1) NOT NULL,
	[CompaniaId] [varchar](20) NOT NULL,
	[Nombre] [varchar](100) NOT NULL,
	[Sigla] [varchar](100) NOT NULL,
	[Nit] [varchar](20) NOT NULL,
	[TipoPropiedad] [varchar](50) NOT NULL,
	[Activa] [bit] NOT NULL,
	[EsActual] [bit] NOT NULL CONSTRAINT [DF_DimCompania_EsActual] DEFAULT (1),
	[FechaIniSKId] [int] NOT NULL,
	[FechaFinSKId] [int] NULL,
	[BitacoraId] [bigint] NULL
) ON [PRIMARY];
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[DW].[DimCompania]') AND name = N'CX_DimCompania')
CREATE CLUSTERED COLUMNSTORE INDEX [CX_DimCompania] ON [DW].[DimCompania]
ON [PRIMARY];
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[DW].[DimCompania]') AND name = N'PK_DimCompania')
ALTER TABLE [DW].[DimCompania] ADD CONSTRAINT [PK_DimCompania] PRIMARY KEY NONCLUSTERED
(
	[CompaniaSKId] ASC
) ON [PRIMARY];
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[DW].[DimCompania]') AND name = N'UX_DimCompania_1')
CREATE UNIQUE NONCLUSTERED INDEX [UX_DimCompania_1] ON [DW].[DimCompania] 
(
	[CompaniaId] ASC,
	[FechaIniSKId] ASC
) ON [PRIMARY];
GO

IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DW].[CK_DimCompania_FechaIni_FechaFin]') AND parent_object_id = OBJECT_ID(N'[DW].[DimCompania]'))
ALTER TABLE [DW].[DimCompania]  WITH CHECK ADD  CONSTRAINT [CK_DimCompania_FechaIni_FechaFin] CHECK  ([FechaFinSKId] IS NULL OR [FechaFinSKId] >= [FechaIniSKId])
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[DW].[CK_DimCompania_FechaIni_FechaFin]') AND parent_object_id = OBJECT_ID(N'[DW].[DimCompania]'))
ALTER TABLE [DW].[DimCompania] CHECK CONSTRAINT [CK_DimCompania_FechaIni_FechaFin]
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimCompania', N'COLUMN',N'CompaniaSKId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Clave subrogada compañia, para identificar un registro.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimCompania', @level2type=N'COLUMN',@level2name=N'CompaniaSKId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimCompania', N'COLUMN',N'CompaniaId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de compañia.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimCompania', @level2type=N'COLUMN',@level2name=N'CompaniaId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimCompania', N'COLUMN',N'Nombre'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de compania.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimCompania', @level2type=N'COLUMN',@level2name=N'Nombre'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimCompania', N'COLUMN',N'Sigla'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Siglas de la compañia.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimCompania', @level2type=N'COLUMN',@level2name=N'Sigla'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimCompania', N'COLUMN',N'Nit'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nit de la compañia.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimCompania', @level2type=N'COLUMN',@level2name=N'Nit'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimCompania', N'COLUMN',N'TipoPropiedad'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tipo de compañia, por ejemplo, publica, privada.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimCompania', @level2type=N'COLUMN',@level2name=N'TipoPropiedad'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimCompania', N'COLUMN',N'Activa'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Indica si la compañia esta activa o no.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimCompania', @level2type=N'COLUMN',@level2name=N'Activa'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimCompania', N'COLUMN',N'EsActual'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Indica si es el registro de la vigencia actual.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimCompania', @level2type=N'COLUMN',@level2name=N'EsActual'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimCompania', N'COLUMN',N'FechaIniSKId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha SK inicio de vigencia. FK a [DW].[DimFecha].' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimCompania', @level2type=N'COLUMN',@level2name=N'FechaIniSKId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimCompania', N'COLUMN',N'FechaFinSKId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha SK fin de vigencia. FK a [DW].[DimFecha].' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimCompania', @level2type=N'COLUMN',@level2name=N'FechaFinSKId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimCompania', N'COLUMN',N'BitacoraId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de bitacora de proceso.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimCompania', @level2type=N'COLUMN',@level2name=N'BitacoraId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimCompania', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Almacena datos maestros de compañia.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimCompania'
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DW].[DimGeografia]') AND type in (N'U'))
BEGIN
CREATE TABLE [DW].[DimGeografia](
	[GeografiaSKId] [int] IDENTITY(1,1) NOT NULL,
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
	[BitacoraId] [bigint] NULL
) ON [PRIMARY];
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[DW].[DimGeografia]') AND name = N'CX_DimGeografia')
CREATE CLUSTERED COLUMNSTORE INDEX [CX_DimGeografia] ON [DW].[DimGeografia]
ON [PRIMARY];
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[DW].[DimGeografia]') AND name = N'PK_DimGeografia')
ALTER TABLE [DW].[DimGeografia] ADD CONSTRAINT [PK_DimGeografia] PRIMARY KEY NONCLUSTERED
(
	[GeografiaSKId] ASC
) ON [PRIMARY];
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[DW].[DimGeografia]') AND name = N'UX_DimGeografia_1')
CREATE UNIQUE NONCLUSTERED INDEX [UX_DimGeografia_1] ON [DW].[DimGeografia] 
(
	[PaisId] ASC,
	[DepartamentoId] ASC,
	[MunicipioId] ASC
) ON [PRIMARY];
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[DW].[DimGeografia]') AND name = N'UX_DimGeografia_2')
CREATE UNIQUE NONCLUSTERED INDEX [UX_DimGeografia_2] ON [DW].[DimGeografia] 
(
	[PaisId] ASC,
	[DepartamentoId] ASC,
	[Municipio] ASC
) ON [PRIMARY];
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimGeografia', N'COLUMN',N'GeografiaSKId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Clave subrogada geografia, para identificar un registro.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimGeografia', @level2type=N'COLUMN',@level2name=N'GeografiaSKId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimGeografia', N'COLUMN',N'PaisId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de pais.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimGeografia', @level2type=N'COLUMN',@level2name=N'PaisId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimGeografia', N'COLUMN',N'Pais'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de pais.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimGeografia', @level2type=N'COLUMN',@level2name=N'Pais'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimGeografia', N'COLUMN',N'DepartamentoId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de departamento.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimGeografia', @level2type=N'COLUMN',@level2name=N'DepartamentoId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimGeografia', N'COLUMN',N'Departamento'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de departamento.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimGeografia', @level2type=N'COLUMN',@level2name=N'Departamento'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimGeografia', N'COLUMN',N'MunicipioId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de municipio.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimGeografia', @level2type=N'COLUMN',@level2name=N'MunicipioId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimGeografia', N'COLUMN',N'Municipio'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de municipio.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimGeografia', @level2type=N'COLUMN',@level2name=N'Municipio'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimGeografia', N'COLUMN',N'AreaId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de area.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimGeografia', @level2type=N'COLUMN',@level2name=N'AreaId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimGeografia', N'COLUMN',N'Area'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de area.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimGeografia', @level2type=N'COLUMN',@level2name=N'Area'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimGeografia', N'COLUMN',N'SubAreaId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de subarea.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimGeografia', @level2type=N'COLUMN',@level2name=N'SubAreaId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimGeografia', N'COLUMN',N'SubArea'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de subarea.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimGeografia', @level2type=N'COLUMN',@level2name=N'SubArea'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimGeografia', N'COLUMN',N'BitacoraId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de bitacora de proceso.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimGeografia', @level2type=N'COLUMN',@level2name=N'BitacoraId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimGeografia', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Almacena datos maestros de geografia.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimGeografia'
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DW].[DimMercado]') AND type in (N'U'))
BEGIN
CREATE TABLE [DW].[DimMercado](
	[MercadoSKId] [smallint] IDENTITY(1,1) NOT NULL,
	[Mercado] [varchar](50) NOT NULL,
	[BitacoraId] [bigint] NULL,
 CONSTRAINT [PK_DimMercado] PRIMARY KEY CLUSTERED 
(
	[MercadoSKId] ASC
) ON [PRIMARY]
) ON [PRIMARY];
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[DW].[DimMercado]') AND name = N'UX_DimMercado_1')
CREATE UNIQUE NONCLUSTERED INDEX [UX_DimMercado_1] ON [DW].[DimMercado] 
(
	[Mercado] ASC
) ON [PRIMARY];
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimMercado', N'COLUMN',N'MercadoSKId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Clave subrogada mercado de energia, para identificar un registro.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimMercado', @level2type=N'COLUMN',@level2name=N'MercadoSKId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimMercado', N'COLUMN',N'Mercado'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre del tipo de mercado, por ejemplo, regulado y no regulado.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimMercado', @level2type=N'COLUMN',@level2name=N'Mercado'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimMercado', N'COLUMN',N'BitacoraId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de bitacora de proceso.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimMercado', @level2type=N'COLUMN',@level2name=N'BitacoraId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'DimMercado', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Almacena datos maestros de tipos de mercados de energia.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'DimMercado'
GO

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - End script: A05Table_Dim.sql'
PRINT '------------------------------------------------------------------------'
GO
