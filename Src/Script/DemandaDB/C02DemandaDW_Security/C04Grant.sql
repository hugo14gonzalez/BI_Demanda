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
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - Start script: C04Grant.sql'
PRINT '------------------------------------------------------------------------'
GO

USE [msdb];
GRANT SELECT ON [dbo].[sysjobs] TO [R_DemandaDW];
GRANT SELECT ON [dbo].[sysjobactivity] TO [R_DemandaDW];
GRANT SELECT ON [dbo].[sysjobhistory] TO [R_DemandaDW];
GRANT SELECT ON [dbo].[sysjobs_view] TO [R_DemandaDW];
GRANT EXECUTE ON [dbo].[sp_start_job] TO [R_DemandaDW];
GRANT EXECUTE ON [dbo].[sp_stop_job] TO [R_DemandaDW];
GO

USE [$(DATABASE_NAME_DW)];

GRANT INSERT, SELECT, UPDATE, DELETE, REFERENCES ON [DW].[DimAgente] TO [R_DemandaDW];
GRANT INSERT, SELECT, UPDATE, DELETE, REFERENCES ON [DW].[DimCompania] TO [R_DemandaDW];
GRANT INSERT, SELECT, UPDATE, DELETE, REFERENCES ON [DW].[DimFecha] TO [R_DemandaDW];
GRANT INSERT, SELECT, UPDATE, DELETE, REFERENCES ON [DW].[DimGeografia] TO [R_DemandaDW];
GRANT INSERT, SELECT, UPDATE, DELETE, REFERENCES ON [DW].[DimMercado] TO [R_DemandaDW];
GRANT INSERT, SELECT, UPDATE, DELETE, REFERENCES ON [DW].[DimPeriodo] TO [R_DemandaDW];
GRANT INSERT, SELECT, UPDATE, DELETE, REFERENCES ON [DW].[FactDemandaPerdida] TO [R_DemandaDW];
GRANT INSERT, SELECT, UPDATE, DELETE, REFERENCES ON [Staging].[TmpDimAgente] TO [R_DemandaDW];
GRANT INSERT, SELECT, UPDATE, DELETE, REFERENCES ON [Staging].[TmpDimCompania] TO [R_DemandaDW];
GRANT INSERT, SELECT, UPDATE, DELETE, REFERENCES ON [Staging].[TmpDimGeografia] TO [R_DemandaDW];
GRANT INSERT, SELECT, UPDATE, DELETE, REFERENCES ON [Staging].[TmpFactDemandaPerdida] TO [R_DemandaDW];
GRANT INSERT, SELECT, UPDATE, DELETE, REFERENCES ON [Staging].[TmpModelVersion] TO [R_DemandaDW];
GRANT INSERT, SELECT, UPDATE, DELETE, REFERENCES ON [Staging].[TruncateList] TO [R_DemandaDW];

GRANT INSERT, SELECT, UPDATE, DELETE, REFERENCES ON [DW].[vFactDemandaPerdida] TO [R_DemandaDW];

GRANT EXECUTE, REFERENCES ON [DW].[spInferDimAgente] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [DW].[spInferDimCompania] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [DW].[spInferDimGeografia] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [DW].[spLoadDimAgente] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [DW].[spLoadDimCompania] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [DW].[spLoadDimDate] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [DW].[spLoadDimDateNext] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [DW].[spLoadDimGeografia] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [DW].[spLoadDimPeriod] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [DW].[spLoadFactDemandaPerdida] TO [R_DemandaDW];
GRANT EXECUTE, REFERENCES ON [Staging].[spTruncateTable] TO [R_DemandaDW];

GO

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - End script: C04Grant.sql'
PRINT '------------------------------------------------------------------------'
GO