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
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - Start script: A11SP_DWInfe.sql'
PRINT '------------------------------------------------------------------------'
GO

USE [$(DATABASE_NAME_DW)];

/* ====================================================================================
SOPORTE PARA MIEMBROS INFERIDOS. DIMENSIONES TIPO 1
==================================================================================== */
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DW].[spInferDimGeografia]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_EXECUTEsql @statement = N'CREATE PROCEDURE [DW].[spInferDimGeografia] AS' 
END
GO
ALTER PROCEDURE [DW].[spInferDimGeografia] 
  @skId int = null OUTPUT
 ,@rowInserted bit OUTPUT
 ,@bitacoraId bigint = 0
 ,@PaisId varchar(10)
 ,@DepartamentoId varchar(10)
 ,@MunicipioId varchar(10)
 ,@unknowText varchar(10) = 'NA'
as
/* ============================================================================================
Proposito: Busca la clave subrogada para una clave de negocio dada, si no la encuentra inserta una fila en la tabla de dimensiones
 con los valores comodines dados. Retorna la clave subrogada encontrada o insertada, e indica si fue necesario insertar una nueva fila.
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2020-07-15
Fecha actualizacion: 2020-07-15

Parametros:
 @skId: Parámetro de retorno clave subrogada.
 @rowInserted: Indica si fue necesario insertar fila comodin.
 @bitacoraId: Codigo de ejecución de proceso.
 @PaisId: Codigo de pais.
 @DepartamentoId: Codigo de departamento.
 @MunicipioId: Codigo de municipio.
 @unknowText: Comodin para textos desconocidos
 
Ejemplo:
 Declare @skId int, @rowInserted bit;
 EXECUTE [DW].[spInferDimGeografia] @skId OUTPUT, @rowInserted OUTPUT, 0, '@Test@', '@Test@', '@Test@', '@Test@', '@Test@', '@Test@';
 Select @skId As idSK, @rowInserted As FilaInsertada, @CompaniaSKId;
 
 Select * From [DW].[DimGeografia] Where [PaisId] = '@Test@';
 Delete From [DW].[DimGeografia] Where [PaisId] = '@Test@';
============================================================================================ */
begin
 set nocount on

 set @skId = null;
 set @rowInserted = 0;

 if (@PaisId is null or @DepartamentoId is null or @MunicipioId is null) 
 begin
  return;
 end;
 
 Set @skId = null;
 Select @skId = [GeografiaSKId]
 From [DW].[DimGeografia] WITH (NOLOCK) 
 Where [PaisId] = @PaisId AND [DepartamentoId] = @DepartamentoId AND [MunicipioId] = @MunicipioId;

 if @skId is null
 Begin
  INSERT INTO [DW].[DimGeografia] ([PaisId],[Pais],[DepartamentoId],[Departamento],[MunicipioId],[Municipio],[AreaId],[Area],[SubAreaId],[SubArea],[BitacoraId])
  VALUES (@PaisId,@PaisId,@DepartamentoId,@DepartamentoId,@MunicipioId,@MunicipioId,@unknowText,@unknowText,@unknowText,@unknowText,@bitacoraId);
  Select @skId = SCOPE_IDENTITY(); 
  set @rowInserted = 1;
 end 
 
 set nocount off
End 
GO

/* ====================================================================================
SOPORTE PARA MIEMBROS INFERIDOS. DIMENSIONES TIPO 2
==================================================================================== */
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DW].[spInferDimAgente]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_EXECUTEsql @statement = N'CREATE PROCEDURE [DW].[spInferDimAgente] AS' 
END
GO
ALTER PROCEDURE [DW].[spInferDimAgente] 
  @skId int = null OUTPUT
 ,@rowInserted bit OUTPUT
 ,@bitacoraId bigint = 0
 ,@AgenteMemId varchar(20)
 ,@fechaIni date
 ,@unknowText varchar(10) = 'NA'
 ,@AgenteId varchar(20) = null OUTPUT
 ,@CompaniaSKId int = null OUTPUT
as
/* ============================================================================================
Proposito: Busca la clave subrogada para una clave de negocio dada, si no la encuentra inserta una fila en la tabla de dimensiones
 con los valores comodines dados. Retorna la clave subrogada encontrada o insertada, e indica si fue necesario insertar una nueva fila.
 Por ser dimension tipo 2, tiene tratamiento especial para manejo de vigencias.
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2020-07-15
Fecha actualizacion: 2020-07-15

Parametros:
 @skId: Parámetro de retorno clave subrogada.
 @rowInserted: Indica si fue necesario insertar fila comodin.
 @bitacoraId: Codigo de ejecución de proceso.
 @AgenteMemeId: Codigo de agente MEM.
 @fechaIni: Fecha inicio de los datos. Por ser dimension tipo 2, esta fecha es utilizado para seleccionar la vigencia apropiada.
 @unknowText: Comodin para textos desconocidos
 @AgenteId: Parámetro de retorno, codigo de agente.
 @CompaniaSKId: Parámetro de retorno, clave subrogada de empresa.
  
Ejemplo:
 Declare @skId int, @rowInserted bit, @AgenteId smallint, @CompaniaSKId int, @fechaIni date;
 set @fechaIni = GetDate();
 EXECUTE [DW].[spInferDimAgente] @skId OUTPUT, @rowInserted OUTPUT, 0, '@Test@', @fechaIni, 'NA'
 , @CompaniaSKId OUTPUT, @ZonaSKId OUTPUT, @NivelTensionSKId OUTPUT;
 Select @skId As idSK, @rowInserted As FilaInsertada, @CompaniaSKId, @ZonaSKId, @NivelTensionSKId;

 Declare @skId int, @rowInserted bit, @ZonaSKId smallint, @CompaniaSKId int, @fechaIni date, @NivelTensionSKId smallint;
 set @fechaIni = DATEADD(month, -3, GetDate());
 EXECUTE [DW].[spInferDimAgente] @skId OUTPUT, @rowInserted OUTPUT, 1, '@Test@', @fechaIni, 'NA'
 , @CompaniaSKId OUTPUT, @ZonaSKId OUTPUT, @NivelTensionSKId OUTPUT;
 Select @skId As idSK, @rowInserted As FilaInsertada, @CompaniaSKId, @ZonaSKId, @NivelTensionSKId;
 
 Declare @skId int, @rowInserted bit, @ZonaSKId smallint, @CompaniaSKId int, @fechaIni date, @NivelTensionSKId smallint;
 set @fechaIni = DATEADD(month, -1, GetDate());
 EXECUTE [DW].[spInferDimAgente] @skId OUTPUT, @rowInserted OUTPUT, 2, '@Test@', @fechaIni, 'NA'
 , @CompaniaSKId OUTPUT, @ZonaSKId OUTPUT, @NivelTensionSKId OUTPUT;
 Select @skId As idSK, @rowInserted As FilaInsertada, @CompaniaSKId, @ZonaSKId, @NivelTensionSKId;

 Declare @skId int, @rowInserted bit, @ZonaSKId smallint, @CompaniaSKId int, @fechaIni date, @NivelTensionSKId smallint;
 set @fechaIni = DATEADD(month, 1, GetDate());
 EXECUTE [DW].[spInferDimAgente] @skId OUTPUT, @rowInserted OUTPUT, 3, '@Test@', @fechaIni, 'NA'
 , @CompaniaSKId OUTPUT, @ZonaSKId OUTPUT, @NivelTensionSKId OUTPUT;
 Select @skId As idSK, @rowInserted As FilaInsertada, @CompaniaSKId, @ZonaSKId, @NivelTensionSKId;

 Select * From [DW].[DimAgente] Where [AgenteId] = '@Test@'; 
 Delete From [DW].[DimAgente] Where [AgenteId] = '@Test@';
============================================================================================ */
begin
 set nocount on
 Declare @fechaIniSK int, @maxFechaIniSK int, @isCurrent bit, @FuenteSKId smallint;

 set @skId = null;
 set @rowInserted = 0;
 set @CompaniaSKId = null;
 set @AgenteId = null;

 if (@AgenteMemId is null OR RTrim(@AgenteMemId) = '') 
 begin
  return;
 end;
 
 SELECT @fechaIniSK = [FechaSKId] FROM [DW].[DimFecha] WITH (NOLOCK) WHERE [Fecha] = @fechaIni;
 Set @skId = null;
 Select @skId = [AgenteSKId], @CompaniaSKId = [CompaniaSKId], @AgenteId = [AgenteId]
 From [DW].[DimAgente] WITH (NOLOCK) 
 Where [AgenteMemId] = @AgenteMemId AND ([FechaIniSKId] <= @fechaIniSK AND ([FechaFinSKId] IS NULL OR [FechaFinSKId] < @fechaIniSK));

 if @skId is null
 Begin
  set @unknowText = Coalesce(@unknowText, 'NA');
  set @AgenteId = @AgenteMemId;
  select @CompaniaSKId = MIN([CompaniaSKId]) From [DW].[DimCompania] WITH (NOLOCK);

  SELECT @maxFechaIniSK = Max([FechaIniSKId]) FROM [DW].[DimAgente] WITH (NOLOCK) WHERE [AgenteId] = @AgenteId;
  if (@maxFechaIniSK IS NULL OR @fechaIniSK > @maxFechaIniSK)
  begin
   set @isCurrent = 1;
  end
  else
  begin
   set @isCurrent = 0;
  end;

  INSERT INTO [DW].[DimAgente]([AgenteId],[AgenteMemId],[Nombre],[Actividad],[CompaniaSKId],[Activo],[EsActual],[FechaIniSKId],[FechaFinSKId],[BitacoraId])
  VALUES (@AgenteId, @AgenteMemId, @AgenteMemId,@unknowText,@CompaniaSKId,1,@isCurrent,@fechaIniSK,NULL,@bitacoraId);
  Select @skId = SCOPE_IDENTITY(); 
  set @rowInserted = 1;

  if (@fechaIniSK > @maxFechaIniSK)
  begin
   UPDATE [DW].[DimAgente] SET
     [EsActual] = 0
    ,[BitacoraId] = @bitacoraId
   WHERE [AgenteId] = @AgenteId AND [FechaIniSKId] = @maxFechaIniSK;
  end;

  /* Ajustar versiones intermedias, fecha fin debe ser igual a la fecha siguiente */
  if (@maxFechaIniSK IS NOT NULL)
  begin
   WITH [CTE_V] AS 
   (
    SELECT [AgenteId],[FechaIniSKId],[FechaFinSKId]
	   ,LEAD([FechaIniSKId]) OVER(PARTITION BY [AgenteId] ORDER BY [AgenteId], [FechaIniSKId]) [FechaFinSKId_Next]
    FROM [DW].[DimAgente] D WITH (NOLOCK)
    WHERE D.[AgenteId] = @AgenteId 
   ) 
   UPDATE D SET
     [FechaFinSKId] = V.[FechaFinSKId_Next]
    ,[BitacoraId] = @bitacoraId
   FROM [CTE_V] V INNER JOIN [DW].[DimAgente] D ON D.[AgenteId] = V.[AgenteId] AND D.[FechaIniSKId] = V.[FechaIniSKId]
   WHERE V.[FechaFinSKId] != V.[FechaFinSKId_Next] OR (V.[FechaFinSKId] IS NULL AND V.[FechaFinSKId_Next] IS NOT NULL);
  end;
 end; 
 
 set nocount off
End 
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DW].[spInferDimCompania]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_EXECUTEsql @statement = N'CREATE PROCEDURE [DW].[spInferDimCompania] AS' 
END
GO
ALTER PROCEDURE [DW].[spInferDimCompania] 
  @skId int = null OUTPUT
 ,@rowInserted bit OUTPUT
 ,@bitacoraId bigint = 0
 ,@CompaniaId varchar(20)
 ,@fechaIni date
 ,@unknowText varchar(10) = 'NA'
as
/* ============================================================================================
Proposito: Busca la clave subrogada para una clave de negocio dada, si no la encuentra inserta una fila en la tabla de dimensiones
 con los valores comodines dados. Retorna la clave subrogada encontrada o insertada, e indica si fue necesario insertar una nueva fila.
 Por ser dimension tipo 2, tiene tratamiento especial para manejo de vigencias.
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2020-07-15
Fecha actualizacion: 2020-07-15

Parametros:
 @skId: Parámetro de retorno clave subrogada.
 @rowInserted: Indica si fue necesario insertar fila comodin.
 @bitacoraId: Codigo de ejecución de proceso.
 @CompaniaId: Codigo de Compañia.
 @fechaIni: Fecha inicio de los datos. Por ser dimension tipo 2, esta fecha es utilizado para seleccionar la vigencia apropiada.
 @unknowText: Comodin para textos desconocidos
  
Ejemplo:
 Declare @skId int, @rowInserted bit, @fechaIni date;
 set @fechaIni = GetDate();
 EXECUTE [DW].[spInferDimCompania] @skId OUTPUT, @rowInserted OUTPUT, 0, '@Test@', @fechaIni;
 Select @skId As idSK, @rowInserted As FilaInsertada;

 Declare @skId int, @rowInserted bit, @fechaIni date;
 set @fechaIni = DATEADD(month, -3, GetDate());
 EXECUTE [DW].[spInferDimCompania] @skId OUTPUT, @rowInserted OUTPUT, 1, '@Test@', @fechaIni;
 Select @skId As idSK, @rowInserted As FilaInsertada;
 
 Declare @skId int, @rowInserted bit, @fechaIni date;
 set @fechaIni = DATEADD(month, '@Test@', GetDate());
 EXECUTE [DW].[spInferDimCompania] @skId OUTPUT, @rowInserted OUTPUT, 2, '@Test@', @fechaIni;
 Select @skId As idSK, @rowInserted As FilaInsertada;

 Declare @skId int, @rowInserted bit, @fechaIni date;
 set @fechaIni = DATEADD(month, 1, GetDate());
 EXECUTE [DW].[spInferDimCompania] @skId OUTPUT, @rowInserted OUTPUT, 3, '@Test@', @fechaIni;
 Select @skId As idSK, @rowInserted As FilaInsertada;

 Select * From [DW].[DimCompania] Where [CompaniaId] = '@Test@'; 
 Delete From [DW].[DimCompania] Where [CompaniaId] = '@Test@';
============================================================================================ */
begin
 set nocount on
 Declare @fechaIniSK int, @maxFechaIniSK int, @isCurrent bit;

 set @skId = null;
 set @rowInserted = 0;
 
 if (@CompaniaId is null) 
 begin
  return;
 end;
 
 SELECT @fechaIniSK = [FechaSKId] FROM [DW].[DimFecha] WITH (NOLOCK) WHERE [Fecha] = @fechaIni;
 Set @skId = null;
 Select @skId = [CompaniaSKId]
 From [DW].[DimCompania] WITH (NOLOCK) 
 Where [CompaniaId] = @CompaniaId AND ([FechaIniSKId] <= @fechaIniSK AND ([FechaFinSKId] IS NULL OR [FechaFinSKId] < @fechaIniSK));

 if @skId is null
 Begin
  set @unknowText = Coalesce(@unknowText, 'NA');

  SELECT @maxFechaIniSK = Max([FechaIniSKId]) FROM [DW].[DimCompania] WITH (NOLOCK) WHERE [CompaniaId] = @CompaniaId;
  if (@maxFechaIniSK IS NULL OR @fechaIniSK > @maxFechaIniSK)
  begin
   set @isCurrent = 1;
  end
  else
  begin
   set @isCurrent = 0;
  end;

  INSERT INTO [DW].[DimCompania]([CompaniaId],[Nombre],[Sigla],[Nit],[TipoPropiedad],[Activa],[EsActual],[FechaIniSKId],[FechaFinSKId],[BitacoraId])
  VALUES (@CompaniaId, @CompaniaId, @CompaniaId, @unknowText, @unknowText, 1, @isCurrent,@fechaIniSK,NULL,@bitacoraId);
  Select @skId = SCOPE_IDENTITY(); 
  set @rowInserted = 1;

  if (@fechaIniSK > @maxFechaIniSK)
  begin
   UPDATE [DW].[DimCompania] SET
     [EsActual] = 0
    ,[BitacoraId] = @bitacoraId
   WHERE [CompaniaId] = @CompaniaId AND [FechaIniSKId] = @maxFechaIniSK;
  end;

  /* Ajustar versiones intermedias, fecha fin debe ser igual a la fecha siguiente */
  if (@maxFechaIniSK IS NOT NULL)
  begin
   WITH [CTE_V] AS 
   (
    SELECT [CompaniaId],[FechaIniSKId],[FechaFinSKId]
	 ,LEAD([FechaIniSKId]) OVER(PARTITION BY [CompaniaId] ORDER BY [CompaniaId], [FechaIniSKId]) [FechaFinSKId_Next]
    FROM [DW].[DimCompania] D WITH (NOLOCK)
    WHERE D.[CompaniaId] = @CompaniaId 
   ) 
   UPDATE D SET
     [FechaFinSKId] = V.[FechaFinSKId_Next]
    ,[BitacoraId] = @bitacoraId
   FROM [CTE_V] V INNER JOIN [DW].[DimCompania] D ON D.[CompaniaId] = V.[CompaniaId] AND D.[FechaIniSKId] = V.[FechaIniSKId]
   WHERE V.[FechaFinSKId] != V.[FechaFinSKId_Next] OR (V.[FechaFinSKId] IS NULL AND V.[FechaFinSKId_Next] IS NOT NULL);
  end;
 end; 
 
 set nocount off
End 
GO

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - End script: A11SP_DWInfe.sql'
PRINT '------------------------------------------------------------------------'
GO