/* ========================================================================== 
Proyecto: DemandaBI
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya 
Fecha: 2020-07-15
Fecha actualizacion: 2020-07-15
Link: 
http://www.made2mentor.com/2013/08/how-to-load-slowly-changing-dimensions-using-t-sql-merge/
http://www.made2mentor.com/2013/08/extracting-historical-dimension-records-using-t-sql/
http://www.made2mentor.com/2013/08/data-warehouse-initial-historical-dimension-loading-with-t-sql-merge/
========================================================================== */ 

/* ========================================================================== 
VARIABLES PARA INSTALAR:
$(DATABASE_NAME_DW): Nombre de la base de datos. Ejemplo: DemandaDW
========================================================================== */

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - Start script: A13SP_DW_Dim2.sql'
PRINT '------------------------------------------------------------------------'
GO

USE [$(DATABASE_NAME_DW)];

/* ========================================================================== 
CARGA DE DIMENSIONES TIPO 2
========================================================================== */
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DW].[spLoadDimAgente]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_EXECUTEsql @statement = N'CREATE PROCEDURE [DW].[spLoadDimAgente] AS' 
END
GO
ALTER PROCEDURE [DW].[spLoadDimAgente] 
 @bitacoraId bigint
As
/* ============================================================================================
Proposito: Inserta o actualiza los datos de tabla DimAgente utilizados los datos de la tabla temporal staging area.
Esta es una dimension tipo 2, los campos para indicar si es tipo 1 o 2 son los siguientes:
Tipo 1: [Nombre],[Actividad]
Tipo 2: [AgenteId],[CompaniaSKId],[Activo]
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2020-07-15
Fecha actualizacion: 2020-07-15

Error: 8624 Internal Query Processor Error: The query processor could not produce a query plan 
Solucion:
1. SET ANSI_PADDING OFF;
2. Actualice estadisticas: 
 Una tabla: UPDATE STATISTICS DW.DimAgente; 
 Todas las tablas: EXEC sp_updatestats;

Parametros:
 @bitacoraId: Código de ejecución de proceso.

Ejemplo:
EXECUTE [DW].[spLoadDimAgente] 0;

SELECT * FROM [DW].[DimAgente];
============================================================================================ */
begin
 set nocount on;
 SET ANSI_PADDING OFF;
 
 Declare @message nvarchar(max), @countRow int, @skId int, @okRowInserted bit, @iCountTempo bigint;
 Declare @item bigint, @rowsConsulted bigint, @rowsError bigint, @rowsInserted bigint, @rowsUpdated bigint;
 Declare @dtDateWork date;
 Declare @CompaniaId varchar(20), @FechaIni date, @minCompaniaSKId int; 

 Declare @TableChanges TABLE 
 (
   [Action] [nvarchar](10) COLLATE DATABASE_DEFAULT
 );
 
 set @dtDateWork = GetDate();
 EXECUTE [Audit].[spBitacoraStatistic_Start] @bitacoraId, @item OUTPUT, @dtDateWork, 'DimAgente';
 set @rowsInserted = 0;
 set @rowsUpdated = 0;

 SELECT @rowsConsulted = Count(*)
 FROM [Staging].[TmpDimAgente];
 if (@rowsConsulted = 0)
 begin
   INSERT INTO [Audit].[BitacoraTable]([BitacoraId],[Name],[StateId],[SeverityId],[TypeId],[DateRun],[DateWork],[TableTarget]
    ,[FieldTarget],[ValueTarget],[TableSource],[FieldSource],[ValueSource],[PKField1],[PKValue1],[PKField2],[PKValue2],[PKField3],[PKValue3]
   ,[PKField4],[PKValue4],[PKField5],[PKValue5],[Message])
   VALUES (@bitacoraId, 'spLoadDimAgente', 13, 2, 3, GetDate(), @dtDateWork, 'DW.DimAgente', NULL, NULL, 'Staging.TmpDimAgente'
   , NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Datos ausente');
  GOTO Salir;
 end;

 IF OBJECT_ID('tempdb..#DimAgente_spLoad') IS NOT NULL
 begin
  DROP TABLE #DimAgente_spLoad;
 end;  	 
 CREATE TABLE #DimAgente_spLoad (
 [Action] [nvarchar](10) COLLATE DATABASE_DEFAULT NOT NULL,
	[AgenteId] [varchar](20) COLLATE DATABASE_DEFAULT NOT NULL,
	[AgenteMemId] [varchar](20) COLLATE DATABASE_DEFAULT NOT NULL,
	[Nombre] [varchar](100) COLLATE DATABASE_DEFAULT NOT NULL,
	[Actividad] [varchar](20) COLLATE DATABASE_DEFAULT NOT NULL,
	[CompaniaSKId] [int] NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaIniSKId] [int] NOT NULL,
	[FechaFinSKId] [int] NULL,
 PRIMARY KEY CLUSTERED 
 (
  [Action] ASC,
	 [AgenteMemId] ASC, 
	 [FechaIniSKId] ASC
  ) 
 );
 Declare @MidleRow TABLE (
	[AgenteId] [varchar](20) COLLATE DATABASE_DEFAULT NOT NULL,
	[AgenteMemId] [varchar](20) COLLATE DATABASE_DEFAULT NOT NULL,
	[Nombre] [varchar](100) COLLATE DATABASE_DEFAULT NOT NULL,
	[Actividad] [varchar](20) COLLATE DATABASE_DEFAULT NOT NULL,
	[CompaniaSKId] [int] NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaIniSKId] [int] NOT NULL,
	[FechaFinSKId] [int] NULL,
 PRIMARY KEY CLUSTERED 
 (
	 [AgenteMemId] ASC, 
 	[FechaIniSKId] ASC
  ) 
 );

 set @minCompaniaSKId = (SELECT Min([CompaniaSKId]) FROM [DW].[DimCompania]);

 /* Auditoria registros duplicados */
 ;WITH [CTE_I] AS
 (
  SELECT [AgenteId],[AgenteMemId],[FechaIni] 
    , ROW_NUMBER() OVER (PARTITION BY [AgenteMemId],[FechaIni] ORDER BY [AgenteMemId],[AgenteId],[FechaIni]) [Row]
  FROM [Staging].[TmpDimAgente] 
  WHERE [Inconsistent] = 0 
 )
 INSERT INTO [Audit].[BitacoraTable]([BitacoraId],[Name],[StateId],[SeverityId],[TypeId],[DateRun],[DateWork],[TableTarget]
  ,[FieldTarget],[ValueTarget],[TableSource],[FieldSource],[ValueSource],[PKField1],[PKValue1],[PKField2],[PKValue2],[PKField3],[PKValue3]
  ,[PKField4],[PKValue4],[PKField5],[PKValue5],[Message])
 SELECT @bitacoraId, 'spLoadDimAgente', 1, 2, 4, GetDate(), @dtDateWork, 'DW.DimAgente', 'AgenteId', [AgenteId], 'Staging.TmpDimAgente', 'AgenteMemId'
   ,[AgenteMemId], 'AgenteId', [AgenteId], 'AgenteMemId', [AgenteMemId], 'FechaIni', [FechaIni], NULL, NULL, NULL, NULL, 'Datos repetidos'
 FROM [CTE_I] WHERE [Row] > 1;

 /* Marcar registros duplicados */
 ;WITH [CTE_I] AS
 (
  SELECT [TmpSKId]
    , ROW_NUMBER() OVER (PARTITION BY [AgenteMemId],[FechaIni] ORDER BY [AgenteMemId],[AgenteId],[FechaIni]) [Row]
  FROM [Staging].[TmpDimAgente] 
  WHERE [Inconsistent] = 0
 )
 UPDATE T SET
  [Inconsistent] = 1 
 FROM [Staging].[TmpDimAgente] T 
 INNER JOIN [CTE_I] I ON I.[TmpSKId] = T.[TmpSKId] 
 WHERE I.[Row] > 1;

 /* Actualizar SK - FechaIniSKId */
 UPDATE T SET
  [FechaIniSKId] = D.[FechaSKId]
 FROM [Staging].[TmpDimAgente] T
 INNER JOIN [DW].[DimFecha] D WITH (NOLOCK) ON D.[Fecha] = T.[FechaIni]
 WHERE T.[Inconsistent] = 0;

 /* Auditoria SK no encontrada - FechaIniSKId */
 INSERT INTO [Audit].[BitacoraTable]([BitacoraId],[Name],[StateId],[SeverityId],[TypeId],[DateRun],[DateWork],[TableTarget]
  ,[FieldTarget],[ValueTarget],[TableSource],[FieldSource],[ValueSource],[PKField1],[PKValue1],[PKField2],[PKValue2],[PKField3],[PKValue3]
  ,[PKField4],[PKValue4],[PKField5],[PKValue5],[Message])
 SELECT @bitacoraId, 'spLoadDimAgente', 1, 2, 5, GetDate(), @dtDateWork, 'DW.DimAgente', 'FechaIniSKId', NULL, 'Staging.TmpDimAgente', 'FechaIni'
   ,[FechaIni], 'AgenteId', [AgenteId], 'AgenteMemId', [AgenteMemId], 'FechaIni', [FechaIni], NULL, NULL, NULL, NULL, 'Clave foranea no encontrada'
 FROM [Staging].[TmpDimAgente] 
 WHERE [FechaIniSKId] IS NULL  AND [Inconsistent] = 0;

 /* Marcar registros inconsistentes */
 UPDATE [Staging].[TmpDimAgente] SET
  [Inconsistent] = 1 
 WHERE [FechaIniSKId] IS NULL;

 /* Actualizar SK - FechaFinSKId */
 UPDATE T SET
  [FechaFinSKId] = D.[FechaSKId]
 FROM [Staging].[TmpDimAgente] T
 INNER JOIN [DW].[DimFecha] D WITH (NOLOCK) ON D.[Fecha] = T.[FechaFin]
 WHERE T.[Inconsistent] = 0 AND T.[FechaFin] IS NOT NULL;

 /* Auditoria SK no encontrada - FechaFinSKId */
 INSERT INTO [Audit].[BitacoraTable]([BitacoraId],[Name],[StateId],[SeverityId],[TypeId],[DateRun],[DateWork],[TableTarget]
  ,[FieldTarget],[ValueTarget],[TableSource],[FieldSource],[ValueSource],[PKField1],[PKValue1],[PKField2],[PKValue2],[PKField3],[PKValue3]
  ,[PKField4],[PKValue4],[PKField5],[PKValue5],[Message])
 SELECT @bitacoraId, 'spLoadDimAgente', 1, 2, 5, GetDate(), @dtDateWork, 'DW.DimAgente', 'FechaFinSKId', NULL, 'Staging.TmpDimAgente', 'FechaFin'
   ,[FechaFin], 'AgenteId', [AgenteId], 'AgenteMemId', [AgenteMemId], 'FechaFin', [FechaFin], NULL, NULL, NULL, NULL, 'Clave foranea no encontrada'
 FROM [Staging].[TmpDimAgente] 
 WHERE [FechaFin] IS NOT NULL AND [FechaFinSKId] IS NULL AND [Inconsistent] = 0;

 /* Marcar registros inconsistentes */
 UPDATE [Staging].[TmpDimAgente] SET
  [Inconsistent] = 1 
 WHERE [FechaFin] IS NOT NULL AND [FechaFinSKId] IS NULL;

 /* Actualizar SK - DimCompania */
 UPDATE T SET
  [CompaniaSKId] = E.[CompaniaSKId]
 FROM [Staging].[TmpDimAgente] T
 INNER JOIN [DW].[DimCompania] E WITH (NOLOCK) ON E.[CompaniaId] = T.[CompaniaId]
 AND ( T.[FechaIniSKId] >= E.[FechaIniSKId] AND (E.[FechaFinSKId] IS NULL OR E.[FechaFinSKId] > T.[FechaIniSKId]) )
 WHERE T.[Inconsistent] = 0;

 /* Inferir datos no encontrados - DimCompania */
 DECLARE Cur_Loop CURSOR FORWARD_ONLY READ_ONLY FOR
 SELECT DISTINCT [CompaniaId], [FechaIni] 
 FROM [Staging].[TmpDimAgente] 
 WHERE [CompaniaSKId] IS NULL AND [Inconsistent] = 0
 ORDER BY [CompaniaId], [FechaIni];
    
 OPEN Cur_Loop;
 FETCH NEXT FROM Cur_Loop INTO @CompaniaId, @FechaIni;
 WHILE @@FETCH_STATUS = 0
 BEGIN   
  SET @skId = NULL;
  EXECUTE [DW].[spInferDimCompania] @skId OUTPUT, @okRowInserted OUTPUT, @bitacoraId, @CompaniaId, @FechaIni;
  if (@skId IS NULL)
  begin
   UPDATE [Staging].[TmpDimAgente] SET 
    [Inconsistent] = 1
   WHERE [CompaniaId] = @CompaniaId AND [FechaIni] = @FechaIni AND [Inconsistent] = 0;

   /* Auditoria SK no encontrada - DimCompania */
   INSERT INTO [Audit].[BitacoraTable]([BitacoraId],[Name],[StateId],[SeverityId],[TypeId],[DateRun],[DateWork],[TableTarget]
    ,[FieldTarget],[ValueTarget],[TableSource],[FieldSource],[ValueSource],[PKField1],[PKValue1],[PKField2],[PKValue2],[PKField3],[PKValue3]
    ,[PKField4],[PKValue4],[PKField5],[PKValue5],[Message])
   VALUES (@bitacoraId, 'spLoadDimAgente', 1, 2, 5, GetDate(), @dtDateWork, 'DW.DimAgente', 'CompaniaSKId', NULL, 'Staging.TmpDimAgente', NULL
    ,NULL, 'CompaniaId', @CompaniaId, 'FechaIni', @FechaIni, NULL, NULL, NULL, NULL, NULL, NULL, 'Clave foranea no encontrada');
  end
  else
  begin
   UPDATE [Staging].[TmpDimAgente] SET 
    [CompaniaSKId] = @skId
   WHERE [CompaniaId] = @CompaniaId AND [FechaIni] = @FechaIni AND [Inconsistent] = 0;

   /* Auditoria SK inferido - DimCompania */
   INSERT INTO [Audit].[BitacoraTable]([BitacoraId],[Name],[StateId],[SeverityId],[TypeId],[DateRun],[DateWork],[TableTarget]
    ,[FieldTarget],[ValueTarget],[TableSource],[FieldSource],[ValueSource],[PKField1],[PKValue1],[PKField2],[PKValue2],[PKField3],[PKValue3]
    ,[PKField4],[PKValue4],[PKField5],[PKValue5],[Message])
   VALUES (@bitacoraId, 'spLoadDimAgente', 0, 1, 6, GetDate(), @dtDateWork, 'DW.DimAgente', 'CompaniaSKId', @skId, 'Staging.TmpDimAgente', NULL
    ,NULL, 'CompaniaId', @CompaniaId, 'FechaIni', @FechaIni, NULL, NULL, NULL, NULL, NULL, NULL, 'Clave foranea inferida adicionada');
  end;
  FETCH NEXT FROM Cur_Loop INTO @CompaniaId, @FechaIni;
 END
 CLOSE Cur_Loop;
 DEALLOCATE Cur_Loop;     

 /* Insertar lo que no existe y luego ajustar las vigencias. Ya que el codigo abajo no adiciona versiones intermedias */
 INSERT INTO @MidleRow ([AgenteId],[AgenteMemId],[Nombre],[Actividad],[CompaniaSKId],[Activo],[FechaIniSKId],[FechaFinSKId])
 SELECT Source.[AgenteId],Source.[AgenteMemId],Source.[Nombre],Source.[Actividad],Source.[CompaniaSKId],Source.[Activo],Source.[FechaIniSKId],Source.[FechaFinSKId]
 FROM [Staging].[TmpDimAgente] Source
 LEFT JOIN [DW].[DimAgente] AS Target ON Target.[AgenteMemId] = Source.[AgenteMemId] AND Target.[FechaIniSKId] = Source.[FechaIniSKId]
 WHERE Source.[Inconsistent] = 0
 AND Source.[FechaIniSKId] > (SELECT Min(T.[FechaIniSKId]) FROM [DW].[DimAgente] T WITH (NOLOCK) WHERE T.[AgenteId] = Source.[AgenteId])
 AND Source.[FechaIniSKId] < (SELECT Max(T.[FechaIniSKId]) FROM [DW].[DimAgente] T WITH (NOLOCK) WHERE T.[AgenteId] = Source.[AgenteId])
 AND Target.[AgenteMemId] IS NULL;
 SET @countRow = @@ROWCOUNT;

 set @rowsInserted = IsNull(@countRow, 0);

 BEGIN TRY
  BEGIN TRANSACTION;

  INSERT INTO [DW].[DimAgente] ([AgenteId],[AgenteMemId],[Nombre],[Actividad],[CompaniaSKId],[Activo],[EsActual],[FechaIniSKId],[FechaFinSKId],[BitacoraId])
  SELECT [AgenteId],[AgenteMemId],[Nombre],[Actividad],[CompaniaSKId],[Activo],0,[FechaIniSKId],NULL,@bitacoraId
  FROM @MidleRow
  ORDER BY [AgenteId], [FechaIniSKId];

	 /* La fuente tiene fechaIni y fechaFin y maneja los cambios tipo 1 y 2 */
  MERGE [DW].[DimAgente] WITH (HOLDLOCK) AS Target
  USING (SELECT [AgenteId],[AgenteMemId],[Nombre],[Actividad],[CompaniaSKId],[Activo],[FechaIniSKId],[FechaFinSKId],[Row] 
		       ,CASE WHEN LEAD([FechaIniSKId]) OVER(PARTITION BY [AgenteMemId] ORDER BY [FechaIniSKId]) IS NULL THEN Convert(bit, 1) ELSE Convert(bit, 0) END as [EsActual]
         FROM [Staging].[TmpDimAgente] WITH (NOLOCK)
         WHERE [Inconsistent] = 0) AS Source
  ON (Target.[AgenteId] = Source.[AgenteId] AND Target.[FechaIniSKId] = Source.[FechaIniSKId])
  WHEN MATCHED AND EXISTS
    (SELECT Source.[AgenteId],Source.[AgenteMemId],Source.[Nombre],Source.[Actividad],Source.[CompaniaSKId],Source.[Activo],Source.[FechaFinSKId],Source.[EsActual]	  
     EXCEPT
     SELECT Target.[AgenteId],Target.[AgenteMemId],Target.[Nombre],Target.[Actividad],Target.[CompaniaSKId],Target.[Activo],Target.[FechaFinSKId],Target.[EsActual])
  THEN UPDATE SET 
    Target.[AgenteId] = Source.[AgenteId]
   ,Target.[AgenteMemId] = Source.[AgenteMemId]
   ,Target.[Nombre] = Source.[Nombre]
   ,Target.[Actividad] = Source.[Actividad]
   ,Target.[CompaniaSKId] = Source.[CompaniaSKId]
   ,Target.[Activo] = Source.[Activo]
   ,Target.[EsActual] = Source.[EsActual]
   ,Target.[FechaFinSKId] = Source.[FechaFinSKId]
   ,Target.[BitacoraId] = @bitacoraId
  WHEN NOT MATCHED BY TARGET THEN
   INSERT ([AgenteId],[AgenteMemId],[Nombre],[Actividad],[CompaniaSKId],[Activo],[EsActual],[FechaIniSKId],[FechaFinSKId],[BitacoraId])
   VALUES (Source.[AgenteId],Source.[AgenteMemId],Source.[Nombre],Source.[Actividad],Source.[CompaniaSKId],Source.[Activo],Source.[EsActual],Source.[FechaIniSKId], Source.[FechaFinSKId], @bitacoraId)
  OUTPUT $action INTO @TableChanges;

  set @iCountTempo = 0;
  SELECT @iCountTempo = [INSERT], @rowsUpdated = [UPDATE]
  FROM (
        SELECT [Action], 1 As [RowsChange]
        from @TableChanges
        ) p
  PIVOT
  (
   Count([RowsChange])
   FOR [Action] IN ([INSERT], [UPDATE], [DELETE])
  ) As pvt;

  set @rowsInserted = IsNull(@rowsInserted, 0) + IsNull(@iCountTempo, 0);

  /* Ajustar versiones intermedias, fecha fin debe ser igual a fecha siguiente */
  if (@countRow > 0)
  begin
   set @iCountTempo = 0;

   WITH [CTE_V] AS 
   (
    SELECT [AgenteMemId],[FechaIniSKId],[FechaFinSKId]
	   ,LEAD([FechaIniSKId]) OVER(PARTITION BY [AgenteMemId] ORDER BY [AgenteMemId], [FechaIniSKId]) [FechaFinSKId_Next]
    FROM [DW].[DimAgente] D
    WHERE EXISTS (SELECT 1 FROM @MidleRow M WHERE M.[AgenteId] = D.[AgenteId]) 
   ) 
   UPDATE D SET
     [FechaFinSKId] = V.[FechaFinSKId_Next]
    ,[BitacoraId] = @bitacoraId
   FROM [CTE_V] V INNER JOIN [DW].[DimAgente] D ON D.[AgenteMemId] = V.[AgenteMemId] AND D.[FechaIniSKId] = V.[FechaIniSKId]
   WHERE V.[FechaFinSKId] != V.[FechaFinSKId_Next] OR (V.[FechaFinSKId] IS NULL AND V.[FechaFinSKId_Next] IS NOT NULL);
   SET @iCountTempo = @@ROWCOUNT;
  
   SET @rowsUpdated = IsNull(@rowsUpdated, 0) + IsNull(@iCountTempo, 0);
  end;

  /* Insertar filas con menor fecha */
  WITH [CTE_Date] As
  (
   SELECT Source.[AgenteId],Source.[AgenteMemId],Source.[Nombre],Source.[Actividad],Source.[CompaniaSKId],Source.[Activo],Source.[FechaIniSKId],Source.[FechaFinSKId]
   ,LEAD(Source.[FechaIniSKId]) OVER(PARTITION BY Source.[AgenteMemId] ORDER BY Source.[AgenteMemId], Source.[FechaIniSKId]) [FechaFinSKId_Next]
   ,Target.[FechaIniSKId] [FechaFinSKId_Target]
   ,ROW_NUMBER() OVER (PARTITION BY Source.[AgenteMemId] ORDER BY Source.[AgenteMemId],Source.[FechaIniSKId]) [Row]
   FROM [Staging].[TmpDimAgente] Source
   INNER JOIN [DW].[DimAgente] AS Target WITH (NOLOCK) ON Target.[AgenteMemId] = Source.[AgenteMemId]  
   AND Source.[FechaIniSKId] < (SELECT Min(T.[FechaIniSKId]) FROM [DW].[DimAgente] T WITH (NOLOCK) WHERE T.[AgenteId] = Source.[AgenteId])
   WHERE Source.[Inconsistent] = 0
   AND Target.[FechaIniSKId] = (SELECT Min(T2.[FechaIniSKId]) FROM [DW].[DimAgente] AS T2 WITH (NOLOCK) WHERE T2.[AgenteId] = Target.[AgenteId])
  )
  INSERT INTO [DW].[DimAgente] ([AgenteId],[AgenteMemId],[Nombre],[Actividad],[CompaniaSKId],[Activo],[EsActual],[FechaIniSKId],[FechaFinSKId],[BitacoraId])
  SELECT Source.[AgenteId],Source.[AgenteMemId],Source.[Nombre],Source.[Actividad],Source.[CompaniaSKId],Source.[Activo]
  , 0, Source.[FechaIniSKId], ISNULL(Source.[FechaFinSKId_Next], Source.[FechaFinSKId_Target]), @bitacoraId
  FROM [CTE_Date] Source;
  SET @iCountTempo = @@ROWCOUNT;
  SET @rowsUpdated = IsNull(@rowsUpdated, 0) + IsNull(@iCountTempo, 0);

  COMMIT; 
 END TRY 
 BEGIN CATCH
  IF @@TRANCOUNT > 0
  Begin
   ROLLBACK;
  end;

  SELECT @message = [Utility].[GetErrorCurrentToString]();
  set @message = 'Error al cargar dimension: ' + Coalesce(@message, '');

  /* En RAISERROR, severidad 10: Informativo, 16: Error */
  EXECUTE [Audit].[spBitacora_Error] @bitacoraId, 'spLoadDimAgente', @message; 
  RAISERROR(@message, 16, 1); 
 END CATCH  
 
Salir:
 IF OBJECT_ID('tempdb..#DimAgente_spLoad') IS NOT NULL
 begin
  DROP TABLE #DimAgente_spLoad;
 end;  	 
 
 SELECT @rowsError = Count(*)
 FROM [Staging].[TmpDimAgente] 
 WHERE [Inconsistent] = 1;

 EXECUTE [Audit].[spBitacoraStatistic_End] @item, NULL, NULL, @rowsConsulted, @rowsError, @rowsInserted, @rowsUpdated, 0;

 set nocount off;
End
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DW].[spLoadDimCompania]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_EXECUTEsql @statement = N'CREATE PROCEDURE [DW].[spLoadDimCompania] AS' 
END
GO
ALTER PROCEDURE [DW].[spLoadDimCompania] 
 @bitacoraId bigint
As
/* ============================================================================================
Proposito: Inserta o actualiza los datos de tabla DimCompania utilizados los datos de la tabla temporal staging area.
Esta es una dimension tipo 2, los campos para indicar si es tipo 1 o 2 son los siguientes:
Tipo 1: [Nombre],[Sigla],[Nit],[TipoPropiedad]
Tipo 2: [Activa]
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2020-07-15
Fecha actualizacion: 2020-07-15

Error: 8624 Internal Query Processor Error: The query processor could not produce a query plan 
Solucion:
1. SET ANSI_PADDING OFF;
2. Actualice estadisticas: 
 Una tabla: UPDATE STATISTICS DW.DimCompania; 
 Todas las tablas: EXEC sp_updatestats;

Parametros:
 @bitacoraId: Código de ejecución de proceso.

Ejemplo:
EXECUTE [DW].[spLoadDimCompania] 0;

SELECT * FROM [DW].[DimCompania];
============================================================================================ */
begin
 set nocount on;
 SET ANSI_PADDING OFF;
-- SET ANSI_WARNINGS OFF; 
 
 Declare @message nvarchar(max), @countRow int, @skId int, @okRowInserted bit, @iCountTempo bigint;
 Declare @item bigint, @rowsConsulted bigint, @rowsError bigint, @rowsInserted bigint, @rowsUpdated bigint;
 Declare @dtDateWork date;

 Declare @TableChanges TABLE 
 (
   [Action] [nvarchar](10) COLLATE DATABASE_DEFAULT
 );
 
 set @dtDateWork = GetDate();
 EXECUTE [Audit].[spBitacoraStatistic_Start] @bitacoraId, @item OUTPUT, @dtDateWork, 'DimCompania';
 set @rowsInserted = 0;
 set @rowsUpdated = 0;

 SELECT @rowsConsulted = Count(*)
 FROM [Staging].[TmpDimCompania];
 if (@rowsConsulted = 0)
 begin
   INSERT INTO [Audit].[BitacoraTable]([BitacoraId],[Name],[StateId],[SeverityId],[TypeId],[DateRun],[DateWork],[TableTarget]
    ,[FieldTarget],[ValueTarget],[TableSource],[FieldSource],[ValueSource],[PKField1],[PKValue1],[PKField2],[PKValue2],[PKField3],[PKValue3]
   ,[PKField4],[PKValue4],[PKField5],[PKValue5],[Message])
   VALUES (@bitacoraId, 'spLoadDimCompania', 13, 2, 3, GetDate(), @dtDateWork, 'DW.DimCompania', NULL, NULL, 'Staging.TmpDimCompania'
   , NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Datos ausente');
  GOTO Salir;
 end;

 IF OBJECT_ID('tempdb..#DimCompania_spLoad') IS NOT NULL
 begin
  DROP TABLE #DimCompania_spLoad;
 end;  	 
 CREATE TABLE #DimCompania_spLoad (
 [Action] [nvarchar](10) COLLATE DATABASE_DEFAULT NOT NULL,
	[CompaniaId] [varchar](20) COLLATE DATABASE_DEFAULT NOT NULL,
	[Nombre] [varchar](100) COLLATE DATABASE_DEFAULT NOT NULL,
	[Sigla] [varchar](100) COLLATE DATABASE_DEFAULT NOT NULL,
	[Nit] [varchar](20) COLLATE DATABASE_DEFAULT NOT NULL,
	[TipoPropiedad] [varchar](50) COLLATE DATABASE_DEFAULT NOT NULL,
	[Activa] [bit] NOT NULL,
	[FechaIniSKId] [int] NOT NULL,
	[FechaFinSKId] [int] NULL,
 PRIMARY KEY CLUSTERED 
 (
  [Action] ASC,
	 [CompaniaId] ASC, 
	 [FechaIniSKId] ASC
  ) 
 );
 Declare @MidleRow TABLE (
	[CompaniaId] [varchar](20) COLLATE DATABASE_DEFAULT NOT NULL,
	[Nombre] [varchar](100) COLLATE DATABASE_DEFAULT NOT NULL,
	[Sigla] [varchar](100) COLLATE DATABASE_DEFAULT NOT NULL,
	[Nit] [varchar](20) COLLATE DATABASE_DEFAULT NOT NULL,
	[TipoPropiedad] [varchar](50) COLLATE DATABASE_DEFAULT NOT NULL,
	[Activa] [bit] NOT NULL,
	[FechaIniSKId] [int] NOT NULL,
	[FechaFinSKId] [int] NULL,
 PRIMARY KEY CLUSTERED 
 (
	 [CompaniaId] ASC, 
	 [FechaIniSKId] ASC
  ) 
 );

 /* Auditoria registros duplicados */
 ;WITH [CTE_I] AS
 (
  SELECT [CompaniaId],[FechaIni] 
    , ROW_NUMBER() OVER (PARTITION BY [CompaniaId],[FechaIni] ORDER BY [CompaniaId],[FechaIni]) [Row]
  FROM [Staging].[TmpDimCompania] 
  WHERE [Inconsistent] = 0 
 )
 INSERT INTO [Audit].[BitacoraTable]([BitacoraId],[Name],[StateId],[SeverityId],[TypeId],[DateRun],[DateWork],[TableTarget]
  ,[FieldTarget],[ValueTarget],[TableSource],[FieldSource],[ValueSource],[PKField1],[PKValue1],[PKField2],[PKValue2],[PKField3],[PKValue3]
  ,[PKField4],[PKValue4],[PKField5],[PKValue5],[Message])
 SELECT @bitacoraId, 'spLoadDimCompania', 1, 2, 4, GetDate(), @dtDateWork, 'DW.DimCompania', 'CompaniaId', [CompaniaId], 'Staging.TmpDimCompania', 'CompaniaId'
   ,[CompaniaId], 'CompaniaId', [CompaniaId], 'FechaIni', [FechaIni], NULL, NULL, NULL, NULL, NULL, NULL, 'Datos repetidos'
 FROM [CTE_I] WHERE [Row] > 1;

 /* Marcar registros duplicados */
 ;WITH [CTE_I] AS
 (
  SELECT [TmpSKId]
    , ROW_NUMBER() OVER (PARTITION BY [CompaniaId],[FechaIni] ORDER BY [CompaniaId],[FechaIni]) [Row]
  FROM [Staging].[TmpDimCompania] 
  WHERE [Inconsistent] = 0
 )
 UPDATE T SET
  [Inconsistent] = 1 
 FROM [Staging].[TmpDimCompania] T 
 INNER JOIN [CTE_I] I ON I.[TmpSKId] = T.[TmpSKId] 
 WHERE I.[Row] > 1;

 /* Actualizar SK - FechaIniSKId */
 UPDATE T SET
  [FechaIniSKId] = D.[FechaSKId]
 FROM [Staging].[TmpDimCompania] T
 INNER JOIN [DW].[DimFecha] D WITH (NOLOCK) ON D.[Fecha] = T.[FechaIni]
 WHERE T.[Inconsistent] = 0;

 /* Auditoria SK no encontrada - FechaIniSKId */
 INSERT INTO [Audit].[BitacoraTable]([BitacoraId],[Name],[StateId],[SeverityId],[TypeId],[DateRun],[DateWork],[TableTarget]
  ,[FieldTarget],[ValueTarget],[TableSource],[FieldSource],[ValueSource],[PKField1],[PKValue1],[PKField2],[PKValue2],[PKField3],[PKValue3]
  ,[PKField4],[PKValue4],[PKField5],[PKValue5],[Message])
 SELECT @bitacoraId, 'spLoadDimCompania', 1, 2, 5, GetDate(), @dtDateWork, 'DW.DimCompania', 'FechaIniSKId', NULL, 'Staging.TmpDimCompania', 'FechaIni'
   ,[FechaIni], 'CompaniaId', [CompaniaId], 'FechaIni', [FechaIni], NULL, NULL, NULL, NULL, NULL, NULL, 'Clave foranea no encontrada'
 FROM [Staging].[TmpDimCompania] 
 WHERE [FechaIniSKId] IS NULL  AND [Inconsistent] = 0;

 /* Marcar registros inconsistentes */
 UPDATE [Staging].[TmpDimCompania] SET
  [Inconsistent] = 1 
 WHERE [FechaIniSKId] IS NULL;

 /* Actualizar SK - FechaFinSKId */
 UPDATE T SET
  [FechaFinSKId] = D.[FechaSKId]
 FROM [Staging].[TmpDimCompania] T
 INNER JOIN [DW].[DimFecha] D WITH (NOLOCK) ON D.[Fecha] = T.[FechaFin]
 WHERE T.[Inconsistent] = 0 AND T.[FechaFin] IS NOT NULL;

 /* Auditoria SK no encontrada - FechaFinSKId */
 INSERT INTO [Audit].[BitacoraTable]([BitacoraId],[Name],[StateId],[SeverityId],[TypeId],[DateRun],[DateWork],[TableTarget]
  ,[FieldTarget],[ValueTarget],[TableSource],[FieldSource],[ValueSource],[PKField1],[PKValue1],[PKField2],[PKValue2],[PKField3],[PKValue3]
  ,[PKField4],[PKValue4],[PKField5],[PKValue5],[Message])
 SELECT @bitacoraId, 'spLoadDimCompania', 1, 2, 5, GetDate(), @dtDateWork, 'DW.DimCompania', 'FechaFinSKId', NULL, 'Staging.TmpDimCompania', 'FechaFin'
   ,[FechaFin], 'CompaniaId', [CompaniaId], 'FechaFin', [FechaFin], NULL, NULL, NULL, NULL, NULL, NULL, 'Clave foranea no encontrada'
 FROM [Staging].[TmpDimCompania] 
 WHERE [FechaFin] IS NOT NULL AND [FechaFinSKId] IS NULL AND [Inconsistent] = 0;

 /* Marcar registros inconsistentes */
 UPDATE [Staging].[TmpDimCompania] SET
  [Inconsistent] = 1 
 WHERE [FechaFin] IS NOT NULL AND [FechaFinSKId] IS NULL;

 /* Insertar lo que no existe y luego ajustar las vigencias. Ya que el codigo abajo no adiciona versiones intermedias */
 INSERT INTO @MidleRow ([CompaniaId],[Nombre],[Sigla],[Nit],[TipoPropiedad],[Activa],[FechaIniSKId],[FechaFinSKId])
 SELECT Source.[CompaniaId],Source.[Nombre],Source.[Sigla],Source.[Nit],Source.[TipoPropiedad],Source.[Activa],Source.[FechaIniSKId],Source.[FechaFinSKId]
 FROM [Staging].[TmpDimCompania] Source
 LEFT JOIN [DW].[DimCompania] AS Target ON Target.[CompaniaId] = Source.[CompaniaId] AND Target.[FechaIniSKId] = Source.[FechaIniSKId]
 WHERE Source.[Inconsistent] = 0
 AND Source.[FechaIniSKId] > (SELECT Min(T.[FechaIniSKId]) FROM [DW].[DimCompania] T WITH (NOLOCK) WHERE T.[CompaniaId] = Source.[CompaniaId])
 AND Source.[FechaIniSKId] < (SELECT Max(T.[FechaIniSKId]) FROM [DW].[DimCompania] T WITH (NOLOCK) WHERE T.[CompaniaId] = Source.[CompaniaId])
 AND Target.[CompaniaId] IS NULL;
 SET @countRow = @@ROWCOUNT;

 set @rowsInserted = IsNull(@countRow, 0);

 BEGIN TRY
  BEGIN TRANSACTION;

  INSERT INTO [DW].[DimCompania] ([CompaniaId],[Nombre],[Sigla],[Nit],[TipoPropiedad],[Activa],[EsActual],[FechaIniSKId],[FechaFinSKId],[BitacoraId])
  SELECT [CompaniaId],[Nombre],[Sigla],[Nit],[TipoPropiedad],[Activa],0,[FechaIniSKId],NULL,@bitacoraId
  FROM @MidleRow
  ORDER BY [CompaniaId], [FechaIniSKId];

	 /* La fuente tiene fechaIni y fechaFin y maneja los cambios tipo 1 y 2 */
  MERGE [DW].[DimCompania] WITH (HOLDLOCK) AS Target
  USING (SELECT [CompaniaId],[Nombre],[Sigla],[Nit],[TipoPropiedad],[Activa],[FechaIniSKId],[FechaFinSKId],[Row] 
		       ,CASE WHEN LEAD([FechaIniSKId]) OVER(PARTITION BY [CompaniaId] ORDER BY [FechaIniSKId]) IS NULL THEN Convert(bit, 1) ELSE Convert(bit, 0) END as [EsActual]
         FROM [Staging].[TmpDimCompania] WITH (NOLOCK)
         WHERE [Inconsistent] = 0) AS Source
  ON (Target.[CompaniaId] = Source.[CompaniaId] AND Target.[FechaIniSKId] = Source.[FechaIniSKId])
  WHEN MATCHED AND EXISTS
     (SELECT Source.[Nombre],Source.[Sigla],Source.[Nit],Source.[TipoPropiedad],Source.[Activa],Source.[FechaFinSKId],Source.[EsActual]	  
      EXCEPT
      SELECT Target.[Nombre],Target.[Sigla],Target.[Nit],Target.[TipoPropiedad],Target.[Activa],Target.[FechaFinSKId],Target.[EsActual])
  THEN UPDATE SET 
	   Target.[Nombre] = Source.[Nombre]
	  ,Target.[Sigla] = Source.[Sigla]
	  ,Target.[Nit] = Source.[Nit]
   ,Target.[TipoPropiedad] = Source.[TipoPropiedad]
	  ,Target.[Activa] = Source.[Activa]
   ,Target.[EsActual] = Source.[EsActual]
   ,Target.[FechaFinSKId] = Source.[FechaFinSKId]
   ,Target.[BitacoraId] = @bitacoraId
  WHEN NOT MATCHED BY TARGET THEN
      INSERT ([CompaniaId],[Nombre],[Sigla],[Nit],[TipoPropiedad],[Activa],[EsActual],[FechaIniSKId],[FechaFinSKId],[BitacoraId])
      VALUES (Source.[CompaniaId],Source.[Nombre],Source.[Sigla],Source.[Nit],Source.[TipoPropiedad],Source.[Activa],Source.[EsActual], Source.[FechaIniSKId], Source.[FechaFinSKId], @bitacoraId)
  OUTPUT $action INTO @TableChanges;

  set @iCountTempo = 0;
  SELECT @iCountTempo = [INSERT], @rowsUpdated = [UPDATE]
  FROM (
        SELECT [Action], 1 As [RowsChange]
        from @TableChanges
        ) p
  PIVOT
  (
   Count([RowsChange])
   FOR [Action] IN ([INSERT], [UPDATE], [DELETE])
  ) As pvt;

  set @rowsInserted = IsNull(@rowsInserted, 0) + IsNull(@iCountTempo, 0);

  /* Ajustar versiones intermedias, fecha fin debe ser igual a fecha siguiente */
  if (@countRow > 0)
  begin
   set @iCountTempo = 0;

   WITH [CTE_V] AS 
   (
    SELECT [CompaniaId],[FechaIniSKId],[FechaFinSKId]
	  ,LEAD([FechaIniSKId]) OVER(PARTITION BY [CompaniaId] ORDER BY [CompaniaId], [FechaIniSKId]) [FechaFinSKId_Next]
    FROM [DW].[DimCompania] D
    WHERE EXISTS (SELECT 1 FROM @MidleRow M WHERE M.[CompaniaId] = D.[CompaniaId]) 
   ) 
   UPDATE D SET
     [FechaFinSKId] = V.[FechaFinSKId_Next]
    ,[BitacoraId] = @bitacoraId
   FROM [CTE_V] V INNER JOIN [DW].[DimCompania] D ON D.[CompaniaId] = V.[CompaniaId] AND D.[FechaIniSKId] = V.[FechaIniSKId]
   WHERE V.[FechaFinSKId] != V.[FechaFinSKId_Next] OR (V.[FechaFinSKId] IS NULL AND V.[FechaFinSKId_Next] IS NOT NULL);
   SET @iCountTempo = @@ROWCOUNT;
  
   SET @rowsUpdated = IsNull(@rowsUpdated, 0) + IsNull(@iCountTempo, 0);
  end;

  /* Insertar filas con menor fecha */
  WITH [CTE_Date] As
  (
   SELECT Source.[CompaniaId],Source.[Nombre],Source.[Sigla],Source.[Nit],Source.[TipoPropiedad],Source.[Activa],Source.[FechaIniSKId],Source.[FechaFinSKId]
   ,LEAD(Source.[FechaIniSKId]) OVER(PARTITION BY Source.[CompaniaId] ORDER BY Source.[CompaniaId], Source.[FechaIniSKId]) [FechaFinSKId_Next]
   ,Target.[FechaIniSKId] [FechaFinSKId_Target]
   ,ROW_NUMBER() OVER (PARTITION BY Source.[CompaniaId] ORDER BY Source.[CompaniaId],Source.[FechaIniSKId]) [Row]
   FROM [Staging].[TmpDimCompania] Source
   INNER JOIN [DW].[DimCompania] AS Target WITH (NOLOCK) ON Target.[CompaniaId] = Source.[CompaniaId]  
   AND Source.[FechaIniSKId] < (SELECT Min(T.[FechaIniSKId]) FROM [DW].[DimCompania] T WITH (NOLOCK) WHERE T.[CompaniaId] = Source.[CompaniaId])
   WHERE Source.[Inconsistent] = 0
   AND Target.[FechaIniSKId] = (SELECT Min(T2.[FechaIniSKId]) FROM [DW].[DimCompania] AS T2 WITH (NOLOCK) WHERE T2.[CompaniaId] = Target.[CompaniaId])
  )
   INSERT INTO [DW].[DimCompania] ([CompaniaId],[Nombre],[Sigla],[Nit],[TipoPropiedad],[Activa],[EsActual],[FechaIniSKId],[FechaFinSKId],[BitacoraId])
  SELECT Source.[CompaniaId],Source.[Nombre],Source.[Sigla],Source.[Nit],Source.[TipoPropiedad],Source.[Activa]
  , 0, Source.[FechaIniSKId], ISNULL(Source.[FechaFinSKId_Next], Source.[FechaFinSKId_Target]), @bitacoraId
  FROM [CTE_Date] Source;
  SET @iCountTempo = @@ROWCOUNT;
  SET @rowsUpdated = IsNull(@rowsUpdated, 0) + IsNull(@iCountTempo, 0);

  COMMIT; 
 END TRY 
 BEGIN CATCH
  IF @@TRANCOUNT > 0
  Begin
   ROLLBACK;
  end;

  SELECT @message = [Utility].[GetErrorCurrentToString]();
  set @message = 'Error al cargar dimension: ' + Coalesce(@message, '');

  /* En RAISERROR, severidad 10: Informativo, 16: Error */
  EXECUTE [Audit].[spBitacora_Error] @bitacoraId, 'spLoadDimCompania', @message; 
  RAISERROR(@message, 16, 1); 
 END CATCH  
 
Salir:
 IF OBJECT_ID('tempdb..#DimCompania_spLoad') IS NOT NULL
 begin
  DROP TABLE #DimCompania_spLoad;
 end;  	 
 
 SELECT @rowsError = Count(*)
 FROM [Staging].[TmpDimCompania] 
 WHERE [Inconsistent] = 1;

 EXECUTE [Audit].[spBitacoraStatistic_End] @item, NULL, NULL, @rowsConsulted, @rowsError, @rowsInserted, @rowsUpdated, 0;

 set nocount off;
End
GO

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - End script: A13SP_DW_Dim2.sql'
PRINT '------------------------------------------------------------------------'
GO