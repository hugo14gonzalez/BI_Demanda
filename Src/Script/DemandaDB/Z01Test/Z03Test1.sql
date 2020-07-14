/* ========================================================================== 
Proyecto: DemandaBI
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya 
Fecha: 2020-07-15
Fecha actualizacion: 2020-07-15
========================================================================== */ 

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - Start script: Z03Test1.sql'
PRINT '------------------------------------------------------------------------'
GO

USE [DemandaDW];

/* ====================================================================================
CONSULTAR PROGRAMACION
==================================================================================== */
/* Consultar programacion en forma detallada */
SELECT MP.[Priority], MP.[ModelId],MO.[AppName] As [Model],MP.[SequenceId],MP.[ModuleId],MD.[AppName] As [Module]
,MP.[ModelProgId],MOP.[AppName] As [ModelProg],MP.[DateVersion],MP.[DateStart],MP.[DateEnd],MP.[Version],MP.[VersionId]
,MP.[StateId],MP.[DateUpdate] 
FROM [Utility].[ModuleProgramming] MP
INNER JOIN [Utility].[ModuleSystem] MD ON MD.[ModuleId] = MP.[ModuleId]
INNER JOIN [Utility].[ModelSystem] MO ON MO.[ModelId] = MP.[ModelId]
INNER JOIN [Utility].[ModelSystem] MOP ON MOP.[ModelId] = MP.[ModelProgId]
--WHERE MP.[StateId] <> 20
ORDER BY MP.[Priority],MP.[ModelId],MP.[SequenceId],MP.[DateStart];

/* Consultar programacion en forma compacta */
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

SELECT * FROM  [Utility].[CubePartitionDetail] ORDER BY [CubeId], [ModelId], [PartitionId];

/* Consultar programacion */
EXECUTE [Utility].[spModuleProgramming_Query] NULL, 'pkgFactDemandaPerdida', 'ETL';

EXECUTE [Utility].[spOLAP_QueryProgramming] NULL, 'pkgCubePartitionCreate', 'ETL';
EXECUTE [Utility].[spOLAP_QueryPartition] 0, NULL, 'pkgCubePartitionCreate', 'ETL';

EXECUTE [Utility].[spOLAP_QueryProgramming] NULL, 'pkgCubePartitionProcess', 'ETL';
EXECUTE [Utility].[spOLAP_QueryPartition] 1, NULL, 'pkgCubePartitionProcess', 'ETL';


EXECUTE [Utility].[spGetQuerySQL] 'DW_TDemaP', '@dateStart=2017-01-01&@dateEnd=2017-02-01&@version=0&@versionId=0', @query OUTPUT, 1;
Print @query;

/* Agendar programacion, al inicio del paquete: pkgFull */
-- EXECUTE [Utility].[spModuleProgramming_Sheduling] 0;

--EXECUTE [Utility].[spModuleProgramming_Query] NULL, 'pkgFactDemandaPerdida', 'ETL';
--EXECUTE [Utility].[spModuleProgramming_UpdateState] 10, 0, '2013-04-14', 'DW_DDemaP', 11, 'pkgFactDemandaPerdida', 'ETL';

/* ====================================================================================
PROGRAMAR RECARGA
SELECT * FROM [Utility].[ModuleProgramming] WHERE [StateId] = 1;
==================================================================================== */
/* Borrar todo para evitar información histórica */
-- TRUNCATE TABLE [Utility].[ModuleProgramming];

-- SELECT * FROM [Utility].[ModuleProgramming] WHERE [ModelProgId] = 'DW_CDim' OR [ModuleId] = 4;
-- DELETE FROM [Utility].[ModuleProgramming] WHERE [ModelProgId] = 'DW_CDim';
-- DELETE FROM [Utility].[ModuleProgramming] WHERE [ModuleId] = 4;


Declare @dateEnd nvarchar(12);
set @dateEnd = Convert(varchar(10),DATEADD(month, DATEDIFF(month, 0, GetDate()), 0)); /* SELECT DATEADD(month, DATEDIFF(month, 0, GetDate()), 0); SELECT DATEADD(D, -1, CONVERT(DATE, GetDate())); */
set @dateEnd = '2000-03-01';
EXECUTE [Utility].[spModuleProgramming_Reload] 0, '2000-01-01', @dateEnd, 'DW_DDemaP', 'DW_DFull', 0, 0;
GO

EXECUTE [Utility].[spModuleProgramming_Reload] 0, '2000-01-01', '2019-10-01', 'DW_DDemaP', 'DW_DFull', 0, 0;
GO

/* ====================================================================================
PROGRAMAR RECARGA DE TODAS LAS DIMENSIONES
==================================================================================== */
EXECUTE [Utility].[spModuleProgramming_Reload] 0, NULL, NULL, 'DW_DDim', 'DW_DFull', 0, 0;
GO

/* ====================================================================================
PROGRAMAR CREACION Y PROCESAMIENTO DE PARTICIONES
==================================================================================== */
/* Borrar todo para evitar informacion histórica */
TRUNCATE TABLE [Utility].[ModuleProgramming];
GO

/* Programar procesamiento de todas las dimensiones */
EXECUTE [Utility].[spModuleProgramming_Reload] 0, '2018-01-01', '2018-02-01', 'DW_CDim', 'DW_DFull', 1, 0;
GO

/* Programar todos los modelos */
EXECUTE [Utility].[spModuleProgramming_Reload] 0, '2017-01-01', '2018-01-01', 'DW_DFull', 'DW_DFull', 1, 0;
GO

/* Programar modelos especificos */
EXECUTE [Utility].[spModuleProgramming_Reload] 0, '2010-01-01', '2019-01-01', 'DW_DDemaP', 'DW_DFull', 1, 0;
GO

UPDATE [Utility].[CubePartitionDetail] SET [Create] = 1, [Update] = 1 WHERE [CubeId] = 'DemandaBI';
SELECT * FROM [Utility].[CubePartitionDetail];

/* ====================================================================================
PROGRAMAR CARGA DE TODO EL SISTEMA
==================================================================================== */
/* 1. '2000-01-01', '2000-02-01' */
TRUNCATE TABLE [Utility].[ModuleProgramming];
GO
EXECUTE [Utility].[spModuleProgramming_Reload] 0, '2000-01-01', '2000-02-01', 'DW_DDemaP', 'DW_DFull', 0, 0;
GO
Ejectuar job: JobDemandaBI_CargaDiaria


/* 2. Particiones para los cubos: '2000-01-01', '2001-01-01' */
TRUNCATE TABLE [Utility].[ModuleProgramming];
GO
EXECUTE [Utility].[spModuleProgramming_Reload] 0, '2000-01-01', '2001-01-01', 'DW_DFull', 'DW_DFull', 1, 0;
GO
Ejectuar job: JobDemandaBI_CargaDiaria

/* 3. '2000-02-01', '2001-01-01' */
TRUNCATE TABLE [Utility].[ModuleProgramming];
GO
EXECUTE [Utility].[spModuleProgramming_Reload] 0, '2000-02-01', '2001-01-01', 'DW_DDemaP', 'DW_DFull', 0, 0;
GO
Ejectuar job: JobDemandaBI_CargaDiaria

/* 4. '2001-01-01', '2003-01-01' */
TRUNCATE TABLE [Utility].[ModuleProgramming];
GO
EXECUTE [Utility].[spModuleProgramming_Reload] 0, '2001-01-01', '2003-01-01', 'DW_DDemaP', 'DW_DFull', 0, 0;
GO
Ejectuar job: JobDemandaBI_CargaDiaria

/* 5. '2003-01-01', '2005-01-01' */
TRUNCATE TABLE [Utility].[ModuleProgramming];
GO
EXECUTE [Utility].[spModuleProgramming_Reload] 0, '2003-01-01', '2005-01-01', 'DW_DDemaP', 'DW_DFull', 0, 0;
GO
Ejectuar job: JobDemandaBI_CargaDiaria

/* 6. '2005-01-01', '2008-01-01' */
TRUNCATE TABLE [Utility].[ModuleProgramming];
GO
EXECUTE [Utility].[spModuleProgramming_Reload] 0, '2005-01-01', '2008-01-01', 'DW_DDemaP', 'DW_DFull', 0, 0;
GO
Ejectuar job: JobDemandaBI_CargaDiaria

/* 7. '2008-01-01', '2012-01-01' */
TRUNCATE TABLE [Utility].[ModuleProgramming];
GO
EXECUTE [Utility].[spModuleProgramming_Reload] 0, '2008-01-01', '2012-01-01', 'DW_DDemaP', 'DW_DFull', 0, 0;
GO
Ejectuar job: JobDemandaBI_CargaDiaria

/* 8. '2012-01-01', '2016-01-01' */
TRUNCATE TABLE [Utility].[ModuleProgramming];
GO
EXECUTE [Utility].[spModuleProgramming_Reload] 0, '2012-01-01', '2016-01-01', 'DW_DDemaP', 'DW_DFull', 0, 0;
GO
Ejectuar job: JobDemandaBI_CargaDiaria

/* 9. '2016-01-01', '2019-10-01' */
TRUNCATE TABLE [Utility].[ModuleProgramming];
GO
EXECUTE [Utility].[spModuleProgramming_Reload] 0, '2016-01-01', '2019-10-01', 'DW_DDemaP', 'DW_DFull', 0, 0;
GO
Ejectuar job: JobDemandaBI_CargaDiaria

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - End script: Z03Test1.sql'
PRINT '------------------------------------------------------------------------'
GO
