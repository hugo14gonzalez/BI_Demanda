/* ========================================================================== 
Proyecto: DemandaBI
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya 
Fecha: 2020-07-15
Fecha actualizacion: 2020-07-15
========================================================================== */ 

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - Start script: Z02Data.sql'
PRINT '------------------------------------------------------------------------'
GO

USE [DemandaDW];

/* ====================================================================================
ORDEN DE EJECUCION DE TAREAS
==================================================================================== */
1. Carga manual
DimFecha
DimTiempo
DimPeriodo
DimEscalonEDAC
DimEventoFlag
DimMercado
DimMercadoEntrada
DimMercadoSalida
DimFormaEjecucion
DimFuente
DimGeneracionFlag
DimIndicadorEstado
DimMantenimientoEstado
DimMantenimientoFlag
DimMantenimientoModo
DimMantenimientoOrigen
DimMantenimientoTipo
DimNivelTension
DimOrdenMovimientoFlag
DimOrdenMovimientoOrigen
DimOrdenMovimientoTipo
DimProteccionEstado
DimSalidaFlag

2. Dim independientes
DimFecha
DimCausa
DimZona
DimOrdenMovimientoMercado

3.A
DimEmpresa
DimIndicador

3.B Dim dependientes orden de ejecucion
DimGeografia
DimElementoSistema
DimPersona

3.C Dim dependientes orden de ejecucion
DimAgente
DimSubestacion

3.D Dim dependientes orden de ejecucion
DimNodo

4.A Fact
FactIndicador
FactGeneracion
FactMantenimiento
FactOrdenMovimiento
FactPGDDistribuidora
FactPGDGeneracionMunicipio
FactSalidaGeneracion
FactSalidaTransmision

4.B Fact
FactDemandaPerdida
FactPerdida
FactFrecuencia
FactPotenciaActiva
FactProteccion
FactTension

5. Cubos
Procesar Dim
Crear particiones
Procesar particiones


/* ====================================================================================
DATOS TABLAS GENERALES
==================================================================================== */
SELECT * FROM [Utility].[SpecialDate]

/* ====================================================================================
DATOS DIMENSIONES
==================================================================================== */
SELECT * FROM [DW].[DimAgente];
SELECT * FROM [DW].[DimCompania];
SELECT * FROM [DW].[DimFecha];
SELECT * FROM [DW].[DimGeografia];
SELECT * FROM [DW].[DimMercado];
SELECT * FROM [DW].[DimPeriodo];

/* ====================================================================================
DATOS FACT
==================================================================================== */
SELECT * FROM [DW].[FactDemandaPerdida];

/* ====================================================================================
DATOS AUDITORIA
==================================================================================== */
SELECT * FROM [Audit].[Bitacora];
SELECT * FROM [Audit].[BitacoraFile];
SELECT * FROM [Audit].[BitacoraDetail];
SELECT * FROM [Audit].[BitacoraStatistic];
SELECT * FROM [Audit].[BitacoraState] ORDER BY [StateId];
SELECT * FROM [Audit].[BitacoraType] ORDER BY [TypeId];
SELECT * FROM [Audit].[BitacoraTable];

/* ====================================================================================
DATOS UTILIDADES
==================================================================================== */
/* Modelos */
SELECT [ModelId],[Name],[AppName],[TypeId],[UseDatesProcess],[UseVersion],[ReloadPeriodType],[Description]
FROM [Utility].[ModelSystem] 
ORDER BY [TypeId] DESC,[ModelId];

/* Modulos */
SELECT [ModuleId],[Name],[AppName],[TypeId],[ProcessTypeId],[Description]
FROM [Utility].[ModuleSystem]
ORDER BY [TypeId],[ProcessTypeId] DESC,[ModuleId];

/* Cubos */
SELECT [CubeId],[Name],[AppName],[Database],[Description]
FROM [Utility].[CubeSystem]
ORDER BY [Name];

/* Consulta tipo de particion en el cubo de modelos */
SELECT CU.[CubeId],CU.[AppName] As [Cubo],MO.[ModelId],MO.[AppName] As [Modelo] 
,CP.[Partitioned],CP.[Period],CP.[PrefixPartition],CP.[StoragePath]
FROM [Utility].[CubeSystem] CU
INNER JOIN [Utility].[CubePartition] CP ON CP.[CubeId] = CU.[CubeId]
INNER JOIN [Utility].[ModelSystem] MO ON MO.[ModelId] = CP.[ModelId]
ORDER BY CU.[Name], MO.[Name];

/* Consulta particiones de cubos */
SELECT TOP 1000 CU.[CubeId],CU.[AppName] As [Cubo],MO.[ModelId],MO.[AppName] As [Modelo] 
,CP.[Partitioned],CP.[Period],CP.[PrefixPartition]
,PD.[PartitionId],PD.[PartitionName],PD.[DateStart],PD.[DateEnd],PD.[Create]
FROM [Utility].[CubeSystem] CU
INNER JOIN [Utility].[CubePartition] CP ON CP.[CubeId] = CU.[CubeId]
INNER JOIN [Utility].[ModelSystem] MO ON MO.[ModelId] = CP.[ModelId]
INNER JOIN [Utility].[CubePartitionDetail] PD ON PD.[CubeId] = CU.[CubeId] AND PD.[ModelId] = CP.[ModelId]
ORDER BY CU.[Name], MO.[Name], PD.[PartitionId];

/* Consulta agendas */
SELECT S.[ScheduleId],S.[Name] As [Agenda],S.[Period],S.[PeriodHowMany],S.[DayPeriod],S.[DayHowMany]
,S.[Monday],S.[Tuesday],S.[Wednesday],S.[Thursday],S.[Fryday],S.[Saturday],S.[Sunday]
,S.[OccursDayOfMonth],S.[DayOccurs],S.[OccursThe],S.[OccursTheDay],S.[Description]
FROM [Utility].[ScheduleSystem] S
ORDER BY S.[ScheduleId];

/* Consulta agendas (dias de ejecucion) y rango de fecha para procesar modelos */
SELECT MO.[ModelId],MO.[AppName] As [Modelo],MS.[ScheduleId],S.[Name] [Agenda],S.[Description] As [DescripcionAgenda]
,MS.[UseVersion],MS.[PeriodType],MS.[PeriodQuantity],MS.[PeriodTypeBefore],MS.[PeriodsBefore],MS.[Enabled],MS.[Description] As [Descripcion]
,Convert(date, [Utility].[GetSchedule_NextExecution](MS.[ScheduleId], GetDate(), 1)) [SiguienteEjecucion]
FROM [Utility].[ModelSystem] MO
INNER JOIN [Utility].[ModelSchedule] MS ON MS.[ModelId] = MO.[ModelId]
INNER JOIN [Utility].[ScheduleSystem] S ON S.[ScheduleId] = MS.[ScheduleId]
ORDER BY MO.[TypeId] DESC,MO.[ModelId],MS.[ScheduleId];

/* Consulta secuencia de modulos para procesar modelos */
SELECT MM.[ModelId],MO.[AppName] As [Modelo],MM.[SequenceId],MM.[ModuleId],MD.[AppName] As [Modulo]
FROM [Utility].[ModuleModel] MM
INNER JOIN [Utility].[ModelSystem] MO ON MO.[ModelId] = MM.[ModelId]
INNER JOIN [Utility].[ModuleSystem] MD ON MD.[ModuleId] = MM.[ModuleId]
ORDER BY MO.[TypeId] DESC,MO.[AppName],MM.[SequenceId];

/* Consulta secuencia de pasos para recargar modelos */
SELECT ML.[ModelId],MO.[AppName] As [Modelo],ML.[SequenceId] As [Secuencia],ML.[ModuleId],MD.[AppName] As [Modulo]
,ML.[ModelProgId],MOP.[AppName] As [ModeloProgramar]
FROM [Utility].[ModelLoad] ML
INNER JOIN [Utility].[ModelSystem] MO ON MO.[ModelId] = ML.[ModelId]
INNER JOIN [Utility].[ModelSystem] MOP ON MOP.[ModelId] = ML.[ModelProgId]
INNER JOIN [Utility].[ModuleSystem] MD ON MD.[ModuleId] = ML.[ModuleId]
ORDER BY MO.[TypeId] DESC,ML.[ModelId], ML.[SequenceId];

/* Consultas del sistema */
SELECT [QueryId],[Name],[Type],[DatabaseId],[QuerySQL],[Parameters],[Description]
FROM [Utility].[QuerySQL]
ORDER BY [QueryId];

/* Consulta metricas */ 
SELECT DISTINCT MO.[ModelId],MO.[AppName] As [Modelo],ME.[MetricId],ME.[AppName] As [Metrica]
,ME.[CalculationType] As [TipoMetrica],ME.[UnityId] As [UnidadId],ME.[DatabaseId] As [BaseDatosId]
,ME.[Table] As [Tabla],ME.[Field] As [Campo],ME.[QueryId],ME.[DateStart],ME.[DateEnd]
,ME.[Formula],ME.[Description] As [Descripcion]
FROM [Utility].[ModelSystem] MO
INNER JOIN [Utility].[MetricSystem] ME ON ME.[ModelId] = MO.[ModelId]
ORDER BY MO.[AppName], ME.[AppName];

/* Consulta version de modelos */
SELECT MV.[DateVersion],MV.[ModelId],MO.[Name],MV.[DateStart],MV.[DateEnd],MV.[Version],MV.[VersionId],MV.[StateId]
,MV.[CreateBitacoraId],MV.[CreateDate],MV.[UpdateBitacoraId],MV.[UpdateDate]
FROM [Utility].[ModelVersion] MV
INNER JOIN [Utility].[ModelSystem] MO ON MO.[ModelId] = MV.[ModelId]
ORDER BY MV.[DateVersion], MO.[Name];

/* Consultar programacion */
SELECT MP.[Priority], MP.[ModelId],MO.[AppName] As [Model],MP.[SequenceId],MP.[ModuleId],MD.[AppName] As [Module]
,MP.[ModelProgId],MOP.[AppName] As [ModelProg],MP.[DateVersion],MP.[DateStart],MP.[DateEnd],MP.[Version],MP.[VersionId]
,MP.[StateId],MP.[DateUpdate] 
FROM [Utility].[ModuleProgramming] MP
INNER JOIN [Utility].[ModuleSystem] MD ON MD.[ModuleId] = MP.[ModuleId]
INNER JOIN [Utility].[ModelSystem] MO ON MO.[ModelId] = MP.[ModelId]
INNER JOIN [Utility].[ModelSystem] MOP ON MOP.[ModelId] = MP.[ModelProgId]
--WHERE MP.[StateId] <> 20
ORDER BY MP.[Priority],MP.[ModelId],MP.[SequenceId],MP.[DateStart];

SELECT [Priority],[SequenceId],[ModuleId],[AppNameModule],[TypeModule],[TypeModel],[StateId]
FROM (
  SELECT MP.[Priority],MP.[SequenceId],MP.[ModuleId],MD.[AppName] As [AppNameModule],MP.[StateId]
  , MD.[TypeId] [TypeModule], MO.[TypeId] [TypeModel]
  , ROW_NUMBER() OVER (PARTITION BY MP.[ModuleId]
	    ORDER BY MP.[ModuleId], CASE WHEN MO.[TypeId] <> 'Cubo' THEN MP.[Priority] END ASC
	                         , CASE WHEN MO.[TypeId] = 'Cubo' THEN MP.[Priority] END DESC, MP.[SequenceId]) [Fila]
  FROM [Utility].[ModuleProgramming] MP
  INNER JOIN [Utility].[ModuleSystem] MD ON MD.[ModuleId] = MP.[ModuleId]
  INNER JOIN [Utility].[ModelSystem] MO ON MO.[ModelId] = MP.[ModelProgId]
) T
WHERE [Fila] = 1 
ORDER BY [Priority],[SequenceId];


/* ========================================================================== 
REPORTES DE AUDITORIA
========================================================================== */
SELECT [Id],[ParentId],[BitacoraId],[ModuleId],[Name],[StateId],[State],[DateStart],[DateEnd],[TimeDuration],[FailureTask],[Message]
FROM [Audit].[GetBitacoraTree_ByDate](Convert(varchar(10), '2018-01-01', 120), Convert(varchar(10), '2018-06-01', 120))
ORDER BY [Id];

SELECT [Id],[ParentId],[BitacoraId],[Name],[StateId],[State],[TypeId],[Type],[DateRun],[Message]
FROM [Audit].[GetBitacoraDetailTree_ByDate](Convert(varchar(10), '2018-01-01', 120), Convert(varchar(10), '2018-06-01', 120))
ORDER BY [Id]

SELECT [Id],[ParentId],[BitacoraId],[StateId],[State],[DateStart],[DateEnd],[TimeDuration],[Name],[PathWithoutProcessing],[PathError],[PathProcessed],[Message]
FROM [Audit].[GetBitacoraFileTree_ByDate](Convert(varchar(10), '2018-01-01', 120), Convert(varchar(10), '2018-06-01', 120))
ORDER BY [Id]

SELECT [Id],[ParentId],[BitacoraId],[Name],[DateStart],[DateEnd],[TimeDuration],[DateWork],[RowsConsulted],[RowsError],[RowsInserted],[RowsUpdated],[RowsDeleted]
FROM [Audit].[GetBitacoraStatisticTree_ByDate](Convert(varchar(10), '2018-01-01', 120), Convert(varchar(10), '2018-06-01', 120))
ORDER BY [Id]

SELECT [Id],[ParentId],[BitacoraId],[Name],[StateId],[State],[TypeId],[Type],[DateRun],[DateWork],[TableTarget],[FieldTarget],[ValueTarget]
,[TableSource],[FieldSource],[ValueSource],[PKField1],[PKValue1],[PKField2],[PKValue2],[PKField3],[PKValue3],[PKField4],[PKValue4],[PKField5],[PKValue5],[Message]
FROM [Audit].[GetBitacoraTableTree_ByDate](Convert(varchar(10), '2018-06-01', 120), Convert(varchar(10), '2018-07-01', 120))
ORDER BY [Id]

/* Estado bitacora */
SELECT NULL [StateId], 'TODOS' [Name]
UNION
SELECT [StateId], Convert(varchar, [StateId]) + ': ' + [Name] FROM [Audit].[BitacoraState] 
ORDER BY [StateId];

/* Modulos */
SELECT NULL [ModuleId], 'TODOS' [AppName]
UNION
SELECT [ModuleId], Convert(varchar, [ModuleId]) + ': ' +[AppName] FROM [Utility].[ModuleSystem]
ORDER BY [ModuleId];

/* Tipo bitacora */
SELECT NULL [TypeId], 'TODOS' [Name]
UNION
SELECT [TypeId], Convert(varchar, [TypeId]) + ': ' + [Name] FROM [Audit].[BitacoraType] 
ORDER BY [TypeId];

/* Nombre */
SELECT NULL [NameId], 'TODOS' [Name]
UNION
SELECT DISTINCT [Name] As [NameId], [Name]
FROM [Audit].[GetBitacoraDetailTree_ByDate](Convert(varchar(10), '2018-01-01', 120), Convert(varchar(10), '2018-06-01', 120))
ORDER BY [NameId]

/* ========================================================================== 
METADATOS DE CUBOS
========================================================================== */
-- Bases de datos
EXECUTE [Utility].[spOLAP_GetCatalogs] 'Demanda_OLAP'; 

-- Dimensiones
EXECUTE [Utility].[spOLAP_GetDimensions] 'Demanda_OLAP', 1, 'Demanda_OLAP';

-- Dimensiones y atributos
EXECUTE [Utility].[spOLAP_GetDimensionsAttributes] 'Demanda_OLAP', 'Demanda_OLAP';

-- Jerarquias
EXECUTE [Utility].[spOLAP_GetHierarchies] 'Demanda_OLAP', 'Demanda_OLAP';

-- Jerarquias y atributos
EXECUTE [Utility].[spOLAP_GetHierarchiesAttributes] 'Demanda_OLAP', 'Demanda_OLAP';

-- Cubos
EXECUTE [Utility].[spOLAP_GetCubes] 'Demanda_OLAP', 'Demanda_OLAP'; 

-- Cubos y grupos de medidas
EXECUTE [Utility].[spOLAP_GetMeasureGroups] 'Demanda_OLAP', 1, 'Demanda_OLAP';

-- Grupos de medidas y dimensiones
EXECUTE [Utility].[spOLAP_GetMeasureGroupsDimensions] 'Demanda_OLAP', 1, 'Demanda_OLAP';

-- Metricas
EXECUTE [Utility].[spOLAP_GetMeasures] 'Demanda_OLAP', 1, 'Demanda_OLAP';

-- Perspectivas
EXECUTE [Utility].[spOLAP_GetPerspectives] 'Demanda_OLAP', 'Demanda_OLAP'; 

-- KPI
EXECUTE [Utility].[spOLAP_GetKPI] 'Demanda_OLAP', 1, 'Demanda_OLAP';


/* ========================================================================== 
CONSULTAS PARA REPORTES
========================================================================== */
/*  dataSetCurrentYear */
SELECT YEAR(GETDATE()) AS [CurrentYear];
SELECT CONCAT('[DimFecha].[Año].&[', YEAR(GETDATE()), ']') AS [CurrentYear];

/* dataSetCurrentMonth */
SELECT MONTH(GETDATE()) AS [CurrentMonth];
SELECT CONCAT('[DimFecha].[Mes].&[', MONTH(GETDATE()), ']') AS [CurrentMonth];
SELECT CONCAT('[DimFecha].[Mes].&[', YEAR(GETDATE()), ']&[', MONTH(GETDATE()), ']') AS [CurrentMonth];



/* dataSetFullMonth */
SELECT 1 AS [MonthNumber], 'Enero' AS [MonthName], 'Ene' AS [MonthNameShort]
UNION
SELECT 2 AS [MonthNumber], 'Febrero' AS [MonthName], 'Feb' AS [MonthNameShort]
UNION
SELECT 3 AS [MonthNumber], 'Marzo' AS [MonthName], 'Mar' AS [MonthNameShort]
UNION
SELECT 4 AS [MonthNumber], 'Abril' AS [MonthName], 'Abr' AS [MonthNameShort]
UNION
SELECT 5 AS [MonthNumber], 'Mayo' AS [MonthName], 'May' AS [MonthNameShort]
UNION
SELECT 6 AS [MonthNumber], 'Junio' AS [MonthName], 'Jun' AS [MonthNameShort]
UNION
SELECT 7 AS [MonthNumber], 'Julio' AS [MonthName], 'Jul' AS [MonthNameShort]
UNION
SELECT 8 AS [MonthNumber], 'Agosto' AS [MonthName], 'Ago' AS [MonthNameShort]
UNION
SELECT 9 AS [MonthNumber], 'Septiembre' AS [MonthName], 'Sep' AS [MonthNameShort]
UNION
SELECT 10 AS [MonthNumber], 'Octubre' AS [MonthName], 'Oct' AS [MonthNameShort]
UNION
SELECT 11 AS [MonthNumber], 'Noviembre' AS [MonthName], 'Nov' AS [MonthNameShort]
UNION
SELECT 12 AS [MonthNumber], 'Diciembre' AS [MonthName], 'Dic' AS [MonthNameShort];


PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - End script: Z02Data.sql'
PRINT '------------------------------------------------------------------------'
GO
