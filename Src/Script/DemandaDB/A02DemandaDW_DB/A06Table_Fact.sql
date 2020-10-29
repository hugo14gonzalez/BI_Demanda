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
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - Start script: A06Table_Fact.sql'
PRINT '------------------------------------------------------------------------'
GO

USE [$(DATABASE_NAME_DW)];

/* ========================================================================== 
FACT
========================================================================== */
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DW].[FactDemandaPerdida]') AND type in (N'U'))
BEGIN
CREATE TABLE [DW].[FactDemandaPerdida](
	[FechaSKId] [int] NOT NULL,
	[PeriodoSKId] [smallint] NOT NULL,
	[AgenteMemDisSKId] [int] NOT NULL,	
	[MercadoSKId] [smallint] NOT NULL,
	[GeografiaSKId] [int] NOT NULL,
	[DemandaReal] [numeric](24, 10) NULL,
	[PerdidaEnergia] [numeric](24, 10) NULL,
	[BitacoraId] [bigint] NULL,
) 
ON [psFactDemandaPerdida_dat] ([FechaSKId])
WITH (DATA_COMPRESSION = PAGE);
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[DW].[FactDemandaPerdida]') AND name = N'CX_FactDemandaPerdida')
CREATE CLUSTERED COLUMNSTORE INDEX [CX_FactDemandaPerdida] ON [DW].[FactDemandaPerdida]
WITH (DATA_COMPRESSION = COLUMNSTORE)
ON [psFactDemandaPerdida_dat] ([FechaSKId]);
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[DW].[FactDemandaPerdida]') AND name = N'PK_FactDemandaPerdida')
ALTER TABLE [DW].[FactDemandaPerdida] ADD  CONSTRAINT [PK_FactDemandaPerdida] PRIMARY KEY NONCLUSTERED 
(
	[FechaSKId] ASC,
	[PeriodoSKId] ASC,
	[AgenteMemDisSKId] ASC,
	[MercadoSKId] ASC,
	[GeografiaSKId] ASC
)
WITH (DATA_COMPRESSION = PAGE)
ON [psFactDemandaPerdida_ind] ([FechaSKId]);
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'FactDemandaPerdida', N'COLUMN',N'FechaSKId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'FactDemandaPerdida', @level2type=N'COLUMN',@level2name=N'FechaSKId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'FactDemandaPerdida', N'COLUMN',N'PeriodoSKId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Periodo.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'FactDemandaPerdida', @level2type=N'COLUMN',@level2name=N'PeriodoSKId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'FactDemandaPerdida', N'COLUMN',N'AgenteMemDisSKId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo SK del agente MEM distribuidor.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'FactDemandaPerdida', @level2type=N'COLUMN',@level2name=N'AgenteMemDisSKId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'FactDemandaPerdida', N'COLUMN',N'MercadoSKId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo SK de mercado.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'FactDemandaPerdida', @level2type=N'COLUMN',@level2name=N'MercadoSKId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'FactDemandaPerdida', N'COLUMN',N'GeografiaSKId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo SK de geografia.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'FactDemandaPerdida', @level2type=N'COLUMN',@level2name=N'GeografiaSKId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'FactDemandaPerdida', N'COLUMN',N'DemandaReal'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Valor demanda de energia real en kWh.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'FactDemandaPerdida', @level2type=N'COLUMN',@level2name=N'DemandaReal'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'FactDemandaPerdida', N'COLUMN',N'PerdidaEnergia'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Valor perdidas de energia en kWh.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'FactDemandaPerdida', @level2type=N'COLUMN',@level2name=N'PerdidaEnergia'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'FactDemandaPerdida', N'COLUMN',N'BitacoraId'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de bitacora de proceso.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'FactDemandaPerdida', @level2type=N'COLUMN',@level2name=N'BitacoraId'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'DW', N'TABLE',N'FactDemandaPerdida', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Almacena datos trasaccionales de demandas y perdidas de energia.' , @level0type=N'SCHEMA',@level0name=N'DW', @level1type=N'TABLE',@level1name=N'FactDemandaPerdida'
GO

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - End script: A06Table_Fact.sql'
PRINT '------------------------------------------------------------------------'
GO