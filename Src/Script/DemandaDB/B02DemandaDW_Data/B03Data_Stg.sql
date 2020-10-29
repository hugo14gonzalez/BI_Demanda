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
PRINT 'Inicio script: B03Data_Stg.sql'
PRINT '------------------------------------------------------------------------'
GO

USE [$(DATABASE_NAME_DW)];

/* ========================================================================== 
SELECT * FROM [Staging].[TruncateList] ORDER BY [SchemaName], [TableName];
========================================================================== */
set nocount on

declare @sqlString nvarchar(4000);
DECLARE Cul_Loop CURSOR FOR 
 SELECT 'IF NOT EXISTS(SELECT * FROM [Staging].[TruncateList] WHERE [SchemaName] = ''' + S.name + ''' AND [TableName] = ''' + O.name + ''')
  INSERT INTO [Staging].[TruncateList] ([SchemaName], [TableName]) VALUES (''' + S.name + ''', ''' + O.name + ''');' 
 FROM sys.objects O INNER JOIN sys.schemas S ON O.schema_id = S.schema_id 
 WHERE O.type = 'U' AND S.name = 'Staging' AND O.name <> 'TruncateList';
OPEN Cul_Loop
FETCH NEXT FROM Cul_Loop INTO @sqlString
 WHILE @@fetch_status = 0
 BEGIN
  --print @sqlString
  Execute sp_executeSQL @sqlString 
 FETCH NEXT FROM Cul_Loop INTO @sqlString
END
CLOSE Cul_Loop
DEALLOCATE Cul_Loop
GO

set nocount off
GO

PRINT '------------------------------------------------------------------------'
PRINT 'Fin script: B03Data_Stg.sql'
PRINT '------------------------------------------------------------------------'
GO