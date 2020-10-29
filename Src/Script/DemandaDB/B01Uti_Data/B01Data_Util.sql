/* ========================================================================== 
Proyecto: DemandaBI
Empresa:  
Desarrollador: Hugo Gonzalez Olaya 
Fecha: 2020-07-15
Fecha actualizacion: 2020-07-15
========================================================================== */ 

/* ========================================================================== 
VARIABLES PARA INSTALAR:
$(DATABASE_NAME_DW): Nombre de la base de datos. Ejemlo: DemandaDW
$(DATABASEOLAP_STORAGEPATH): Ruta de almacenamiento de objetos de base de datos SQL Server Analysis Services. Ejemplo: C:\MSDB\Demanda_OLAP\
========================================================================== */

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - Start script: B01Data_Util.sql'
PRINT '------------------------------------------------------------------------'
GO

USE [$(DATABASE_NAME_DW)];
GO

/*
TRUNCATE TABLE [Utility].[ModuleProgramming];
DELETE FROM [Utility].[CubePartitionDetail];
DELETE FROM [Utility].[ModelParameter];
DELETE FROM [Utility].[CubePartition];
DELETE FROM [Utility].[MetricSystem];
DELETE FROM [Utility].[CubeSystem];
DELETE FROM [Utility].[ModelLoad];
DELETE FROM [Utility].[ModelSchedule];
DELETE FROM [Utility].[ModuleModel];
DELETE FROM [Utility].[ModelSystem];
DELETE FROM [Utility].[ModuleSystem];
DELETE FROM [Utility].[ScheduleSystem];
DELETE FROM [Utility].[QuerySQL];
DELETE FROM [Utility].[Subscription];
*/

/* ====================================================================================
AGENDAS DEL SISTEMA PARA EJECUTAR PROCESOS:
SELECT * FROM  [Utility].[ScheduleSystem]; 
==================================================================================== */
IF NOT EXISTS(SELECT * FROM [Utility].[ScheduleSystem] WHERE [ScheduleId] = 1)
 INSERT INTO [Utility].[ScheduleSystem]([ScheduleId],[Name],[Period],[PeriodHowMany],[DayPeriod],[DayHowMany]
  ,[DayHourStart],[DayHourEnd],[Monday],[Tuesday],[Wednesday],[Thursday],[Fryday],[Saturday],[Sunday],[OccursDayOfMonth],[DayOccurs]
  ,[OccursThe],[OccursTheDay],[DateStart],[DateEnd],[UseNotification],[NotificationDaysBefore],[NotificationDaysIsEnable],[NotificationDaysFrencence]
  ,[NotificationSubject],[NotificationBody],[Description])
 VALUES (1,'Diario 6:00 am','Dia',1,'UnaVez',1,'06:00:00','23:59:59',1,1,1,1,1,1,1,0,1,'Primer','Dia','20000101'
  ,NULL,0,0,0,0,NULL,NULL,'Cada 1 dia, en el dia una vez a las 6:00 am');
GO
IF NOT EXISTS(SELECT * FROM [Utility].[ScheduleSystem] WHERE [ScheduleId] = 2)
 INSERT INTO [Utility].[ScheduleSystem]([ScheduleId],[Name],[Period],[PeriodHowMany],[DayPeriod],[DayHowMany]
  ,[DayHourStart],[DayHourEnd],[Monday],[Tuesday],[Wednesday],[Thursday],[Fryday],[Saturday],[Sunday],[OccursDayOfMonth],[DayOccurs]
  ,[OccursThe],[OccursTheDay],[DateStart],[DateEnd],[UseNotification],[NotificationDaysBefore],[NotificationDaysIsEnable],[NotificationDaysFrencence]
  ,[NotificationSubject],[NotificationBody],[Description])
 VALUES (2,'Semanal LU - VI, 6:00:00 am','Semana',1,'UnaVez',1,'06:00:00','23:59:59',1,1,1,1,1,0,0,0,1,'Primer','Dia','20000101'
  ,NULL,0,0,0,0,NULL,NULL,'Cada 1 semana de lunes a viernes; en el día una vez a las 6:00:00 am');
GO
IF NOT EXISTS(SELECT * FROM [Utility].[ScheduleSystem] WHERE [ScheduleId] = 3)
 INSERT INTO [Utility].[ScheduleSystem]([ScheduleId],[Name],[Period],[PeriodHowMany],[DayPeriod],[DayHowMany]
  ,[DayHourStart],[DayHourEnd],[Monday],[Tuesday],[Wednesday],[Thursday],[Fryday],[Saturday],[Sunday],[OccursDayOfMonth],[DayOccurs]
  ,[OccursThe],[OccursTheDay],[DateStart],[DateEnd],[UseNotification],[NotificationDaysBefore],[NotificationDaysIsEnable],[NotificationDaysFrencence]
  ,[NotificationSubject],[NotificationBody],[Description])
 VALUES (3,'Semanal SA - DO, 6:00:00 am','Semana',1,'UnaVez',1,'06:00:00','23:59:59',0,0,0,0,0,1,1,0,1,'Primer','Dia','20000101'
  ,NULL,0,0,0,0,NULL,NULL,'Cada 1 semana de sabado a domingo; en el día una vez a las 6:00:00 am');
GO
IF NOT EXISTS(SELECT * FROM [Utility].[ScheduleSystem] WHERE [ScheduleId] = 4)
 INSERT INTO [Utility].[ScheduleSystem]([ScheduleId],[Name],[Period],[PeriodHowMany],[DayPeriod],[DayHowMany]
  ,[DayHourStart],[DayHourEnd],[Monday],[Tuesday],[Wednesday],[Thursday],[Fryday],[Saturday],[Sunday],[OccursDayOfMonth],[DayOccurs]
  ,[OccursThe],[OccursTheDay],[DateStart],[DateEnd],[UseNotification],[NotificationDaysBefore],[NotificationDaysIsEnable],[NotificationDaysFrencence]
  ,[NotificationSubject],[NotificationBody],[Description])
 VALUES (4,'Mensual primer domingo, 6:00:00 am','Mes',1,'UnaVez',1,'06:00:00','23:59:59',1,1,1,1,1,1,1,0,1,'Primer','Domingo','20000101'
  ,NULL,0,0,0,0,NULL,NULL,'Cada 1 mes el primer domingo; en el día una vez a las 6:00:00 am');
GO
IF NOT EXISTS(SELECT * FROM [Utility].[ScheduleSystem] WHERE [ScheduleId] = 5)
 INSERT INTO [Utility].[ScheduleSystem]([ScheduleId],[Name],[Period],[PeriodHowMany],[DayPeriod],[DayHowMany]
  ,[DayHourStart],[DayHourEnd],[Monday],[Tuesday],[Wednesday],[Thursday],[Fryday],[Saturday],[Sunday],[OccursDayOfMonth],[DayOccurs]
  ,[OccursThe],[OccursTheDay],[DateStart],[DateEnd],[UseNotification],[NotificationDaysBefore],[NotificationDaysIsEnable],[NotificationDaysFrencence]
  ,[NotificationSubject],[NotificationBody],[Description])
 VALUES (5,'Mensual segundo sabado, 6:00:00 am','Mes',1,'UnaVez',1,'06:00:00','23:59:59',1,1,1,1,1,1,1,0,1,'Segundo','Sabado','20000101'
  ,NULL,0,0,0,0,NULL,NULL,'Cada 1 mes el segundo sabado; en el día una vez a las 6:00:00 am');
GO
IF NOT EXISTS(SELECT * FROM [Utility].[ScheduleSystem] WHERE [ScheduleId] = 6)
 INSERT INTO [Utility].[ScheduleSystem]([ScheduleId],[Name],[Period],[PeriodHowMany],[DayPeriod],[DayHowMany]
  ,[DayHourStart],[DayHourEnd],[Monday],[Tuesday],[Wednesday],[Thursday],[Fryday],[Saturday],[Sunday],[OccursDayOfMonth],[DayOccurs]
  ,[OccursThe],[OccursTheDay],[DateStart],[DateEnd],[UseNotification],[NotificationDaysBefore],[NotificationDaysIsEnable],[NotificationDaysFrencence]
  ,[NotificationSubject],[NotificationBody],[Description])
 VALUES (6,'Mensual dia 10, 6:00:00 am','Mes',1,'UnaVez',1,'06:00:00','23:59:59',1,1,1,1,1,1,1,1,10,'Primer','Dia','20000101'
  ,NULL,0,0,0,0,NULL,NULL,'Cada 1 mes el dia 10; en el día una vez a las 6:00:00 am');
GO
IF NOT EXISTS(SELECT * FROM [Utility].[ScheduleSystem] WHERE [ScheduleId] = 7)
 INSERT INTO [Utility].[ScheduleSystem]([ScheduleId],[Name],[Period],[PeriodHowMany],[DayPeriod],[DayHowMany]
  ,[DayHourStart],[DayHourEnd],[Monday],[Tuesday],[Wednesday],[Thursday],[Fryday],[Saturday],[Sunday],[OccursDayOfMonth],[DayOccurs]
  ,[OccursThe],[OccursTheDay],[DateStart],[DateEnd],[UseNotification],[NotificationDaysBefore],[NotificationDaysIsEnable],[NotificationDaysFrencence]
  ,[NotificationSubject],[NotificationBody],[Description])
 VALUES (7,'Trimestral primer sabado, 6:00:00 pm','Mes',3,'UnaVez',1,'18:00:00','23:59:59',1,1,1,1,1,1,1,0,1,'Primer','Sabado','20000101'
  ,NULL,0,0,0,0,NULL,NULL,'Cada 3 mes el primer sabado; en el día una vez a las 6:00:00 pm');
GO

/* ====================================================================================
CONSULTAS DEL SISTEMA:
SELECT * FROM [Utility].[QuerySQL]; 

Declare @sqlQuery nvarchar(max);
SELECT @sqlQuery = [QuerySQL] FROM [Utility].[QuerySQL] WHERE [QueryId] = 'Per_ProcDim';
Print Len( @sqlQuery);
EXECUTE [Utility].[PrintLongText] @sqlQuery, 0;
==================================================================================== */
IF NOT EXISTS(SELECT * FROM [Utility].[QuerySQL] WHERE [QueryId] = 'DW_DemaP')
Begin
 declare @query nvarchar(max);
 set @query = '';
 set @query = @query +
'SELECT [FechaSKId],[PeriodoSKId],[AgenteMemDisSKId],[MercadoSKId],[GeografiaSKId],[DemandaReal],[PerdidaEnergia],[DemandaDesc] ' + 
' FROM [DW].[vFactDemandaPerdida] ';
 INSERT INTO [Utility].[QuerySQL] ([QueryId], [Name], [Type], [DatabaseId], [Parameters], [QuerySQL], [Description])
 VALUES ('DW_DemaP', 'Demanda: [DW].[vFactDemandaPerdida]', 'T', 'DemandaDW', NULL
 , @query
 ,'BD: DemandaDW - Datos de FactDemandaPerdida');
end;
GO

/* ====================================================================================
CUBOS:
SELECT * FROM  [Utility].[CubeSystem];
==================================================================================== */
IF NOT EXISTS(SELECT * FROM  [Utility].[CubeSystem] WHERE [CubeId] = 'DemandaBI')
 INSERT INTO [Utility].[CubeSystem] ([CubeId],[Name],[AppName],[Database],[Description])
 VALUES ('DemandaBI','Demanda','Demanda','Demanda_OLAP','Cubo sistema Demanda BI');
GO

/* ====================================================================================
MODELOS DEL SISTEMA (Un modelo es como un grupo de metricas el cual está formada por Fact(s) y sus dimensiones relacionadas)
SELECT * FROM [Utility].[ModelSystem];
==================================================================================== */
IF NOT EXISTS(SELECT * FROM [Utility].[ModelSystem] WHERE [ModelId] = 'DW_DFull')
 INSERT INTO [Utility].[ModelSystem] ([ModelId],[Name],[AppName],[TypeId],[UseDatesProcess],[UseVersion],[ReloadPeriodType],[Description])
 VALUES ('DW_DFull', 'DemandaBI - DW completo', 'DW', 'DW', 0, 0, 'Dia', 'DemandaBI - DW completo. Carga DW y procesamiento de cubos');
GO
IF NOT EXISTS(SELECT * FROM [Utility].[ModelSystem] WHERE [ModelId] = 'DW_DDim')
 INSERT INTO [Utility].[ModelSystem] ([ModelId],[Name],[AppName],[TypeId],[UseDatesProcess],[UseVersion],[ReloadPeriodType],[Description])
 VALUES ('DW_DDim', 'DemandaBI - Todas las dimensiones DW', 'Dimensiones-DW', 'DW', 0, 0, 'Dia', 'DemandaBI - Todas las dimensiones');
GO
IF NOT EXISTS(SELECT * FROM [Utility].[ModelSystem] WHERE [ModelId] = 'DW_DVersion')
 INSERT INTO [Utility].[ModelSystem] ([ModelId],[Name],[AppName],[TypeId],[UseDatesProcess],[UseVersion],[ReloadPeriodType],[Description])
 VALUES ('DW_DVersion', 'DemandaBI - ModelVersion', 'ModelVersion', 'DW', 1, 0, 'Dia', 'DemandaBI - version de modelos o conceptos');
GO
IF NOT EXISTS(SELECT * FROM [Utility].[ModelSystem] WHERE [ModelId] = 'DW_DDemaP')
 INSERT INTO [Utility].[ModelSystem] ([ModelId],[Name],[AppName],[TypeId],[UseDatesProcess],[UseVersion],[ReloadPeriodType],[Description])
 VALUES ('DW_DDemaP', 'DemandaBI - Modelo demanda y perdidas', 'FactDemandaPerdida', 'DW', 1, 0, 'Dia', 'DemandaBI - modelo demanda y perdidas');
GO

IF NOT EXISTS(SELECT * FROM [Utility].[ModelSystem] WHERE [ModelId] = 'DW_CDim')
 INSERT INTO [Utility].[ModelSystem] ([ModelId],[Name],[AppName],[TypeId],[UseDatesProcess],[UseVersion],[ReloadPeriodType],[Description])
 VALUES ('DW_CDim', 'DemandaBI - Dimensiones', 'Dimensiones-Cubo', 'Cubo', 0, 0, 'Dia', 'Cubo DemandaBI - Dimensiones');
GO
IF NOT EXISTS(SELECT * FROM [Utility].[ModelSystem] WHERE [ModelId] = 'DW_CDemaP')
 INSERT INTO [Utility].[ModelSystem] ([ModelId],[Name],[AppName],[TypeId],[UseDatesProcess],[UseVersion],[ReloadPeriodType],[Description])
 VALUES ('DW_CDemaP', 'DemandaBI - Cubo demanda y perdidas', 'DemandaPerdida', 'Cubo', 1, 0, 'Mes', 'DemandaBI - Cubo DemandaPerdidas');
GO

/* ====================================================================================
DISEÑO DE PARTICIONES DE GRUPOS DE MEDIDAS DE CUBOS:
SELECT * FROM  [Utility].[CubePartition];
==================================================================================== */
IF NOT EXISTS(SELECT * FROM  [Utility].[CubePartition] WHERE [CubeId] = 'DemandaBI' AND [ModelId] = 'DW_CDemaP')
 INSERT INTO [Utility].[CubePartition] ([CubeId],[ModelId],[Partitioned],[Period],[PrefixPartition],[DataSource],[QueryId],[PartitionField],[UsePathBefore],[StoragePath])
 VALUES ('DemandaBI','DW_CDemaP',1,'Mes','DemandaPerdida','dsDemandaDW', 'DW_DemaP', 'FechaSKId', 1, '$(DATABASEOLAP_STORAGEPATH)');
GO

/* ====================================================================================
MODULOS DEL SISTEMA (los módulos hacen parte de las aplicaciones. Por ejemplo una ETL para carga de datos)
SELECT * FROM [Utility].[ModuleSystem];
==================================================================================== */
IF NOT EXISTS(SELECT * FROM  [Utility].[ModuleSystem] WHERE [ModuleId] = 1)
 INSERT INTO [Utility].[ModuleSystem] ([ModuleId],[Name],[AppName],[TypeId],[ProcessTypeId],[Description])
 VALUES (1,'DemandaBI-Completo','pkgFull','ETL','UTIL_SA_DW', 'Ejecuta todas las ETL de carga: Sataging area y data warehouse, y procesa dimensiones y cubos');
GO
IF NOT EXISTS(SELECT * FROM  [Utility].[ModuleSystem] WHERE [ModuleId] = 2)
 INSERT INTO [Utility].[ModuleSystem] ([ModuleId],[Name],[AppName],[TypeId],[ProcessTypeId],[Description])
 VALUES (2,'DemandaBI-Recarga','pkgReload','ETL','UTIL_SA_DW', 'Recarga, generalmente programada con: [Utility].[spModuleProgramming_Reload] o en forma manual.');
GO
IF NOT EXISTS(SELECT * FROM  [Utility].[ModuleSystem] WHERE [ModuleId] = 3)
 INSERT INTO [Utility].[ModuleSystem] ([ModuleId],[Name],[AppName],[TypeId],[ProcessTypeId],[Description])
 VALUES (3,'DemandaBI-Demanda_OLAP_DimProcess','pkgCubeDimProcess','ETL','CUBO', 'Procesa dimensiones del cubo.');
GO
IF NOT EXISTS(SELECT * FROM  [Utility].[ModuleSystem] WHERE [ModuleId] = 4)
 INSERT INTO [Utility].[ModuleSystem] ([ModuleId],[Name],[AppName],[TypeId],[ProcessTypeId],[Description])
 VALUES (4,'DemandaBI-Demanda_OLAP_PartitionCreate','pkgCubePartitionCreate','ETL','CUBO', 'Crea particiones para el cubo.');
GO
IF NOT EXISTS(SELECT * FROM  [Utility].[ModuleSystem] WHERE [ModuleId] = 5)
 INSERT INTO [Utility].[ModuleSystem] ([ModuleId],[Name],[AppName],[TypeId],[ProcessTypeId],[Description])
 VALUES (5,'DemandaBI-Demanda_OLAP_PartitionProcess','pkgCubePartitionProcess','ETL','CUBO', 'Procesa particiones para el cubo.');
GO
IF NOT EXISTS(SELECT * FROM  [Utility].[ModuleSystem] WHERE [ModuleId] = 6)
 INSERT INTO [Utility].[ModuleSystem] ([ModuleId],[Name],[AppName],[TypeId],[ProcessTypeId],[Description])
 VALUES (6,'DemandaBI-ModelVersion','pkgVersion','ETL','UTIL_SA_DW', 'Carga las tablas ModelVersion: SA y DW.');
GO

IF NOT EXISTS(SELECT * FROM  [Utility].[ModuleSystem] WHERE [ModuleId] = 7)
 INSERT INTO [Utility].[ModuleSystem] ([ModuleId],[Name],[AppName],[TypeId],[ProcessTypeId],[Description])
 VALUES (7,'DemandaBI-DimAgente','pkgDimAgente','ETL','DIM_SA_DW', 'Carga las tablas DimAgente: SA y DW.');
GO
IF NOT EXISTS(SELECT * FROM  [Utility].[ModuleSystem] WHERE [ModuleId] = 8)
 INSERT INTO [Utility].[ModuleSystem] ([ModuleId],[Name],[AppName],[TypeId],[ProcessTypeId],[Description])
 VALUES (8,'DemandaBI-DimCompania','pkgDimCompania','ETL','DIM_SA_DW', 'Carga las tablas DimCompania: SA y DW.');
GO
IF NOT EXISTS(SELECT * FROM  [Utility].[ModuleSystem] WHERE [ModuleId] = 9)
 INSERT INTO [Utility].[ModuleSystem] ([ModuleId],[Name],[AppName],[TypeId],[ProcessTypeId],[Description])
 VALUES (9,'DemandaBI-DimGeografia','pkgDimGeografia','ETL','DIM_SA_DW', 'Carga las tablas DimGeografia: SA y DW.');
GO

IF NOT EXISTS(SELECT * FROM  [Utility].[ModuleSystem] WHERE [ModuleId] = 10)
 INSERT INTO [Utility].[ModuleSystem] ([ModuleId],[Name],[AppName],[TypeId],[ProcessTypeId],[Description])
 VALUES (10,'DemandaBI-FactDemandaPerdida','pkgFactDemandaPerdida','ETL','DIM_SA_DW', 'Carga las tablas FactDemandaPerdida: SA y DW.');
GO

/* ====================================================================================
SECUENCIA DE MODULOS (por ejemplo una ETL a ser ejecutados para procesar los modelos del sistema)
SELECT * FROM [Utility].[ModuleModel];
==================================================================================== */
IF NOT EXISTS(SELECT * FROM [Utility].[ModuleModel] WHERE [ModuleId] = 2 AND [ModelId] = 'DW_DVersion')
 INSERT INTO [Utility].[ModuleModel]([ModuleId],[ModelId],[SequenceId])
 VALUES (2, 'DW_DVersion', 1);
GO

IF NOT EXISTS(SELECT * FROM [Utility].[ModuleModel] WHERE [ModuleId] = 3 AND [ModelId] = 'DW_CDim')
 INSERT INTO [Utility].[ModuleModel]([ModuleId],[ModelId],[SequenceId])
 VALUES (3, 'DW_CDim', 1);
GO

IF NOT EXISTS(SELECT * FROM [Utility].[ModuleModel] WHERE [ModuleId] = 10 AND [ModelId] = 'DW_DDemaP')
 INSERT INTO [Utility].[ModuleModel]([ModuleId],[ModelId],[SequenceId])
 VALUES (10, 'DW_DDemaP', 1);
GO
IF NOT EXISTS(SELECT * FROM [Utility].[ModuleModel] WHERE [ModuleId] = 4 AND [ModelId] = 'DW_CDemaP')
 INSERT INTO [Utility].[ModuleModel]([ModuleId],[ModelId],[SequenceId])
 VALUES (4, 'DW_CDemaP', 1);
GO
IF NOT EXISTS(SELECT * FROM [Utility].[ModuleModel] WHERE [ModuleId] = 5 AND [ModelId] = 'DW_CDemaP')
 INSERT INTO [Utility].[ModuleModel]([ModuleId],[ModelId],[SequenceId])
 VALUES (5, 'DW_CDemaP', 2);
GO

/* ====================================================================================
CARGA DE MODELOS 
SELECT * FROM [Utility].[ModelLoad] ORDER BY [ModelId], [SequenceId];
SELECT * FROM [Utility].[ModuleModel];
SELECT * FROM [Utility].[ModelSystem];
SELECT * FROM [Utility].[ModuleSystem];
==================================================================================== */
IF NOT EXISTS(SELECT * FROM [Utility].[ModelLoad] WHERE [ModelId] = 'DW_DVersion' AND [SequenceId] = 1)
 INSERT INTO [Utility].[ModelLoad]([ModelId],[SequenceId],[ModuleId],[ModelProgId])
 VALUES ('DW_DVersion', 1, 6, 'DW_DVersion');
GO

IF NOT EXISTS(SELECT * FROM [Utility].[ModelLoad] WHERE [ModelId] = 'DW_DFull' AND [SequenceId] = 1)
 INSERT INTO [Utility].[ModelLoad]([ModelId],[SequenceId],[ModuleId],[ModelProgId])
 VALUES ('DW_DFull', 1, 9, 'DW_DDim');
GO
IF NOT EXISTS(SELECT * FROM [Utility].[ModelLoad] WHERE [ModelId] = 'DW_DFull' AND [SequenceId] = 2)
 INSERT INTO [Utility].[ModelLoad]([ModelId],[SequenceId],[ModuleId],[ModelProgId])
 VALUES ('DW_DFull', 2, 8, 'DW_DDim');
GO
IF NOT EXISTS(SELECT * FROM [Utility].[ModelLoad] WHERE [ModelId] = 'DW_DFull' AND [SequenceId] = 3)
 INSERT INTO [Utility].[ModelLoad]([ModelId],[SequenceId],[ModuleId],[ModelProgId])
 VALUES ('DW_DFull', 3, 7, 'DW_DDim');
GO

IF NOT EXISTS(SELECT * FROM [Utility].[ModelLoad] WHERE [ModelId] = 'DW_DFull' AND [SequenceId] = 4)
 INSERT INTO [Utility].[ModelLoad]([ModelId],[SequenceId],[ModuleId],[ModelProgId])
 VALUES ('DW_DFull', 4, 10, 'DW_DDemaP');
GO

IF NOT EXISTS(SELECT * FROM [Utility].[ModelLoad] WHERE [ModelId] = 'DW_DFull' AND [SequenceId] = 5)
 INSERT INTO [Utility].[ModelLoad]([ModelId],[SequenceId],[ModuleId],[ModelProgId])
 VALUES ('DW_DFull', 5, 3, 'DW_CDim');
GO
IF NOT EXISTS(SELECT * FROM [Utility].[ModelLoad] WHERE [ModelId] = 'DW_DFull' AND [SequenceId] = 6)
 INSERT INTO [Utility].[ModelLoad]([ModelId],[SequenceId],[ModuleId],[ModelProgId])
 VALUES ('DW_DFull', 6, 4, 'DW_CDemaP');
GO
IF NOT EXISTS(SELECT * FROM [Utility].[ModelLoad] WHERE [ModelId] = 'DW_DFull' AND [SequenceId] = 7)
 INSERT INTO [Utility].[ModelLoad]([ModelId],[SequenceId],[ModuleId],[ModelProgId])
 VALUES ('DW_DFull', 7, 5, 'DW_CDemaP');
GO

IF NOT EXISTS(SELECT * FROM [Utility].[ModelLoad] WHERE [ModelId] = 'DW_DDim' AND [SequenceId] = 1)
 INSERT INTO [Utility].[ModelLoad]([ModelId],[SequenceId],[ModuleId],[ModelProgId])
 VALUES ('DW_DDim', 1, 9, 'DW_DDim');
GO
IF NOT EXISTS(SELECT * FROM [Utility].[ModelLoad] WHERE [ModelId] = 'DW_DDim' AND [SequenceId] = 2)
 INSERT INTO [Utility].[ModelLoad]([ModelId],[SequenceId],[ModuleId],[ModelProgId])
 VALUES ('DW_DDim', 2, 8, 'DW_DDim');
GO
IF NOT EXISTS(SELECT * FROM [Utility].[ModelLoad] WHERE [ModelId] = 'DW_DDim' AND [SequenceId] = 3)
 INSERT INTO [Utility].[ModelLoad]([ModelId],[SequenceId],[ModuleId],[ModelProgId])
 VALUES ('DW_DDim', 3, 7, 'DW_DDim');
GO
IF NOT EXISTS(SELECT * FROM [Utility].[ModelLoad] WHERE [ModelId] = 'DW_DDim' AND [SequenceId] = 4)
 INSERT INTO [Utility].[ModelLoad]([ModelId],[SequenceId],[ModuleId],[ModelProgId])
 VALUES ('DW_DDim', 4, 3, 'DW_CDim');
GO

IF NOT EXISTS(SELECT * FROM [Utility].[ModelLoad] WHERE [ModelId] = 'DW_CDim' AND [SequenceId] = 1)
 INSERT INTO [Utility].[ModelLoad]([ModelId],[SequenceId],[ModuleId],[ModelProgId])
 VALUES ('DW_CDim', 1, 3, 'DW_CDim');
GO

IF NOT EXISTS(SELECT * FROM [Utility].[ModelLoad] WHERE [ModelId] = 'DW_DDemaP' AND [SequenceId] = 1)
 INSERT INTO [Utility].[ModelLoad]([ModelId],[SequenceId],[ModuleId],[ModelProgId])
 VALUES ('DW_DDemaP', 1, 9, 'DW_DDim');
GO
IF NOT EXISTS(SELECT * FROM [Utility].[ModelLoad] WHERE [ModelId] = 'DW_DDemaP' AND [SequenceId] = 2)
 INSERT INTO [Utility].[ModelLoad]([ModelId],[SequenceId],[ModuleId],[ModelProgId])
 VALUES ('DW_DDemaP', 2, 8, 'DW_DDim');
GO
IF NOT EXISTS(SELECT * FROM [Utility].[ModelLoad] WHERE [ModelId] = 'DW_DDemaP' AND [SequenceId] = 3)
 INSERT INTO [Utility].[ModelLoad]([ModelId],[SequenceId],[ModuleId],[ModelProgId])
 VALUES ('DW_DDemaP', 3, 7, 'DW_DDim');
GO
IF NOT EXISTS(SELECT * FROM [Utility].[ModelLoad] WHERE [ModelId] = 'DW_DDemaP' AND [SequenceId] = 4)
 INSERT INTO [Utility].[ModelLoad]([ModelId],[SequenceId],[ModuleId],[ModelProgId])
 VALUES ('DW_DDemaP', 4, 10, 'DW_DDemaP');
GO
IF NOT EXISTS(SELECT * FROM [Utility].[ModelLoad] WHERE [ModelId] = 'DW_DDemaP' AND [SequenceId] = 5)
 INSERT INTO [Utility].[ModelLoad]([ModelId],[SequenceId],[ModuleId],[ModelProgId])
 VALUES ('DW_DDemaP', 5, 3, 'DW_CDim');
GO
IF NOT EXISTS(SELECT * FROM [Utility].[ModelLoad] WHERE [ModelId] = 'DW_DDemaP' AND [SequenceId] = 6)
 INSERT INTO [Utility].[ModelLoad]([ModelId],[SequenceId],[ModuleId],[ModelProgId])
 VALUES ('DW_DDemaP', 6, 4, 'DW_CDemaP');
GO
IF NOT EXISTS(SELECT * FROM [Utility].[ModelLoad] WHERE [ModelId] = 'DW_DDemaP' AND [SequenceId] = 7)
 INSERT INTO [Utility].[ModelLoad]([ModelId],[SequenceId],[ModuleId],[ModelProgId])
 VALUES ('DW_DDemaP', 7, 5, 'DW_CDemaP');
GO

/* ====================================================================================
METRICAS O VARIABLES DEL SISTEMA (asociadas a un modelo y grupo de medidas)
SELECT * FROM  [Utility].[MetricSystem];
SELECT * FROM  [Utility].[ModelSystem];
SELECT * FROM  [Utility].[QuerySQL];
==================================================================================== */
IF NOT EXISTS(SELECT * FROM [Utility].[MetricSystem] WHERE [MetricId] = 1)
 INSERT INTO [Utility].[MetricSystem] ([MetricId],[Name],[AppName],[ModelId],[DatabaseId],[Table],[Field],[QueryId],[DateStart],[DateEnd],[CalculationType]
  ,[UnityId],[BusinessRule],[Formula],[Group1Id],[Group2Id],[Group3Id],[MetadataId],[Description],[BitacoraId])
 VALUES (1,'Dem_Demanda real','Dem_Demanda real','DW_CDemaP','DW','FactDemandaPerdida','DemandaReal'
 ,'DW_DemaP','20000101','20191031','Natural','MWh',NULL,'Sum',NULL,NULL,NULL,NULL,'Demanda real.',0);
GO
IF NOT EXISTS(SELECT * FROM [Utility].[MetricSystem] WHERE [MetricId] = 2)
 INSERT INTO [Utility].[MetricSystem] ([MetricId],[Name],[AppName],[ModelId],[DatabaseId],[Table],[Field],[QueryId],[DateStart],[DateEnd],[CalculationType]
  ,[UnityId],[BusinessRule],[Formula],[Group1Id],[Group2Id],[Group3Id],[MetadataId],[Description],[BitacoraId])
 VALUES (2,'Dem_Perdida energia','Dem_Perdida energia','DW_CDemaP','DW','FactDemandaPerdida','PerdidaEnergia'
 ,'DW_DemaP','20000101','20191031','Natural','MWh',NULL,'Sum',NULL,NULL,NULL,NULL,'Perdida de energia.',0);
GO
IF NOT EXISTS(SELECT * FROM [Utility].[MetricSystem] WHERE [MetricId] = 3)
 INSERT INTO [Utility].[MetricSystem] ([MetricId],[Name],[AppName],[ModelId],[DatabaseId],[Table],[Field],[QueryId],[DateStart],[DateEnd],[CalculationType]
  ,[UnityId],[BusinessRule],[Formula],[Group1Id],[Group2Id],[Group3Id],[MetadataId],[Description],[BitacoraId])
 VALUES (3,'Dem_Contar','Dem_Contar','DW_CDemaP','DW','FactDemandaPerdida',''
 ,'DW_DemaP','20000101','20191031','Calculada','#',NULL,'Count',NULL,NULL,NULL,NULL,'Cuenta numero de filas.',0);
GO

/* ====================================================================================
AGENDA Y DIAS DE PROCESAMIENTO DE DATOS PARA LOS MODELOS DEL SISTEMA
SELECT * FROM  [Utility].[ModelSchedule];
==================================================================================== */
IF NOT EXISTS(SELECT * FROM [Utility].[ModelSchedule] WHERE [ModelId] = 'DW_DDemaP' AND [ScheduleId] = 1)
 INSERT INTO [Utility].[ModelSchedule]([ModelId],[ScheduleId],[UseVersion],[PeriodType],[PeriodQuantity],[PeriodTypeBefore],[PeriodsBefore],[Enabled],[Description])
 VALUES ('DW_DDemaP',1,0,'Dia',1,'Dia',1,1,'Carga dia anterior, 1 dia de datos, en forma diaria.');
GO

/* No requiere agendadar procesar dimensiones (DW_CDim), porque siempre son procesadas en forma diaria */ 

IF NOT EXISTS(SELECT * FROM [Utility].[ModelSchedule] WHERE [ModelId] = 'DW_CDemaP' AND [ScheduleId] = 1)
 INSERT INTO [Utility].[ModelSchedule]([ModelId],[ScheduleId],[UseVersion],[PeriodType],[PeriodQuantity],[PeriodTypeBefore],[PeriodsBefore],[Enabled],[Description])
 VALUES ('DW_CDemaP',1,0,'Mes',2,'Mes',0,1,'Procesa mes anterior y el actual, en forma diaria.');
GO

/* ====================================================================================
CREAR DETALLE DE PARTICIONES
SELECT * FROM [Utility].[CubePartition];
SELECT * FROM [Utility].[CubePartitionDetail];
==================================================================================== */
EXECUTE [Utility].[spOLAP_PartitionDefine] 0, 'DemandaBI', 'DW_CDemaP', '2000-01-01', '2020-01-01', 0;
GO

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - End script: B01Data_Util.sql'
PRINT '------------------------------------------------------------------------'
GO
