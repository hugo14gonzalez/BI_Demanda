/* ========================================================================== 
Proyecto: DemandaBI
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya 
Fecha: 2020-07-15
Fecha actualizacion: 2020-07-15
Link: 
http://www.made2mentor.com/2013/08/how-to-load-slowly-changing-dimensions-using-t-sql-merge/
http://www.made2mentor.com/2013/08/extracting-historical-dimension-records-using-t-sql/
http://www.made2mentor.com/2013/08/data-warehouse-initial-historical-dimension-loading-with-t-sql-merge/
========================================================================== */ 

/* ========================================================================== 
VARIABLES PARA INSTALAR:
$(DATABASE_NAME_DW): Nombre de la base de datos. Ejemplo: DemandaDW
========================================================================== */

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - Start script: A12SP_DW_Dim1.sql'
PRINT '------------------------------------------------------------------------'
GO

USE [$(DATABASE_NAME_DW)];

/* ========================================================================== 
CARGA DE FECHA Y TIEMPO
========================================================================== */
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DW].[spLoadDimDate]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_EXECUTEsql @statement = N'CREATE PROCEDURE [DW].[spLoadDimDate] AS' 
END
GO
ALTER PROCEDURE [DW].[spLoadDimDate] 
 @dateStart date
 ,@DateEnd date
 ,@updateIfExists bit = 1
As
/* ============================================================================================
Proposito: Inserta o actualiza los datos de tabla DimDate en el intervalo de fechas dado.
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2020-07-15
Fecha actualizacion: 2020-07-15

Parametros:  
 @dateStart: Fecha inicio
 @DateEnd: Fecha fin
 @updateIfExists: 
  0: Solo insertar si la fila no existe
  1: Si la fila existe actualizar de lo contrario insertar

Ejemplo:
 Declare @dateStart datetime, @DateEnd datetime;
 Set @dateStart = convert(datetime, '2010-01-01', 120);
 set @DateEnd = convert(datetime, Convert(nvarchar, Year(GetDate()) + 1) + '-01-01', 120);
 EXECUTE [DW].[spLoadDimDate] @dateStart, @DateEnd, 1;

 SELECT * FROM [DW].[DimFecha];
============================================================================================ */
begin
 set nocount on;
 /* Establecer primer dia de la semana: 1 = Lunes, ... 7 = Domingo */
 SET DATEFIRST 1 

 Declare @dateTempo date
 Declare @tmpDimDate table ( 
	[DateKey] [int] PRIMARY KEY NOT NULL,
	[Date] [date] NULL,
	[DateDesc] [nvarchar](10) NOT NULL,
	[Year] [smallint] NOT NULL,
	[Half] [smallint] NOT NULL,
	[HalfDesc] [nvarchar](15) NOT NULL,
	[Quarter] [smallint] NOT NULL,
	[QuarterDesc] [nvarchar](15) NOT NULL,
	[Month] [smallint] NOT NULL,
	[MonthName] [nvarchar](10) NOT NULL,
	[MonthNameShort] [nchar](3) NOT NULL,
	[MonthDesc] [nvarchar](15) NOT NULL,
	[MonthDescShort] [nvarchar](8) NOT NULL,
	[WeekYear] [smallint] NOT NULL,
	[WeekYearDesc] [nvarchar](15) NOT NULL,
	[Day] [smallint] NOT NULL,
	[DayYear] [smallint] NOT NULL,
	[DayWeek] [smallint] NOT NULL,
	[DayName] [nvarchar](10) NOT NULL,
	[DayNameShort] [nchar](3) NOT NULL,
	[DayType] [nvarchar](10) NOT NULL);
	  
 set @dateTempo = @dateStart;
 while @dateTempo <= @DateEnd
 Begin
  INSERT INTO @tmpDimDate ([DateKey],[Date],[DateDesc],[Year],[Half],[HalfDesc],[Quarter],[QuarterDesc],[Month], [MonthName],
   [MonthNameShort],[MonthDesc],[MonthDescShort],[WeekYear],[WeekYearDesc],[Day],[DayYear],[DayWeek],[DayName],[DayNameShort],[DayType])
  SELECT [DateKey], [Date], [DateDesc], [Year], [Half], [HalfDesc], [Quarter], [QuarterDesc], [Month], [MonthName],
   [MonthNameShort],[MonthDesc],[MonthDescShort],[WeekYear], [WeekYearDesc], [Day], [DayYear], [DayWeek], [DayName],[DayNameShort],[DayType] 
  FROM [Utility].[GetDateParts] (@dateTempo);

  set @dateTempo = DateAdd(d, 1, @dateTempo);
 end
 
 /* No utilizar 'WITH (HOLDLOCK)' para evitar abrazos mortales (deadlock) cuando varias tablas intenten actualizar datos */
 MERGE [DW].[DimFecha] AS Target
 USING (SELECT [DateKey],[Date],[DateDesc],[Year],[Half],[HalfDesc],[Quarter],[QuarterDesc],[Month],[MonthName],
        [MonthNameShort],[MonthDesc],[MonthDescShort],[WeekYear],[WeekYearDesc],[Day],[DayYear],[DayWeek],[DayName],[DayNameShort],[DayType]
        FROM @tmpDimDate) AS Source 
 ON (Target.[FechaSKId] = Source.[DateKey])
 -- Cuando cazan los registros, actualizar si hay algun cambio
 WHEN MATCHED AND (@updateIfExists = 1) THEN
  UPDATE SET 
   Target.[Fecha] = Source.[Date]
   ,Target.[FechaDesc] = Source.[DateDesc]
   ,Target.[Anio] = Source.[Year]
   ,Target.[Semestre] = Source.[Half]
   ,Target.[SemestreDesc] = Source.[HalfDesc]
   ,Target.[Trimestre] = Source.[Quarter]
   ,Target.[TrimestreDesc] = Source.[QuarterDesc]
   ,Target.[Mes] = Source.[Month]
   ,Target.[MesNombre] = Source.[MonthName]
   ,Target.[MesNombreCorto] = Source.[MonthNameShort]
   ,Target.[MesDesc] = Source.[MonthDesc]
   ,Target.[MesDescCorto] = Source.[MonthDescShort]
   ,Target.[SemanaAnio] = Source.[WeekYear]
   ,Target.[SemanaAnioDesc] = Source.[WeekYearDesc]
   ,Target.[Dia] = Source.[Day]
   ,Target.[DiaAnio] = Source.[DayYear]
   ,Target.[DiaSemana] = Source.[DayWeek]
   ,Target.[DiaNombre] = Source.[DayName]
   ,Target.[DiaNombreCorto] = Source.[DayNameShort]
   ,Target.[DiaTipo] = Source.[DayType]
 -- Cuando no cazan los registros, insertar
 WHEN NOT MATCHED BY TARGET THEN
  INSERT ([FechaSKId],[Fecha],[FechaDesc],[Anio],[Semestre],[SemestreDesc],[Trimestre],[TrimestreDesc],[Mes],[MesNombre]
   ,[MesNombreCorto],[MesDesc],[MesDescCorto],[SemanaAnio],[SemanaAnioDesc],[Dia],[DiaAnio],[DiaSemana],[DiaNombre],[DiaNombreCorto],[DiaTipo])
  VALUES (Source.[DateKey],[Date],Source.[DateDesc],Source.[Year],Source.[Half],Source.[HalfDesc],Source.[Quarter],Source.[QuarterDesc]
   ,Source.[Month],Source.[MonthName],Source.[MonthNameShort],Source.[MonthDesc],Source.[MonthDescShort],Source.[WeekYear],Source.[WeekYearDesc]
   ,Source.[Day],Source.[DayYear],Source.[DayWeek],Source.[DayName],Source.[DayNameShort],Source.[DayType]);

 set nocount off;
End
GO


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DW].[spLoadDimDateNext]') AND type in (N'P', N'PC'))
 DROP PROCEDURE [DW].[spLoadDimDateNext]
GO
CREATE procedure [DW].[spLoadDimDateNext] 
 @dateStart date
,@DateEnd date
as
/* ============================================================================================
Proposito: Inserta o actualiza los datos de tabla DimDate en el intervalo de fechas dado.
 No deja huecos entre la mínima y máxima fecha de la tabla y el intervalo dado.  
 Si la fecha final es nula o menor o igual a cero sale sin realizar cambios.
 Si la fecha inicial es nula o menor o igual a cero hace la fecha inicio igual a la fecha fin.
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2020-07-15
Fecha actualizacion: 2020-07-15

Parametros:  
 @dateStart: Fecha inicio
 @DateEnd: Fecha fin
 
Ejemplo:
 Declare @dateStart datetime, @DateEnd datetime
 set @dateStart = convert(datetime, '2005-01-01', 120)
 set @DateEnd = convert(datetime, '2005-01-03', 120)
 EXECUTE [DW].[spLoadDimDateNext] @dateStart, @DateEnd
 SELECT * FROM [DW].[DimFecha];

 Declare @dateStart datetime, @DateEnd datetime
 set @dateStart = convert(datetime, '2005-03-01', 120)
 set @DateEnd = convert(datetime, '2005-03-31', 120)
 EXECUTE [DW].[spLoadDimDateNext] @dateStart, @DateEnd
 SELECT * FROM [DW].[DimFecha];
============================================================================================ */
begin
 set nocount on
 Declare @fMax date, @fMin date
 
 if ( @DateEnd is null or @DateEnd <= CONVERT(datetime, 0, 112) )
 begin
  return;
 end;

 if ( @dateStart is null or @dateStart <= CONVERT(datetime, 0, 112) )
 begin
  set @dateStart = @DateEnd;
 end;

 Select @fMax = CONVERT(date, convert(nvarchar, Max([FechaSKId])), 112) From [DW].[DimFecha] WITH (NOLOCK)
 Select @fMin = CONVERT(date, convert(nvarchar, Min([FechaSKId])), 112) From [DW].[DimFecha] WITH (NOLOCK) Where [FechaSKId] > 0
 
 EXECUTE [DW].[spLoadDimDate] @dateStart, @DateEnd, 0;
 
 -- llenar huecos desde el máximo hacia arriba
 if (@dateStart > @fMax)
 begin
  EXECUTE [DW].[spLoadDimDate] @fMax, @dateStart, 0;
 end;

 -- llenar huecos desde el mínimo hacia abajo
 if (@DateEnd < @fMin)
 begin
  EXECUTE [DW].[spLoadDimDate] @DateEnd, @fMin, 0;
 end;

 set nocount off
end
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DW].[spLoadDimPeriod]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_EXECUTEsql @statement = N'CREATE PROCEDURE [DW].[spLoadDimPeriod] AS' 
END
GO
ALTER PROCEDURE [DW].[spLoadDimPeriod] 
 @updateIfExists bit = 1
As
/* ============================================================================================
Proposito: Inserta o actualiza los datos de tabla DimTimeHour.
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2016-06-24
Fecha actualizacion: 2016-06-24

Parametros:  
 @updateIfExists: 
  0: Solo insertar si la fila no existe
  1: Si la fila existe actualizar de lo contrario insertar

Ejemplo:
EXECUTE [DW].[spLoadDimPeriod] 0;

SELECT * FROM [DW].[DimPeriodo];
============================================================================================ */
begin
 set nocount on;

 MERGE [DW].[DimPeriodo] WITH (HOLDLOCK) AS Target
 USING (SELECT TOP 100 PERCENT [Period], [Hour24], [Time24Id]
 FROM [Utility].[GetTimeHourParts] () ORDER BY [TimeKey]) AS Source 
 ON (Target.[PeriodoSKId] = Source.[Period])
 -- Cuando cazan los registros, actualizar si hay algun cambio
 WHEN MATCHED AND (@updateIfExists = 1) THEN
  UPDATE SET 
    Target.[Hora] = Source.[Hour24]
   ,Target.[Tiempo] = Source.[Time24Id]
 -- Cuando no cazan los registros, insertar
 WHEN NOT MATCHED BY TARGET THEN
  INSERT ([PeriodoSKId], [Hora], [Tiempo])
  VALUES (Source.[Period], Source.[Hour24], Source.[Time24Id]);

 set nocount off;
End
GO


/* ========================================================================== 
CARGA DE DIMENSIONES TIPO 1
========================================================================== */
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DW].[spLoadDimGeografia]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_EXECUTEsql @statement = N'CREATE PROCEDURE [DW].[spLoadDimGeografia] AS' 
END
GO
ALTER PROCEDURE [DW].[spLoadDimGeografia] 
 @bitacoraId bigint
As
/* ============================================================================================
Proposito: Inserta o actualiza los datos de tabla DimGeografia utilizados los datos de la tabla temporal staging area.
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2020-07-15
Fecha actualizacion: 2020-07-15

Parametros:
 @bitacoraId: Código de ejecución de proceso.

Ejemplo:
EXECUTE [DW].[spLoadDimGeografia] 0;

SELECT * FROM [DW].[DimGeografia];
============================================================================================ */
begin
 set nocount on;

 Declare @date date, @skId int, @okRowInserted bit;
 Declare @item bigint, @rowsConsulted bigint, @rowsError bigint, @rowsInserted bigint, @rowsUpdated bigint;
 Declare @DateWork date, @currentDate date, @minDateChange date, @dateChange date;

 Declare @TableChanges TABLE 
 (
   [Action] [nvarchar](10) COLLATE DATABASE_DEFAULT
 );

 set @DateWork = GetDate();
 EXECUTE [Audit].[spBitacoraStatistic_Start] @bitacoraId, @item OUTPUT, @DateWork, 'DimGeografia';
 set @rowsInserted = 0;
 set @rowsUpdated = 0;

 SELECT @rowsConsulted = Count(*)
 FROM [Staging].[TmpDimGeografia];
 if (@rowsConsulted = 0)
 begin
   INSERT INTO [Audit].[BitacoraTable]([BitacoraId],[Name],[StateId],[SeverityId],[TypeId],[DateRun],[DateWork],[TableTarget]
    ,[FieldTarget],[ValueTarget],[TableSource],[FieldSource],[ValueSource],[PKField1],[PKValue1],[PKField2],[PKValue2],[PKField3],[PKValue3]
   ,[PKField4],[PKValue4],[PKField5],[PKValue5],[Message])
   VALUES (@bitacoraId, 'spLoadDimGeografia', 13, 2, 3, GetDate(), @DateWork, 'DW.DimGeografia', NULL, NULL, 'Staging.TmpDimGeografia'
   , NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Datos ausente');
  set @rowsError = 0;
  GOTO Salir;
 end;

 /* Auditoria registros duplicados */
 ;WITH [CTE_I] AS
 (
  SELECT [PaisId], [DepartamentoId], [MunicipioId], [AreaId], [SubAreaId]
    , ROW_NUMBER() OVER (PARTITION BY [PaisId], [DepartamentoId], [MunicipioId] ORDER BY [PaisId], [DepartamentoId], [MunicipioId], [AreaId], [SubAreaId]) [Row]
  FROM [Staging].[TmpDimGeografia] 
 )
 INSERT INTO [Audit].[BitacoraTable]([BitacoraId],[Name],[StateId],[SeverityId],[TypeId],[DateRun],[DateWork],[TableTarget]
  ,[FieldTarget],[ValueTarget],[TableSource],[FieldSource],[ValueSource],[PKField1],[PKValue1],[PKField2],[PKValue2],[PKField3],[PKValue3]
  ,[PKField4],[PKValue4],[PKField5],[PKValue5],[Message])
 SELECT @bitacoraId, 'spLoadDimGeografia', 1, 2, 4, GetDate(), @DateWork, 'DW.DimGeografia', 'PaisId', NULL, 'Staging.TmpDimGeografia', NULL
   ,NULL, 'PaisId', [PaisId], 'DepartamentoId', [DepartamentoId], 'MunicipioId', [MunicipioId], 'AreaId', [AreaId], 'SubAreaId', [SubAreaId], 'Datos repetidos'
 FROM [CTE_I] WHERE [Row] > 1;

 /* Marcar registros duplicados */
 ;WITH [CTE_I] AS
 (
  SELECT [TmpSKId] 
    , ROW_NUMBER() OVER (PARTITION BY [PaisId], [DepartamentoId], [MunicipioId] ORDER BY [PaisId], [DepartamentoId], [MunicipioId], [AreaId], [SubAreaId]) [Row]
  FROM [Staging].[TmpDimGeografia] 
 )
 UPDATE T SET
  [Inconsistent] = 1 
 FROM [Staging].[TmpDimGeografia] T INNER JOIN [CTE_I] I ON I.[TmpSKId] = T.[TmpSKId] 
 WHERE I.[Row] > 1;

 MERGE [DW].[DimGeografia] WITH (HOLDLOCK) AS Target
 USING (SELECT TOP 100 PERCENT [PaisId],[Pais],[DepartamentoId],[Departamento],[MunicipioId],[Municipio],[AreaId],[Area],[SubAreaId],[SubArea]
        FROM [Staging].[TmpDimGeografia] WITH (NOLOCK)
		WHERE [Inconsistent] = 0
		ORDER BY [PaisId], [DepartamentoId], [MunicipioId]) AS Source
 ON (Target.[PaisId] = Source.[PaisId] AND Target.[DepartamentoId] = Source.[DepartamentoId] AND Target.[MunicipioId] = Source.[MunicipioId])
 WHEN MATCHED AND ( Exists( 
 Select Source.[Pais], Source.[Departamento], Source.[Municipio], Source.[Municipio], Source.[AreaId], Source.[Area], Source.[SubAreaId], Source.[SubArea] 
 except 
 select Target.[Pais], Target.[Departamento], Target.[Municipio], Target.[Municipio], Target.[AreaId], Target.[Area], Target.[SubAreaId], Target.[SubArea])
 ) THEN
  UPDATE SET 
    Target.[Pais] = Source.[Pais]
   ,Target.[Departamento] = Source.[Departamento]
   ,Target.[Municipio] = Source.[Municipio]
   ,Target.[AreaId] = Source.[AreaId]
   ,Target.[Area] = Source.[Area]
   ,Target.[SubAreaId] = Source.[SubAreaId]
   ,Target.[SubArea] = Source.[SubArea]
   ,Target.[BitacoraId] = @bitacoraId
 WHEN NOT MATCHED BY TARGET THEN
 INSERT ([PaisId],[Pais],[DepartamentoId],[Departamento],[MunicipioId],[Municipio],[AreaId],[Area],[SubAreaId],[SubArea],[BitacoraId])
  VALUES (Source.[PaisId], Source.[Pais], Source.[DepartamentoId], Source.[Departamento], Source.[MunicipioId], Source.[Municipio]
  , Source.[AreaId], Source.[Area], Source.[SubAreaId], Source.[SubArea], @bitacoraId)
 OUTPUT $action INTO @TableChanges;

 SELECT @rowsInserted = [INSERT], @rowsUpdated = [UPDATE]
 FROM (
        SELECT [Action], 1 As [RowsChange]
        from @TableChanges
        ) p
 PIVOT
 (
   Count([RowsChange])
   FOR [Action] IN ([INSERT], [UPDATE], [DELETE])
 ) As pvt;

 SELECT @rowsError = Count(*)
 FROM [Staging].[TmpDimGeografia] 
 WHERE [Inconsistent] = 1;

Salir:

 EXECUTE [Audit].[spBitacoraStatistic_End] @item, NULL, NULL, @rowsConsulted, @rowsError, @rowsInserted, @rowsUpdated, 0;

 set nocount off;
End
GO

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - End script: A12SP_DW_Dim1.sql'
PRINT '------------------------------------------------------------------------'
GO