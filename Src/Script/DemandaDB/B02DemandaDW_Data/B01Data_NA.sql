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
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - Start script: B01Data_NA.sql'
PRINT '------------------------------------------------------------------------'
GO

USE [$(DATABASE_NAME_DW)];

/* ========================================================================== 
DATO INCONSISTENTE: [DimFecha]
========================================================================== */
IF NOT EXISTS(SELECT * FROM [DW].[DimFecha] WHERE [FechaSKId] = 19000101)
BEGIN
 INSERT INTO [DW].[DimFecha]([FechaSKId],[Fecha],[FechaDesc],[Anio],[Semestre],[SemestreDesc],[Trimestre],[TrimestreDesc],[Mes],[MesNombre]
,[MesNombreCorto],[MesDesc],[MesDescCorto],[SemanaAnio],[SemanaAnioDesc],[Dia],[DiaAnio],[DiaSemana],[DiaNombre],[DiaNombreCorto],[DiaTipo])
 VALUES (19000101,'19000101','1900-01-01',1900,1,'1900-Semestre1',1,'1900-Trim1',1,'Enero'
  ,'Ene','1900-Enero','1900-Ene',1,'1900-Semana01',1,1,1,'Lunes','Lun','Festivo');
END
GO

/* ========================================================================== 
DATO INCONSISTENTE: [DW].[DimGeografia]
========================================================================== */
IF NOT EXISTS(SELECT * FROM [DW].[DimGeografia] WHERE [GeografiaSKId] = 0)
BEGIN
 SET IDENTITY_INSERT [DW].[DimGeografia] ON;

 INSERT INTO [DW].[DimGeografia]([GeografiaSKId],[PaisId],[Pais],[DepartamentoId],[Departamento],[MunicipioId],[Municipio],[AreaId],[Area],[SubAreaId],[SubArea],[BitacoraId])
 VALUES (0, 'NA', 'NA', 'NA', 'NA', 'NA', 'NA', 'NA', 'NA', 'NA', 'NA', 0);

 SET IDENTITY_INSERT [DW].[DimGeografia] OFF;
END
GO

/* ========================================================================== 
DATO INCONSISTENTE: [DW].[DimCompania]
========================================================================== */
IF NOT EXISTS(SELECT * FROM [DW].[DimCompania] WHERE [CompaniaSKId] = 0)
BEGIN
 SET IDENTITY_INSERT [DW].[DimCompania] ON;

 INSERT INTO [DW].[DimCompania]([CompaniaSKId],[CompaniaId],[Nombre],[Sigla],[Nit],[TipoPropiedad],[Activa],[EsActual],[FechaIniSKId],[FechaFinSKId],[BitacoraId])
 VALUES (0, 'NA', 'NA', 'NA', 'NA', 'NA', 1, 1, 19000101, NULL, 0);

 SET IDENTITY_INSERT [DW].[DimCompania] OFF;
END
GO

IF NOT EXISTS(SELECT * FROM [DW].[DimCompania] WHERE [CompaniaSKId] = 1)
BEGIN
 SET IDENTITY_INSERT [DW].[DimCompania] ON;

 INSERT INTO [DW].[DimCompania]([CompaniaSKId],[CompaniaId],[Nombre],[Sigla],[Nit],[TipoPropiedad],[Activa],[EsActual],[FechaIniSKId],[FechaFinSKId],[BitacoraId])
 VALUES (1, '0', '0', '0', '0', '0', 1, 1, 19000101, NULL, 0);

 SET IDENTITY_INSERT [DW].[DimCompania] OFF;
END
GO

/* ========================================================================== 
DATO INCONSISTENTE: [DW].[DimAgente]
========================================================================== */
IF NOT EXISTS(SELECT * FROM [DW].[DimAgente] WHERE [AgenteSKId] = 0)
BEGIN
 SET IDENTITY_INSERT [DW].[DimAgente] ON;

 INSERT INTO [DW].[DimAgente]([AgenteSKId],[AgenteId],[AgenteMemId],[Nombre],[Actividad],[CompaniaSKId],[Activo],[EsActual],[FechaIniSKId],[FechaFinSKId],[BitacoraId])
 VALUES (0, 'NA', 'NA', 'NA', 'NA', 0, 1, 1, 19000101, NULL, 0);

 SET IDENTITY_INSERT [DW].[DimAgente] OFF;
END
GO

IF NOT EXISTS(SELECT * FROM [DW].[DimAgente] WHERE [AgenteSKId] = 1)
BEGIN
 SET IDENTITY_INSERT [DW].[DimAgente] ON;

 INSERT INTO [DW].[DimAgente]([AgenteSKId],[AgenteId],[AgenteMemId],[Nombre],[Actividad],[CompaniaSKId],[Activo],[EsActual],[FechaIniSKId],[FechaFinSKId],[BitacoraId])
 VALUES (1, '0', '0', '0', '0', 0, 1, 1, 19000101, NULL, 0);

 SET IDENTITY_INSERT [DW].[DimAgente] OFF;
END
GO

/* ============================================================================================
DATO INCONSISTENTE: [DW].[DimMercado]
============================================================================================ */
IF NOT EXISTS(SELECT * FROM [DW].[DimMercado] WHERE [MercadoSKId] = 0) 
BEGIN 
 SET IDENTITY_INSERT [DW].[DimMercado] ON;

 INSERT INTO [DW].[DimMercado]([MercadoSKId],[Mercado],[BitacoraId])
 VALUES(0, 'NA', 0); 

 SET IDENTITY_INSERT [DW].[DimMercado] OFF;
END;
GO

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - End script: B01Data_NA.sql'
PRINT '------------------------------------------------------------------------'
GO