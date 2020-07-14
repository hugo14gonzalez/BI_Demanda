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
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - Start script: A09View.sql'
PRINT '------------------------------------------------------------------------'
GO

/*
SELECT * FROM [DW].[vFactDemandaPerdida];
*/

USE [$(DATABASE_NAME_DW)];

IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[DW].[vFactDemandaPerdida]'))
 EXEC dbo.sp_executesql @statement = N'CREATE VIEW [DW].[vFactDemandaPerdida] WITH SCHEMABINDING AS SELECT [FechaSKId] FROM [DW].[FactDemandaPerdida];'
GO
ALTER VIEW [DW].[vFactDemandaPerdida]
WITH SCHEMABINDING
As
SELECT [FechaSKId],[PeriodoSKId],[AgenteMemDisSKId],[MercadoSKId],[GeografiaSKId],[DemandaReal],[PerdidaEnergia]
,CONCAT([FechaSKId], '_', [PeriodoSKId], '_', [AgenteMemDisSKId], '_', [MercadoSKId], '_', [GeografiaSKId]) As [DemandaDesc]
FROM [DW].[FactDemandaPerdida];
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'VIEW',N'vFactDemandaPerdida', N'COLUMN',N'FechaSKId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'VIEW',@level1name=N'vFactDemandaPerdida', @level2type=N'COLUMN',@level2name=N'FechaSKId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'VIEW',N'vFactDemandaPerdida', N'COLUMN',N'PeriodoSKId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Periodo.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'VIEW',@level1name=N'vFactDemandaPerdida', @level2type=N'COLUMN',@level2name=N'PeriodoSKId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'VIEW',N'vFactDemandaPerdida', N'COLUMN',N'AgenteMemDisSKId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo SK del agente MEM distribuidor.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'VIEW',@level1name=N'vFactDemandaPerdida', @level2type=N'COLUMN',@level2name=N'AgenteMemDisSKId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'VIEW',N'vFactDemandaPerdida', N'COLUMN',N'MercadoSKId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo SK de mercado.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'VIEW',@level1name=N'vFactDemandaPerdida', @level2type=N'COLUMN',@level2name=N'MercadoSKId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'VIEW',N'vFactDemandaPerdida', N'COLUMN',N'GeografiaSKId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo SK de geografia.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'VIEW',@level1name=N'vFactDemandaPerdida', @level2type=N'COLUMN',@level2name=N'GeografiaSKId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'VIEW',N'vFactDemandaPerdida', N'COLUMN',N'DemandaReal'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Valor demanda de energia real en kWh.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'VIEW',@level1name=N'vFactDemandaPerdida', @level2type=N'COLUMN',@level2name=N'DemandaReal'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'VIEW',N'vFactDemandaPerdida', N'COLUMN',N'PerdidaEnergia'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Valor perdidas de energia en kWh.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'VIEW',@level1name=N'vFactDemandaPerdida', @level2type=N'COLUMN',@level2name=N'PerdidaEnergia'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'VIEW',N'vFactDemandaPerdida', N'COLUMN',N'DemandaDesc'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Descripcion formada al concatenar los campos PK.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'VIEW',@level1name=N'vFactDemandaPerdida', @level2type=N'COLUMN',@level2name=N'DemandaDesc'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'VIEW',N'vFactDemandaPerdida', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Vista FactDemandaPerdida. Datos trasaccionales de demandas y perdidas de energia.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'VIEW',@level1name=N'vFactDemandaPerdida'
GO

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - End script: A09View.sql'
PRINT '------------------------------------------------------------------------'
GO
