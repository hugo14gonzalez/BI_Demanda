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
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - Start script: A14SP_DW_Fact.sql'
PRINT '------------------------------------------------------------------------'
GO

USE [$(DATABASE_NAME_DW)];


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DW].[spLoadFactDemandaPerdida]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_EXECUTEsql @statement = N'CREATE PROCEDURE [DW].[spLoadFactDemandaPerdida] AS' 
END
GO
ALTER PROCEDURE [DW].[spLoadFactDemandaPerdida] 
  @bitacoraId bigint
 ,@queryStringParameters nvarchar(4000)
As
/* ============================================================================================
Proposito: Carga datos a la tabla FactDemandaPerdida utilizados los datos de la tabla temporal staging area.
Los datos son borrados antes de insertar, en el rango de fechas de proceso.
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2020-07-15
Fecha actualizacion: 2020-07-15

Parametros:
 @bitacoraId: Código de ejecución de proceso.
 @queryStringParameters: Query string con parametros. En formato @p1=value1&@p2=value&@p3=value3
  Formato: @dateVersion=2017-01-01&@dateStart=2017-01-01&@dateEnd=2017-02-01&@version=0&@versionId=0
  Cuando las fechas son tipos de datos texto, por lo general estan en formato: YYYY-MM-DD. 
  Pero si las fechas el tipo de datos es fecha, es preferible enviar los datos en formato: YYYYMMDD.

Ejemplo:
EXECUTE [DW].[spLoadFactDemandaPerdida] 0, '@dateVersion=2017-01-01&@dateStart=2017-01-01&@dateEnd=2017-02-01&@version=0&@versionId=0';
SELECT * FROM [DW].[FactDemandaPerdida];
============================================================================================ */
begin
 set nocount on;
 
 Declare @message nvarchar(max), @i int, @countRow int;
 Declare @DateVersion date, @DateStart date, @DateEnd date, @version int, @versionId nvarchar(10), @skId int, @okRowInserted bit;
 Declare @item bigint, @rowsConsulted bigint, @rowsError bigint, @rowsInserted bigint, @rowsDeleted bigint, @DateWork varchar(10), @dtDateWork date;
 Declare @AgenteId varchar(20), @PaisId varchar(10), @DepartamentoId varchar(10), @MunicipioId varchar(10); 
 Declare @Mercado varchar(20), @fechaIni date, @dateInfer date, @minGeografiaSKId int, @minMercadoSKId smallint;

 BEGIN TRY
  EXECUTE [Audit].[spBitacoraStatistic_Start] @bitacoraId, @item OUTPUT, NULL, 'FactDemandaPerdida';

  set @rowsConsulted = 0;
  set @rowsError = 0;
  set @rowsInserted = 0;
  set @rowsDeleted = 0;

  /* Establecer parámetros de configuración */
  SELECT @DateVersion = [DateVersion], @DateStart = [DateStart], @DateEnd = [DateEnd], @version = [Version], @versionId = [VersionId], @DateWork =[DateWork] 
  FROM [Utility].[GetParametersModuleProgramming](@queryStringParameters);

  set @dtDateWork = convert(date,@DateWork,120);

  if (@DateStart IS NULL)
  begin
   GOTO Salir;
  end;

  SELECT @rowsConsulted = Count(*) 
  FROM [Staging].[TmpFactDemandaPerdida] 
  WHERE [Fecha] >= @DateStart AND [Fecha] < @DateEnd;

  /* Si no hay datos, no hacer nada y registrar auditoria */
  if (@rowsConsulted = 0)
  begin
   INSERT INTO [Audit].[BitacoraTable]([BitacoraId],[Name],[StateId],[SeverityId],[TypeId],[DateRun],[DateWork],[TableTarget]
    ,[FieldTarget],[ValueTarget],[TableSource],[FieldSource],[ValueSource],[PKField1],[PKValue1],[PKField2],[PKValue2],[PKField3],[PKValue3]
   ,[PKField4],[PKValue4],[PKField5],[PKValue5],[Message])
   VALUES (@bitacoraId, 'spLoadFactDemandaPerdida', 13, 2, 3, GetDate(), @dtDateWork, 'DW.FactDemandaPerdida', NULL, NULL, 'Staging.TmpFactDemandaPerdida'
   , NULL, NULL, 'FechaIni', Convert(nvarchar(10), @DateStart, 120), 'FechaFin', Convert(nvarchar(10), @DateEnd, 120), NULL, NULL, NULL, NULL, NULL, NULL, 'Datos ausente');
   GOTO Salir;
  end;

 /* Insertar datos a la dimension fecha */
 EXECUTE [DW].[spLoadDimDateNext] @DateStart, @DateEnd;
   
 set @minGeografiaSKId = (SELECT Min([GeografiaSKId]) FROM [DW].[DimGeografia]);
 set @minMercadoSKId = (SELECT Min([MercadoSKId]) FROM [DW].[DimMercado]);

 /* Por facilidad al inicio es buscada FK de geografia */

 /* Actualizar SK - DimGeografia */
 UPDATE T SET
  [GeografiaSKId] = E.[GeografiaSKId]
 FROM [Staging].[TmpFactDemandaPerdida] T
 INNER JOIN [DW].[DimGeografia] E WITH (NOLOCK) ON E.[PaisId] = T.[PaisId] AND E.[DepartamentoId] = T.[DepartamentoId] AND E.[MunicipioId] = T.[MunicipioId]
 WHERE T.[Fecha] >= @DateStart AND T.[Fecha] < @DateEnd AND T.[Inconsistent] = 0;

 UPDATE [Staging].[TmpFactDemandaPerdida] SET
  [GeografiaSKId] = @minGeografiaSKId
 WHERE [Inconsistent] = 0 AND [GeografiaSKId] IS NULL AND ([PaisId] IN ('0', '') OR [PaisId] IS NULL);

 UPDATE [Staging].[TmpFactDemandaPerdida] SET
  [GeografiaSKId] = @minGeografiaSKId
 WHERE [Inconsistent] = 0 AND [GeografiaSKId] IS NULL AND ([DepartamentoId] IN ('') OR [DepartamentoId] IS NULL);

 UPDATE [Staging].[TmpFactDemandaPerdida] SET
  [GeografiaSKId] = @minGeografiaSKId
 WHERE [Inconsistent] = 0 AND [GeografiaSKId] IS NULL AND ([MunicipioId] IN ('') OR [MunicipioId] IS NULL);

 /* Inferir datos no encontrados - DimGeografia */
 DECLARE Cur_Loop CURSOR FORWARD_ONLY READ_ONLY FOR
 SELECT DISTINCT [PaisId], [DepartamentoId], [MunicipioId]
 FROM [Staging].[TmpFactDemandaPerdida] 
 WHERE [Fecha] >= @DateStart AND [Fecha] < @DateEnd AND [GeografiaSKId] IS NULL AND [Inconsistent] = 0
 ORDER BY [PaisId], [DepartamentoId], [MunicipioId];
    
 OPEN Cur_Loop;
 FETCH NEXT FROM Cur_Loop INTO @PaisId, @DepartamentoId, @MunicipioId;
 WHILE @@FETCH_STATUS = 0
 BEGIN   
  SET @skId = NULL;
  EXECUTE [DW].[spInferDimGeografia] @skId OUTPUT, @okRowInserted OUTPUT, @bitacoraId, @PaisId, @DepartamentoId, @MunicipioId;
  if (@skId IS NULL)
  begin
   UPDATE [Staging].[TmpFactDemandaPerdida] SET 
    [Inconsistent] = 1
   WHERE [Fecha] >= @DateStart AND [Fecha] < @DateEnd 
   AND [PaisId] = @PaisId AND [DepartamentoId] = @DepartamentoId AND [MunicipioId] = @MunicipioId AND [Inconsistent] = 0;

   /* Auditoria SK no encontrada - DimGeografia */
   INSERT INTO [Audit].[BitacoraTable]([BitacoraId],[Name],[StateId],[SeverityId],[TypeId],[DateRun],[DateWork],[TableTarget]
    ,[FieldTarget],[ValueTarget],[TableSource],[FieldSource],[ValueSource],[PKField1],[PKValue1],[PKField2],[PKValue2],[PKField3],[PKValue3]
    ,[PKField4],[PKValue4],[PKField5],[PKValue5],[Message])
   VALUES (@bitacoraId, 'spLoadFactDemandaPerdida', 1, 2, 5, GetDate(), @dtDateWork, 'DW.FactDemandaPerdida', 'GeografiaSKId', NULL, 'Staging.TmpFactDemandaPerdida', NULL
    ,NULL, 'PaisId', @PaisId, 'DepartamentoId', @DepartamentoId, 'MunicipioId', @MunicipioId, NULL, NULL, NULL, NULL, 'Clave foranea no encontrada');
  end
  else
  begin
   UPDATE [Staging].[TmpFactDemandaPerdida] SET 
    [GeografiaSKId] = @skId
   WHERE [Fecha] >= @DateStart AND [Fecha] < @DateEnd 
   AND [PaisId] = @PaisId AND [DepartamentoId] = @DepartamentoId AND [MunicipioId] = @MunicipioId AND [Inconsistent] = 0;
   
   /* Auditoria SK inferido - DimGeografia */
   INSERT INTO [Audit].[BitacoraTable]([BitacoraId],[Name],[StateId],[SeverityId],[TypeId],[DateRun],[DateWork],[TableTarget]
    ,[FieldTarget],[ValueTarget],[TableSource],[FieldSource],[ValueSource],[PKField1],[PKValue1],[PKField2],[PKValue2],[PKField3],[PKValue3]
    ,[PKField4],[PKValue4],[PKField5],[PKValue5],[Message])
   VALUES (@bitacoraId, 'spLoadFactDemandaPerdida', 0, 1, 6, GetDate(), @dtDateWork, 'DW.FactDemandaPerdida', 'GeografiaSKId', @skId, 'Staging.TmpFactDemandaPerdida', NULL
    ,NULL, 'PaisId', @PaisId, 'DepartamentoId', @DepartamentoId, 'MunicipioId', @MunicipioId, NULL, NULL, NULL, NULL, 'Clave foranea inferida adicionada');
  end;
  FETCH NEXT FROM Cur_Loop INTO @PaisId, @DepartamentoId, @MunicipioId;
 END
 CLOSE Cur_Loop;
 DEALLOCATE Cur_Loop;     

 /* Auditoria registros duplicados */
  ;WITH [CTE_I] AS
  (
   SELECT [Fecha], [PeriodoSKId], [AgenteMemDisId], [Mercado], [GeografiaSKId]
    , ROW_NUMBER() OVER (PARTITION BY [Fecha], [PeriodoSKId], [AgenteMemDisId], [Mercado], [GeografiaSKId]
	   ORDER BY [Fecha], [PeriodoSKId], [AgenteMemDisId], [Mercado], [GeografiaSKId]) [Fila]
   FROM [Staging].[TmpFactDemandaPerdida] 
   WHERE [Fecha] >= @DateStart AND [Fecha] < @DateEnd
  )
  INSERT INTO [Audit].[BitacoraTable]([BitacoraId],[Name],[StateId],[SeverityId],[TypeId],[DateRun],[DateWork],[TableTarget]
   ,[FieldTarget],[ValueTarget],[TableSource],[FieldSource],[ValueSource],[PKField1],[PKValue1],[PKField2],[PKValue2],[PKField3],[PKValue3]
   ,[PKField4],[PKValue4],[PKField5],[PKValue5],[Message])
  SELECT @bitacoraId, 'spLoadFactDemandaPerdida', 1, 2, 4, GetDate(), @dtDateWork, 'DW.FactDemandaPerdida', NULL, NULL, 'Staging.TmpFactDemandaPerdida'
   , NULL, NULL, 'Fecha', [Fecha], 'PeriodoSKId', [PeriodoSKId], 'AgenteMemDisId', [AgenteMemDisId], 'Mercado', [Mercado], 'GeografiaSKId', [GeografiaSKId], 'Datos repetidos'
  FROM [CTE_I] WHERE [Fila] > 1;

  /* Marcar registros duplicados */
  ;WITH [CTE_I] AS
  (
   SELECT [TmpSKId]
    , ROW_NUMBER() OVER (PARTITION BY [Fecha], [PeriodoSKId], [AgenteMemDisId], [Mercado], [GeografiaSKId]
	   ORDER BY [Fecha], [PeriodoSKId], [AgenteMemDisId], [Mercado], [GeografiaSKId]) [Fila]
   FROM [Staging].[TmpFactDemandaPerdida] 
   WHERE [Fecha] >= @DateStart AND [Fecha] < @DateEnd
  )
  UPDATE T SET
   [Inconsistent] = 1 
  FROM [Staging].[TmpFactDemandaPerdida] T INNER JOIN [CTE_I] I ON I.[TmpSKId] = T.[TmpSKId] 
  WHERE T.[Fecha] >= @DateStart AND T.[Fecha] < @DateEnd AND I.[Fila] > 1;
  
  /* Actualizar SK - Fecha */
  UPDATE T SET
   [FechaSKId] = F.[FechaSKId]
  FROM [Staging].[TmpFactDemandaPerdida] T
  INNER JOIN [DW].[DimFecha] F WITH (NOLOCK) ON F.[Fecha] = T.[Fecha]
  WHERE T.[Fecha] >= @DateStart AND T.[Fecha] < @DateEnd AND [Inconsistent] = 0;
  
  /* Auditoria SK no encontrada - Fecha */
  INSERT INTO [Audit].[BitacoraTable]([BitacoraId],[Name],[StateId],[SeverityId],[TypeId],[DateRun],[DateWork],[TableTarget]
   ,[FieldTarget],[ValueTarget],[TableSource],[FieldSource],[ValueSource],[PKField1],[PKValue1],[PKField2],[PKValue2],[PKField3],[PKValue3]
   ,[PKField4],[PKValue4],[PKField5],[PKValue5],[Message])
  SELECT @bitacoraId, 'spLoadFactDemandaPerdida', 1, 2, 5, GetDate(), @dtDateWork, 'DW.FactDemandaPerdida', 'FechaSKId', NULL, 'Staging.TmpFactDemandaPerdida', 'Fecha'
    ,[Fecha], 'Fecha', [Fecha], 'PeriodoSKId', [PeriodoSKId], 'AgenteMemDisId', [AgenteMemDisId], 'Mercado', [Mercado], 'GeografiaSKId', [GeografiaSKId], 'Clave foranea no encontrada'
  FROM [Staging].[TmpFactDemandaPerdida] 
  WHERE [Fecha] >= @DateStart AND [Fecha] < @DateEnd AND [FechaSKId] IS NULL AND [Inconsistent] = 0;
  
  /* Marcar registros inconsistentes - Fecha */
  UPDATE [Staging].[TmpFactDemandaPerdida] SET
   [Inconsistent] = 1 
  WHERE [Fecha] >= @DateStart AND [Fecha] < @DateEnd AND [FechaSKId] IS NULL AND [Inconsistent] = 0;
  
  /* Actualizar SK - Mercado */
  UPDATE T SET
   [MercadoSKId] = M.[MercadoSKId] 
  FROM [Staging].[TmpFactDemandaPerdida] T
  INNER JOIN [DW].[DimMercado] M WITH (NOLOCK) ON M.[Mercado] = T.[Mercado]
  WHERE T.[Fecha] >= @DateStart AND T.[Fecha] < @DateEnd AND T.[Inconsistent] = 0;

  /* Auditoria SK no encontrada - Mercado */
  INSERT INTO [Audit].[BitacoraTable]([BitacoraId],[Name],[StateId],[SeverityId],[TypeId],[DateRun],[DateWork],[TableTarget]
   ,[FieldTarget],[ValueTarget],[TableSource],[FieldSource],[ValueSource],[PKField1],[PKValue1],[PKField2],[PKValue2],[PKField3],[PKValue3]
   ,[PKField4],[PKValue4],[PKField5],[PKValue5],[Message])
  SELECT @bitacoraId, 'spLoadFactDemandaPerdida', 1, 2, 5, GetDate(), @dtDateWork, 'DW.FactDemandaPerdida', 'FechaSKId', NULL, 'Staging.TmpFactDemandaPerdida', 'Mercado'
    ,[Mercado], 'Fecha', [Fecha], 'PeriodoSKId', [PeriodoSKId], 'AgenteMemDisId', [AgenteMemDisId], 'Mercado', [Mercado], 'GeografiaSKId', [GeografiaSKId], 'Clave foranea no encontrada'
  FROM [Staging].[TmpFactDemandaPerdida] 
  WHERE [Fecha] >= @DateStart AND [Fecha] < @DateEnd AND [FechaSKId] IS NULL AND [Inconsistent] = 0;

  UPDATE T SET
   [MercadoSKId] = @minMercadoSKId 
  FROM [Staging].[TmpFactDemandaPerdida] T
  WHERE T.[Fecha] >= @DateStart AND T.[Fecha] < @DateEnd AND T.[MercadoSKId] IS NULL AND T.[Inconsistent] = 0;

 /* Actualizar SK - DimAgente */
 UPDATE T SET
  [AgenteMemDisSKId] = E.[AgenteSKId]
 FROM [Staging].[TmpFactDemandaPerdida] T
 INNER JOIN [DW].[DimAgente] E WITH (NOLOCK) ON E.[AgenteMemId] = T.[AgenteMemDisId]
 AND ( T.[FechaSKId] >= E.[FechaIniSKId] AND (E.[FechaFinSKId] IS NULL OR E.[FechaFinSKId] > T.[FechaSKId]) )
 WHERE T.[Fecha] >= @DateStart AND T.[Fecha] < @DateEnd AND T.[Inconsistent] = 0;
 
 /* Inferir datos no encontrados - DimAgente */
 DECLARE Cur_Loop CURSOR FORWARD_ONLY READ_ONLY FOR
 SELECT DISTINCT [AgenteMemDisId] As [AgenteId], [Fecha] 
 FROM [Staging].[TmpFactDemandaPerdida] 
 WHERE [Fecha] >= @DateStart AND [Fecha] < @DateEnd AND [AgenteMemDisSKId] IS NULL AND [Inconsistent] = 0 
 ORDER BY [AgenteId], [Fecha];
    
 OPEN Cur_Loop;
 FETCH NEXT FROM Cur_Loop INTO @AgenteId, @FechaIni;
 WHILE @@FETCH_STATUS = 0
 BEGIN   
  SET @skId = NULL;
  EXECUTE [DW].[spInferDimAgente] @skId OUTPUT, @okRowInserted OUTPUT, @bitacoraId, @AgenteId, @FechaIni;
  if (@skId IS NULL)
  begin
   UPDATE [Staging].[TmpFactDemandaPerdida] SET 
    [Inconsistent] = 1
   WHERE [AgenteMemDisId] = @AgenteId AND [Fecha] = @FechaIni AND [Inconsistent] = 0;

   /* Auditoria SK no encontrada - DimAgente */
   INSERT INTO [Audit].[BitacoraTable]([BitacoraId],[Name],[StateId],[SeverityId],[TypeId],[DateRun],[DateWork],[TableTarget]
   ,[FieldTarget],[ValueTarget],[TableSource],[FieldSource],[ValueSource],[PKField1],[PKValue1],[PKField2],[PKValue2],[PKField3],[PKValue3]
   ,[PKField4],[PKValue4],[PKField5],[PKValue5],[Message])
   VALUES (@bitacoraId, 'spLoadFactDemandaPerdida', 1, 2, 5, GetDate(), @dtDateWork, 'DW.FactDemandaPerdida', 'AgenteSKId', NULL, 'Staging.TmpFactDemandaPerdida', NULL
   ,NULL, 'AgenteMemDisId', @AgenteId, 'FechaIni', @FechaIni, NULL, NULL, NULL, NULL, NULL, NULL, 'Clave foranea no encontrada');
  end
  else
  begin
   UPDATE [Staging].[TmpFactDemandaPerdida] SET 
    [AgenteMemDisSKId] = @skId
   WHERE [AgenteMemDisId] = @AgenteId AND [Fecha] = @FechaIni AND [Inconsistent] = 0;

   /* Auditoria SK inferido - DimAgente */
   INSERT INTO [Audit].[BitacoraTable]([BitacoraId],[Name],[StateId],[SeverityId],[TypeId],[DateRun],[DateWork],[TableTarget]
   ,[FieldTarget],[ValueTarget],[TableSource],[FieldSource],[ValueSource],[PKField1],[PKValue1],[PKField2],[PKValue2],[PKField3],[PKValue3]
   ,[PKField4],[PKValue4],[PKField5],[PKValue5],[Message])
   VALUES (@bitacoraId, 'spLoadFactDemandaPerdida', 0, 1, 6, GetDate(), @dtDateWork, 'DW.FactDemandaPerdida', 'AgenteSKId', @skId, 'Staging.TmpFactDemandaPerdida', NULL
   ,NULL, 'AgenteMemComId', @AgenteId, 'FechaIni', @FechaIni, NULL, NULL, NULL, NULL, NULL, NULL, 'Clave foranea inferida adicionada');
  end;
  
  FETCH NEXT FROM Cur_Loop INTO @AgenteId, @FechaIni;
 END
 CLOSE Cur_Loop;
 DEALLOCATE Cur_Loop;     
 
  /* Borrar datos existentes */
  DELETE FROM [DW].[FactDemandaPerdida] 
  WHERE [FechaSKId] >= Convert(int, Convert(nvarchar(8), @DateStart, 112)) AND [FechaSKId] < Convert(int, Convert(nvarchar(8), @DateEnd, 112));

  /* Insertar datos */
  INSERT INTO [DW].[FactDemandaPerdida] ([FechaSKId],[PeriodoSKId],[AgenteMemDisSKId],[MercadoSKId],[GeografiaSKId],[DemandaReal],[PerdidaEnergia],[BitacoraId])
  SELECT [FechaSKId],[PeriodoSKId],[AgenteMemDisSKId],[MercadoSKId],[GeografiaSKId],[DemandaReal],[PerdidaEnergia],@bitacoraId
  FROM [Staging].[TmpFactDemandaPerdida] 
  WHERE [Fecha] >= @DateStart AND [Fecha] < @DateEnd AND [Inconsistent] = 0
  ORDER BY [FechaSKId],[PeriodoSKId],[AgenteMemDisSKId],[MercadoSKId];
 
  SELECT @rowsInserted = Count(*)
  FROM [Staging].[TmpFactDemandaPerdida] 
  WHERE [Fecha] >= @DateStart AND [Fecha] < @DateEnd AND [Inconsistent] = 0;
 
  SELECT @rowsError = Count(*)
  FROM [Staging].[TmpFactDemandaPerdida] 
  WHERE [Fecha] >= @DateStart AND [Fecha] < @DateEnd AND [Inconsistent] = 1;

  if (@rowsError = 0)
  begin
   DELETE FROM [Staging].[TmpFactDemandaPerdida] 
   WHERE [Fecha] >= @DateStart AND [Fecha] < @DateEnd;
  end;
 END TRY 
 BEGIN CATCH
  SELECT @message = [Utility].[GetErrorCurrentToString]();
  set @message = 'Error al cargar tabla Fact: ' + Coalesce(@message, '');
  set @message = @message + '. Parametros: ' + Coalesce(@queryStringParameters, '');

  -- En RAISERROR, severidad 10: Informativo, 16: Error 
  EXECUTE [Audit].[spBitacora_Error] @bitacoraId, 'spLoadFactDemandaPerdida', @message; 
  RAISERROR(@message, 16, 1); 
 END CATCH  
 
Salir:
 EXECUTE [Audit].[spBitacoraStatistic_End] @item, @DateWork, NULL, @rowsConsulted, @rowsError, @rowsInserted, 0, @rowsDeleted;

 set nocount off;
End
GO

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - End script: A14SP_DW_Fact.sql'
PRINT '------------------------------------------------------------------------'
GO