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
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - Start script: A03Table_Util.sql'
PRINT '------------------------------------------------------------------------'
GO

USE [$(DATABASE_NAME_DW)];

/* ========================================================================== 
UTILIDADES DE USO GENERAL
========================================================================== */
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[ChangeDateForDim]') AND type in (N'U'))
BEGIN
CREATE TABLE [Utility].[ChangeDateForDim](
	[TableName] [nvarchar](128) NOT NULL,
	[UseCurrentDate] [bit] NOT NULL,
	[DaysToDecrease] [smallint] NOT NULL CONSTRAINT [DF_ChangeDateForDim_DaysToDecrease] DEFAULT (0), 
	[FechaIni] [date] NOT NULL,
	[FechaFin] [date] NULL,
 CONSTRAINT [PK_ChangeDateForDim] PRIMARY KEY CLUSTERED 
(
	[TableName] ASC,
	[FechaIni] ASC
) ON [PRIMARY]
) ON [PRIMARY];
END
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ChangeDateForDim', N'COLUMN',N'TableName'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de tabla de dimension tipo 2' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ChangeDateForDim', @level2type=N'COLUMN',@level2name=N'TableName'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ChangeDateForDim', N'COLUMN',N'UseCurrentDate'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Si es verdadero utiliza la fecha actual como fecha de cambio, de lo contrario usa una fecha minima, por ejemplo: 1900-01-01.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ChangeDateForDim', @level2type=N'COLUMN',@level2name=N'UseCurrentDate'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ChangeDateForDim', N'COLUMN',N'DaysToDecrease'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Dias a disminuir a la fecha actual.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ChangeDateForDim', @level2type=N'COLUMN',@level2name=N'DaysToDecrease'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ChangeDateForDim', N'COLUMN',N'FechaIni'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha inicio de vigencia del registro.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ChangeDateForDim', @level2type=N'COLUMN',@level2name=N'FechaIni'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ChangeDateForDim', N'COLUMN',N'FechaFin'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha fin de vigencia del registro.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ChangeDateForDim', @level2type=N'COLUMN',@level2name=N'FechaFin'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ChangeDateForDim', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Almacena fecha de cambio para dimensiones tipo 2, utilizada cuando los datos origen no manejan vigencia o la fecha de cambio es nula.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ChangeDateForDim'
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[ParameterKeyValue]') AND type in (N'U'))
BEGIN
CREATE TABLE [Utility].[ParameterKeyValue](
	[Process] [nvarchar](200) NOT NULL,
	[KeyName] [nvarchar](128) NOT NULL,
	[KeyValue] [nvarchar] (4000) NULL,
	[DateRun] [datetime] NOT NULL CONSTRAINT [DF_ParameterKeyValue_DateRun] DEFAULT (GetDate()),
	[BitacoraId] [bigint] NULL,
 CONSTRAINT [PK_ParameterKeyValue] PRIMARY KEY CLUSTERED 
(
	[Process] ASC,
	[KeyName] ASC
) 
) 
END
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ParameterKeyValue', N'COLUMN',N'Process'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre del proceso. Por ejemplo nombre de Job o ETL.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ParameterKeyValue', @level2type=N'COLUMN',@level2name=N'Process'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ParameterKeyValue', N'COLUMN',N'KeyName'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre del parametro.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ParameterKeyValue', @level2type=N'COLUMN',@level2name=N'KeyName'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ParameterKeyValue', N'COLUMN',N'KeyValue'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Valor del parámetro. El sistema que utiliza los datos debe convertir al Type de datos apropiado. Por ejemplo para fechas utilice el formato YYYY-MM-DD.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ParameterKeyValue', @level2type=N'COLUMN',@level2name=N'KeyValue'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ParameterKeyValue', N'COLUMN',N'DateRun'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de ejecucion.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ParameterKeyValue', @level2type=N'COLUMN',@level2name=N'DateRun'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ParameterKeyValue', N'COLUMN',N'BitacoraId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo del registro de bitacora. FK a [Audit].[Bitacora].' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ParameterKeyValue', @level2type=N'COLUMN',@level2name=N'BitacoraId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ParameterKeyValue', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Almacena parámetros de ejecucion de procesos como jobs y ETLs. Consulte el SP: [Utility].[spJob_StartJob_ParameterKeyValue].' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ParameterKeyValue'
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[SpecialDate]') AND type in (N'U'))
BEGIN
 CREATE TABLE [Utility].[SpecialDate](
	[DateId] [date] NOT NULL,
	[Type] [nvarchar](10) NOT NULL,
 CONSTRAINT [PK_SpecialDate] PRIMARY KEY CLUSTERED 
(
	[DateId] ASC
) 
) 
END
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'SpecialDate', N'COLUMN',N'DateId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de día festivo o día especial.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'SpecialDate', @level2type=N'COLUMN',@level2name=N'DateId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'SpecialDate', N'COLUMN',N'Type'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Type de día (Festivo, Aniversario).' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'SpecialDate', @level2type=N'COLUMN',@level2name=N'Type'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'SpecialDate', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Almacena días festivos y fechas especiales.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'SpecialDate'
GO

/* ========================================================================== 
TABLAS PARA CONTROL DE EJECUCION DE PROCESOS
========================================================================== */
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[ScheduleSystem]') AND type in (N'U'))
BEGIN
CREATE TABLE [Utility].[ScheduleSystem](
	[ScheduleId] [int] NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Period] [nvarchar](10) NOT NULL CONSTRAINT [DF_ScheduleSystem_Periodo] DEFAULT ('Dia')
	 CONSTRAINT [CK_ScheduleSystem_Period] CHECK ([Period] IN ('UnaVez', 'Dia', 'Semana', 'Mes')),
	[PeriodHowMany] [smallint] NOT NULL,
    [DayPeriod] [nvarchar](10) NOT NULL CONSTRAINT [DF_ScheduleSystem_DayPeriod] DEFAULT ('UnaVez')
	 CONSTRAINT [CK_ScheduleSystem_DayPeriod] CHECK ([DayPeriod] IN ('UnaVez', 'Segundos', 'Minutos', 'Horas')),
    [DayHowMany] [tinyint] NOT NULL,
	[DayHourStart] [time] NULL,
	[DayHourEnd] [time] NULL,
    [Monday] [bit] NOT NULL CONSTRAINT [DF_ScheduleSystem_Lunes] DEFAULT (1),
    [Tuesday] [bit] NOT NULL CONSTRAINT [DF_ScheduleSystem_Martes] DEFAULT (1),
    [Wednesday] [bit] NOT NULL CONSTRAINT [DF_ScheduleSystem_Miercoles] DEFAULT (1),
    [Thursday] [bit] NOT NULL CONSTRAINT [DF_ScheduleSystem_Jueves] DEFAULT (1),
    [Fryday] [bit] NOT NULL CONSTRAINT [DF_ScheduleSystem_Viernes] DEFAULT (1),
    [Saturday] [bit] NOT NULL CONSTRAINT [DF_ScheduleSystem_Sabado] DEFAULT (1),
    [Sunday] [bit] NOT NULL CONSTRAINT [DF_ScheduleSystem_Domingo] DEFAULT (1),
    [OccursDayOfMonth] [bit] NOT NULL CONSTRAINT [DF_ScheduleSystem_OccursDayOfMonth] DEFAULT (1),
    [DayOccurs] [tinyint] NOT NULL CONSTRAINT [DF_ScheduleSystem_DayOccurs] DEFAULT (1)
	 CONSTRAINT [CK_ScheduleSystem_DayOccurs] CHECK ([DayOccurs] >= 1 AND [DayOccurs] <= 31),
    [OccursThe] [nvarchar](10) NOT NULL CONSTRAINT [DF_ScheduleSystem_OccursThe] DEFAULT ('Primer')
	 CONSTRAINT [CK_ScheduleSystem_OccursThe] CHECK ([OccursThe] IN ('Primer', 'Segundo', 'Tercero', 'Cuarto', 'Ultimo')),
    [OccursTheDay] [nvarchar](15) NOT NULL CONSTRAINT [DF_ScheduleSystem_OccursTheDay] DEFAULT ('Dia')
	 CONSTRAINT [CK_ScheduleSystem_OccursTheDay] CHECK ([OccursTheDay] IN ('Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado', 'Domingo', 'Dia', 'DiaSemana', 'DiaFinSemana')),
	[DateStart] [date] NOT NULL,
	[DateEnd] [date] NULL,
	[UseNotification] [bit] NOT NULL CONSTRAINT [DF_ScheduleSystem_UsarNotificacion] DEFAULT (0),
	[NotificationDaysBefore] [tinyint] NOT NULL,
	[NotificationDaysIsEnable] [bit] NOT NULL CONSTRAINT [DF_ScheduleSystem_NotificationDaysIsEnable] DEFAULT (0),
	[NotificationDaysFrencence] [tinyint] NOT NULL,
	[NotificationSubject] [nvarchar](500) NULL,
	[NotificationBody] [nvarchar](4000) NULL,
	[Description] [nvarchar](500) NULL,
 CONSTRAINT [PK_ScheduleSystem] PRIMARY KEY CLUSTERED 
(
	[ScheduleId] ASC
) 
) 
END
GO

IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[Utility].[CK_ScheduleSystem_DateStart_DateEnd]') AND parent_object_id = OBJECT_ID(N'[Utility].[ScheduleSystem]'))
ALTER TABLE [Utility].[ScheduleSystem]  WITH CHECK ADD  CONSTRAINT [CK_ScheduleSystem_DateStart_DateEnd] CHECK  ([DateEnd] IS NULL OR [DateEnd] >= [DateStart])
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[Utility].[CK_ScheduleSystem_DateStart_DateEnd]') AND parent_object_id = OBJECT_ID(N'[Utility].[ScheduleSystem]'))
ALTER TABLE [Utility].[ScheduleSystem] CHECK CONSTRAINT [CK_ScheduleSystem_DateStart_DateEnd]
GO

IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[Utility].[CK_ScheduleSystem_HoraIni_HoraFin]') AND parent_object_id = OBJECT_ID(N'[Utility].[ScheduleSystem]'))
ALTER TABLE [Utility].[ScheduleSystem]  WITH CHECK ADD  CONSTRAINT [CK_ScheduleSystem_HoraIni_HoraFin] CHECK  ([DayHourEnd] >= [DayHourStart])
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[Utility].[CK_ScheduleSystem_HoraIni_HoraFin]') AND parent_object_id = OBJECT_ID(N'[Utility].[ScheduleSystem]'))
ALTER TABLE [Utility].[ScheduleSystem] CHECK CONSTRAINT [CK_ScheduleSystem_HoraIni_HoraFin]
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ScheduleSystem', N'COLUMN',N'ScheduleId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de agenda.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ScheduleSystem', @level2type=N'COLUMN',@level2name=N'ScheduleId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ScheduleSystem', N'COLUMN',N'Name'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre para identificar la agenda.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ScheduleSystem', @level2type=N'COLUMN',@level2name=N'Name'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ScheduleSystem', N'COLUMN',N'Period'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de tipo de frecuencia de ejecucion: UnaVez, Dia, Semana, Mes.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ScheduleSystem', @level2type=N'COLUMN',@level2name=N'Period'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ScheduleSystem', N'COLUMN',N'PeriodHowMany'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Cada cuantos períodos repetir [Period]. Por ejemplo cada 3 días, cada 2 semanas, cada 3 meses.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ScheduleSystem', @level2type=N'COLUMN',@level2name=N'PeriodHowMany'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ScheduleSystem', N'COLUMN',N'DayPeriod'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tipo de frecuencia diaria. Frecuencia diaria: UnaVez, Segundos, Minutos, Horas.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ScheduleSystem', @level2type=N'COLUMN',@level2name=N'DayPeriod'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ScheduleSystem', N'COLUMN',N'DayHowMany'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Cada cuantos periodos [DayPeriod] debe ejecutar el evento. Por ejemplo cada 6 horas.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ScheduleSystem', @level2type=N'COLUMN',@level2name=N'DayHowMany'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ScheduleSystem', N'COLUMN',N'DayHourStart'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Hora del días desde la cual iniciar a ejecucion de eventos.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ScheduleSystem', @level2type=N'COLUMN',@level2name=N'DayHourStart'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ScheduleSystem', N'COLUMN',N'DayHourEnd'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Hora del día de finalización de ejecucion de eventos.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ScheduleSystem', @level2type=N'COLUMN',@level2name=N'DayHourEnd'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ScheduleSystem', N'COLUMN',N'Monday'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Para programacion semanal indica si debe ejecutar el día lunes.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ScheduleSystem', @level2type=N'COLUMN',@level2name=N'Monday'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ScheduleSystem', N'COLUMN',N'Tuesday'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Para programacion semanal indica si debe ejecutar el día martes.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ScheduleSystem', @level2type=N'COLUMN',@level2name=N'Tuesday'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ScheduleSystem', N'COLUMN',N'Wednesday'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Para programacion semanal indica si debe ejecutar el día miercoles.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ScheduleSystem', @level2type=N'COLUMN',@level2name=N'Wednesday'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ScheduleSystem', N'COLUMN',N'Thursday'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Para programacion semanal indica si debe ejecutar el día jueves.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ScheduleSystem', @level2type=N'COLUMN',@level2name=N'Thursday'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ScheduleSystem', N'COLUMN',N'Fryday'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Para programacion semanal indica si debe ejecutar el día viernes.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ScheduleSystem', @level2type=N'COLUMN',@level2name=N'Fryday'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ScheduleSystem', N'COLUMN',N'Saturday'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Para programacion semanal indica si debe ejecutar el día sabado.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ScheduleSystem', @level2type=N'COLUMN',@level2name=N'Saturday'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ScheduleSystem', N'COLUMN',N'Sunday'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Para programacion semanal indica si debe ejecutar el día domingo.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ScheduleSystem', @level2type=N'COLUMN',@level2name=N'Sunday'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ScheduleSystem', N'COLUMN',N'OccursDayOfMonth'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Para programacion mensual indica si los eventos ocurren: 0: un tipo de día como primer lunes del mes, 1: un número de día del mes.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ScheduleSystem', @level2type=N'COLUMN',@level2name=N'OccursDayOfMonth'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ScheduleSystem', N'COLUMN',N'DayOccurs'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Para programacion mensual, si [OccursDayOfMonth] = 1, indica el número del día del mes que debe ejecutar el evento.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ScheduleSystem', @level2type=N'COLUMN',@level2name=N'DayOccurs'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ScheduleSystem', N'COLUMN',N'OccursThe'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Para programacion mensual, si [OccursDayOfMonth] = 0 y según [OccursTheDay], indica el número de ocurrencia: Primer, Segundo, Tercero, Cuarto, Ultimo.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ScheduleSystem', @level2type=N'COLUMN',@level2name=N'OccursThe'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ScheduleSystem', N'COLUMN',N'OccursTheDay'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Para programacion mensual, si [OccursDayOfMonth] = 0, indica el tipo de ocurrencia mensual: Lunes, Martes, Miercoles, Jueves, Viernes, Sabado, Domingo, Dia, DiaSemana, DiaFinSemana.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ScheduleSystem', @level2type=N'COLUMN',@level2name=N'OccursTheDay'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ScheduleSystem', N'COLUMN',N'DateStart'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha inicio de vigencia del plazo.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ScheduleSystem', @level2type=N'COLUMN',@level2name=N'DateStart'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ScheduleSystem', N'COLUMN',N'DateEnd'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha fin de vigencia del plazo.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ScheduleSystem', @level2type=N'COLUMN',@level2name=N'DateEnd'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ScheduleSystem', N'COLUMN',N'UseNotification'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Indica si utiliza mensaje de notificación.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ScheduleSystem', @level2type=N'COLUMN',@level2name=N'UseNotification'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ScheduleSystem', N'COLUMN',N'NotificationDaysBefore'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Número de días de anticipación en los cuales empieza el envio de la notificación.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ScheduleSystem', @level2type=N'COLUMN',@level2name=N'NotificationDaysBefore'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ScheduleSystem', N'COLUMN',N'NotificationDaysIsEnable'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Indica si los días de anticipación son hábiles o calendario. 0: Día calendario, 1: Día hábil.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ScheduleSystem', @level2type=N'COLUMN',@level2name=N'NotificationDaysIsEnable'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ScheduleSystem', N'COLUMN',N'NotificationDaysFrencence'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Días de frecuencia entre cada envió de notificación.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ScheduleSystem', @level2type=N'COLUMN',@level2name=N'NotificationDaysFrencence'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ScheduleSystem', N'COLUMN',N'NotificationSubject'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Asunto del mensaje de notificación.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ScheduleSystem', @level2type=N'COLUMN',@level2name=N'NotificationSubject'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ScheduleSystem', N'COLUMN',N'NotificationBody'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Cuerpo del mensaje de notificación.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ScheduleSystem', @level2type=N'COLUMN',@level2name=N'NotificationBody'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ScheduleSystem', N'COLUMN',N'Description'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Descripcion de la agenda.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ScheduleSystem', @level2type=N'COLUMN',@level2name=N'Description'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ScheduleSystem', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Almacena agenda de ejecucion de procesos, por ejemplo, la fecha de ejecucion de una ETL.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ScheduleSystem'
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[ModelLoad]') AND type in (N'U'))
BEGIN
CREATE TABLE [Utility].[ModelLoad](
	[ModelId] [nvarchar](12) NOT NULL,
	[SequenceId] [smallint] NOT NULL,
	[ModuleId] [int] NOT NULL,
	[ModelProgId] [nvarchar](12) NOT NULL,
 CONSTRAINT [PK_ModelLoad] PRIMARY KEY CLUSTERED 
(
	[ModelId] ASC,
	[SequenceId] ASC
) 
) 
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Utility].[ModelLoad]') AND name = N'IX_ModelLoad_1')
CREATE NONCLUSTERED INDEX [IX_ModelLoad_1] ON [Utility].[ModelLoad] 
(
	[ModuleId] ASC
)
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModelLoad', N'COLUMN',N'ModelId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo del modelo. FK a [Utility].[ModelSystem].' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModelLoad', @level2type=N'COLUMN',@level2name=N'ModelId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModelLoad', N'COLUMN',N'SequenceId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Numero de secuencia.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModelLoad', @level2type=N'COLUMN',@level2name=N'SequenceId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModelLoad', N'COLUMN',N'ModuleId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de módulo. FK a [Utility].[ModuleSystem].' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModelLoad', @level2type=N'COLUMN',@level2name=N'ModuleId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModelLoad', N'COLUMN',N'ModelProgId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo del modelo a ser programado en el modulo. FK a [Utility].[ModelSystem].' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModelLoad', @level2type=N'COLUMN',@level2name=N'ModelProgId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModelLoad', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Almacena el orden de actividades a ser ejecutados para cargar los modelos del sistema.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModelLoad'
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[ModelParameter]') AND type in (N'U'))
BEGIN
CREATE TABLE [Utility].[ModelParameter](
	[ModelId] [nvarchar](12) NOT NULL,
	[ParameterId] [int] NOT NULL,
	[Value] [nvarchar](4000) NULL,
	[Description] [nvarchar](500) NOT NULL,
 CONSTRAINT [PK_ModelParameter] PRIMARY KEY CLUSTERED 
(
	[ModelId] ASC,
	[ParameterId] ASC
) ON [PRIMARY]
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModelParameter', N'COLUMN',N'ModelId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo del modelo. FK a [Utility].[ModelSystem].' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModelParameter', @level2type=N'COLUMN',@level2name=N'ModelId'
GO

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModelParameter', N'COLUMN',N'ParameterId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Numero de parametro.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModelParameter', @level2type=N'COLUMN',@level2name=N'ParameterId'
GO

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModelParameter', N'COLUMN',N'Value'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Valor del parametro para el modelo.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModelParameter', @level2type=N'COLUMN',@level2name=N'Value'
GO

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModelParameter', N'COLUMN',N'Description'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Descripcion del parametro a utilizar en el modelo.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModelParameter', @level2type=N'COLUMN',@level2name=N'Description'
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[ModelSchedule]') AND type in (N'U'))
BEGIN
CREATE TABLE [Utility].[ModelSchedule](
	[ModelId] [nvarchar](12) NOT NULL,
	[ScheduleId] [int] NOT NULL,
	[UseVersion] [bit] NOT NULL CONSTRAINT [DF_ModelSchedule_UseVersion] DEFAULT (0),
	[PeriodType] [nvarchar](12) NOT NULL CONSTRAINT [DF_ModelSchedule_PeriodType] DEFAULT ('Dia')
	 CONSTRAINT [CK_ModelSchedule_PeriodType] CHECK ([PeriodType] IN ('Dia', 'Semana', 'Mes', 'Bimestre', 'Trimestre', 'Semestre', 'Año')),
    [PeriodQuantity] [smallint] NOT NULL,
	[PeriodTypeBefore] [nvarchar](12) NOT NULL CONSTRAINT [DF_ModelSchedule_PeriodTypeBefore] DEFAULT ('Dia')
	 CONSTRAINT [CK_ModelSchedule_PeriodTypeBefore] CHECK ([PeriodTypeBefore] IN ('Dia', 'Semana', 'Mes', 'Bimestre', 'Trimestre', 'Semestre', 'Año')),
    [PeriodsBefore] [smallint] NOT NULL,
	[Enabled] [bit] NOT NULL  CONSTRAINT [DF_ModelSchedule_Activa] DEFAULT (1),
	[Description] [nvarchar](500) NULL
 CONSTRAINT [PK_ModelSchedule] PRIMARY KEY CLUSTERED 
(
	[ModelId] ASC,
	[ScheduleId] ASC
) 
) 
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Utility].[ModelSchedule]') AND name = N'IX_ModelSchedule_1')
CREATE NONCLUSTERED INDEX [IX_ModelSchedule_1] ON [Utility].[ModelSchedule] 
(
	[ScheduleId] ASC
)
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModelSchedule', N'COLUMN',N'ModelId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de modelo. FK a [Utility].[ModelSystem]' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModelSchedule', @level2type=N'COLUMN',@level2name=N'ModelId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModelSchedule', N'COLUMN',N'ScheduleId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de agenda de ejecucion del proceso. FK a [Utility].[ScheduleSystem].' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModelSchedule', @level2type=N'COLUMN',@level2name=N'ScheduleId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModelSchedule', N'COLUMN',N'UseVersion'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Indica si utiliza una tabla de version: 0: El rango de fechas de proceso es establecido con los datos de esta tabla, 1: el rango de fechas de proceso es tomado de la tabla de versiones: [Utility].[ModelVersion].' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModelSchedule', @level2type=N'COLUMN',@level2name=N'UseVersion'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModelSchedule', N'COLUMN',N'PeriodType'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tipo de periodo de tiempo a ser procesado: Dia, Semana, Mes, Bimestre, Trimestre, Semestre, Año.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModelSchedule', @level2type=N'COLUMN',@level2name=N'PeriodType'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModelSchedule', N'COLUMN',N'PeriodQuantity'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Número de períodos de tiempo a ser procesados. Por ejemplo 10 días.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModelSchedule', @level2type=N'COLUMN',@level2name=N'PeriodQuantity'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModelSchedule', N'COLUMN',N'PeriodTypeBefore'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tipo de periodo de tiempo anterior usado en el campo: [PeriodsBefore], para establecer la fecha fin de los datos a ser procesados: Dia, Semana, Mes, Bimestre, Trimestre, Semestre, Año.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModelSchedule', @level2type=N'COLUMN',@level2name=N'PeriodTypeBefore'
GO	
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModelSchedule', N'COLUMN',N'PeriodsBefore'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Número de períodos anteriores a la fecha actual para establecer la fecha fin de los datos a ser procesados. Puede ser 0 o negativo. Por ejemplo si el valor es uno (1): para tipo periodo diario es el último día es el día anterior, si es mensual es el último día del mes anterior, si anual es ultimo día del año anterior.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModelSchedule', @level2type=N'COLUMN',@level2name=N'PeriodsBefore'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModelSchedule', N'COLUMN',N'Enabled'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Indica si la agenda esta activa o no. Cuando esta inactiva, no son adicionado filas a la tabla: [Utility].[ModuleProgramming] por los SP del sistema.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModelSchedule', @level2type=N'COLUMN',@level2name=N'Enabled'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModelSchedule', N'COLUMN',N'Description'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Descripcion de la agenda para el modelo.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModelSchedule', @level2type=N'COLUMN',@level2name=N'Description'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModelSchedule', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Almacena la(s) agenda(s) o dia de ejecucion y el rango de fechas (consultas de carga, procesamiento particiones, etc) para procesar modelos.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModelSchedule'
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[ModelSystem]') AND type in (N'U'))
BEGIN
CREATE TABLE [Utility].[ModelSystem](
	[ModelId] [nvarchar](12) NOT NULL,
	[Name] [nvarchar](128) NOT NULL,
	[AppName] [nvarchar](128) NOT NULL,
	[TypeId] [nvarchar](12) NOT NULL,
	[UseDatesProcess] [bit] NOT NULL,
	[UseVersion] [bit] NOT NULL CONSTRAINT [DF_ModelSystem_UseVersion] DEFAULT (0),
	[ReloadPeriodType] [nvarchar](12) NOT NULL CONSTRAINT [DF_ModelSystem_ReloadPeriodType] DEFAULT ('Mes')
	 CONSTRAINT [CK_ModelSystem_ReloadPeriodType] CHECK ([ReloadPeriodType] IN ('Dia', 'Semana', 'Mes', 'Bimestre', 'Trimestre', 'Semestre', 'Año')),
	[Description] [nvarchar](500) NOT NULL
 CONSTRAINT [PK_ModelSystem] PRIMARY KEY CLUSTERED 
(
	[ModelId] ASC
) 
) 
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Utility].[ModelSystem]') AND name = N'UX_ModelSystem_1')
CREATE UNIQUE NONCLUSTERED INDEX [UX_ModelSystem_1] ON [Utility].[ModelSystem] 
(
	[Name] ASC,
	[TypeId] ASC
) 
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Utility].[ModelSystem]') AND name = N'IX_ModelSystem_1')
CREATE NONCLUSTERED INDEX [IX_ModelSystem_1] ON [Utility].[ModelSystem] 
(
	[AppName] ASC
) 
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModelSystem', N'COLUMN',N'ModelId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de modelo.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModelSystem', @level2type=N'COLUMN',@level2name=N'ModelId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModelSystem', N'COLUMN',N'Name'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de modelo.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModelSystem', @level2type=N'COLUMN',@level2name=N'Name'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModelSystem', N'COLUMN',N'AppName'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de modelo en la aplicación. Por ejemplo la propiedad id de un grupo de metricas de un cubo de datos.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModelSystem', @level2type=N'COLUMN',@level2name=N'AppName'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModelSystem', N'COLUMN',N'TypeId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de tipo de modelo. Por ejemplo: DW, Cubo, App.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModelSystem', @level2type=N'COLUMN',@level2name=N'TypeId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModelSystem', N'COLUMN',N'UseDatesProcess'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Indica si utiliza fechas de proceso o si ejecuta una sola vez.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModelSystem', @level2type=N'COLUMN',@level2name=N'UseDatesProcess'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModelSystem', N'COLUMN',N'UseVersion'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Indica si utiliza una tabla de version: 0: El rango de fechas de proceso es establecido en la agenda del modelo o en forma manual, 1: el rango de fechas de proceso es tomado de la tabla de versiones: [Utility].[ModelVersion].' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModelSystem', @level2type=N'COLUMN',@level2name=N'UseVersion'
GO	
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModelSystem', N'COLUMN',N'ReloadPeriodType'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tipo de periodo de tiempo cuando programa recarga con procedimiento almacenado: Dia, Semana, Mes, Bimestre, Trimestre, Semestre, Año.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModelSystem', @level2type=N'COLUMN',@level2name=N'ReloadPeriodType'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModelSystem', N'COLUMN',N'Description'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Descripcion del modelo.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModelSystem', @level2type=N'COLUMN',@level2name=N'Description'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModelSystem', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Almacena los modelos del sistema. Un modelo es como un grupo de metricas el cual esta formada por Fact(s) y sus dimensiones relacionadas.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModelSystem'
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[ModelVersion]') AND type in (N'U'))
BEGIN
CREATE TABLE [Utility].[ModelVersion](
	[DateVersion] [date] NOT NULL,
	[ModelId] [nvarchar](12) NOT NULL,
	[DateStart] [date] NOT NULL,
	[DateEnd] [date] NOT NULL,
	[Version] [smallint] NOT NULL,
	[VersionId] [nvarchar](12) NOT NULL,
	[StateId] [tinyint] NOT NULL,
	[CreateBitacoraId] [bigint] NULL,
	[CreateDate] [datetime] NOT NULL CONSTRAINT [DF_ModelVersion_CreateDate] DEFAULT (GetDate()),
	[UpdateBitacoraId] [bigint] NULL,
	[UpdateDate] [datetime] NULL CONSTRAINT [DF_ModelVersion_UpdateDate] DEFAULT (GetDate()),
 CONSTRAINT [PK_ModelVersion] PRIMARY KEY CLUSTERED 
(
	[DateVersion] ASC,
	[ModelId] ASC
) 
) 
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Utility].[ModelVersion]') AND name = N'UX_ModelVersion_1')
CREATE UNIQUE NONCLUSTERED INDEX [UX_ModelVersion_1] ON [Utility].[ModelVersion] 
(
	[DateStart] ASC,
	[ModelId] ASC
) 
GO

IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[Utility].[CK_ModelVersion_DateStart_DateEnd]') AND parent_object_id = OBJECT_ID(N'[Utility].[ModelVersion]'))
ALTER TABLE [Utility].[ModelVersion]  WITH CHECK ADD  CONSTRAINT [CK_ModelVersion_DateStart_DateEnd] CHECK  ([DateEnd] IS NULL OR [DateEnd] >= [DateStart])
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[Utility].[CK_ModelVersion_DateStart_DateEnd]') AND parent_object_id = OBJECT_ID(N'[Utility].[ModelVersion]'))
ALTER TABLE [Utility].[ModelVersion] CHECK CONSTRAINT [CK_ModelVersion_DateStart_DateEnd]
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModelVersion', N'COLUMN',N'DateVersion'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de version de los datos.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModelVersion', @level2type=N'COLUMN',@level2name=N'DateVersion'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModelVersion', N'COLUMN',N'ModelId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de modelo. FK a [Utility].[ModelSystem].' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModelVersion', @level2type=N'COLUMN',@level2name=N'ModelId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModelVersion', N'COLUMN',N'DateStart'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha inicio de carga de datos.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModelVersion', @level2type=N'COLUMN',@level2name=N'DateStart'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModelVersion', N'COLUMN',N'DateEnd'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha fin de carga de datos.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModelVersion', @level2type=N'COLUMN',@level2name=N'DateEnd'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModelVersion', N'COLUMN',N'Version'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de version (para versiones numéricas).' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModelVersion', @level2type=N'COLUMN',@level2name=N'Version'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModelVersion', N'COLUMN',N'VersionId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de version (para versiones texto).' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModelVersion', @level2type=N'COLUMN',@level2name=N'VersionId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModelVersion', N'COLUMN',N'StateId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de estado de proceso. FK a [Audit].[BitacoraState].' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModelVersion', @level2type=N'COLUMN',@level2name=N'StateId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModelVersion', N'COLUMN',N'CreateBitacoraId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de bitacora de creación del registro.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModelVersion', @level2type=N'COLUMN',@level2name=N'CreateBitacoraId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModelVersion', N'COLUMN',N'CreateDate'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creación del registro.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModelVersion', @level2type=N'COLUMN',@level2name=N'CreateDate'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModelVersion', N'COLUMN',N'UpdateBitacoraId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de bitacora de modificación del registro.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModelVersion', @level2type=N'COLUMN',@level2name=N'UpdateBitacoraId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModelVersion', N'COLUMN',N'UpdateDate'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de modificación del registro.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModelVersion', @level2type=N'COLUMN',@level2name=N'UpdateDate'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModelVersion', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Almacena codigo de version de los datos de modelos. Las versiones son creadas por ajustes o cambios en los datos con el tiempo.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModelVersion'
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[ModuleModel]') AND type in (N'U'))
BEGIN
CREATE TABLE [Utility].[ModuleModel](
	[ModuleId] [int] NOT NULL,
	[ModelId] [nvarchar](12) NOT NULL,
	[SequenceId] [smallint] NOT NULL,
 CONSTRAINT [PK_ModuleModel] PRIMARY KEY CLUSTERED 
(
	[ModuleId] ASC,
	[ModelId] ASC
) 
) 
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Utility].[ModuleModel]') AND name = N'IX_ModuleModel_1')
CREATE NONCLUSTERED INDEX [IX_ModuleModel_1] ON [Utility].[ModuleModel] 
(
	[ModelId] ASC
)
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModuleModel', N'COLUMN',N'ModelId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo del modelo. FK a [Utility].[ModelSystem].' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModuleModel', @level2type=N'COLUMN',@level2name=N'ModelId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModuleModel', N'COLUMN',N'ModuleId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de módulo. FK a [Utility].[ModuleSystem].' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModuleModel', @level2type=N'COLUMN',@level2name=N'ModuleId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModuleModel', N'COLUMN',N'SequenceId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Numero de secuencia.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModuleModel', @level2type=N'COLUMN',@level2name=N'SequenceId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModuleModel', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Almacena la secuencia de modulos (ejemplo: ETL, servicio) a ser ejecutados para procesar los modelos del sistema.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModuleModel'
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[ModuleProgramming]') AND type in (N'U'))
BEGIN
CREATE TABLE [Utility].[ModuleProgramming](
	[ProgrammingId] [bigint] IDENTITY(1,1) NOT NULL,
	[Priority] [smallint] NOT NULL,
	[ModelId] [nvarchar](12) NOT NULL,
	[SequenceId] [smallint] NOT NULL,
	[ModuleId] [int] NOT NULL,
	[ModelProgId] [nvarchar](12) NOT NULL,
	[DateVersion] [date] NOT NULL,
	[DateStart] [date] NOT NULL,
	[DateEnd] [date] NOT NULL,
	[Version] [smallint] NOT NULL,
	[VersionId] [nvarchar](12) NOT NULL,
	[StateId] [tinyint] NOT NULL,
	[DateUpdate] [dateTime] NULL,
	[BitacoraId] [bigint] NULL,
 CONSTRAINT [PK_ModuleProgramming] PRIMARY KEY CLUSTERED 
(
	[ProgrammingId] ASC
) 
) 
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Utility].[ModuleProgramming]') AND name = N'UX_ModuleProgramming_1')
CREATE UNIQUE NONCLUSTERED INDEX [UX_ModuleProgramming_1] ON [Utility].[ModuleProgramming] 
(
	[ModuleId] ASC,
	[ModelProgId] ASC,
	[DateStart] ASC
) 
GO

IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[Utility].[CK_ModuleProgramming_DateStart_DateEnd]') AND parent_object_id = OBJECT_ID(N'[Utility].[ModuleProgramming]'))
ALTER TABLE [Utility].[ModuleProgramming]  WITH CHECK ADD  CONSTRAINT [CK_ModuleProgramming_DateStart_DateEnd] CHECK  ([DateEnd] IS NULL OR [DateEnd] >= [DateStart])
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[Utility].[CK_ModuleProgramming_DateStart_DateEnd]') AND parent_object_id = OBJECT_ID(N'[Utility].[ModuleProgramming]'))
ALTER TABLE [Utility].[ModuleProgramming] CHECK CONSTRAINT [CK_ModuleProgramming_DateStart_DateEnd]
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModuleProgramming', N'COLUMN',N'ProgrammingId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de programacion de carga, autonumérico para identificar un registro.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModuleProgramming', @level2type=N'COLUMN',@level2name=N'ProgrammingId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModuleProgramming', N'COLUMN',N'Priority'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Prioridad de ejecucion.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModuleProgramming', @level2type=N'COLUMN',@level2name=N'Priority'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModuleProgramming', N'COLUMN',N'ModelId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo del modelo. FK a [Utility].[ModelSystem].' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModuleProgramming', @level2type=N'COLUMN',@level2name=N'ModelId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModuleProgramming', N'COLUMN',N'SequenceId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Numero de secuencia.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModuleProgramming', @level2type=N'COLUMN',@level2name=N'SequenceId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModuleProgramming', N'COLUMN',N'ModuleId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de modulo. FK a [Utility].[ModuleSystem].' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModuleProgramming', @level2type=N'COLUMN',@level2name=N'ModuleId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModuleProgramming', N'COLUMN',N'ModelProgId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo del modelo a ser programado en el modulo. FK a [Utility].[ModelSystem].' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModuleProgramming', @level2type=N'COLUMN',@level2name=N'ModelProgId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModuleProgramming', N'COLUMN',N'DateVersion'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de version de los datos.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModuleProgramming', @level2type=N'COLUMN',@level2name=N'DateVersion'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModuleProgramming', N'COLUMN',N'DateStart'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha inicio de carga de datos.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModuleProgramming', @level2type=N'COLUMN',@level2name=N'DateStart'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModuleProgramming', N'COLUMN',N'DateEnd'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha fin de carga de datos.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModuleProgramming', @level2type=N'COLUMN',@level2name=N'DateEnd'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModuleProgramming', N'COLUMN',N'Version'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de version a ser procesada (para versiones numéricas).' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModuleProgramming', @level2type=N'COLUMN',@level2name=N'Version'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModuleProgramming', N'COLUMN',N'VersionId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de version a ser procesada (para versiones texto).' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModuleProgramming', @level2type=N'COLUMN',@level2name=N'VersionId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModuleProgramming', N'COLUMN',N'StateId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de estado de proceso. FK a [Audit].[BitacoraState].' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModuleProgramming', @level2type=N'COLUMN',@level2name=N'StateId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModuleProgramming', N'COLUMN',N'DateUpdate'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de actualizacion.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModuleProgramming', @level2type=N'COLUMN',@level2name=N'DateUpdate'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModuleProgramming', N'COLUMN',N'BitacoraId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de bitacora de ejecucion.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModuleProgramming', @level2type=N'COLUMN',@level2name=N'BitacoraId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModuleProgramming', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Almacena programacion de ejecucion de modulos, por ejemplo, la ejecucion de ETLs para cargar un data warehouse.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModuleProgramming'
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[ModuleSystem]') AND type in (N'U'))
BEGIN
CREATE TABLE [Utility].[ModuleSystem](
	[ModuleId] [int] NOT NULL,
	[Name] [nvarchar](128) NOT NULL,
	[AppName] [nvarchar](128) NOT NULL,
	[TypeId] [nvarchar](12) NOT NULL,
	[ProcessTypeId] [nvarchar](12) NOT NULL,
	[Description] [nvarchar](500) NOT NULL,
 CONSTRAINT [PK_ModuleSystem] PRIMARY KEY CLUSTERED 
(
	[ModuleId] ASC
) 
) 
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Utility].[ModuleSystem]') AND name = N'UX_ModuleSystem_1')
CREATE UNIQUE NONCLUSTERED INDEX [UX_ModuleSystem_1] ON [Utility].[ModuleSystem] 
(
	[Name] ASC,
	[TypeId] ASC
)
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Utility].[ModuleSystem]') AND name = N'IX_ModuleSystem_1')
CREATE NONCLUSTERED INDEX [IX_ModuleSystem_1] ON [Utility].[ModuleSystem] 
(
	[AppName] ASC
)
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModuleSystem', N'COLUMN',N'ModuleId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de módulo.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModuleSystem', @level2type=N'COLUMN',@level2name=N'ModuleId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModuleSystem', N'COLUMN',N'Name'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de módulo.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModuleSystem', @level2type=N'COLUMN',@level2name=N'Name'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModuleSystem', N'COLUMN',N'AppName'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de módulo en el Codigo de aplicación. Por ejemplo el nombre de una ETL.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModuleSystem', @level2type=N'COLUMN',@level2name=N'AppName'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModuleSystem', N'COLUMN',N'TypeId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de tipo de módulo. Por ejemplo: ETL, Menu.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModuleSystem', @level2type=N'COLUMN',@level2name=N'TypeId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModuleSystem', N'COLUMN',N'ProcessTypeId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de tipo de proceso. Por ejemplo: CALCULO, DIM_DW, DIM_SA, DIM_SA_DW, FACT_DW, FACT_SA, FACT_SA_DW, UTIL_SA_DW, CUBO.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModuleSystem', @level2type=N'COLUMN',@level2name=N'ProcessTypeId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModuleSystem', N'COLUMN',N'Description'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Descripcion del modulo.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModuleSystem', @level2type=N'COLUMN',@level2name=N'Description'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'ModuleSystem', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Almacena modulos del sistema, los modulos hacen parte de aplicaciones o programas de computo, por ejemplo, una ETL para carga de datos.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'ModuleSystem'
GO


/*====================================================================================
STAGING UTILIDADDES
==================================================================================== */
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Staging].[TmpModelVersion]') AND type in (N'U'))
BEGIN
CREATE TABLE [Staging].[TmpModelVersion](
	[TmpSKId] [int] IDENTITY(1,1) NOT NULL,
	[DateVersion] [date] NOT NULL,
	[ModelId] [nvarchar](12) NOT NULL,
	[DateStart] [date] NOT NULL,
	[DateEnd] [date] NOT NULL,
	[Version] [smallint] NOT NULL,
	[VersionId] [nvarchar](12) NOT NULL,
	[Inconsistent] [bit] NULL CONSTRAINT [DF_TmpModelVersion_Inconsistent] DEFAULT (0),
	[BitacoraId] [bigint] NULL,
 CONSTRAINT [PK_TmpModelVersion] PRIMARY KEY CLUSTERED 
(
	[TmpSKId] ASC
) ON [PRIMARY]
) ON [PRIMARY];
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[Staging].[TmpModelVersion]') AND name = N'IX_TmpModelVersion_1')
CREATE NONCLUSTERED INDEX [IX_TmpModelVersion_1] ON [Staging].[TmpModelVersion] 
(
	[DateVersion] ASC,
	[ModelId] ASC
) ON [PRIMARY];
GO

IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[Staging].[CK_TmpModelVersion_DateStart_DateEnd]') AND parent_object_id = OBJECT_ID(N'[Staging].[TmpModelVersion]'))
ALTER TABLE [Staging].[TmpModelVersion]  WITH CHECK ADD  CONSTRAINT [CK_TmpModelVersion_DateStart_DateEnd] CHECK  ([DateEnd] IS NULL OR [DateEnd] >= [DateStart])
GO
IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[Staging].[CK_TmpModelVersion_DateStart_DateEnd]') AND parent_object_id = OBJECT_ID(N'[Staging].[TmpModelVersion]'))
ALTER TABLE [Staging].[TmpModelVersion] CHECK CONSTRAINT [CK_TmpModelVersion_DateStart_DateEnd]
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpModelVersion', N'COLUMN',N'TmpSKId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Clave subrogada tabla temporal, autonumérico para identificar un registro.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpModelVersion', @level2type=N'COLUMN',@level2name=N'TmpSKId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpModelVersion', N'COLUMN',N'DateVersion'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de version de los datos.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpModelVersion', @level2type=N'COLUMN',@level2name=N'DateVersion'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpModelVersion', N'COLUMN',N'ModelId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de modelo. FK a [Staging].[ModelSystem].' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpModelVersion', @level2type=N'COLUMN',@level2name=N'ModelId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpModelVersion', N'COLUMN',N'DateStart'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha inicio de carga de datos.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpModelVersion', @level2type=N'COLUMN',@level2name=N'DateStart'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpModelVersion', N'COLUMN',N'DateEnd'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha fin de carga de datos.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpModelVersion', @level2type=N'COLUMN',@level2name=N'DateEnd'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpModelVersion', N'COLUMN',N'Version'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de version (para versiones numéricas).' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpModelVersion', @level2type=N'COLUMN',@level2name=N'Version'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpModelVersion', N'COLUMN',N'VersionId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de version (para versiones texto).' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpModelVersion', @level2type=N'COLUMN',@level2name=N'VersionId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpModelVersion', N'COLUMN',N'Inconsistent'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Indica si una fila es Inconsistent, utilizado para procesar datos.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpModelVersion', @level2type=N'COLUMN',@level2name=N'Inconsistent'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpModelVersion', N'COLUMN',N'BitacoraId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de bitacora de proceso.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpModelVersion', @level2type=N'COLUMN',@level2name=N'BitacoraId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Staging', N'TABLE',N'TmpModelVersion', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Almacena en forma termporal version ejecutada por los modelos. Las versiones son creadas por ajustes o cambios en los datos.' , @level0type=N'SCHEMA',@level0name=N'Staging', @level1type=N'TABLE',@level1name=N'TmpModelVersion'
GO

/*====================================================================================
SUBSCRIPCION UTILIDADES
==================================================================================== */
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[Subscription]') AND type in (N'U'))
BEGIN
CREATE TABLE [Utility].[Subscription](
	[SKId] [int] IDENTITY(1,1) NOT NULL,
	[FileName] [Varchar](100) NOT NULL,
	[Path] [Varchar](255) NOT NULL,
  	[RenderFormat] [Varchar](100) NOT NULL,
  	[WriteMode]    [Varchar](100) NOT NULL,
	[FileExtension]  [Varchar](5) NOT NULL,
	[UserName]       [Varchar](100) NULL,
	[Password]       [Varchar](100) NULL,
	[FileShareAccount] [Varchar](5) NOT NULL,
	[DateName] [VarChar](100) Not NULL,
 CONSTRAINT [PK_Subscription] PRIMARY KEY CLUSTERED 
(
	[SKId] ASC
) ON [PRIMARY]
) ON [PRIMARY];
END
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'Subscription', N'COLUMN',N'SKId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Clave subrogada, autonumérico para identificar un registro.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'Subscription', @level2type=N'COLUMN',@level2name=N'SKId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'Subscription', N'COLUMN',N'FileName'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre del archivo de suscripción.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'Subscription', @level2type=N'COLUMN',@level2name=N'FileName'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'Subscription', N'COLUMN',N'Path'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Ruta de almacenamiento de suscripción' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'Subscription', @level2type=N'COLUMN',@level2name=N'Path'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'Subscription', N'COLUMN',N'RenderFormat'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Formato de Renderizado' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'Subscription', @level2type=N'COLUMN',@level2name=N'RenderFormat'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'Subscription', N'COLUMN',N'WriteMode'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Modo de escritura' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'Subscription', @level2type=N'COLUMN',@level2name=N'WriteMode'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'Subscription', N'COLUMN',N'FileExtension'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tipo de archivo' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'Subscription', @level2type=N'COLUMN',@level2name=N'FileExtension'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'Subscription', N'COLUMN',N'UserName'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de usuario' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'Subscription', @level2type=N'COLUMN',@level2name=N'UserName'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'Subscription', N'COLUMN',N'Password'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Contraseña' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'Subscription', @level2type=N'COLUMN',@level2name=N'Password'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'Subscription', N'COLUMN',N'FileShareAccount'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Cuenta de archivo compatido' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'Subscription', @level2type=N'COLUMN',@level2name=N'FileShareAccount'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'TABLE',N'Subscription', N'COLUMN',N'DateName'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha para el parametro de reporte automático' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'Subscription', @level2type=N'COLUMN',@level2name=N'DateName'
GO

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - End script: A03Table_Util.sql'
PRINT '------------------------------------------------------------------------'
GO
