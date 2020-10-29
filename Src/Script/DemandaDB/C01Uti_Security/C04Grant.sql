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
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - Start script: C04Grant.sql'
PRINT '------------------------------------------------------------------------'
GO

USE [$(DATABASE_NAME_DW)];
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sysssislog]'))
 GRANT SELECT, REFERENCES, INSERT, UPDATE, DELETE ON [dbo].[sysssislog] TO [R_DemandaDW];
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_ssis_addlogentry]') AND type in (N'P', N'PC'))
 GRANT EXECUTE, REFERENCES ON [dbo].[sp_ssis_addlogentry] TO [R_DemandaDW];
GO

GRANT INSERT, SELECT, UPDATE, DELETE, REFERENCES ON [Audit].[Bitacora] TO [R_DemandaDW];
GRANT INSERT, SELECT, UPDATE, DELETE, REFERENCES ON [Audit].[BitacoraDetail] TO [R_DemandaDW];
GRANT INSERT, SELECT, UPDATE, DELETE, REFERENCES ON [Audit].[BitacoraFile] TO [R_DemandaDW];
GRANT INSERT, SELECT, UPDATE, DELETE, REFERENCES ON [Audit].[BitacoraState] TO [R_DemandaDW];
GRANT INSERT, SELECT, UPDATE, DELETE, REFERENCES ON [Audit].[BitacoraStatistic] TO [R_DemandaDW];
GRANT INSERT, SELECT, UPDATE, DELETE, REFERENCES ON [Audit].[BitacoraTable] TO [R_DemandaDW];
GRANT INSERT, SELECT, UPDATE, DELETE, REFERENCES ON [Audit].[BitacoraType] TO [R_DemandaDW];
GRANT INSERT, SELECT, UPDATE, DELETE, REFERENCES ON [Utility].[ChangeDateForDim] TO [R_DemandaDW];
GRANT INSERT, SELECT, UPDATE, DELETE, REFERENCES ON [Utility].[CubePartition] TO [R_DemandaDW];
GRANT INSERT, SELECT, UPDATE, DELETE, REFERENCES ON [Utility].[CubePartitionDetail] TO [R_DemandaDW];
GRANT INSERT, SELECT, UPDATE, DELETE, REFERENCES ON [Utility].[CubeSystem] TO [R_DemandaDW];
GRANT INSERT, SELECT, UPDATE, DELETE, REFERENCES ON [Utility].[MetricSystem] TO [R_DemandaDW];
GRANT INSERT, SELECT, UPDATE, DELETE, REFERENCES ON [Utility].[ModelLoad] TO [R_DemandaDW];
GRANT INSERT, SELECT, UPDATE, DELETE, REFERENCES ON [Utility].[ModelParameter] TO [R_DemandaDW];
GRANT INSERT, SELECT, UPDATE, DELETE, REFERENCES ON [Utility].[ModelSchedule] TO [R_DemandaDW];
GRANT INSERT, SELECT, UPDATE, DELETE, REFERENCES ON [Utility].[ModelSystem] TO [R_DemandaDW];
GRANT INSERT, SELECT, UPDATE, DELETE, REFERENCES ON [Utility].[ModelVersion] TO [R_DemandaDW];
GRANT INSERT, SELECT, UPDATE, DELETE, REFERENCES ON [Utility].[ModuleModel] TO [R_DemandaDW];
GRANT INSERT, SELECT, UPDATE, DELETE, REFERENCES ON [Utility].[ModuleProgramming] TO [R_DemandaDW];
GRANT INSERT, SELECT, UPDATE, DELETE, REFERENCES ON [Utility].[ModuleSystem] TO [R_DemandaDW];
GRANT INSERT, SELECT, UPDATE, DELETE, REFERENCES ON [Utility].[ParameterKeyValue] TO [R_DemandaDW];
GRANT INSERT, SELECT, UPDATE, DELETE, REFERENCES ON [Utility].[QuerySQL] TO [R_DemandaDW];
GRANT INSERT, SELECT, UPDATE, DELETE, REFERENCES ON [Utility].[ScheduleSystem] TO [R_DemandaDW];
GRANT INSERT, SELECT, UPDATE, DELETE, REFERENCES ON [Utility].[SpecialDate] TO [R_DemandaDW];
GRANT INSERT, SELECT, UPDATE, DELETE, REFERENCES ON [Utility].[Subscription] TO [R_DemandaDW];
GRANT INSERT, SELECT, UPDATE, DELETE, REFERENCES ON [Utility].[UserAgent] TO [R_DemandaDW];
GRANT INSERT, SELECT, UPDATE, DELETE, REFERENCES ON [Utility].[UserDomain] TO [R_DemandaDW];

GRANT EXECUTE, REFERENCES ON [Audit].[spBitacora_Cancel] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Audit].[spBitacora_End] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Audit].[spBitacora_Error] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Audit].[spBitacora_Start] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Audit].[spBitacoraDetail_Insert] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Audit].[spBitacoraFile_Cancel] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Audit].[spBitacoraFile_End] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Audit].[spBitacoraFile_Error] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Audit].[spBitacoraFile_GetFileId] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Audit].[spBitacoraFile_IsErrorCanceled] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Audit].[spBitacoraFile_Start] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Audit].[spBitacoraFile_Validate] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Audit].[spBitacoraStatistic_End] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Audit].[spBitacoraStatistic_Start] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Audit].[spBitacoraTable_Insert] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[PrintLongText] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[spGetQuerySQL] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[spLoadModelVersion] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[spModuleProgramming_End] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[spModuleProgramming_Query] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[spModuleProgramming_Reload] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[spModuleProgramming_Reload_Query] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[spModuleProgramming_Sheduling] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[spModuleProgramming_UpdateState] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[spModuleProgramming_UpdateState_WithoutDate] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[spOLAP_GetCatalogs] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[spOLAP_GetCubes] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[spOLAP_GetDimensions] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[spOLAP_GetDimensionsAttributes] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[spOLAP_GetHierarchies] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[spOLAP_GetHierarchiesAttributes] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[spOLAP_GetKPI] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[spOLAP_GetMeasureGroups] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[spOLAP_GetMeasureGroupsDimensions] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[spOLAP_GetMeasureGroupsDimensionsSpaceDiagram] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[spOLAP_GetMeasures] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[spOLAP_GetMiningModel] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[spOLAP_GetMiningModelColumns] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[spOLAP_GetMiningStructureColumns] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[spOLAP_GetMiningStructures] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[spOLAP_GetPerspectives] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[spOLAP_GetSearchObject] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[spOLAP_PartitionDefine] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[spOLAP_QueryPartition] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[spOLAP_QueryProgramming] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[spOLAP_ScriptXMLAParttition] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[spOLAP_UpdatePartitionToCreated] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[spOLAP_UpdatePartitionToProsessed] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[spSubscription] TO [R_DemandaDW];

GRANT EXECUTE, REFERENCES ON [Audit].[GetBitacoraRoot] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[ConvertUTF8Ansi] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[ConvertUTF8String] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[DateAddPeriod] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[DateCountBusinessDays] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[DateFormat] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[fnString_AddPad] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[GetDataPart_Period] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[GetDateBusinessDays] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[GetDateDiff] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[GetDateDiffToString] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[GetDateDiffValue] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[GetDateDiffValue2] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[GetDaysInMonth] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[GetDurationBetweenDates] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[GetEndOfDatePart] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[GetEndOfDay] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[GetEndOfHalf] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[GetEndOfMonth] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[GetEndOfMonth2] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[GetEndOfQuarter] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[GetEndOftWeek] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[GetEndOfYear] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[GetErrorCurrentToString] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[GetHalf] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[GetMonth2] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[GetQuarter] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[GetSchedule_NextExecution] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[GetSchedule_NextExecutionDay] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[GetSchedule_NextExecutionMoth] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[GetSchedule_NextExecutionWeek] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[GetStartOfDatePart] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[GetStartOfDay] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[GetStartOfHalf] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[GetStartOfMonth] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[GetStartOfMonth2] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[GetStartOfQuarter] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[GetStartOfWeek] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[GetStartOfYear] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Utility].[GetTimeStartEnd] TO [R_DemandaDW];

GRANT SELECT, REFERENCES ON [Audit].[GetBitacoraDetailTree] TO [R_DemandaDW];
GRANT SELECT, REFERENCES ON [Audit].[GetBitacoraDetailTree_ByDate] TO [R_DemandaDW];
GRANT SELECT, REFERENCES ON [Audit].[GetBitacoraFileTree] TO [R_DemandaDW];
GRANT SELECT, REFERENCES ON [Audit].[GetBitacoraFileTree_ByDate] TO [R_DemandaDW];
GRANT SELECT, REFERENCES ON [Audit].[GetBitacoraStatisticTree] TO [R_DemandaDW];
GRANT SELECT, REFERENCES ON [Audit].[GetBitacoraStatisticTree_ByDate] TO [R_DemandaDW];
GRANT SELECT, REFERENCES ON [Audit].[GetBitacoraTableTree] TO [R_DemandaDW];
GRANT SELECT, REFERENCES ON [Audit].[GetBitacoraTableTree_ByDate] TO [R_DemandaDW];
GRANT SELECT, REFERENCES ON [Audit].[GetBitacoraTree] TO [R_DemandaDW];
GRANT SELECT, REFERENCES ON [Audit].[GetBitacoraTree_ByDate] TO [R_DemandaDW];
GRANT SELECT, REFERENCES ON [Utility].[fnString_Split] TO [R_DemandaDW];
GRANT SELECT, REFERENCES ON [Utility].[GetDateAge] TO [R_DemandaDW];
GRANT SELECT, REFERENCES ON [Utility].[GetDateParts] TO [R_DemandaDW];
GRANT SELECT, REFERENCES ON [Utility].[GetDateSequence] TO [R_DemandaDW];
GRANT SELECT, REFERENCES ON [Utility].[GetParameters_SPFunction] TO [R_DemandaDW];
GRANT SELECT, REFERENCES ON [Utility].[GetParametersModuleProgramming] TO [R_DemandaDW];
GRANT SELECT, REFERENCES ON [Utility].[GetPeriod] TO [R_DemandaDW];
GRANT SELECT, REFERENCES ON [Utility].[GetTimeHourParts] TO [R_DemandaDW];
GRANT SELECT, REFERENCES ON [Utility].[GetTimeParts] TO [R_DemandaDW];
GO

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - End script: C04Grant.sql'
PRINT '------------------------------------------------------------------------'
GO