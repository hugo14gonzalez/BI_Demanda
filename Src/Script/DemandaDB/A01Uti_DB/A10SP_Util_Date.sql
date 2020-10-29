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
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - Start script: A10SP_Util_Date.sql'
PRINT '------------------------------------------------------------------------'
GO

USE [$(DATABASE_NAME_DW)];

/*====================================================================================
 Funciones Fecha
==================================================================================== */
IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[GetDateDiffValue]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
 EXEC('CREATE FUNCTION [Utility].[GetDateDiffValue] (@datePart nvarchar(12), @dateStart datetime, @dateEnd datetime)
RETURNS numeric(18, 6)
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN
 RETURN(0);
END');
GO
ALTER FUNCTION [Utility].[GetDateDiffValue] (@datePart nvarchar(12), @dateStart datetime, @dateEnd datetime)
RETURNS numeric(18, 6)
WITH RETURNS NULL ON NULL INPUT
AS
/* ============================================================================================
Proposito: Retorna la duración entre dos fechas.
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2018-01-09
Fecha actualizacion: 2020-07-15

Parametros:
 @datePart: Parte de fecha
  Año: year, yy, yyyy
  Semestre: half
  Trimestre: quarter, qq, q 
  Bimestre: month2, mm2, m2
  Mes: month, mm, m 
  Semana: week, wk, ww 
  Día: day, dd, d 
  Hora: hour, hh
  Minuto: minute, mi, n
  Segundo: second, ss, s
 @dateStart: Fecha inicial
 @dateEnd: Fecha final

Retorna: Valor con la diferencia de tiempo entre dos fechas.
 
Ejemplo:
select DATEDIFF_BIG(minute, '2018-01-01 00:00:00', '2018-03-11 10:15:20')
select DATEDIFF_BIG(hour, '2018-01-01 00:00:00', '2018-03-11 10:15:20')
select DATEDIFF_BIG(d, '2018-01-01 00:00:00', '2018-03-11 10:15:20')
select DATEDIFF_BIG(ww, '2018-01-01 00:00:00', '2018-03-11 10:15:20')
select DATEDIFF_BIG(month, '2018-01-01 00:00:00', '2018-03-11 10:15:20')

SELECT [Utility].[GetDateDiffValue]('day', '2018-01-01 00:00:00', Convert(datetime, null)); -- NULL
SELECT [Utility].[GetDateDiffValue]('year', '2018-01-01 00:00:00', Convert(datetime, 0)); -- -117.998631

SELECT [Utility].[GetDateDiffValue]('second', '2018-01-01 00:00:00', '2018-03-11 10:15:20'); -- 5998520.0
select ((69 * 24) + 10)  * 3600 + (15 * 60) + 20 

SELECT [Utility].[GetDateDiffValue]('minute', '2018-01-01 00:00:00', '2018-03-11 10:15:20'); -- 99975.333333
select ((69 * 24) + 10)  * 60 + (15) + 20 / 60.0

SELECT [Utility].[GetDateDiffValue]('hour', '2018-01-01 00:00:00', '2018-03-11 10:15:20'); -- 1666.255555
select ((69 * 24) + 10) + (15 / 60.0) + 20 / 3600.0

SELECT [Utility].[GetDateDiffValue]('day', '2018-01-01 00:00:00', '2018-03-11 10:15:20'); -- 69.427315
select 69 + (10 / 24.0) + (15 / 1440.0) + 20 / 86400.0
select 5998520.0 / 86400.0

SELECT [Utility].[GetDateDiffValue]('week', '2018-01-01 00:00:00', '2018-03-11 10:15:20'); -- 9.918188
select 69.427315 / 7.0

SELECT [Utility].[GetDateDiffValue]('month', '2018-01-01 00:00:00', '2018-03-11 10:15:00'); -- 2.322581

SELECT [Utility].[GetDateDiffValue]('month2', '2018-01-01 00:00:00', '2019-03-11 10:15:00');
SELECT [Utility].[GetDateDiffValue]('quarter', '2018-01-01 00:00:00', '2019-03-11 10:15:00');
SELECT [Utility].[GetDateDiffValue]('half', '2018-01-01 00:00:00', '2019-03-11 10:15:00');
SELECT [Utility].[GetDateDiffValue]('year', '2018-01-01 00:00:00', '2019-03-11 10:15:00');
============================================================================================ */
BEGIN
 Declare @value numeric(18, 6);

 if (@datePart NOT IN ('YEAR', 'YY', 'YYYY', 'HALF', 'QUARTER', 'QQ', 'Q', 'MONTH2', 'MM2', 'M2', 
     'MONTH', 'MM', 'M', 'WEEK', 'WK', 'WW', 'DAY', 'DD', 'D', 'HOUR', 'HH', 'MINUTE', 'MI', 'N', 'SECOND', 'SS', 'S'))
 begin
  return null; 
 end;
 
 if (@datePart IN ('SECOND', 'SS', 'S')) 
 begin
  set @value = DATEDIFF_BIG(SS, @dateStart, @dateEnd);
 end
 else if (@datePart IN ('MINUTE', 'MI', 'N'))
 begin
  set @value = DATEDIFF_BIG(SS, @dateStart, @dateEnd) / 60.0;
 end
 else if (@datePart IN ('HOUR', 'HH'))
 begin
  set @value = DATEDIFF_BIG(SS, @dateStart, @dateEnd) / 3600.0;
 end
 else if (@datePart in ('DAY', 'DD', 'D'))
 begin
  set @value = DATEDIFF_BIG(SS, @dateStart, @dateEnd) / 86400.0;
 end;
 else if (@datePart in ('WEEK', 'WK', 'WW'))
 begin
  set @value = DATEDIFF_BIG(SS, @dateStart, @dateEnd) /  604800.0;
 end
 else if (@datePart in ('MONTH', 'MM', 'M'))
 begin
  set @value = datediff(month, @dateStart, @dateEnd) - 1 +
               1 - 1.0 * (day(@dateStart) - 1)/ day(dateadd(m, datediff(m, -1, @dateStart), -1)) 
			   + 1.0 * (day(@dateEnd) - 1) / day(dateadd(m, datediff(m, -1, @dateEnd), - 1));
 end
 else if @datePart in ('MONTH2', 'MM2', 'M2') -- bimestre
 begin
  set @value = ( datediff(month, @dateStart, @dateEnd) - 1 +
               1 - 1.0 * (day(@dateStart) - 1)/ day(dateadd(m, datediff(m, -1, @dateStart), -1)) 
			   + 1.0 * (day(@dateEnd) - 1) / day(dateadd(m, datediff(m, -1, @dateEnd), - 1)) ) / 2.0;
 end
 else if @datePart in ('QUARTER', 'QQ', 'Q') -- Trimestre
 begin
  set @value = ( datediff(month, @dateStart, @dateEnd) - 1 +
               1 - 1.0 * (day(@dateStart) - 1)/ day(dateadd(m, datediff(m, -1, @dateStart), -1)) 
			   + 1.0 * (day(@dateEnd) - 1) / day(dateadd(m, datediff(m, -1, @dateEnd), - 1)) ) / 3.0;
 end
 else if @datePart in ('HALF') -- semestre
 begin
  set @value = DATEDIFF_BIG(day, @dateStart, @dateEnd) / 182.625;
 end
 else if @datePart in ('YEAR', 'YY', 'YYYY') 
 begin
  set @value = DATEDIFF_BIG(day, @dateStart, @dateEnd) / 365.25;
 end
 else
 begin
  set @value = DATEDIFF_BIG(SS, @dateStart, @dateEnd);
 end
   
 RETURN (@value);
END
GO

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[GetDateDiffValue2]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
 EXEC('CREATE FUNCTION [Utility].[GetDateDiffValue2] (@datePart nvarchar(12), @dateStart date, @timeStart time(7), @dateEnd date, @timeEnd time(7))
RETURNS numeric(18, 6)
AS
BEGIN
 RETURN(0);
END');
GO
ALTER FUNCTION [Utility].[GetDateDiffValue2] (@datePart nvarchar(12), @dateStart date, @timeStart time(7), @dateEnd date, @timeEnd time(7))
RETURNS numeric(18, 6)
AS
/* ============================================================================================
Proposito: Retorna la duración entre dos fechas.
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2018-01-09
Fecha actualizacion: 2020-07-15

Parametros:
 @datePart: Parte de fecha
  Año: year, yy, yyyy
  Semestre: half
  Trimestre: quarter, qq, q 
  Bimestre: month2, mm2, m2
  Mes: month, mm, m 
  Semana: week, wk, ww 
  Día: day, dd, d 
  Hora: hour, hh
  Minuto: minute, mi, n
  Segundo: second, ss, s
 @dateStart: Fecha inicial
 @timeStart: Tiempo inicial
 @dateEnd: Fecha final
 @timeEnd: Tiempo final

Retorna: Valor con la diferencia de tiempo entre dos fechas.
 
Ejemplo:
select DATEDIFF_BIG(minute, '2018-01-01 00:00:00', '2018-03-11 10:15:20')
select DATEDIFF_BIG(hour, '2018-01-01 00:00:00', '2018-03-11 10:15:20')
select DATEDIFF_BIG(d, '2018-01-01 00:00:00', '2018-03-11 10:15:20')
select DATEDIFF_BIG(ww, '2018-01-01 00:00:00', '2018-03-11 10:15:20')
select DATEDIFF_BIG(month, '2018-01-01 00:00:00', '2018-03-11 10:15:20')

SELECT [Utility].[GetDateDiffValue2]('day', '2018-01-01', '00:00:00', Convert(datetime, null), NULL); -- NULL
SELECT [Utility].[GetDateDiffValue2]('year', '2018-01-01', '00:00:00', Convert(datetime, 0), NULL); -- -117.998631
SELECT [Utility].[GetDateDiffValue2]('second', Convert(datetime, null), '00:00:00', Convert(datetime, null), NULL); -- NULL
SELECT [Utility].[GetDateDiffValue2]('second', Convert(datetime, null), '00:00:00', Convert(datetime, null), '10:15:20'); -- 36920.0
select (10) * 3600 + (15 * 60) + 20 

SELECT [Utility].[GetDateDiffValue2]('second', '2018-01-01', '00:00:00', '2018-03-11', '10:15:20'); -- 5998520.0
select ((69 * 24) + 10) * 3600 + (15 * 60) + 20 

SELECT [Utility].[GetDateDiffValue2]('minute', '2018-01-01', '00:00:00', '2018-03-11', '10:15:20'); -- 99975.333333
select ((69 * 24) + 10) * 60 + (15) + 20 / 60.0

SELECT [Utility].[GetDateDiffValue2]('hour', '2018-01-01', '00:00:00', '2018-03-11', '10:15:20'); -- 1666.255555
select ((69 * 24) + 10) + (15 / 60.0) + 20 / 3600.0

SELECT [Utility].[GetDateDiffValue2]('day', '2018-01-01', '00:00:00', '2018-03-11', '10:15:20'); -- 69.427315
select 69 + (10 / 24.0) + (15 / 1440.0) + 20 / 86400.0
select 5998520.0 / 86400.0

SELECT [Utility].[GetDateDiffValue2]('week', '2018-01-01', '00:00:00', '2018-03-11', '10:15:20'); -- 9.918188
select 69.427315 / 7.0

SELECT [Utility].[GetDateDiffValue2]('month', '2018-01-01', '00:00:00', '2018-03-11', '10:15:20'); -- 2.322581

SELECT [Utility].[GetDateDiffValue2]('month2', '2018-01-01', '00:00:00', '2019-03-11', '10:15:20');
SELECT [Utility].[GetDateDiffValue2]('quarter', '2018-01-01', '00:00:00', '2019-03-11', '10:15:20');
SELECT [Utility].[GetDateDiffValue2]('half', '2018-01-01', '00:00:00', '2019-03-11', '10:15:20');
SELECT [Utility].[GetDateDiffValue2]('year', '2018-01-01', '00:00:00', '2019-03-11', '10:15:20');
============================================================================================ */
BEGIN
 Declare @value numeric(18, 6), @dateS datetime, @dateE datetime;

 if (@datePart NOT IN ('YEAR', 'YY', 'YYYY', 'HALF', 'QUARTER', 'QQ', 'Q', 'MONTH2', 'MM2', 'M2', 
     'MONTH', 'MM', 'M', 'WEEK', 'WK', 'WW', 'DAY', 'DD', 'D', 'HOUR', 'HH', 'MINUTE', 'MI', 'N', 'SECOND', 'SS', 'S'))
 begin
  return null; 
 end;
 
 if (@dateStart IS NULL AND @dateEnd IS NULL)
 begin
  set @dateS = convert(datetime, @timeStart);
  set @dateE = convert(datetime, @timeEnd);
 end
 else
 begin
  set @dateS = CASE WHEN @timeStart IS NULL THEN @dateStart ELSE convert(datetime, @dateStart) + convert(datetime, @timeStart) END;
  set @dateE = CASE WHEN @timeEnd IS NULL THEN @dateEnd ELSE convert(datetime, @dateEnd) + convert(datetime, @timeEnd) END;
 end;

 if (@datePart IN ('SECOND', 'SS', 'S')) 
 begin
  set @value = DATEDIFF_BIG(SS, @dateS, @dateE);
 end
 else if (@datePart IN ('MINUTE', 'MI', 'N'))
 begin
  set @value = DATEDIFF_BIG(SS, @dateS, @dateE) / 60.0;
 end
 else if (@datePart IN ('HOUR', 'HH'))
 begin
  set @value = DATEDIFF_BIG(SS, @dateS, @dateE) / 3600.0;
 end
 else if (@datePart in ('DAY', 'DD', 'D'))
 begin
  set @value = DATEDIFF_BIG(SS, @dateS, @dateE) / 86400.0;
 end;
 else if (@datePart in ('WEEK', 'WK', 'WW'))
 begin
  set @value = DATEDIFF_BIG(SS, @dateS, @dateE) /  604800.0;
 end
 else if (@datePart in ('MONTH', 'MM', 'M'))
 begin
  set @value = datediff(month, @dateS, @dateE) - 1 +
               1 - 1.0 * (day(@dateS) - 1)/ day(dateadd(m, datediff(m, -1, @dateS), -1)) 
			   + 1.0 * (day(@dateE) - 1) / day(dateadd(m, datediff(m, -1, @dateE), - 1));
 end
 else if @datePart in ('MONTH2', 'MM2', 'M2') -- bimestre
 begin
  set @value = ( datediff(month, @dateS, @dateE) - 1 +
               1 - 1.0 * (day(@dateS) - 1)/ day(dateadd(m, datediff(m, -1, @dateS), -1)) 
			   + 1.0 * (day(@dateE) - 1) / day(dateadd(m, datediff(m, -1, @dateE), - 1)) ) / 2.0;
 end
 else if @datePart in ('QUARTER', 'QQ', 'Q') -- Trimestre
 begin
  set @value = ( datediff(month, @dateS, @dateE) - 1 +
               1 - 1.0 * (day(@dateS) - 1)/ day(dateadd(m, datediff(m, -1, @dateS), -1)) 
			   + 1.0 * (day(@dateE) - 1) / day(dateadd(m, datediff(m, -1, @dateE), - 1)) ) / 3.0;
 end
 else if @datePart in ('HALF') -- semestre
 begin
  set @value = DATEDIFF_BIG(day, @dateS, @dateE) / 182.625;
 end
 else if @datePart in ('YEAR', 'YY', 'YYYY') 
 begin
  set @value = DATEDIFF_BIG(day, @dateS, @dateE) / 365.25;
 end
 else
 begin
  set @value = DATEDIFF_BIG(SS, @dateS, @dateE);
 end;
   
 RETURN (@value);
END
GO


IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[GetDurationBetweenDates]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
 EXEC('CREATE FUNCTION [Utility].[GetDurationBetweenDates] (@dateStart datetime, @dateEnd datetime)
RETURNS nvarchar(30)
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN
 RETURN('''');
END');
GO
ALTER FUNCTION [Utility].[GetDurationBetweenDates] (@dateStart datetime, @dateEnd datetime)
RETURNS nvarchar(30)
AS
/* ============================================================================================
Proposito: Retorna la duración entre dos fechas.
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2016-04-01
Fecha actualizacion: 2020-07-15

Parametros:
 @dateStart: Fecha inicial
 @dateEnd: Fecha final

Ejemplo:
SELECT [Utility].[GetDurationBetweenDates]('20110101', '20110131');
============================================================================================ */
BEGIN
 Declare @iDays int, @iHours int, @iMinutes int, @iSeconds int, @sDuration  nvarchar(50);
 
  SET @iDays = CONVERT(INT, DATEDIFF(ss, @dateStart, @dateEnd)/(24*60*60))
  SET @iHours = CONVERT(INT, DATEDIFF(ss, @dateStart, @dateEnd)/(60*60)) - (@iDays * 24)
  SET @iMinutes = CONVERT(INT, DATEDIFF(ss, @dateStart, @dateEnd)/60) - (@iHours * 60) - (@iDays * 24 * 60)
  SET @iSeconds = DATEDIFF(ss, @dateStart, @dateEnd) - (@iMinutes * 60) - (@iHours * 60 * 60) - (@iDays * 24 * 3600)
   
 IF (@iDays <> 0)
 begin
  SET @sDuration = CONVERT(nvarchar, @iDays) + ' Dias ';
 end
 else
 begin
  SET @sDuration = '';
 end;

 RETURN(@sDuration + CONVERT(nvarchar, @iHours) + ' Horas ' + Right('0' + CONVERT(nvarchar, @iMinutes), 2) + ':' + Right('0' + CONVERT(nvarchar, @iSeconds), 2));
END
GO

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[GetDateSequence]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
 EXEC('CREATE FUNCTION [Utility].[GetDateSequence] (
	@dateStart DATETIME,
	@dateEnd DATETIME,
	@frequency SMALLINT
)
RETURNS @returnDates TABLE
(
	[DateSecuence] DATE
) 
AS
BEGIN
 RETURN;
END');
GO
ALTER FUNCTION [Utility].[GetDateSequence]
(
	@dateStart DATETIME,
	@dateEnd DATETIME,
	@frequency SMALLINT
)
RETURNS @returnDates TABLE
(
	[DateSecuence] DATE
) 
AS
/* ============================================================================================
Proposito: Retorna lista de fechas secuenciales, desde fecha inicio hasta la fecha fin, aumentando el número de días dado por la frecuencia.
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2015-02-01
Fecha actualizacion: 2020-07-15

Parametros:
@dateStart: fecha inicio
@dateEnd: Fecha fin
@frequency: Frecuencia o numéro de días a sumar a la fecha anterior, desde fecha inicio hasta fecha fin.

Retorno: Retorna lista de fechas según la frecuencia.

Ejemplo:
SELECT * FROM [Utility].[GetDateSequence] ('20110101', '20110131', 3) 
============================================================================================ */
BEGIN
 DECLARE @f datetime;
 
 if @dateStart is not null
 begin
  insert into @returnDates ([DateSecuence]) values (@dateStart) 
 end

 if @frequency = 0
 begin
  RETURN;
 end
 
 if not (@frequency is null or @frequency < 0)  
 begin
  if @dateEnd is null
  begin
   set @dateEnd = @dateStart
  end
  else if @dateStart > @dateEnd
  begin
   set @f = @dateStart
   set @dateStart = @dateEnd
   set @dateEnd = @f 
  end
  
  while (@dateStart <= @dateEnd)
  begin
   set @dateStart = DateAdd(d, @frequency, @dateStart)
   if (@dateStart <= @dateEnd)
   begin
    insert into @returnDates ([DateSecuence]) values (@dateStart) 
   end
  end
 end
 
 RETURN;
END; 
GO

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[GetTimeStartEnd]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
 EXEC('CREATE FUNCTION [Utility].[GetTimeStartEnd](@truncateTime bit)
RETURNS char(12)
AS
BEGIN
 RETURN ''00:00:00.000'';
END');
GO
ALTER FUNCTION [Utility].[GetTimeStartEnd](@truncateTime bit)
RETURNS char(12)
AS
/* ============================================================================================
Proposito: Retorna tiempo como texto de inicio o fin del día.
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2011-01-31
Fecha actualizacion: 2020-07-15

Parametros:
 @truncateTime: Indica si truncar la hora de la fecha retornada.
  true: 00:00:00.000
  false: 23:59:59.997

Retorno: Retorna tiempo.

Ejemplo:
SELECT [Utility].[GetTimeStartEnd](0);
SELECT [Utility].[GetTimeStartEnd](1)
SELECT [Utility].[GetTimeStartEnd](Null)
============================================================================================ */
begin
 Declare @time char(12)
 if (@truncateTime = 0)
 begin
  set @time = '23:59:59.997';
 end
 else
 begin
  set @time = '00:00:00.000';
 end
 return @time;
end
GO

/* ====================================================================================
 Funciones Semestre
==================================================================================== */
IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[GetEndOfHalf]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
 EXEC('CREATE FUNCTION [Utility].[GetEndOfHalf] (@year int, @half int, @truncateTime bit)
RETURNS DateTime
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN
 RETURN(GetDate());
END');
GO

ALTER FUNCTION [Utility].[GetEndOfHalf](@year int, @half int, @truncateTime bit)
RETURNS DateTime
WITH RETURNS NULL ON NULL INPUT
AS
/* ============================================================================================
Proposito: Retorna la fecha del último día del semestre, del año dado.
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2011-01-31
Fecha actualizacion: 2020-07-15

Parametros:
 @year: Año.
 @half: Número de semestre en el rango 1 a 2.
 @truncateTime: Indica si truncar la hora de la fecha retornada.
  true: 00:00:00.000
  false: 23:59:59.997

Retorno: Retorna la fecha del último día del semestre.

Excepcion: semestre fuera del rango (retorna null).

Ejemplo:
SELECT [Utility].[GetEndOfHalf](YEAR(GetDate()), 1, 0)
SELECT [Utility].[GetEndOfHalf](YEAR(GetDate()), 1, 1)
SELECT [Utility].[GetEndOfHalf](YEAR(GetDate()), 2, 0)
============================================================================================ */
begin  
 declare @date datetime
 
 if (@half <= 0 OR @half > 2)
  return null;      

 set @date = case 
  when @half = 1 then [Utility].[GetEndOfMonth](@year, 6, @truncateTime)
  else [Utility].[GetEndOfMonth](@year, 12, @truncateTime) end;

 return @date;
 -- return DATEADD(QQ,((DATEDIFF(QQ,0,@Date)/2)*2)+2,-1)
end
GO

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[GetStartOfHalf]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
 EXEC('CREATE FUNCTION [Utility].[GetStartOfHalf](@year int, @half int)
RETURNS DateTime
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN
 RETURN(GetDate());
END');
GO

ALTER FUNCTION [Utility].[GetStartOfHalf](@year int, @half int)
RETURNS DateTime
WITH RETURNS NULL ON NULL INPUT
AS
/* ============================================================================================
Proposito: Retorna la fecha del primer día del semestre. del año dado.
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2011-01-31
Fecha actualizacion: 2020-07-15

Parametros:
 @year: Año.
 @half: Número de semestre en el rango 1 a 2.

Retorno: Retorna la fecha del primer día del semestre.

Excepcion: semestre fuera del rango (retorna null).

Ejemplo:
SELECT [Utility].[GetStartOfHalf](YEAR(GetDate()), 1)
SELECT [Utility].[GetStartOfHalf](YEAR(GetDate()), 2)
============================================================================================ */
begin  
 declare @date datetime
 
 if (@half <= 0 OR @half > 2)
  return null;      

 set @date = case 
  when @half = 1 then [Utility].[GetStartOfMonth](@year, 1)
  else [Utility].[GetStartOfMonth](@year, 7) end;

 return @date;
 -- returna DATEADD(QQ,((DATEDIFF(QQ,0,@Date)/2)*2),0)
end
GO


IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[GetHalf]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
 EXEC('CREATE FUNCTION [Utility].[GetHalf](@month int)
RETURNS int
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN
 RETURN(0);
END');
GO

ALTER FUNCTION [Utility].[GetHalf](@month int)
RETURNS int
WITH RETURNS NULL ON NULL INPUT
AS
/* ============================================================================================
Proposito: Retorna el número de semestre de un número de mes dado.
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2011-01-31
Fecha actualizacion: 2020-07-15

Parametros:
 @month: Mes, en el rango 1 a 12.

Retorno: Retorna el número de semestre.

Excepcion: semestre fuera del rango (retorna null).

Ejemplo:
SELECT [Utility].[GetHalf](2)
SELECT [Utility].[GetHalf](8)
============================================================================================ */
begin  
 declare @half int
 
 if (@month <= 0 OR @month > 12)
  return null;      

 set @half = case 
  when @month <= 6 then 1
  else 2 end;

 return @half;
end
GO

/* ====================================================================================
Funciones bimestre
==================================================================================== */
IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[GetEndOfMonth2]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
 EXEC('CREATE FUNCTION [Utility].[GetEndOfMonth2](@year int, @month2 int, @truncateTime bit)
RETURNS DateTime
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN
 RETURN(GetDate());
END');
GO

ALTER FUNCTION [Utility].[GetEndOfMonth2](@year int, @month2 int, @truncateTime bit)
RETURNS DateTime
WITH RETURNS NULL ON NULL INPUT
AS
/* ============================================================================================
Proposito: Retorna la fecha del último día del bimestre, del año dado.
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2011-01-31
Fecha actualizacion: 2020-07-15

Parametros:
 @year: Año.
 @month2: Número de bimestre en el rango 1 a 6.
 @truncateTime: Indica si truncar la hora de la fecha retornada.
  true: 00:00:00.000
  false: 23:59:59.997

Retorno: Retorna la fecha del último día del bimestre.

Excepcion: bimestre fuera del rango (retorna null).

Ejemplo:
SELECT [Utility].[GetEndOfMonth2](YEAR(GetDate()), 1, 0)
SELECT [Utility].[GetEndOfMonth2](YEAR(GetDate()), 1, 1)
SELECT [Utility].[GetEndOfMonth2](YEAR(GetDate()), 2, 0)
SELECT [Utility].[GetEndOfMonth2](YEAR(GetDate()), 3, 0)
SELECT [Utility].[GetEndOfMonth2](YEAR(GetDate()), 4, 0)
============================================================================================ */
begin  
 declare @date datetime
 
 if (@month2 <= 0 OR @month2 > 6)
  return null;      

 set @date = case 
  when @month2 = 1 then [Utility].[GetEndOfMonth](@year, 2, @truncateTime)
  when @month2 = 2 then [Utility].[GetEndOfMonth](@year, 4, @truncateTime)
  when @month2 = 3 then [Utility].[GetEndOfMonth](@year, 6, @truncateTime)
  when @month2 = 4 then [Utility].[GetEndOfMonth](@year, 8, @truncateTime)
  when @month2 = 5 then [Utility].[GetEndOfMonth](@year, 10, @truncateTime)
  else [Utility].[GetEndOfMonth](@year, 12, @truncateTime) end;

 return @date;
end
GO

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[GetStartOfMonth2]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
 EXEC('CREATE FUNCTION [Utility].[GetStartOfMonth2](@year int, @month2 int)
RETURNS DateTime
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN
 RETURN(GetDate());
END');
GO

ALTER FUNCTION [Utility].[GetStartOfMonth2](@year int, @month2 int)
RETURNS DateTime
WITH RETURNS NULL ON NULL INPUT
AS
/* ============================================================================================
Proposito: Retorna la fecha del primer día del bimestre. del año dado.
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2011-01-31
Fecha actualizacion: 2020-07-15

Parametros:
 @year: Año.
 @month2: Número de bimestre en el rango 1 a 6.

Retorno: Retorna la fecha del primer día del bimestre.

Excepcion: bimestre fuera del rango (retorna null).

Ejemplo:
SELECT [Utility].[GetStartOfMonth2](YEAR(GetDate()), 1)
SELECT [Utility].[GetStartOfMonth2](YEAR(GetDate()), 1)
SELECT [Utility].[GetStartOfMonth2](YEAR(GetDate()), 2)
SELECT [Utility].[GetStartOfMonth2](YEAR(GetDate()), 3)
SELECT [Utility].[GetStartOfMonth2](YEAR(GetDate()), 4)
============================================================================================ */
begin  
 declare @date datetime
 
 if (@month2 <= 0 OR @month2 > 6)
  return null;      

 set @date = case 
  when @month2 = 1 then [Utility].[GetStartOfMonth](@year, 1)
  when @month2 = 2 then [Utility].[GetStartOfMonth](@year, 3)
  when @month2 = 3 then [Utility].[GetStartOfMonth](@year, 5)
  when @month2 = 4 then [Utility].[GetStartOfMonth](@year, 7)
  when @month2 = 5 then [Utility].[GetStartOfMonth](@year, 9)
  else [Utility].[GetStartOfMonth](@year, 11) end;

 return @date;
end
GO

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[GetMonth2]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
 EXEC('CREATE FUNCTION [Utility].[GetMonth2](@month int)
RETURNS int
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN
 RETURN(0);
END');
GO

ALTER FUNCTION [Utility].[GetMonth2](@month int)
RETURNS int
WITH RETURNS NULL ON NULL INPUT
AS
/* ============================================================================================
Proposito: Retorna el número de bimestre de un número de mes dado.
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2011-01-31
Fecha actualizacion: 2020-07-15

Parametros:
 @month: Mes, en el rango 1 a 12.

Retorno: Retorna el número de bimestre.

Excepcion: bimestre fuera del rango (retorna null).

Ejemplo:
SELECT [Utility].[GetMonth2](2)
SELECT [Utility].[GetMonth2](5)
SELECT [Utility].[GetMonth2](8)
SELECT [Utility].[GetMonth2](11)
============================================================================================ */
begin  
 declare @monthNumber int
 
 if (@month <= 0 OR @month > 12)
  return null;      

 set @monthNumber = case 
  when @month <= 2 then 1
  when @month >= 3 and @month <= 4 then 2
  when @month >= 5 and @month <= 6 then 3
  when @month >= 7 and @month <= 8 then 4
  when @month >= 9 and @month <= 10 then 5
  else 6 end;

 return @monthNumber;
end
GO

/* ====================================================================================
 Funciones Trimestre
==================================================================================== */
IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[GetEndOfQuarter]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
 EXEC('CREATE FUNCTION [Utility].[GetEndOfQuarter](@year int, @quarter int, @truncateTime bit)
RETURNS DateTime
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN
 RETURN(GetDate());
END');
GO

ALTER FUNCTION [Utility].[GetEndOfQuarter](@year int, @quarter int, @truncateTime bit)
RETURNS DateTime
WITH RETURNS NULL ON NULL INPUT
AS
/* ============================================================================================
Proposito: Retorna la fecha del último día del trimestre, del año dado.
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2011-01-31
Fecha actualizacion: 2020-07-15

Parametros:
 @year: Año.
 @quarter: Número de trimestre en el rango 1 a 4.
 @truncateTime: Indica si truncar la hora de la fecha retornada.
  true: 00:00:00.000
  false: 23:59:59.997

Retorno: Retorna la fecha del último día del trimestre.

Excepcion: Trimestre fuera del rango (retorna null).

Ejemplo:
SELECT [Utility].[GetEndOfQuarter](YEAR(GetDate()), 1, 0)
SELECT [Utility].[GetEndOfQuarter](YEAR(GetDate()), 1, 1)
SELECT [Utility].[GetEndOfQuarter](YEAR(GetDate()), 2, 0)
SELECT [Utility].[GetEndOfQuarter](YEAR(GetDate()), 3, 0)
SELECT [Utility].[GetEndOfQuarter](YEAR(GetDate()), 4, 0)
============================================================================================ */
begin  
 declare @date datetime
 
 if (@quarter <= 0 OR @quarter > 4)
  return null;      

 set @date = case 
  when @quarter = 1 then [Utility].[GetEndOfMonth](@year, 3, @truncateTime)
  when @quarter = 2 then [Utility].[GetEndOfMonth](@year, 6, @truncateTime)
  when @quarter = 3 then [Utility].[GetEndOfMonth](@year, 9, @truncateTime)
  else [Utility].[GetEndOfMonth](@year, 12, @truncateTime) end;

 return @date;
 -- return DATEADD(QQ, DATEDIFF(QQ,0, @Date)+1,-1)
end
GO

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[GetStartOfQuarter]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
 EXEC('CREATE FUNCTION [Utility].[GetStartOfQuarter](@year int, @quarter int)
RETURNS DateTime
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN
 RETURN(GetDate());
END');
GO

ALTER FUNCTION [Utility].[GetStartOfQuarter](@year int, @quarter int)
RETURNS DateTime
WITH RETURNS NULL ON NULL INPUT
AS
/* ============================================================================================
Proposito: Retorna la fecha del primer día del trimestre. del año dado.
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2011-01-31
Fecha actualizacion: 2020-07-15

Parametros:
 @year: Año.
 @quarter: Número de trimestre en el rango 1 a 4.

Retorno: Retorna la fecha del primer día del trimestre.

Excepcion: Trimestre fuera del rango (retorna null).

Ejemplo:
SELECT [Utility].[GetStartOfQuarter](YEAR(GetDate()), 1)
SELECT [Utility].[GetStartOfQuarter](YEAR(GetDate()), 2)
SELECT [Utility].[GetStartOfQuarter](YEAR(GetDate()), 3)
SELECT [Utility].[GetStartOfQuarter](YEAR(GetDate()), 4)
============================================================================================ */
begin  
 declare @date datetime
 
 if (@quarter <= 0 OR @quarter > 4)
  return null;      

 set @date = case 
  when @quarter = 1 then [Utility].[GetStartOfMonth](@year, 1)
  when @quarter = 2 then [Utility].[GetStartOfMonth](@year, 4)
  when @quarter = 3 then [Utility].[GetStartOfMonth](@year, 7)
  else [Utility].[GetStartOfMonth](@year, 10) end;

 return @date;
 --return DATEADD(QQ, DATEDIFF(QQ,0, @Date),0)
end
GO

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[GetQuarter]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
 EXEC('CREATE FUNCTION [Utility].[GetQuarter](@month int)
RETURNS int
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN
 RETURN(0);
END');
GO

ALTER FUNCTION [Utility].[GetQuarter](@month int)
RETURNS int
WITH RETURNS NULL ON NULL INPUT
AS
/* ============================================================================================
Proposito: Retorna el número de trimestre de un número de mes dado.
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2011-01-31
Fecha actualizacion: 2020-07-15

Parametros:
 @month: Mes, en el rango 1 a 12.

Retorno: Retorna el número de trimestre.

Excepcion: Trimestre fuera del rango (retorna null).

Ejemplo:
SELECT [Utility].[GetQuarter](2)
SELECT [Utility].[GetQuarter](5)
SELECT [Utility].[GetQuarter](8)
SELECT [Utility].[GetQuarter](11)
============================================================================================ */
begin  
 declare @quarter int
 
 if (@month <= 0 OR @month > 12)
  return null;      

 set @quarter = case 
  when @month <= 3 then 1
  when @month >= 4 and @month <= 6 then 2
  when @month >= 7 and @month <= 9 then 3
  else 4 end;

 return @quarter;
end
GO

/* ====================================================================================
Funciones Semana
==================================================================================== */
IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[GetEndOftWeek]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
 EXEC('CREATE FUNCTION [Utility].[GetEndOftWeek](@date datetime, @truncateTime bit)
RETURNS DateTime
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN
 RETURN(GetDate());
END');
GO

ALTER FUNCTION [Utility].[GetEndOftWeek](@date datetime, @truncateTime bit)
RETURNS DateTime
WITH RETURNS NULL ON NULL INPUT
AS
/* ============================================================================================
Proposito: Retorna la fecha del último día de semana.
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2011-01-31
Fecha actualizacion: 2020-07-15

Parametros:
 @date: Fecha.
 @truncateTime: Indica si truncar la hora de la fecha retornada.
  true: 00:00:00.000
  false: 23:59:59.997

Retorno: Retorna la fecha del último día de semana.

Ejemplo:
SELECT [Utility].[GetEndOftWeek](GetDate(), 0)
SELECT [Utility].[GetEndOftWeek](GetDate(), 1)
============================================================================================ */
begin  
 declare @dateW datetime
 
 -- set @dateW = @date - DATEDIFF(dd, @@DATEFIRST - 1, @date) % 7 + 6; 
 set @dateW = DATEADD(WK, DATEDIFF(WK, 0, @date) + 1, -1)
 set @dateW = CONVERT(datetime, convert(nvarchar(10), @dateW, 120) + ' ' + [Utility].[GetTimeStartEnd](@truncateTime), 120);
 return @dateW;
end
GO

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[GetStartOfWeek]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
 EXEC('CREATE FUNCTION [Utility].[GetStartOfWeek](@date datetime)
RETURNS DateTime
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN
 RETURN(GetDate());
END');
GO

ALTER FUNCTION [Utility].[GetStartOfWeek](@date datetime)
RETURNS DateTime
WITH RETURNS NULL ON NULL INPUT
AS
/* ============================================================================================
Proposito: Retorna la fecha del primer día de semana.
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2011-01-31
Fecha actualizacion: 2020-07-15

Parametros:
 @date: Fecha.

Retorno: Retorna la fecha del primer día de semana.

Ejemplo:
SELECT [Utility].[GetStartOfWeek](GetDate())
============================================================================================ */
begin  
 declare @dateW datetime
 
-- set @dateW = @date - DATEDIFF(dd, @@DATEFIRST - 1, @date) % 7; 
 set @dateW = DATEADD(WK, DATEDIFF(WK, 0, @date), 0)
 return Convert(datetime, ROUND(Convert(float, @dateW), 0, 1));
end
GO

/* ====================================================================================
 Funciones Mes
==================================================================================== */
IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[GetDaysInMonth]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
 EXEC('CREATE FUNCTION [Utility].[GetDaysInMonth](@year int, @month int)
RETURNS int
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN
 RETURN(0);
END');
GO

ALTER FUNCTION [Utility].[GetDaysInMonth](@year int, @month int)
RETURNS int
WITH RETURNS NULL ON NULL INPUT
AS
/* ============================================================================================
Proposito: Retorna el número de días de un mes.
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2011-01-31
Fecha actualizacion: 2020-07-15

Parametros:
 @year: Año.
 @month: Mes, en el rango 1 a 12. 

Retorno: Retorna el número de días de un mes.

Excepcion: Mes fuera del rango (retorna null).

Ejemplo:
SELECT [Utility].[GetDaysInMonth](YEAR(GetDate()), MONTH(GetDate()))
SELECT [Utility].[GetDaysInMonth](2011, 7)
============================================================================================ */
begin
 declare @dateStart datetime, @dateEnd datetime
 if (@month <= 0 OR @month > 12)
  return null;      
  
 set @dateStart = CONVERT(datetime, convert(nvarchar, @year) + '-' + convert(nvarchar, @month) + '-01', 120);
 set @dateEnd = DATEADD(month, 1, @dateStart);

  return DateDiff(day, @dateStart, @dateEnd);
end
GO

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[GetEndOfMonth]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
 EXEC('CREATE FUNCTION [Utility].[GetEndOfMonth](@year int, @month int, @truncateTime bit)
RETURNS DateTime
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN
 RETURN(GetDate());
END');
GO

ALTER FUNCTION [Utility].[GetEndOfMonth](@year int, @month int, @truncateTime bit)
RETURNS DateTime
WITH RETURNS NULL ON NULL INPUT
AS
/* ============================================================================================
Proposito: Retorna la fecha del último día del mes.
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2011-01-31
Fecha actualizacion: 2020-07-15

Parametros:
 @year: Año.
 @month: Mes, en el rango 1 a 12.
 @truncateTime: Indica si truncar la hora de la fecha retornada.
  true: 00:00:00.000
  false: 23:59:59.997

Retorno: Retorna la fecha del último día del mes.

Excepcion: Mes fuera del rango (retorna null).

Ejemplo:
SELECT [Utility].[GetEndOfMonth](YEAR(GetDate()), MONTH(GetDate()), 0)
SELECT [Utility].[GetEndOfMonth](YEAR(GetDate()), MONTH(GetDate()), 1)
============================================================================================ */
begin  
 if (@month <= 0 OR @month > 12)
  return null;      

 return CONVERT(datetime, convert(nvarchar, @year) + '-' + convert(nvarchar, @month) + '-' + 
  convert(nvarchar, [Utility].[GetDaysInMonth](@year, @month)) + ' ' + [Utility].[GetTimeStartEnd](@truncateTime), 120);
 --RETURN (DATEADD(month, DATEDIFF(month, 0, @date) + 1, 0) - 1)
end
GO

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[GetStartOfMonth]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
 EXEC('CREATE FUNCTION [Utility].[GetStartOfMonth](@year int, @month int)
RETURNS DateTime
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN
 RETURN(GetDate());
END');
GO

ALTER FUNCTION [Utility].[GetStartOfMonth](@year int, @month int)
RETURNS DateTime
WITH RETURNS NULL ON NULL INPUT
AS
/* ============================================================================================
Proposito: Retorna la fecha del primer día del mes.
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2011-01-31
Fecha actualizacion: 2020-07-15

Parametros:
 @year: Año.
 @month: Mes, en el rango 1 a 12.  

Retorno: Retorna la fecha del primer día del mes.
Excepcion: Mes fuera del rango.

Ejemplo:
SELECT [Utility].[GetStartOfMonth](YEAR(GetDate()), MONTH(GetDate()))
============================================================================================ */
begin  
 if (@month <= 0 OR @month > 12)
  return null;      

 return CONVERT(datetime, convert(nvarchar, @year) + '-' + convert(nvarchar, @month) + '-01', 120);
 --RETURN (DATEADD(month, DATEDIFF(month, 0, @date), 0))
end
GO

/* ====================================================================================
Funciones Año
==================================================================================== */
IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[GetEndOfYear]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
 EXEC('CREATE FUNCTION [Utility].[GetEndOfYear](@year int, @truncateTime bit)
RETURNS DateTime
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN
 RETURN(GetDate());
END');
GO

ALTER FUNCTION [Utility].[GetEndOfYear](@year int, @truncateTime bit)
RETURNS DateTime
WITH RETURNS NULL ON NULL INPUT
AS
/* ============================================================================================
Proposito: Retorna la fecha del último día del año.
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2011-01-31
Fecha actualizacion: 2020-07-15

Parametros:
 @year: Año.
 @truncateTime: Indica si truncar la hora de la fecha retornada.
  true: 00:00:00.000
  false: 23:59:59.997

Retorno: Retorna la fecha del último día del año.

Ejemplo:
SELECT [Utility].[GetEndOfYear](YEAR(GetDate()), 0)
SELECT [Utility].[GetEndOfYear](YEAR(GetDate()), 1)
============================================================================================ */
begin 
 return CONVERT(datetime, convert(nvarchar, @year) + '-12-31 '+ [Utility].[GetTimeStartEnd](@truncateTime), 120);
 --RETURN (DATEADD(year, DATEDIFF(year, 0, @date) + 1, 0) - 1)
end
GO

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[GetStartOfYear]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
 EXEC('CREATE FUNCTION [Utility].[GetStartOfYear](@year int)
RETURNS DateTime
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN
 RETURN(GetDate());
END');
GO

ALTER FUNCTION [Utility].[GetStartOfYear](@year int)
RETURNS DateTime
WITH RETURNS NULL ON NULL INPUT
AS
/* ============================================================================================
Proposito: Retorna la fecha del primer día del año.
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2011-01-31
Fecha actualizacion: 2020-07-15

Parametros:
 @year: Año.

Retorno: Retorna la fecha del primer día del año.

Ejemplo:
SELECT [Utility].[GetStartOfYear](YEAR(GetDate()))
============================================================================================ */
begin 
 return CONVERT(datetime, convert(nvarchar, @year) + '-01-01', 120);
 --RETURN (DATEADD(year, DATEDIFF(year, 0, @date), 0))
end
GO

/* ====================================================================================
 Funciones Dia
==================================================================================== */
IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[GetEndOfDay]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
 EXEC('CREATE FUNCTION [Utility].[GetEndOfDay](@date datetime)
RETURNS DateTime
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN
 RETURN(GetDate());
END');
GO

ALTER FUNCTION [Utility].[GetEndOfDay](@date datetime)
RETURNS DateTime
WITH RETURNS NULL ON NULL INPUT
AS
/* ============================================================================================
Proposito: Retorna la fecha dada con el tiempo 23:59:59.997.
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2011-01-31
Fecha actualizacion: 2020-07-15

Parametros:
 @date: Fecha.

Retorno: Retorna la fecha dada con el tiempo 23:59:59.997.

Ejemplo:
SELECT [Utility].[GetEndOfDay](GetDate())
============================================================================================ */
begin  
 return CONVERT(datetime, convert(nvarchar(10), @date, 120) + ' ' + [Utility].[GetTimeStartEnd](0), 120);
end
GO

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[GetStartOfDay]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
 EXEC('CREATE FUNCTION [Utility].[GetStartOfDay](@date datetime)
RETURNS DateTime
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN
 RETURN(GetDate());
END');
GO

ALTER FUNCTION [Utility].[GetStartOfDay](@date datetime)
RETURNS DateTime
WITH RETURNS NULL ON NULL INPUT
AS
/* ============================================================================================
Proposito: Retorna la fecha dada con el tiempo truncado 00:00:00.000.
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2011-01-31
Fecha actualizacion: 2020-07-15

Parametros:
 @date: Fecha.

Retorno: Retorna la fecha dada con el tiempo truncado 00:00:00.000.

Ejemplo:
SELECT [Utility].[GetStartOfDay](GetDate())
============================================================================================ */
begin  
 return Convert(datetime, ROUND(Convert(float, @date), 0, 1));
end
GO


/* ====================================================================================
 Funciones Particion
==================================================================================== */
IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[GetEndOfDatePart]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
 EXEC('CREATE FUNCTION [Utility].[GetEndOfDatePart](@datePart nvarchar(12), @date datetime, @truncateTime bit)
RETURNS DateTime
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN
 RETURN(GetDate());
END');
GO

ALTER FUNCTION [Utility].[GetEndOfDatePart](@datePart nvarchar(12), @date datetime, @truncateTime bit)
RETURNS DateTime
WITH RETURNS NULL ON NULL INPUT
AS
/* ============================================================================================
Proposito: Retorna la fecha del último día, según el tipo de partición dada.
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2011-01-31
Fecha actualizacion: 2020-07-15

select DATEPART ( dayofyear , GetDate() )

Parametros:
 @datePart: Parte de fecha
  Año: year, yy, yyyy
  Semestre: half
  Trimestre: quarter, qq, q 
  Bimestre: month2, mm2, m2
  Mes: month, mm, m 
  Semana: week, wk, ww 
  Día: day, dd, d 
 @date: Fecha.
 @truncateTime: Indica si truncar la hora de la fecha retornada.
  true: 00:00:00.000
  false: 23:59:59.997

Retorno: Retorna la fecha del último día.

Excepcion: Período de partición fuera del rango.

Ejemplo:
SELECT [Utility].[GetEndOfDatePart]('YEAR', GetDate(), 1)
SELECT [Utility].[GetEndOfDatePart]('HALF', GetDate(), 1)
SELECT [Utility].[GetEndOfDatePart]('QUARTER', GetDate(), 1)
SELECT [Utility].[GetEndOfDatePart]('MONTH2', GetDate(), 1)
SELECT [Utility].[GetEndOfDatePart]('MONTH', GetDate(), 1)
SELECT [Utility].[GetEndOfDatePart]('WEEK', GetDate(), 1)
SELECT [Utility].[GetEndOfDatePart]('DAY', GetDate(), 1)
============================================================================================ */
begin 
 Declare @dateTempo datetime 

 set @datePart = UPPER(@datePart);
 if (@datePart not in ('YEAR', 'YY', 'YYYY', 'HALF', 'QUARTER', 'QQ', 'Q', 'MONTH2', 'MM2', 'M2', 
     'MONTH', 'MM', 'M', 'WEEK', 'WK', 'WW', 'DAY', 'DD', 'D'))
 begin
  return null; 
 end

 if @datePart in ('DAY', 'DD', 'D') -- Dia
 begin
  if (@truncateTime = 1)
   set @dateTempo = [Utility].[GetStartOfDay](@date);
  else
   set @dateTempo = [Utility].[GetEndOfDay](@date);
 end
 else if @datePart in ('WEEK', 'WK', 'WW') -- semana
  set @dateTempo = [Utility].[GetEndOftWeek](@date, @truncateTime);
 else if @datePart in ('MONTH', 'MM', 'M') -- mes
  set @dateTempo = [Utility].[GetEndOfMonth](Year(@date), Month(@date), @truncateTime);
 else if @datePart in ('MONTH2', 'MM2', 'M2') -- bimestre
  set @dateTempo = [Utility].[GetEndOfMonth2](Year(@date), [Utility].[GetMonth2](Month(@date)), @truncateTime);
 else if @datePart in ('QUARTER', 'QQ', 'Q') -- Trimestre
  set @dateTempo = [Utility].[GetEndOfQuarter](Year(@date), [Utility].[GetQuarter](Month(@date)), @truncateTime);
 else if @datePart in ('HALF') -- semestre
  set @dateTempo = [Utility].[GetEndOfHalf](Year(@date), [Utility].[GetHalf](Month(@date)), @truncateTime);
 else if @datePart in ('YEAR', 'YY', 'YYYY') -- año
  set @dateTempo = [Utility].[GetEndOfYear](Year(@date), @truncateTime);

 return @dateTempo;
end
GO 

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[GetStartOfDatePart]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
 EXEC('CREATE FUNCTION [Utility].[GetStartOfDatePart](@datePart nvarchar(12), @date datetime)
RETURNS DateTime
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN
 RETURN(GetDate());
END');
GO

ALTER FUNCTION [Utility].[GetStartOfDatePart](@datePart nvarchar(12), @date datetime)
RETURNS DateTime
WITH RETURNS NULL ON NULL INPUT
AS
/* ============================================================================================
Proposito: Retorna la fecha del primer día, según el tipo de partición dada.
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2011-01-31
Fecha actualizacion: 2020-07-15

Parametros:
 @datePart: Parte de fecha
  Año: year, yy, yyyy
  Semestre: half
  Trimestre: quarter, qq, q 
  Bimestre: month2, mm2, m2
  Mes: month, mm, m 
  Semana: week, wk, ww 
  Día: day, dd, d 
 @date: Fecha.

Retorno: Retorna la fecha del primer día.

Exception: Argumentos fuera del rango (tipo de partición o tipo de datos).

Ejemplo:
SELECT [Utility].[GetStartOfDatePart]('YEAR', GetDate())
SELECT [Utility].[GetStartOfDatePart]('HALF', GetDate())
SELECT [Utility].[GetStartOfDatePart]('QUARTER', GetDate())
SELECT [Utility].[GetStartOfDatePart]('MONTH2', GetDate())
SELECT [Utility].[GetStartOfDatePart]('MONTH', GetDate())
SELECT [Utility].[GetStartOfDatePart]('WEEK', GetDate())
SELECT [Utility].[GetStartOfDatePart]('DAY', GetDate())
============================================================================================ */
begin 
 Declare @dateTempo datetime 
 
 set @datePart = UPPER(@datePart);
 if (@datePart not in ('YEAR', 'YY', 'YYYY', 'HALF', 'QUARTER', 'QQ', 'Q', 'MONTH2', 'MM2', 'M2', 
     'MONTH', 'MM', 'M', 'WEEK', 'WK', 'WW', 'DAY', 'DD', 'D'))
 begin
  return null; 
 end

 if @datePart in ('DAY', 'DD', 'D') -- Dia
  set @dateTempo = [Utility].[GetStartOfDay](@date);
 else if @datePart in ('WEEK', 'WK', 'WW') -- semana
  set @dateTempo = [Utility].[GetStartOfWeek](@date);
 else if @datePart in ('MONTH', 'MM', 'M') -- mes
  set @dateTempo = [Utility].[GetStartOfMonth](Year(@date), Month(@date));
 else if @datePart in ('MONTH2', 'MM2', 'M2') -- bimestre
  set @dateTempo = [Utility].[GetStartOfMonth2](Year(@date), [Utility].[GetMonth2](Month(@date)));
 else if @datePart in ('QUARTER', 'QQ', 'Q') -- Trimestre
  set @dateTempo = [Utility].[GetStartOfQuarter](Year(@date), [Utility].[GetQuarter](Month(@date)));
 else if @datePart in ('HALF') -- semestre
  set @dateTempo = [Utility].[GetStartOfHalf](Year(@date), [Utility].[GetHalf](Month(@date)));
 else if @datePart in ('YEAR', 'YY', 'YYYY') -- año
  set @dateTempo = [Utility].[GetStartOfYear](Year(@date));

 return @dateTempo;
end
GO 

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[DateAddPeriod]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
 EXEC('CREATE FUNCTION [Utility].[DateAddPeriod](@datePart nvarchar(12), @number int, @date datetime)
RETURNS DateTime
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN
 RETURN(GetDate());
END');
GO

ALTER FUNCTION [Utility].[DateAddPeriod](@datePart nvarchar(12), @number int, @date datetime)
RETURNS DateTime
WITH RETURNS NULL ON NULL INPUT
AS
/* ============================================================================================
Proposito: Retorna fecha más un número de periódos de tiempo.
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2011-01-31
Fecha actualizacion: 2020-07-15

Parametros:
 @datePart: Parte de fecha
  Año: year, yy, yyyy
  Semestre: half
  Trimestre: quarter, qq, q 
  Bimestre: month2, mm2, m2
  Mes: month, mm, m 
  Semana: week, wk, ww 
  Día: day, dd, d 
 @number: Número de periodos de tiempo a ser adicionados 
 @date: Fecha.

Retorno: Retorna fecha más un número de periódos de tiempo.

Exception: Argumentos fuera del rango: tipo de partición.

Ejemplo:
SELECT [Utility].[DateAddPeriod]('YEAR', 1, GetDate())
SELECT [Utility].[DateAddPeriod]('HALF', 1, GetDate())
SELECT [Utility].[DateAddPeriod]('QUARTER', 1, GetDate())
SELECT [Utility].[DateAddPeriod]('MONTH2', 1, GetDate())
SELECT [Utility].[DateAddPeriod]('MONTH', 1, GetDate())
SELECT [Utility].[DateAddPeriod]('WEEK', 1, GetDate())
SELECT [Utility].[DateAddPeriod]('DAY', 1, GetDate())
============================================================================================ */
begin 
 Declare @dateTempo datetime 
 
 set @datePart = UPPER(@datePart);
 if (@datePart not in ('YEAR', 'YY', 'YYYY', 'HALF', 'QUARTER', 'QQ', 'Q', 'MONTH2', 'MM2', 'M2', 
     'MONTH', 'MM', 'M', 'WEEK', 'WK', 'WW', 'DAY', 'DD', 'D'))
 begin
  return null; 
 end

 if @datePart in ('DAY', 'DD', 'D') -- Dia
  set @dateTempo = DATEADD (DAY , @number , @date);
 else if @datePart in ('WEEK', 'WK', 'WW') -- semana
  set @dateTempo = DATEADD (WEEK , @number , @date);
 else if @datePart in ('MONTH', 'MM', 'M') -- mes
  set @dateTempo = DATEADD (MONTH , @number , @date);
 else if @datePart in ('MONTH2', 'MM2', 'M2') -- bimestre
  set @dateTempo = DATEADD (MONTH , @number * 2, @date);
 else if @datePart in ('QUARTER', 'QQ', 'Q') -- Trimestre
  set @dateTempo = DATEADD (QUARTER , @number , @date);
 else if @datePart in ('HALF') -- semestre
  set @dateTempo = DATEADD (MONTH , @number * 6, @date);
 else if @datePart in ('YEAR', 'YY', 'YYYY') -- año
  set @dateTempo = DATEADD (YEAR , @number , @date);

 return @dateTempo;
end
GO 

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[GetDateDiff]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
 EXEC('CREATE FUNCTION [Utility].[GetDateDiff](@datePart nvarchar(12), @dateStart datetime, @dateEnd datetime)
RETURNS int
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN
 RETURN(0);
END');
GO

ALTER FUNCTION [Utility].[GetDateDiff](@datePart nvarchar(12), @dateStart datetime, @dateEnd datetime)
RETURNS int
WITH RETURNS NULL ON NULL INPUT
AS
/* ============================================================================================
Proposito: Retorna el número de períodos de tiempo entre dos fechas.
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2011-01-31
Fecha actualizacion: 2020-07-15

Parametros:
 @datePart: Parte de fecha
  Año: year, yy, yyyy
  Semestre: half
  Trimestre: quarter, qq, q 
  Bimestre: month2, mm2, m2
  Mes: month, mm, m 
  Semana: week, wk, ww 
  Día: day, dd, d 
 @dateStart: Fecha inicio.  Esta fecha se resta de la fecha fin.
 @dateEnd: Fecha fin.
 
Retorno: Retorna el número de períodos de tiempo entre dos fechas.

Exception: Argumentos fuera del rango: tipo de partición.

Ejemplo:
SELECT [Utility].[GetDateDiff]('YEAR', '20110131', '20120131')
SELECT [Utility].[GetDateDiff]('HALF', '20110131', '20120131')
SELECT [Utility].[GetDateDiff]('QUARTER', '20110131', '20120131')
SELECT [Utility].[GetDateDiff]('MONTH2', '20110131', '20120131')
SELECT [Utility].[GetDateDiff]('MONTH', '20110131', '20120131')
SELECT [Utility].[GetDateDiff]('WEEK', '20110131', '20120131')
SELECT [Utility].[GetDateDiff]('DAY', '20110131', '20120131')

SELECT [Utility].[GetDateDiff]('HALF', '20110115', '20090810')
SELECT [Utility].[GetDateDiff]('QUARTER', '20110115', '20110810')
SELECT [Utility].[GetDateDiff]('MONTH2', '20110115', '20110810')
SELECT [Utility].[GetDateDiff]('MONTH', '20110115', '20110810')
============================================================================================ */
begin 
 Declare @total int 
 
 set @datePart = UPPER(@datePart);
 if (@datePart not in ('YEAR', 'YY', 'YYYY', 'HALF', 'QUARTER', 'QQ', 'Q', 'MONTH2', 'MM2', 'M2', 
     'MONTH', 'MM', 'M', 'WEEK', 'WK', 'WW', 'DAY', 'DD', 'D'))
 begin
  return null; 
 end;

 if @datePart in ('DAY', 'DD', 'D') -- Dia
  set @total = DATEDIFF (DAY , @dateStart, @dateEnd);
 else if @datePart in ('WEEK', 'WK', 'WW') -- semana
  set @total = DATEDIFF (WEEK , @dateStart, @dateEnd);
 else if @datePart in ('MONTH', 'MM', 'M') -- mes
  set @total = DATEDIFF (MONTH , @dateStart, @dateEnd);
 else if @datePart in ('MONTH2', 'MM2', 'M2') -- bimestre
  set @total = DATEDIFF (MONTH , @dateStart, @dateEnd) / 2;
 else if @datePart in ('QUARTER', 'QQ', 'Q') -- Trimestre
  set @total = DATEDIFF (QUARTER , @dateStart, @dateEnd);
 else if @datePart in ('HALF') -- semestre
  set @total = DATEDIFF (MONTH , @dateStart, @dateEnd) / 6;
 else if @datePart in ('YEAR', 'YY', 'YYYY') -- año
  set @total = DATEDIFF (YEAR , @dateStart, @dateEnd);

 return @total;
end
GO 

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[GetDataPart_Period]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
 EXEC('CREATE FUNCTION [Utility].[GetDataPart_Period](@datePart nvarchar(12), @value date)
RETURNS nvarchar(12)
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN
 RETURN('''');
END');
GO

ALTER FUNCTION [Utility].[GetDataPart_Period](@datePart nvarchar(12), @value date)
RETURNS nvarchar(12)
WITH RETURNS NULL ON NULL INPUT
AS
/* ============================================================================================
Proposito: Extrae el periódo de tiempo de un texto.
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2011-01-31
Fecha actualizacion: 2020-07-15

Parametros:
 @datePart: Parte de fecha
  Año: year, yy, yyyy
  Semestre: half
  Trimestre: quarter, qq, q 
  Bimestre: month2, mm2, m2
  Mes: month, mm, m 
  Semana: week, wk, ww 
  Día: day, dd, d 
 @value: fecha.

Retorno: 
 Periodo: Periodo de tiempo

Exception: Argumentos fuera del rango: tipo de partición.

Ejemplo:
SELECT [Utility].[GetDataPart_Period]('YEAR', '20150531');
SELECT [Utility].[GetDataPart_Period]('HALF', '20150531');
SELECT [Utility].[GetDataPart_Period]('QUARTER', '20150531');
SELECT [Utility].[GetDataPart_Period]('MONTH2', '20150531');
SELECT [Utility].[GetDataPart_Period]('MONTH', '20150531');
SELECT [Utility].[GetDataPart_Period]('WEEK', '20150531');
SELECT [Utility].[GetDataPart_Period]('DAY', '20150531');
============================================================================================ */
begin 
 declare @d nvarchar(12);

 set @datePart = UPPER(@datePart);
 if (@datePart not in ('YEAR', 'YY', 'YYYY', 'HALF', 'QUARTER', 'QQ', 'Q', 'MONTH2', 'MM2', 'M2', 
     'MONTH', 'MM', 'M', 'WEEK', 'WK', 'WW', 'DAY', 'DD', 'D'))
 begin
  return null; 
 end;

 if @datePart in ('DAY', 'DD', 'D') -- Dia
  set @d = Convert(nvarchar(8), @value, 112);
 else if @datePart in ('WEEK', 'WK', 'WW') -- semana
  set @d = Convert(nvarchar(4), @value, 112) + Right('0' + Convert(nvarchar(2), DATEPART (wk, @value)), 2);
 else if @datePart in ('MONTH', 'MM', 'M') -- mes
  set @d = Convert(nvarchar(6), @value, 112);
 else if @datePart in ('MONTH2', 'MM2', 'M2') -- bimestre
  set @d = Convert(nvarchar(4), @value, 112) + Right('0' + Convert(nvarchar(2), [Utility].[GetMonth2] (Month(@value))), 2);
 else if @datePart in ('QUARTER', 'QQ', 'Q') -- Trimestre
  set @d = Convert(nvarchar(4), @value, 112) + Right('0' + Convert(nvarchar(2), [Utility].[GetQuarter] (Month(@value))), 2);
 else if @datePart in ('HALF') -- semestre
  set @d = Convert(nvarchar(4), @value, 112) + Right('0' + Convert(nvarchar(2), [Utility].[GetHalf] (Month(@value))), 2);
 else if @datePart in ('YEAR', 'YY', 'YYYY') -- año
  set @d = YEAR (@value);
 else
  set @d = Convert(nvarchar(8), @value, 112);

 return @d;
end
GO 


IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[GetPeriod]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
 EXEC('CREATE FUNCTION [Utility].[GetPeriod](@datePart nvarchar(12), @value nvarchar(20))
RETURNS @tableResult TABLE 
(
  [Period] nvarchar(12) 
)
AS
BEGIN
 RETURN;
END');
GO

ALTER FUNCTION [Utility].[GetPeriod](@datePart nvarchar(12), @value nvarchar(20))
RETURNS @tableResult TABLE 
(
  [Period] nvarchar(12) 
)
AS
/* ============================================================================================
Proposito: Extrae el periódo de tiempo de un texto.
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2011-01-31
Fecha actualizacion: 2020-07-15

Parametros:
 @datePart: Parte de fecha
  Año: year, yy, yyyy
  Semestre: half
  Trimestre: quarter, qq, q 
  Bimestre: month2, mm2, m2
  Mes: month, mm, m 
  Semana: week, wk, ww 
  Día: day, dd, d 
 @value: Texto que tiene el periodo de tiempo a ser extraído, en formato AAAMMDD.

Retorno: 
 Periodo: Periodo de tiempo

Ejemplo:
SELECT * FROM [Utility].[GetPeriod]('YEAR', '20110508')
SELECT * FROM [Utility].[GetPeriod]('MONTH', '20110508')
SELECT * FROM [Utility].[GetPeriod]('DAY', '20110508')
============================================================================================ */
begin
 Declare @p nvarchar(12)

 set @p = case 
  when @datePart IN ('DAY', 'DD', 'D') then LEFT(@value, 8)
  when @datePart in ('WEEK', 'WK', 'WW') then LEFT(@value, 6)
  when @datePart in ('MONTH', 'MM', 'M') then LEFT(@value, 6)
  when @datePart in ('MONTH2', 'MM2', 'M2') then LEFT(@value, 5)
  when @datePart in ('QUARTER', 'QQ', 'Q') then LEFT(@value, 5)
  when @datePart in ('HALF') then LEFT(@value, 5)
  when @datePart in ('YEAR', 'YY', 'YYYY') then LEFT(@value, 4)
  else @value end;
  
 INSERT INTO @tableResult ([Period]) 
 Values (@p)

 RETURN;
end
GO


/* ====================================================================================
 Funciones Utility
==================================================================================== */
IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[GetDateAge]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
 EXEC('CREATE FUNCTION [Utility].[GetDateAge]  (@birthDate DATETIME) 
RETURNS @Age TABLE(Years int, Months int, Days int) 
AS
BEGIN
 RETURN;
END');
GO

ALTER FUNCTION [Utility].[GetDateAge]  (@birthDate DATETIME) 
RETURNS @Age TABLE(Years int, Months int, Days int) 
AS
/* ============================================================================================
Proposito: Retorna una Table con la edad, comparando la fecha dada con la fecha actual.
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2011-01-31
Fecha actualizacion: 2020-07-15

Parametros:
 @birthDate: Fecha de cumpleaños
 
Retorno: 
 Years: Número de años.
 Months: Número de meses.
 Days: Número de días 

Ejemplo:
 Select * from [Utility].[GetDateAge] ('20000101')
 Select * from [Utility].[GetDateAge] ('20200101')
============================================================================================ */
BEGIN 
 DECLARE  @EndDate  DATETIME, @Anniversary DATETIME 

 SET @EndDate = Getdate(); 
 SET @Anniversary = Dateadd(yy,Datediff(yy,@birthDate,@EndDate),@birthDate); 
 INSERT @Age SELECT Datediff(yy,@birthDate,@EndDate) - (CASE WHEN @Anniversary > @EndDate THEN 1 ELSE 0 END), 0, 0;
 UPDATE @Age SET Months = Month(@EndDate - @Anniversary) - 1; 
 UPDATE @Age SET Days = Day(@EndDate - @Anniversary) - 1 ;

 RETURN; 
END 
GO 

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[DateCountBusinessDays]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
 EXEC('CREATE FUNCTION [Utility].[DateCountBusinessDays] (@startDate datetime, @endDate datetime) 
RETURNS INT 
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN
 RETURN (0);
END');
GO

ALTER FUNCTION [Utility].[DateCountBusinessDays] (@startDate datetime, @endDate datetime) 
RETURNS INT 
WITH RETURNS NULL ON NULL INPUT
AS 
/* ============================================================================================
Proposito: Retorna el número de días laborables entre dos fechas - excluyendo sabado y domingo.
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2011-01-31
Fecha actualizacion: 2020-07-15

Parametros:
 @startDate: Fecha inicio.
 @endDate: Fecha fin.  

Retorno: Retorna el número de días laborables entre dos fechas.

Ejemplo:
SELECT [Utility].[DateCountBusinessDays] ('20110101', '20111231') -- 261
============================================================================================ */
BEGIN 
 DECLARE @i INT; 

 set @i = 0;
 IF (@startDate IS NULL OR @endDate IS NULL)  
  RETURN 0 

 WHILE (@startDate <= @endDate) 
 BEGIN 
  SET @i = @i + CASE WHEN datepart(dw, @startDate) BETWEEN 2 AND 6 THEN 1 ELSE 0 END;

  SET @startDate = DATEADD(dd, 1, @startDate)
 END  -- while  

 RETURN (@i) 
END 
GO 

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[GetDateBusinessDays]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
 EXEC('CREATE FUNCTION [Utility].[GetDateBusinessDays] (@startDate datetime, @days smallint) 
RETURNS DATETIME 
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN
 RETURN (GetDate());
END');
GO

ALTER FUNCTION [Utility].[GetDateBusinessDays] (@startDate datetime, @days smallint) 
RETURNS DATETIME 
WITH RETURNS NULL ON NULL INPUT
AS 
/* ============================================================================================
Proposito: Retorna el número de días laborables entre dos fechas - excluyendo sabado y domingo.
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2011-01-31
Fecha actualizacion: 2020-07-15

Parametros:
@startDate: Fecha inicio.
@days: Número de días que se sumarán a la fecha inicial.  

Retorno: Retorna el número de días laborables entre dos fechas.

Ejemplo:
select datepart(dw, ''20110101'')
select datepart(dw, ''20110102'')
select datepart(dw, ''20110103'')
select datepart(dw, ''20110104'')
select datepart(dw, ''20110105'')
select datepart(dw, ''20110106'')
select datepart(dw, ''20110107'')

SELECT * FROM [Utility].[SpecialDate] 
WHERE [Date] >=''20110101'' and [Date] <=''20110131'' AND [Type] IN (''Festivo'')
SELECT [Utility].[GetStartOfDay](''20110110'')

SELECT [Utility].[GetDateBusinessDays] (''20101231'', 10) -- 2011-01-17 00:00:00.000
SELECT [Utility].[GetDateBusinessDays] (''20101231'', -10) -- 2011-01-17 00:00:00.000
============================================================================================ */
BEGIN 
 DECLARE  @i INT
 DECLARE  @iMax INT
 DECLARE  @j INT, @K INT, @count int
 DECLARE  @Date DATETIME
 DECLARE  @DateCompare DATETIME

 IF (@startDate IS NULL OR @days IS NULL)  
  RETURN (NULL)

 SET @i = 1; 
 SET @k = 1; 
 SET @iMax = abs(@days);
 SET @count= 0;

 IF (@days = 0)  
  RETURN (@startDate)
 else if (@days > 0)  
  set @j = 1
 else
  set @j = -1

 WHILE (@i <= @iMax ) 
 BEGIN 
  Set @DateCompare = DATEADD(dd, @j * @k, @startDate)
  if (datepart(dw, @DateCompare) BETWEEN 1 AND 5) AND 
     (NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] 
                 WHERE [Utility].[GetStartOfDay]([DateId]) = [Utility].[GetStartOfDay](@DateCompare) AND [Type] IN ('Festivo')))
  begin
   set @i = @i + 1
  end
  else
  begin
   set @count = @count + 1
  end
  set @k = @k + 1
 END  -- while  
 set @Date = DATEADD(dd, @j * (@count + @iMax), @startDate)

 RETURN (@Date) 
END 
GO

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[DateFormat]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
 EXEC('CREATE FUNCTION [Utility].[DateFormat] (@date DATETIME, @formatMask nvarchar(32)) 
RETURNS nvarchar(32) 
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN
 RETURN ('''');
END');
GO

ALTER FUNCTION [Utility].[DateFormat] (@date DATETIME, @formatMask nvarchar(32)) 
RETURNS nvarchar(32) 
WITH RETURNS NULL ON NULL INPUT
AS 
/* ============================================================================================
Proposito: Aplica formato a la fecha y la retorna como texto.
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2011-01-31
Fecha actualizacion: 2020-07-15

Parametros:
 @date: Fecha a ser formateada.
 @formatMask: Mascara de formato.  

Retorno: Retorna la fecha en formato texto.

Ejemplo:
SELECT [Utility].[DateFormat] (getdate(), 'MM/DD/YYYY')           -- 01/03/2012
SELECT [Utility].[DateFormat] (getdate(), 'DD/MM/YYYY')           -- 03/01/2012
SELECT [Utility].[DateFormat] (getdate(), 'M/DD/YYYY')            -- 1/03/2012
SELECT [Utility].[DateFormat] (getdate(), 'M/D/YYYY')             -- 1/3/2012
SELECT [Utility].[DateFormat] (getdate(), 'M/D/YY')               -- 1/3/12
SELECT [Utility].[DateFormat] (getdate(), 'MM/DD/YY')             -- 01/03/12
SELECT [Utility].[DateFormat] (getdate(), 'MON DD, YYYY')         -- JAN 03, 2012
SELECT [Utility].[DateFormat] (getdate(), 'Mon DD, YYYY')         -- Jan 03, 2012
SELECT [Utility].[DateFormat] (getdate(), 'Month DD, YYYY')       -- January 03, 2012
SELECT [Utility].[DateFormat] (getdate(), 'YYYY/MM/DD')           -- 2012/01/03
SELECT [Utility].[DateFormat] (getdate(), 'YYYYMMDD')             -- 20120103
SELECT [Utility].[DateFormat] (getdate(), 'YYYY-MM-DD')           -- 2012-01-03
SELECT [Utility].[DateFormat] (CURRENT_TIMESTAMP,'YY.MM.DD')      -- 12.01.03
============================================================================================ */
BEGIN 
 DECLARE @textoDate nvarchar(32) 

 SET @textoDate = @formatMask
 
 IF (CHARINDEX ('YYYY', @textoDate) > 0)
    SET @textoDate = REPLACE(@textoDate, 'YYYY', DATENAME(YY, @date))
 IF (CHARINDEX ('YY',@textoDate) > 0)
    SET @textoDate = REPLACE(@textoDate, 'YY', RIGHT(DATENAME(YY, @date),2))
 IF (CHARINDEX ('Month',@textoDate) > 0)
    SET @textoDate = REPLACE(@textoDate, 'Month', DATENAME(MM, @date))
 IF (CHARINDEX ('MON', @textoDate COLLATE SQL_Latin1_General_CP1_CS_AS) > 0)
    SET @textoDate = REPLACE(@textoDate, 'MON', LEFT(UPPER(DATENAME(MM, @date)),3))
 IF (CHARINDEX ('Mon',@textoDate) > 0)
    SET @textoDate = REPLACE(@textoDate, 'Mon', LEFT(DATENAME(MM, @date),3))
 IF (CHARINDEX ('MM',@textoDate) > 0)
    SET @textoDate = REPLACE(@textoDate, 'MM', 
      RIGHT('0' + CONVERT(nvarchar,DATEPART(MM, @date)),2))
 IF (CHARINDEX ('M',@textoDate) > 0)
    SET @textoDate = REPLACE(@textoDate, 'M', CONVERT(nvarchar,DATEPART(MM, @date)))
 IF (CHARINDEX ('DD',@textoDate) > 0)
    SET @textoDate = REPLACE(@textoDate, 'DD', RIGHT('0'+DATENAME(DD, @date),2))
 IF (CHARINDEX ('D',@textoDate) > 0)
    SET @textoDate = REPLACE(@textoDate, 'D', DATENAME(DD, @date)) 

RETURN @textoDate

END
GO

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[GetDateDiffToString]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
 EXEC('CREATE FUNCTION [Utility].[GetDateDiffToString] (@dateStart datetime, @dateEnd datetime)
RETURNS nvarchar(50)
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN
 RETURN ('''');
END');
GO

ALTER FUNCTION [Utility].[GetDateDiffToString] (@dateStart datetime, @dateEnd datetime)
RETURNS nvarchar(50)
WITH RETURNS NULL ON NULL INPUT
AS
/* ============================================================================================
Proposito: Retorna la duración entre dos fechas en formato: # Dias # Horas # Minutos # Segundos.
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2011-01-31
Fecha actualizacion: 2020-07-15

Parametros:  
 @dateStart: Fecha inicial
 @dateEnd: Fecha final

Retorno:
 Duración en formato: # Dias # Horas # Minutos # Segundos
 
Ejemplo:
 Select [Utility].[GetDateDiffToString] (GetDate(), GetDate() + 1.5)
============================================================================================ */
BEGIN
   Declare @intDias	int
   Declare @intHoras	int
   Declare @intMinutos	int
   Declare @intSegundos	int
   Declare @strDuracion  nvarchar(50)

   SET @intDias = CONVERT(INT, DATEDIFF(ss, @dateStart, @dateEnd)/(24*60*60))
   SET @intHoras = CONVERT(INT, DATEDIFF(ss, @dateStart, @dateEnd)/(60*60)) - (@intDias * 24)
   SET @intMinutos = CONVERT(INT, DATEDIFF(ss, @dateStart, @dateEnd)/60) - (@intHoras * 60) - (@intDias * 24 * 60)
   SET @intSegundos = DATEDIFF(ss, @dateStart, @dateEnd) - (@intMinutos * 60) - (@intHoras * 60 * 60) - (@intDias * 24 * 3600)

   SET @strDuracion = ''
   IF @intDias <> 0  SET @strDuracion = CONVERT(nvarchar, @intDias) + ' Dias '
   SET @strDuracion = @strDuracion + CONVERT(nvarchar, @intHoras) + ' Horas '
   SET @strDuracion = @strDuracion + CONVERT(nvarchar, @intMinutos) + ' Minutos '
   SET @strDuracion = @strDuracion + CONVERT(nvarchar, @intSegundos) + ' Segundos'

   RETURN(@strDuracion)
END
GO

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[GetDateParts]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
 EXEC('CREATE FUNCTION [Utility].[GetDateParts](@date date)
RETURNS @tableResult TABLE 
(
  [DateKey] int, [Date] date, [DateDesc] nvarchar(10), [Year] smallint, [Half] smallint, [HalfDesc] nvarchar(15), 
  [Quarter] smallint, [QuarterDesc] nvarchar(15), [Month] smallint, [MonthName] nvarchar (10), [MonthNameShort] nvarchar (3), [MonthDesc] nvarchar (15), 
  [MonthDescShort] nvarchar (8), [WeekYear] smallint, [WeekYearDesc] nvarchar(15), [Day] smallint, [DayYear] smallint, [DayWeek] smallint, 
  [DayName] nvarchar(10), [DayNameShort] nchar(3), [DayType] nvarchar(10), [Fortnight] smallint
)
AS
BEGIN
 RETURN;
END');
GO

ALTER FUNCTION [Utility].[GetDateParts](@date date)
RETURNS @tableResult TABLE 
(
  [DateKey] int, [Date] date, [DateDesc] nvarchar(10), [Year] smallint, [Half] smallint, [HalfDesc] nvarchar(15), 
  [Quarter] smallint, [QuarterDesc] nvarchar(15), [Month] smallint, [MonthName] nvarchar (10), [MonthNameShort] nvarchar (3), [MonthDesc] nvarchar (15), 
  [MonthDescShort] nvarchar (8), [WeekYear] smallint, [WeekYearDesc] nvarchar(15), [Day] smallint, [DayYear] smallint, [DayWeek] smallint, 
  [DayName] nvarchar(10), [DayNameShort] nchar(3), [DayType] nvarchar(10), [Fortnight] smallint
)
AS 
/* ============================================================================================
Proposito: Retorna las diferentes partes de una fecha.  Antes de ejecutar debe establecer el primer dia de la semana: SET DATEFIRST 1.
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2011-01-31
Fecha actualizacion: 2020-07-15

Parametros:
 @date: Fecha a ser divida en partes
 
Retorno: 
 DateKey: Entero que representa la fecha en formato: YYYYMMDD
 Date: Fecha suministrada, como tipo de dato date
 DateDesc: Descripción fecha: YYYY-MM-DD
 Year: Número año 
 Half: Número semestre
 HalfDesc: Descripción semestre: 2011-Semestre1
 Quarter: Número trimestre
 Quarter: Descripción trimestre: 2011-Trim1
 Month: Número de mes
 MonthName: Nombre del mes: Junio
 MonthNameShort: Nombre del mes abrebiado a 3 letras: Jun
 MonthDesc: Descripción del mes: 2011-Junio
 MonthDescShort: Descripción del mes, pero el mes abreviado a 3 letras: 2011-Jun
 WeekYear: Semana del año 
 WeekYearDesc: Descripción semana del año: 2011-Semana01
 Day: Número de día 
 DayYear: Número de día del año
 DayWeek: Número de día de la semana (entre 1 y 7)
 DayName: Nombre del día (Lunes, Martes, ...)
 DayNameShort: Nombre del día abreviado a 3 letras (Lun, Mar, ...)
 DayType: Tipo de día: Habil, No habil, Festivo
 Fortnight: Número de quincena

Ejemplo:
 SET DATEFIRST 1 
 Select * from [Utility].[GetDateParts] (GetDate())
 SET DATEFIRST 5 
 Select * from [Utility].[GetDateParts] ('20091231')
============================================================================================ */
BEGIN
 declare @year smallint, @half smallint, @quarter smallint, @month2 smallint, @month smallint,  @monthName nvarchar (10), @monthDesc nvarchar (15);
 Declare @weekYear smallint, @dayType nvarchar(10), @dayName nvarchar(10), @dayWeek smallint;
 
-- SET DATEFIRST 1 -- Primer dia de la semana lunes (no permitido en funciones) 
 set @year = year(@date)
 set @half = CASE WHEN Month(@date) Between 1 and 6 Then 1 Else 2 End;
 set @quarter = DATEPART(quarter, @date)
 
 set @month2 = CASE 
  WHEN Month(@date) Between 1 and 2 Then 1
  WHEN Month(@date) Between 3 and 4 Then 2
  WHEN Month(@date) Between 5 and 6 Then 3
  WHEN Month(@date) Between 7 and 8 Then 4
  WHEN Month(@date) Between 9 and 10 Then 5
  Else 6 End;
  
 set @month = Month(@date);
 set @monthName = CASE @month 
  When 1	Then 'Enero'
  When 2	Then 'Febrero'
  When 3	Then 'Marzo'
  When 4	Then 'Abril'
  When 5	Then 'Mayo'
  When 6	Then 'Junio'
  When 7	Then 'Julio'
  When 8	Then 'Agosto'
  When 9	Then 'Septiembre'
  When 10	Then 'Octubre'
  When 11	Then 'Noviembre'
  When 12   Then 'Diciembre'
  Else Null End; 
 set @monthDesc = Convert(nvarchar, @year) + '-' + @monthName; 
 
 set @weekYear = DATEPART (wk, @date); 
 Select @dayType = [Type] From [Utility].[SpecialDate] WITH (NOLOCK) Where [DateId] = @date;
 If (@dayType IS NULL)
 begin  
  set @dayType = CASE When DATEPART (dw, @date) Between 1 and 5 Then 'Habil' Else 'No habil' End; 
 end 

-- set @dayWeek = DATEPART (dw, @date) ... (depende de DATEFIRST)
 set @dayWeek = (DATEDIFF(day, 0, @date) % 7) + 1
 set @dayName = Case @dayWeek
  When 1	Then 'Lunes'
  When 2	Then 'Martes'
  When 3	Then 'Miercoles'
  When 4	Then 'Jueves'
  When 5	Then 'Viernes'
  When 6	Then 'Sabado'
  When 7	Then 'Domingo'
  Else Null End;
 
 INSERT INTO @tableResult ([DateKey], [Date], [DateDesc], [Year], [Half], [HalfDesc], [Quarter], [QuarterDesc], [Month], [MonthName], [MonthNameShort], 
  [MonthDesc], [MonthDescShort], [WeekYear], [WeekYearDesc], [Day], [DayYear], [DayWeek], [DayName], [DayNameShort], [DayType], [Fortnight]) 
 Values (Convert(int, Convert(nvarchar(10), @date, 112)), @date, Convert(nvarchar(10), @date, 120), @year
 , @half, Convert(nvarchar, @year) + '-' + 'Semestre' + Convert(nvarchar(1), @half)
 , @quarter, Convert(nvarchar, @year)  + '-' + 'Trim' + Convert(nvarchar(1), @quarter)
 , @month, @monthName, Left(@monthName, 3), @monthDesc, Left(@monthDesc, 8)
 , @weekYear, Convert(nvarchar, @year) + '-' + 'Semana' + Right('0' + Convert(nvarchar(2), @weekYear), 2)
 , day(@date), datepart(DAYOFYEAR, @date), @dayWeek, @dayName, Left(@dayName, 3), @dayType
 , CASE WHEN Day(@date) Between 1 and 15 Then 1 Else 2 End)
 
 RETURN;
END;
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'FUNCTION',N'GetDateParts', N'COLUMN',N'dateKey'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Entero que representa la fecha en formato: YYYYMMDD' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'FUNCTION',@level1name=N'GetDateParts', @level2type=N'COLUMN',@level2name=N'dateKey'
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'FUNCTION',N'GetDateParts', N'PARAMETER',N'@date'))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha a ser divida en partes' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'FUNCTION',@level1name=N'GetDateParts', @level2type=N'PARAMETER',@level2name=N'@date'
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'SCHEMA',N'Utility', N'FUNCTION',N'GetDateParts', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Retorna las diferentes partes de una fecha.  Antes de ejecutar debe establecer el primer dia de la semana: SET DATEFIRST 1.' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'FUNCTION',@level1name=N'GetDateParts'
GO


IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[GetTimeParts]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
 EXEC('CREATE FUNCTION [Utility].[GetTimeParts] ()
RETURNS @tableResult TABLE 
(
	[TimeKey] [int] NOT NULL,
	[Time] [time](0) NOT NULL,
	[Time24Id] [nvarchar](8) NOT NULL,
	[Time12Id] [nvarchar](8) NOT NULL,
	[Hour24] [smallint] NOT NULL,
	[Period] [smallint] NOT NULL,
	[Hour24Short] [nvarchar](2) NOT NULL,
	[Hour24Min] [nvarchar](5) NOT NULL,
	[Hour24Full] [nvarchar](8) NOT NULL,
	[Hour12] [smallint] NOT NULL,
	[Hour12Short] [nvarchar](2) NOT NULL,
	[Hour12Min] [nvarchar](5) NOT NULL,
	[Hour12Full] [nvarchar](8) NOT NULL,
	[MinuteId] [smallint] NOT NULL,
	[Minute] [smallint] NOT NULL,
	[MinuteShort] [nvarchar](2) NOT NULL,
	[MinuteFull24] [nvarchar](8) NOT NULL,
	[MinuteFull12] [nvarchar](8) NOT NULL,
	[Second] [smallint] NOT NULL,
	[SecondShort] [nvarchar](2) NOT NULL,
	[IsAmPm] [bit] NOT NULL,
	[AmPm] [nvarchar](2) NOT NULL,
	[QuarterHourId] [smallint] NOT NULL,
	[QuarterHour] [smallint] NOT NULL,
	[QuarterHourShort] [nvarchar](2) NOT NULL,
	[QuarterHourFull24] [nvarchar](8) NOT NULL,
	[QuarterHourFull12] [nvarchar](8) NOT NULL
)
AS
BEGIN
 RETURN;
END');
GO

ALTER FUNCTION [Utility].[GetTimeParts]()
RETURNS @tableResult TABLE 
(
	[TimeKey] [int] NOT NULL,
	[Time] [time](0) NOT NULL,
	[Time24Id] [nvarchar](8) NOT NULL,
	[Time12Id] [nvarchar](8) NOT NULL,
	[Hour24] [smallint] NOT NULL,
	[Period] [smallint] NOT NULL,
	[Hour24Short] [nvarchar](2) NOT NULL,
	[Hour24Min] [nvarchar](5) NOT NULL,
	[Hour24Full] [nvarchar](8) NOT NULL,
	[Hour12] [smallint] NOT NULL,
	[Hour12Short] [nvarchar](2) NOT NULL,
	[Hour12Min] [nvarchar](5) NOT NULL,
	[Hour12Full] [nvarchar](8) NOT NULL,
	[MinuteId] [smallint] NOT NULL,
	[Minute] [smallint] NOT NULL,
	[MinuteShort] [nvarchar](2) NOT NULL,
	[MinuteFull24] [nvarchar](8) NOT NULL,
	[MinuteFull12] [nvarchar](8) NOT NULL,
	[Second] [smallint] NOT NULL,
	[SecondShort] [nvarchar](2) NOT NULL,
	[IsAmPm] [bit] NOT NULL,
	[AmPm] [nvarchar](2) NOT NULL,
	[QuarterHourId] [smallint] NOT NULL,
	[QuarterHour] [smallint] NOT NULL,
	[QuarterHourShort] [nvarchar](2) NOT NULL,
	[QuarterHourFull24] [nvarchar](8) NOT NULL,
	[QuarterHourFull12] [nvarchar](8) NOT NULL
)
AS 
/* ============================================================================================
Proposito: Retorna las diferentes partes de las horas de un día.
 Con granularidad de segundos. Numero de miembros: 24 horas * 60 Minutos * 60 Segundos = 86400.
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2016-06-24
Fecha actualizacion: 2016-06-24

Retorno: 
 [TimeKey]: Clave subrogada tiempo para identificar un registro, en formato: HHmmss, consecutivo de 0 a 235959.
 [Time]: Tiempo como tipo de datos: Time, con milisegundos truncados.
 [Time24Id]: Tiempo texto en formato de 24 horas: HH:mm:ss, de 00:00:00 a 23:59:59
 [Time12Id]: Tiempo texto en formato de 12 horas: hh:mm:ss, de 00:00:00 a 11:59:59.
 [Hour24]: Hora como número en formato de 24 horas, de 0 a 23.
 [Period]: Periodo de 1 a 24, representan las horas.
 [Hour24Short]: Hora como texto en formato de 24 horas, de 00 a 23.
 [Hour24Min]: Hora con minutos truncados en formato de 24 horas, de 00:00 a 23:00.
 [Hour24Full]: Hora con minutos y segundos truncados en formato de 24 horas, de 00:00:00 a 23:00:00.
 [Hour12]: Hora como número en formato de 12 horas, de 0 a 11.
 [Hour12Short]: Hora como texto en formato de 12 horas, de 00 a 11.
 [Hour12Min]: Hora con minutos truncados en formato de 12 horas, de 00:00 a 11:00.
 [Hour12Full]: Hora con minutos y segundos truncaddos en formato de 12 horas, de 00:00:00 a 11:00:00.
 [MinuteId]: Codigo de minutos: (hora * 100) + minutos. Formato: HHmm, de 0 a 2359.
 [Minute]: Minutos como número, de 0 a 59.
 [MinuteShort]: Minutos como texto, de 00 a 59.
 [MinuteFull24]: Minutos como texto con hora en formato de 24 horas y segundos truncados, de 00:00:00 a 23:59:00.
 [MinuteFull12]: Minutos como texto con hora en formato de 12 horas y segundos truncados, de 00:00:00 a 11:59:00.
 [Second]: Segundos como número, de 0 a 59.
 [SecondShort]: Segundos como texto, de 00 a 59.
 [IsAmPm]: Indica si es en las horas de la mañana (0: AM) o de la tarde (1: PM).
 [AmPm]: Texto que indica si es en las horas de la mañana (AM) o de la tarde (PM).
 [QuarterHourId]: Codigo de tiempo divido en cuartos (15 minutos): (houra * 100) + ((minutos / 15) * 15). Formato: HHmm, de 0 a 2345.
 [QuarterHour]: Tiempo divido en cuartos (15 minutos): minutos / 15. De 0 a 3.
 [QuarterHourShort]: Tiempo divido en cuartos (15 minutos) como texto. Formato: mm, de 00 a 45.
 [QuarterHourFull24]: Tiempo divido en cuartos (15 minutos). Formato de 24 horas con segundos truncados: HH:mm:00, de 00:00:00 a 23:45:00.
 [QuarterHourFull12]: Tiempo divido en cuartos (15 minutos). Formato de 12 horas con segundos truncados: HH:mm:00, de 00:00:00 a 11:45:00.
 
Ejemplo:
Select * from [Utility].[GetTimeParts] () ORDER BY [TimeKey];
============================================================================================ */
BEGIN
 Declare @hour int, @minute int, @second int;

 set @hour = 0;
 while (@hour < 24)
 begin
  set @minute = 0;
  while (@minute < 60)
  begin
   set @second=0;
   while (@second < 60)
   begin
    INSERT INTO @tableResult ([TimeKey],[Time],[Time24Id],[Time12Id],[Hour24],[Period],[Hour24Short],[Hour24Min],[Hour24Full],[Hour12]
	 ,[Hour12Short],[Hour12Min],[Hour12Full],[MinuteId],[Minute],[MinuteShort],[MinuteFull24],[MinuteFull12]
	 ,[Second],[SecondShort],[IsAmPm],[AmPm],[QuarterHourId],[QuarterHour],[QuarterHourShort],[QuarterHourFull24],[QuarterHourFull12])
    SELECT 
	 (@hour*10000) + (@minute*100) + @second as TimeKey
	 ,convert(time,right('0'+convert(nvarchar(2),@hour),2)+':' + right('0'+convert(nvarchar(2),@minute),2)+':' + right('0'+convert(nvarchar(2),@second),2)) as [Time]
	 ,right('0'+convert(nvarchar(2),@hour),2)+':' + right('0'+convert(nvarchar(2),@minute),2)+':' + right('0'+convert(nvarchar(2),@second),2) [Time24Id]
	 ,right('0'+convert(nvarchar(2),@hour%12),2)+':' + right('0'+convert(nvarchar(2),@minute),2)+':' + right('0'+convert(nvarchar(2),@second),2) [Time12Id]
	 ,@hour as [Hour24]
	 ,@hour + 1 as [Period]
	 ,right('0'+convert(nvarchar(2),@hour),2) [Hour24Short]
	 ,right('0'+convert(nvarchar(2),@hour),2)+':00' [Hour24Min]
	 ,right('0'+convert(nvarchar(2),@hour),2)+':00:00' [Hour24Full]
	 ,@hour%12 as [Hour12]
	 ,right('0'+convert(nvarchar(2),@hour%12),2) [Hour12Short]
	 ,right('0'+convert(nvarchar(2),@hour%12),2)+':00' [Hour12Min]
	 ,right('0'+convert(nvarchar(2),@hour%12),2)+':00:00' [Hour12Full]
	 ,(@hour*100) + (@minute) [MinuteId]
	 ,@minute as [Minute]
	 ,right('0'+convert(nvarchar(2),@minute),2) [MinuteShort]
	 ,right('0'+convert(nvarchar(2),@hour),2)+':' + right('0'+convert(nvarchar(2),@minute),2)+':00' [MinuteFull24]
	 ,right('0'+convert(nvarchar(2),@hour%12),2)+':' + right('0'+convert(nvarchar(2),@minute),2)+':00' [MinuteFull12]
	 ,@second as [Second]
	 ,right('0'+convert(nvarchar(2),@second),2) [SecondShort]
	 ,@hour / 12 as [IsAmPm]
	 ,case when @hour < 12 then 'AM' else 'PM' end as [AmPm]
	 ,(@hour * 100) + ((@minute / 15) * 15) [QuarterHourId]
	 ,@minute / 15 as [QuarterHour]
	 ,right('0'+convert(nvarchar(2),((@minute/15)*15)),2) [QuarterHourShort]
	 ,right('0'+convert(nvarchar(2),@hour),2)+':' + right('0'+convert(nvarchar(2),((@minute/15)*15)),2)+':00' [QuarterHourFull24]
	 ,right('0'+convert(nvarchar(2),@hour%12),2)+':' + right('0'+convert(nvarchar(2),((@minute/15)*15)),2)+':00' [QuarterHourFull12];
     
    set @second = @second + 1;
   end
   set @minute = @minute + 1;
  end
  set @hour = @hour + 1;
 end
 
 RETURN;
END;
GO


IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[GetTimeHourParts]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
 EXEC('CREATE FUNCTION [Utility].[GetTimeHourParts] ()
RETURNS @tableResult TABLE 
(
	[TimeKey] [int] NOT NULL,
	[Time] [time](0) NOT NULL,
	[Time24Id] [nvarchar](8) NOT NULL,
	[Time12Id] [nvarchar](8) NOT NULL,
	[Hour24] [smallint] NOT NULL,
	[Period] [smallint] NOT NULL,
	[Hour24Short] [nvarchar](2) NOT NULL,
	[Hour24Min] [nvarchar](5) NOT NULL,
	[Hour24Full] [nvarchar](8) NOT NULL,
	[Hour12] [smallint] NOT NULL,
	[Hour12Short] [nvarchar](2) NOT NULL,
	[Hour12Min] [nvarchar](5) NOT NULL,
	[Hour12Full] [nvarchar](8) NOT NULL,
	[IsAmPm] [bit] NOT NULL,
	[AmPm] [nvarchar](2) NOT NULL
)
AS
BEGIN
 RETURN;
END');
GO

ALTER FUNCTION [Utility].[GetTimeHourParts]()
RETURNS @tableResult TABLE 
(
	[TimeKey] [int] NOT NULL,
	[Time] [time](0) NOT NULL,
	[Time24Id] [nvarchar](8) NOT NULL,
	[Time12Id] [nvarchar](8) NOT NULL,
	[Hour24] [smallint] NOT NULL,
	[Period] [smallint] NOT NULL,
	[Hour24Short] [nvarchar](2) NOT NULL,
	[Hour24Min] [nvarchar](5) NOT NULL,
	[Hour24Full] [nvarchar](8) NOT NULL,
	[Hour12] [smallint] NOT NULL,
	[Hour12Short] [nvarchar](2) NOT NULL,
	[Hour12Min] [nvarchar](5) NOT NULL,
	[Hour12Full] [nvarchar](8) NOT NULL,
	[IsAmPm] [bit] NOT NULL,
	[AmPm] [nvarchar](2) NOT NULL
)
AS 
/* ============================================================================================
Proposito: Retorna las diferentes partes de las horas de un día.
 Con granularidad de horas. Numero de miembros: 24.
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2016-06-24
Fecha actualizacion: 2016-06-24

Retorno: 
 [TimeKey]: Clave subrogada tiempo para identificar un registro, en formato: HHmmss, consecutivo de 0 a 235959.
 [Time]: Tiempo como tipo de datos: Time, con milisegundos truncados.
 [Time24Id]: Tiempo texto en formato de 24 horas: HH:mm:ss, de 00:00:00 a 23:59:59
 [Time12Id]: Tiempo texto en formato de 12 horas: hh:mm:ss, de 00:00:00 a 11:59:59.
 [Hour24]: Hora como número en formato de 24 horas, de 0 a 23.
 [Period]: Periodo de 1 a 24, representan las horas.
 [Hour24Short]: Hora como texto en formato de 24 horas, de 00 a 23.
 [Hour24Min]: Hora con minutos truncados en formato de 24 horas, de 00:00 a 23:00.
 [Hour24Full]: Hora con minutos y segundos truncados en formato de 24 horas, de 00:00:00 a 23:00:00.
 [Hour12]: Hora como número en formato de 12 horas, de 0 a 11.
 [Hour12Short]: Hora como texto en formato de 12 horas, de 00 a 11.
 [Hour12Min]: Hora con minutos truncados en formato de 12 horas, de 00:00 a 11:00.
 [Hour12Full]: Hora con minutos y segundos truncaddos en formato de 12 horas, de 00:00:00 a 11:00:00.
 [IsAmPm]: Indica si es en las horas de la mañana (0: AM) o de la tarde (1: PM).
 [AmPm]: Texto que indica si es en las horas de la mañana (AM) o de la tarde (PM).
 
Ejemplo:
Select * from [Utility].[GetTimeHourParts] () ORDER BY [TimeKey];
============================================================================================ */
BEGIN
 Declare @hour int, @minute int, @second int;

 set @hour = 0;
 set @minute = 0;
 set @second = 0;
 while (@hour < 24)
 begin
    INSERT INTO @tableResult ([TimeKey],[Time],[Time24Id],[Time12Id],[Hour24],[Period],[Hour24Short],[Hour24Min],[Hour24Full],[Hour12]
	 ,[Hour12Short],[Hour12Min],[Hour12Full],[IsAmPm],[AmPm])
    SELECT 
	 @hour as TimeKey
	 ,convert(time,right('0'+convert(nvarchar(2),@hour),2)+':' + right('0'+convert(nvarchar(2),@minute),2)+':' + right('0'+convert(nvarchar(2),@second),2)) as [Time]
	 ,right('0'+convert(nvarchar(2),@hour),2)+':' + right('0'+convert(nvarchar(2),@minute),2)+':' + right('0'+convert(nvarchar(2),@second),2) [Time24Id]
	 ,right('0'+convert(nvarchar(2),@hour%12),2)+':' + right('0'+convert(nvarchar(2),@minute),2)+':' + right('0'+convert(nvarchar(2),@second),2) [Time12Id]
	 ,@hour as [Hour24]
	 ,@hour + 1 as [Period]
	 ,right('0'+convert(nvarchar(2),@hour),2) [Hour24Short]
	 ,right('0'+convert(nvarchar(2),@hour),2)+':00' [Hour24Min]
	 ,right('0'+convert(nvarchar(2),@hour),2)+':00:00' [Hour24Full]
	 ,@hour%12 as [Hour12]
	 ,right('0'+convert(nvarchar(2),@hour%12),2) [Hour12Short]
	 ,right('0'+convert(nvarchar(2),@hour%12),2)+':00' [Hour12Min]
	 ,right('0'+convert(nvarchar(2),@hour%12),2)+':00:00' [Hour12Full]
	 ,@hour / 12 as [IsAmPm]
	 ,case when @hour < 12 then 'AM' else 'PM' end as [AmPm]
     
  set @hour = @hour + 1;
 end
 
 RETURN;
END;
GO

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - End script: A10SP_Util_Date.sql'
PRINT '------------------------------------------------------------------------'
GO