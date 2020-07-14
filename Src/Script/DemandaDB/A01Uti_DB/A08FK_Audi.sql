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
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - Start script: A08FK_Audi.sql'
PRINT '------------------------------------------------------------------------'
GO

USE [$(DATABASE_NAME_DW)];

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Audit].[FK_Bitacora_BitacoraState_StateId]') AND parent_object_id = OBJECT_ID(N'[Audit].[Bitacora]'))
ALTER TABLE [Audit].[Bitacora]  WITH CHECK ADD  CONSTRAINT [FK_Bitacora_BitacoraState_StateId] FOREIGN KEY([StateId])
REFERENCES [Audit].[BitacoraState] ([StateId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Audit].[FK_Bitacora_BitacoraState_StateId]') AND parent_object_id = OBJECT_ID(N'[Audit].[Bitacora]'))
ALTER TABLE [Audit].[Bitacora] CHECK CONSTRAINT [FK_Bitacora_BitacoraState_StateId]
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Audit].[FK_BitacoraFile_Bitacora_BitacoraId]') AND parent_object_id = OBJECT_ID(N'[Audit].[BitacoraFile]'))
ALTER TABLE [Audit].[BitacoraFile]  WITH CHECK ADD  CONSTRAINT [FK_BitacoraFile_Bitacora_BitacoraId] FOREIGN KEY([BitacoraId])
REFERENCES [Audit].[Bitacora] ([BitacoraId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Audit].[FK_BitacoraFile_Bitacora_BitacoraId]') AND parent_object_id = OBJECT_ID(N'[Audit].[BitacoraFile]'))
ALTER TABLE [Audit].[BitacoraFile] CHECK CONSTRAINT [FK_BitacoraFile_Bitacora_BitacoraId]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Audit].[FK_BitacoraFile_BitacoraState_StateId]') AND parent_object_id = OBJECT_ID(N'[Audit].[BitacoraFile]'))
ALTER TABLE [Audit].[BitacoraFile]  WITH CHECK ADD  CONSTRAINT [FK_BitacoraFile_BitacoraState_StateId] FOREIGN KEY([StateId])
REFERENCES [Audit].[BitacoraState] ([StateId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Audit].[FK_BitacoraFile_BitacoraState_StateId]') AND parent_object_id = OBJECT_ID(N'[Audit].[BitacoraFile]'))
ALTER TABLE [Audit].[BitacoraFile] CHECK CONSTRAINT [FK_BitacoraFile_BitacoraState_StateId]
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Audit].[FK_BitacoraDetail_Bitacora_BitacoraId]') AND parent_object_id = OBJECT_ID(N'[Audit].[BitacoraDetail]'))
ALTER TABLE [Audit].[BitacoraDetail]  WITH CHECK ADD  CONSTRAINT [FK_BitacoraDetail_Bitacora_BitacoraId] FOREIGN KEY([BitacoraId])
REFERENCES [Audit].[Bitacora] ([BitacoraId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Audit].[FK_BitacoraDetail_Bitacora_BitacoraId]') AND parent_object_id = OBJECT_ID(N'[Audit].[BitacoraDetail]'))
ALTER TABLE [Audit].[BitacoraDetail] CHECK CONSTRAINT [FK_BitacoraDetail_Bitacora_BitacoraId]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Audit].[FK_BitacoraDetail_BitacoraState_StateId]') AND parent_object_id = OBJECT_ID(N'[Audit].[BitacoraDetail]'))
ALTER TABLE [Audit].[BitacoraDetail]  WITH CHECK ADD  CONSTRAINT [FK_BitacoraDetail_BitacoraState_StateId] FOREIGN KEY([StateId])
REFERENCES [Audit].[BitacoraState] ([StateId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Audit].[FK_BitacoraDetail_BitacoraState_StateId]') AND parent_object_id = OBJECT_ID(N'[Audit].[BitacoraDetail]'))
ALTER TABLE [Audit].[BitacoraDetail] CHECK CONSTRAINT [FK_BitacoraDetail_BitacoraState_StateId]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Audit].[FK_BitacoraDetail_BitacoraType_TypeId]') AND parent_object_id = OBJECT_ID(N'[Audit].[BitacoraDetail]'))
ALTER TABLE [Audit].[BitacoraDetail]  WITH CHECK ADD  CONSTRAINT [FK_BitacoraDetail_BitacoraType_TypeId] FOREIGN KEY([TypeId])
REFERENCES [Audit].[BitacoraType] ([TypeId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Audit].[FK_BitacoraDetail_BitacoraType_TypeId]') AND parent_object_id = OBJECT_ID(N'[Audit].[BitacoraDetail]'))
ALTER TABLE [Audit].[BitacoraDetail] CHECK CONSTRAINT [FK_BitacoraDetail_BitacoraType_TypeId]
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Audit].[FK_BitacoraStatistic_Bitacora_BitacoraId]') AND parent_object_id = OBJECT_ID(N'[Audit].[BitacoraStatistic]'))
ALTER TABLE [Audit].[BitacoraStatistic]  WITH CHECK ADD  CONSTRAINT [FK_BitacoraStatistic_Bitacora_BitacoraId] FOREIGN KEY([BitacoraId])
REFERENCES [Audit].[Bitacora] ([BitacoraId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Audit].[FK_BitacoraStatistic_Bitacora_BitacoraId]') AND parent_object_id = OBJECT_ID(N'[Audit].[BitacoraStatistic]'))
ALTER TABLE [Audit].[BitacoraStatistic] CHECK CONSTRAINT [FK_BitacoraStatistic_Bitacora_BitacoraId]
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Audit].[FK_BitacoraTable_Bitacora_BitacoraId]') AND parent_object_id = OBJECT_ID(N'[Audit].[BitacoraTable]'))
ALTER TABLE [Audit].[BitacoraTable]  WITH CHECK ADD  CONSTRAINT [FK_BitacoraTable_Bitacora_BitacoraId] FOREIGN KEY([BitacoraId])
REFERENCES [Audit].[Bitacora] ([BitacoraId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Audit].[FK_BitacoraTable_Bitacora_BitacoraId]') AND parent_object_id = OBJECT_ID(N'[Audit].[BitacoraTable]'))
ALTER TABLE [Audit].[BitacoraTable] CHECK CONSTRAINT [FK_BitacoraTable_Bitacora_BitacoraId]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Audit].[FK_BitacoraTable_BitacoraState_StateId]') AND parent_object_id = OBJECT_ID(N'[Audit].[BitacoraTable]'))
ALTER TABLE [Audit].[BitacoraTable]  WITH CHECK ADD  CONSTRAINT [FK_BitacoraTable_BitacoraState_StateId] FOREIGN KEY([StateId])
REFERENCES [Audit].[BitacoraState] ([StateId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Audit].[FK_BitacoraTable_BitacoraState_StateId]') AND parent_object_id = OBJECT_ID(N'[Audit].[BitacoraTable]'))
ALTER TABLE [Audit].[BitacoraTable] CHECK CONSTRAINT [FK_BitacoraTable_BitacoraState_StateId]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Audit].[FK_BitacoraTable_BitacoraType_TypeId]') AND parent_object_id = OBJECT_ID(N'[Audit].[BitacoraTable]'))
ALTER TABLE [Audit].[BitacoraTable]  WITH CHECK ADD  CONSTRAINT [FK_BitacoraTable_BitacoraType_TypeId] FOREIGN KEY([TypeId])
REFERENCES [Audit].[BitacoraType] ([TypeId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Audit].[FK_BitacoraTable_BitacoraType_TypeId]') AND parent_object_id = OBJECT_ID(N'[Audit].[BitacoraTable]'))
ALTER TABLE [Audit].[BitacoraTable] CHECK CONSTRAINT [FK_BitacoraTable_BitacoraType_TypeId]
GO

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - End script: A08FK_Audi.sql'
PRINT '------------------------------------------------------------------------'
GO
