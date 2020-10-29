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
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - Start script: A08FK_DW.sql'
PRINT '------------------------------------------------------------------------'
GO

USE [$(DATABASE_NAME_DW)];
GO

/* ====================================================================================
 TABLAS DE DIMENSIONES
==================================================================================== */
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[DW].[FK_DimAgente_DimCompania_CompaniaSKId]') AND parent_object_id = OBJECT_ID(N'[DW].[DimAgente]'))
ALTER TABLE [DW].[DimAgente]  WITH CHECK ADD  CONSTRAINT [FK_DimAgente_DimCompania_CompaniaSKId] FOREIGN KEY([CompaniaSKId])
REFERENCES [DW].[DimCompania] ([CompaniaSKId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[DW].[FK_DimAgente_DimCompania_CompaniaSKId]') AND parent_object_id = OBJECT_ID(N'[DW].[DimAgente]'))
ALTER TABLE [DW].[DimAgente] CHECK CONSTRAINT [FK_DimAgente_DimCompania_CompaniaSKId]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[DW].[FK_DimAgente_DimFecha_FechaIniSKId]') AND parent_object_id = OBJECT_ID(N'[DW].[DimAgente]'))
ALTER TABLE [DW].[DimAgente]  WITH CHECK ADD  CONSTRAINT [FK_DimAgente_DimFecha_FechaIniSKId] FOREIGN KEY([FechaIniSKId])
REFERENCES [DW].[DimFecha] ([FechaSKId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[DW].[FK_DimAgente_DimFecha_FechaIniSKId]') AND parent_object_id = OBJECT_ID(N'[DW].[DimAgente]'))
ALTER TABLE [DW].[DimAgente] CHECK CONSTRAINT [FK_DimAgente_DimFecha_FechaIniSKId]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[DW].[FK_DimAgente_DimFecha_FechaFinSKId]') AND parent_object_id = OBJECT_ID(N'[DW].[DimAgente]'))
ALTER TABLE [DW].[DimAgente]  WITH CHECK ADD  CONSTRAINT [FK_DimAgente_DimFecha_FechaFinSKId] FOREIGN KEY([FechaFinSKId])
REFERENCES [DW].[DimFecha] ([FechaSKId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[DW].[FK_DimAgente_DimFecha_FechaFinSKId]') AND parent_object_id = OBJECT_ID(N'[DW].[DimAgente]'))
ALTER TABLE [DW].[DimAgente] CHECK CONSTRAINT [FK_DimAgente_DimFecha_FechaFinSKId]
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[DW].[FK_DimCompania_DimFecha_FechaIniSKId]') AND parent_object_id = OBJECT_ID(N'[DW].[DimCompania]'))
ALTER TABLE [DW].[DimCompania]  WITH CHECK ADD  CONSTRAINT [FK_DimCompania_DimFecha_FechaIniSKId] FOREIGN KEY([FechaIniSKId])
REFERENCES [DW].[DimFecha] ([FechaSKId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[DW].[FK_DimCompania_DimFecha_FechaIniSKId]') AND parent_object_id = OBJECT_ID(N'[DW].[DimCompania]'))
ALTER TABLE [DW].[DimCompania] CHECK CONSTRAINT [FK_DimCompania_DimFecha_FechaIniSKId]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[DW].[FK_DimCompania_DimFecha_FechaFinSKId]') AND parent_object_id = OBJECT_ID(N'[DW].[DimCompania]'))
ALTER TABLE [DW].[DimCompania]  WITH CHECK ADD  CONSTRAINT [FK_DimCompania_DimFecha_FechaFinSKId] FOREIGN KEY([FechaFinSKId])
REFERENCES [DW].[DimFecha] ([FechaSKId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[DW].[FK_DimCompania_DimFecha_FechaFinSKId]') AND parent_object_id = OBJECT_ID(N'[DW].[DimCompania]'))
ALTER TABLE [DW].[DimCompania] CHECK CONSTRAINT [FK_DimCompania_DimFecha_FechaFinSKId]
GO

/* ====================================================================================
 TABLAS FACT
==================================================================================== */
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[DW].[FK_FactDemandaPerdida_DimFecha_FechaSKId]') AND parent_object_id = OBJECT_ID(N'[DW].[FactDemandaPerdida]'))
ALTER TABLE [DW].[FactDemandaPerdida]  WITH CHECK ADD  CONSTRAINT [FK_FactDemandaPerdida_DimFecha_FechaSKId] FOREIGN KEY([FechaSKId])
REFERENCES [DW].[DimFecha] ([FechaSKId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[DW].[FK_FactDemandaPerdida_DimFecha_FechaSKId]') AND parent_object_id = OBJECT_ID(N'[DW].[FactDemandaPerdida]'))
ALTER TABLE [DW].[FactDemandaPerdida] CHECK CONSTRAINT [FK_FactDemandaPerdida_DimFecha_FechaSKId]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[DW].[FK_FactDemandaPerdida_DimPeriodo_PeriodoSKId]') AND parent_object_id = OBJECT_ID(N'[DW].[FactDemandaPerdida]'))
ALTER TABLE [DW].[FactDemandaPerdida]  WITH CHECK ADD  CONSTRAINT [FK_FactDemandaPerdida_DimPeriodo_PeriodoSKId] FOREIGN KEY([PeriodoSKId])
REFERENCES [DW].[DimPeriodo] ([PeriodoSKId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[DW].[FK_FactDemandaPerdida_DimPeriodo_PeriodoSKId]') AND parent_object_id = OBJECT_ID(N'[DW].[FactDemandaPerdida]'))
ALTER TABLE [DW].[FactDemandaPerdida] CHECK CONSTRAINT [FK_FactDemandaPerdida_DimPeriodo_PeriodoSKId]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[DW].[FK_FactDemandaPerdida_DimMercado_MercadoSKId]') AND parent_object_id = OBJECT_ID(N'[DW].[FactDemandaPerdida]'))
ALTER TABLE [DW].[FactDemandaPerdida]  WITH CHECK ADD  CONSTRAINT [FK_FactDemandaPerdida_DimMercado_MercadoSKId] FOREIGN KEY([MercadoSKId])
REFERENCES [DW].[DimMercado] ([MercadoSKId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[DW].[FK_FactDemandaPerdida_DimMercado_MercadoSKId]') AND parent_object_id = OBJECT_ID(N'[DW].[FactDemandaPerdida]'))
ALTER TABLE [DW].[FactDemandaPerdida] CHECK CONSTRAINT [FK_FactDemandaPerdida_DimMercado_MercadoSKId]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[DW].[FK_FactDemandaPerdida_DimAgente_AgenteMemDisSKId]') AND parent_object_id = OBJECT_ID(N'[DW].[FactDemandaPerdida]'))
ALTER TABLE [DW].[FactDemandaPerdida]  WITH CHECK ADD  CONSTRAINT [FK_FactDemandaPerdida_DimAgente_AgenteMemDisSKId] FOREIGN KEY([AgenteMemDisSKId])
REFERENCES [DW].[DimAgente] ([AgenteSKId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[DW].[FK_FactDemandaPerdida_DimAgente_AgenteMemDisSKId]') AND parent_object_id = OBJECT_ID(N'[DW].[FactDemandaPerdida]'))
ALTER TABLE [DW].[FactDemandaPerdida] CHECK CONSTRAINT [FK_FactDemandaPerdida_DimAgente_AgenteMemDisSKId]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[DW].[FK_FactDemandaPerdida_DimGeografia_GeografiaSKId]') AND parent_object_id = OBJECT_ID(N'[DW].[FactDemandaPerdida]'))
ALTER TABLE [DW].[FactDemandaPerdida]  WITH CHECK ADD  CONSTRAINT [FK_FactDemandaPerdida_DimGeografia_GeografiaSKId] FOREIGN KEY([GeografiaSKId])
REFERENCES [DW].[DimGeografia] ([GeografiaSKId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[DW].[FK_FactDemandaPerdida_DimGeografia_GeografiaSKId]') AND parent_object_id = OBJECT_ID(N'[DW].[FactDemandaPerdida]'))
ALTER TABLE [DW].[FactDemandaPerdida] CHECK CONSTRAINT [FK_FactDemandaPerdida_DimGeografia_GeografiaSKId]
GO

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - End script: A08FK_DW.sql'
PRINT '------------------------------------------------------------------------'
GO
