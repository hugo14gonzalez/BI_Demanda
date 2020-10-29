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
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - Start script: A13SP_Util_Cube.sql'
PRINT '------------------------------------------------------------------------'
GO

USE [$(DATABASE_NAME_DW)];

/* ====================================================================================
UTILIDADES CUBOS
==================================================================================== */
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[spOLAP_QueryPartition]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_EXECUTEsql @statement = N'CREATE PROCEDURE [Utility].[spOLAP_QueryPartition] AS' 
END
GO
ALTER PROCEDURE [Utility].[spOLAP_QueryPartition] 
  @process bit
 ,@ModuleId int = NULL
 ,@moduleAppName nvarchar(128) = NULL
 ,@TypeId nvarchar(12) = NULL
As
/* ============================================================================================
Proposito: Retorna consulta con las particiones a ser creadas.
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2017-04-10
Fecha actualizacion: 2020-07-15

Parametros:  
 @process: Indica si retorna particiones a ser procesadas
  0: Retorna particiones que requieren ser creadas o actualizadas.  
  1: Retorna particiones que requieren ser procesadas
 @ModuleId: Código de módulo. Si es nulo o menor o igual a cero (0) utiliza los parámetros de nombre y tipo de modulo.
 @moduleAppName: Nombre de módulo en el código de aplicación. Por ejemplo el nombre de una ETL.
  Si suministra el código de módulo, no utiliza este parámetro.
 @TypeId: Código de tipo de módulo. Por ejemplo: ETL, menu de programa.

Ejemplo:
EXECUTE [Utility].[spOLAP_QueryPartition] 0, NULL, 'pkgCubePartitionCreate', 'ETL';
EXECUTE [Utility].[spOLAP_QueryPartition] 1, NULL, 'pkgCubePartitionProcess', 'ETL';

SELECT * FROM [Utility].[ModuleProgramming];
SELECT * FROM [Utility].[CubePartitionDetail];
============================================================================================ */
begin
 set nocount on

 Declare @tmpModelPartition TABLE (
	[ModelPartitionId] [bigint] IDENTITY(1,1) PRIMARY KEY NOT NULL,
	[ModuleId] [int] NOT NULL,
	[ModelProgId] [nvarchar](12) NOT NULL,
	[CubeId] [nvarchar](12) NOT NULL,
	[DateStart] [date] NOT NULL,
	[DateEnd] [date] NOT NULL); 

 if (@ModuleId IS NOT NULL AND @ModuleId > 0)
 begin
  INSERT INTO @tmpModelPartition ([ModuleId], [ModelProgId], [CubeId], [DateStart], [DateEnd])
  SELECT MP.[ModuleId], MP.[ModelProgId], Min(MP.[VersionId]) [CubeId], Min(MP.[DateStart]) [DateStart], Max(MP.[DateEnd]) [DateEnd]
  FROM [Utility].[ModuleProgramming] MP WITH (NOLOCK)
  WHERE MP.[ModuleId] = @ModuleId AND MP.[StateId] IN (20, 21)
  GROUP BY MP.[ModuleId], MP.[ModelProgId] 
  ORDER BY MP.[ModuleId], MP.[ModelProgId];
 end;
 else
 begin
  INSERT INTO @tmpModelPartition ([ModuleId], [ModelProgId], [CubeId], [DateStart], [DateEnd])
  SELECT MP.[ModuleId], MP.[ModelProgId], Min(MP.[VersionId]) [CubeId], Min(MP.[DateStart]) [DateStart], Max(MP.[DateEnd]) [DateEnd]
  FROM [Utility].[ModuleProgramming] MP WITH (NOLOCK)
  INNER JOIN [Utility].[ModuleSystem] M WITH (NOLOCK) ON M.[ModuleId] = MP.[ModuleId]
  WHERE M.[AppName] = @moduleAppName AND M.[TypeId] = @TypeId AND MP.[StateId] IN (20, 21) 
  GROUP BY MP.[ModuleId], MP.[ModelProgId] 
  ORDER BY MP.[ModuleId], MP.[ModelProgId];
 end;

 if (@process = 1)
 begin
  SELECT M.[ModuleId],M.[AppName] [AppNameModule], PD.[CubeId],C.[AppName] [AppNameCube]
   , PD.[ModelId],MO.[AppName] [MeasureGroupName]
   , CP.[Partitioned], CP.[DataSource] [DataSourceName], CP.[PartitionField], CP.[QueryId], Q.[QuerySQL]
   , PD.[PartitionId], PD.[PartitionName], PD.[PartitionNameBefore], PD.[DatePartition], PD.[DateStart], PD.[DateEnd]
   , PD.[UsePathBefore], ISNULL(PD.[StoragePath], '') [StoragePath]
   , PD.[IsFirstPartition],PD.[IsLastPartition],PD.[Create] [CreateParticion],PD.[Update] [UpdatePartition],PD.[Process] [ProcessPartition]
  FROM [Utility].[CubePartitionDetail] PD WITH (NOLOCK)
  INNER JOIN [Utility].[CubePartition] CP WITH (NOLOCK) ON CP.[CubeId] = PD.[CubeId] AND CP.[ModelId] = PD.[ModelId]
  INNER JOIN [Utility].[CubeSystem] C WITH (NOLOCK) ON C.[CubeId] = PD.[CubeId]
  INNER JOIN [Utility].[ModelSystem] MO WITH (NOLOCK) ON MO.[ModelId] = PD.[ModelId]
  INNER JOIN @tmpModelPartition T ON T.[CubeId] = PD.[CubeId] AND T.[ModelProgId] = PD.[ModelId]
  AND PD.[DateStart] >= T.[DateStart] AND PD.[DateStart] <= T.[DateEnd]
  INNER JOIN [Utility].[ModuleSystem] M WITH (NOLOCK) ON M.[ModuleId] = T.[ModuleId]
  LEFT JOIN [Utility].[QuerySQL] Q WITH (NOLOCK) ON Q.[QueryId] = CP.[QueryId]
  ORDER BY M.[ModuleId], PD.[ModelId], PD.[PartitionId];
 end
 else
 begin
  SELECT M.[ModuleId],M.[AppName] [AppNameModule], PD.[CubeId],C.[AppName] [AppNameCube]
   , PD.[ModelId],MO.[AppName] [MeasureGroupName]
   , CP.[Partitioned], CP.[DataSource] [DataSourceName], CP.[PartitionField], CP.[QueryId], Q.[QuerySQL]
   , PD.[PartitionId], PD.[PartitionName], PD.[PartitionNameBefore], PD.[DatePartition], PD.[DateStart], PD.[DateEnd]
   , PD.[UsePathBefore], ISNULL(PD.[StoragePath], '') [StoragePath]
   , PD.[IsFirstPartition],PD.[IsLastPartition],PD.[Create] [CreateParticion],PD.[Update] [UpdatePartition],PD.[Process] [ProcessPartition]
  FROM [Utility].[CubePartitionDetail] PD WITH (NOLOCK)
  INNER JOIN [Utility].[CubePartition] CP WITH (NOLOCK) ON CP.[CubeId] = PD.[CubeId] AND CP.[ModelId] = PD.[ModelId]
  INNER JOIN [Utility].[CubeSystem] C WITH (NOLOCK) ON C.[CubeId] = PD.[CubeId]
  INNER JOIN [Utility].[ModelSystem] MO WITH (NOLOCK) ON MO.[ModelId] = PD.[ModelId]
  INNER JOIN @tmpModelPartition T ON T.[CubeId] = PD.[CubeId] AND T.[ModelProgId] = PD.[ModelId]
  AND PD.[DateStart] >= T.[DateStart] AND PD.[DateStart] <= T.[DateEnd]
  INNER JOIN [Utility].[ModuleSystem] M WITH (NOLOCK) ON M.[ModuleId] = T.[ModuleId]
  LEFT JOIN [Utility].[QuerySQL] Q WITH (NOLOCK) ON Q.[QueryId] = CP.[QueryId]
  ORDER BY M.[ModuleId], PD.[ModelId], PD.[PartitionId];
 end

 set nocount off;
End
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[spOLAP_QueryProgramming]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_EXECUTEsql @statement = N'CREATE PROCEDURE [Utility].[spOLAP_QueryProgramming] AS' 
END
GO
ALTER PROCEDURE [Utility].[spOLAP_QueryProgramming] 
  @ModuleId int = NULL
 ,@moduleAppName nvarchar(128) = NULL
 ,@TypeId nvarchar(12) = NULL
As
/* ============================================================================================
Proposito: Retorna consulta con la programación de carga, es similar al SP: [Utility].[spModuleProgramming_Query].
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2017-04-10
Fecha actualizacion: 2020-07-15

Parametros:  
 @ModuleId: Código de módulo. Si es nulo o menor o igual a cero (0) utiliza los parámetros de nombre y tipo de modulo.
 @moduleAppName: Nombre de módulo en el código de aplicación. Por ejemplo el nombre de una ETL.
  Si suministra el código de módulo, no utiliza este parámetro.
 @TypeId: Código de tipo de módulo. Por ejemplo: ETL, menu de programa.

Ejemplo:
EXECUTE [Utility].[spOLAP_QueryProgramming] 4;
EXECUTE [Utility].[spOLAP_QueryProgramming] NULL, 'pkgCubePartitionCreate', 'ETL';
EXECUTE [Utility].[spOLAP_QueryProgramming] NULL, 'pkgCubePartitionProcess', 'ETL';

SELECT * FROM [Utility].[ModuleProgramming];
SELECT * FROM [Utility].[CubePartition];
============================================================================================ */
begin
 set nocount on

  if (@ModuleId IS NOT NULL OR @ModuleId > 0)
 begin
  SELECT C.[CubeId], MP.[ModelProgId], Min(MP.[DateStart]) [DateStart], Max(MP.[DateEnd]) [DateEnd]
  , (Select TOP 1 C2.[Partitioned] FROM [Utility].[CubePartition] C2 WITH (NOLOCK) WHERE C2.[CubeId] = C.[CubeId] AND C2.[ModelId] = MP.[ModelProgId]) [Partitioned]
  FROM [Utility].[ModuleProgramming] MP WITH (NOLOCK)
  INNER JOIN [Utility].[CubePartition] C WITH (NOLOCK) ON C.[CubeId] = MP.[VersionId] AND C.[ModelId] = MP.[ModelProgId]
  WHERE MP.[ModuleId] = @ModuleId AND MP.[StateId] IN (20, 21)
  GROUP BY C.[CubeId], MP.[ModelProgId]
  ORDER BY C.[CubeId], MP.[ModelProgId];
 end;
 else
 begin
  SELECT C.[CubeId], MP.[ModelProgId], Min(MP.[DateStart]) [DateStart], Max(MP.[DateEnd]) [DateEnd]
  , (Select TOP 1 C2.[Partitioned] FROM [Utility].[CubePartition] C2 WITH (NOLOCK) WHERE C2.[CubeId] = C.[CubeId] AND C2.[ModelId] = MP.[ModelProgId]) [Partitioned]
  FROM [Utility].[ModuleProgramming] MP WITH (NOLOCK)
  INNER JOIN [Utility].[ModuleSystem] M WITH (NOLOCK) ON M.[ModuleId] = MP.[ModuleId]
  INNER JOIN [Utility].[CubePartition] C WITH (NOLOCK) ON C.[CubeId] = MP.[VersionId] AND C.[ModelId] = MP.[ModelProgId]
  WHERE M.[AppName] = @moduleAppName AND M.[TypeId] = @TypeId AND MP.[StateId] IN (20, 21) 
  GROUP BY C.[CubeId], MP.[ModelProgId]
  ORDER BY C.[CubeId], MP.[ModelProgId];
 end;

 set nocount off;
End
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[spOLAP_PartitionDefine]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_EXECUTEsql @statement = N'CREATE PROCEDURE [Utility].[spOLAP_PartitionDefine] AS' 
END
GO
ALTER PROCEDURE [Utility].[spOLAP_PartitionDefine] 
  @bitacoraId bigint = NULL
 ,@CubeId nvarchar(12)
 ,@ModelId nvarchar(12)
 ,@dateStart nvarchar(10) = NULL
 ,@dateEnd nvarchar(10) = NULL
 ,@updateData bit = 0
As
/* ============================================================================================
Proposito: Llena las tablas de metadatos con el diseño de particiones.
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2017-04-10
Fecha actualizacion: 2020-07-15

Parametros:  
 @bitacoraId: Código de ejecución de proceso.
 @CubeId: Código de cubo. 
 @ModelId: Código de modelo (grupo de metricas). Si no es suministrado procesa todos los modelos
 @dateStart: Fecha inicial en formato: YYYY-MM-DD.
 @dateEnd: Fecha final en formato: YYYY-MM-DD.
 @updateData: Indica si actualiza los datos en caso que existan.

Ejemplo:
EXECUTE [Utility].[spOLAP_PartitionDefine] 0, 'Perdidas', 'PER_CBalEne', '2014-01-01', '2014-03-01', 0;
EXECUTE [Utility].[spOLAP_PartitionDefine] 1, 'Perdidas', 'PER_CBalEne', '2014-02-01', '2014-06-01', 0;
EXECUTE [Utility].[spOLAP_PartitionDefine] 2, 'Perdidas', 'PER_CBalEne', '2014-01-01', '2015-01-01', 0;
EXECUTE [Utility].[spOLAP_PartitionDefine] 3, 'Perdidas', 'PER_CBalEne', '2013-02-01', '2013-05-01', 1;
EXECUTE [Utility].[spOLAP_PartitionDefine] 4, 'Perdidas', 'PER_CBalEne', '2016-05-01', '2016-07-01', 0;
EXECUTE [Utility].[spOLAP_PartitionDefine] 5, 'Perdidas', NULL, '2014-01-01', '2015-01-01', 0;

SELECT * FROM  [Utility].[CubePartitionDetail] WHERE [CubeId] = 'Perdidas' ORDER BY [ModelId], [PartitionId];
SELECT * FROM [Utility].[CubePartition] WHERE [CubeId] = 'Perdidas' ORDER BY [ModelId];
============================================================================================ */
begin
 set nocount on
 Declare @dtDateStart date, @dtDateEnd date, @dtTemp date, @dtDate1 date, @dtDate2 date, @dtDateNext date, @datePart nvarchar(12), @dtPartition date;
 Declare @PartitionId nvarchar(12), @periodo nvarchar(12), @PrefixPartition nvarchar(128);
 Declare @StoragePath nvarchar(500), @IsFirstPartition bit, @IsLastPartition bit, @tempPartitionId nvarchar(12);
 Declare @dtMinDate date, @dtMaxDate date, @dtMaxProcessDate date, @bOK bit, @dtTempDateEnd date, @Partitioned bit, @UsePathBefore bit;
 Declare @dtDatePrevious date, @particionAnteriorId nvarchar(12), @tempParticionAnteriorId nvarchar(12);
 Declare @dtTempDateStart date;

 -- Validacion fechas
 if ( (@dateStart IS NULL OR RTrim(@dateStart) = '') OR (@dateEnd IS NULL OR RTrim(@dateEnd) = '') )
 begin
  set @dtDateStart = GetDate();
  set @dtDateEnd = @dtDateStart;

  SELECT @dtDateEnd = [Utility].[GetEndOfMonth] (Year(@dtDateEnd), Month(@dtDateEnd), 1);
  SELECT @dtDateEnd = DATEADD(day, 1, @dtDateEnd);
 end
 else
 begin
  set @dtDateStart = convert(date, @dateStart, 120);
  set @dtDateEnd = convert(date, @dateEnd, 120);

  if (@dtDateEnd < @dtDateStart)
  begin
   set @dtTemp = @dtDateStart;
   set @dtDateStart = @dtDateEnd;
   set @dtDateEnd = @dtTemp;
  end; 
 end;

 if (RTrim(@ModelId) = '')
 begin
  set @ModelId = NULL;
 end;

 DECLARE Cur_Loop CURSOR FORWARD_ONLY READ_ONLY FOR
 SELECT CP.[ModelId], CP.[Period],CP.[PrefixPartition],CP.[UsePathBefore],CP.[StoragePath],CP.[Partitioned]
 FROM [Utility].[CubePartition] CP WITH (NOLOCK)
 WHERE CP.[CubeId] = @CubeId AND (CP.[ModelId] = @ModelId OR @ModelId IS NULL) 
 ORDER BY CP.[ModelId];
    
 OPEN Cur_Loop;
 FETCH NEXT FROM Cur_Loop INTO @ModelId, @periodo, @PrefixPartition, @UsePathBefore, @StoragePath, @Partitioned;
 WHILE @@FETCH_STATUS = 0
 BEGIN  
  set @bOK = 1;

  if (@Partitioned = 1)
  begin
   if (@periodo = 'Dia')
   begin
    SET @datePart = 'DAY';
   end
   else if (@periodo = 'Semana')
   begin
    SET @datePart = 'WEEK';
   end
   else if (@periodo = 'Mes')
   begin
    SET @datePart = 'MONTH';
   end
   else if (@periodo = 'Bimestre')
   begin
    SET @datePart = 'MONTH2';
   end
   else if (@periodo = 'Trimestre')
   begin
    SET @datePart = 'QUARTER';
   end
   else if (@periodo = 'Semestre')
   begin
    SET @datePart = 'HALF';
   end
   else if (@periodo = 'Año')
   begin
    SET @datePart = 'YEAR';
   end
   else
   begin
    INSERT INTO [Audit].[BitacoraTable]([BitacoraId],[Name],[StateId],[SeverityId],[TypeId],[DateRun],[DateWork],[TableTarget]
     ,[FieldTarget],[ValueTarget],[TableSource],[FieldSource],[ValueSource],[PKField1],[PKValue1],[PKField2],[PKValue2],[PKField3],[PKValue3]
     ,[PKField4],[PKValue4],[PKField5],[PKValue5],[Message])
    VALUES (@bitacoraId, 'spOLAP_PartitionDefine', 1, 2, 7, GetDate(), NULL, 'Utility.CubePartitionDetail', NULL, NULL, 'Utility.CubePartition'
     , 'Period', @periodo, 'CubeId', @CubeId, 'ModelId', @ModelId, NULL, NULL, NULL, NULL, NULL, NULL, 'Valor no permitido');

    set @bOK = 0;
   end;
  
   if (@bOK = 1)
   begin
    set @dtTempDateStart = [Utility].[GetStartOfDatePart] (@datePart, @dtDateStart);

    set @dtTempDateEnd = [Utility].[GetStartOfDatePart] (@datePart, @dtDateEnd);
	if (@dtTempDateEnd <> @dtDateEnd)
	begin
	 set @dtTempDateEnd = DATEADD(day, 1, [Utility].[GetEndOfDatePart](@datePart, @dtDateEnd, 1));   
    end;
	 
	set @dtDateNext = @dtTempDateStart;

    set @dtMinDate = NULL;
    set @dtMaxDate = NULL;
    SELECT @dtMinDate = Min([DateStart]), @dtMaxDate = Max([DateStart])
    FROM [Utility].[CubePartitionDetail] WITH (NOLOCK)
    WHERE [CubeId] = @CubeId AND [ModelId] = @ModelId;

    if (@dtMinDate IS NULL)
    begin
     set @dtMinDate = @dtDateNext;
    end;
    if (@dtMaxDate IS NULL)
    begin
     set @dtMaxDate = [Utility].[DateAddPeriod](@datePart, - 1, @dtTempDateEnd);
    end;

    /* Llenar huecos faltantes */
    if (@dtTempDateEnd < @dtMinDate)
    begin
     set @dtTempDateEnd = @dtMinDate;
    end;
    if (@dtDateNext > @dtMaxDate)
    begin
     set @dtDateNext = @dtMaxDate;
    end;
    set @dtMaxProcessDate = [Utility].[DateAddPeriod](@datePart, - 1, @dtTempDateEnd);

    WHILE (@dtDateNext < @dtTempDateEnd)
    begin
     set @dtDate1 = @dtDateNext;

     if ( (@dtDateNext = @dtTempDateStart OR @dtDateNext = @dtMaxDate) AND @dtDateNext <= @dtMinDate) 
     begin
	  set @IsFirstPartition = 1;
	  set @IsLastPartition = 0;
	  set @dtDate2 = NULL;
     end
     else if (@dtDateNext = @dtMaxProcessDate AND @dtDateNext >= @dtMaxDate)
     begin
  	  set @IsFirstPartition = 0;
	  set @IsLastPartition = 1;
	  set @dtDate2 = NULL;
     end
     else
     begin
	  set @IsFirstPartition = 0;
	  set @IsLastPartition = 0;
     end;
    
 	 set @dtDatePrevious = [Utility].[DateAddPeriod](@datePart, - 1, @dtDate1);
	 set @dtPartition = @dtDate1;
     SELECT @PartitionId = [Utility].[GetDataPart_Period](@datePart, @dtDate1);     
     SELECT @particionAnteriorId = [Utility].[GetDataPart_Period](@datePart, @dtDatePrevious);

     if (@IsFirstPartition = 1)
     begin
  	  set @dtPartition = [Utility].[DateAddPeriod](@datePart, -1, @dtDate1);
      SELECT @PartitionId = [Utility].[GetDataPart_Period](@datePart, [Utility].[DateAddPeriod](@datePart, -1, @dtDate1));
      SELECT @particionAnteriorId = [Utility].[GetDataPart_Period](@datePart, [Utility].[DateAddPeriod](@datePart, -2, @dtDate1));

      SELECT @tempPartitionId = [Utility].[GetDataPart_Period](@datePart, @dtDate1);
      SELECT @tempParticionAnteriorId = [Utility].[GetDataPart_Period](@datePart, @dtDatePrevious);
	 end;

     SELECT @dtDateNext = DATEADD(day, 1, [Utility].[GetEndOfDatePart](@datePart, @dtDateNext, 1));

     if (@IsFirstPartition = 0 AND @IsLastPartition = 0)
     begin
      set @dtDate2 = @dtDateNext;
     end;

     if (@IsFirstPartition = 1)
     begin
      /* Para particiones derecha queda un hueco entre la primera y segunda particion */
      IF NOT EXISTS(SELECT * FROM [Utility].[CubePartitionDetail] WITH (NOLOCK) 
                    WHERE [CubeId] = @CubeId AND [ModelId] = @ModelId AND [PartitionId] = @tempPartitionId)
      begin
       INSERT INTO [Utility].[CubePartitionDetail] ([CubeId],[ModelId],[PartitionId],[PartitionName],[PartitionNameBefore]
	    ,[DatePartition],[DateStart],[DateEnd],[UsePathBefore],[StoragePath],[IsFirstPartition],[IsLastPartition],[Create],[Update]
		,[Process],[CreateBitacoraId],[ProcessBitacoraId])
       VALUES (@CubeId, @ModelId, @tempPartitionId, @PrefixPartition + '_' + @tempPartitionId, @PrefixPartition + '_' + @tempParticionAnteriorId
	    , @dtDate1, @dtDate1, @dtDateNext, @UsePathBefore, @StoragePath, 0, 0, 1, 1, 1, @bitacoraId, NULL);
      end;
	  else
	  begin
       if (@updateData = 1)
       begin
	    UPDATE [Utility].[CubePartitionDetail] SET
	      [PartitionName] = @PrefixPartition + '_' + @tempPartitionId
		 ,[PartitionNameBefore] = @PrefixPartition + '_' + @tempParticionAnteriorId
		 ,[DatePartition] = @dtDate1
	     ,[DateStart] = @dtDate1
	     ,[DateEnd] = @dtDateNext
		 ,[UsePathBefore] = @UsePathBefore
	     ,[StoragePath] = @StoragePath
		 ,[Update] = 1
		 ,[Process] = 1
	     ,[CreateBitacoraId] = @bitacoraId
	     WHERE [CubeId] = @CubeId AND [ModelId] = @ModelId AND [PartitionId] = @tempPartitionId;
       end
	   else
	   begin
	    UPDATE [Utility].[CubePartitionDetail] SET
	      [DatePartition] = @dtDate1
	     ,[DateStart] = @dtDate1
	     ,[DateEnd] = @dtDateNext
		 ,[Update] = 1
		 ,[Process] = 1
	     ,[CreateBitacoraId] = @bitacoraId
	    WHERE [CubeId] = @CubeId AND [ModelId] = @ModelId AND [PartitionId] = @tempPartitionId
	    AND ([DatePartition] != @dtDate1 OR [DateStart] != @dtDate1 OR ([DateEnd] IS NULL OR [DateEnd] != @dtDateNext) );
	   end;
	  end;

      -- Actualizar si hay primera fila marcada
	  if EXISTS(SELECT * FROM [Utility].[CubePartitionDetail] 
                WHERE [CubeId] = @CubeId AND [ModelId] = @ModelId AND [DateStart] > @dtDate1 AND [IsFirstPartition] = 1)
	  begin
	   UPDATE PD SET
	     [DatePartition] = [Utility].[DateAddPeriod](@datePart, -1, PD.[DateStart])
	    ,[DateStart] = [Utility].[DateAddPeriod](@datePart, -1, PD.[DateStart])
	    ,[DateEnd] = PD.[DateStart]
	    ,[IsFirstPartition] = 0
 	    ,[IsLastPartition] = 0
		,[Update] = 1
		,[Process] = 1
	    ,[CreateBitacoraId] = @bitacoraId
	   FROM [Utility].[CubePartitionDetail] PD
       WHERE PD.[CubeId] = @CubeId AND PD.[ModelId] = @ModelId AND PD.[DateStart] > @dtDate1 AND PD.[IsFirstPartition] = 1;
	  end;
     end
     else if (@IsLastPartition = 1)
     begin
      -- Actualizar si hay ultima fila marcada
      if EXISTS(SELECT * FROM [Utility].[CubePartitionDetail] 
                WHERE [CubeId] = @CubeId AND [ModelId] = @ModelId AND [DateStart] < @dtDate1 AND [IsLastPartition] = 1)
      begin
	   UPDATE PD SET
	     [DatePartition] = [DateStart]
        ,[DateEnd] = [Utility].[DateAddPeriod](@datePart, 1, PD.[DateStart])
	    ,[IsFirstPartition] = 0
	    ,[IsLastPartition] = 0
		,[Update] = 1
		,[Process] = 1
	    ,[CreateBitacoraId] = @bitacoraId
	   FROM [Utility].[CubePartitionDetail] PD
       WHERE PD.[CubeId] = @CubeId AND PD.[ModelId] = @ModelId AND PD.[DateStart] < @dtDate1 AND PD.[IsLastPartition] = 1;
      end;
     end;

     IF NOT EXISTS(SELECT * FROM [Utility].[CubePartitionDetail] WITH (NOLOCK)
                   WHERE [CubeId] = @CubeId AND [ModelId] = @ModelId AND [PartitionId] = @PartitionId)
     begin
      INSERT INTO [Utility].[CubePartitionDetail] ([CubeId],[ModelId],[PartitionId],[PartitionName],[PartitionNameBefore]
	  ,[DatePartition],[DateStart],[DateEnd],[UsePathBefore],[StoragePath],[IsFirstPartition],[IsLastPartition],[Create],[Update]
	  ,[Process],[CreateBitacoraId],[ProcessBitacoraId])
      VALUES (@CubeId, @ModelId, @PartitionId, @PrefixPartition + '_' + @PartitionId, @PrefixPartition + '_' + @particionAnteriorId
	   , @dtPartition, @dtDate1, @dtDate2, @UsePathBefore, @StoragePath, @IsFirstPartition, @IsLastPartition, 1, 1, 1, @bitacoraId, NULL);
     end
     else
     begin
      if (@updateData = 1)
      begin
	   UPDATE [Utility].[CubePartitionDetail] SET
	     [PartitionName] = @PrefixPartition + '_' + @PartitionId
		,[PartitionNameBefore] = @PrefixPartition + '_' + @particionAnteriorId
		,[DatePartition] = @dtPartition
	    ,[DateStart] = @dtDate1
	    ,[DateEnd] = @dtDate2
		,[UsePathBefore] = @UsePathBefore
	    ,[StoragePath] = @StoragePath
	    ,[IsFirstPartition] = @IsFirstPartition
	    ,[IsLastPartition] = @IsLastPartition
		,[Update] = 1
		,[Process] = 1
	    ,[CreateBitacoraId] = @bitacoraId
	   WHERE [CubeId] = @CubeId AND [ModelId] = @ModelId AND [PartitionId] = @PartitionId;
      end
	  else
	  begin
	   UPDATE [Utility].[CubePartitionDetail] SET
	     [DatePartition] = @dtPartition
	    ,[DateStart] = @dtDate1
	    ,[DateEnd] = @dtDate2
	    ,[IsFirstPartition] = @IsFirstPartition
	    ,[IsLastPartition] = @IsLastPartition
		,[Update] = 1
		,[Process] = 1
	    ,[CreateBitacoraId] = @bitacoraId
	   WHERE [CubeId] = @CubeId AND [ModelId] = @ModelId AND [PartitionId] = @PartitionId
	   AND ([DateStart] != @dtDate1 OR ([DateEnd] != @dtDate2 OR @dtDate2 IS NULL) OR [IsFirstPartition] != @IsFirstPartition OR [IsLastPartition] != @IsLastPartition);
	  end;
     end;
    end;
   end;
  end
  else
  begin
   /* No Partitioned */ 
   set @PartitionId = @ModelId;
   IF NOT EXISTS(SELECT * FROM [Utility].[CubePartitionDetail] WITH (NOLOCK)
                  WHERE [CubeId] = @CubeId AND [ModelId] = @ModelId AND [PartitionId] = @PartitionId)
   begin
     INSERT INTO [Utility].[CubePartitionDetail] ([CubeId],[ModelId],[PartitionId],[PartitionName],[PartitionNameBefore]
	 ,[DatePartition],[DateStart],[DateEnd],[UsePathBefore],[StoragePath],[IsFirstPartition],[IsLastPartition],[Create],[Update]
	 ,[Process],[CreateBitacoraId],[ProcessBitacoraId])
     VALUES (@CubeId, @ModelId, @PartitionId, @PrefixPartition, @PrefixPartition
	 , [Utility].[GetStartOfYear] (year(GetDate())), [Utility].[GetStartOfYear] (year(GetDate())), NULL, @UsePathBefore, @StoragePath, 1, 1, 0, 0, 1, @bitacoraId, NULL);
   end
   else
   begin
    if (@updateData = 1)
    begin
	 UPDATE [Utility].[CubePartitionDetail] SET
	     [PartitionName] = @PrefixPartition
		,[PartitionNameBefore] = @PrefixPartition
		,[DatePartition] = [Utility].[GetStartOfYear] (year(GetDate()))
	    ,[DateStart] = [Utility].[GetStartOfYear] (year(GetDate()))
	    ,[DateEnd] = NULL
		,[UsePathBefore] = @UsePathBefore
	    ,[StoragePath] = @StoragePath
	    ,[IsFirstPartition] = 1
	    ,[IsLastPartition] = 1
		,[Create] = 0
		,[Update] = 0
		,[Process] = 1
	    ,[CreateBitacoraId] = @bitacoraId
	 WHERE [CubeId] = @CubeId AND [ModelId] = @ModelId AND [PartitionId] = @PartitionId;
    end;
   end;
  end;

  FETCH NEXT FROM Cur_Loop INTO @ModelId, @periodo, @PrefixPartition, @UsePathBefore, @StoragePath, @Partitioned;
 END; 
 CLOSE Cur_Loop;
 DEALLOCATE Cur_Loop;     

 set nocount off;
End;
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[spOLAP_UpdatePartitionToCreated]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_EXECUTEsql @statement = N'CREATE PROCEDURE [Utility].[spOLAP_UpdatePartitionToCreated] AS' 
END
GO
ALTER PROCEDURE [Utility].[spOLAP_UpdatePartitionToCreated] 
  @bitacoraId bigint
 ,@CubeId nvarchar(12)
 ,@ModelId nvarchar(12)
 ,@PartitionId nvarchar(12)
As
/* ============================================================================================
Proposito: Actualiza partición como creada.
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2017-04-10
Fecha actualizacion: 2020-07-15

Parametros:  
 @bitacoraId: Código de bitacora.
 @CubeId: Código de cubo. 
 @ModelId: Código de modelo (grupo de metricas).
 @PartitionId: Código de particion.

Ejemplo:
EXECUTE [Utility].[spOLAP_UpdatePartitionToCreated] 0, 'Perdidas', 'PER_CBalEne', '201401';

SELECT * FROM [Utility].[CubePartitionDetail] ORDER BY [CubeId],[ModelId],[PartitionId];
============================================================================================ */
begin
 set nocount on

 if EXISTS(SELECT * FROM [Utility].[CubePartition] WITH (NOLOCK) WHERE [CubeId] = @CubeId AND [ModelId] = @ModelId AND [Partitioned] = 0)
 begin
  UPDATE [Utility].[CubePartitionDetail] SET 
    [Create] = 0
   ,[Update] = 0
   ,[CreateBitacoraId] = @bitacoraId
  WHERE [CubeId] = @CubeId AND [ModelId] = @ModelId AND ([Create] = 1 OR [Update] = 1); 
 end
 else
 begin
  UPDATE [Utility].[CubePartitionDetail] SET 
    [Create] = 0
   ,[Update] = 0
   ,[CreateBitacoraId] = @bitacoraId
  WHERE [CubeId] = @CubeId AND [ModelId] = @ModelId AND [PartitionId] = @PartitionId AND ([Create] = 1 OR [Update] = 1); 
 end

 set nocount off;
End
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[spOLAP_UpdatePartitionToProsessed]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_EXECUTEsql @statement = N'CREATE PROCEDURE [Utility].[spOLAP_UpdatePartitionToProsessed] AS' 
END
GO
ALTER PROCEDURE [Utility].[spOLAP_UpdatePartitionToProsessed] 
  @bitacoraId bigint
 ,@CubeId nvarchar(12)
 ,@ModelId nvarchar(12)
 ,@PartitionId nvarchar(12)
As
/* ============================================================================================
Proposito: Actualiza partición como procesada.
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2017-04-10
Fecha actualizacion: 2020-07-15

Parametros:  
 @bitacoraId: Código de bitacora.
 @CubeId: Código de cubo. 
 @ModelId: Código de modelo (grupo de metricas).
 @PartitionId: Código de particion.

Ejemplo:
EXECUTE [Utility].[spOLAP_UpdatePartitionToProsessed] 0, 'Perdidas', 'PER_CBalEne', '201401';

SELECT * FROM [Utility].[CubePartitionDetail] ORDER BY [CubeId],[ModelId],[PartitionId];
============================================================================================ */
begin
 set nocount on

 if EXISTS(SELECT * FROM [Utility].[CubePartition] WITH (NOLOCK) WHERE [CubeId] = @CubeId AND [ModelId] = @ModelId AND [Partitioned] = 0)
 begin
  UPDATE [Utility].[CubePartitionDetail] SET 
   [ProcessBitacoraId] = @bitacoraId
  WHERE [CubeId] = @CubeId AND [ModelId] = @ModelId; 
 end
 else
 begin
  UPDATE [Utility].[CubePartitionDetail] SET 
   [ProcessBitacoraId] = @bitacoraId
  WHERE [CubeId] = @CubeId AND [ModelId] = @ModelId AND [PartitionId] = @PartitionId; 
 end;

 set nocount off;
End
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[spOLAP_ScriptXMLAParttition]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_EXECUTEsql @statement = N'CREATE PROCEDURE [Utility].[spOLAP_ScriptXMLAParttition] AS' 
END
GO
ALTER PROCEDURE [Utility].[spOLAP_ScriptXMLAParttition] 
  @scriptType char(1)
 ,@CubeId nvarchar(12)
 ,@ModelId nvarchar(12)
 ,@PartitionId nvarchar(12)
 ,@StoragePathBefore nvarchar(500) = NULL
As
/* ============================================================================================
Proposito: Genera script XMLA para el manejo de particiones.
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2017-04-10
Fecha actualizacion: 2020-07-15

Parametros:  
 @scriptType: Código de tipo de script a ser generado:
  C: Create particon.
  U: Actualizar particion.
  D: Borrar partición.
  P: Procesar.
 @CubeId: Código de cubo. 
 @ModelId: Código de modelo (grupo de metricas).
 @PartitionId: Código de particion.
 @StoragePathBefore: Ruta de almacenamiento de la particion anterior.

Ejemplo:
Declare @scriptXMLA nvarchar(max);
EXECUTE [Utility].[spOLAP_ScriptXMLAParttition] 'C', 'Perdidas', 'PER_CBalEne', '201401', 'D:\MSDB\SQL2016\PerdidasOLAP';
Print Len(@scriptXMLA);
EXECUTE [Utility].[PrintLongText] @scriptXMLA, 0;

SELECT * FROM [Utility].[CubePartition] WHERE [CubeId] = 'Perdidas' ORDER BY [ModelId];
SELECT * FROM  [Utility].[CubePartitionDetail] WHERE [CubeId] = 'Perdidas' ORDER BY [ModelId], [PartitionId];
============================================================================================ */
begin
 set nocount on
 Declare @sqlQuery nvarchar(max), @iPosition int, @sDateStart nvarchar(8), @sDateEnd nvarchar(8), @baseDatosOLAP nvarchar(128), @QueryId nvarchar(12);
 Declare @PartitionField nvarchar(128), @cuboAppName nvarchar(128), @measureGroupId nvarchar(128), @DataSource nvarchar(128);
 Declare @StoragePath nvarchar(500), @IsFirstPartition bit, @IsLastPartition bit, @PartitionName nvarchar(200), @Partitioned bit, @UsePathBefore bit;
 Declare  @scriptXMLA nvarchar(max), @storageLocation nvarchar(500);

 set @scriptXMLA = '';
 if (@scriptType NOT IN ('C', 'P', 'U', 'D') OR @scriptType IS NULL)
 begin
  Print 'Tipo no valido @scriptType: ' + IsNull(@scriptType, '');
  SELECT '' [ScriptXMLA];
  return;
 end;

 if EXISTS(SELECT * FROM [Utility].[CubePartition] WITH (NOLOCK) WHERE [CubeId] = @CubeId AND [ModelId] = @ModelId AND [Partitioned] = 0)
 begin
  set @Partitioned = 0;
  SELECT TOP 1 @baseDatosOLAP = CU.[Database], @cuboAppName = CU.[AppName], @measureGroupId =  MO.[AppName], @DataSource = CP.[DataSource]
  , @PartitionName = [PartitionName], @QueryId = CP.[QueryId], @PartitionField = CP.[PartitionField], @UsePathBefore = PD.[UsePathBefore]
  , @StoragePath = ISNULL(PD.[StoragePath], '')
  , @sDateStart = Convert(nvarchar(8), PD.[DateStart], 112), @sDateEnd = Convert(nvarchar(8), PD.[DateEnd], 112)
  , @IsFirstPartition = PD.[IsFirstPartition], @IsLastPartition = PD.[IsLastPartition]
  FROM [Utility].[CubeSystem] CU WITH (NOLOCK)
  INNER JOIN [Utility].[CubePartition] CP WITH (NOLOCK) ON CP.[CubeId] = CU.[CubeId]
  INNER JOIN [Utility].[ModelSystem] MO WITH (NOLOCK) ON MO.[ModelId] = CP.[ModelId]
  INNER JOIN [Utility].[CubePartitionDetail] PD WITH (NOLOCK) ON PD.[CubeId] = CU.[CubeId] AND PD.[ModelId] = CP.[ModelId]
  WHERE PD.[CubeId] = @CubeId AND PD.[ModelId] = @ModelId
  ORDER BY PD.[PartitionId] DESC;
 end
 else
 begin
  set @Partitioned = 1;
  SELECT @baseDatosOLAP = CU.[Database], @cuboAppName = CU.[AppName], @measureGroupId =  MO.[AppName], @DataSource = CP.[DataSource]
  , @PartitionName = [PartitionName], @QueryId = CP.[QueryId], @PartitionField = CP.[PartitionField], @UsePathBefore = PD.[UsePathBefore]
  , @StoragePath = ISNULL(PD.[StoragePath], '')
  , @sDateStart = Convert(nvarchar(8), PD.[DateStart], 112), @sDateEnd = Convert(nvarchar(8), PD.[DateEnd], 112)
  , @IsFirstPartition = PD.[IsFirstPartition], @IsLastPartition = PD.[IsLastPartition]
  FROM [Utility].[CubeSystem] CU WITH (NOLOCK)
  INNER JOIN [Utility].[CubePartition] CP WITH (NOLOCK) ON CP.[CubeId] = CU.[CubeId]
  INNER JOIN [Utility].[ModelSystem] MO WITH (NOLOCK) ON MO.[ModelId] = CP.[ModelId]
  INNER JOIN [Utility].[CubePartitionDetail] PD WITH (NOLOCK) ON PD.[CubeId] = CU.[CubeId] AND PD.[ModelId] = CP.[ModelId]
  WHERE PD.[CubeId] = @CubeId AND PD.[ModelId] = @ModelId AND PD.[PartitionId] = @PartitionId;
 end;

 if (@scriptType IN ('C', 'U'))
 begin
  if (@QueryId IS NULL OR @QueryId = '')
  begin
   Print 'En la tabla: [Utility].[ModelSystem], no fue establecida la consulta: ' + IsNull(@QueryId, '');
   SELECT '' [ScriptXMLA];
   return;
  end;

  SELECT @sqlQuery = [QuerySQL] FROM [Utility].[QuerySQL] WHERE [QueryId] = @QueryId;

  if (@sqlQuery IS NULL OR @sqlQuery = '')
  begin
   Print 'En la tabla: [Utility].[QuerySQL], no fue establecida la consulta: ' + IsNull(@QueryId, '');
   SELECT '' [ScriptXMLA];
   return;
  end;

  set @sqlQuery = Replace(@sqlQuery, ';', '');
  set @iPosition = CHARINDEX('WHERE', @sqlQuery);
  if (@iPosition > 0)
  begin
   set @sqlQuery = RTrim(LEFT(@sqlQuery, @iPosition - 1))
  end

  if (@Partitioned = 1)
  begin
   if (@IsFirstPartition = 1)
   begin
    set @sqlQuery = @sqlQuery + CHAR(13) + CHAR(10) + ' WHERE ' + QUOTENAME(@PartitionField) + ' &lt; ' + @sDateStart;
    
	if (@UsePathBefore = 1)
	begin
	 if (@StoragePathBefore IS NULL OR RTrim(@StoragePathBefore) = '') 
	 begin
      set @storageLocation = @StoragePath;
     end
     else
	 begin
      set @storageLocation = @StoragePathBefore;
	 end;
    end
    else
	begin
     set @storageLocation = @StoragePath;
	end;
   end
   else
   begin     
    if (@IsLastPartition = 1)   
    begin
     set @sqlQuery = @sqlQuery + CHAR(13) + CHAR(10) + ' WHERE ' + QUOTENAME(@PartitionField) + ' &gt;= ' + @sDateStart;
    end 
    else
    begin
     set @sqlQuery = @sqlQuery + CHAR(13) + CHAR(10) + ' WHERE ' + QUOTENAME(@PartitionField) + ' &gt;= ' + @sDateStart +
      ' AND ' + QUOTENAME(@PartitionField) + ' &lt; ' + @sDateEnd;
    end;
   end;
  end -- if (@Partitioned = 1)

  if ( (@Partitioned = 0) OR (@Partitioned = 1 and @IsFirstPartition = 0) )
  begin
   if (@UsePathBefore = 1)
   begin
    set @storageLocation = @StoragePathBefore;
   end
   else
   begin
    set @storageLocation = @StoragePath;
   end;
  end;

  if (@storageLocation IS NULL)
  begin
   set @storageLocation = '';
  end;
 end; -- if (@scriptType IN ('C', 'U'))
  
 if (@scriptType = 'C')
 begin   
/* '        <Partition xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ddl2="http://schemas.microsoft.com/analysisservices/2003/engine/2" xmlns:ddl2_2="http://schemas.microsoft.com/analysisservices/2003/engine/2/2" xmlns:ddl100_100="http://schemas.microsoft.com/analysisservices/2008/engine/100/100" xmlns:ddl200="http://schemas.microsoft.com/analysisservices/2010/engine/200" xmlns:ddl200_200="http://schemas.microsoft.com/analysisservices/2010/engine/200/200" xmlns:ddl300="http://schemas.microsoft.com/analysisservices/2011/engine/300" xmlns:ddl300_300="http://schemas.microsoft.com/analysisservices/2011/engine/300/300" xmlns:ddl400="http://schemas.microsoft.com/analysisservices/2012/engine/400" xmlns:ddl400_400="http://schemas.microsoft.com/analysisservices/2012/engine/400/400"> ' + CHAR(13) + CHAR(10) +  */

  set @scriptXMLA = @scriptXMLA +
'<Create xmlns="http://schemas.microsoft.com/analysisservices/2003/engine"> ' + CHAR(13) + CHAR(10) + 
'    <ParentObject> ' + CHAR(13) + CHAR(10) + 
'        <DatabaseID>' + @baseDatosOLAP + '</DatabaseID> ' + CHAR(13) + CHAR(10) + 
'        <CubeID>' + @cuboAppName + '</CubeID> ' + CHAR(13) + CHAR(10) + 
'        <MeasureGroupID>' + @measureGroupId + '</MeasureGroupID> ' + CHAR(13) + CHAR(10) + 
'    </ParentObject> ' + CHAR(13) + CHAR(10) + 
'    <ObjectDefinition> ' + CHAR(13) + CHAR(10) + 
'        <Partition xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ddl2="http://schemas.microsoft.com/analysisservices/2003/engine/2" xmlns:ddl2_2="http://schemas.microsoft.com/analysisservices/2003/engine/2/2" xmlns:ddl100_100="http://schemas.microsoft.com/analysisservices/2008/engine/100/100" xmlns:ddl200="http://schemas.microsoft.com/analysisservices/2010/engine/200" xmlns:ddl200_200="http://schemas.microsoft.com/analysisservices/2010/engine/200/200" xmlns:ddl300="http://schemas.microsoft.com/analysisservices/2011/engine/300" xmlns:ddl300_300="http://schemas.microsoft.com/analysisservices/2011/engine/300/300" xmlns:ddl400="http://schemas.microsoft.com/analysisservices/2012/engine/400" xmlns:ddl400_400="http://schemas.microsoft.com/analysisservices/2012/engine/400/400" xmlns:ddl500="http://schemas.microsoft.com/analysisservices/2013/engine/500" xmlns:ddl500_500="http://schemas.microsoft.com/analysisservices/2013/engine/500/500"> ' + CHAR(13) + CHAR(10) + 
'            <ID>' + @PartitionName + '</ID> ' + CHAR(13) + CHAR(10) + 
'            <Name>' + @PartitionName + '</Name> ' + CHAR(13) + CHAR(10) + 
'            <Source xsi:type="QueryBinding"> ' + CHAR(13) + CHAR(10) + 
'                <DataSourceID>' + @DataSource + '</DataSourceID> ' + CHAR(13) + CHAR(10) + 
'                <QueryDefinition> ' + CHAR(13) + CHAR(10) + @sqlQuery + CHAR(13) + CHAR(10) +
'                </QueryDefinition> ' + CHAR(13) + CHAR(10) + 
'            </Source> ' + CHAR(13) + CHAR(10) + 
'            <StorageMode>Molap</StorageMode> ' + CHAR(13) + CHAR(10) + 
'            <ProcessingMode>Regular</ProcessingMode> ' + CHAR(13) + CHAR(10) + 
'            <StorageLocation>' + @storageLocation + '</StorageLocation> ' + CHAR(13) + CHAR(10) + 
'            <ProactiveCaching> ' + CHAR(13) + CHAR(10) + 
'                <SilenceInterval>-PT1S</SilenceInterval> ' + CHAR(13) + CHAR(10) + 
'                <Latency>-PT1S</Latency> ' + CHAR(13) + CHAR(10) + 
'                <SilenceOverrideInterval>-PT1S</SilenceOverrideInterval> ' + CHAR(13) + CHAR(10) + 
'                <ForceRebuildInterval>-PT1S</ForceRebuildInterval> ' + CHAR(13) + CHAR(10) + 
'                <Source xsi:type="ProactiveCachingInheritedBinding" /> ' + CHAR(13) + CHAR(10) + 
'            </ProactiveCaching> ' + CHAR(13) + CHAR(10) + 
'        </Partition> ' + CHAR(13) + CHAR(10) + 
'    </ObjectDefinition> ' + CHAR(13) + CHAR(10) + 
'</Create>';
 end
 else if (@scriptType = 'P')
 begin
/* '   <Process xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ddl2="http://schemas.microsoft.com/analysisservices/2003/engine/2" xmlns:ddl2_2="http://schemas.microsoft.com/analysisservices/2003/engine/2/2" xmlns:ddl100_100="http://schemas.microsoft.com/analysisservices/2008/engine/100/100" xmlns:ddl200="http://schemas.microsoft.com/analysisservices/2010/engine/200" xmlns:ddl200_200="http://schemas.microsoft.com/analysisservices/2010/engine/200/200" xmlns:ddl300="http://schemas.microsoft.com/analysisservices/2011/engine/300" xmlns:ddl300_300="http://schemas.microsoft.com/analysisservices/2011/engine/300/300" xmlns:ddl400="http://schemas.microsoft.com/analysisservices/2012/engine/400" xmlns:ddl400_400="http://schemas.microsoft.com/analysisservices/2012/engine/400/400"> ' + CHAR(13) + CHAR(10) + */

  set @scriptXMLA = @scriptXMLA +
 '<Batch ProcessAffectedObjects="true" xmlns="http://schemas.microsoft.com/analysisservices/2003/engine"> ' + CHAR(13) + CHAR(10) + 
 ' <Parallel> ' + CHAR(13) + CHAR(10) + 
 '   <Process xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ddl2="http://schemas.microsoft.com/analysisservices/2003/engine/2" xmlns:ddl2_2="http://schemas.microsoft.com/analysisservices/2003/engine/2/2" xmlns:ddl100_100="http://schemas.microsoft.com/analysisservices/2008/engine/100/100" xmlns:ddl200="http://schemas.microsoft.com/analysisservices/2010/engine/200" xmlns:ddl200_200="http://schemas.microsoft.com/analysisservices/2010/engine/200/200" xmlns:ddl300="http://schemas.microsoft.com/analysisservices/2011/engine/300" xmlns:ddl300_300="http://schemas.microsoft.com/analysisservices/2011/engine/300/300" xmlns:ddl400="http://schemas.microsoft.com/analysisservices/2012/engine/400" xmlns:ddl400_400="http://schemas.microsoft.com/analysisservices/2012/engine/400/400" xmlns:ddl500="http://schemas.microsoft.com/analysisservices/2013/engine/500" xmlns:ddl500_500="http://schemas.microsoft.com/analysisservices/2013/engine/500/500"> ' + CHAR(13) + CHAR(10) + 
 '     <Object> ' + CHAR(13) + CHAR(10) + 
 '       <DatabaseID>' + @baseDatosOLAP + '</DatabaseID> ' + CHAR(13) + CHAR(10) + 
 '       <CubeID>' + @cuboAppName + '</CubeID> ' + CHAR(13) + CHAR(10) + 
 '       <MeasureGroupID>' + @measureGroupId + '</MeasureGroupID> ' + CHAR(13) + CHAR(10) + 
 '       <PartitionID>' + @PartitionName + '</PartitionID> ' + CHAR(13) + CHAR(10) + 
 '     </Object> ' + CHAR(13) + CHAR(10) + 
 '     <Type>ProcessFull</Type> ' + CHAR(13) + CHAR(10) + 
 '     <WriteBackTableCreation>UseExisting</WriteBackTableCreation> ' + CHAR(13) + CHAR(10) + 
 '   </Process> ' + CHAR(13) + CHAR(10) + 
 ' </Parallel> ' + CHAR(13) + CHAR(10) + 
'</Batch>';
 end
 else if (@scriptType = 'U')
 begin
/*'        <Partition xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ddl2="http://schemas.microsoft.com/analysisservices/2003/engine/2" xmlns:ddl2_2="http://schemas.microsoft.com/analysisservices/2003/engine/2/2" xmlns:ddl100_100="http://schemas.microsoft.com/analysisservices/2008/engine/100/100" xmlns:ddl200="http://schemas.microsoft.com/analysisservices/2010/engine/200" xmlns:ddl200_200="http://schemas.microsoft.com/analysisservices/2010/engine/200/200" xmlns:ddl300="http://schemas.microsoft.com/analysisservices/2011/engine/300" xmlns:ddl300_300="http://schemas.microsoft.com/analysisservices/2011/engine/300/300" xmlns:ddl400="http://schemas.microsoft.com/analysisservices/2012/engine/400" xmlns:ddl400_400="http://schemas.microsoft.com/analysisservices/2012/engine/400/400"> ' + CHAR(13) + CHAR(10) + */

  set @scriptXMLA = @scriptXMLA +
'<Alter AllowCreate="true" ObjectExpansion="ExpandFull" xmlns="http://schemas.microsoft.com/analysisservices/2003/engine"> ' + CHAR(13) + CHAR(10) + 
'    <Object> ' + CHAR(13) + CHAR(10) + 
'        <DatabaseID>' + @baseDatosOLAP + '</DatabaseID> ' + CHAR(13) + CHAR(10) + 
'        <CubeID>' + @cuboAppName + '</CubeID> ' + CHAR(13) + CHAR(10) + 
'        <MeasureGroupID>' + @measureGroupId + '</MeasureGroupID> ' + CHAR(13) + CHAR(10) + 
'        <PartitionID>' + @PartitionName + '</PartitionID> ' + CHAR(13) + CHAR(10) + 
'    </Object> ' + CHAR(13) + CHAR(10) + 
'    <ObjectDefinition> ' + CHAR(13) + CHAR(10) + 
'        <Partition xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ddl2="http://schemas.microsoft.com/analysisservices/2003/engine/2" xmlns:ddl2_2="http://schemas.microsoft.com/analysisservices/2003/engine/2/2" xmlns:ddl100_100="http://schemas.microsoft.com/analysisservices/2008/engine/100/100" xmlns:ddl200="http://schemas.microsoft.com/analysisservices/2010/engine/200" xmlns:ddl200_200="http://schemas.microsoft.com/analysisservices/2010/engine/200/200" xmlns:ddl300="http://schemas.microsoft.com/analysisservices/2011/engine/300" xmlns:ddl300_300="http://schemas.microsoft.com/analysisservices/2011/engine/300/300" xmlns:ddl400="http://schemas.microsoft.com/analysisservices/2012/engine/400" xmlns:ddl400_400="http://schemas.microsoft.com/analysisservices/2012/engine/400/400" xmlns:ddl500="http://schemas.microsoft.com/analysisservices/2013/engine/500" xmlns:ddl500_500="http://schemas.microsoft.com/analysisservices/2013/engine/500/500"> ' + CHAR(13) + CHAR(10) + 
'            <ID>' + @PartitionName + '</ID> ' + CHAR(13) + CHAR(10) + 
'            <Name>' + @PartitionName + '</Name> ' + CHAR(13) + CHAR(10) + 
'            <Source xsi:type="QueryBinding"> ' + CHAR(13) + CHAR(10) + 
'                <DataSourceID>' + @DataSource + '</DataSourceID> ' + CHAR(13) + CHAR(10) + 
'                <QueryDefinition> ' + CHAR(13) + CHAR(10) + @sqlQuery + CHAR(13) + CHAR(10) +
'                </QueryDefinition> ' + CHAR(13) + CHAR(10) + 
'            </Source> ' + CHAR(13) + CHAR(10) + 
'            <StorageMode>Molap</StorageMode> ' + CHAR(13) + CHAR(10) + 
'            <ProcessingMode>Regular</ProcessingMode> ' + CHAR(13) + CHAR(10) + 
'            <StorageLocation>' + @storageLocation + '</StorageLocation> ' + CHAR(13) + CHAR(10) + 
'            <ProactiveCaching> ' + CHAR(13) + CHAR(10) + 
'                <SilenceInterval>-PT1S</SilenceInterval> ' + CHAR(13) + CHAR(10) + 
'                <Latency>-PT1S</Latency> ' + CHAR(13) + CHAR(10) + 
'                <SilenceOverrideInterval>-PT1S</SilenceOverrideInterval> ' + CHAR(13) + CHAR(10) + 
'                <ForceRebuildInterval>-PT1S</ForceRebuildInterval> ' + CHAR(13) + CHAR(10) + 
'                <Source xsi:type="ProactiveCachingInheritedBinding" /> ' + CHAR(13) + CHAR(10) + 
'            </ProactiveCaching> ' + CHAR(13) + CHAR(10) + 
'        </Partition> ' + CHAR(13) + CHAR(10) + 
'    </ObjectDefinition> ' + CHAR(13) + CHAR(10) + 
'</Alter>';
 end
 else if (@scriptType = 'D')
 begin
  set @scriptXMLA = @scriptXMLA +
'<Delete xmlns="http://schemas.microsoft.com/analysisservices/2003/engine"> ' + CHAR(13) + CHAR(10) + 
'    <Object> ' + CHAR(13) + CHAR(10) + 
'        <DatabaseID>' + @baseDatosOLAP + '</DatabaseID> ' + CHAR(13) + CHAR(10) + 
'        <CubeID>' + @cuboAppName + '</CubeID> ' + CHAR(13) + CHAR(10) + 
'        <MeasureGroupID>' + @measureGroupId + '</MeasureGroupID> ' + CHAR(13) + CHAR(10) + 
'        <PartitionID>' + @PartitionName + '</PartitionID> ' + CHAR(13) + CHAR(10) + 
'    </Object> ' + CHAR(13) + CHAR(10) + 
'</Delete>';
 end

 SELECT @scriptXMLA [ScriptXMLA];
 set nocount off;
End;
GO

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - End script: A13SP_Util_Cube.sql'
PRINT '------------------------------------------------------------------------'
GO