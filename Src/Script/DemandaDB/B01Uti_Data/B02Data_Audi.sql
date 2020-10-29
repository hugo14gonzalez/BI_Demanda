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
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - Start script: B02Data_Audi.sql'
PRINT '------------------------------------------------------------------------'
GO

USE [$(DATABASE_NAME_DW)];

/* ====================================================================================
 SELECT * FROM [Audit].[BitacoraState];
==================================================================================== */
IF NOT EXISTS(SELECT * FROM [Audit].[BitacoraState] WHERE [StateId] = 0)
 INSERT INTO [Audit].[BitacoraState]([StateId], [Name])
 VALUES (0, 'Exitoso');
GO
IF NOT EXISTS(SELECT * FROM [Audit].[BitacoraState] WHERE [StateId] = 1)
 INSERT INTO [Audit].[BitacoraState]([StateId], [Name])
 VALUES (1, 'Error');
GO
IF NOT EXISTS(SELECT * FROM [Audit].[BitacoraState] WHERE [StateId] = 2)
 INSERT INTO [Audit].[BitacoraState]([StateId], [Name])
 VALUES (2, 'Iniciado');
GO
IF NOT EXISTS(SELECT * FROM [Audit].[BitacoraState] WHERE [StateId] = 3)
 INSERT INTO [Audit].[BitacoraState]([StateId], [Name])
 VALUES (3, 'Cancelado');
GO
IF NOT EXISTS(SELECT * FROM [Audit].[BitacoraState] WHERE [StateId] = 4)
 INSERT INTO [Audit].[BitacoraState]([StateId], [Name])
 VALUES (4, 'Abierto');
GO
IF NOT EXISTS(SELECT * FROM [Audit].[BitacoraState] WHERE [StateId] = 5)
 INSERT INTO [Audit].[BitacoraState]([StateId], [Name])
 VALUES (5, 'Cerrado');
GO
IF NOT EXISTS(SELECT * FROM [Audit].[BitacoraState] WHERE [StateId] = 6)
 INSERT INTO [Audit].[BitacoraState]([StateId], [Name])
 VALUES (6, 'Activo');
GO
IF NOT EXISTS(SELECT * FROM [Audit].[BitacoraState] WHERE [StateId] = 7)
 INSERT INTO [Audit].[BitacoraState]([StateId], [Name])
 VALUES (7, 'Inactivo');
GO
IF NOT EXISTS(SELECT * FROM [Audit].[BitacoraState] WHERE [StateId] = 8)
 INSERT INTO [Audit].[BitacoraState]([StateId], [Name])
 VALUES (8, 'Generado');
GO
IF NOT EXISTS(SELECT * FROM [Audit].[BitacoraState] WHERE [StateId] = 9)
 INSERT INTO [Audit].[BitacoraState]([StateId], [Name])
 VALUES (9, 'Definitivo');
GO
IF NOT EXISTS(SELECT * FROM [Audit].[BitacoraState] WHERE [StateId] = 10)
 INSERT INTO [Audit].[BitacoraState]([StateId], [Name])
 VALUES (10, 'Publicado');
GO
IF NOT EXISTS(SELECT * FROM [Audit].[BitacoraState] WHERE [StateId] = 11)
 INSERT INTO [Audit].[BitacoraState]([StateId], [Name])
 VALUES (11, 'Existente');
GO
IF NOT EXISTS(SELECT * FROM [Audit].[BitacoraState] WHERE [StateId] = 12)
 INSERT INTO [Audit].[BitacoraState]([StateId], [Name])
 VALUES (12, 'Eliminado');
GO
IF NOT EXISTS(SELECT * FROM [Audit].[BitacoraState] WHERE [StateId] = 13)
 INSERT INTO [Audit].[BitacoraState]([StateId], [Name])
 VALUES (13, 'Sin fuente de datos');
GO
IF NOT EXISTS(SELECT * FROM [Audit].[BitacoraState] WHERE [StateId] = 20)
 INSERT INTO [Audit].[BitacoraState]([StateId], [Name])
 VALUES (20, 'Programado para ejecutar');
GO
IF NOT EXISTS(SELECT * FROM [Audit].[BitacoraState] WHERE [StateId] = 21)
 INSERT INTO [Audit].[BitacoraState]([StateId], [Name])
 VALUES (21, 'Reprogramar ejecucion');
GO


/* ============================================================================================
SELECT * FROM [Audit].[BitacoraType];
============================================================================================ */
IF NOT EXISTS(SELECT * FROM [Audit].[BitacoraType] WHERE [TypeId] = 1)
 INSERT INTO [Audit].[BitacoraType]([TypeId],[Name],[Group],[Description])
 VALUES (1, 'General', 'General', 'General');
GO
IF NOT EXISTS(SELECT * FROM [Audit].[BitacoraType] WHERE [TypeId] = 2)
 INSERT INTO [Audit].[BitacoraType]([TypeId],[Name],[Group],[Description])
 VALUES (2, 'Conversion', 'General', 'Conversion de tipo de datos');
GO
IF NOT EXISTS(SELECT * FROM [Audit].[BitacoraType] WHERE [TypeId] = 3)
 INSERT INTO [Audit].[BitacoraType]([TypeId],[Name],[Group],[Description])
 VALUES (3, 'Datos ausente', 'General', 'Datos no suministrados');
GO
IF NOT EXISTS(SELECT * FROM [Audit].[BitacoraType] WHERE [TypeId] = 4)
 INSERT INTO [Audit].[BitacoraType]([TypeId],[Name],[Group],[Description])
 VALUES (4, 'Repetido', 'General', 'Datos repetidos');
GO
IF NOT EXISTS(SELECT * FROM [Audit].[BitacoraType] WHERE [TypeId] = 5)
 INSERT INTO [Audit].[BitacoraType]([TypeId],[Name],[Group],[Description])
 VALUES (5, 'Clave FK', 'General', 'Clave foranea no encontrada');
GO
IF NOT EXISTS(SELECT * FROM [Audit].[BitacoraType] WHERE [TypeId] = 6)
 INSERT INTO [Audit].[BitacoraType]([TypeId],[Name],[Group],[Description])
 VALUES (6, 'Inferir FK', 'General', 'Clave foranea inferida adicionada');
GO
IF NOT EXISTS(SELECT * FROM [Audit].[BitacoraType] WHERE [TypeId] = 7)
 INSERT INTO [Audit].[BitacoraType]([TypeId],[Name],[Group],[Description])
 VALUES (7, 'Valor no permitido', 'General', 'Valor no permitido');
GO
IF NOT EXISTS(SELECT * FROM [Audit].[BitacoraType] WHERE [TypeId] = 8)
 INSERT INTO [Audit].[BitacoraType]([TypeId],[Name],[Group],[Description])
 VALUES (8, 'Operacion no valida', 'General', 'Operacion no valida');
GO
IF NOT EXISTS(SELECT * FROM [Audit].[BitacoraType] WHERE [TypeId] = 9)
 INSERT INTO [Audit].[BitacoraType]([TypeId],[Name],[Group],[Description])
 VALUES (9, 'Dim tipo 2 DateStart', 'General', 'Dim tipo 2 fecha inicio igual, fila actualizada sin insertar version');
GO
IF NOT EXISTS(SELECT * FROM [Audit].[BitacoraType] WHERE [TypeId] = 10)
 INSERT INTO [Audit].[BitacoraType]([TypeId],[Name],[Group],[Description])
 VALUES (10, 'Informacion', 'Informacion', 'Informacion');
GO
IF NOT EXISTS(SELECT * FROM [Audit].[BitacoraType] WHERE [TypeId] = 11)
 INSERT INTO [Audit].[BitacoraType]([TypeId],[Name],[Group],[Description])
 VALUES (11, 'Calidad', 'General', 'Calidad de datos');
GO
IF NOT EXISTS(SELECT * FROM [Audit].[BitacoraType] WHERE [TypeId] = 12)
 INSERT INTO [Audit].[BitacoraType]([TypeId],[Name],[Group],[Description])
 VALUES (12, 'Particion', 'Particion', 'Operaciones CRUD con particion de cubos o tablas');
GO
IF NOT EXISTS(SELECT * FROM [Audit].[BitacoraType] WHERE [TypeId] = 13)
 INSERT INTO [Audit].[BitacoraType]([TypeId],[Name],[Group],[Description])
 VALUES (13, 'Mapeo', 'Mapeo', 'Mapeo de codigo');
GO
IF NOT EXISTS(SELECT * FROM [Audit].[BitacoraType] WHERE [TypeId] = 14)
 INSERT INTO [Audit].[BitacoraType]([TypeId],[Name],[Group],[Description])
 VALUES (14, 'ErrorFuente', 'General', 'Error o ajuste en la fuente de datos');
GO

/* ========================================================================== 
DATO INCONSISTENTE: [Audit].[Bitacora]
========================================================================== */
IF NOT EXISTS(SELECT * FROM [Audit].[Bitacora] Where [BitacoraId] = 0)
Begin
 SET IDENTITY_INSERT [Audit].[Bitacora] ON;

 INSERT INTO [Audit].[Bitacora] ([BitacoraId], [ParentId],[AppId],[ModuleId],[Name],[StateId],[DateStart],[DateEnd],[DateWorkStart],[DateWorkEnd]
  ,[ProcessId],[ProcessStringId],[UserId],[MachineId],[FailureTask],[Message])
 VALUES (0, NULL, 'NA', 0, 'NA', 0, GetDate(), GetDate(), NULL, NULL, NULL, NULL, 0 , 'NA', NULL, NULL);
 
 SET IDENTITY_INSERT [Audit].[Bitacora] OFF;
end;
GO

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - End script: B02Data_Audi.sql'
PRINT '------------------------------------------------------------------------'
GO