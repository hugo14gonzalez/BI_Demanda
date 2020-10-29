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
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - Start script: A06FK_Util.sql'
PRINT '------------------------------------------------------------------------'
GO

USE [$(DATABASE_NAME_DW)];

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Utility].[FK_ModelLoad_ModelSystem_ModelId]') AND parent_object_id = OBJECT_ID(N'[Utility].[ModelLoad]'))
ALTER TABLE [Utility].[ModelLoad]  WITH CHECK ADD  CONSTRAINT [FK_ModelLoad_ModelSystem_ModelId] FOREIGN KEY([ModelId])
REFERENCES [Utility].[ModelSystem] ([ModelId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Utility].[FK_ModelLoad_ModelSystem_ModelId]') AND parent_object_id = OBJECT_ID(N'[Utility].[ModelLoad]'))
ALTER TABLE [Utility].[ModelLoad] CHECK CONSTRAINT [FK_ModelLoad_ModelSystem_ModelId]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Utility].[FK_ModelLoad_ModuleSystem_ModuleId]') AND parent_object_id = OBJECT_ID(N'[Utility].[ModelLoad]'))
ALTER TABLE [Utility].[ModelLoad]  WITH CHECK ADD  CONSTRAINT [FK_ModelLoad_ModuleSystem_ModuleId] FOREIGN KEY([ModuleId])
REFERENCES [Utility].[ModuleSystem] ([ModuleId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Utility].[FK_ModelLoad_ModuleSystem_ModuleId]') AND parent_object_id = OBJECT_ID(N'[Utility].[ModelLoad]'))
ALTER TABLE [Utility].[ModelLoad] CHECK CONSTRAINT [FK_ModelLoad_ModuleSystem_ModuleId]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Utility].[FK_ModelLoad_ModelSystem_ModelProgId]') AND parent_object_id = OBJECT_ID(N'[Utility].[ModelLoad]'))
ALTER TABLE [Utility].[ModelLoad]  WITH CHECK ADD  CONSTRAINT [FK_ModelLoad_ModelSystem_ModelProgId] FOREIGN KEY([ModelProgId])
REFERENCES [Utility].[ModelSystem] ([ModelId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Utility].[FK_ModelLoad_ModelSystem_ModelProgId]') AND parent_object_id = OBJECT_ID(N'[Utility].[ModelLoad]'))
ALTER TABLE [Utility].[ModelLoad] CHECK CONSTRAINT [FK_ModelLoad_ModelSystem_ModelProgId]
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Utility].[FK_ModelParameter_ModelSystem_ModelId]') AND parent_object_id = OBJECT_ID(N'[Utility].[ModelParameter]'))
ALTER TABLE [Utility].[ModelParameter]  WITH CHECK ADD  CONSTRAINT [FK_ModelParameter_ModelSystem_ModelId] FOREIGN KEY([ModelId])
REFERENCES [Utility].[ModelSystem] ([ModelId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Utility].[FK_ModelParameter_ModelSystem_ModelId]') AND parent_object_id = OBJECT_ID(N'[Utility].[ModelParameter]'))
ALTER TABLE [Utility].[ModelParameter] CHECK CONSTRAINT [FK_ModelParameter_ModelSystem_ModelId]
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Utility].[FK_ModelSchedule_ModelSystem_ModelId]') AND parent_object_id = OBJECT_ID(N'[Utility].[ModelSchedule]'))
ALTER TABLE [Utility].[ModelSchedule]  WITH CHECK ADD  CONSTRAINT [FK_ModelSchedule_ModelSystem_ModelId] FOREIGN KEY([ModelId])
REFERENCES [Utility].[ModelSystem] ([ModelId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Utility].[FK_ModelSchedule_ModelSystem_ModelId]') AND parent_object_id = OBJECT_ID(N'[Utility].[ModelSchedule]'))
ALTER TABLE [Utility].[ModelSchedule] CHECK CONSTRAINT [FK_ModelSchedule_ModelSystem_ModelId]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Utility].[FK_ModelSchedule_ScheduleSystem_ScheduleId]') AND parent_object_id = OBJECT_ID(N'[Utility].[ModelSchedule]'))
ALTER TABLE [Utility].[ModelSchedule]  WITH CHECK ADD  CONSTRAINT [FK_ModelSchedule_ScheduleSystem_ScheduleId] FOREIGN KEY([ScheduleId])
REFERENCES [Utility].[ScheduleSystem] ([ScheduleId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Utility].[FK_ModelSchedule_ScheduleSystem_ScheduleId]') AND parent_object_id = OBJECT_ID(N'[Utility].[ModelSchedule]'))
ALTER TABLE [Utility].[ModelSchedule] CHECK CONSTRAINT [FK_ModelSchedule_ScheduleSystem_ScheduleId]
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Utility].[FK_ModelVersion_ModelSystem_ModelId]') AND parent_object_id = OBJECT_ID(N'[Utility].[ModelVersion]'))
ALTER TABLE [Utility].[ModelVersion]  WITH CHECK ADD  CONSTRAINT [FK_ModelVersion_ModelSystem_ModelId] FOREIGN KEY([ModelId])
REFERENCES [Utility].[ModelSystem] ([ModelId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Utility].[FK_ModelVersion_ModelSystem_ModelId]') AND parent_object_id = OBJECT_ID(N'[Utility].[ModelVersion]'))
ALTER TABLE [Utility].[ModelVersion] CHECK CONSTRAINT [FK_ModelVersion_ModelSystem_ModelId]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Utility].[FK_ModelVersion_BitacoraState_StateId]') AND parent_object_id = OBJECT_ID(N'[Utility].[ModelVersion]'))
   AND EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Audit].[BitacoraState]') AND type in (N'U'))
ALTER TABLE [Utility].[ModelVersion]  WITH CHECK ADD  CONSTRAINT [FK_ModelVersion_BitacoraState_StateId] FOREIGN KEY([StateId])
REFERENCES [Audit].[BitacoraState] ([StateId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Utility].[FK_ModelVersion_BitacoraState_StateId]') AND parent_object_id = OBJECT_ID(N'[Utility].[ModelVersion]'))
ALTER TABLE [Utility].[ModelVersion] CHECK CONSTRAINT [FK_ModelVersion_BitacoraState_StateId]
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Utility].[FK_ModuleModel_ModuleSystem_ModuleId]') AND parent_object_id = OBJECT_ID(N'[Utility].[ModuleModel]'))
ALTER TABLE [Utility].[ModuleModel]  WITH CHECK ADD  CONSTRAINT [FK_ModuleModel_ModuleSystem_ModuleId] FOREIGN KEY([ModuleId])
REFERENCES [Utility].[ModuleSystem] ([ModuleId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Utility].[FK_ModuleModel_ModuleSystem_ModuleId]') AND parent_object_id = OBJECT_ID(N'[Utility].[ModuleModel]'))
ALTER TABLE [Utility].[ModuleModel] CHECK CONSTRAINT [FK_ModuleModel_ModuleSystem_ModuleId]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Utility].[FK_ModuleModel_ModelSystem_ModelId]') AND parent_object_id = OBJECT_ID(N'[Utility].[ModuleModel]'))
ALTER TABLE [Utility].[ModuleModel]  WITH CHECK ADD  CONSTRAINT [FK_ModuleModel_ModelSystem_ModelId] FOREIGN KEY([ModelId])
REFERENCES [Utility].[ModelSystem] ([ModelId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Utility].[FK_ModuleModel_ModelSystem_ModelId]') AND parent_object_id = OBJECT_ID(N'[Utility].[ModuleModel]'))
ALTER TABLE [Utility].[ModuleModel] CHECK CONSTRAINT [FK_ModuleModel_ModelSystem_ModelId]
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Utility].[FK_ModuleProgramming_ModuleSystem_ModuleId]') AND parent_object_id = OBJECT_ID(N'[Utility].[ModuleProgramming]'))
ALTER TABLE [Utility].[ModuleProgramming]  WITH CHECK ADD  CONSTRAINT [FK_ModuleProgramming_ModuleSystem_ModuleId] FOREIGN KEY([ModuleId])
REFERENCES [Utility].[ModuleSystem] ([ModuleId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Utility].[FK_ModuleProgramming_ModuleSystem_ModuleId]') AND parent_object_id = OBJECT_ID(N'[Utility].[ModuleProgramming]'))
ALTER TABLE [Utility].[ModuleProgramming] CHECK CONSTRAINT [FK_ModuleProgramming_ModuleSystem_ModuleId]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Utility].[FK_ModuleProgramming_ModelSystem_ModelId]') AND parent_object_id = OBJECT_ID(N'[Utility].[ModuleProgramming]'))
ALTER TABLE [Utility].[ModuleProgramming]  WITH CHECK ADD  CONSTRAINT [FK_ModuleProgramming_ModelSystem_ModelId] FOREIGN KEY([ModelId])
REFERENCES [Utility].[ModelSystem] ([ModelId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Utility].[FK_ModuleProgramming_ModelSystem_ModelId]') AND parent_object_id = OBJECT_ID(N'[Utility].[ModuleProgramming]'))
ALTER TABLE [Utility].[ModuleProgramming] CHECK CONSTRAINT [FK_ModuleProgramming_ModelSystem_ModelId]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Utility].[FK_ModuleProgramming_ModelSystem_ModelProgId]') AND parent_object_id = OBJECT_ID(N'[Utility].[ModuleProgramming]'))
ALTER TABLE [Utility].[ModuleProgramming]  WITH CHECK ADD  CONSTRAINT [FK_ModuleProgramming_ModelSystem_ModelProgId] FOREIGN KEY([ModelProgId])
REFERENCES [Utility].[ModelSystem] ([ModelId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Utility].[FK_ModuleProgramming_ModelSystem_ModelProgId]') AND parent_object_id = OBJECT_ID(N'[Utility].[ModuleProgramming]'))
ALTER TABLE [Utility].[ModuleProgramming] CHECK CONSTRAINT [FK_ModuleProgramming_ModelSystem_ModelProgId]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Utility].[FK_ModuleProgramming_BitacoraState_StateId]') AND parent_object_id = OBJECT_ID(N'[Utility].[ModuleProgramming]'))
   AND EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Audit].[BitacoraState]') AND type in (N'U'))
ALTER TABLE [Utility].[ModuleProgramming]  WITH CHECK ADD  CONSTRAINT [FK_ModuleProgramming_BitacoraState_StateId] FOREIGN KEY([StateId])
REFERENCES [Audit].[BitacoraState] ([StateId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Utility].[FK_ModuleProgramming_BitacoraState_StateId]') AND parent_object_id = OBJECT_ID(N'[Utility].[ModuleProgramming]'))
ALTER TABLE [Utility].[ModuleProgramming] CHECK CONSTRAINT [FK_ModuleProgramming_BitacoraState_StateId]
GO

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - End script: A06FK_Util.sql'
PRINT '------------------------------------------------------------------------'
GO
