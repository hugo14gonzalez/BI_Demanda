/* ========================================================================== 
Proyecto: DemandaBI
Empresa:  
Desarrollador: Hugo Gonzalez Olaya 
Fecha: 2020-07-15
Fecha actualizacion: 2020-07-15
========================================================================== */ 

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - Start script: Z01Artefactos.sql'
PRINT '------------------------------------------------------------------------'
GO

/* ====================================================================================
 VALIDAR DESCRIPCION DE CAMPOS
==================================================================================== */
SELECT SCHEMA_NAME(o.schema_id) As [Schema], OBJECT_NAME(c.object_id) As [Table], c.name As [Field], ex.value As [Description], o.type
FROM sys.columns c  
INNER JOIN sys.objects o on c.object_id = o.object_id
LEFT JOIN sys.extended_properties ex 
ON  ex.major_id = c.object_id AND ex.minor_id = c.column_id  AND ex.name = 'MS_Description'  
WHERE ex.value IS NULL
AND o.type NOT IN ('FN', 'TF', 'IF' /*, 'V' */)
-- AND OBJECT_NAME(c.object_id) = 'MiTable' 
 AND OBJECTPROPERTY(c.object_id, 'IsMsShipped') = 0 
ORDER BY o.type, SCHEMA_NAME(o.schema_id), OBJECT_NAME(c.object_id), c.column_id;

/* ====================================================================================
 DISTRIBUCION DE TABLAS E INDICES EN FILE GROUPS Y ESQUEMAS DE particion
==================================================================================== */
WITH [WCTE_Particion] AS (
SELECT SCHEMA_NAME(o.schema_id) As Esquema
 ,o.Name As Tabla
 ,coalesce(i.Name, 'HEAP') As Indice
 ,i.type_desc As Indice_Tipo 
 ,i.index_id
 ,Coalesce(ps.name, fg.name) AS Filegroup_PartScheme
 ,CASE WHEN ps.data_space_id IS NOT NULL THEN 'Si' ELSE 'No' END As Partitioned
 ,convert(numeric, p.used_page_count) * 8 / 1024 As Usado_MB
 ,convert(numeric, p.in_row_data_page_count) * 8 / 1024 As EnDatos_MB
 ,convert(numeric, p.reserved_page_count) * 8 / 1024 As Reservado_MB
 ,p.row_count As Rows_Indice
 ,case when i.index_id in ( 0, 1 ) then p.row_count else 0 end As Rows_Table
  FROM sys.dm_db_partition_stats p
  INNER JOIN sys.objects as o ON o.object_id = p.object_id
  LEFT OUTER JOIN sys.indexes as i on i.object_id = p.object_id and i.index_id = p.index_id
  LEFT JOIN sys.data_spaces AS ds ON i.data_space_id = ds.data_space_id
  LEFT JOIN sys.partition_schemes AS ps ON ps.data_space_id = ds.data_space_id
  LEFT JOIN sys.filegroups AS fg ON fg.data_space_id = i.data_space_id
 WHERE o.type in ('U') 
)
SELECT t.Esquema
 ,t.Tabla
 ,t.Indice
 ,t.Indice_Tipo
 ,t.Filegroup_PartScheme
 ,Partitioned
 ,sum(t.Usado_MB) as Usado_MB
 ,sum(t.EnDatos_MB) as EnDatos_MB
 ,sum(t.Reservado_MB) as Reservado_MB
 ,case when t.index_id in ( 0, 1 ) then sum(t.Rows_Indice) else sum(t.Rows_Table) end as Rows
FROM [WCTE_Particion] as t
--WHERE t.index_id in ( 0, 1 ) -- AND t.Table = 'MiTable'
GROUP BY t.Esquema, t.Tabla, t.Indice, t.index_id, t.Indice_Tipo, Filegroup_PartScheme, Partitioned 
ORDER BY t.Esquema, t.Tabla, t.Indice_Tipo;

/* ====================================================================================
 DETALLES DE PARTICIONES
==================================================================================== */
 SELECT DISTINCT OBJECT_NAME(p.object_id) AS [ObjectName]
 , ps.[name] AS [PartitionScheme], p.partition_number AS [PartitionNumber], fg.name AS [FileGroupName]
 , CASE pf.boundary_value_on_right WHEN 1 THEN 'RIGHT' ELSE 'LEFT' END AS [Range]
 , T.[system_type_id] As [TypeId], T.[name] As [TypeName]
 , IIf(T.[system_type_id] IN (40,41,42,43,61,189), 1, 0) As [IsRangeDate]
 , prv_left.[value] AS [LowerBoundaryValue]
 , prv_right.[value] AS [UpperBoundaryValue]
 , IIf(T.[system_type_id] IN (40,41,42,43,61,189), convert(int, Convert(varchar(8), prv_left.[value], 112)), convert(int, prv_left.[value]) ) [LowerBoundaryValueNumeric]
 , IIf(T.[system_type_id] IN (40,41,42,43,61,189), convert(int, Convert(varchar(8), prv_right.[value], 112)), convert(int, prv_right.[value]) ) [UpperBoundaryValueNumeric]
 , IIf(T.[system_type_id] IN (40,41,42,43,61,189), convert(date, prv_left.[value]), convert(date, Convert(varchar(8), Convert(varchar, prv_left.[value]) + '0101'), 112) ) [LowerBoundaryValueDate]
 , IIf(T.[system_type_id] IN (40,41,42,43,61,189), convert(date, prv_right.[value]), convert(date, Convert(varchar(8), Convert(varchar, prv_right.[value]) + '0101'), 112) ) [UpperBoundaryValueDate]
 , p.rows AS [Rows]
 FROM sys.partitions AS p 
 INNER JOIN sys.indexes AS i ON i.object_id = p.object_id AND i.index_id = p.index_id
 INNER JOIN sys.data_spaces AS ds ON ds.data_space_id = i.data_space_id
 INNER JOIN sys.partition_schemes AS ps ON ps.data_space_id = ds.data_space_id
 INNER JOIN sys.partition_functions AS pf ON pf.function_id = ps.function_id
 INNER JOIN sys.destination_data_spaces AS dds2 ON dds2.partition_scheme_id = ps.data_space_id AND dds2.destination_id = p.partition_number
 INNER JOIN sys.filegroups AS fg ON fg.data_space_id = dds2.data_space_id
 INNER JOIN sys.partition_parameters pp on pp.function_id = pf.function_id and pp.parameter_id = 1
 INNER JOIN sys.types T on T.system_type_id = pp.system_type_id
 LEFT JOIN sys.partition_range_values AS prv_left ON ps.function_id = prv_left.function_id AND prv_left.boundary_id = p.partition_number - 1
 LEFT JOIN sys.partition_range_values AS prv_right ON ps.function_id = prv_right.function_id AND prv_right.boundary_id = p.partition_number 
 WHERE OBJECTPROPERTY(p.object_id, 'ISMSShipped') = 0 /* Object created during installation of SQL Server */
 ORDER BY ObjectName, PartitionScheme, PartitionNumber;

/* ====================================================================================
 LISTA DE OBJETOS
==================================================================================== */
SELECT O.type, QUOTENAME(SCHEMA_NAME(O.schema_id)) + '.' + QUOTENAME(O.name)
FROM sys.objects O 
WHERE O.type IN ('V', 'U', 'P', 'TF', 'FN', 'IF') 
--WHERE O.type IN ('C', 'D') 
ORDER BY O.type, SCHEMA_NAME(O.schema_id), O.name;

-- Opbetos por tipo
SELECT [Type], [Esquema], [Objeto] FROM ( 
SELECT RTrim(Convert(nvarchar, O.[type])) As [Type], QuoteName(S.[name]) As [Esquema], QuoteName(O.[name]) As [Objeto] 
FROM [sys].[objects] O 
INNER JOIN [sys].[schemas] S ON O.[schema_id] = S.[schema_id] 
WHERE O.type IN ('U','V','P','FN','TF','IF','SQ','SCHEMAXML','SERVICE')
AND O.[name] NOT IN ('ServiceBrokerQueue') 
UNION ALL 
SELECT 'U' [Type], '' [Esquema], '' [Objeto] 
UNION ALL 
SELECT 'U' [Type], '' [Esquema], '' [Objeto] 
UNION ALL 
SELECT 'V' [Type], '' [Esquema], '' [Objeto] 
UNION ALL 
SELECT 'V' [Type], '' [Esquema], '' [Objeto] 
UNION ALL 
SELECT 'P' [Type], '' [Esquema], '' [Objeto] 
UNION ALL 
SELECT 'P' [Type], '' [Esquema], '' [Objeto] 
UNION ALL 
SELECT 'FN' [Type], '' [Esquema], '' [Objeto] 
UNION ALL 
SELECT 'FN' [Type], '' [Esquema], '' [Objeto] 
UNION ALL 
SELECT 'TF' [Type], '' [Esquema], '' [Objeto] 
UNION ALL 
SELECT 'TF' [Type], '' [Esquema], '' [Objeto] 
UNION ALL 
SELECT 'IF' [Type], '' [Esquema], '' [Objeto] 
UNION ALL 
SELECT 'IF' [Type], '' [Esquema], '' [Objeto] 
UNION ALL 
SELECT 'SQ' [Type], '' [Esquema], '' [Objeto] 
UNION ALL 
SELECT 'SQ' [Type], '' [Esquema], '' [Objeto] 
UNION ALL 
SELECT 'SCHEMAXML' As [Type], QuoteName(S.[name]) As [Esquema], QuoteName(X.[name]) AS [Objeto] 
FROM [sys].[xml_schema_collections] X 
INNER JOIN [sys].[schemas] S ON X.[schema_id] = S.[schema_id] 
WHERE S.[name] NOT IN ('sys') 
UNION ALL 
SELECT 'SCHEMAXML' [Type], '' [Esquema], '' [Objeto] 
UNION ALL 
SELECT 'SCHEMAXML' [Type], '' [Esquema], '' [Objeto] 
UNION ALL 
SELECT 'SERVICE' As [Type], '' As [Esquema], QuoteName(S.[name]) COLLATE DATABASE_DEFAULT  AS [Objeto] 
FROM [sys].[services] S 
WHERE S.[name] NOT LIKE 'http://schemas.microsoft.com/SQL/%' 
UNION ALL 
SELECT 'SERVICE' [Type], '' [Esquema], '' [Objeto] 
UNION ALL 
SELECT 'SERVICE' [Type], '' [Esquema], '' [Objeto] 
) T 
ORDER BY CASE WHEN [Type] = 'U' THEN 1 
              WHEN [Type] = 'V' THEN 2 
              WHEN [Type] = 'P' THEN 3 
              WHEN [Type] = 'FN' THEN 4 
              WHEN [Type] = 'TF' THEN 5 
              WHEN [Type] = 'IF' THEN 6 
              WHEN [Type] = 'SQ' THEN 7 
              WHEN [Type] = 'SCHEMAXML' THEN 8 
              WHEN [Type] = 'SERVICE' THEN 9 
              ELSE 10 END 
, CASE WHEN [Esquema] = '' THEN 1 ELSE 0 END, [Esquema] 
, CASE WHEN [Objeto] = '' THEN 1 ELSE 0 END, [Objeto];

-- Esquemas
SELECT [Esquema] FROM ( 
 SELECT QuoteName([name]) As [Esquema] 
 FROM [sys].[schemas] 
 WHERE [name] NOT IN ('guest', 'sys', 'INFORMATION_SCHEMA') 
 AND [name] NOT IN (SELECT [name] FROM [sys].[database_principals] WHERE [is_fixed_role] = 1) 
 UNION ALL 
 SELECT '' As [Esquema] 
 UNION ALL 
 SELECT '' As [Esquema] 
) S 
ORDER BY CASE WHEN [Esquema] = '' THEN 1 ELSE 0 END, [Esquema];

/* ====================================================================================
DICCIONARIO DE DATOS
==================================================================================== */
SELECT CASE o.type WHEN 'U' THEN 'Tabla' WHEN 'V' THEN 'Vista' ELSE o.type END [Type], 
 QUOTENAME(SCHEMA_NAME(O.schema_id)) + '.' + QUOTENAME(O.name) As [Name], 
 SCHEMA_NAME(o.schema_id) As [Esquema], O.name As [Table], C.column_id As [ColumnaId], c.name As [Field], 
 CASE WHEN T.name IN ('varbinary', 'nvarchar', 'binary', 'char', 'nvarchar', 'nchar', 'sysname') THEN 
       T.name + ' (' + CASE WHEN C.max_length = - 1 THEN 'max' ELSE CAST(C.max_length AS nvarchar) END + ')' 
      WHEN T.name IN ('numeric', 'real', 'money', 'float', 'decimal') THEN T.name + ' (' + CAST(C.precision AS nvarchar) + ', ' + CAST(C.scale AS nvarchar) + ')' 
      ELSE T.name END + CASE WHEN c.is_identity = 1 THEN ' (IDENTITY)' ELSE '' END AS [TipoDato], 
 CASE WHEN ic.column_id IS NULL THEN 'NO' ELSE 'SI' END [EsPK],
 CASE WHEN C.is_nullable = 0 THEN 'SI' ELSE 'NO' END AS [Requerido],
 CASE WHEN C.is_computed = 0 THEN 'NO' ELSE 'SI' END AS [EsComputado],
 ISNULL(exT.value, '') As [TablaDescripcion], 
 ISNULL(ex.value, '') As [Description], 
 ISNULL(CC.definition, '') [FormulaColCalculada], 
 LEFT(SCHEMA_NAME(o.schema_id), 3) + '_' + OBJECT_NAME(c.object_id) AS [Hoja]
FROM sys.columns c  
INNER JOIN sys.objects o on c.object_id = o.object_id
INNER JOIN sys.types T ON C.system_type_id = T.system_type_id AND T.system_type_id = T.user_type_id
LEFT JOIN sys.extended_properties exT 
ON  exT.major_id = c.object_id AND exT.minor_id = 0 AND exT.name = 'MS_Description'  
LEFT JOIN sys.extended_properties ex 
ON  ex.major_id = c.object_id AND ex.minor_id = c.column_id AND ex.name = 'MS_Description'  
LEFT JOIN sys.indexes i ON i.object_id = o.object_id AND i.is_primary_key = 1
LEFT JOIN sys.index_columns ic on ic.object_id = o.object_id  AND ic.index_id = i.index_id  AND ic.column_id = c.column_id 
LEFT JOIN sys.computed_columns CC on cc.object_id = c.object_id AND cc.column_id = c.column_id AND cc.is_computed = c.is_computed AND cc.is_computed = 1 
WHERE o.type IN ('U', 'V')
-- AND SCHEMA_NAME(o.schema_id) IN ('Utility') AND OBJECT_NAME(c.object_id) IN ('SpecialDate') 
ORDER BY O.type, SCHEMA_NAME(O.schema_id), O.name, c.column_id;


/* ====================================================================================
SIGUENTE AUTONUMERICO
==================================================================================== */
SELECT SCHEMA_NAME(o.schema_id) As [Schema], OBJECT_NAME(o.object_id) As [Table]
,i.name ColumnName
,i.seed_value
,i.increment_value
,i.last_value
FROM sys.identity_columns i
INNER JOIN sys.objects o on o.object_id = i.object_id
WHERE SCHEMA_NAME(o.schema_id) IN ('Audit', 'DW')
ORDER BY SCHEMA_NAME(o.schema_id), OBJECT_NAME(o.object_id);

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - End script: Z01Artefactos.sql'
PRINT '------------------------------------------------------------------------'
GO