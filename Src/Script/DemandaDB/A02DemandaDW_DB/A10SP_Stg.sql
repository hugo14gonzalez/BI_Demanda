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
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - Start script: A10SP_Stg.sql'
PRINT '------------------------------------------------------------------------'
GO

USE [$(DATABASE_NAME_DW)];

/* ====================================================================================
SP TRUNCAR TABLA TEMPORALES
==================================================================================== */
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Staging].[spTruncateTable]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_EXECUTEsql @statement = N'CREATE PROCEDURE [Staging].[spTruncateTable] AS' 
END
GO
ALTER PROCEDURE [Staging].[spTruncateTable] 
  @schema nvarchar (128)
 ,@table nvarchar (128) 
WITH EXECUTE AS SELF 
as 
/* ============================================================================================
Proposito: Trunca una tabla, si está registrada en la lista de tablas permitidas.
 Este SP es invocado en ETLs para evietar errores por permisos al ejecutar la instrucción TRUNCATE TABLE.
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2020-07-15
Fecha actualizacion: 2020-07-15

Parametros:
 @schema: Nombre de esquema
 @table: Nomber de tabla
 @resetIdentity: Si la tabla tiene autonumerico, reinicia el consecutivo en uno.
 
Ejemplo:
EXECUTE [Staging].[spTruncateTable] 'EsquemaError', 'TablaError';
EXECUTE [Staging].[spTruncateTable] 'TMP', 'TmpDimGeografia';

SELECT * FROM [Staging].[TruncateList];
============================================================================================ */
begin
 set nocount on

 Declare @result int, @sqlString nvarchar(1000) , @st nvarchar(400)
 Declare @errorMessage nvarchar(4000), @errorNumber INT, @errorSeverity INT, @errorState INT, @errorLine INT, @errorProcedure nvarchar(200); 
 
 set @st = QUOTENAME(@schema) + '.' + QUOTENAME(@table) 
 If exists (select * from [Staging].[TruncateList] Where [SchemaName] = @schema AND [TableName] = @table) 
 Begin 
  set @sqlString = 'TRUNCATE TABLE ' + @st;
  set @result = - 1;

  BEGIN TRY 
   Execute @result = sp_executeSQL @sqlString;
  END TRY 
  BEGIN CATCH 
   SELECT @errorNumber = ERROR_NUMBER (), @errorSeverity = ERROR_SEVERITY (), @errorState = ERROR_STATE (), @errorLine = ERROR_LINE (), @errorProcedure = ISNULL ( ERROR_PROCEDURE (), '-' ); 
   SELECT @errorMessage =  'Error %d, nivel %d, estado %d, procedencia %s, línea %d, ' + 'mensaje: ' + ERROR_MESSAGE (); 
   
   RAISERROR ( @errorMessage , @errorSeverity , 1 , @errorNumber , @errorSeverity , @errorState , @errorProcedure , @errorLine ) 
   RETURN @result 
  END CATCH 
 End 
 ELSE 
 Begin 
  set @errorMessage = 'Objeto no existe o no tiene permisos: ' + @st
  RAISERROR (@errorMessage, 16, 1); 
  Return - 1 
 End 
 
 set nocount off
end
GO

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - End script: A10SP_Stg.sql'
PRINT '------------------------------------------------------------------------'
GO