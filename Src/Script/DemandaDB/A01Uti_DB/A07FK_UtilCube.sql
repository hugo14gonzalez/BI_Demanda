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
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - Start script: A07FK_UtilCube.sql'
PRINT '------------------------------------------------------------------------'
GO

USE [$(DATABASE_NAME_DW)];

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Utility].[FK_CubePartition_CubeSystem_CubeId]') AND parent_object_id = OBJECT_ID(N'[Utility].[CubePartition]'))
ALTER TABLE [Utility].[CubePartition]  WITH CHECK ADD  CONSTRAINT [FK_CubePartition_CubeSystem_CubeId] FOREIGN KEY([CubeId])
REFERENCES [Utility].[CubeSystem] ([CubeId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Utility].[FK_CubePartition_CubeSystem_CubeId]') AND parent_object_id = OBJECT_ID(N'[Utility].[CubePartition]'))
ALTER TABLE [Utility].[CubePartition] CHECK CONSTRAINT [FK_CubePartition_CubeSystem_CubeId]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Utility].[FK_CubePartition_ModelSystem_ModelId]') AND parent_object_id = OBJECT_ID(N'[Utility].[CubePartition]'))
ALTER TABLE [Utility].[CubePartition]  WITH CHECK ADD  CONSTRAINT [FK_CubePartition_ModelSystem_ModelId] FOREIGN KEY([ModelId])
REFERENCES [Utility].[ModelSystem] ([ModelId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Utility].[FK_CubePartition_ModelSystem_ModelId]') AND parent_object_id = OBJECT_ID(N'[Utility].[CubePartition]'))
ALTER TABLE [Utility].[CubePartition] CHECK CONSTRAINT [FK_CubePartition_ModelSystem_ModelId]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Utility].[FK_CubePartition_QuerySQL_QueryId]') AND parent_object_id = OBJECT_ID(N'[Utility].[CubePartition]'))
ALTER TABLE [Utility].[CubePartition]  WITH CHECK ADD  CONSTRAINT [FK_CubePartition_QuerySQL_QueryId] FOREIGN KEY([QueryId])
REFERENCES [Utility].[QuerySQL] ([QueryId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Utility].[FK_CubePartition_QuerySQL_QueryId]') AND parent_object_id = OBJECT_ID(N'[Utility].[CubePartition]'))
ALTER TABLE [Utility].[CubePartition] CHECK CONSTRAINT [FK_CubePartition_QuerySQL_QueryId]
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Utility].[FK_CubePartitionDetail_CubePartition_1]') AND parent_object_id = OBJECT_ID(N'[Utility].[CubePartitionDetail]'))
ALTER TABLE [Utility].[CubePartitionDetail]  WITH CHECK ADD  CONSTRAINT [FK_CubePartitionDetail_CubePartition_1] FOREIGN KEY([CubeId], [ModelId])
REFERENCES [Utility].[CubePartition] ([CubeId], [ModelId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Utility].[FK_CubePartitionDetail_CubePartition_1]') AND parent_object_id = OBJECT_ID(N'[Utility].[CubePartitionDetail]'))
ALTER TABLE [Utility].[CubePartitionDetail] CHECK CONSTRAINT [FK_CubePartitionDetail_CubePartition_1]
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Utility].[FK_MetricSystem_ModelSystem_ModelId]') AND parent_object_id = OBJECT_ID(N'[Utility].[MetricSystem]'))
ALTER TABLE [Utility].[MetricSystem]  WITH CHECK ADD  CONSTRAINT [FK_MetricSystem_ModelSystem_ModelId] FOREIGN KEY([ModelId])
REFERENCES [Utility].[ModelSystem] ([ModelId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Utility].[FK_MetricSystem_ModelSystem_ModelId]') AND parent_object_id = OBJECT_ID(N'[Utility].[MetricSystem]'))
ALTER TABLE [Utility].[MetricSystem] CHECK CONSTRAINT [FK_MetricSystem_ModelSystem_ModelId]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Utility].[FK_MetricSystem_QuerySQL_QueryId]') AND parent_object_id = OBJECT_ID(N'[Utility].[MetricSystem]'))
ALTER TABLE [Utility].[MetricSystem]  WITH CHECK ADD  CONSTRAINT [FK_MetricSystem_QuerySQL_QueryId] FOREIGN KEY([QueryId])
REFERENCES [Utility].[QuerySQL] ([QueryId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Utility].[FK_MetricSystem_QuerySQL_QueryId]') AND parent_object_id = OBJECT_ID(N'[Utility].[MetricSystem]'))
ALTER TABLE [Utility].[MetricSystem] CHECK CONSTRAINT [FK_MetricSystem_QuerySQL_QueryId]
GO

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - End script: A07FK_UtilCube.sql'
PRINT '------------------------------------------------------------------------'
GO
