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
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - Start script: A14SP_Util_Load.sql'
PRINT '------------------------------------------------------------------------'
GO

USE [$(DATABASE_NAME_DW)];

/* ====================================================================================
UTILIDADES CARGA
==================================================================================== */
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[spLoadModelVersion]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_EXECUTEsql @statement = N'CREATE PROCEDURE [Utility].[spLoadModelVersion] AS' 
END
GO
ALTER PROCEDURE [Utility].[spLoadModelVersion] 
 @bitacoraId bigint = 0
As
/* ============================================================================================
Proposito: Inserta o actualiza los datos de tabla ModelVersion utilizados los datos de la base de dato de tabla temporal de la base de datos staging area.
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2017-04-10
Fecha actualizacion: 2020-07-15

Parametros:
 @bitacoraId: Código de ejecución de proceso.

Ejemplo:
EXECUTE [Utility].[spLoadModelVersion] 0;

SELECT * FROM [Utility].[ModelVersion];
============================================================================================ */
begin
 set nocount on;

 -- Auditoria registros duplicados
 ;WITH [CTE_I] AS
 (
  SELECT [DateVersion], [ModelId] 
    , ROW_NUMBER() OVER (PARTITION BY [DateVersion], [ModelId] ORDER BY [DateVersion], [ModelId], [DateStart], [DateEnd], [Version] DESC) [Fila]
  FROM [Staging].[TmpModelVersion] 
 )
 INSERT INTO [Audit].[BitacoraTable]([BitacoraId],[Name],[StateId],[SeverityId],[TypeId],[DateRun],[DateWork],[TableTarget]
  ,[FieldTarget],[ValueTarget],[TableSource],[FieldSource],[ValueSource],[PKField1],[PKValue1],[PKField2],[PKValue2],[PKField3],[PKValue3]
  ,[PKField4],[PKValue4],[PKField5],[PKValue5],[Message])
 SELECT @bitacoraId, 'spLoadModelVersion', 1, 2, 4, GetDate(), NULL, 'Utility.ModelVersion', NULL, NULL, 'TMP.TmpModelVersion', NULL
   ,NULL, 'DateVersion', [DateVersion], 'ModelId', [ModelId], NULL, NULL, NULL, NULL, NULL, NULL, 'Datos repetidos'
 FROM [CTE_I] WHERE [Fila] > 1;

 -- Marcar registros duplicados
 ;WITH [CTE_I] AS
 (
  SELECT [TmpSKId] 
    , ROW_NUMBER() OVER (PARTITION BY [DateVersion], [ModelId] ORDER BY [DateVersion], [ModelId], [DateStart], [DateEnd], [Version] DESC) [Fila]
  FROM [Staging].[TmpModelVersion] 
 )
 UPDATE T SET
  [Inconsistent] = 1 
 FROM [Staging].[TmpModelVersion] T INNER JOIN [CTE_I] I ON I.[TmpSKId] = T.[TmpSKId] 
 WHERE I.[Fila] > 1;

 MERGE [Utility].[ModelVersion] AS Target
 USING (SELECT TOP 100 PERCENT [DateVersion],[ModelId],[DateStart],[DateEnd],[Version],[VersionId] 
        FROM [Staging].[TmpModelVersion] 
		WHERE [Inconsistent] = 0
		ORDER BY [DateVersion],[ModelId]) AS Source
 ON (Target.[DateVersion] = Source.[DateVersion] AND Target.[ModelId] = Source.[ModelId])
 -- Cuando cazan, actualzar si hay algun cambio
 WHEN MATCHED AND 
  (   Target.[DateStart] <> Source.[DateStart] 
   OR Target.[DateEnd] <> Source.[DateEnd] 
   OR Target.[Version] <> Source.[Version] 
   OR Target.[VersionId] <> Source.[VersionId]  ) THEN
  UPDATE SET 
    Target.[DateStart] = Source.[DateStart]
   ,Target.[DateEnd] = Source.[DateEnd]
   ,Target.[Version] = Source.[Version]
   ,Target.[VersionId] = Source.[VersionId]
   ,Target.[StateId] = 20 /* Programado para ejecutar */
   ,Target.[UpdateBitacoraId] = @bitacoraId
   ,Target.[UpdateDate] = GetDate()
 -- Cuando no cazan, insertar
 WHEN NOT MATCHED BY TARGET THEN
  INSERT ([DateVersion],[ModelId],[DateStart],[DateEnd],[Version],[VersionId],[StateId]
   ,[CreateBitacoraId],[CreateDate],[UpdateBitacoraId],[UpdateDate])
  VALUES (Source.[DateVersion], Source.[ModelId], Source.[DateStart], Source.[DateEnd], Source.[Version], Source.[VersionId], 20 /* Programado para ejecutar */
   , @bitacoraId, GetDate(), @bitacoraId, GetDate());
 -- Cuando existe una fila en el destino, pero no en el origen: No borrar (DELETE;)

 set nocount off;
End
GO

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - End script: A14SP_Util_Load.sql'
PRINT '------------------------------------------------------------------------'
GO