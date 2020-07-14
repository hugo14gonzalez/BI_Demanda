/* ========================================================================== 
Proyecto: DemandaBI
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya 
Fecha: 2020-07-15
Fecha actualizacion: 2020-07-15
Link: http://www.purplefrogsystems.com/blog/2010/09/olap-cube-documentation-in-ssrs-part-1/ 

Azure SQL Database elastic query (cross-database queries)
https://docs.microsoft.com/en-us/azure/sql-database/sql-database-elastic-query-overview

Query across cloud databases with different schemas (preview)
https://docs.microsoft.com/en-us/azure/sql-database/sql-database-elastic-query-vertical-partitioning
========================================================================== */ 

/* ========================================================================== 
VARIABLES PARA INSTALAR:
$(DATABASE_NAME_DW): Nombre de la base de datos. Ejemplo: DemandaDW
========================================================================== */

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - Start script: A15SPUtil_OLAP.sql'
PRINT '------------------------------------------------------------------------'
GO

USE [$(DATABASE_NAME_DW)];

/* ========================================================================== 
Metadatos para Create diccionario de datos de cubos OLAP
========================================================================== */
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[spOLAP_GetCatalogs]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_EXECUTEsql @statement = N'CREATE PROCEDURE [Utility].[spOLAP_GetCatalogs] AS' 
END
GO
ALTER PROCEDURE [Utility].[spOLAP_GetCatalogs]
(
   @linkServer nvarchar(128)
)
WITH EXECUTE AS OWNER 
AS
/* ============================================================================================
Proposito: Retorna bases de datos OLAP de una instancia.
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2017-04-10
Fecha actualizacion: 2020-07-15

Parametros:  
 @linkServer: Nombre del servidor vinculado a la base de datos en un servidor SQL Server Analysis Services. Ejemplo: PerdidasOLAP.

Ejemplo:
EXECUTE [Utility].[spOLAP_GetCatalogs] 'PerdidasOLAP'; 
============================================================================================ */
BEGIN
 SET NOCOUNT ON;
 Declare @sql nvarchar(max);

 set @sql = '';

 set @sql = @sql +
'SELECT [CATALOG_NAME], [DESCRIPTION] ' + CHAR(13) + CHAR(10) + 
'FROM OPENQUERY(' + @linkServer + ', ' + CHAR(13) + CHAR(10) + 
' ''SELECT [CATALOG_NAME], [DESCRIPTION] ' + CHAR(13) + CHAR(10) +
' FROM $SYSTEM.DBSCHEMA_CATALOGS'') ' + CHAR(13) + CHAR(10) + 
'ORDER BY CAST([CATALOG_NAME] AS nvarchar(4000))';

 EXECUTE sp_executesql @sql;
END; 
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[spOLAP_GetCubes]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_EXECUTEsql @statement = N'CREATE PROCEDURE [Utility].[spOLAP_GetCubes] AS' 
END
GO
ALTER PROCEDURE [Utility].[spOLAP_GetCubes]
(
   @linkServer nvarchar(128)
  ,@catalog nvarchar(255) = NULL
)
WITH EXECUTE AS OWNER 
AS
/* ============================================================================================
Proposito: Retorna los cubos de una base de datos OLAP.
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2017-04-10
Fecha actualizacion: 2020-07-15

Parametros:  
 @linkServer: Nombre del servidor vinculado a la base de datos en un servidor SQL Server Analysis Services. Ejemplo: PerdidasOLAP.
 @catalog: Nombre de la base de datos OLAP. Ejemplo: PerdidasOLAP.

Ejemplo:
EXECUTE [Utility].[spOLAP_GetCubes] 'PerdidasOLAP', 'PerdidasOLAP'; 
EXECUTE [Utility].[spOLAP_GetCubes] 'PerdidasOLAP'; 
============================================================================================ */
BEGIN
 SET NOCOUNT ON;
 Declare @sql nvarchar(max), @parmDefinition nvarchar(1024);

 set @sql = '';
 set @parmDefinition = N'@catalog nvarchar(255)';

 set @sql = @sql +
'SELECT [CATALOG_NAME], [CUBE_NAME], [DESCRIPTION] ' + CHAR(13) + CHAR(10) + 
', CONVERT(BIT, [IS_DRILLTHROUGH_ENABLED]) [IS_DRILLTHROUGH_ENABLED] ' + CHAR(13) + CHAR(10) +
', CONVERT(BIT, [IS_LINKABLE]) [IS_LINKABLE] ' + CHAR(13) + CHAR(10) + 
', CONVERT(BIT, [IS_WRITE_ENABLED]) [IS_WRITE_ENABLED] ' + CHAR(13) + CHAR(10) + 
', CONVERT(BIT, [IS_SQL_ENABLED]) [IS_SQL_ENABLED] ' + CHAR(13) + CHAR(10) + 
', CONVERT(SMALLDATETIME, [LAST_SCHEMA_UPDATE]) AS [LAST_SCHEMA_UPDATE] ' + CHAR(13) + CHAR(10) + 
'FROM OPENQUERY(' + @linkServer + ', ' + CHAR(13) + CHAR(10) + 
' ''SELECT [CATALOG_NAME], [CUBE_NAME], [DESCRIPTION], [IS_DRILLTHROUGH_ENABLED] ' + CHAR(13) + CHAR(10) +
' , [IS_LINKABLE], [IS_WRITE_ENABLED], [IS_SQL_ENABLED], [LAST_SCHEMA_UPDATE], [BASE_CUBE_NAME]' + CHAR(13) + CHAR(10) +
' FROM $SYSTEM.MDSCHEMA_CUBES ' + CHAR(13) + CHAR(10) +
' WHERE [CUBE_SOURCE] = 1 '') ' + CHAR(13) + CHAR(10) + 
'WHERE (CAST([CATALOG_NAME] AS nvarchar(4000)) = @catalog OR @catalog IS NULL) ' + CHAR(13) + CHAR(10) + 
'AND (CAST([BASE_CUBE_NAME] AS nvarchar(4000)) IS NULL) ' + CHAR(13) + CHAR(10) + 
'ORDER BY CAST([CATALOG_NAME] AS nvarchar(4000)), CAST([CUBE_NAME] AS nvarchar(4000))';

 EXECUTE sp_executesql @sql, @parmDefinition, @catalog = @catalog;
END; 
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[spOLAP_GetDimensions]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_EXECUTEsql @statement = N'CREATE PROCEDURE [Utility].[spOLAP_GetDimensions] AS' 
END
GO
ALTER PROCEDURE [Utility].[spOLAP_GetDimensions]
( @linkServer nvarchar(128)
 ,@excludePerspectives bit = 1
 ,@catalog nvarchar(255) = NULL
 ,@cube nvarchar(255) = NULL )
WITH EXECUTE AS OWNER 
AS
/* ============================================================================================
Proposito: Retorna dimensiones en cubo de bases de datos OLAP.
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2017-04-10
Fecha actualizacion: 2020-07-15

Parametros:  
 @linkServer: Nombre del servidor vinculado a la base de datos en un servidor SQL Server Analysis Services. Ejemplo: PerdidasOLAP.
 @excludePerspectives: Indica si excluye perspectivas.
 @catalog: Nombre de la base de datos OLAP. Ejemplo: PerdidasOLAP.
 @cube: Nombre del cubo. Ejemplo: Perdidas.

Ejemplo:
EXECUTE [Utility].[spOLAP_GetDimensions] 'PerdidasOLAP', 1, 'PerdidasOLAP', 'Perdidas';
EXECUTE [Utility].[spOLAP_GetDimensions] 'PerdidasOLAP', 1, 'PerdidasOLAP';
EXECUTE [Utility].[spOLAP_GetDimensions] 'PerdidasOLAP', 0;
============================================================================================ */
BEGIN
 SET NOCOUNT ON;
 Declare @sql nvarchar(max), @parmDefinition nvarchar(1024);

 set @sql = '';
 set @parmDefinition = N'@catalog nvarchar(255), @cube nvarchar(255)';

 set @sql = @sql +
'SELECT D.[CATALOG_NAME] ' + CHAR(13) + CHAR(10) +
', CASE WHEN C.[BASE_CUBE_NAME] IS NULL THEN C.[CUBE_NAME] ELSE C.[BASE_CUBE_NAME] END [BASE_CUBE_NAME] ' + CHAR(13) + CHAR(10) +
', D.[CUBE_NAME], D.[DIMENSION_MASTER_NAME], D.[DIMENSION_NAME] ' + CHAR(13) + CHAR(10) +
', D.[DESCRIPTION] ' + CHAR(13) + CHAR(10) +
', CASE D.[DIMENSION_TYPE] ' + CHAR(13) + CHAR(10) +
'		WHEN 0 THEN ''Unknown'' ' + CHAR(13) + CHAR(10) +
'		WHEN 1 THEN ''Time'' ' + CHAR(13) + CHAR(10) +
'		WHEN 2 THEN ''Measure'' ' + CHAR(13) + CHAR(10) +
'		WHEN 3 THEN ''Regular'' ' + CHAR(13) + CHAR(10) +
'		WHEN 5 THEN ''Quantitative'' ' + CHAR(13) + CHAR(10) +
'		WHEN 6 THEN ''Accounts'' ' + CHAR(13) + CHAR(10) +
'		WHEN 7 THEN ''Customers'' ' + CHAR(13) + CHAR(10) +
'		WHEN 8 THEN ''Products'' ' + CHAR(13) + CHAR(10) +
'		WHEN 9 THEN ''Scenario'' ' + CHAR(13) + CHAR(10) +
'		WHEN 10 THEN ''Utility'' ' + CHAR(13) + CHAR(10) +
'		WHEN 11 THEN ''Currency'' ' + CHAR(13) + CHAR(10) +
'		WHEN 12 THEN ''Rates'' ' + CHAR(13) + CHAR(10) +
'		WHEN 13 THEN ''Channel'' ' + CHAR(13) + CHAR(10) +
'		WHEN 14 THEN ''Promotion'' ' + CHAR(13) + CHAR(10) +
'		WHEN 15 THEN ''Organization'' ' + CHAR(13) + CHAR(10) +
'		WHEN 16 THEN ''Bill of Materials'' ' + CHAR(13) + CHAR(10) +
'		WHEN 17 THEN ''Geography'' ' + CHAR(13) + CHAR(10) +
'       ELSE NULL END [DIMENSION_TYPE]' + CHAR(13) + CHAR(10) + 
', D.[DEFAULT_HIERARCHY], D.[DIMENSION_IS_VISIBLE], D.[IS_VIRTUAL], D.[IS_READWRITE] ' + CHAR(13) + CHAR(10) + 
'FROM OPENQUERY(' + @linkServer + ', ' + CHAR(13) + CHAR(10) + 
'''SELECT [CATALOG_NAME], [CUBE_NAME], [DIMENSION_MASTER_NAME], [DIMENSION_NAME], [DIMENSION_UNIQUE_NAME] ' + CHAR(13) + CHAR(10) +
' , [DESCRIPTION], [DIMENSION_TYPE], [DIMENSION_IS_VISIBLE],  [DEFAULT_HIERARCHY], [IS_VIRTUAL], [IS_READWRITE] ' + CHAR(13) + CHAR(10) + 
' FROM $SYSTEM.MDSCHEMA_DIMENSIONS ' + CHAR(13) + CHAR(10) + 
' WHERE [DIMENSION_MASTER_NAME] <> ''''Measures'''' '') D ' + CHAR(13) + CHAR(10) + 
'INNER JOIN OPENQUERY(' + @linkServer + ', ' + CHAR(13) + CHAR(10) + 
' ''SELECT [CATALOG_NAME], [BASE_CUBE_NAME], [CUBE_NAME] ' + CHAR(13) + CHAR(10) +
' FROM $SYSTEM.MDSCHEMA_CUBES ' + CHAR(13) + CHAR(10) +
' WHERE [CUBE_SOURCE] = 1'') C ' + CHAR(13) + CHAR(10) + 
'ON CAST(D.[CATALOG_NAME] AS nvarchar(4000)) = CAST(C.[CATALOG_NAME] AS nvarchar(4000)) ' + CHAR(13) + CHAR(10) + 
'AND CAST(D.[CUBE_NAME] AS nvarchar(4000)) = CAST(C.[CUBE_NAME] AS nvarchar(4000)) ' + CHAR(13) + CHAR(10);

 if (@excludePerspectives = 1)
 begin
  set @sql = @sql + 'AND C.[BASE_CUBE_NAME] IS NULL ' + CHAR(13) + CHAR(10);
 end

 set @sql = @sql + 
'WHERE (CAST(D.[CATALOG_NAME] AS nvarchar(4000)) = @catalog OR @catalog IS NULL) ' + CHAR(13) + CHAR(10) +
' AND (CAST(D.[CUBE_NAME] AS nvarchar(4000)) = @cube OR (@cube IS NULL AND LEFT(CAST(D.[CUBE_NAME] AS nvarchar(4000)), 1) <> ''$'')) ' + CHAR(13) + CHAR(10) +
'ORDER BY CAST(D.[CATALOG_NAME] AS nvarchar(4000)), CASE WHEN C.[BASE_CUBE_NAME] IS NULL THEN CAST(C.[CUBE_NAME] AS nvarchar(4000)) ELSE CAST(C.[BASE_CUBE_NAME] AS nvarchar(4000)) END ' + CHAR(13) + CHAR(10) +
', CAST(D.[CUBE_NAME] AS nvarchar(4000)), CAST(D.[DIMENSION_MASTER_NAME] AS nvarchar(4000))';

 EXECUTE sp_executesql @sql, @parmDefinition, @catalog = @catalog, @cube = @cube;
END; 
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[spOLAP_GetDimensionsAttributes]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_EXECUTEsql @statement = N'CREATE PROCEDURE [Utility].[spOLAP_GetDimensionsAttributes] AS' 
END
GO
ALTER PROCEDURE [Utility].[spOLAP_GetDimensionsAttributes]
( @linkServer nvarchar(128)
 ,@catalog nvarchar(255) = NULL
 ,@dimension nvarchar(255) = NULL )
WITH EXECUTE AS OWNER 
AS
/* ============================================================================================
Proposito: Retorna atributos de dimensiones de bases de datos OLAP.
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2017-04-10
Fecha actualizacion: 2020-07-15

Parametros:  
 @linkServer: Nombre del servidor vinculado a la base de datos en un servidor SQL Server Analysis Services. Ejemplo: PerdidasOLAP.
 @catalog: Nombre de la base de datos OLAP. Ejemplo: PerdidasOLAP.
 @dimension: Nombre de dimension. Ejemplo: DimCliente.

NOTA: El campo [HIERARCHY_ORIGIN] tien los siguientes valores: 1: definidas por el usuario, 2: Atributo, 3: Parent-Child, 6: Key

Ejemplo:
EXECUTE [Utility].[spOLAP_GetDimensionsAttributes] 'PerdidasOLAP', 'PerdidasOLAP', 'DimCliente';
EXECUTE [Utility].[spOLAP_GetDimensionsAttributes] 'PerdidasOLAP', 'PerdidasOLAP';
EXECUTE [Utility].[spOLAP_GetDimensionsAttributes] 'PerdidasOLAP';
============================================================================================ */
BEGIN
 SET NOCOUNT ON;
 Declare @sql nvarchar(max), @parmDefinition nvarchar(1024);

 set @sql = '';
 set @parmDefinition = N'@catalog nvarchar(255), @dimension nvarchar(255)';

 set @sql = @sql +
'SELECT [CATALOG_NAME], REPLACE(REPLACE(CAST([DIMENSION_UNIQUE_NAME] AS nvarchar(4000)) ,''['', ''''), '']'', '''') AS [DIMENSION_UNIQUE_NAME], [LEVEL_NAME] [ATTRIBUTE_NAME] ' + CHAR(13) + CHAR(10) + 
', CASE WHEN CAST(LEVEL_ORIGIN AS INT) = 1 THEN ''User define'' ' + CHAR(13) + CHAR(10) +  
'       WHEN CAST(LEVEL_ORIGIN AS INT) = 2 THEN ''Attibute'' ' + CHAR(13) + CHAR(10) + 
'       WHEN CAST(LEVEL_ORIGIN AS INT) = 3 THEN ''Parent-Chlid'' ' + CHAR(13) + CHAR(10) + 
'       WHEN CAST(LEVEL_ORIGIN AS INT) = 6 THEN ''Key'' ' + CHAR(13) + CHAR(10) + 
'       ELSE NULL END AS [TYPE] ' + CHAR(13) + CHAR(10) + 
', [DESCRIPTION], [LEVEL_IS_VISIBLE] ' + CHAR(13) + CHAR(10) + 
'FROM OPENQUERY(' + @linkServer + ', ' + CHAR(13) + CHAR(10) + 
' ''SELECT [CATALOG_NAME], [CUBE_NAME], [DIMENSION_UNIQUE_NAME], [LEVEL_NAME], [LEVEL_ORIGIN], [DESCRIPTION], [LEVEL_IS_VISIBLE] ' + CHAR(13) + CHAR(10) + 
' FROM $SYSTEM.MDSCHEMA_LEVELS ' + CHAR(13) + CHAR(10) +  
' WHERE [LEVEL_NUMBER] <> 0  AND [LEVEL_ORIGIN] <> 1'') ' + CHAR(13) + CHAR(10) + 
'WHERE (CAST([CATALOG_NAME] AS nvarchar(4000)) = @catalog OR @catalog IS NULL) ' + CHAR(13) + CHAR(10) +
' AND (LEFT(CAST([CUBE_NAME] AS nvarchar(4000)), 1) = ''$'') ' + CHAR(13) + CHAR(10) +
' AND (CAST([DIMENSION_UNIQUE_NAME] AS nvarchar(4000)) = QUOTENAME(@dimension) OR @dimension IS NULL) ' + CHAR(13) + CHAR(10) +
'ORDER BY  CAST([CATALOG_NAME] AS nvarchar(4000)), CAST([DIMENSION_UNIQUE_NAME] AS nvarchar(4000)), CAST(LEVEL_ORIGIN AS INT) DESC, CAST([LEVEL_NAME] AS nvarchar(4000))'

 EXECUTE sp_executesql @sql, @parmDefinition, @catalog = @catalog, @dimension = @dimension;
END; 
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[spOLAP_GetHierarchies]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_EXECUTEsql @statement = N'CREATE PROCEDURE [Utility].[spOLAP_GetHierarchies] AS' 
END
GO
ALTER PROCEDURE [Utility].[spOLAP_GetHierarchies]
( @linkServer nvarchar(128)
 ,@catalog nvarchar(255) = NULL
 ,@dimension nvarchar(255) = NULL )
WITH EXECUTE AS OWNER 
AS
/* ============================================================================================
Proposito: Retorna jerarquías de dimensiones de bases de datos OLAP.
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2017-04-10
Fecha actualizacion: 2020-07-15

Parametros:  
 @linkServer: Nombre del servidor vinculado a la base de datos en un servidor SQL Server Analysis Services. Ejemplo: PerdidasOLAP.
 @catalog: Nombre de la base de datos OLAP. Ejemplo: PerdidasOLAP.
 @dimension: Nombre de dimension. Ejemplo: DimCliente.

NOTA: El campo [HIERARCHY_ORIGIN] tien los siguientes valores: 1: definidas por el usuario, 2: Atributo, 3: Parent-Child, 6: Key

Ejemplo:
EXECUTE [Utility].[spOLAP_GetHierarchies] 'PerdidasOLAP', 'PerdidasOLAP', 'DimCliente';
EXECUTE [Utility].[spOLAP_GetHierarchies] 'PerdidasOLAP', 'PerdidasOLAP';
EXECUTE [Utility].[spOLAP_GetHierarchies] 'PerdidasOLAP';
============================================================================================ */
BEGIN
 SET NOCOUNT ON;
 Declare @sql nvarchar(max), @parmDefinition nvarchar(1024);

 set @sql = '';
 set @parmDefinition = N'@catalog nvarchar(255), @dimension nvarchar(255)';

 set @sql = @sql +
'SELECT [CATALOG_NAME], REPLACE(REPLACE(CAST([DIMENSION_UNIQUE_NAME] AS nvarchar(4000)) ,''['', ''''), '']'', '''') AS [DIMENSION_UNIQUE_NAME], [HIERARCHY_NAME] ' + CHAR(13) + CHAR(10) + 
', CASE WHEN CAST([HIERARCHY_ORIGIN] AS INT) = 1 THEN ''User define'' ' + CHAR(13) + CHAR(10) +  
'       WHEN CAST([HIERARCHY_ORIGIN] AS INT) = 2 THEN ''Attibute'' ' + CHAR(13) + CHAR(10) + 
'       WHEN CAST([HIERARCHY_ORIGIN] AS INT) = 3 THEN ''Parent-Chlid'' ' + CHAR(13) + CHAR(10) + 
'       WHEN CAST([HIERARCHY_ORIGIN] AS INT) = 6 THEN ''Key'' ' + CHAR(13) + CHAR(10) + 
'       ELSE NULL END AS [TYPE] ' + CHAR(13) + CHAR(10) + 
', [DESCRIPTION], [HIERARCHY_DISPLAY_FOLDER], [HIERARCHY_IS_VISIBLE] ' + CHAR(13) + CHAR(10) + 
'FROM OPENQUERY(' + @linkServer + ', ' + CHAR(13) + CHAR(10) + 
' ''SELECT [CATALOG_NAME], [CUBE_NAME], [DIMENSION_UNIQUE_NAME], [HIERARCHY_NAME], [HIERARCHY_UNIQUE_NAME] ' + CHAR(13) + CHAR(10) + 
' , [HIERARCHY_ORIGIN], [DESCRIPTION], [HIERARCHY_DISPLAY_FOLDER], [HIERARCHY_IS_VISIBLE] ' + CHAR(13) + CHAR(10) + 
' FROM $SYSTEM.MDSCHEMA_HIERARCHIES ' + CHAR(13) + CHAR(10) +  
' WHERE [HIERARCHY_ORIGIN] = 1 OR [HIERARCHY_ORIGIN] = 3 '') ' + CHAR(13) + CHAR(10) + 
'WHERE (CAST([CATALOG_NAME] AS nvarchar(4000)) = @catalog OR @catalog IS NULL) ' + CHAR(13) + CHAR(10) +
' AND (LEFT(CAST([CUBE_NAME] AS nvarchar(4000)), 1) = ''$'') ' + CHAR(13) + CHAR(10) +
' AND (CAST([DIMENSION_UNIQUE_NAME] AS nvarchar(4000)) = QUOTENAME(@dimension) OR @dimension IS NULL) ' + CHAR(13) + CHAR(10) +
'ORDER BY  CAST([CATALOG_NAME] AS nvarchar(4000)), CAST([DIMENSION_UNIQUE_NAME] AS nvarchar(4000)), CAST([HIERARCHY_NAME] AS nvarchar(4000))'

 EXECUTE sp_executesql @sql, @parmDefinition, @catalog = @catalog, @dimension = @dimension;
END; 
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[spOLAP_GetHierarchiesAttributes]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_EXECUTEsql @statement = N'CREATE PROCEDURE [Utility].[spOLAP_GetHierarchiesAttributes] AS' 
END
GO
ALTER PROCEDURE [Utility].[spOLAP_GetHierarchiesAttributes]
( @linkServer nvarchar(128)
 ,@catalog nvarchar(255) = NULL
 ,@dimension nvarchar(255) = NULL )
WITH EXECUTE AS OWNER 
AS
/* ============================================================================================
Proposito: Retorna atributos de jerarquías de dimensiones de bases de datos OLAP.
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2017-04-10
Fecha actualizacion: 2020-07-15

Parametros:  
 @linkServer: Nombre del servidor vinculado a la base de datos en un servidor SQL Server Analysis Services. Ejemplo: PerdidasOLAP.
 @catalog: Nombre de la base de datos OLAP. Ejemplo: PerdidasOLAP.
 @dimension: Nombre de dimension. Ejemplo: DimCliente.

NOTA: El campo [HIERARCHY_ORIGIN] tien los siguientes valores: 1: definidas por el usuario, 2: Atributo, 3: Parent-Child, 6: Key

Ejemplo:
EXECUTE [Utility].[spOLAP_GetHierarchiesAttributes] 'PerdidasOLAP', 'PerdidasOLAP', 'DimCliente';
EXECUTE [Utility].[spOLAP_GetHierarchiesAttributes] 'PerdidasOLAP', 'PerdidasOLAP';
EXECUTE [Utility].[spOLAP_GetHierarchiesAttributes] 'PerdidasOLAP';
============================================================================================ */
BEGIN
 SET NOCOUNT ON;
 Declare @sql nvarchar(max), @parmDefinition nvarchar(1024);

 set @sql = '';
 set @parmDefinition = N'@catalog nvarchar(255), @dimension nvarchar(255)';

 set @sql = @sql +
'SELECT [CATALOG_NAME], REPLACE(REPLACE(CAST([DIMENSION_UNIQUE_NAME] AS nvarchar(4000)) ,''['', ''''), '']'', '''') AS [DIMENSION_UNIQUE_NAME], [HIERARCHY_UNIQUE_NAME] ' + CHAR(13) + CHAR(10) + 
', [LEVEL_NAME], [LEVEL_NUMBER] ' + CHAR(13) + CHAR(10) + 
', CASE WHEN CAST(LEVEL_ORIGIN AS INT) = 1 THEN ''User define'' ' + CHAR(13) + CHAR(10) +  
'       WHEN CAST(LEVEL_ORIGIN AS INT) = 2 THEN ''Attibute'' ' + CHAR(13) + CHAR(10) + 
'       WHEN CAST(LEVEL_ORIGIN AS INT) = 3 THEN ''Parent-Chlid'' ' + CHAR(13) + CHAR(10) + 
'       WHEN CAST(LEVEL_ORIGIN AS INT) = 6 THEN ''Key'' ' + CHAR(13) + CHAR(10) + 
'       ELSE NULL END AS [TYPE] ' + CHAR(13) + CHAR(10) + 
', [DESCRIPTION]  ' + CHAR(13) + CHAR(10) + 
'FROM OPENQUERY(' + @linkServer + ', ' + CHAR(13) + CHAR(10) + 
' ''SELECT [CATALOG_NAME], [CUBE_NAME], [DIMENSION_UNIQUE_NAME], [HIERARCHY_UNIQUE_NAME] ' + CHAR(13) + CHAR(10) + 
' , [LEVEL_NAME], [LEVEL_NUMBER], [LEVEL_ORIGIN], [DESCRIPTION] ' + CHAR(13) + CHAR(10) + 
' FROM $SYSTEM.MDSCHEMA_LEVELS ' + CHAR(13) + CHAR(10) +  
' WHERE [LEVEL_NUMBER] <> 0  AND ([LEVEL_ORIGIN] = 1 OR [LEVEL_ORIGIN] = 3) '') ' + CHAR(13) + CHAR(10) + 
'WHERE (CAST([CATALOG_NAME] AS nvarchar(4000)) = @catalog OR @catalog IS NULL) ' + CHAR(13) + CHAR(10) +
' AND (LEFT(CAST([CUBE_NAME] AS nvarchar(4000)), 1) = ''$'') ' + CHAR(13) + CHAR(10) +
' AND (CAST([DIMENSION_UNIQUE_NAME] AS nvarchar(4000)) = QUOTENAME(@dimension) OR @dimension IS NULL) ' + CHAR(13) + CHAR(10) +
'ORDER BY  CAST([CATALOG_NAME] AS nvarchar(4000)), CAST([DIMENSION_UNIQUE_NAME] AS nvarchar(4000)), CAST([HIERARCHY_UNIQUE_NAME] AS nvarchar(4000)), CAST([LEVEL_NUMBER] AS INT)'

 EXECUTE sp_executesql @sql, @parmDefinition, @catalog = @catalog, @dimension = @dimension;
END; 
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[spOLAP_GetKPI]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_EXECUTEsql @statement = N'CREATE PROCEDURE [Utility].[spOLAP_GetKPI] AS' 
END
GO
ALTER PROCEDURE [Utility].[spOLAP_GetKPI]
( @linkServer nvarchar(128)
 ,@excludePerspectives bit = 1
 ,@catalog nvarchar(255) = NULL
 ,@cube nvarchar(255) = NULL )
WITH EXECUTE AS OWNER 
AS
/* ============================================================================================
Proposito: Retorna KPI de un cubo de bases de datos OLAP.
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2017-04-10
Fecha actualizacion: 2020-07-15

Parametros:  
 @linkServer: Nombre del servidor vinculado a la base de datos en un servidor SQL Server Analysis Services. Ejemplo: PerdidasOLAP.
 @excludePerspectives: Indica si excluye perspectivas.
 @catalog: Nombre de la base de datos OLAP. Ejemplo: PerdidasOLAP.
 @cube: Nombre del cubo. Ejemplo: Perdidas.

Ejemplo:
EXECUTE [Utility].[spOLAP_GetKPI] 'PerdidasOLAP', 1, 'PerdidasOLAP', 'Perdidas';
EXECUTE [Utility].[spOLAP_GetKPI] 'PerdidasOLAP', 1, 'PerdidasOLAP';
EXECUTE [Utility].[spOLAP_GetKPI] 'PerdidasOLAP', 0;
============================================================================================ */
BEGIN
 SET NOCOUNT ON;
 Declare @sql nvarchar(max), @parmDefinition nvarchar(1024);

 set @sql = '';
 set @parmDefinition = N'@catalog nvarchar(255), @cube nvarchar(255)';

 set @sql = @sql +
'SELECT K.[CATALOG_NAME] ' + CHAR(13) + CHAR(10) +
', CASE WHEN C.[BASE_CUBE_NAME] IS NULL THEN C.[CUBE_NAME] ELSE C.[BASE_CUBE_NAME] END [BASE_CUBE_NAME] ' + CHAR(13) + CHAR(10) +
', K.[CUBE_NAME], K.[MEASUREGROUP_NAME], K.[KPI_NAME], K.[KPI_DESCRIPTION], K.[KPI_DISPLAY_FOLDER] ' + CHAR(13) + CHAR(10) + 
', K.[KPI_VALUE], K.[KPI_GOAL], K.[KPI_STATUS], K.[KPI_TREND], K.[KPI_STATUS_GRAPHIC], K.[KPI_TREND_GRAPHIC] ' + CHAR(13) + CHAR(10) + 
', K.[KPI_WEIGHT], K.[KPI_CURRENT_TIME_MEMBER], K.[KPI_PARENT_KPI_NAME], K.[SCOPE], K.[ANNOTATIONS] ' + CHAR(13) + CHAR(10) + 
'FROM OPENQUERY(' + @linkServer + ', ' + CHAR(13) + CHAR(10) + 
' ''SELECT [CATALOG_NAME],[CUBE_NAME],[MEASUREGROUP_NAME], [KPI_NAME], [KPI_DESCRIPTION], [KPI_DISPLAY_FOLDER] ' + CHAR(13) + CHAR(10) + 
' , [KPI_VALUE], [KPI_GOAL], [KPI_STATUS], [KPI_TREND], [KPI_STATUS_GRAPHIC], [KPI_TREND_GRAPHIC] ' + CHAR(13) + CHAR(10) + 
' , [KPI_WEIGHT], [KPI_CURRENT_TIME_MEMBER], [KPI_PARENT_KPI_NAME], [SCOPE], [ANNOTATIONS] ' + CHAR(13) + CHAR(10) + 
' FROM $SYSTEM.MDSCHEMA_KPIS'') K ' + CHAR(13) + CHAR(10) + 
'INNER JOIN OPENQUERY(' + @linkServer + ', ' + CHAR(13) + CHAR(10) + 
' ''SELECT [CATALOG_NAME], [BASE_CUBE_NAME], [CUBE_NAME] ' + CHAR(13) + CHAR(10) +
' FROM $SYSTEM.MDSCHEMA_CUBES ' + CHAR(13) + CHAR(10) +
' WHERE [CUBE_SOURCE] = 1'') C ' + CHAR(13) + CHAR(10) + 
'ON CAST(K.[CATALOG_NAME] AS nvarchar(4000)) = CAST(C.[CATALOG_NAME] AS nvarchar(4000)) ' + CHAR(13) + CHAR(10) + 
'AND CAST(K.[CUBE_NAME] AS nvarchar(4000)) = CAST(C.[CUBE_NAME] AS nvarchar(4000)) ' + CHAR(13) + CHAR(10);

 if (@excludePerspectives = 1)
 begin
  set @sql = @sql + 'AND C.[BASE_CUBE_NAME] IS NULL ' + CHAR(13) + CHAR(10);
 end

 set @sql = @sql + 
'WHERE (CAST(K.[CATALOG_NAME] AS nvarchar(4000)) = @catalog OR @catalog IS NULL) ' + CHAR(13) + CHAR(10) +
' AND (CAST(K.[CUBE_NAME] AS nvarchar(4000)) = @cube OR (@cube IS NULL AND LEFT(CAST(K.[CUBE_NAME] AS nvarchar(4000)),1) <> ''$'')) ' + CHAR(13) + CHAR(10) +
'ORDER BY CAST(K.[CATALOG_NAME] AS nvarchar(4000)), CASE WHEN C.[BASE_CUBE_NAME] IS NULL THEN CAST(C.[CUBE_NAME] AS nvarchar(4000)) ELSE CAST(C.[BASE_CUBE_NAME] AS nvarchar(4000)) END ' + CHAR(13) + CHAR(10) +
', CAST(K.[CUBE_NAME] AS nvarchar(4000)), CAST(K.[MEASUREGROUP_NAME] AS nvarchar(4000)),  CAST(K.[KPI_NAME] AS nvarchar(4000))';

 EXECUTE sp_executesql @sql, @parmDefinition, @catalog = @catalog, @cube = @cube;
END; 
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[spOLAP_GetMeasureGroups]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_EXECUTEsql @statement = N'CREATE PROCEDURE [Utility].[spOLAP_GetMeasureGroups] AS' 
END
GO
ALTER PROCEDURE [Utility].[spOLAP_GetMeasureGroups]
( @linkServer nvarchar(128)
 ,@excludePerspectives bit = 1
 ,@catalog nvarchar(255) = NULL
 ,@cube nvarchar(255) = NULL )
WITH EXECUTE AS OWNER 
AS
/* ============================================================================================
Proposito: Retorna grupos de medidas de un cubo de bases de datos OLAP.
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2017-04-10
Fecha actualizacion: 2020-07-15

Parametros:  
 @linkServer: Nombre del servidor vinculado a la base de datos en un servidor SQL Server Analysis Services. Ejemplo: PerdidasOLAP.
 @excludePerspectives: Indica si excluye perspectivas.
 @catalog: Nombre de la base de datos OLAP. Ejemplo: PerdidasOLAP.
 @cube: Nombre del cubo. Ejemplo: Perdidas.

Ejemplo:
EXECUTE [Utility].[spOLAP_GetMeasureGroups] 'PerdidasOLAP', 1, 'PerdidasOLAP', 'Perdidas';
EXECUTE [Utility].[spOLAP_GetMeasureGroups] 'PerdidasOLAP', 1, 'PerdidasOLAP';
EXECUTE [Utility].[spOLAP_GetMeasureGroups] 'PerdidasOLAP', 0;
============================================================================================ */
BEGIN
 SET NOCOUNT ON;
 Declare @sql nvarchar(max), @parmDefinition nvarchar(1024);

 set @sql = '';
 set @parmDefinition = N'@catalog nvarchar(255), @cube nvarchar(255)';

 set @sql = @sql +
'SELECT M.[CATALOG_NAME] ' + CHAR(13) + CHAR(10) +
', CASE WHEN C.[BASE_CUBE_NAME] IS NULL THEN C.[CUBE_NAME] ELSE C.[BASE_CUBE_NAME] END [BASE_CUBE_NAME] ' + CHAR(13) + CHAR(10) +
', M.[CUBE_NAME], M.[MEASUREGROUP_NAME], M.[DESCRIPTION], M.[IS_WRITE_ENABLED] ' + CHAR(13) + CHAR(10) + 
'FROM OPENQUERY(' + @linkServer + ', ' + CHAR(13) + CHAR(10) + 
' ''SELECT [CATALOG_NAME], [CUBE_NAME], [MEASUREGROUP_NAME], [DESCRIPTION], [IS_WRITE_ENABLED] ' + CHAR(13) + CHAR(10) + 
' FROM $SYSTEM.MDSCHEMA_MEASUREGROUPS'') M ' + CHAR(13) + CHAR(10) + 
'INNER JOIN OPENQUERY(' + @linkServer + ', ' + CHAR(13) + CHAR(10) + 
' ''SELECT [CATALOG_NAME], [BASE_CUBE_NAME], [CUBE_NAME] ' + CHAR(13) + CHAR(10) +
' FROM $SYSTEM.MDSCHEMA_CUBES ' + CHAR(13) + CHAR(10) +
' WHERE [CUBE_SOURCE] = 1'') C ' + CHAR(13) + CHAR(10) + 
'ON CAST(M.[CATALOG_NAME] AS nvarchar(4000)) = CAST(C.[CATALOG_NAME] AS nvarchar(4000)) ' + CHAR(13) + CHAR(10) + 
'AND CAST(M.[CUBE_NAME] AS nvarchar(4000)) = CAST(C.[CUBE_NAME] AS nvarchar(4000)) ' + CHAR(13) + CHAR(10);

 if (@excludePerspectives = 1)
 begin
  set @sql = @sql + 'AND C.[BASE_CUBE_NAME] IS NULL ' + CHAR(13) + CHAR(10);
 end

 set @sql = @sql + 
'WHERE (CAST(M.[CATALOG_NAME] AS nvarchar(4000)) = @catalog OR @catalog IS NULL) ' + CHAR(13) + CHAR(10) +
' AND (CAST(M.[CUBE_NAME] AS nvarchar(4000)) = @cube OR (@cube IS NULL AND LEFT(CAST(M.[CUBE_NAME] AS nvarchar(4000)),1) <> ''$'')) ' + CHAR(13) + CHAR(10) +
'ORDER BY CAST(M.[CATALOG_NAME] AS nvarchar(4000)), CASE WHEN C.[BASE_CUBE_NAME] IS NULL THEN CAST(C.[CUBE_NAME] AS nvarchar(4000)) ELSE CAST(C.[BASE_CUBE_NAME] AS nvarchar(4000)) END ' + CHAR(13) + CHAR(10) +
', CAST(M.[CUBE_NAME] AS nvarchar(4000)), CAST(M.[MEASUREGROUP_NAME] AS nvarchar(4000))';

 EXECUTE sp_executesql @sql, @parmDefinition, @catalog = @catalog, @cube = @cube;
END; 
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[spOLAP_GetMeasureGroupsDimensions]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_EXECUTEsql @statement = N'CREATE PROCEDURE [Utility].[spOLAP_GetMeasureGroupsDimensions] AS' 
END
GO
ALTER PROCEDURE [Utility].[spOLAP_GetMeasureGroupsDimensions]
( @linkServer nvarchar(128)
 ,@excludePerspectives bit = 1
 ,@catalog nvarchar(255) = NULL
 ,@cube nvarchar(255) = NULL 
 ,@measureGroup nvarchar(255) = NULL )
WITH EXECUTE AS OWNER 
AS
/* ============================================================================================
Proposito: Retorna una matriz la cual será pivoteada en un reporte. Une cada dimension con su grupo de medida relacionada para bases de datos OLAP.
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2017-04-10
Fecha actualizacion: 2020-07-15

Parametros:  
 @linkServer: Nombre del servidor vinculado a la base de datos en un servidor SQL Server Analysis Services. Ejemplo: PerdidasOLAP.
 @excludePerspectives: Indica si excluye perspectivas.
 @catalog: Nombre de la base de datos OLAP. Ejemplo: PerdidasOLAP.
 @cube: Nombre del cubo. Ejemplo: Perdidas.
 @measureGroup: Nombre de grupo de medidas. Ejemplo: Cartera

Ejemplo:
EXECUTE [Utility].[spOLAP_GetMeasureGroupsDimensions] 'PerdidasOLAP', 1, 'PerdidasOLAP', 'Perdidas', 'BalanceEnergetico';
EXECUTE [Utility].[spOLAP_GetMeasureGroupsDimensions] 'PerdidasOLAP', 1, 'PerdidasOLAP';
EXECUTE [Utility].[spOLAP_GetMeasureGroupsDimensions] 'PerdidasOLAP', 0;
============================================================================================ */
BEGIN
 SET NOCOUNT ON;
 Declare @sql nvarchar(max), @parmDefinition nvarchar(1024);

 set @sql = '';
 set @parmDefinition = N'@catalog nvarchar(255), @cube nvarchar(255), @measureGroup nvarchar(255)';

 set @sql = @sql +
'SELECT mgd.[CATALOG_NAME] ' + CHAR(13) + CHAR(10) +
', CASE WHEN C.[BASE_CUBE_NAME] IS NULL THEN C.[CUBE_NAME] ELSE C.[BASE_CUBE_NAME] END [BASE_CUBE_NAME] ' + CHAR(13) + CHAR(10) +
', mgd.[CUBE_NAME], mgd.[MEASUREGROUP_NAME], D.[DIMENSION_MASTER_NAME], D.[DIMENSION_NAME] ' + CHAR(13) + CHAR(10) + 
',mgd.[MEASUREGROUP_CARDINALITY], mgd.[DIMENSION_CARDINALITY] ' + CHAR(13) + CHAR(10) + 
',mgd.[DIMENSION_GRANULARITY], mgd.[DIMENSION_IS_VISIBLE], mgd.[DIMENSION_IS_FACT_DIMENSION] ' + CHAR(13) + CHAR(10) + 
'FROM OPENQUERY(' + @linkServer + ', ' + CHAR(13) + CHAR(10) + 
' ''SELECT [CATALOG_NAME], [CUBE_NAME], [MEASUREGROUP_NAME], [DIMENSION_UNIQUE_NAME], [MEASUREGROUP_CARDINALITY], [DIMENSION_CARDINALITY] ' + CHAR(13) + CHAR(10) + 
'  , [DIMENSION_GRANULARITY], [DIMENSION_IS_VISIBLE], [DIMENSION_IS_FACT_DIMENSION] ' + CHAR(13) + CHAR(10) + 
' FROM $SYSTEM.MDSCHEMA_MEASUREGROUP_DIMENSIONS ' + CHAR(13) + CHAR(10) + 
' WHERE [DIMENSION_IS_VISIBLE]'') mgd ' + CHAR(13) + CHAR(10) + 
'INNER JOIN OPENQUERY(' + @linkServer + ', ' + CHAR(13) + CHAR(10) + 
' ''SELECT [CATALOG_NAME], [CUBE_NAME], [DIMENSION_UNIQUE_NAME], [DIMENSION_MASTER_NAME], [DIMENSION_NAME] ' + CHAR(13) + CHAR(10) + 
' FROM $SYSTEM.MDSCHEMA_DIMENSIONS'') D ' + CHAR(13) + CHAR(10) + 
'ON CAST(mgd.[CATALOG_NAME] AS nvarchar(4000)) = CAST(D.[CATALOG_NAME] AS nvarchar(4000)) ' + CHAR(13) + CHAR(10) + 
'AND CAST(mgd.[CUBE_NAME] AS nvarchar(4000)) = CAST(D.[CUBE_NAME] AS nvarchar(4000)) ' + CHAR(13) + CHAR(10) + 
'AND CAST(mgd.[DIMENSION_UNIQUE_NAME] AS nvarchar(4000)) = CAST(D.[DIMENSION_UNIQUE_NAME] AS nvarchar(4000)) ' + CHAR(13) + CHAR(10) + 
'INNER JOIN OPENQUERY(' + @linkServer + ', ' + CHAR(13) + CHAR(10) + 
' ''SELECT [CATALOG_NAME], [BASE_CUBE_NAME], [CUBE_NAME] ' + CHAR(13) + CHAR(10) +
' FROM $SYSTEM.MDSCHEMA_CUBES ' + CHAR(13) + CHAR(10) +
' WHERE [CUBE_SOURCE] = 1'') C ' + CHAR(13) + CHAR(10) + 
'ON CAST(MGD.[CATALOG_NAME] AS nvarchar(4000)) = CAST(C.[CATALOG_NAME] AS nvarchar(4000)) ' + CHAR(13) + CHAR(10) + 
'AND CAST(MGD.[CUBE_NAME] AS nvarchar(4000)) = CAST(C.[CUBE_NAME] AS nvarchar(4000)) ' + CHAR(13) + CHAR(10);

 if (@excludePerspectives = 1)
 begin
  set @sql = @sql + 'AND C.[BASE_CUBE_NAME] IS NULL ' + CHAR(13) + CHAR(10);
 end

 set @sql = @sql + 
'WHERE (CAST(mgd.[CATALOG_NAME] AS nvarchar(4000))  = @catalog OR @catalog IS NULL) ' + CHAR(13) + CHAR(10) + 
'AND (CAST(mgd.[CUBE_NAME] AS nvarchar(4000)) = @cube OR (@cube IS NULL AND LEFT(CAST(mgd.[CUBE_NAME] AS nvarchar(4000)), 1) <> ''$'')) ' + CHAR(13) + CHAR(10) + 
'AND (CAST(mgd.[MEASUREGROUP_NAME] AS nvarchar(4000)) = @measureGroup OR @measureGroup IS NULL) ' + CHAR(13) + CHAR(10) + 
'ORDER BY CAST(mgd.[CATALOG_NAME] AS nvarchar(4000)), CASE WHEN C.[BASE_CUBE_NAME] IS NULL THEN CAST(C.[CUBE_NAME] AS nvarchar(4000)) ELSE CAST(C.[BASE_CUBE_NAME] AS nvarchar(4000)) END ' + CHAR(13) + CHAR(10) +
', CAST(mgd.[CUBE_NAME] AS nvarchar(4000)), CAST(mgd.[MEASUREGROUP_NAME] AS nvarchar(4000)) ' + CHAR(13) + CHAR(10) + 
', CAST(D.[DIMENSION_MASTER_NAME] AS nvarchar(4000)), CAST(mgd.[DIMENSION_UNIQUE_NAME] AS nvarchar(4000))';

 EXECUTE sp_executesql @sql, @parmDefinition, @catalog = @catalog, @cube = @cube, @measureGroup = @measureGroup;
END; 
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[spOLAP_GetMeasureGroupsDimensionsSpaceDiagram]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_EXECUTEsql @statement = N'CREATE PROCEDURE [Utility].[spOLAP_GetMeasureGroupsDimensionsSpaceDiagram] AS' 
END
GO
ALTER PROCEDURE [Utility].[spOLAP_GetMeasureGroupsDimensionsSpaceDiagram]
( @linkServer nvarchar(128)
 ,@excludePerspectives bit = 1
 ,@catalog nvarchar(255) = NULL
 ,@cube nvarchar(255) = NULL
 ,@measureGroup nvarchar(255) = NULL )
WITH EXECUTE AS OWNER 
AS
/* ============================================================================================
Proposito: Retorna dimensiones que son realacionadas a un grupo de medidas para bases de datos OLAP.
 Este es un reporte espacial en forma de estrella.
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2017-04-10
Fecha actualizacion: 2020-07-15

Parametros:  
 @linkServer: Nombre del servidor vinculado a la base de datos en un servidor SQL Server Analysis Services. Ejemplo: PerdidasOLAP.
 @excludePerspectives: Indica si excluye perspectivas.
 @catalog: Nombre de la base de datos OLAP. Ejemplo: PerdidasOLAP.
 @cube: Nombre del cubo. Ejemplo: Perdidas.
 @measureGroup: Nombre de grupo de medidas. Ejemplo: Cartera

Ejemplo:
EXECUTE [Utility].[spOLAP_GetMeasureGroupsDimensionsSpaceDiagram] 'PerdidasOLAP', 1, 'PerdidasOLAP', 'Perdidas', 'BalanceEnergetico';
EXECUTE [Utility].[spOLAP_GetMeasureGroupsDimensionsSpaceDiagram] 'PerdidasOLAP', 1, 'PerdidasOLAP', 'Perdidas', 'Cartera';
EXECUTE [Utility].[spOLAP_GetMeasureGroupsDimensionsSpaceDiagram] 'PerdidasOLAP', 1, 'PerdidasOLAP';
EXECUTE [Utility].[spOLAP_GetMeasureGroupsDimensionsSpaceDiagram] 'PerdidasOLAP', 0;
============================================================================================ */
BEGIN
 SET NOCOUNT ON;
 Declare @sql nvarchar(max), @parmDefinition nvarchar(1024);
 DECLARE @boxSize int, @stretch float;
 SET @boxSize = 250;
 SET @stretch = 1.4;

 set @sql = '';
 set @parmDefinition = N'@catalog nvarchar(255), @cube nvarchar(255), @measureGroup nvarchar(255), @boxSize int, @stretch float';

 set @sql = @sql +
';WITH BaseData AS ' + CHAR(13) + CHAR(10) + 
'( ' + CHAR(13) + CHAR(10) + 
' SELECT mgd.[Seq], mgd.[CATALOG_NAME] ' + CHAR(13) + CHAR(10) +
'  , CASE WHEN C.[BASE_CUBE_NAME] IS NULL THEN C.[CUBE_NAME] ELSE C.[BASE_CUBE_NAME] END [BASE_CUBE_NAME] ' + CHAR(13) + CHAR(10) +
'  , mgd.[CUBE_NAME], mgd.[MEASUREGROUP_NAME], D.[DIMENSION_MASTER_NAME], D.[DIMENSION_NAME] ' + CHAR(13) + CHAR(10) + 
'  , mgd.[MEASUREGROUP_CARDINALITY], mgd.[DIMENSION_CARDINALITY] ' + CHAR(13) + CHAR(10) +
'  , mgd.[DIMENSION_GRANULARITY], mgd.[DIMENSION_IS_VISIBLE], mgd.[DIMENSION_IS_FACT_DIMENSION] ' + CHAR(13) + CHAR(10) +
'  , D.[DESCRIPTION] AS [DIMENSION_DESCRIPTION] ' + CHAR(13) + CHAR(10) + 
'    FROM OPENQUERY(' + @linkServer + ', ' + CHAR(13) + CHAR(10) +  
'  ''SELECT [CATALOG_NAME] + [CUBE_NAME] + [MEASUREGROUP_NAME] + [DIMENSION_UNIQUE_NAME] AS Seq ' + CHAR(13) + CHAR(10) + 
'    , [CATALOG_NAME], [CUBE_NAME], [MEASUREGROUP_NAME], [MEASUREGROUP_CARDINALITY], [DIMENSION_UNIQUE_NAME] ' + CHAR(13) + CHAR(10) + 
'    , [DIMENSION_CARDINALITY], [DIMENSION_GRANULARITY], [DIMENSION_IS_VISIBLE], [DIMENSION_IS_FACT_DIMENSION] ' + CHAR(13) + CHAR(10) + 
'   FROM $SYSTEM.MDSCHEMA_MEASUREGROUP_DIMENSIONS ' + CHAR(13) + CHAR(10) + 
'   WHERE [DIMENSION_IS_VISIBLE]'') mgd ' + CHAR(13) + CHAR(10) + 
' INNER JOIN OPENQUERY(' + @linkServer + ', ' + CHAR(13) + CHAR(10) + 
'  ''SELECT [CATALOG_NAME], [CUBE_NAME], [DIMENSION_MASTER_NAME], [DIMENSION_NAME], [DIMENSION_UNIQUE_NAME], [DESCRIPTION] ' + CHAR(13) + CHAR(10) + 
'   FROM $SYSTEM.MDSCHEMA_DIMENSIONS ' + CHAR(13) + CHAR(10) +   
'   WHERE [DIMENSION_IS_VISIBLE]'') D ' + CHAR(13) + CHAR(10) +  
'  ON CAST(mgd.[CATALOG_NAME] AS nvarchar(4000)) = CAST(d.[CATALOG_NAME] AS nvarchar(4000)) ' + CHAR(13) + CHAR(10) + 
'  AND CAST(mgd.[CUBE_NAME] AS nvarchar(4000)) = CAST(d.[CUBE_NAME] AS nvarchar(4000)) ' + CHAR(13) + CHAR(10) + 
'  AND CAST(mgd.[DIMENSION_UNIQUE_NAME] AS nvarchar(4000)) = CAST(d.[DIMENSION_UNIQUE_NAME] AS nvarchar(4000)) ' + CHAR(13) + CHAR(10) + 
'INNER JOIN OPENQUERY(' + @linkServer + ', ' + CHAR(13) + CHAR(10) + 
' ''SELECT [CATALOG_NAME], [BASE_CUBE_NAME], [CUBE_NAME] ' + CHAR(13) + CHAR(10) +
' FROM $SYSTEM.MDSCHEMA_CUBES ' + CHAR(13) + CHAR(10) +
' WHERE [CUBE_SOURCE] = 1'') C ' + CHAR(13) + CHAR(10) + 
'ON CAST(MGD.[CATALOG_NAME] AS nvarchar(4000)) = CAST(C.[CATALOG_NAME] AS nvarchar(4000)) ' + CHAR(13) + CHAR(10) + 
'AND CAST(MGD.[CUBE_NAME] AS nvarchar(4000)) = CAST(C.[CUBE_NAME] AS nvarchar(4000)) ' + CHAR(13) + CHAR(10);

 if (@excludePerspectives = 1)
 begin
  set @sql = @sql + 'AND C.[BASE_CUBE_NAME] IS NULL ' + CHAR(13) + CHAR(10);
 end

 set @sql = @sql + 
'  WHERE (CAST(mgd.[CATALOG_NAME] AS nvarchar(4000)) = @catalog OR @catalog IS NULL)' + CHAR(13) + CHAR(10) + 
'   AND (CAST(mgd.[CUBE_NAME] AS nvarchar(4000)) = @cube OR (@cube IS NULL AND LEFT(CAST(mgd.[CUBE_NAME] AS nvarchar(4000)), 1) <> ''$''))' + CHAR(13) + CHAR(10) + 
'   AND (CAST(mgd.[MEASUREGROUP_NAME] AS nvarchar(4000)) = @measureGroup OR @measureGroup IS NULL) ' + CHAR(13) + CHAR(10) + 
') ' + CHAR(13) + CHAR(10) + 
', TotCount AS ' + CHAR(13) + CHAR(10) + 
'( ' + CHAR(13) + CHAR(10) + 
'  SELECT COUNT(*) AS RecCount FROM BaseData ' + CHAR(13) + CHAR(10) +  
') ' + CHAR(13) + CHAR(10) + 
', RecCount AS ' + CHAR(13) + CHAR(10) + 
'( ' + CHAR(13) + CHAR(10) + 
'  SELECT RANK() OVER (ORDER BY CAST(Seq AS nvarchar(4000))) AS RecID ' + CHAR(13) + CHAR(10) + 
'   , RecCount ' + CHAR(13) + CHAR(10) + 
'   , BaseData.* ' + CHAR(13) + CHAR(10) +  
'  FROM BaseData CROSS JOIN TotCount ' + CHAR(13) + CHAR(10) +  
') ' + CHAR(13) + CHAR(10) + 
', Angles AS ' + CHAR(13) + CHAR(10) + 
'( ' + CHAR(13) + CHAR(10) + 
'  SELECT * ' + CHAR(13) + CHAR(10) +  
'   , SIN(RADIANS((CAST(RecID AS FLOAT)/CAST(RecCount AS FLOAT)) * 360)) * 1000 AS x ' + CHAR(13) + CHAR(10) + 
'   , COS(RADIANS((CAST(RecID AS FLOAT)/CAST(RecCount AS FLOAT)) * 360)) * 1000 AS y ' + CHAR(13) + CHAR(10) + 
'  FROM RecCount ' + CHAR(13) + CHAR(10) + 
') ' + CHAR(13) + CHAR(10) + 
', Results AS ' + CHAR(13) + CHAR(10) + 
'( ' + CHAR(13) + CHAR(10) + 
'  SELECT * ' + CHAR(13) + CHAR(10) + 
'   , geometry::STGeomFromText(''POINT('' + CAST(y AS nvarchar(20)) + '' '' + CAST(x AS nvarchar(20))  + '')'', 4326) AS Posn ' + CHAR(13) + CHAR(10) + 
'   , geometry::STPolyFromText(''POLYGON(('' + ' + CHAR(13) + CHAR(10) +  
'       CAST((y*@stretch)+@boxSize AS nvarchar(20)) + '' '' + CAST(x+(@boxSize/2) AS nvarchar(20)) + ' + CHAR(13) + CHAR(10) + 
'     '', '' + CAST((y*@stretch)-@boxSize AS nvarchar(20)) + '' '' + CAST(x+(@boxSize/2) AS nvarchar(20)) + ' + CHAR(13) + CHAR(10) + 
'     '', '' + CAST((y*@stretch)-@boxSize AS nvarchar(20)) + '' '' + CAST(x-(@boxSize/2) AS nvarchar(20)) + ' + CHAR(13) + CHAR(10) + 
'     '', '' + CAST((y*@stretch)+@boxSize AS nvarchar(20)) + '' '' + CAST(x-(@boxSize/2) AS nvarchar(20)) + ' + CHAR(13) + CHAR(10) + 
'     '', '' + CAST((y*@stretch)+@boxSize AS nvarchar(20)) + '' '' + CAST(x+(@boxSize/2) AS nvarchar(20)) + ''))'', 0) AS Box ' + CHAR(13) + CHAR(10) + 
'   , geometry::STLineFromText(''LINESTRING (0 0, '' + CAST((y*@stretch) AS nvarchar(20)) + '' '' + CAST(x AS nvarchar(20))  + '')'', 0) AS Line ' + CHAR(13) + CHAR(10) + 
'   , geometry::STPolyFromText(''POLYGON (('' + ' + CHAR(13) + CHAR(10) +  
'       CAST(0+@boxSize AS nvarchar(20)) + '' '' + CAST(0+(@boxSize/2) AS nvarchar(20)) + ' + CHAR(13) + CHAR(10) + 
'     '', '' + CAST(0-@boxSize AS nvarchar(20)) + '' '' + CAST(0+(@boxSize/2) AS nvarchar(20)) + ' + CHAR(13) + CHAR(10) + 
'     '', '' + CAST(0-@boxSize AS nvarchar(20)) + '' '' + CAST(0-(@boxSize/2) AS nvarchar(20)) + ' + CHAR(13) + CHAR(10) + 
'     '', '' + CAST(0+@boxSize AS nvarchar(20)) + '' '' + CAST(0-(@boxSize/2) AS nvarchar(20)) + ' + CHAR(13) + CHAR(10) + 
'     '', '' + CAST(0+@boxSize AS nvarchar(20)) + '' '' + CAST(0+(@boxSize/2) AS nvarchar(20)) + ''))'', 0) AS CenterBox ' + CHAR(13) + CHAR(10) + 
'   FROM Angles ' + CHAR(13) + CHAR(10) + 
') ' + CHAR(13) + CHAR(10) + 
'SELECT [RecID], [RecCount], [Seq] ' + CHAR(13) + CHAR(10) +
', [CATALOG_NAME], [BASE_CUBE_NAME], [CUBE_NAME], [MEASUREGROUP_NAME], [DIMENSION_MASTER_NAME], [DIMENSION_NAME] ' + CHAR(13) + CHAR(10) + 
', [MEASUREGROUP_CARDINALITY], [DIMENSION_CARDINALITY], [DIMENSION_GRANULARITY], [DIMENSION_IS_VISIBLE], [DIMENSION_IS_FACT_DIMENSION] ' + CHAR(13) + CHAR(10) + 
', [x], [y], [Posn], [Box], [Line], [CenterBox] ' + CHAR(13) + CHAR(10) +  
'FROM Results ' + CHAR(13) + CHAR(10) +
'ORDER BY CAST([CATALOG_NAME] AS nvarchar(4000)), CASE WHEN [BASE_CUBE_NAME] IS NULL THEN CAST([CUBE_NAME] AS nvarchar(4000)) ELSE CAST([BASE_CUBE_NAME] AS nvarchar(4000)) END ' + CHAR(13) + CHAR(10) +
', CAST([CUBE_NAME] AS nvarchar(4000)), CAST([MEASUREGROUP_NAME] AS nvarchar(4000)) ' + CHAR(13) + CHAR(10) + 
', CAST([DIMENSION_MASTER_NAME] AS nvarchar(4000)), CAST([DIMENSION_NAME] AS nvarchar(4000))';

 EXECUTE sp_executesql @sql, @parmDefinition, @catalog = @catalog, @cube = @cube, @measureGroup = @measureGroup, @boxSize = @boxSize, @stretch = @stretch;
END; 
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[spOLAP_GetMeasures]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_EXECUTEsql @statement = N'CREATE PROCEDURE [Utility].[spOLAP_GetMeasures] AS' 
END
GO
ALTER PROCEDURE [Utility].[spOLAP_GetMeasures]
( @linkServer nvarchar(128)
 ,@excludePerspectives bit = 1
 ,@catalog nvarchar(255) = NULL
 ,@cube nvarchar(255) = NULL
 ,@measureGroup nvarchar(255) = NULL )
WITH EXECUTE AS OWNER 
AS
/* ============================================================================================
Proposito: Retorna medidas de un grupo de medidas de bases de datos OLAP.
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2017-04-10
Fecha actualizacion: 2020-07-15

Parametros:  
 @linkServer: Nombre del servidor vinculado a la base de datos en un servidor SQL Server Analysis Services. Ejemplo: PerdidasOLAP.
 @excludePerspectives: Indica si excluye perspectivas.
 @catalog: Nombre de la base de datos OLAP. Ejemplo: PerdidasOLAP.
 @cube: Nombre del cubo. Ejemplo: Perdidas.
 @measureGroup: Nombre de grupo de medidas. Ejemplo: Cartera

Ejemplo:
EXECUTE [Utility].[spOLAP_GetMeasures] 'PerdidasOLAP', 1, 'PerdidasOLAP', 'Perdidas', 'Cartera';
EXECUTE [Utility].[spOLAP_GetMeasures] 'PerdidasOLAP', 1, 'PerdidasOLAP';
EXECUTE [Utility].[spOLAP_GetMeasures] 'PerdidasOLAP', 0;
============================================================================================ */
BEGIN
 SET NOCOUNT ON;
 Declare @sql nvarchar(max), @parmDefinition nvarchar(1024);

 set @sql = '';
 set @parmDefinition = N'@catalog nvarchar(255), @cube nvarchar(255), @measureGroup nvarchar(255)';

 set @sql = @sql +
'SELECT M.[CATALOG_NAME] ' + CHAR(13) + CHAR(10) + 
', CASE WHEN C.[BASE_CUBE_NAME] IS NULL THEN C.[CUBE_NAME] ELSE C.[BASE_CUBE_NAME] END [BASE_CUBE_NAME] ' + CHAR(13) + CHAR(10) +
', M.[CUBE_NAME], M.[MEASUREGROUP_NAME],  M.[MEASURE_NAME] ' + CHAR(13) + CHAR(10) + 
', CASE WHEN M.[MEASURE_AGGREGATOR] = 127 THEN ''Calculada'' ELSE ''Natural'' END [MEASURE_TYPE] ' + CHAR(13) + CHAR(10) +  
', CASE M.[MEASURE_AGGREGATOR] ' + CHAR(13) + CHAR(10) +  
'       WHEN 1 THEN ''Sum'' ' + CHAR(13) + CHAR(10) +  
'       WHEN 2 THEN ''Count'' ' + CHAR(13) + CHAR(10) +  
'       WHEN 3 THEN ''Min'' ' + CHAR(13) + CHAR(10) +  
'       WHEN 4 THEN ''Max'' ' + CHAR(13) + CHAR(10) +  
'       WHEN 8 THEN ''DistinctCount'' ' + CHAR(13) + CHAR(10) +  
'       WHEN 9 THEN ''None'' ' + CHAR(13) + CHAR(10) +  
'       WHEN 10 THEN ''AverageOfChildren'' ' + CHAR(13) + CHAR(10) +  
'       WHEN 11 THEN ''FirstChild'' ' + CHAR(13) + CHAR(10) +  
'       WHEN 12 THEN ''LastChild'' ' + CHAR(13) + CHAR(10) +  
'       WHEN 13 THEN ''FirstNonEmpty'' ' + CHAR(13) + CHAR(10) +  
'       WHEN 14 THEN ''LastNonEmpty'' ' + CHAR(13) + CHAR(10) +  
'       WHEN 15 THEN ''ByAccount'' ' + CHAR(13) + CHAR(10) +  
'       WHEN 127 THEN ''Calculated'' ' + CHAR(13) + CHAR(10) +  
'       ELSE NULL END AS [AGGREGATE_FUNCTION] ' + CHAR(13) + CHAR(10) +  
', M.[EXPRESSION], M.[MEASURE_DISPLAY_FOLDER], M.[DEFAULT_FORMAT_STRING] ' + CHAR(13) + CHAR(10) + 
', D.[DATA_TYPE_NAME], M.[MEASURE_IS_VISIBLE], M.[DESCRIPTION] ' + CHAR(13) + CHAR(10) +  
'FROM OPENQUERY(' + @linkServer + ', ' + CHAR(13) + CHAR(10) + 
' ''SELECT [CATALOG_NAME], [CUBE_NAME], [MEASUREGROUP_NAME],  [MEASURE_NAME], [DESCRIPTION] ' + CHAR(13) + CHAR(10) + 
' , [MEASURE_DISPLAY_FOLDER], [DEFAULT_FORMAT_STRING] ' + CHAR(13) + CHAR(10) +  
' , [MEASURE_AGGREGATOR], [DATA_TYPE], [EXPRESSION], [NUMERIC_PRECISION], [MEASURE_IS_VISIBLE] ' + CHAR(13) + CHAR(10) + 
' FROM $SYSTEM.MDSCHEMA_MEASURES ' + CHAR(13) + CHAR(10) +  
' /* WHERE [MEASURE_IS_VISIBLE] */ '') M' + CHAR(13) + CHAR(10) + 
'INNER JOIN OPENQUERY(' + @linkServer + ', ' + CHAR(13) + CHAR(10) +
' ''SELECT [DATA_TYPE], [TYPE_NAME] AS [DATA_TYPE_NAME], [COLUMN_SIZE] ' + CHAR(13) + CHAR(10) +
' FROM $SYSTEM.DBSCHEMA_PROVIDER_TYPES'') D  ' + CHAR(13) + CHAR(10) +
'ON D.[DATA_TYPE] = M.[DATA_TYPE] ' + CHAR(13) + CHAR(10) +
'INNER JOIN OPENQUERY(' + @linkServer + ', ' + CHAR(13) + CHAR(10) + 
' ''SELECT [CATALOG_NAME], [BASE_CUBE_NAME], [CUBE_NAME] ' + CHAR(13) + CHAR(10) +
' FROM $SYSTEM.MDSCHEMA_CUBES ' + CHAR(13) + CHAR(10) +
' WHERE [CUBE_SOURCE] = 1'') C ' + CHAR(13) + CHAR(10) + 
'ON CAST(M.[CATALOG_NAME] AS nvarchar(4000)) = CAST(C.[CATALOG_NAME] AS nvarchar(4000)) ' + CHAR(13) + CHAR(10) + 
'AND CAST(M.[CUBE_NAME] AS nvarchar(4000)) = CAST(C.[CUBE_NAME] AS nvarchar(4000)) ' + CHAR(13) + CHAR(10);

 if (@excludePerspectives = 1)
 begin
  set @sql = @sql + 'AND C.[BASE_CUBE_NAME] IS NULL ' + CHAR(13) + CHAR(10);
 end

 set @sql = @sql + 
'WHERE (CAST(M.[CATALOG_NAME] AS nvarchar(4000)) = @catalog OR @catalog IS NULL)  ' + CHAR(13) + CHAR(10) +
' AND (CAST(M.[CUBE_NAME] AS nvarchar(4000)) = @cube OR (@cube IS NULL AND LEFT(CAST(M.[CUBE_NAME] AS nvarchar(4000)),1) <> ''$'')) ' + CHAR(13) + CHAR(10) +
' AND (CAST(M.[MEASUREGROUP_NAME] AS nvarchar(4000)) = @measureGroup OR @measureGroup IS NULL) ' + CHAR(13) + CHAR(10) +
'ORDER BY CAST(M.[CATALOG_NAME] AS nvarchar(4000)), CAST(M.[CUBE_NAME] AS nvarchar(4000)), CAST(M.[MEASUREGROUP_NAME] AS nvarchar(4000)) ' + CHAR(13) + CHAR(10) +
', CASE WHEN M.[MEASURE_AGGREGATOR] = 127 THEN 1 ELSE 0 END, CAST(M.[MEASURE_NAME] AS nvarchar(4000))';

 EXECUTE sp_executesql @sql, @parmDefinition, @catalog = @catalog, @cube = @cube, @measureGroup = @measureGroup;
END; 
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[spOLAP_GetPerspectives]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_EXECUTEsql @statement = N'CREATE PROCEDURE [Utility].[spOLAP_GetPerspectives] AS' 
END
GO
ALTER PROCEDURE [Utility].[spOLAP_GetPerspectives]
(
   @linkServer nvarchar(128)
  ,@catalog nvarchar(255) = NULL
)
WITH EXECUTE AS OWNER 
AS
/* ============================================================================================
Proposito: Retorna las perspectivas de cubos de una base de datos OLAP.
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2017-04-10
Fecha actualizacion: 2020-07-15

Parametros:  
 @linkServer: Nombre del servidor vinculado a la base de datos en un servidor SQL Server Analysis Services. Ejemplo: PerdidasOLAP.
 @catalog: Nombre de la base de datos OLAP. Ejemplo: PerdidasOLAP.

Ejemplo:
EXECUTE [Utility].[spOLAP_GetPerspectives] 'PerdidasOLAP', 'PerdidasOLAP'; 
EXECUTE [Utility].[spOLAP_GetPerspectives] 'PerdidasOLAP'; 
============================================================================================ */
BEGIN
 SET NOCOUNT ON;
 Declare @sql nvarchar(max), @parmDefinition nvarchar(1024);

 set @sql = '';
 set @parmDefinition = N'@catalog nvarchar(255)';

 set @sql = @sql +
'SELECT [CATALOG_NAME], CASE WHEN [BASE_CUBE_NAME] IS NULL THEN [CUBE_NAME] ELSE [BASE_CUBE_NAME] END [BASE_CUBE_NAME] ' + CHAR(13) + CHAR(10) + 
', [CUBE_NAME] As [PERSPECTIVE_NAME], [DESCRIPTION] ' + CHAR(13) + CHAR(10) + 
'FROM OPENQUERY(' + @linkServer + ', ' + CHAR(13) + CHAR(10) + 
' ''SELECT [CATALOG_NAME], [BASE_CUBE_NAME], [CUBE_NAME], [DESCRIPTION] ' + CHAR(13) + CHAR(10) +
' FROM $system.MDSchema_Cubes ' + CHAR(13) + CHAR(10) +
' WHERE [CUBE_SOURCE] = 1'') ' + CHAR(13) + CHAR(10) + 
'WHERE (CAST([CATALOG_NAME] AS nvarchar(4000)) = @catalog OR @catalog IS NULL) ' + CHAR(13) + CHAR(10) + 
'ORDER BY CAST([CATALOG_NAME] AS nvarchar(4000)) ' + CHAR(13) + CHAR(10) + 
', CASE WHEN [BASE_CUBE_NAME] IS NULL THEN  CAST([CUBE_NAME] AS nvarchar(4000)) ELSE CAST([BASE_CUBE_NAME] AS nvarchar(4000)) END ' + CHAR(13) + CHAR(10) + 
', CAST([CUBE_NAME] AS nvarchar(4000))';

 EXECUTE sp_executesql @sql, @parmDefinition, @catalog = @catalog;
END; 
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[spOLAP_GetSearchObject]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_EXECUTEsql @statement = N'CREATE PROCEDURE [Utility].[spOLAP_GetSearchObject] AS' 
END
GO
ALTER PROCEDURE [Utility].[spOLAP_GetSearchObject] 
( @linkServer nvarchar(128)
 ,@search nvarchar(255)
 ,@catalog nvarchar(255) = NULL
 ,@cube nvarchar(255) = NULL )
WITH EXECUTE AS OWNER 
AS
/* ============================================================================================
Proposito: Busca un objeto (cube, measure group, measure, dimension, attribute, hierarchy, KPI, etc.) de bases de datos OLAP.
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2017-04-10
Fecha actualizacion: 2020-07-15

Parametros:  
 @linkServer: Nombre del servidor vinculado a la base de datos en un servidor SQL Server Analysis Services. Ejemplo: PerdidasOLAP.
 @search: Nombre o descripcipon de un tipo de objeto (cube, measure group, measure, dimension, attribute, hierarchy, KPI, etc.) 
  por el cual filtar los datos. Ejemplo: DimCliente.
 @catalog: Nombre de la base de datos OLAP. Ejemplo: PerdidasOLAP.
 @cube: Nombre del cubo. Ejemplo: Perdidas.

Ejemplo:
EXECUTE [Utility].[spOLAP_GetSearchObject] 'PerdidasOLAP', 'BalanceEnergetico', 'PerdidasOLAP', 'Perdidas';
EXECUTE [Utility].[spOLAP_GetSearchObject] 'PerdidasOLAP', 'BalEne_Consumo entrada', 'PerdidasOLAP';
EXECUTE [Utility].[spOLAP_GetSearchObject] 'PerdidasOLAP', 'Fact_Indice recaudo', 'PerdidasOLAP';
EXECUTE [Utility].[spOLAP_GetSearchObject] 'PerdidasOLAP', 'DimCliente';
============================================================================================ */
begin
 SET NOCOUNT ON;
 Declare @sql nvarchar(max), @parmDefinition nvarchar(1024);
 
 set @sql = '';
 set @parmDefinition = N'@search nvarchar(255), @catalog nvarchar(255), @cube nvarchar(255)';

 set @sql = @sql +
'WITH [CTE_OLAP] AS ' + CHAR(13) + CHAR(10) +
'( ' + CHAR(13) + CHAR(10) +
'   --Cubes ' + CHAR(13) + CHAR(10) +
'    SELECT CAST(''Cube'' AS nvarchar(20)) AS [Type] ' + CHAR(13) + CHAR(10) +
'            , CAST(CATALOG_NAME AS nvarchar(4000)) AS [Catalog] ' + CHAR(13) + CHAR(10) +
'            , CAST(CUBE_NAME AS nvarchar(4000)) AS [Cube] ' + CHAR(13) + CHAR(10) +
'            , CAST(CUBE_NAME AS nvarchar(4000)) AS [Name] ' + CHAR(13) + CHAR(10) +
'            , CAST(DESCRIPTION AS nvarchar(4000)) AS [Description] ' + CHAR(13) + CHAR(10) +
'            , CAST(CUBE_NAME AS nvarchar(4000)) AS [Link] ' + CHAR(13) + CHAR(10) +
'            FROM OPENQUERY(' + @linkServer + ', ''SELECT [CATALOG_NAME], [CUBE_NAME], [DESCRIPTION]  ' + CHAR(13) + CHAR(10) +
'            FROM $SYSTEM.MDSCHEMA_CUBES  ' + CHAR(13) + CHAR(10) +
'            WHERE CUBE_SOURCE = 1'') ' + CHAR(13) + CHAR(10) +
'        WHERE (CAST([CATALOG_NAME] AS nvarchar(4000)) = @catalog OR @catalog IS NULL) ' + CHAR(13) + CHAR(10) +
'    UNION ALL ' + CHAR(13) + CHAR(10) +
'    --Dimensions ' + CHAR(13) + CHAR(10) +
'    SELECT CAST(''Dimension'' AS nvarchar(20)) AS [Type] ' + CHAR(13) + CHAR(10) +
'            , CAST(CATALOG_NAME AS nvarchar(4000)) AS [Catalog] ' + CHAR(13) + CHAR(10) +
'            , CAST(CUBE_NAME AS nvarchar(4000)) AS [Cube] ' + CHAR(13) + CHAR(10) +
'            , CAST(DIMENSION_NAME AS nvarchar(4000)) AS [Name] ' + CHAR(13) + CHAR(10) +
'            , CAST(DESCRIPTION AS nvarchar(4000)) AS [Description] ' + CHAR(13) + CHAR(10) +
'            , CAST(DIMENSION_UNIQUE_NAME AS nvarchar(4000)) AS [Link] ' + CHAR(13) + CHAR(10) +
'    FROM OPENQUERY(' + @linkServer + ', ''SELECT [CATALOG_NAME], [CUBE_NAME], [DIMENSION_NAME], [DESCRIPTION], [DIMENSION_UNIQUE_NAME] ' + CHAR(13) + CHAR(10) + 
'                FROM $SYSTEM.MDSCHEMA_DIMENSIONS ' + CHAR(13) + CHAR(10) +  
'                WHERE [DIMENSION_IS_VISIBLE]'') ' + CHAR(13) + CHAR(10) +
'        WHERE  (CAST([CATALOG_NAME] AS nvarchar(4000)) = @catalog OR @catalog IS NULL) ' + CHAR(13) + CHAR(10) +
'        AND (CAST([CUBE_NAME] AS nvarchar(4000))               = @cube OR @cube IS NULL) ' + CHAR(13) + CHAR(10) +
'        AND LEFT(CAST(CUBE_NAME AS nvarchar(4000)),1) <> ''$'' --Filter out dimensions not in a cube ' + CHAR(13) + CHAR(10) +            
'        UNION ALL ' + CHAR(13) + CHAR(10) +
'    --Attributes ' + CHAR(13) + CHAR(10) +
'    SELECT CAST(''Attribute'' AS nvarchar(20)) AS [Type] ' + CHAR(13) + CHAR(10) +
'            , CAST(CATALOG_NAME AS nvarchar(4000)) AS [Catalog] ' + CHAR(13) + CHAR(10) +
'            , CAST(CUBE_NAME AS nvarchar(4000)) AS [Cube] ' + CHAR(13) + CHAR(10) +
'            , CAST(LEVEL_CAPTION AS nvarchar(4000)) AS [Name] ' + CHAR(13) + CHAR(10) +
'            , CAST(DESCRIPTION AS nvarchar(4000)) AS [Description] ' + CHAR(13) + CHAR(10) +
'            , CAST(DIMENSION_UNIQUE_NAME AS nvarchar(4000)) AS [Link] ' + CHAR(13) + CHAR(10) +
'    FROM OPENQUERY(' + @linkServer + ', ''SELECT [CATALOG_NAME], [CUBE_NAME], [LEVEL_CAPTION], [DESCRIPTION], [DIMENSION_UNIQUE_NAME] ' + CHAR(13) + CHAR(10) + 
'                FROM $SYSTEM.MDSCHEMA_LEVELS ' + CHAR(13) + CHAR(10) +
'                WHERE [LEVEL_NUMBER]>0 ' + CHAR(13) + CHAR(10) + 
'                AND [LEVEL_IS_VISIBLE]'') ' + CHAR(13) + CHAR(10) +
'        WHERE  (CAST([CATALOG_NAME] AS nvarchar(4000)) = @catalog OR @catalog IS NULL) ' + CHAR(13) + CHAR(10) +
'        AND (CAST([CUBE_NAME] AS nvarchar(4000)) = @cube OR @cube IS NULL) ' + CHAR(13) + CHAR(10) +
'        AND LEFT(CAST(CUBE_NAME AS nvarchar(4000)), 1) <>''$'' --Filter out dimensions not in a cube ' + CHAR(13) + CHAR(10) +                        
'        UNION ALL ' + CHAR(13) + CHAR(10) +
'    --Measure Groups ' + CHAR(13) + CHAR(10) +
'    SELECT CAST(''Measure Group'' AS nvarchar(20)) AS [Type] ' + CHAR(13) + CHAR(10) +
'            , CAST(CATALOG_NAME AS nvarchar(4000)) AS [Catalog] ' + CHAR(13) + CHAR(10) +
'            , CAST(CUBE_NAME AS nvarchar(4000)) AS [Cube] ' + CHAR(13) + CHAR(10) +
'            , CAST(MEASUREGROUP_NAME AS nvarchar(4000)) AS [Name] ' + CHAR(13) + CHAR(10) +
'            , CAST(DESCRIPTION AS nvarchar(4000)) AS [Description] ' + CHAR(13) + CHAR(10) +
'            , CAST(MEASUREGROUP_NAME AS nvarchar(4000)) AS [Link] ' + CHAR(13) + CHAR(10) +
'    FROM OPENQUERY(' + @linkServer + ', ''SELECT [CATALOG_NAME], [CUBE_NAME], [MEASUREGROUP_NAME], [DESCRIPTION] ' + CHAR(13) + CHAR(10) + 
'                FROM $SYSTEM.MDSCHEMA_MEASUREGROUPS'') ' + CHAR(13) + CHAR(10) +
'        WHERE  (CAST([CATALOG_NAME] AS nvarchar(4000)) = @catalog OR @catalog IS NULL) ' + CHAR(13) + CHAR(10) +
'        AND (CAST([CUBE_NAME] AS nvarchar(4000)) = @cube OR @cube IS NULL) ' + CHAR(13) + CHAR(10) +
'        AND LEFT(CAST(CUBE_NAME AS nvarchar(4000)),1) <> ''$'' --Filter out dimensions not in a cube ' + CHAR(13) + CHAR(10) +
'        UNION ALL ' + CHAR(13) + CHAR(10) +
'    --Measures ' + CHAR(13) + CHAR(10) +
'    SELECT CAST(''Measure'' AS nvarchar(20)) AS [Type] ' + CHAR(13) + CHAR(10) +
'            , CAST(CATALOG_NAME AS nvarchar(4000)) AS [Catalog] ' + CHAR(13) + CHAR(10) +
'            , CAST(CUBE_NAME AS nvarchar(4000)) AS [Cube] ' + CHAR(13) + CHAR(10) +
'            , CAST(MEASURE_NAME AS nvarchar(4000)) AS [Name] ' + CHAR(13) + CHAR(10) +
'            , CAST(DESCRIPTION AS nvarchar(4000)) AS [Description] ' + CHAR(13) + CHAR(10) +
'            , CAST(MEASUREGROUP_NAME AS nvarchar(4000)) AS [Link] ' + CHAR(13) + CHAR(10) +
'    FROM OPENQUERY(' + @linkServer + ', ''SELECT [CATALOG_NAME], [CUBE_NAME], [MEASURE_NAME], [DESCRIPTION], [MEASUREGROUP_NAME] ' + CHAR(13) + CHAR(10) + 
'                FROM $SYSTEM.MDSCHEMA_MEASURES ' + CHAR(13) + CHAR(10) + 
'                WHERE [MEASURE_IS_VISIBLE]'') ' + CHAR(13) + CHAR(10) +
'        WHERE  (CAST([CATALOG_NAME] AS nvarchar(4000)) = @catalog OR @catalog IS NULL) ' + CHAR(13) + CHAR(10) +
'        AND (CAST([CUBE_NAME] AS nvarchar(4000)) = @cube OR @cube IS NULL) ' + CHAR(13) + CHAR(10) +
'        AND LEFT(CAST(CUBE_NAME AS nvarchar(4000)), 1) <> ''$'' --Filter out dimensions not in a cube ' + CHAR(13) + CHAR(10) +
' ) ' + CHAR(13) + CHAR(10) +
' SELECT * ' + CHAR(13) + CHAR(10) +
' FROM [CTE_OLAP] ' + CHAR(13) + CHAR(10) +
' WHERE @search <> '''' AND ([Name] LIKE ''%'' + @search + ''%'' OR [Description] LIKE ''%'' + @search + ''%'')';

 EXECUTE sp_executesql @sql, @parmDefinition, @search = @search, @catalog = @catalog, @cube = @cube;
end;
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[spOLAP_GetMiningModel]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_EXECUTEsql @statement = N'CREATE PROCEDURE [Utility].[spOLAP_GetMiningModel] AS' 
END
GO
ALTER PROCEDURE [Utility].[spOLAP_GetMiningModel]
( @linkServer nvarchar(128)
 ,@catalog nvarchar(255) = NULL
 ,@miningStructure nvarchar(255) = NULL 
 ,@miningModel nvarchar(255) = NULL )
WITH EXECUTE AS OWNER 
AS
/* ============================================================================================
Proposito: Retorna modelo de mineria de datos para bases de datos OLAP.
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2017-04-10
Fecha actualizacion: 2020-07-15

Parametros:  
 @linkServer: Nombre del servidor vinculado a la base de datos en un servidor SQL Server Analysis Services. Ejemplo: PerdidasOLAP.
 @catalog: Nombre de la base de datos OLAP. Ejemplo: PerdidasOLAP.
 @miningStructure: Nombre de estructura de minería de datos. Ejemplo: VisitasRevision.
 @miningModel: Nombre de modelo de mineria de datos. Ejemplo: DT_Perdidas.

Ejemplo:
EXECUTE [Utility].[spOLAP_GetMiningModel] 'PerdidasOLAP', 'PerdidasOLAP', 'VisitasRevision', 'DT_Perdidas';
EXECUTE [Utility].[spOLAP_GetMiningModel] 'PerdidasOLAP', 'PerdidasOLAP', 'VisitasRevision';
EXECUTE [Utility].[spOLAP_GetMiningModel] 'PerdidasOLAP';
============================================================================================ */
BEGIN
 SET NOCOUNT ON;
 Declare @sql nvarchar(max), @parmDefinition nvarchar(1024);

 set @sql = '';
 set @parmDefinition = N'@catalog nvarchar(255), @miningStructure nvarchar(255), @miningModel nvarchar(255)';

 set @sql = @sql +
'SELECT [MODEL_CATALOG], [MINING_STRUCTURE], [MODEL_NAME] ' + CHAR(13) + CHAR(10) + 
', CASE CONVERT(INT,[SERVICE_TYPE_ID]) ' + CHAR(13) + CHAR(10) +  
'   WHEN 1 THEN ''Classification'' ' + CHAR(13) + CHAR(10) + 
'   WHEN 2 THEN ''Clustering'' ' + CHAR(13) + CHAR(10) + 
'   WHEN 10 THEN ''Sequence'' ' + CHAR(13) + CHAR(10) + 
'   WHEN 17 THEN ''Time-Series'' ' + CHAR(13) + CHAR(10) + 
'   WHEN 18 THEN ''Sequence Clustering'' ' + CHAR(13) + CHAR(10) + 
'   ELSE NULL END AS [ALGORITHM_TYPE] ' + CHAR(13) + CHAR(10) + 
', [SERVICE_NAME] AS [ALGORITHM_NAME], [PREDICTION_ENTITY] ' + CHAR(13) + CHAR(10) + 
', CONVERT(BIT,[IS_POPULATED]) AS [IS_POPULATED] ' + CHAR(13) + CHAR(10) + 
', CONVERT(nvarchar(MAX),[MINING_PARAMETERS]) AS [MINING_PARAMETERS] ' + CHAR(13) + CHAR(10) + 
', [MSOLAP_IS_DRILLTHROUGH_ENABLED],[FILTER] ' + CHAR(13) + CHAR(10) + 
', [DESCRIPTION] ' + CHAR(13) + CHAR(10) + 
', CONVERT(INT,[TRAINING_SET_SIZE]) AS [TRAINING_SET_ROWCOUNT] ' + CHAR(13) + CHAR(10) + 
', CONVERT(SMALLDATETIME,[DATE_CREATED]) AS [DATE_CREATED] ' + CHAR(13) + CHAR(10) + 
', CONVERT(SMALLDATETIME,[DATE_MODIFIED]) AS [DATE_MODIFIED] ' + CHAR(13) + CHAR(10) + 
', CONVERT(SMALLDATETIME,[LAST_PROCESSED]) AS [LAST_PROCESSED] ' + CHAR(13) + CHAR(10) + 
'FROM OPENQUERY(' + @linkServer + ', ' + CHAR(13) + CHAR(10) + 
' ''SELECT [MODEL_CATALOG], [MINING_STRUCTURE], [MODEL_NAME], [SERVICE_TYPE_ID], [SERVICE_NAME], [PREDICTION_ENTITY], [IS_POPULATED] ' + CHAR(13) + CHAR(10) + 
' ,[MINING_PARAMETERS], [MSOLAP_IS_DRILLTHROUGH_ENABLED], [DESCRIPTION], [FILTER], [TRAINING_SET_SIZE], [DATE_CREATED], [DATE_MODIFIED], [LAST_PROCESSED]' + CHAR(13) + CHAR(10) + 
' FROM $SYSTEM.DMSCHEMA_MINING_MODELS'') ' + CHAR(13) + CHAR(10) + 
'WHERE (CAST([MODEL_CATALOG] AS nvarchar(4000))  = @catalog OR @catalog IS NULL) ' + CHAR(13) + CHAR(10) + 
'AND (CAST([MINING_STRUCTURE] AS nvarchar(4000)) = @miningStructure OR @miningStructure IS NULL) ' + CHAR(13) + CHAR(10) + 
'AND (CAST([MODEL_NAME] AS nvarchar(4000)) = @miningModel OR @miningModel IS NULL) ' + CHAR(13) + CHAR(10) + 
'ORDER BY CAST([MODEL_CATALOG] AS nvarchar(4000)), CAST([MINING_STRUCTURE] AS nvarchar(4000)), CAST([MODEL_NAME] AS nvarchar(4000))';

 EXECUTE sp_executesql @sql, @parmDefinition, @catalog = @catalog, @miningStructure = @miningStructure, @miningModel = @miningModel;
END; 
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[spOLAP_GetMiningModelColumns]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_EXECUTEsql @statement = N'CREATE PROCEDURE [Utility].[spOLAP_GetMiningModelColumns] AS' 
END
GO
ALTER PROCEDURE [Utility].[spOLAP_GetMiningModelColumns]
( @linkServer nvarchar(128)
 ,@catalog nvarchar(255) = NULL
 ,@miningModel nvarchar(255) = NULL )
WITH EXECUTE AS OWNER 
AS
/* ============================================================================================
Proposito: Retorna columnas de modelo de mineria de datos para bases de datos OLAP.
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2017-04-10
Fecha actualizacion: 2020-07-15

Parametros:  
 @linkServer: Nombre del servidor vinculado a la base de datos en un servidor SQL Server Analysis Services. Ejemplo: PerdidasOLAP.
 @catalog: Nombre de la base de datos OLAP. Ejemplo: PerdidasOLAP.
 @miningModel: Nombre de modelo de mineria de datos. Ejemplo: DT_Perdidas.

Ejemplo:
EXECUTE [Utility].[spOLAP_GetMiningModelColumns] 'PerdidasOLAP', 'PerdidasOLAP', 'DT_Perdidas';
EXECUTE [Utility].[spOLAP_GetMiningModelColumns] 'PerdidasOLAP';
============================================================================================ */
BEGIN
 SET NOCOUNT ON;
 Declare @sql nvarchar(max), @parmDefinition nvarchar(1024);

 set @sql = '';
 set @parmDefinition = N'@catalog nvarchar(255), @miningModel nvarchar(255)';

 set @sql = @sql +
'SELECT M.[MODEL_CATALOG], M.[MODEL_NAME], M.[COLUMN_NAME], D.[DATA_TYPE_NAME], M.[CONTENT_TYPE], M.[DESCRIPTION] ' + CHAR(13) + CHAR(10) + 
'FROM OPENQUERY(' + @linkServer + ', ' + CHAR(13) + CHAR(10) + 
' ''SELECT [MODEL_CATALOG], [MODEL_NAME], [COLUMN_NAME], [DATA_TYPE], [CONTENT_TYPE], [DESCRIPTION] ' + CHAR(13) + CHAR(10) + 
' FROM $SYSTEM.DMSCHEMA_MINING_COLUMNS'') M ' + CHAR(13) + CHAR(10) + 
'INNER JOIN OPENQUERY(' + @linkServer + ', ' + CHAR(13) + CHAR(10) +
' ''SELECT [DATA_TYPE], [TYPE_NAME] AS [DATA_TYPE_NAME], [COLUMN_SIZE] ' + CHAR(13) + CHAR(10) +
' FROM $SYSTEM.DBSCHEMA_PROVIDER_TYPES'') D  ' + CHAR(13) + CHAR(10) +
'ON D.[DATA_TYPE] = M.[DATA_TYPE] ' + CHAR(13) + CHAR(10) +
'WHERE (CAST(M.[MODEL_CATALOG] AS nvarchar(4000))  = @catalog OR @catalog IS NULL) ' + CHAR(13) + CHAR(10) + 
'AND (CAST(M.[MODEL_NAME] AS nvarchar(4000)) = @miningModel OR @miningModel IS NULL) ' + CHAR(13) + CHAR(10) + 
'ORDER BY CAST(M.[MODEL_CATALOG] AS nvarchar(4000)), CAST(M.[MODEL_NAME] AS nvarchar(4000)), CAST(M.[COLUMN_NAME] AS nvarchar(4000))';

 EXECUTE sp_executesql @sql, @parmDefinition, @catalog = @catalog, @miningModel = @miningModel;
END; 
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[spOLAP_GetMiningStructures]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_EXECUTEsql @statement = N'CREATE PROCEDURE [Utility].[spOLAP_GetMiningStructures] AS' 
END
GO
ALTER PROCEDURE [Utility].[spOLAP_GetMiningStructures]
( @linkServer nvarchar(128)
 ,@catalog nvarchar(255) = NULL
 ,@miningStructure nvarchar(255) = NULL )
WITH EXECUTE AS OWNER 
AS
/* ============================================================================================
Proposito: Retorna columnas de estructura de mineria de datos para bases de datos OLAP.
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2017-04-10
Fecha actualizacion: 2020-07-15

Parametros:  
 @linkServer: Nombre del servidor vinculado a la base de datos en un servidor SQL Server Analysis Services. Ejemplo: PerdidasOLAP.
 @catalog: Nombre de la base de datos OLAP. Ejemplo: PerdidasOLAP.
 @miningStructure: Nombre de estructura de minería de datos. Ejemplo: VisitasRevision.

Ejemplo:
EXECUTE [Utility].[spOLAP_GetMiningStructures] 'PerdidasOLAP', 'PerdidasOLAP', 'VisitasRevision';
EXECUTE [Utility].[spOLAP_GetMiningStructures] 'PerdidasOLAP';
============================================================================================ */
BEGIN
 SET NOCOUNT ON;
 Declare @sql nvarchar(max), @parmDefinition nvarchar(1024);

 set @sql = '';
 set @parmDefinition = N'@catalog nvarchar(255), @miningStructure nvarchar(255)';

 set @sql = @sql +
'SELECT S.[STRUCTURE_CATALOG], S.[STRUCTURE_NAME], S.[DESCRIPTION], CONVERT(BIT, S.[IS_POPULATED]) AS [IS_POPULATED] ' + CHAR(13) + CHAR(10) + 
', S.[HOLDOUT_SEED] ' + CHAR(13) + CHAR(10) + 
', CASE CONVERT(INT, S.[HOLDOUT_ACTUAL_SIZE]) WHEN NULL THEN CONVERT(BIT, 0) ELSE CONVERT(BIT, 1) END AS [IS_PROCESSED] ' + CHAR(13) + CHAR(10) + 
', CONVERT(INT,[HOLDOUT_ACTUAL_SIZE]) AS [COUNT_TESTCASES] ' + CHAR(13) + CHAR(10) + 
', CONVERT(INT,[HOLDOUT_MAXPERCENT]) AS [HOLDOUT_MAXPERCENT] ' + CHAR(13) + CHAR(10) + 
', CONVERT(INT,[HOLDOUT_MAXCASES]) AS [HOLDOUT_MAXCASES] ' + CHAR(13) + CHAR(10) + 
', CONVERT(SMALLDATETIME, S.[DATE_CREATED]) AS [DATE_CREATED] ' + CHAR(13) + CHAR(10) + 
', CONVERT(SMALLDATETIME, S.[DATE_MODIFIED]) AS [DATE_MODIFIED] ' + CHAR(13) + CHAR(10) + 
', CONVERT(SMALLDATETIME, S.[LAST_PROCESSED]) AS [LAST_PROCESSED] ' + CHAR(13) + CHAR(10) + 
'FROM OPENQUERY(' + @linkServer + ', ' + CHAR(13) + CHAR(10) + 
' ''SELECT [STRUCTURE_CATALOG], [STRUCTURE_NAME], [DESCRIPTION], [IS_POPULATED], [HOLDOUT_MAXPERCENT] ' + CHAR(13) + CHAR(10) +
' , [HOLDOUT_MAXCASES], [HOLDOUT_SEED], [HOLDOUT_ACTUAL_SIZE], [DATE_CREATED], [DATE_MODIFIED], [LAST_PROCESSED] ' + CHAR(13) + CHAR(10) +
' FROM $SYSTEM.DMSCHEMA_MINING_STRUCTURES'') S ' + CHAR(13) + CHAR(10) + 
'WHERE (CAST(S.[STRUCTURE_CATALOG] AS nvarchar(4000))  = @catalog OR @catalog IS NULL) ' + CHAR(13) + CHAR(10) + 
'AND (CAST(S.[STRUCTURE_NAME] AS nvarchar(4000)) = @miningStructure OR @miningStructure IS NULL) ' + CHAR(13) + CHAR(10) + 
'ORDER BY CAST(S.[STRUCTURE_CATALOG] AS nvarchar(4000)), CAST(S.[STRUCTURE_NAME] AS nvarchar(4000))';

 EXECUTE sp_executesql @sql, @parmDefinition, @catalog = @catalog, @miningStructure = @miningStructure;
END; 
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[spOLAP_GetMiningStructureColumns]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_EXECUTEsql @statement = N'CREATE PROCEDURE [Utility].[spOLAP_GetMiningStructureColumns] AS' 
END
GO
ALTER PROCEDURE [Utility].[spOLAP_GetMiningStructureColumns]
( @linkServer nvarchar(128)
 ,@catalog nvarchar(255) = NULL
 ,@miningStructure nvarchar(255) = NULL )
WITH EXECUTE AS OWNER 
AS
/* ============================================================================================
Proposito: Retorna columnas de estructura de mineria de datos para bases de datos OLAP.
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2017-04-10
Fecha actualizacion: 2020-07-15

Parametros:  
 @linkServer: Nombre del servidor vinculado a la base de datos en un servidor SQL Server Analysis Services. Ejemplo: PerdidasOLAP.
 @catalog: Nombre de la base de datos OLAP. Ejemplo: PerdidasOLAP.
 @miningStructure: Nombre de estructura de minería de datos. Ejemplo: VisitasRevision.

Ejemplo:
EXECUTE [Utility].[spOLAP_GetMiningStructureColumns] 'PerdidasOLAP', 'PerdidasOLAP', 'VisitasRevision';
EXECUTE [Utility].[spOLAP_GetMiningStructureColumns] 'PerdidasOLAP';
============================================================================================ */
BEGIN
 SET NOCOUNT ON;
 Declare @sql nvarchar(max), @parmDefinition nvarchar(1024);

 set @sql = '';
 set @parmDefinition = N'@catalog nvarchar(255), @miningStructure nvarchar(255)';

 set @sql = @sql +
'SELECT S.[STRUCTURE_CATALOG], S.[STRUCTURE_NAME], S.[COLUMN_NAME], CONVERT(INT, S.[ORDINAL_POSITION]) [ORDINAL_POSITION] ' + CHAR(13) + CHAR(10) + 
', CONVERT(BIT, S.[COLUMN_HASDEFAULT]) As [COLUMN_HASDEFAULT], S.[COLUMN_DEFAULT] ' + CHAR(13) + CHAR(10) + 
', CONVERT(BIT, S.[IS_NULLABLE]) AS [IS_NULLABLE], D.[DATA_TYPE_NAME], S.[CHARACTER_MAXIMUM_LENGTH], S.[NUMERIC_PRECISION], S.[CONTENT_TYPE], S.[MODELING_FLAG] ' + CHAR(13) + CHAR(10) + 
', CONVERT(BIT, S.[IS_RELATED_TO_KEY]) As [IS_RELATED_TO_KEY], S.[RELATED_ATTRIBUTE], S.[CONTAINING_COLUMN] ' + CHAR(13) + CHAR(10) +
', CONVERT(BIT,S.[IS_POPULATED]) As [IS_POPULATED] ' + CHAR(13) + CHAR(10) + 
'FROM OPENQUERY(' + @linkServer + ', ' + CHAR(13) + CHAR(10) + 
' ''SELECT [STRUCTURE_CATALOG], [STRUCTURE_NAME], [COLUMN_NAME], [ORDINAL_POSITION], [COLUMN_HASDEFAULT], [COLUMN_DEFAULT] ' + CHAR(13) + CHAR(10) +
' , [IS_NULLABLE], [DATA_TYPE], [CHARACTER_MAXIMUM_LENGTH], [NUMERIC_PRECISION], [NUMERIC_SCALE], [CONTENT_TYPE], [MODELING_FLAG] ' + CHAR(13) + CHAR(10) +
' , [IS_RELATED_TO_KEY], [RELATED_ATTRIBUTE], [CONTAINING_COLUMN], [IS_POPULATED] ' + CHAR(13) + CHAR(10) + 
' FROM $SYSTEM.DMSCHEMA_MINING_STRUCTURE_COLUMNS'') S ' + CHAR(13) + CHAR(10) + 
'INNER JOIN OPENQUERY(' + @linkServer + ', ' + CHAR(13) + CHAR(10) +
' ''SELECT [DATA_TYPE], [TYPE_NAME] AS [DATA_TYPE_NAME], [COLUMN_SIZE] ' + CHAR(13) + CHAR(10) +
' FROM $SYSTEM.DBSCHEMA_PROVIDER_TYPES'') D  ' + CHAR(13) + CHAR(10) +
'ON D.[DATA_TYPE] = S.[DATA_TYPE] ' + CHAR(13) + CHAR(10) +
'WHERE (CAST(S.[STRUCTURE_CATALOG] AS nvarchar(4000))  = @catalog OR @catalog IS NULL) ' + CHAR(13) + CHAR(10) + 
'AND (CAST(S.[STRUCTURE_NAME] AS nvarchar(4000)) = @miningStructure OR @miningStructure IS NULL) ' + CHAR(13) + CHAR(10) + 
'ORDER BY CAST(S.[STRUCTURE_CATALOG] AS nvarchar(4000)), CAST(S.[STRUCTURE_NAME] AS nvarchar(4000)), CAST(S.[COLUMN_NAME] AS nvarchar(4000))';

 EXECUTE sp_executesql @sql, @parmDefinition, @catalog = @catalog, @miningStructure = @miningStructure;
END; 
GO

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - End script: A15SPUtil_OLAP.sql'
PRINT '------------------------------------------------------------------------'
GO