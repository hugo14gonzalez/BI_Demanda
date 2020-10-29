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
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - Start script: A12SP_Util_Prog.sql'
PRINT '------------------------------------------------------------------------'
GO

USE [$(DATABASE_NAME_DW)];

/*====================================================================================
EJECUCION DE PROCESOS
==================================================================================== */
IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[GetSchedule_NextExecutionDay]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
 EXEC('CREATE FUNCTION [Utility].[GetSchedule_NextExecutionDay] (@dateStart date, @dateCurrent date, @includeDateStart bit, @howManyPeriods smallint)
RETURNS Date
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN
 RETURN(GetDate());
END');
GO

ALTER FUNCTION [Utility].[GetSchedule_NextExecutionDay](@dateStart date, @dateCurrent date, @includeDateStart bit, @howManyPeriods smallint)
RETURNS Date
WITH RETURNS NULL ON NULL INPUT
AS
/* ============================================================================================
Proposito: Retorna la fecha de la siguiente ejecución diaria, para agendas con tipo de periodo = Dia.
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2016-04-01
Fecha actualizacion: 2020-07-15

Parametros:
 @dateStart: Fecha de inicio de ejecución.
 @dateCurrent: Fecha desde la cual seleccionar la próxima fecha de ejecución, usualmente es la fecha actual.
 @includeDateStart: Indica si inclue la fecha de inicio.
 @howManyPeriods: Cada cuantos periodos debe repetir la ejecución. Por ejemplo cada 3 días.

Retorno: Retorna la fecha de la siguiente ejecución.

Excepcion: Agenda no encontrada (retorna null).

Ejemplo:
Declare @dateStart date, @dateCurrent date;
set @dateStart = DateAdd(day, -1, GetDate());
set @dateCurrent = GetDate();
SELECT [Utility].[GetSchedule_NextExecutionDay](@dateStart, @dateCurrent, 1, 0);
SELECT [Utility].[GetSchedule_NextExecutionDay](@dateStart, @dateCurrent, 1, 2);
SELECT [Utility].[GetSchedule_NextExecutionDay](@dateStart, @dateCurrent, 1, 5);
============================================================================================ */
begin  
 Declare @dtNext date, @i int, @iDays int;

 if (@howManyPeriods <= 0)
 begin
  set @howManyPeriods = 1;
 end;

 set @i = DATEDIFF(day, @dateStart, @dateCurrent);
 if (@i = 0)
 begin
  if (@includeDateStart = 1)
  begin
   set @dtNext = @dateCurrent;
  end
  else
  begin
   set @dtNext = DATEADD(day, @howManyPeriods, @dateCurrent);
  end;
 end
 else
 begin
  if (@i >= @howManyPeriods)
  begin
   set @i = @i % @howManyPeriods;
  end;
  if (@i = 0)
  begin
   set @dtNext = @dateCurrent; 
  end
  else
  begin
   set @iDays = @howManyPeriods - @i;
   set @dtNext = DATEADD(day, @iDays, @dateCurrent);
  end;
 end;

 return @dtNext;
end
GO

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[GetSchedule_NextExecutionMoth]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
 EXEC('CREATE FUNCTION [Utility].[GetSchedule_NextExecutionMoth] (@dateStart date, @dateCurrent date, @occursInDayOfMonth bit, @howManyPeriods smallint,
  @dayOccurrence tinyint, @occursThe nvarchar(10), @occursDay nvarchar(15))
RETURNS Date
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN
 RETURN(GetDate());
END');
GO

ALTER FUNCTION [Utility].[GetSchedule_NextExecutionMoth](@dateStart date, @dateCurrent date, @howManyPeriods smallint, @occursInDayOfMonth bit, 
 @dayOccurrence tinyint, @occursThe nvarchar(10), @occursDay nvarchar(15))
RETURNS Date
WITH RETURNS NULL ON NULL INPUT
AS
/* ============================================================================================
Proposito: Retorna la fecha de la siguiente ejecución mensual, para agendas con tipo de periodo = Mes.
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2016-04-01
Fecha actualizacion: 2020-07-15

Parametros:
 @dateStart: Fecha de inicio de ejecución.
 @dateCurrent: Fecha desde la cual seleccionar la próxima fecha de ejecución, usualmente es la fecha actual.
 @howManyPeriods: Cada cuantos periodos debe repetir la ejecución. Por ejemplo cada 3 meses.
 @occursInDayOfMonth: Indica si los eventos ocurren: 0: un tipo de día como primer lunes del mes, 1: un número de día del mes. 
 @dayOccurrence: Si @occursInDayOfMonth = 1, indica el número del día del mes que debe ejecutar el evento.
 @occursThe: Si @occursInDayOfMonth = 0 y según [OccursTheDay], indica el número de ocurrencia: Primer, Segundo, Tercero, Cuarto, Ultimo.
 @occursDay: Si @occursInDayOfMonth = 0, indica el tipo de ocurrencia mensual: Lunes, Martes, Miercoles, Jueves, Viernes, Sabado, Domingo, Dia, DiaSemana, DiaFinSemana.

Retorno: Retorna la fecha de la siguiente ejecución.

Excepcion: Agenda no encontrada (retorna null).

Ejemplo:
Declare @dateStart date, @dateCurrent date;
set @dateStart = DateAdd(day, -1, GetDate());
set @dateCurrent = GetDate();
SELECT [Utility].[GetSchedule_NextExecutionMoth](@dateStart, @dateCurrent, 1, 1, 20, 'Primer', 'Sabado');
SELECT [Utility].[GetSchedule_NextExecutionMoth](@dateStart, @dateCurrent, 1, 0, 1, 'Primer', 'Sabado');
SELECT [Utility].[GetSchedule_NextExecutionMoth](@dateStart, @dateCurrent, 2, 0, 1, 'Ultimo', 'Sabado');
============================================================================================ */
begin  
 Declare @dtNext date, @dtNextTempo date, @i int, @iDays int, @idayWeek smallint, @idayWeekCurrent smallint, @iOccurrences int, @iAddDays int;

 if (@howManyPeriods <= 0)
 begin
  set @howManyPeriods = 1;
 end;

 -- Mes del siguiente periodo
 set @dtNext = DATEADD(month, @howManyPeriods, [Utility].[GetStartOfMonth] (year(@dateCurrent), month(@dateCurrent)));

 set @i = DATEDIFF(month, @dateStart, @dtNext);
 if (@i != 0)
 begin
  if (@i >= @howManyPeriods)
  begin
   set @i = @i % @howManyPeriods;
  end;
  
  if (@i != 0)
  begin
   set @dtNext = DATEADD(month, @howManyPeriods - @i, @dtNext); 
  end;
 end;

 /* Evento ocurre en un dia especifico del mes */
 if (@occursInDayOfMonth = 1)
 begin
  set @dtNextTempo = DATEADD(day, @dayOccurrence - 1, @dtNext); 
  if (month(@dtNextTempo) = month(@dtNext))
  begin
   set @dtNext = @dtNextTempo;
  end
  else
  begin
   set @dtNextTempo = DATEADD(month, -1, @dtNextTempo);
   set @dtNext = [Utility].[GetEndOfMonth] (year(@dtNextTempo), month(@dtNextTempo), 1);
  end;
 end
 else /* Evento ocurre en un tipo de dia especifico */
 begin
  set @dtNextTempo = @dtNext;

  if (@occursDay = 'Dia')
  begin
   set @dtNext = [Utility].[GetStartOfMonth] (year(@dtNextTempo), month(@dtNextTempo));

   if (@occursThe = 'Primer')
   begin
    set @dtNext = @dtNext;
   end
   else if (@occursThe = 'Segundo')
   begin
    set @dtNext = DATEADD(day, 1, @dtNext);
   end
   else if (@occursThe = 'Tercero')
   begin
    set @dtNext = DATEADD(day, 2, @dtNext);
   end
   else if (@occursThe = 'Cuarto')
   begin
    set @dtNext = DATEADD(day, 3, @dtNext);
   end
   else if (@occursThe = 'Ultimo')
   begin
    set @dtNext = [Utility].[GetEndOfMonth] (year(@dtNextTempo), month(@dtNextTempo), 1);
   end;
  end
  else
  begin
   set @iOccurrences = 0;

   if (@occursThe = 'Ultimo')
   begin
    set @dtNext = [Utility].[GetEndOfMonth] (year(@dtNextTempo), month(@dtNextTempo), 1);
	set @iAddDays = -1;
   end
   else
   begin
    set @dtNext = [Utility].[GetStartOfMonth] (year(@dtNextTempo), month(@dtNextTempo));
	set @iAddDays = 1;
   end;

   -- Dia de inicio de la semana es el Lunes. Do: 1, Lu: 2, ... Sa: 7 
   -- Dia de la semana en el cual ocurre el evento
   if (@occursDay = 'Monday')
   begin
    set @idayWeek = 2;
   end
   else if (@occursDay = 'Martes')
   begin
    set @idayWeek = 3;
   end
   else if (@occursDay = 'Miercoles')
   begin
    set @idayWeek = 4;
   end
   else if (@occursDay = 'Jueves')
   begin
    set @idayWeek = 5;
   end
   else if (@occursDay = 'Viernes')
   begin
    set @idayWeek = 6;
   end
   else if (@occursDay = 'Sabado')
   begin
    set @idayWeek = 7;
   end
   else if (@occursDay = 'Domingo')
   begin
    set @idayWeek = 1;
   end
   else if (@occursDay = 'DiaSemana')
   begin
    if (@occursThe = 'Primer')
    begin
     set @idayWeek = 2; --Lunes
    end
    else if (@occursThe = 'Segundo')
    begin
     set @idayWeek = 3; --Martes
    end
    else if (@occursThe = 'Tercero')
    begin
     set @idayWeek = 4; --Miercoles
    end
    else if (@occursThe = 'Cuarto')
    begin
     set @idayWeek = 5; --Jueves
    end
    else if (@occursThe = 'Ultimo')
    begin
     set @idayWeek = 6; --Viernes
    end;
   end
   else if (@occursDay = 'DiaFinSemana')
   begin
    if (@occursThe = 'Primer')
    begin
     set @idayWeek = 7; --Sabado
    end
    else if (@occursThe = 'Ultimo')
    begin
     set @idayWeek = 1; --Domingo
    end
    else
	begin
     set @idayWeek = 1; --Domingo
    end;
   end;
  
   while (@iOccurrences < 10)
   begin
    set @idayWeekCurrent = DATEPART(weekday, @dtNext);
    
	if (@idayWeekCurrent = @idayWeek)
	begin
	 set @iOccurrences = @iOccurrences + 1;

     if (@occursThe = 'Primer')
     begin
	  BREAK;
     end
     else if (@occursThe = 'Segundo')
     begin
	  if (@iOccurrences = 2)
      begin
	   BREAK;
      end
	  else
	  begin
       set @dtNext = DATEADD(day, 7, @dtNext);
      end;
     end
     else if (@occursThe = 'Tercero')
     begin
	  if (@iOccurrences = 2)
      begin
	   BREAK;
      end
	  else
	  begin
       set @dtNext = DATEADD(day, 14, @dtNext);
      end;
     end
     else if (@occursThe = 'Cuarto')
     begin
	  if (@iOccurrences = 2)
      begin
	   BREAK;
      end
	  else
	  begin
       set @dtNext = DATEADD(day, 21, @dtNext);
      end;
     end
     else if (@occursThe = 'Ultimo')
     begin
      BREAK;
     end;
	end
    else
    begin
     set @dtNext = DATEADD(day, @iAddDays, @dtNext);
    end;
   end;
  end;
 end;

 return @dtNext;
end
GO


IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[GetSchedule_NextExecutionWeek]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
 EXEC('CREATE FUNCTION [Utility].[GetSchedule_NextExecutionWeek] (@dateCurrent date, @howManyPeriods smallint, 
 @monday bit, @tuesday bit, @wednesday bit, @thursday bit, @friday bit, @saturday bit, @sunday bit)
RETURNS Date
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN
 RETURN(GetDate());
END');
GO

ALTER FUNCTION [Utility].[GetSchedule_NextExecutionWeek](@dateCurrent date, @howManyPeriods smallint, 
 @monday bit, @tuesday bit, @wednesday bit, @thursday bit, @friday bit, @saturday bit, @sunday bit)
RETURNS Date
WITH RETURNS NULL ON NULL INPUT
AS
/* ============================================================================================
Proposito: Retorna la fecha de la siguiente ejecución semanal, para agendas con tipo de periodo = Semana.
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2016-04-01
Fecha actualizacion: 2020-07-15

Parametros:
 @dateCurrent: Fecha desde la cual seleccionar la próxima fecha de ejecución, usualmente es la fecha actual.
 @howManyPeriods: Cada cuantos periodos debe repetir la ejecución. Por ejemplo cada 3 días.
 @monday: Indica si debe ejecutar el día lunes.
 @tuesday: Indica si debe ejecutar el día martes.
 @wednesday: Indica si debe ejecutar el día miercoles.
 @thursday: Indica si debe ejecutar el día jueves.
 @friday: Indica si debe ejecutar el día viernes.
 @saturday: Indica si debe ejecutar el día sabado.
 @sunday: Indica si debe ejecutar el día domingo.

Retorno: Retorna la fecha de la siguiente ejecución.

Excepcion: Agenda no encontrada (retorna null).

Ejemplo:
Declare @dateCurrent date;
set @dateCurrent = GetDate();
set @dateCurrent = '20160425';
set @dateCurrent = '20160426';
set @dateCurrent = '20160501';
SELECT [Utility].[GetSchedule_NextExecutionWeek](@dateCurrent, 1, 0,1,0,1,0,1,0);
SELECT [Utility].[GetSchedule_NextExecutionWeek](@dateCurrent, 2, 1,0,1,0,1,0,0);
SELECT [Utility].[GetSchedule_NextExecutionWeek](@dateCurrent, 3, 0,0,0,0,0,1,1);
============================================================================================ */
begin  
 Declare @dtNext date, @i int, @iDays int, @bExecute bit, @idayWeek smallint;
 Declare @ifirstDayWeek int, @ilastDayWeek int;

 -- Dia de inicio de la semana es el Lunes. Do: 1, Lu: 2, ... Sa: 7 
 Declare @weekTable TABLE (
	[DayWeek] [smallint] PRIMARY KEY NOT NULL,
	[Execute] [bit] NOT NULL); 

 -- Primer dia de la semana 2 = Lu, ultimo dia semana 1 = Do
 set @ifirstDayWeek = DATEPART(weekday, DATEADD(wk, DATEDIFF(wk, 0, GETDATE()), 0));
 set @ilastDayWeek =  DATEPART(weekday, DATEADD(wk, DATEDIFF(wk, 0, GETDATE()), 6));

 INSERT INTO @weekTable([DayWeek], [Execute]) VALUES (1, @sunday);
 INSERT INTO @weekTable([DayWeek], [Execute]) VALUES (2, @monday);
 INSERT INTO @weekTable([DayWeek], [Execute]) VALUES (3, @tuesday);
 INSERT INTO @weekTable([DayWeek], [Execute]) VALUES (4, @wednesday);
 INSERT INTO @weekTable([DayWeek], [Execute]) VALUES (5, @thursday);
 INSERT INTO @weekTable([DayWeek], [Execute]) VALUES (6, @friday);
 INSERT INTO @weekTable([DayWeek], [Execute]) VALUES (7, @saturday);

 if (@howManyPeriods <= 0)
 begin
  set @howManyPeriods = 1;
 end;

 set @idayWeek = DATEPART(weekday, @dateCurrent);

 -- Dia de la siguiente semana 
 if (@idayWeek = @ifirstDayWeek)  /* if (@idayWeek = @ilastDayWeek) */
 begin
  set @dtNext = DATEADD (WEEK, @howManyPeriods - 1, @dateCurrent);
 end
 else
 begin
  set @dtNext = @dateCurrent;
 end;

 set @i = @idayWeek; 
 while (@i <= 7)
 begin
  set @bExecute = 0;
  SELECT @bExecute = [Execute] FROM @weekTable WHERE [DayWeek] = @i;
  if (@bExecute = 1)
  begin
   return DATEADD (day, @i - @idayWeek, @dtNext);
  end;
  set @i = @i + 1;
 end;

 set @i = 1; 
 while (@i < @idayWeek)
 begin
  set @bExecute = 0;
  SELECT @bExecute = [Execute] FROM @weekTable WHERE [DayWeek] = @i;
  if (@bExecute = 1)
  begin
   return DATEADD (day, @i, @dtNext);
  end;
  set @i = @i + 1;
 end;

 return Convert(date, '99991231', 112); ;
end
GO


IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[GetSchedule_NextExecution]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
 EXEC('CREATE FUNCTION [Utility].[GetSchedule_NextExecution] (@scheduleId int, @dateCurrent dateTime, @includeDateStart bit)
RETURNS DateTime
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN
 RETURN(GetDate());
END');
GO

ALTER FUNCTION [Utility].[GetSchedule_NextExecution](@scheduleId int, @dateCurrent dateTime, @includeDateStart bit)
RETURNS DateTime
WITH RETURNS NULL ON NULL INPUT
AS
/* ============================================================================================
Proposito: Retorna la fecha de la siguiente ejecución de un Codigo de agenda dado.
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2016-04-01
Fecha actualizacion: 2020-07-15

Parametros:
 @scheduleId: Codigo de agenda de la tabla: [Utility].[ModelSchedule].
 @dateCurrent: Fecha desde la cual seleccionar la próxima fecha de ejecución, usualmente es la fecha actual.
 @includeDateStart: Indica si inclue la fecha de inicio.

Retorno: Retorna la fecha de la siguiente ejecución.

Excepcion: Agenda no encontrada (retorna null).

Ejemplo:
SELECT * FROM [Utility].[ScheduleSystem] ORDER BY [ScheduleId];

Declare @dateCurrent date;
set @dateCurrent = GetDate();
set @dateCurrent = '20160425';
set @dateCurrent = '20160426';
set @dateCurrent = '20160501';
set @dateCurrent = '20160502';
set @dateCurrent = '20160510';
set @dateCurrent = '20160511';
SELECT [Utility].[GetSchedule_NextExecution](1, @dateCurrent, 1);
SELECT [Utility].[GetSchedule_NextExecution](2, @dateCurrent, 1);
SELECT [Utility].[GetSchedule_NextExecution](3, @dateCurrent, 1);
SELECT [Utility].[GetSchedule_NextExecution](4, @dateCurrent, 1);
SELECT [Utility].[GetSchedule_NextExecution](5, @dateCurrent, 1);
SELECT [Utility].[GetSchedule_NextExecution](6, @dateCurrent, 1);
============================================================================================ */
begin  
 Declare @dtNext date, @dtNextTempo date, @dtMax date, @idayWeek smallint;
 Declare @period nvarchar(10), @howManyPeriods smallint, @dayPeriodType nvarchar(10), @dayHowMany tinyint, @dayHourSatart time, @dayHourEnd time;
 Declare @monday bit, @tuesday bit, @wednesday bit, @thursday bit, @friday bit, @saturday bit, @sunday bit;
 Declare @occursInDayOfMonth bit, @dayOccurrence tinyint, @occursThe nvarchar(10), @occursDay nvarchar(15), @dateStart date, @dateEnd date;

 set @dtMax = Convert(date, '99991231', 112); 
 set @dtNext = NULL;

 SELECT @period = A.[Period], @howManyPeriods = A.[PeriodHowMany], @dayPeriodType = A.[DayPeriod], @dayHowMany = A.[DayHowMany]
  ,@dayHourSatart = A.[DayHourStart], @dayHourEnd = A.[DayHourEnd]
  ,@monday = A.[Monday], @tuesday = A.[Tuesday], @wednesday = A.[Wednesday], @thursday = A.[Thursday], @friday = A.[Fryday], @saturday = A.[Saturday], @sunday = A.[Sunday]
  ,@occursInDayOfMonth = A.[OccursDayOfMonth], @dayOccurrence = A.[DayOccurs], @occursThe = A.[OccursThe], @occursDay = A.[OccursTheDay]
  ,@dateStart = A.[DateStart], @dateEnd = A.[DateEnd]
 FROM [Utility].[ScheduleSystem] A WITH (NOLOCK) 
 WHERE A.[ScheduleId] = @scheduleId
 AND ( (A.[DateStart] <= @dateCurrent) AND (A.[DateEnd] IS NULL OR A.[DateEnd] <= @dateCurrent) );
 
 if (@period IS NULL)
 begin
  return NULL;
 end;

 if (@howManyPeriods <= 0)
 begin
  set @howManyPeriods = 1;
 end;

 if (@period = 'UnaVez')
 begin
  set @dtNext = @dtMax;

  if (@includeDateStart = 1)
  begin
   if (@dateStart >= @dateCurrent)
   begin
    set @dtNext = @dateStart;
   end;
  end
  else
  begin
   if (@dateStart > @dateCurrent)
   begin
    set @dtNext = @dateStart;
   end;
  end;
 end
 else if (@period = 'Dia')
 begin
  set @dtNext = @dtMax;
  
  if ((@dateCurrent < @dateStart) OR (@dateStart = @dateCurrent AND @includeDateStart = 1))
  begin
   set @dtNext = @dateStart;
  end
  else 
  begin
   set @dtNext = [Utility].[GetSchedule_NextExecutionDay](@dateStart, @dateCurrent, @includeDateStart, @howManyPeriods);
   if (@dtNext < @dateCurrent)
   begin
    set @dtNext = [Utility].[GetSchedule_NextExecutionDay](@dateStart, DATEADD(day, 1, @dateCurrent), @includeDateStart, @howManyPeriods);
   end;
  end;
  
  if (@dtNext >= @dateEnd AND @dateStart != @dateEnd)
  begin
   set @dtNext = @dtMax;
  end;
 end
 else if (@period = 'Semana')
 begin
  set @dtNext = @dtMax;

  if (@dateCurrent < @dateStart)
  begin
   set @dtNextTempo = DATEADD(week, - @howManyPeriods, @dateStart); 
   set @dtNext = [Utility].[GetSchedule_NextExecutionWeek](@dtNextTempo, @howManyPeriods, 
    @monday, @tuesday, @wednesday, @thursday, @friday, @saturday, @sunday);
   
   if (@dtNext < @dateStart)
   begin
    set @dtNext = [Utility].[GetSchedule_NextExecutionWeek](@dateStart, @howManyPeriods, 
     @monday, @tuesday, @wednesday, @thursday, @friday, @saturday, @sunday);
   end;
  end
  else if (@dateStart = @dateCurrent AND @includeDateStart = 1)
  begin
   set @idayWeek = DATEPART(weekday, @dateCurrent);
   
   if (@idayWeek = 1 AND @sunday = 1)
   begin
	set @dtNext = @dateCurrent;
   end
   else if (@idayWeek = 2 AND @monday = 1)
   begin
    set @dtNext = @dateCurrent;
   end
   else if (@idayWeek = 3 AND @tuesday = 1)
   begin
    set @dtNext = @dateCurrent;
   end
   else if (@idayWeek = 4 AND @wednesday = 1)
   begin
    set @dtNext = @dateCurrent;
   end
   else if (@idayWeek = 5 AND @thursday = 1)
   begin
    set @dtNext = @dateCurrent;
   end
   else if (@idayWeek = 6 AND @friday = 1)
   begin
    set @dtNext = @dateCurrent;
   end
   else if (@idayWeek = 7 AND @saturday = 1)
   begin
    set @dtNext = @dateCurrent;
   end;
  end
  else
  begin
   set @dtNextTempo = DATEADD(week, - @howManyPeriods, @dateCurrent); 
   set @dtNext = [Utility].[GetSchedule_NextExecutionWeek](@dtNextTempo, @howManyPeriods, 
    @monday, @tuesday, @wednesday, @thursday, @friday, @saturday, @sunday);
   
   if NOT (@dtNext > @dateCurrent OR (@dtNext = @dateCurrent AND @includeDateStart = 1))
   begin
    set @dtNext = [Utility].[GetSchedule_NextExecutionWeek](@dateCurrent, @howManyPeriods, 
     @monday, @tuesday, @wednesday, @thursday, @friday, @saturday, @sunday);
   end;
  end;

  if (@dtNext >= @dateEnd AND @dateStart != @dateEnd)
  begin
   set @dtNext = @dtMax;
  end;
 end
 else if (@period = 'Mes')
 begin
  set @dtNext = @dtMax;

  if ((@dateCurrent < @dateStart) OR (@dateStart = @dateCurrent AND @includeDateStart = 1))
  begin
   set @dtNextTempo = DATEADD(month, - @howManyPeriods, @dateStart);
   set @dtNext = [Utility].[GetSchedule_NextExecutionMoth](@dateStart, @dtNextTempo, @howManyPeriods, @occursInDayOfMonth
    ,@dayOccurrence, @occursThe, @occursDay);

   if (@dtNext < @dateStart)
   begin
    set @dtNext = [Utility].[GetSchedule_NextExecutionMoth](@dateStart, @dateStart, @howManyPeriods, @occursInDayOfMonth
     ,@dayOccurrence, @occursThe, @occursDay);
   end;
  end
  else
  begin
   set @dtNextTempo = DATEADD(month, - @howManyPeriods, @dateCurrent);
   set @dtNext = [Utility].[GetSchedule_NextExecutionMoth](@dateStart, @dtNextTempo, @howManyPeriods, @occursInDayOfMonth
    ,@dayOccurrence, @occursThe, @occursDay);
   
   if NOT (@dtNext > @dateCurrent OR (@dtNext = @dateCurrent AND @includeDateStart = 1))
   begin
    set @dtNext = [Utility].[GetSchedule_NextExecutionMoth](@dateStart, @dateCurrent, @howManyPeriods, @occursInDayOfMonth
     ,@dayOccurrence, @occursThe, @occursDay);
   end;
  end;

  if (@dtNext >= @dateEnd AND @dateStart != @dateEnd)
  begin
   set @dtNext = @dtMax;
  end;
 end
 else 
 begin
  set @dtNext = @dtMax;
 end;

 return @dtNext;
end
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[spModuleProgramming_End]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_EXECUTEsql @statement = N'CREATE PROCEDURE [Utility].[spModuleProgramming_End] AS' 
END
GO
ALTER PROCEDURE [Utility].[spModuleProgramming_End] 
 @bitacoraId bigint = NULL
As
/* ============================================================================================
Proposito: Al finalizar la ejecución de procesos actualiza la tabla: [Utility].[ModuleProgramming]:
 - Borra ejecuciones exitosas: [StateId] = 0.
 - Reprogram ejecuciones con error: [StateId] = 1.
 - Borra ejecuciones con estado programado o reprogramado: [StateId] IN (20, 21), que probablemente no fueron ejecutadas, 
   pero solo para el Codigo de bitacora dado o filas en [Audit].[Bitacora], donde [ParentId] = @bitacoraId.  
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2017-04-10
Fecha actualizacion: 2020-07-15

Parametros:  
 @bitacoraId: Codigo de bitacora.

Ejemplo:
EXECUTE [Utility].[spModuleProgramming_End] 0;

SELECT * FROM [Utility].[ModuleProgramming] ORDER BY [ModuleId],[DateStart];
============================================================================================ */
begin
 set nocount on

 /* Bitacora de programacion. Solo una fila por cada modulo */
 INSERT INTO [Audit].[BitacoraDetail]([BitacoraId],[Name],[StateId],[SeverityId],[TypeId],[DateRun],[DateWork],[Message])
 SELECT DISTINCT @bitacoraId, 'spModuleProgramming_End', [StateId], 0, 10, GetDate(), NULL
 , 'ModuleId: ' + Convert(varchar, [ModuleId]) + ', ModelProgId: ' + [ModelProgId]
 FROM [Utility].[ModuleProgramming] WITH (NOLOCK);

 /* Borrar tareas terminadas satisfactoriamente */
 DELETE FROM [Utility].[ModuleProgramming] WHERE [StateId] = 0; /* Exitoso */

 /* Borrar programaciones no ejecutadas para el codigo de bitacora dado */
 /*
 DELETE FROM [Utility].[ModuleProgramming] 
 FROM [ModuleProgramming] P WITH (NOLOCK)
 WHERE ( P.[BitacoraId] = @bitacoraId OR EXISTS(SELECT B.[BitacoraId] FROM [Audit].[Bitacora] B WITH (NOLOCK) WHERE B.[ParentId] = @bitacoraId) )
 AND P.[StateId] IN (20, 21); 
 */

 /* Reprogramar cuando termine con error */
 UPDATE [Utility].[ModuleProgramming] SET 
   [StateId] = 21 /* Reprogramar ejecucion */
  ,[DateUpdate] = GetDate()
  ,[BitacoraId] = @bitacoraId
 WHERE [StateId] = 1;  /* Error */

 set nocount off;
End
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[spModuleProgramming_Query]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_EXECUTEsql @statement = N'CREATE PROCEDURE [Utility].[spModuleProgramming_Query] AS' 
END
GO
ALTER PROCEDURE [Utility].[spModuleProgramming_Query] 
  @ModuleId int = NULL
 ,@moduleAppName nvarchar(128) = NULL
 ,@TypeId nvarchar(12) = NULL
As
/* ============================================================================================
Proposito: Retorna consulta con la programación de carga de una ETL.
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2017-04-10
Fecha actualizacion: 2020-07-15

Parametros:  
 @ModuleId: Codigo de modulo. Si es nulo o menor o igual a cero (0) utiliza los parámetros de nombre y tipo de modulo.
 @moduleAppName: Nombre de modulo en el codigo de aplicación. Por ejemplo el nombre de una ETL.
  Si suministra el codigo de modulo, no utiliza este parámetro.
 @TypeId: Codigo de tipo de modulo. Por ejemplo: ETL, menu de programa.

Ejemplo:
EXECUTE [Utility].[spModuleProgramming_Query] NULL, 'pkgFactEvento', 'ETL';
EXECUTE [Utility].[spModuleProgramming_Query] 17;

SELECT * FROM [Utility].[ModuleProgramming];
============================================================================================ */
begin
 set nocount on

 if (@ModuleId IS NOT NULL AND @ModuleId > 0)
 begin
  SELECT MP.[ModuleId], M.[AppName] As [AppNameModule], M.[TypeId] As [TypeModuleId]
   ,MP.[ModelProgId], MO.[AppName] As [AppNameModelProg], MO.[TypeId] As [TypeModelProgId]
   ,MP.[DateVersion],MP.[DateStart],MP.[DateEnd],MP.[Version],MP.[VersionId],MP.[StateId]
  FROM [Utility].[ModuleProgramming] MP WITH (NOLOCK)
  INNER JOIN [Utility].[ModuleSystem] M WITH (NOLOCK) ON M.[ModuleId] = MP.[ModuleId]
  INNER JOIN [Utility].[ModelSystem] MO WITH (NOLOCK) ON MO.[ModelId] = MP.[ModelProgId]
  WHERE MP.[ModuleId] = @ModuleId AND MP.[StateId] IN (20, 21)
  ORDER BY MP.[ModelProgId], MP.[DateStart];
 end;
 else
 begin
  SELECT MP.[ModuleId], M.[AppName] As [AppNameModule], M.[TypeId] As [TypeModuleId]
   ,MP.[ModelProgId], MO.[AppName] As [AppNameModelProg], MO.[TypeId] As [TypeModelProgId]
   ,MP.[DateVersion],MP.[DateStart],MP.[DateEnd],MP.[Version],MP.[VersionId],MP.[StateId]
  FROM [Utility].[ModuleProgramming] MP WITH (NOLOCK)
  INNER JOIN [Utility].[ModuleSystem] M WITH (NOLOCK) ON M.[ModuleId] = MP.[ModuleId]
  INNER JOIN [Utility].[ModelSystem] MO WITH (NOLOCK) ON MO.[ModelId] = MP.[ModelProgId]
  WHERE M.[AppName] = @moduleAppName AND M.[TypeId] = @TypeId AND MP.[StateId] IN (20, 21) 
  ORDER BY MP.[ModelProgId], MP.[DateStart];
 end;

 set nocount off;
End
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[spModuleProgramming_Reload]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_EXECUTEsql @statement = N'CREATE PROCEDURE [Utility].[spModuleProgramming_Reload] AS' 
END
GO
ALTER PROCEDURE [Utility].[spModuleProgramming_Reload] 
  @bitacoraId bigint = 0
 ,@dateStart nvarchar(10)
 ,@dateEnd nvarchar(10)
 ,@listModelId varchar(8000)
 ,@ModelFullId nvarchar(12) = 'DW_DFull'
 ,@onlyPartitionCubes bit = 0
 ,@onlyQuery bit = 0
As
/* ============================================================================================
Proposito: Consulta o adiciona filas a la tabla: [Utility].[ModuleProgramming] utilizando los datos de la tabla: [Utility].[ModelLoad].
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2017-04-10
Fecha actualizacion: 2020-07-15

Parametros:  
 @bitacoraId: Codigo de ejecución de proceso.
 @dateStart: Fecha inicial en formato: YYYY-MM-DD.
 @dateEnd: Fecha final en formato: YYYY-MM-DD.
 @listModelId: Lista de codigos de modelos, separados por coma. Ejemplo: 'DW_DEvento,DW_DEventoA'
 @ModelFullId: Codigo de modelo completo. Utilizado para establecer orden de ejecucion. Ejemplo: 'DW_DFull'
 @onlyPartitionCubes: Indica si solo programar procesamiento de dimensiones de cubos y creacion y procesamiento de particiones de cubos para los modelos indicados.
 @onlyQuery: 0: Solo retorna consulta. 1: Adiciona los datos a la tabla de programacion

Ejemplo:
TRUNCATE TABLE [Utility].[ModuleProgramming];

SELECT MP.[Priority], MP.[ModelId],MO.[AppName] As [Model],MP.[SequenceId],MP.[ModuleId],MD.[AppName] As [Module]
,MP.[ModelProgId],MOP.[AppName] As [ModelProg],MP.[DateVersion],MP.[DateStart],MP.[DateEnd],MP.[Version],MP.[VersionId]
,MP.[StateId],MP.[DateUpdate] 
FROM [Utility].[ModuleProgramming] MP
INNER JOIN [Utility].[ModuleSystem] MD ON MD.[ModuleId] = MP.[ModuleId]
INNER JOIN [Utility].[ModelSystem] MO ON MO.[ModelId] = MP.[ModelId]
INNER JOIN [Utility].[ModelSystem] MOP ON MOP.[ModelId] = MP.[ModelProgId]
ORDER BY MP.[Priority],MP.[ModelId],MP.[SequenceId],MP.[DateStart];

Declare @dateEnd nvarchar(12);
set @dateEnd = Convert(varchar(10), DATEADD(D, -1, CONVERT(date, GetDate()))); 
EXECUTE [Utility].[spModuleProgramming_Reload] 0, '2015-07-01', @dateEnd, 'DW_DEvento,DW_DEventoE,DW_DEventoG', 'DW_DFull', 0, 0;

Declare @dateEnd nvarchar(12);
set @dateEnd = Convert(varchar(10), DATEADD(D, -1, CONVERT(date, GetDate()))); 
EXECUTE [Utility].[spModuleProgramming_Reload] 0, '2015-07-01', @dateEnd, 'DW_DEvento,DW_DEventoE,DW_DEventoG', 'DW_DFull', 1, 0;
============================================================================================ */
begin
 set nocount on

 Declare @dtDateStart date, @dtDateEnd date, @dtDateEndLoad date, @dtDateNext date, @bOK bit, @datePart nvarchar(12), @dtTempDateEnd date;
 Declare @priority smallint, @SequenceId smallint, @ModuleId int, @ModelId nvarchar(12), @ModelProgId nvarchar(12), @VersionId nvarchar(12);
 Declare @UseDatesProcess bit, @UseVersion bit, @ReloadPeriodType nvarchar(12), @TypeId nvarchar(12);

 if (@dateStart IS NULL OR RTrim(@dateStart) = '')
 begin
  set @dtDateStart = DateAdd(day, -2, GetDate());
  set @dtDateEnd = DateAdd(day, 1, @dtDateStart);
 end
 else
 begin
  set @dtDateStart = convert(date, @dateStart, 120);
  set @dtDateEnd = convert(date, @dateEnd, 120);
 end;

 Declare @tmpModuleProgramming TABLE (
	[ProgrammingId] [bigint] IDENTITY(1,1) PRIMARY KEY NOT NULL,
	[Priority] [smallint] NOT NULL,
	[ModelId] [nvarchar](12) COLLATE DATABASE_DEFAULT NOT NULL,
	[SequenceId] [smallint] NOT NULL,
	[ModuleId] [int] NOT NULL,
	[ModelProgId] [nvarchar](12) COLLATE DATABASE_DEFAULT NOT NULL,
	[DateVersion] [date] NOT NULL,
	[DateStart] [date] NOT NULL,
	[DateEnd] [date] NOT NULL,
	[Version] [smallint] NOT NULL,
	[VersionId] [nvarchar](12) COLLATE DATABASE_DEFAULT NOT NULL); 

 Declare @tmpModelId table 
 (  
  [ModelId] [nvarchar](12) COLLATE DATABASE_DEFAULT
 ); 

 if (@ModelFullId IS NULL OR LTrim(@ModelFullId) = '')
 begin
  set @ModelFullId = 'DW_DFull';
 end;

 INSERT INTO @tmpModelId ([ModelId])
 SELECT DISTINCT RTrim(LTrim([value])) FROM STRING_SPLIT(@listModelId, ',');
/* SELECT DISTINCT RTrim(LTrim([value])) FROM [Utility].[fnString_Split](@listModelId, ','); */

 DECLARE Cur_Loop CURSOR FORWARD_ONLY READ_ONLY FOR
 SELECT IIF([ModelId] = @ModelFullId, [Priority2], IIF([TypeModel] = 'Cubo' OR [UseDatesProcess] = 1, [Priority], [Priority2])) [Priority]
 ,IIF([ModelId] = @ModelFullId OR ([TypeModel] = 'Cubo' OR [UseDatesProcess] = 1), [ModelId], [ModelProgId]) [ModelId]
 ,IIF([ModelId] = @ModelFullId OR ([TypeModel] = 'Cubo' OR [UseDatesProcess] = 1), [SequenceId], [Priority2]) [SequenceId]
 ,[ModuleId],[ModelProgId],[VersionId],[UseDatesProcess],[UseVersion],[ReloadPeriodType],[TypeModel]
 FROM (
 SELECT IsNull(MLF2.[SequenceId], 1) [Priority2]
 , IsNull(MLF.[SequenceId], 1) [Priority], ML.[ModelId], ML.[SequenceId], ML.[ModuleId], ML.[ModelProgId], ISNULL(CP.[CubeId], '0') [VersionId]
 , MO.[UseDatesProcess], MO.[UseVersion], MO.[ReloadPeriodType], MO.[TypeId] [TypeModel]
 , ROW_NUMBER() OVER (PARTITION BY IsNull(MLF2.[SequenceId], 1)  
     ORDER BY CASE WHEN MO.[TypeId] <> 'Cubo' THEN IsNull(MLF.[SequenceId], 1) END ASC
            , CASE WHEN MO.[TypeId] = 'Cubo' THEN IsNull(MLF.[SequenceId], 1) END DESC, IsNull(MLF2.[SequenceId], 1), IsNull(MLF.[SequenceId], 1)) [Fila]
 , ROW_NUMBER() OVER (PARTITION BY IsNull(MLF2.[SequenceId], 1)  
     ORDER BY CASE WHEN MO.[TypeId] <> 'Cubo' THEN IsNull(MLF.[SequenceId], 1) END ASC
            , CASE WHEN MO.[TypeId] = 'Cubo' AND MO.[UseDatesProcess] = 0 THEN IsNull(MLF.[SequenceId], 1) END ASC
            , CASE WHEN MO.[TypeId] = 'Cubo' AND MO.[UseDatesProcess] = 1 THEN IsNull(MLF.[SequenceId], 1) END DESC
			, IsNull(MLF2.[SequenceId], 1), IsNull(MLF.[SequenceId], 1)) [Fila_2]
 FROM [Utility].[ModelLoad] ML WITH (NOLOCK) 
 INNER JOIN @tmpModelId tmp ON tmp.[ModelId] = ML.[ModelId]
 INNER JOIN [Utility].[ModelSystem] MO WITH (NOLOCK) ON MO.[ModelId] = ML.[ModelProgId]
 INNER JOIN [Utility].[ModuleSystem] MD WITH (NOLOCK) ON MD.[ModuleId] = ML.[ModuleId]
 LEFT JOIN [Utility].[CubePartition] CP WITH (NOLOCK) ON CP.[ModelId] = ML.[ModelProgId]
 LEFT JOIN [Utility].[ModelLoad] MLF ON MLF.[ModelId] = @ModelFullId AND MLF.[ModelProgId] = ML.[ModelId]
 LEFT JOIN [Utility].[ModelLoad] MLF2 ON (MLF2.[ModelId] = @ModelFullId AND MLF2.[ModelId] = ML.[ModelId] AND MLF2.[SequenceId] = MLF.[SequenceId]) 
 OR (MLF2.[ModelId] = @ModelFullId AND MLF2.[ModuleId] = ML.[ModuleId] AND MLF2.[ModelProgId] = ML.[ModelProgId])
 WHERE (@onlyPartitionCubes = 0) OR (@onlyPartitionCubes = 1 AND MO.[TypeId] = 'Cubo') /* OR (@onlyPartitionCubes = 1 AND CP.[CubeId] IS NOT NULL) */
 ) T
 WHERE ([UseDatesProcess] = 1 OR ([UseDatesProcess] = 0 AND [Fila] = 1) )
 ORDER BY [Priority], [ModelId], [SequenceId];

 OPEN Cur_Loop;
 FETCH NEXT FROM Cur_Loop INTO @priority, @ModelId, @SequenceId, @ModuleId, @ModelProgId, @VersionId, @UseDatesProcess, @UseVersion, @ReloadPeriodType, @TypeId;
 WHILE @@FETCH_STATUS = 0
 BEGIN   
  set @bOK = 1;

  if (@ReloadPeriodType = 'Dia')
  begin
   SET @datePart = 'DAY';
  end
  else if (@ReloadPeriodType = 'Semana')
  begin
   SET @datePart = 'WEEK';
  end
  else if (@ReloadPeriodType = 'Mes')
  begin
   SET @datePart = 'MONTH';
  end
  else if (@ReloadPeriodType = 'Bimestre')
  begin
   SET @datePart = 'MONTH2';
  end
  else if (@ReloadPeriodType = 'Trimestre')
  begin
   SET @datePart = 'QUARTER';
  end
  else if (@ReloadPeriodType = 'Semestre')
  begin
   SET @datePart = 'HALF';
  end
  else if (@ReloadPeriodType = 'Año')
  begin
   SET @datePart = 'YEAR';
  end
  else
  begin
   INSERT INTO [Audit].[BitacoraTable]([BitacoraId],[Name],[StateId],[SeverityId],[TypeId],[DateRun],[DateWork],[TableTarget]
    ,[FieldTarget],[ValueTarget],[TableSource],[FieldSource],[ValueSource],[PKField1],[PKValue1],[PKField2],[PKValue2],[PKField3],[PKValue3]
    ,[PKField4],[PKValue4],[PKField5],[PKValue5],[Message])
   VALUES (@bitacoraId, 'spModuleProgramming_Reload', 1, 2, 7, GetDate(), NULL, 'Utility.ModuleProgramming', NULL, NULL, 'Utility.ModelSystem'
    , 'PeriodType', @ReloadPeriodType, 'ModelId', @ModelId, 'SequenceId', @SequenceId, 'ModuleId', @ModuleId, 'ModelProgId', @ModelProgId, NULL, NULL, 'Valor no permitido');

   set @bOK = 0;   
  end;

  if (@bOK = 1)
  begin
   if (@TypeId = 'Cubo' AND @UseDatesProcess = 1)
   begin
    set @dtDateNext = [Utility].[GetStartOfDatePart] (@datePart, @dtDateStart);

    set @dtTempDateEnd = [Utility].[GetStartOfDatePart] (@datePart, @dtDateEnd);
	if (@dtTempDateEnd <> @dtDateEnd)
	begin
	 set @dtTempDateEnd = DATEADD(day, 1, [Utility].[GetEndOfDatePart](@datePart, @dtDateEnd, 1));   
    end;
   end
   else
   begin
    set @dtDateNext = @dtDateStart;
	set @dtTempDateEnd = @dtDateEnd;
   end;

   While @dtDateNext < @dtTempDateEnd
   begin
    if (@UseDatesProcess = 0)
	begin
	 set @dtDateNext = Convert(date, '1900-01-01', 120);
	 set @dtDateEndLoad = @dtTempDateEnd;
	end
	else
	begin
     SELECT @dtDateEndLoad = DATEADD(day, 1, [Utility].[GetEndOfDatePart](@datePart, @dtDateNext, 1));
     if (@dtDateEndLoad > @dtTempDateEnd)
     begin
      set @dtDateEndLoad = @dtTempDateEnd;
     end;
	end;

	if NOT (@UseDatesProcess = 0 AND EXISTS(SELECT * FROM @tmpModuleProgramming WHERE [ModuleId] = @ModuleId AND [ModelProgId] = @ModelProgId))
	begin
     if (@useVersion = 1)
     begin
      INSERT INTO @tmpModuleProgramming ([Priority], [ModelId], [SequenceId],[ModuleId],[ModelProgId],[DateVersion],[DateStart],[DateEnd],[Version],[VersionId])
      SELECT @priority, @ModelId, @SequenceId, @ModuleId, @ModelProgId, MV.[DateVersion], MV.[DateStart], MV.[DateEnd], MV.[Version], MV.[VersionId]  
      FROM [Utility].[ModelVersion] MV WITH (NOLOCK)
      WHERE MV.[ModelId] = @ModelProgId 
      AND MV.[DateStart] = (SELECT Max(MV2.[DateStart]) FROM [Utility].[ModelVersion] MV2 WITH (NOLOCK)
                            WHERE MV2.[ModelId] = @ModelProgId AND MV2.[DateStart] >= @dtDateNext AND MV2.[DateEnd] <= @dtDateNext AND MV2.[StateId] <> 0);
     end
     else
     begin 
      INSERT INTO @tmpModuleProgramming ([Priority], [ModelId], [SequenceId],[ModuleId],[ModelProgId],[DateVersion],[DateStart],[DateEnd],[Version],[VersionId])
      VALUES (@priority, @ModelId, @SequenceId, @ModuleId, @ModelProgId, @dtDateNext, @dtDateNext, @dtDateEndLoad, 0, @VersionId);
     end;
    end;

	set @dtDateNext = @dtDateEndLoad;
   end;
  end;

  FETCH NEXT FROM Cur_Loop INTO @priority, @ModelId, @SequenceId, @ModuleId, @ModelProgId, @VersionId, @UseDatesProcess, @UseVersion, @ReloadPeriodType, @TypeId;
 END
 CLOSE Cur_Loop;
 DEALLOCATE Cur_Loop;


 if (@onlyQuery = 1)
 begin
  SELECT [Priority],[ModelId],[SequenceId],[ModuleId],[ModelProgId],[DateVersion],[DateStart],[DateEnd],[Version],[VersionId]
  , 20 [StateId], GetDate() [DateUpdate], @bitacoraId [BitacoraId]
  FROM @tmpModuleProgramming
  ORDER BY [Priority],[ModelId],[SequenceId],[DateStart];
 end
 else
 begin
  WITH [CTE_P] AS
  (
   SELECT [Priority], [ModelId], [SequenceId], [ModuleId], [ModelProgId], [DateVersion], [DateStart], [DateEnd], [Version], [VersionId] 
  , ROW_NUMBER() OVER (PARTITION BY [ModuleId], [ModelProgId], [DateStart]
	   ORDER BY [ModuleId], [ModelProgId], [DateStart], [Priority], [ModelId], [SequenceId]) [Fila]
   FROM @tmpModuleProgramming
  )
  MERGE [Utility].[ModuleProgramming] AS Target
  USING (SELECT TOP 100 PERCENT [Priority], [ModelId], [SequenceId], [ModuleId], [ModelProgId], [DateVersion], [DateStart], [DateEnd], [Version], [VersionId]
         FROM [CTE_P]
		 WHERE [Fila] = 1
		 ORDER BY [Priority], [ModelId], [SequenceId], [ModuleId], [DateVersion]) AS Source
 ON (Target.[ModuleId] = Source.[ModuleId] AND Target.[ModelProgId] = Source.[ModelProgId] AND Target.[DateStart] = Source.[DateStart])
 -- Cuando cazan, actualzar si hay algun cambio
 WHEN MATCHED AND 
  (   Target.[Priority] <> Source.[Priority] 
   OR Target.[ModelId] <> Source.[ModelId] 
   OR Target.[SequenceId] <> Source.[SequenceId] 
   OR Target.[DateStart] <> Source.[DateStart] 
   OR Target.[DateEnd] <> Source.[DateEnd] 
   OR Target.[Version] <> Source.[Version] 
   OR Target.[VersionId] <> Source.[VersionId]  ) THEN
  UPDATE SET 
    Target.[Priority] = Source.[Priority]
   ,Target.[ModelId] = Source.[ModelId]
   ,Target.[SequenceId] = Source.[SequenceId]
   ,Target.[DateStart] = Source.[DateStart]
   ,Target.[DateEnd] = Source.[DateEnd]
   ,Target.[Version] = Source.[Version]
   ,Target.[VersionId] = Source.[VersionId]
   ,Target.[StateId] = 20 /* Programado para ejecutar */
   ,Target.[DateUpdate] = GetDate()
   ,Target.[BitacoraId] = @bitacoraId
 -- Cuando no cazan, insertar
 WHEN NOT MATCHED BY TARGET THEN
  INSERT ([Priority],[ModelId],[SequenceId],[ModuleId],[ModelProgId],[DateVersion],[DateStart],[DateEnd],[Version],[VersionId],[StateId],[DateUpdate],[BitacoraId])
  VALUES (Source.[Priority],Source.[ModelId],Source.[SequenceId],Source.[ModuleId], Source.[ModelProgId], Source.[DateVersion], Source.[DateStart]
  , Source.[DateEnd], Source.[Version], Source.[VersionId], 20, GetDate(), @bitacoraId);
 -- Cuando existe una fila en el destino, pero no en el origen: No borrar (DELETE;)
 
  SELECT [Priority],[ModelId],[SequenceId],[ModuleId],[ModelProgId],[DateVersion],[DateStart],[DateEnd],[Version],[VersionId]
  ,[StateId],[DateUpdate],[BitacoraId]
  FROM [Utility].[ModuleProgramming]
  ORDER BY [Priority],[ModelId],[SequenceId],[DateStart];
 end;

 set nocount off;
End
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[spModuleProgramming_Reload_Query]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_EXECUTEsql @statement = N'CREATE PROCEDURE [Utility].[spModuleProgramming_Reload_Query] AS' 
END
GO
ALTER PROCEDURE [Utility].[spModuleProgramming_Reload_Query] 
As
/* ============================================================================================
Proposito: Retorna consulta con la programación de recarga.
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2018-04-03
Fecha actualizacion: 2018-04-03

NOTA: En SQL 2012, hay bug para ejecutar paquete hijo en paquete padre: 
http://microsoft-ssis.blogspot.com.co/2014/06/ssis-2012-execute-package-task-external.html
http://microsoft-ssis.blogspot.com.co/2013/01/call-ssis-2012-package-within-net.html

Ejemplo:
EXECUTE [Utility].[spModuleProgramming_Reload_Query];
============================================================================================ */
begin
 set nocount on

 SELECT [Priority],[SequenceId],[ModuleId],[AppNameModule],[TypeModule],[TypeModel],[StateId]
 FROM (
  SELECT MP.[Priority],MP.[SequenceId],MP.[ModuleId],MD.[AppName] As [AppNameModule],MP.[StateId]
  , MD.[TypeId] [TypeModule], MO.[TypeId] [TypeModel]
  , ROW_NUMBER() OVER (PARTITION BY MP.[ModuleId]
	    ORDER BY MP.[ModuleId], CASE WHEN MO.[TypeId] <> 'Cubo' THEN MP.[Priority] END ASC
	                         , CASE WHEN MO.[TypeId] = 'Cubo' THEN MP.[Priority] END DESC, MP.[SequenceId]) [Fila]
  FROM [Utility].[ModuleProgramming] MP
  INNER JOIN [Utility].[ModuleSystem] MD ON MD.[ModuleId] = MP.[ModuleId]
  INNER JOIN [Utility].[ModelSystem] MO ON MO.[ModelId] = MP.[ModelProgId]
 ) T
 WHERE [Fila] = 1 AND [StateId] IN (20, 21)
 ORDER BY [Priority],[SequenceId];

 set nocount off;
End
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[spModuleProgramming_Sheduling]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_EXECUTEsql @statement = N'CREATE PROCEDURE [Utility].[spModuleProgramming_Sheduling] AS' 
END
GO
ALTER PROCEDURE [Utility].[spModuleProgramming_Sheduling] 
 @bitacoraId bigint = 0
,@ModelFullId nvarchar(12) = 'DW_DFull'
,@dateProcess nvarchar(10) = NULL
As
/* ============================================================================================
Proposito: Llena la tabla: [Utility].[ModuleProgramming] con la agenda de ejecución de modulos para los modelos definidos en la tabla: [Utility].[ModelSchedule].
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2017-04-10
Fecha actualizacion: 2020-07-15

Parametros:  
 @bitacoraId: Codigo de ejecución de proceso.
 @ModelFullId: Codigo de modelo completo. Utilizado para establecer orden de ejecucion. Ejemplo: 'DW_DFull'
 @dateProcess: Fecha de proceso en formato: YYYY-MM-DD. Generalmente no es suministrada, para utilizar la fecha actual.

Ejemplo:
TRUNCATE TABLE [Utility].[ModuleProgramming];
EXECUTE [Utility].[spModuleProgramming_Sheduling] 0, NULL, '2016-05-14';
EXECUTE [Utility].[spModuleProgramming_Sheduling] 0;

SELECT MP.[Priority], MP.[ModelId],MO.[AppName] As [Model],MP.[SequenceId],MP.[ModuleId],MD.[AppName] As [Module]
,MP.[ModelProgId],MOP.[AppName] As [ModelProg],MP.[DateVersion],MP.[DateStart],MP.[DateEnd],MP.[Version],MP.[VersionId]
,MP.[StateId],MP.[DateUpdate] 
FROM [Utility].[ModuleProgramming] MP
INNER JOIN [Utility].[ModuleSystem] MD ON MD.[ModuleId] = MP.[ModuleId]
INNER JOIN [Utility].[ModelSystem] MO ON MO.[ModelId] = MP.[ModelId]
INNER JOIN [Utility].[ModelSystem] MOP ON MOP.[ModelId] = MP.[ModelProgId]
ORDER BY MP.[Priority],MP.[ModelId],MP.[SequenceId],MP.[DateStart];

Declare @dateCurrent date;
set @dateCurrent = '20160514';
set @dateCurrent = GetDate();
SELECT MM.[ModelId], MD.[ModuleId], MD.[AppName] 
,MA.[ScheduleId],MA.[UseVersion],MA.[PeriodType],MA.[PeriodQuantity],MA.[PeriodTypeBefore],MA.[PeriodsBefore]
,Convert(date, [Utility].[GetSchedule_NextExecution](MA.[ScheduleId], @dateCurrent, 1)) [FechaSiguiente]
,MA.[Enabled]
,MP.[DateVersion],MP.[DateStart],MP.[DateEnd],MP.[StateId]
FROM [Utility].[ModuleModel] MM
INNER JOIN [Utility].[ModuleSystem] MD ON MD.[ModuleId] = MM.[ModuleId]
INNER JOIN [Utility].[ModelSchedule] MA ON MA.[ModelId] = MM.[ModelId]
LEFT JOIN [Utility].[ModuleProgramming] MP ON MP.[ModuleId] = MD.[ModuleId] AND MP.[ModelProgId] = MM.[ModelId]
ORDER BY MM.[ModelId],MM.[ModuleId],MP.[DateStart];
============================================================================================ */
begin
 set nocount on

 Declare @ModelId nvarchar(12), @ModuleId int, @useVersion bit, @periodProcess nvarchar(12), @periodsQuntity smallint, @periodsPrevious smallint;
 Declare @scheduleId int, @dateStart date, @dateEnd date, @dateCurrent date, @dateCurrentEndWeek date, @dateCurrentEndMonth date;
 Declare @dateCurrentEndMonth2 date, @dateCurrentEndQuarter date, @dateCurrentEndHalf date, @dateCurrentEndYear date;
 Declare @iYear int, @iMonth int, @bOK bit, @versionId nvarchar(12), @SequenceId smallint, @datePart nvarchar(12);
 Declare @dtTempoDateEnd date, @dtDateNext date, @dtDate1 date, @dtDate2 date, @periodBefore nvarchar(12), @priority smallint;

 Declare @tmpModuleProgramming TABLE (
	[ProgrammingId] [bigint] IDENTITY(1,1) PRIMARY KEY NOT NULL,
	[Priority] [smallint] NOT NULL,
	[ModelId] [nvarchar](12) COLLATE DATABASE_DEFAULT NOT NULL,
	[SequenceId] [smallint] NOT NULL,
	[ModuleId] [int] NOT NULL,
	[ModelProgId] [nvarchar](12) COLLATE DATABASE_DEFAULT NOT NULL,
	[DateVersion] [date] NOT NULL,
	[DateStart] [date] NOT NULL,
	[DateEnd] [date] NOT NULL,
	[Version] [smallint] NOT NULL,
	[VersionId] [nvarchar](12) COLLATE DATABASE_DEFAULT NOT NULL); 

 if (@ModelFullId IS NULL OR LTrim(@ModelFullId) = '')
 begin
  set @ModelFullId = 'DW_DFull';
 end;

 if (@dateProcess IS NULL OR RTrim(@dateProcess) = '')
 begin
  set @dateCurrent = GetDate();
 end
 else
 begin
  set @dateCurrent = convert(date, @dateProcess, 120);
 end;

 set @iYear = Year(@dateCurrent);
 set @iMonth = Month(@dateCurrent);
 SELECT @dateCurrentEndWeek = [Utility].[GetEndOftWeek] (@dateCurrent, 1);
 SELECT @dateCurrentEndMonth = [Utility].[GetEndOfMonth] (@iYear, @iMonth, 1);
 SELECT @dateCurrentEndMonth2 = [Utility].[GetEndOfMonth2] (@iYear, [Utility].[GetMonth2] (@iMonth), 1);
 SELECT @dateCurrentEndQuarter = [Utility].[GetEndOfQuarter] (@iYear, [Utility].[GetQuarter] (@iMonth), 1);
 SELECT @dateCurrentEndHalf = [Utility].[GetEndOfHalf] (@iYear, [Utility].[GetHalf] (@iMonth), 1);
 SELECT @dateCurrentEndYear = [Utility].[GetEndOfYear] (@iYear, 1);

 DECLARE Cur_Loop CURSOR FORWARD_ONLY READ_ONLY FOR
 SELECT DISTINCT [Priority],[SequenceId],[ModuleId],[ModelId],[UseVersion],[PeriodType],[PeriodQuantity],[PeriodTypeBefore],[PeriodsBefore],[ScheduleId],[VersionId]
 FROM (
  SELECT IsNull(MLF.[SequenceId], 1) [Priority],MM.[SequenceId],MM.[ModuleId],MM.[ModelId],MA.[UseVersion],MA.[PeriodType],MA.[PeriodQuantity],MA.[PeriodTypeBefore],MA.[PeriodsBefore],A.[ScheduleId]
   , Convert(date, [Utility].[GetSchedule_NextExecution](A.[ScheduleId], @dateCurrent, 1)) [FechaSiguiente]
   , ISNULL(CP.[CubeId], '0') [VersionId]
  FROM [Utility].[ModuleModel] MM WITH (NOLOCK)  
  INNER JOIN [Utility].[ModelSchedule] MA WITH (NOLOCK)  ON MA.[ModelId] = MM.[ModelId]
  INNER JOIN [Utility].[ScheduleSystem] A WITH (NOLOCK)  ON A.[ScheduleId] = MA.[ScheduleId]
   AND ( (A.[DateStart] <= @dateCurrent) AND (A.[DateEnd] IS NULL OR A.[DateEnd] <= @dateCurrent) )
  LEFT JOIN [Utility].[CubePartition] CP WITH (NOLOCK) ON CP.[ModelId] = MM.[ModelId]
  LEFT JOIN [Utility].[ModelLoad] MLF ON MLF.[ModelId] = @ModelFullId AND MLF.[ModelProgId] = MM.[ModelId]
  WHERE MA.[Enabled] = 1
 ) A
 WHERE A.[FechaSiguiente] = @dateCurrent
 ORDER BY [Priority],[ModelId],[SequenceId],[ModuleId];
    
 OPEN Cur_Loop;
 FETCH NEXT FROM Cur_Loop INTO @priority, @SequenceId, @ModuleId, @ModelId, @useVersion, @periodProcess, @periodsQuntity, @periodBefore, @periodsPrevious, @scheduleId, @VersionId;
 WHILE @@FETCH_STATUS = 0
 BEGIN   
  if (@useVersion = 1)
  begin
   INSERT INTO @tmpModuleProgramming ([Priority], [ModelId], [SequenceId],[ModuleId],[ModelProgId],[DateVersion],[DateStart],[DateEnd],[Version],[VersionId])
   SELECT @priority, @ModelId, @SequenceId, @ModuleId, @ModelId, MV.[DateVersion], MV.[DateStart], MV.[DateEnd], MV.[Version], MV.[VersionId]  
   FROM [Utility].[ModelVersion] MV WITH (NOLOCK)
   WHERE MV.[ModelId] = @ModelId AND MV.[DateStart] >= @dateCurrent AND MV.[DateEnd] <= @dateCurrent AND MV.[StateId] <> 0
   AND MV.[DateStart] = (SELECT Max(MV2.[DateStart]) FROM [Utility].[ModelVersion] MV2 WITH (NOLOCK)
                         WHERE MV2.[ModelId] = @ModelId AND MV2.[DateStart] >= @dateCurrent AND MV2.[DateEnd] <= @dateCurrent AND MV2.[StateId] <> 0);
  end;
  else
  begin
   set @bOK = 1;

   if (@periodProcess NOT IN ('Dia', 'Semana', 'Mes', 'Bimestre', 'Trimestre', 'Semestre', 'Año'))
   begin
    INSERT INTO [Audit].[BitacoraTable]([BitacoraId],[Name],[StateId],[SeverityId],[TypeId],[DateRun],[DateWork],[TableTarget]
     ,[FieldTarget],[ValueTarget],[TableSource],[FieldSource],[ValueSource],[PKField1],[PKValue1],[PKField2],[PKValue2],[PKField3],[PKValue3]
     ,[PKField4],[PKValue4],[PKField5],[PKValue5],[Message])
    VALUES (@bitacoraId, 'spModuleProgramming_Sheduling', 1, 2, 7, GetDate(), NULL, 'Utility.ModuleProgramming', NULL, NULL, 'Utility.ModelSchedule'
     , 'PeriodType', @periodProcess, 'ModuleId', @ModuleId, 'ModelId', @ModelId, 'ScheduleId', @scheduleId, NULL, NULL, NULL, NULL, 'Valor no permitido');

    set @bOK = 0;   
   end;

   if (@periodBefore NOT IN ('Dia', 'Semana', 'Mes', 'Bimestre', 'Trimestre', 'Semestre', 'Año'))
   begin
    INSERT INTO [Audit].[BitacoraTable]([BitacoraId],[Name],[StateId],[SeverityId],[TypeId],[DateRun],[DateWork],[TableTarget]
     ,[FieldTarget],[ValueTarget],[TableSource],[FieldSource],[ValueSource],[PKField1],[PKValue1],[PKField2],[PKValue2],[PKField3],[PKValue3]
     ,[PKField4],[PKValue4],[PKField5],[PKValue5],[Message])
    VALUES (@bitacoraId, 'spModuleProgramming_Sheduling', 1, 2, 7, GetDate(), NULL, 'Utility.ModuleProgramming', NULL, NULL, 'Utility.ModelSchedule'
     , 'PeriodTypeBefore', @periodBefore, 'ModuleId', @ModuleId, 'ModelId', @ModelId, 'ScheduleId', @scheduleId, NULL, NULL, NULL, NULL, 'Valor no permitido');

    set @bOK = 0;   
   end;

   if (@bOK = 1) 
   begin
    if (@periodProcess = 'Dia')
    begin
     SET @datePart = 'DAY';

     if (@periodBefore = 'Dia')
     begin
	  set @dateEnd = DATEADD(day, - @periodsPrevious, @dateCurrent);
     end
     else if (@periodBefore = 'Semana')
     begin
	  set @dateEnd = DATEADD(week, - @periodsPrevious, @dateCurrentEndWeek);
     end
     else if (@periodBefore = 'Mes')
     begin
	  set @dateEnd = DATEADD(month, - @periodsPrevious, @dateCurrentEndMonth);
	  set @dateEnd = [Utility].[GetEndOfMonth] (year(@dateEnd), Month(@dateEnd), 1);
     end
     else if (@periodBefore = 'Bimestre')
     begin
	  set @dateEnd = DATEADD(month, - (@periodsPrevious * 2), @dateCurrentEndMonth2);
	  set @dateEnd = [Utility].[GetEndOfMonth] (year(@dateEnd), Month(@dateEnd), 1);
     end
     else if (@periodBefore = 'Trimestre')
     begin
	  set @dateEnd = DATEADD(quarter, - @periodsPrevious, @dateCurrentEndQuarter);
	  set @dateEnd = [Utility].[GetEndOfMonth] (year(@dateEnd), Month(@dateEnd), 1);
     end
     else if (@periodBefore = 'Semestre')
     begin
	  set @dateEnd = DATEADD(month, - (@periodsPrevious * 6), @dateCurrentEndHalf);
	  set @dateEnd = [Utility].[GetEndOfMonth] (year(@dateEnd), Month(@dateEnd), 1);
     end
     else if (@periodBefore = 'Año')
     begin
	  set @dateEnd = DATEADD(year, - @periodsPrevious, @dateCurrentEndYear);
     end
	 else
     begin
	  set @dateEnd = DATEADD(day, - @periodsPrevious, @dateCurrent);
     end;

	 set @dateStart = DATEADD(day, - @periodsQuntity + 1, @dateEnd);
	 set @dateEnd = DATEADD(day, 1, @dateEnd);
    end
    else if (@periodProcess = 'Semana')
    begin
     SET @datePart = 'WEEK';
	 
     if (@periodBefore = 'Dia')
     begin
	  set @dateEnd = DATEADD(day, - @periodsPrevious, @dateCurrent);
     end
     else if (@periodBefore = 'Semana')
     begin
	  set @dateEnd = DATEADD(week, - @periodsPrevious, @dateCurrentEndWeek);
     end
     else if (@periodBefore = 'Mes')
     begin
	  set @dateEnd = DATEADD(month, - @periodsPrevious, @dateCurrentEndMonth);
	  set @dateEnd = [Utility].[GetEndOfMonth] (year(@dateEnd), Month(@dateEnd), 1);
     end
     else if (@periodBefore = 'Bimestre')
     begin
	  set @dateEnd = DATEADD(month, - (@periodsPrevious * 2), @dateCurrentEndMonth2);
	  set @dateEnd = [Utility].[GetEndOfMonth] (year(@dateEnd), Month(@dateEnd), 1);
     end
     else if (@periodBefore = 'Trimestre')
     begin
	  set @dateEnd = DATEADD(quarter, - @periodsPrevious, @dateCurrentEndQuarter);
	  set @dateEnd = [Utility].[GetEndOfMonth] (year(@dateEnd), Month(@dateEnd), 1);
     end
     else if (@periodBefore = 'Semestre')
     begin
	  set @dateEnd = DATEADD(month, - (@periodsPrevious * 6), @dateCurrentEndHalf);
	  set @dateEnd = [Utility].[GetEndOfMonth] (year(@dateEnd), Month(@dateEnd), 1);
     end
     else if (@periodBefore = 'Año')
     begin
	  set @dateEnd = DATEADD(year, - @periodsPrevious, @dateCurrentEndYear);
     end
	 else
     begin
	  set @dateEnd = DATEADD(day, - @periodsPrevious, @dateCurrent);
     end;

	 set @dateStart = DATEADD(day, 1, DATEADD(week, - @periodsQuntity, @dateEnd));
	 set @dateEnd = DATEADD(day, 1, @dateEnd);
    end
    else if (@periodProcess = 'Mes')
    begin
     SET @datePart = 'MONTH';
	 
     if (@periodBefore = 'Dia')
     begin
	  set @dateEnd = DATEADD(day, - @periodsPrevious, @dateCurrent);
     end
     else if (@periodBefore = 'Semana')
     begin
	  set @dateEnd = DATEADD(week, - @periodsPrevious, @dateCurrentEndWeek);
     end
     else if (@periodBefore = 'Mes')
     begin
	  set @dateEnd = DATEADD(month, - @periodsPrevious, @dateCurrentEndMonth);
	  set @dateEnd = [Utility].[GetEndOfMonth] (year(@dateEnd), Month(@dateEnd), 1);
     end
     else if (@periodBefore = 'Bimestre')
     begin
	  set @dateEnd = DATEADD(month, - (@periodsPrevious * 2), @dateCurrentEndMonth2);
	  set @dateEnd = [Utility].[GetEndOfMonth] (year(@dateEnd), Month(@dateEnd), 1);
     end
     else if (@periodBefore = 'Trimestre')
     begin
	  set @dateEnd = DATEADD(quarter, - @periodsPrevious, @dateCurrentEndQuarter);
	  set @dateEnd = [Utility].[GetEndOfMonth] (year(@dateEnd), Month(@dateEnd), 1);
     end
     else if (@periodBefore = 'Semestre')
     begin
	  set @dateEnd = DATEADD(month, - (@periodsPrevious * 6), @dateCurrentEndHalf);
	  set @dateEnd = [Utility].[GetEndOfMonth] (year(@dateEnd), Month(@dateEnd), 1);
     end
     else if (@periodBefore = 'Año')
     begin
	  set @dateEnd = DATEADD(year, - @periodsPrevious, @dateCurrentEndYear);
     end
	 else
     begin
	  set @dateEnd = DATEADD(day, - @periodsPrevious, @dateCurrent);
     end;

	 set @dateStart = DATEADD(month, - @periodsQuntity + 1, @dateEnd);
	 set @dateStart = [Utility].[GetStartOfMonth] (year(@dateStart), month(@dateStart));
	 set @dateEnd = DATEADD(day, 1, @dateEnd);
    end
    else if (@periodProcess = 'Bimestre')
    begin
     SET @datePart = 'MONTH2';

     if (@periodBefore = 'Dia')
     begin
	  set @dateEnd = DATEADD(day, - @periodsPrevious, @dateCurrent);
     end
     else if (@periodBefore = 'Semana')
     begin
	  set @dateEnd = DATEADD(week, - @periodsPrevious, @dateCurrentEndWeek);
     end
     else if (@periodBefore = 'Mes')
     begin
	  set @dateEnd = DATEADD(month, - @periodsPrevious, @dateCurrentEndMonth);
	  set @dateEnd = [Utility].[GetEndOfMonth] (year(@dateEnd), Month(@dateEnd), 1);
     end
     else if (@periodBefore = 'Bimestre')
     begin
	  set @dateEnd = DATEADD(month, - (@periodsPrevious * 2), @dateCurrentEndMonth2);
	  set @dateEnd = [Utility].[GetEndOfMonth] (year(@dateEnd), Month(@dateEnd), 1);
     end
     else if (@periodBefore = 'Trimestre')
     begin
	  set @dateEnd = DATEADD(quarter, - @periodsPrevious, @dateCurrentEndQuarter);
	  set @dateEnd = [Utility].[GetEndOfMonth] (year(@dateEnd), Month(@dateEnd), 1);
     end
     else if (@periodBefore = 'Semestre')
     begin
	  set @dateEnd = DATEADD(month, - (@periodsPrevious * 6), @dateCurrentEndHalf);
	  set @dateEnd = [Utility].[GetEndOfMonth] (year(@dateEnd), Month(@dateEnd), 1);
     end
     else if (@periodBefore = 'Año')
     begin
	  set @dateEnd = DATEADD(year, - @periodsPrevious, @dateCurrentEndYear);
     end
	 else
     begin
	  set @dateEnd = DATEADD(day, - @periodsPrevious, @dateCurrent);
     end;

	 set @dateStart = DATEADD(month, - (@periodsQuntity * 2) + 1, @dateEnd);
	 set @dateStart = [Utility].[GetStartOfMonth] (year(@dateStart), month(@dateStart));
	 set @dateEnd = DATEADD(day, 1, @dateEnd);
    end
    else if (@periodProcess = 'Trimestre')
    begin
     SET @datePart = 'QUARTER';

     if (@periodBefore = 'Dia')
     begin
	  set @dateEnd = DATEADD(day, - @periodsPrevious, @dateCurrent);
     end
     else if (@periodBefore = 'Semana')
     begin
	  set @dateEnd = DATEADD(week, - @periodsPrevious, @dateCurrentEndWeek);
     end
     else if (@periodBefore = 'Mes')
     begin
	  set @dateEnd = DATEADD(month, - @periodsPrevious, @dateCurrentEndMonth);
	  set @dateEnd = [Utility].[GetEndOfMonth] (year(@dateEnd), Month(@dateEnd), 1);
     end
     else if (@periodBefore = 'Bimestre')
     begin
	  set @dateEnd = DATEADD(month, - (@periodsPrevious * 2), @dateCurrentEndMonth2);
	  set @dateEnd = [Utility].[GetEndOfMonth] (year(@dateEnd), Month(@dateEnd), 1);
     end
     else if (@periodBefore = 'Trimestre')
     begin
	  set @dateEnd = DATEADD(quarter, - @periodsPrevious, @dateCurrentEndQuarter);
	  set @dateEnd = [Utility].[GetEndOfMonth] (year(@dateEnd), Month(@dateEnd), 1);
     end
     else if (@periodBefore = 'Semestre')
     begin
	  set @dateEnd = DATEADD(month, - (@periodsPrevious * 6), @dateCurrentEndHalf);
	  set @dateEnd = [Utility].[GetEndOfMonth] (year(@dateEnd), Month(@dateEnd), 1);
     end
     else if (@periodBefore = 'Año')
     begin
	  set @dateEnd = DATEADD(year, - @periodsPrevious, @dateCurrentEndYear);
     end
	 else
     begin
	  set @dateEnd = DATEADD(day, - @periodsPrevious, @dateCurrent);
     end;

	 set @dateStart = DATEADD(quarter, - @periodsQuntity, DATEADD(day, 1, @dateEnd));
	 set @dateStart = [Utility].[GetStartOfMonth] (year(@dateStart), month(@dateStart));
     set @dateEnd = DATEADD(day, 1, @dateEnd);
    end
    else if (@periodProcess = 'Semestre')
    begin
     SET @datePart = 'HALF';

     if (@periodBefore = 'Dia')
     begin
	  set @dateEnd = DATEADD(day, - @periodsPrevious, @dateCurrent);
     end
     else if (@periodBefore = 'Semana')
     begin
	  set @dateEnd = DATEADD(week, - @periodsPrevious, @dateCurrentEndWeek);
     end
     else if (@periodBefore = 'Mes')
     begin
	  set @dateEnd = DATEADD(month, - @periodsPrevious, @dateCurrentEndMonth);
	  set @dateEnd = [Utility].[GetEndOfMonth] (year(@dateEnd), Month(@dateEnd), 1);
     end
     else if (@periodBefore = 'Bimestre')
     begin
	  set @dateEnd = DATEADD(month, - (@periodsPrevious * 2), @dateCurrentEndMonth2);
	  set @dateEnd = [Utility].[GetEndOfMonth] (year(@dateEnd), Month(@dateEnd), 1);
     end
     else if (@periodBefore = 'Trimestre')
     begin
	  set @dateEnd = DATEADD(quarter, - @periodsPrevious, @dateCurrentEndQuarter);
	  set @dateEnd = [Utility].[GetEndOfMonth] (year(@dateEnd), Month(@dateEnd), 1);
     end
     else if (@periodBefore = 'Semestre')
     begin
	  set @dateEnd = DATEADD(month, - (@periodsPrevious * 6), @dateCurrentEndHalf);
	  set @dateEnd = [Utility].[GetEndOfMonth] (year(@dateEnd), Month(@dateEnd), 1);
     end
     else if (@periodBefore = 'Año')
     begin
	  set @dateEnd = DATEADD(year, - @periodsPrevious, @dateCurrentEndYear);
     end
	 else
     begin
	  set @dateEnd = DATEADD(day, - @periodsPrevious, @dateCurrent);
     end;

	 set @dateStart = DATEADD(month, - (@periodsQuntity * 6) + 1, @dateEnd);
	 set @dateStart = [Utility].[GetStartOfMonth] (year(@dateStart), month(@dateStart));
     set @dateEnd = DATEADD(day, 1, @dateEnd);
    end
    else if (@periodProcess = 'Año')
    begin
     SET @datePart = 'YEAR';

     if (@periodBefore = 'Dia')
     begin
	  set @dateEnd = DATEADD(day, - @periodsPrevious, @dateCurrent);
     end
     else if (@periodBefore = 'Semana')
     begin
	  set @dateEnd = DATEADD(week, - @periodsPrevious, @dateCurrentEndWeek);
     end
     else if (@periodBefore = 'Mes')
     begin
	  set @dateEnd = DATEADD(month, - @periodsPrevious, @dateCurrentEndMonth);
	  set @dateEnd = [Utility].[GetEndOfMonth] (year(@dateEnd), Month(@dateEnd), 1);
     end
     else if (@periodBefore = 'Bimestre')
     begin
	  set @dateEnd = DATEADD(month, - (@periodsPrevious * 2), @dateCurrentEndMonth2);
	  set @dateEnd = [Utility].[GetEndOfMonth] (year(@dateEnd), Month(@dateEnd), 1);
     end
     else if (@periodBefore = 'Trimestre')
     begin
	  set @dateEnd = DATEADD(quarter, - @periodsPrevious, @dateCurrentEndQuarter);
	  set @dateEnd = [Utility].[GetEndOfMonth] (year(@dateEnd), Month(@dateEnd), 1);
     end
     else if (@periodBefore = 'Semestre')
     begin
	  set @dateEnd = DATEADD(month, - (@periodsPrevious * 6), @dateCurrentEndHalf);
	  set @dateEnd = [Utility].[GetEndOfMonth] (year(@dateEnd), Month(@dateEnd), 1);
     end
     else if (@periodBefore = 'Año')
     begin
	  set @dateEnd = DATEADD(year, - @periodsPrevious, @dateCurrentEndYear);
     end
	 else
     begin
	  set @dateEnd = DATEADD(day, - @periodsPrevious, @dateCurrent);
     end;

	 set @dateStart = DATEADD(day, 1, DATEADD(year, - @periodsQuntity, @dateEnd));
	 set @dateEnd = DATEADD(day, 1, @dateEnd);
    end;

    set @dtDateNext = @dateStart;
    set @dtTempoDateEnd = @dateEnd;
	WHILE (@dtDateNext < @dtTempoDateEnd)
	begin
	 set @dtDate1 = @dtDateNext;
     SELECT @dtDateNext = DATEADD(day, 1, [Utility].[GetEndOfDatePart](@datePart, @dtDateNext, 1));
	 if (@dtDateNext > @dateEnd)
	 begin 
	  set @dtDate2 = @dateEnd;
     end
	 else
	 begin
	  set @dtDate2 = @dtDateNext;
     end;

     IF NOT EXISTS(SELECT * FROM @tmpModuleProgramming WHERE [ModuleId] = @ModuleId AND [ModelProgId] = @ModelId AND [DateStart] = @dtDate1)
	 begin
      INSERT INTO @tmpModuleProgramming ([Priority], [ModelId], [SequenceId],[ModuleId],[ModelProgId],[DateVersion],[DateStart],[DateEnd],[Version],[VersionId])
      VALUES (@priority, @ModelId, @SequenceId, @ModuleId, @ModelId, @dtDate1, @dtDate1, @dtDate2, 0, @versionId);
	 end;
    end;

   end;
  end;

  FETCH NEXT FROM Cur_Loop INTO @priority, @SequenceId, @ModuleId, @ModelId, @useVersion, @periodProcess, @periodsQuntity, @periodBefore, @periodsPrevious, @scheduleId, @VersionId;
 END
 CLOSE Cur_Loop;
 DEALLOCATE Cur_Loop;

  WITH [CTE_P] AS
  (
   SELECT [Priority], [ModelId], [SequenceId], [ModuleId], [ModelProgId], [DateVersion], [DateStart], [DateEnd], [Version], [VersionId] 
  , ROW_NUMBER() OVER (PARTITION BY [ModuleId], [ModelProgId], [DateStart]
	   ORDER BY [ModuleId], [ModelProgId], [DateStart], [Priority], [ModelId], [SequenceId]) [Fila]
   FROM @tmpModuleProgramming
  )
  MERGE [Utility].[ModuleProgramming] AS Target
  USING (SELECT TOP 100 PERCENT [Priority], [ModelId], [SequenceId], [ModuleId], [ModelProgId], [DateVersion], [DateStart], [DateEnd], [Version], [VersionId]
         FROM [CTE_P]
		 WHERE [Fila] = 1
		 ORDER BY [Priority], [ModelId], [SequenceId], [ModuleId], [DateVersion]) AS Source
 ON (Target.[ModuleId] = Source.[ModuleId] AND Target.[ModelProgId] = Source.[ModelProgId] AND Target.[DateStart] = Source.[DateStart])
 -- Cuando cazan, actualzar si hay algun cambio
 WHEN MATCHED AND 
  (   Target.[Priority] <> Source.[Priority] 
   OR Target.[ModelId] <> Source.[ModelId] 
   OR Target.[SequenceId] <> Source.[SequenceId] 
   OR Target.[DateStart] <> Source.[DateStart] 
   OR Target.[DateEnd] <> Source.[DateEnd] 
   OR Target.[Version] <> Source.[Version] 
   OR Target.[VersionId] <> Source.[VersionId]  ) THEN
  UPDATE SET 
    Target.[Priority] = Source.[Priority]
   ,Target.[ModelId] = Source.[ModelId]
   ,Target.[SequenceId] = Source.[SequenceId]
   ,Target.[DateStart] = Source.[DateStart]
   ,Target.[DateEnd] = Source.[DateEnd]
   ,Target.[Version] = Source.[Version]
   ,Target.[VersionId] = Source.[VersionId]
   ,Target.[StateId] = 20 /* Programado para ejecutar */
   ,Target.[DateUpdate] = GetDate()
   ,Target.[BitacoraId] = @bitacoraId
 -- Cuando no cazan, insertar
 WHEN NOT MATCHED BY TARGET THEN
  INSERT ([Priority],[ModelId],[SequenceId],[ModuleId],[ModelProgId],[DateVersion],[DateStart],[DateEnd],[Version],[VersionId],[StateId],[DateUpdate],[BitacoraId])
  VALUES (Source.[Priority],Source.[ModelId],Source.[SequenceId],Source.[ModuleId], Source.[ModelProgId], Source.[DateVersion], Source.[DateStart]
  , Source.[DateEnd], Source.[Version], Source.[VersionId], 20, GetDate(), @bitacoraId);
 -- Cuando existe una fila en el destino, pero no en el origen: No borrar (DELETE;)

 set nocount off;
End
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[spModuleProgramming_UpdateState]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_EXECUTEsql @statement = N'CREATE PROCEDURE [Utility].[spModuleProgramming_UpdateState] AS' 
END
GO
ALTER PROCEDURE [Utility].[spModuleProgramming_UpdateState] 
  @bitacoraId bigint
 ,@StateId tinyint
 ,@dateStart nvarchar(10)
 ,@ModelProgId nvarchar(12)
 ,@ModuleId int = NULL
 ,@moduleAppName nvarchar(128) = NULL
 ,@TypeId nvarchar(12) = NULL
As
/* ============================================================================================
Proposito: Actualiza estado de la programación de ejecución, en la tabla: [Utility].[ModuleProgramming].
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2017-04-10
Fecha actualizacion: 2020-07-15

Parametros:  
 @bitacoraId: Codigo de bitacora.
 @StateId: Codigo de estado de proceso a ser establecido. FK a [Audit].[BitacoraState].
 @dateStart: Fecha inicio de carga de datos, en formato: YYYY-MM-DD.
 @ModelProgId: Codigo del modelo a ser programado en el modulo.
 @ModuleId: Codigo de modulo. Si es nulo o menor o igual a cero (0) utiliza los parámetros de nombre y tipo de modulo.
 @moduleAppName: Nombre de modulo en el Codigo de aplicación. Por ejemplo el nombre de una ETL.
  Si suministra el Codigo de modulo, no utiliza este parámetro.
 @TypeId: Codigo de tipo de modulo. Por ejemplo: ETL, menu de programa.

Ejemplo:
EXECUTE [Utility].[spModuleProgramming_UpdateState] 0, 0, '2015-01-01', 'Per_DBalEne', NULL, 'pkgFactEvento', 'ETL';
EXECUTE [Utility].[spModuleProgramming_UpdateState] 0, 1, '2015-01-01', 'Per_DBalEne', 12;

SELECT * FROM [Utility].[ModuleProgramming] ORDER BY [ModuleId],[DateStart];
============================================================================================ */
begin
 set nocount on
 Declare @dtTempo date;
 set @dtTempo = Convert(date, @dateStart, 120);

 if (@ModuleId IS NOT NULL AND @ModuleId > 0)
 begin
  UPDATE MP SET 
    [StateId] = @StateId
   ,[DateUpdate] = GetDate()
   ,[BitacoraId] = @bitacoraId
  FROM [Utility].[ModuleProgramming] MP
  INNER JOIN [Utility].[ModelSystem] MO WITH (NOLOCK) ON MO.[ModelId] = MP.[ModelProgId]
  WHERE MP.[ModuleId] = @ModuleId AND MP.[ModelProgId] = @ModelProgId  
  AND (MO.[UseDatesProcess] = 0 OR (MO.[UseDatesProcess] = 1 AND MP.[DateStart] = @dtTempo)); 
 end;
 else
 begin
  UPDATE MP SET 
     [StateId] = @StateId
    ,[DateUpdate] = GetDate()
    ,[BitacoraId] = @bitacoraId
  FROM [Utility].[ModuleProgramming] MP
  INNER JOIN [Utility].[ModuleSystem] M ON M.[ModuleId] = MP.[ModuleId]
  INNER JOIN [Utility].[ModelSystem] MO WITH (NOLOCK) ON MO.[ModelId] = MP.[ModelProgId]
  WHERE M.[AppName] = @moduleAppName AND M.[TypeId] = @TypeId AND MP.[ModelProgId] = @ModelProgId 
  AND (MO.[UseDatesProcess] = 0 OR (MO.[UseDatesProcess] = 1 AND MP.[DateStart] = @dtTempo)); 
 end;

 set nocount off;
End
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[spModuleProgramming_UpdateState_WithoutDate]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_EXECUTEsql @statement = N'CREATE PROCEDURE [Utility].[spModuleProgramming_UpdateState_WithoutDate] AS' 
END
GO
ALTER PROCEDURE [Utility].[spModuleProgramming_UpdateState_WithoutDate] 
  @bitacoraId bigint
 ,@StateId tinyint
 ,@allModel bit 
 ,@ModelProgId nvarchar(12)
 ,@ModuleId int = NULL
 ,@moduleAppName nvarchar(128) = NULL
 ,@TypeId nvarchar(12) = NULL
As
/* ============================================================================================
Proposito: Actualiza estado de la programación de ejecucion de modelos que no utilizan feccha de proceso, en la tabla: [Utility].[ModuleProgramming].
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2017-04-10
Fecha actualizacion: 2020-07-15

Parametros:  
 @bitacoraId: Codigo de bitacora.
 @StateId: Codigo de estado de proceso a ser establecido. FK a [Audit].[BitacoraState].
 @allModel: 0: Solo el modulo indicado. 1: Todos los modulos para los cuales [ModelId] = [ModelProgId]
 @ModelProgId: Codigo del modelo a ser programado en el modulo.
 @ModuleId: Codigo de modulo. Si es nulo o menor o igual a cero (0) utiliza los parámetros de nombre y tipo de modulo.
 @moduleAppName: Nombre de modulo en el Codigo de aplicación. Por ejemplo el nombre de una ETL.
  Si suministra el Codigo de modulo, no utiliza este parámetro.
 @TypeId: Codigo de tipo de modulo. Por ejemplo: ETL, menu de programa.

Ejemplo:
EXECUTE [Utility].[spModuleProgramming_UpdateState_WithoutDate] 0, 0, 0, 'DW_DDim', NULL, 'pkgDimCausa', 'ETL';
EXECUTE [Utility].[spModuleProgramming_UpdateState_WithoutDate] 0, 1, 0, 'DW_DDim', 16;
EXECUTE [Utility].[spModuleProgramming_UpdateState_WithoutDate] 0, 0, 1, 'DW_DDim', 0;

SELECT * FROM [Utility].[ModuleProgramming] ORDER BY [ModuleId],[DateStart];
============================================================================================ */
begin
 set nocount on

 if (@allModel = 1)
 begin
   UPDATE MP SET 
      [StateId] = @StateId
     ,[DateUpdate] = GetDate()
     ,[BitacoraId] = @bitacoraId
   FROM [Utility].[ModuleProgramming] MP
   INNER JOIN [Utility].[ModuleSystem] M ON M.[ModuleId] = MP.[ModuleId]
   INNER JOIN [Utility].[ModelSystem] MO WITH (NOLOCK) ON MO.[ModelId] = MP.[ModelProgId]
   WHERE MP.[ModelProgId] = @ModelProgId AND MP.[ModelId] = MP.[ModelProgId] AND MO.[UseDatesProcess] = 0 AND [StateId] <> 1;  
 end
 else
 begin
  if (@ModuleId IS NOT NULL AND @ModuleId > 0)
  begin
   UPDATE MP SET 
     [StateId] = @StateId
    ,[DateUpdate] = GetDate()
    ,[BitacoraId] = @bitacoraId
   FROM [Utility].[ModuleProgramming] MP
   INNER JOIN [Utility].[ModelSystem] MO WITH (NOLOCK) ON MO.[ModelId] = MP.[ModelProgId]
   WHERE MP.[ModuleId] = @ModuleId AND MP.[ModelProgId] = @ModelProgId AND MO.[UseDatesProcess] = 0; 
  end
  else
  begin
   UPDATE MP SET 
      [StateId] = @StateId
     ,[DateUpdate] = GetDate()
     ,[BitacoraId] = @bitacoraId
   FROM [Utility].[ModuleProgramming] MP
   INNER JOIN [Utility].[ModuleSystem] M ON M.[ModuleId] = MP.[ModuleId]
   INNER JOIN [Utility].[ModelSystem] MO WITH (NOLOCK) ON MO.[ModelId] = MP.[ModelProgId]
   WHERE M.[AppName] = @moduleAppName AND M.[TypeId] = @TypeId AND MP.[ModelProgId] = @ModelProgId AND MO.[UseDatesProcess] = 0; 
  end;
 end;
 
 set nocount off;
End
GO


IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[GetParametersModuleProgramming]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
 EXEC('CREATE FUNCTION [Utility].[GetParametersModuleProgramming] (@queryStringParameters nvarchar(max))
RETURNS @TableResult TABLE 
(
   [DateVersion] date
  ,[DateStart] date 
  ,[DateEnd] date 
  ,[Version] int
  ,[VersionId] nvarchar(10)
  ,[DateWork] nvarchar(10)
)
WITH EXECUTE AS OWNER
AS  
BEGIN
 RETURN
END');
GO
ALTER FUNCTION [Utility].[GetParametersModuleProgramming] (@queryStringParameters nvarchar(max))
RETURNS @TableResult TABLE 
(
   [DateVersion] date
  ,[DateStart] date 
  ,[DateEnd] date 
  ,[Version] int
  ,[VersionId] nvarchar(10)
  ,[DateWork] nvarchar(10)
)
WITH EXECUTE AS OWNER
AS
/* ============================================================================================
Proposito: Retorna parametros de programación de recarga de datos.
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2016-07-26
Fecha actualizacion: 2020-07-15

PARAMETROS:
 @queryStringParameters: Query string con parametros. En formato @p1=value1&@p2=value&@p3=value3
  Formato: @dateVersion=2017-01-01&@dateStart=2017-01-01&@dateEnd=2017-02-01&@version=0&@versionId=0
  Cuando las fechas son tipos de datos texto, por lo general estan en formato: YYYY-MM-DD. 
  Pero si las fechas el tipo de datos es fecha, es preferible enviar los datos en formato: YYYYMMDD.

RETORNO:
 [DateVersion]: Fecha de versión de los datos.
 [DateStart]: Fecha inicio de carga de datos. 
 [DateEnd]: Fecha fin de carga de datos. 
 [Version]: Codigo de versión a ser procesada (para versiones numéricas).
 [VersionId]: Codigo de versión a ser procesada (para versiones texto).
 [DateWork]: Fecha de trabajo como texto, igual DateVersion, si este valor es nulo utiliza DateStart.

EJEMLPO:
 SELECT * FROM [Utility].[GetParametersModuleProgramming]('@dateVersion=2017-01-01&@dateStart=2017-01-01&@dateEnd=2017-02-01&@version=0&versionId=0');
============================================================================================ */
BEGIN
 Declare @DateVersion date, @DateStart date, @DateEnd date, @version int, @versionId nvarchar(10), @dtTempo date, @maxLen bigint;
 Declare @DateWork nvarchar(10);

 Declare @tableQueryStringPar TABLE 
 (
   [KeyName] [nvarchar](128) COLLATE DATABASE_DEFAULT,
   [KeyValue] [nvarchar](4000) COLLATE DATABASE_DEFAULT,
   PRIMARY KEY ([KeyName])
 );
 
 if (@queryStringParameters IS NOT NULL AND LEN(@queryStringParameters) > 0)
 begin
  set @maxLen = LEN(@queryStringParameters);
   WITH [CTE_ParSplitter] AS 
   (
    SELECT CHARINDEX('&', @queryStringParameters) as pos, convert(bigint, 0) as lastPos
    UNION ALL
    SELECT CHARINDEX('&', @queryStringParameters, pos + 1), pos
    FROM [CTE_ParSplitter]
    WHERE pos > 0
   ),
   [CTE_PairKeyValue] AS 
   (
    SELECT chunk, CHARINDEX('=', chunk) as pos
    FROM (
     SELECT SUBSTRING(@queryStringParameters, lastPos + 1, case when pos = 0 then @maxLen else pos - lastPos -1 end) as chunk
     FROM [CTE_ParSplitter]) as T1
   )
   INSERT INTO @tableQueryStringPar ([KeyName], [KeyValue])
   SELECT convert(nvarchar(128), Replace(substring(chunk, 0, pos), '@', '')), convert(nvarchar(4000), substring(chunk, pos + 1, @maxLen))
   FROM [CTE_PairKeyValue];
   
   SELECT @DateVersion = Convert(date, [KeyValue], 120)
   FROM @tableQueryStringPar 
   WHERE [KeyName] = 'DateVersion';
  
   SELECT @DateStart = Convert(date, [KeyValue], 120)
   FROM @tableQueryStringPar 
   WHERE [KeyName] = 'DateStart';
  
   SELECT @DateEnd = Convert(date, [KeyValue], 120)
   FROM @tableQueryStringPar 
   WHERE [KeyName] = 'DateEnd';

   SELECT @version = Convert(int, [KeyValue])
   FROM @tableQueryStringPar 
   WHERE [KeyName] = 'Version';
  
   SELECT @versionId =  [KeyValue]
   FROM @tableQueryStringPar 
   WHERE [KeyName] = 'VersionId';
 end;

  -- Validacion fechas
  if (@DateStart IS NULL)
  begin
   GOTO Salir;
  end;
  if (@DateEnd IS NULL)
  begin
   set @DateEnd = DATEADD(day, 1, @DateStart);
  end;

  if (@DateEnd < @DateStart)
  begin
   set @dtTempo = @DateStart;
   set @DateStart = @DateEnd;
   set @DateEnd = @dtTempo;
  end
  else if (@DateEnd = @DateStart)
  begin
   set @DateEnd = DATEADD(day, 1, @DateEnd);
  end;

  if (@DateVersion IS NULL)
  begin
   set @DateWork =  Convert(nvarchar(10), @DateStart, 120);
  end
  else
  begin
   set @DateWork =  Convert(nvarchar(10), @DateVersion, 120);
  end;

Salir:  
 INSERT INTO @TableResult ([DateVersion], [DateStart], [DateEnd], [Version], [VersionId], [DateWork]) 
 Values (@DateVersion, @DateStart, @DateEnd, @version, @versionId, @DateWork);

 RETURN;
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[spGetQuerySQL]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_EXECUTEsql @statement = N'CREATE PROCEDURE [Utility].[spGetQuerySQL] AS' 
END
GO
ALTER PROCEDURE [Utility].[spGetQuerySQL] 
  @queryId nvarchar(12)
 ,@queryStringParameters nvarchar(max)
 ,@querySQL nvarchar(max) OUTPUT
 ,@parameterByPosition bit = 0 
As
/* ============================================================================================
Proposito: Retorna consulta de seleccion de datos almacenada en la tabla: [Utility].[QuerySQL], remplazando los parametros.
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2017-06-01
Fecha actualizacion: 2017-06-01

PARAMETROS:
 @queryId: Codigo de consulta de seleccion de datos
 @queryStringParameters: Query string con parametros. En formato @p1=value1&@p2=value&@p3=value3
  Formato: @dateStart=2017-01-01&@dateEnd=2017-02-01&@version=0
  Cuando las fechas son tipos de datos texto, por lo general estan en formato: YYYY-MM-DD. 
  Pero si las fechas el tipo de datos es fecha, es preferible enviar los datos en formato: YYYYMMDD.
 @querySQL: Consulta de seleccion de datos retornada.
 @parameterByPosition: Establece que los parametros son enviados por nombre o posicion
  0: Valor por defecto, indica que las claves son buscacadas por nombre
  1: Indica que las claves son enviadas por posicion

EJEMLPO:
 Declare @querySQL nvarchar(max);
 EXECUTE [Utility].[spGetQuerySQL] 'DW_TTension2', '@version=0&@dateEnd=2017-02-01&@dateStart=2017-01-01', @querySQL OUTPUT, 0;
 PRINT @querySQL

 EXECUTE [Utility].[spGetQuerySQL] 'DW_TTension2', '@version=0&@dateEnd=2017-02-01&@dateStart=2017-01-01', @querySQL OUTPUT, 1;
 PRINT @querySQL

 EXECUTE [Utility].[spGetQuerySQL] 'DW_TTension2', '@version=0&@dV=2018-01-01&@dtEnd=2017-02-01&@dS=2017-01-01', @querySQL OUTPUT, 0;
 PRINT @querySQL
 
 EXECUTE [Utility].[spGetQuerySQL] 'DW_TTension1', '@dateVersion=2017-01-01&@dateStart=2017-05-01&@dateEnd=2017-10-01&@version=0&@versionId=0', @querySQL OUTPUT, 0;
 Print @querySQL;

 EXECUTE [Utility].[spGetQuerySQL] 'DW_TTension1', '@dateStart=2017-01-01&@dateEnd=2017-02-01&@version=0', @querySQL OUTPUT;
 PRINT @querySQL

 EXECUTE [Utility].[spGetQuerySQL] 'DW_TTension1', NULL, @querySQL OUTPUT;
 PRINT @querySQL

 EXECUTE [Utility].[spGetQuerySQL] 'DW_TTension1', '@p1=2017-01-01&@p2=2017-02-01&@p3=0', @querySQL OUTPUT, 1;
 PRINT @querySQL

 EXECUTE [Utility].[spGetQuerySQL] 'DW_TZona', '@dateStart=null&@dateEnd=2017-02-01&@version=', @querySQL OUTPUT;
 PRINT @querySQL

 EXECUTE [Utility].[spGetQuerySQL] 'DW_TZona', NULL, @querySQL OUTPUT;
 PRINT @querySQL

 SELECT * FROM [Utility].[QuerySQL] WHERE [QueryId] IN ('DW_TTension1', 'DW_TTension2', 'DW_TZona');
============================================================================================ */
BEGIN
 set nocount on;
 Declare @parameters nvarchar(4000), @keyName nvarchar(128), @keyValue nvarchar(4000), @dataTypeId tinyint, @maxLen bigint; 

 Declare @tableQueryStringPar TABLE 
 (
   [Id] [int] IDENTITY(1, 1)
   ,[KeyName] [nvarchar](128) COLLATE DATABASE_DEFAULT
   ,[KeyValue] [nvarchar](4000) COLLATE DATABASE_DEFAULT
   ,PRIMARY KEY ([Id])
 );

 Declare @tableQueryPar TABLE 
 (
   [Id] [int] IDENTITY(1, 1)
   ,[KeyName] [nvarchar](128) COLLATE DATABASE_DEFAULT
   ,[DataType] [nvarchar](128) COLLATE DATABASE_DEFAULT
   ,PRIMARY KEY ([Id])
 );
 
 SET @querySQL = NULL;
 SELECT @querySQL = [QuerySQL], @parameters = [Parameters] FROM [Utility].[QuerySQL] WITH(NOLOCK) WHERE [QueryId] = @queryId;
 
 if (@queryStringParameters IS NOT NULL AND LEN(@queryStringParameters) > 0 AND @querySQL IS NOT NULL)
 begin
  set @maxLen = LEN(@queryStringParameters);
  WITH [CTE_ParSplitter] AS 
  (
    SELECT CHARINDEX('&', @queryStringParameters) as pos, convert(bigint, 0) as lastPos
    UNION ALL
    SELECT CHARINDEX('&', @queryStringParameters, pos + 1), pos
    FROM [CTE_ParSplitter]
    WHERE pos > 0
  ),
  [CTE_PairKeyValue] AS 
  (
    SELECT chunk, CHARINDEX('=', chunk) as pos
    FROM (
     SELECT SUBSTRING(@queryStringParameters, lastPos + 1, case when pos = 0 then @maxLen else pos - lastPos -1 end) as chunk
     FROM [CTE_ParSplitter]) as T1
  )
  INSERT INTO @tableQueryStringPar ([KeyName], [KeyValue])
  SELECT convert(nvarchar(128), Replace(substring(chunk, 0, pos), '@', '')), convert(nvarchar(4000), substring(chunk, pos + 1, @maxLen))
  FROM [CTE_PairKeyValue];
 end;
   
 if (@parameters IS NOT NULL AND LEN(@parameters) > 0 AND @querySQL IS NOT NULL)
 begin
  set @maxLen = LEN(@parameters);
  WITH [CTE_ParSplitter] AS 
  (
    SELECT CHARINDEX('&', @parameters) as pos, convert(int, 0) as lastPos
    UNION ALL
    SELECT CHARINDEX('&', @parameters, pos + 1), pos
    FROM [CTE_ParSplitter]
    WHERE pos > 0
  ),
  [CTE_PairKeyValue] AS 
  (
    SELECT chunk, CHARINDEX('=', chunk) as pos
    FROM (
     SELECT SUBSTRING(@parameters, lastPos + 1, case when pos = 0 then @maxLen else pos - lastPos -1 end) as chunk
     FROM [CTE_ParSplitter]) as T1
  )
  INSERT INTO @tableQueryPar ([KeyName], [DataType])
  SELECT convert(nvarchar(128), Replace(substring(chunk, 0, pos), '@', '')), convert(nvarchar(128), substring(chunk, pos + 1, @maxLen))
  FROM [CTE_PairKeyValue];

  if (@parameterByPosition = 0)
  begin
   DECLARE Cur_Loop CURSOR FORWARD_ONLY READ_ONLY FOR
   SELECT '@' + P.[KeyName], Q.[KeyValue] 
   , CASE WHEN P.[DataType] IN ('bigint','numeric','bit','smallint','decimal','smallmoney','int','tinyint','money','float','real','table') THEN 1
         WHEN P.[DataType] IN ('date','datetimeoffset','datetime2','smalldatetime','datetime','time','timestamp') THEN 2
     ELSE 3 END As [DataType]
   FROM @tableQueryPar P LEFT JOIN @tableQueryStringPar Q ON P.[KeyName] = Q.[KeyName]
   ORDER BY P.[Id];
  end
  else
  begin
   DECLARE Cur_Loop CURSOR FORWARD_ONLY READ_ONLY FOR
   SELECT '@' + P.[KeyName], Q.[KeyValue] 
   , CASE WHEN P.[DataType] IN ('bigint','numeric','bit','smallint','decimal','smallmoney','int','tinyint','money','float','real','table') THEN 1
         WHEN P.[DataType] IN ('date','datetimeoffset','datetime2','smalldatetime','datetime','time','timestamp') THEN 2
     ELSE 3 END As [DataType]
   FROM @tableQueryPar P LEFT JOIN @tableQueryStringPar Q ON P.[Id] = Q.[Id]
   ORDER BY P.[Id];
  end;

  OPEN Cur_Loop;
  FETCH NEXT FROM Cur_Loop INTO @keyName, @keyValue, @dataTypeId;
  WHILE @@FETCH_STATUS = 0
  BEGIN   
   if (@dataTypeId = 1) 
   begin
    if (@keyValue IS NULL OR LTRIM(RTRIM(@keyValue)) = '')
	begin
     set @keyValue = 'NULL';
    end;
   end
   else if (@dataTypeId = 2)
   begin
    if (@keyValue IS NULL OR LTRIM(RTRIM(@keyValue)) = '' OR @keyValue = 'NULL')
	begin
     set @keyValue = 'NULL';
    end;
   end 
   else
   begin
    if (@keyValue IS NULL OR @keyValue = 'NULL')
	begin
     set @keyValue = 'NULL';
    end
    else
	begin
	 set @keyValue = '''' + @keyValue + '''';
	end;
   end;

   SET @querySQL = REPLACE(@querySQL, @keyName, @keyValue);

   FETCH NEXT FROM Cur_Loop INTO @keyName, @keyValue, @dataTypeId;
  END
  CLOSE Cur_Loop;
  DEALLOCATE Cur_Loop;
 end;    
END;
GO

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - End script: A12SP_Util_Prog.sql'
PRINT '------------------------------------------------------------------------'
GO