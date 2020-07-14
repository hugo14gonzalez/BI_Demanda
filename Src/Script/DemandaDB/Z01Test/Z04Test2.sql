/* ========================================================================== 
Proyecto: DemandaBI
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya 
Fecha: 2020-07-15
Fecha actualizacion: 2020-07-15
========================================================================== */ 

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - Start script: Z04Test2.sql'
PRINT '------------------------------------------------------------------------'
GO

USE [DemandaDW];

/* ====================================================================================
Borrar tablas de datos
==================================================================================== */
/* Borrar tablas de log
TRUNCATE TABLE [Audit].[BitacoraFile];
TRUNCATE TABLE [Audit].[BitacoraDetail];
TRUNCATE TABLE [Audit].[BitacoraStatistic];
TRUNCATE TABLE [Audit].[BitacoraTable];
DELETE FROM [Audit].[Bitacora] WHERE [BitacoraId] > 0;
DBCC CHECKIDENT ('Audit.Bitacora', RESEED, 0);
*/

/*
DELETE FROM [DW].[DimAgente] WHERE [AgenteSKId] > 0;
DBCC CHECKIDENT ('DW.DimAgente', RESEED, 0);
GO
DELETE FROM [DW].[DimCompania] WHERE [CompaniaSKId] > 0;
DBCC CHECKIDENT ('DW.DimCompania', RESEED, 0);
GO
DELETE FROM [DW].[DimGeografia] WHERE [GeografiaSKId] > 0;
DBCC CHECKIDENT ('DW.DimGeografia', RESEED, 0);
GO
*/

/*
TRUNCATE TABLE [DW].[FactDemandaPerdida];
*/

/*
DELETE FROM [Utility].[ModelVersion];
*/

/* RUTA AMBIENTE DESARRLLO
UPDATE [Utility].[CubePartition] SET [StoragePath] = 'G:\MSDB\Demanda_OLAP\';
*/

/* ====================================================================================
TEST 1: Tablas maestras y parametros, pobladas en forma manual tiene datos
==================================================================================== */
SELECT TOP 3 * FROM [DW].[DimFecha]; 
/*
FechaSKId   Fecha      FechaDesc  Anio   Semestre SemestreDesc    Trimestre TrimestreDesc   Mes    MesNombre  MesNombreCorto MesDesc         MesDescCorto SemanaAnio SemanaAnioDesc  Dia    DiaAnio DiaSemana DiaNombre  DiaNombreCorto DiaTipo
----------- ---------- ---------- ------ -------- --------------- --------- --------------- ------ ---------- -------------- --------------- ------------ ---------- --------------- ------ ------- --------- ---------- -------------- ----------
0           1900-01-01 1900-01-01 1900   1        1900-Semestre1  1         1900-Trim1      1      Enero      Ene            1900-Enero      1900-Ene     1          1900-Semana01   1      1       1         Lunes      Lun            Festivo
20050101    2005-01-01 2005-01-01 2005   1        2005-Semestre1  1         2005-Trim1      1      Enero      Ene            2005-Enero      2005-Ene     1          2005-Semana01   1      1       6         Sabado     Sab            Festivo
20050102    2005-01-02 2005-01-02 2005   1        2005-Semestre1  1         2005-Trim1      1      Enero      Ene            2005-Enero      2005-Ene     1          2005-Semana01   2      2       7         Domingo    Dom            No habil
*/

SELECT TOP 3 * FROM [DW].[DimFecha] ORDER BY [FechaSKId] DESC;
/*
FechaSKId   Fecha      FechaDesc  Anio   Semestre SemestreDesc    Trimestre TrimestreDesc   Mes    MesNombre  MesNombreCorto MesDesc         MesDescCorto SemanaAnio SemanaAnioDesc  Dia    DiaAnio DiaSemana DiaNombre  DiaNombreCorto DiaTipo
----------- ---------- ---------- ------ -------- --------------- --------- --------------- ------ ---------- -------------- --------------- ------------ ---------- --------------- ------ ------- --------- ---------- -------------- ----------
20190101    2019-01-01 2019-01-01 2019   1        2019-Semestre1  1         2019-Trim1      1      Enero      Ene            2019-Enero      2019-Ene     1          2019-Semana01   1      1       2         Martes     Mar            Festivo
20181231    2018-12-31 2018-12-31 2018   2        2018-Semestre2  4         2018-Trim4      12     Diciembre  Dic            2018-Diciembre  2018-Dic     53         2018-Semana53   31     365     1         Monday     Mon            Habil
20181230    2018-12-30 2018-12-30 2018   2        2018-Semestre2  4         2018-Trim4      12     Diciembre  Dic            2018-Diciembre  2018-Dic     52         2018-Semana52   30     364     7         Domingo    Dom            No habil
*/

SELECT * FROM [DW].[DimPeriodo]




SELECT * FROM [DW].[DimMercado];


/* ====================================================================================
TEST 2: Las ETLs dejan log de ejecución
-- SELECT * from sysprocesses
==================================================================================== */
SELECT * FROM [Audit].[Bitacora] ORDER BY [BitacoraId];

/* A. Tablas de auditoria */
SELECT * FROM [Audit].[GetBitacoraTree]((SELECT Max([BitacoraId]) FROM [Audit].[Bitacora]), 1) ORDER BY Id;
/*

*/


SELECT * FROM [Audit].[GetBitacoraStatisticTree]((SELECT Max([BitacoraId]) FROM [Audit].[Bitacora]), 1) ORDER BY Id;
SELECT * FROM [Audit].[BitacoraStatistic] ORDER BY [Name], [DateStart];
/*

*/

SELECT * FROM [Audit].[GetBitacoraTableTree]((SELECT Max([BitacoraId]) FROM [Audit].[Bitacora]), 1) ORDER BY Id;
SELECT * FROM [Audit].[BitacoraTable];
/*

*/

SELECT * FROM [Audit].[GetBitacoraDetailTree]((SELECT Max([BitacoraId]) FROM [Audit].[Bitacora]), 1) ORDER BY Id;
/*

*/

SELECT * FROM [Audit].[GetBitacoraFileTree]((SELECT Max([BitacoraId]) FROM [Audit].[Bitacora]), 1) ORDER BY Id;
SELECT * FROM [Audit].[BitacoraFile] ORDER BY FileId;
/*

*/


SELECT * FROM [Utility].[ModuleProgramming] ORDER BY [ModuleId],[DateStart];
/* 

*/

/* B. Archivos de log en disco, dejados por las ETLs */


/* C. El job, deja log en el historial del job */


/* ====================================================================================
TEST 3: La ETL pkgDimGeografia carga la tabla: DimGeografia
==================================================================================== */
SELECT Count(*) FROM [Staging].[TmpDimGeografia];
/* 1166 */
SELECT Count(*) FROM [DW].[DimGeografia];
/* 1166 */

SELECT TOP 3 * FROM [Staging].[TmpDimGeografia] ORDER BY PaisId, DepartamentoId, MunicipioId;
/*
TmpSKId     PaisId     Pais      DepartamentoId Departamento  MunicipioId Municipio     AreaId     Area                SubAreaId  SubArea         Inconsistent BitacoraId
----------- ---------- --------- -------------- ---------     ----------- ---------     ---------- ---------           ---------- ---------       ------------ ----------
4           Pai0001    COLOMBIA  Dep0001        AMAZONAS      Mpi0001     LETICIA       Are0128    AREA SUROCCIDENTAL  Are0026    SUBAREA CAQUETA     0            47
1           Pai0001    COLOMBIA  Dep0001        AMAZONAS      Mpi0002     EL ENCANTO    Are0128    AREA SUROCCIDENTAL  Are0026    SUBAREA CAQUETA     0            47
2           Pai0001    COLOMBIA  Dep0001        AMAZONAS      Mpi0003     LA CHORRERA   Are0128    AREA SUROCCIDENTAL  Are0026    SUBAREA CAQUETA     0            47

*/

SELECT * FROM [DW].[DimGeografia];
/*
GeografiaSKId PaisId     Pais      DepartamentoId Departamento  MunicipioId Municipio     AreaId     Area                SubAreaId SubArea            BitacoraId
------------- ---------- --------- -------------- ---------     ----------- ---------     ---------- ---------------     --------- ------------------ ----------
0             NA         NA        NA             NA            NA          NA            NA         NA                  NA         NA                  0
1             Pai0001    COLOMBIA  Dep0001        AMAZONAS      Mpi0001     LETICIA       Are0128    AREA SUROCCIDENTAL  Are0026    SUBAREA CAQUETA     2
2             Pai0001    COLOMBIA  Dep0001        AMAZONAS      Mpi0002     EL ENCANTO    Are0128    AREA SUROCCIDENTAL  Are0026    SUBAREA CAQUETA     2
3             Pai0001    COLOMBIA  Dep0001        AMAZONAS      Mpi0003     LA CHORRERA   Are0128    AREA SUROCCIDENTAL  Are0026    SUBAREA CAQUETA     2
*/


/* ====================================================================================
TEST 5: La ETL pkgDimCompania carga la tabla: DimCompania
==================================================================================== */
SELECT Count(*) FROM [Staging].[TmpDimCompania];
/* 462 */
SELECT Count(*) FROM [DW].[DimCompania];
/* 464  */

SELECT TOP 3 * FROM [Staging].[TmpDimCompania] ORDER BY [CompaniaId], [FechaIniSKId];
/*
TmpSKId	CompaniaId	Nombre	Sigla	Nit	TipoPropiedad	Activa	FechaIni	FechaIniSKId	FechaFin	FechaFinSKId	Inconsistent	Row	BitacoraId
1	Cia0001	CENTRAL HIDROELECTRICA DE BETANIA S.A. E.S.P.	CHB	8600638758	PRIVADA	1	1995-07-20	19950720	2007-09-01	20070901	0	NULL	48
2	Cia0001	CENTRAL HIDROELECTRICA DE BETANIA S.A. E.S.P.	CHB	8600638758	PRIVADA	0	2007-09-01	20070901	NULL	NULL	0	NULL	48
3	Cia0002	CENTRAL HIDROELECTRICA DE CALDAS S.A. E.S.P.	CHEC	890800128-6	MIXTA	1	1995-07-20	19950720	NULL	NULL	0	NULL	48
*/

SELECT * FROM [DW].[DimCompania] ORDER BY [CompaniaId], [FechaIniSKId];
/*
CompaniaSKId	CompaniaId	Nombre	Sigla	Nit	TipoPropiedad	Activa	EsActual	FechaIniSKId	FechaFinSKId	BitacoraId
1	Cia0001	CENTRAL HIDROELECTRICA DE BETANIA S.A. E.S.P.	CHB	8600638758	PRIVADA	1	0	19950720	20070901	3
2	Cia0001	CENTRAL HIDROELECTRICA DE BETANIA S.A. E.S.P.	CHB	8600638758	PRIVADA	0	1	20070901	NULL	3
3	Cia0002	CENTRAL HIDROELECTRICA DE CALDAS S.A. E.S.P.	CHEC	890800128-6	MIXTA	1	1	19950720	NULL	3
*/

SELECT * FROM [DW].[DimCompania] WHERE [Nombre] like '%OCCIDENTE%';


/* ====================================================================================
TEST 5: La ETL pkgDimAgente carga la tabla: DimAgente
==================================================================================== */
SELECT Count(*) FROM [Staging].[TmpDimAgente];
/* 825 */
SELECT Count(*) FROM [DW].[DimAgente];
/* 828 */

SELECT TOP 3 * FROM [Staging].[TmpDimAgente] ORDER BY AgenteMemId, [FechaIniSKId];
/*
TmpSKId	AgenteId	AgenteMemId	Nombre	Actividad	CompaniaId	CompaniaSKId	Activo	FechaIni	FechaIniSKId	FechaFin	FechaFinSKId	Inconsistent	Row	BitacoraId
1	Ung0921	ABAG	AURES BAJO S.A.S. E.S.P.	GENERACION	Cia5927	436	1	2017-08-28	20170828	2018-05-18	20180518	0	NULL	49
2	Ung0921	ABAG	AURES BAJO S.A.S. E.S.P.	GENERACION	Cia5927	437	1	2018-05-18	20180518	NULL	NULL	0	NULL	49
3	Ung0873	ACEC	ASELCA COMERCIALIZADORA DE ENERGIA S.A. E.S.P.	COMERCIALIZACION	Cia5881	396	1	2015-12-29	20151229	NULL	NULL	0	NULL	49
*/

SELECT * FROM [DW].[DimAgente] ORDER BY AgenteMemId, [FechaIniSKId];
/*

*/

/* ========================================================================== 
TEST 14: La ETL pkgFactDemandaPerdida carga la tabla: FactDemandaPerdida
========================================================================== */
SELECT Count(*) FROM [Staging].[TmpFactDemandaPerdida] 
/*  */ 
SELECT Count(*) FROM [Staging].[TmpFactDemandaPerdida] WHERE [Inconsistent] = 0 ;
/*  */
SELECT Count(*) FROM [Staging].[TmpFactDemandaPerdida] WHERE [Inconsistent] = 1 ;

SELECT Count(*) FROM [DW].[FactDemandaPerdida]; 
/* 121,706,501 */
SELECT Count(*) FROM [DW].[FactDemandaPerdida] WHERE [fechaSKId] >= 20100101 AND [fechaSKId] < 20100103; 
/* 125936 */

SELECT TOP 3 * FROM [Staging].[TmpFactDemandaPerdida] ORDER BY [FechaSKId],[PeriodoSKId], [MercadoSKId];

SELECT TOP 3 * FROM [DW].[FactDemandaPerdida] WHERE [fechaSKId] >= 20100101 AND [fechaSKId] < 20100103
ORDER BY [FechaSKId],[PeriodoSKId],[MercadoSKId];
/* 

*/

SELECT F.[Anio], F.[Mes], Count(*) Contar
FROM [DW].[FactDemandaPerdida] E
INNER JOIN [DW].[DimFecha] F ON F.[FechaSKId] = E.[FechaSKId]
GROUP BY F.[Anio], F.[Mes]
ORDER BY F.[Anio], F.[Mes];
/*

*/

-- Estado de la programacion
SELECT * FROM [Utility].[ModuleProgramming] ORDER BY [ModuleId],[DateStart];


/* ========================================================================== 
TEST 29: La ETL pkgCubeDimProcess procesa las dimensiones
TEST 30: La ETL pkgCubePartitionCreate crea particiones en los grupos de medidas de los cubos
TEST 31: La ETL pkgCubePartitionProcess procesa particiones en los grupos de medidas de los cubos
========================================================================== */
--DELETE FROM [Utility].[CubePartitionDetail];
--DELETE FROM [Utility].[CubePartition];
--DELETE FROM [Utility].[ModuleProgramming];
--DELETE FROM [Utility].[ModelSchedule];
--DELETE FROM [Utility].[ScheduleSystem];
--DELETE FROM [Utility].[ModeloModulo];
--DELETE FROM [Utility].[MetricSystem];
--DELETE FROM [Utility].[ModelSystem];
--DELETE FROM [Utility].[QuerySQL];
--DELETE FROM [Utility].[CubeSystem];
--DELETE FROM [Utility].[ModuleSystem];
--UPDATE [Utility].[CubePartitionDetail] SET [Create] = 1, [Update] = 0, [Process] = 1, [CreateBitacoraId] = 0, [ProcessBitacoraId] = 0;

-- ETL Full, crea la agenda de ejecucion
-- TRUNCATE TABLE [Utility].[ModuleProgramming];
EXECUTE [Utility].[spModuleProgramming_Sheduling] 0;

-- La ETL de procesamiento revisa la progrmacion
EXECUTE [Utility].[spOLAP_QueryProgramming] 22;
EXECUTE [Utility].[spOLAP_QueryProgramming] 23;

-- Consultar programacion particiones
SELECT * FROM  [Utility].[CubePartitionDetail] WHERE [CubeId] = 'DemandaBI' ORDER BY [ModelId], [PartitionId];
SELECT * FROM [Utility].[ModuleProgramming] ORDER BY [ModuleId],[ModelId],[DateStart];

EXECUTE [Utility].[spOLAP_QueryPartition] 0, NULL, 'pkgCubePartitionCreate', 'ETL';
EXECUTE [Utility].[spOLAP_QueryPartition] 1, NULL, 'pkgCubePartitionProcess', 'ETL';

/* ========================================================================== 
TEST 32: La ETL pkgFull realiza el proceso de carga de todo el data warehouse y procesamiento OLAP
========================================================================== */
SELECT * FROM [Audit].[Bitacora] ORDER BY [Name];

/* A. Tablas de auditoria */
SELECT * FROM [Audit].[GetBitacoraTree]((SELECT Max([BitacoraId]) FROM [Audit].[Bitacora]), 1);
/*
Id          Level       BitacoraId           ParentId             AppId        ModuleId    Name                                                                                                                             StateId State                                              DateStart               DateEnd                 TimeDuration                   DateWorkStart           DateWorkEnd             ProcessId            ProcessStringId      UserId      MachineId                                                                                            FailureTask                                                                                                                      Message
----------- ----------- -------------------- -------------------- ------------ ----------- -------------------------------------------------------------------------------------------------------------------------------- ------- -------------------------------------------------- ----------------------- ----------------------- ------------------------------ ----------------------- ----------------------- -------------------- -------------------- ----------- ---------------------------------------------------------------------------------------------------- -------------------------------------------------------------------------------------------------------------------------------- -------------------------------------------------------------------------------------------------------------------
1           0           22                   NULL                 ETL          7           pkgDWFactMLP_MDA                                                                                                                 0       Exitoso                                            2017-06-05 16:27:15.463 2017-06-05 16:53:15.520 0 Horas 26:00                  NULL                    NULL                    0                    NULL                 0           ETL                                                                                                  NULL                                                                                                                             NULL
*/

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - End script: Z04Test2.sql'
PRINT '------------------------------------------------------------------------'
GO
