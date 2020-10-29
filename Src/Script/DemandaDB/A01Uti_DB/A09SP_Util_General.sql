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
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - Start script: A09SP_Util_General.sql'
PRINT '------------------------------------------------------------------------'
GO

USE [$(DATABASE_NAME_DW)];

/* ========================================================================== 
Funciones generales
========================================================================== */
IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[ConvertUTF8String]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
 EXEC('CREATE FUNCTION [Utility].[ConvertUTF8String] (@value nvarchar(MAX))
RETURNS nvarchar(max)
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN
 RETURN('''');
END');
GO
ALTER FUNCTION [Utility].[ConvertUTF8String] (@value nvarchar(max))
RETURNS nvarchar(max)
AS
/* ============================================================================================
Proposito: Convierte caracteres UTF8 a ANSI
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2016-04-01
Fecha actualizacion: 2020-07-15

Parametros:
 @value: Texto a ser convertido

Ejemplo:
Select [Utility].[ConvertUTF8String] ('BOGOT? GUTI?RREZ JUN?N ?TICA ÐÐÐ ËËË');
Select [Utility].[ConvertUTF8String] ('BOGOT- GUTI+RREZ JUN-N +TICA ??? ??');
============================================================================================ */
BEGIN
    -- Transforms a UTF-8 encoded varchar string into Unicode, By Anthony Faull 2014-07-31
    DECLARE @result nvarchar(max);

    -- If ASCII or null there's no work to do
    IF (@value IS NULL
        OR @value NOT LIKE '%[^ -~]%' COLLATE Latin1_General_BIN
    )
        RETURN @value;

    -- Generate all integers from 1 to the length of string
    WITH e0(n) AS (SELECT TOP(POWER(2,POWER(2,0))) NULL FROM (VALUES (NULL),(NULL)) e(n))
        , e1(n) AS (SELECT TOP(POWER(2,POWER(2,1))) NULL FROM e0 CROSS JOIN e0 e)
        , e2(n) AS (SELECT TOP(POWER(2,POWER(2,2))) NULL FROM e1 CROSS JOIN e1 e)
        , e3(n) AS (SELECT TOP(POWER(2,POWER(2,3))) NULL FROM e2 CROSS JOIN e2 e)
        , e4(n) AS (SELECT TOP(POWER(2,POWER(2,4))) NULL FROM e3 CROSS JOIN e3 e)
        , e5(n) AS (SELECT TOP(POWER(2.,POWER(2,5)-1)-1) NULL FROM e4 CROSS JOIN e4 e)
    , numbers(position) AS
    (
        SELECT TOP(DATALENGTH(@value)) ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
        FROM e5
    )
    -- UTF-8 Algorithm (http://en.wikipedia.org/wiki/UTF-8)
    -- For each octet, count the high-order one bits, and extract the data bits.
    , octets AS
    (
        SELECT position, highorderones, partialcodepoint
        FROM numbers a
        -- Split UTF8 string into rows of one octet each.
        CROSS APPLY (SELECT octet = ASCII(SUBSTRING(@value, position, 1))) b
        -- Count the number of leading one bits
        CROSS APPLY (SELECT highorderones = 8 - FLOOR(LOG( ~CONVERT(tinyint, octet) * 2 + 1)/LOG(2))) c
        CROSS APPLY (SELECT databits = 7 - highorderones) d
        CROSS APPLY (SELECT partialcodepoint = octet % POWER(2, databits)) e
    )
    -- Compute the Unicode codepoint for each sequence of 1 to 4 bytes
    , codepoints AS
    (
        SELECT position, codepoint
        FROM
        (
            -- Get the starting octect for each sequence (i.e. exclude the continuation bytes)
            SELECT position, highorderones, partialcodepoint
            FROM octets
            WHERE highorderones <> 1
        ) lead
        CROSS APPLY (SELECT sequencelength = CASE WHEN highorderones in (1,2,3,4) THEN highorderones ELSE 1 END) b
        CROSS APPLY (SELECT endposition = position + sequencelength - 1) c
        CROSS APPLY
        (
            -- Compute the codepoint of a single UTF-8 sequence
            SELECT codepoint = SUM(POWER(2, shiftleft) * partialcodepoint)
            FROM octets
            CROSS APPLY (SELECT shiftleft = 6 * (endposition - position)) b
            WHERE position BETWEEN lead.position AND endposition
        ) d
    )
    -- Concatenate the codepoints into a Unicode string
    SELECT @result = CONVERT(xml,
        (
            SELECT NCHAR(codepoint)
            FROM codepoints
            ORDER BY position
            FOR XML PATH('')
        )).value('.', 'nvarchar(max)');

    RETURN @result;
END
GO

 
IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[ConvertUTF8Ansi]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
 EXEC('CREATE FUNCTION [Utility].[ConvertUTF8Ansi] (@value nvarchar(MAX))
RETURNS nvarchar(max)
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN
 RETURN('''');
END');
GO
ALTER FUNCTION [Utility].[ConvertUTF8Ansi]
(
	@value nvarchar(MAX)
)
RETURNS nvarchar(MAX)
AS
/* ============================================================================================
Proposito: Convierte caracteres UTF8 a ANSI
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2016-04-01
Fecha actualizacion: 2020-07-15

Parametros:
 @value: Texto a ser convertido

Ejemplo:
Select [Utility].[ConvertUTF8Ansi] ('BOGOT? GUTI?RREZ JUN?N ?TICA ÐÐÐ ËËË');
Select [Utility].[ConvertUTF8Ansi] ('BOGOT- GUTI+RREZ JUN-N +TICA ??? ??');
============================================================================================ */
BEGIN
 DECLARE @i SMALLINT = 160, @Utf8 CHAR(2),	@Ansi CHAR(1);

 WHILE (@i <= 255)
 BEGIN
  SELECT @Utf8 = CASE
				WHEN @i BETWEEN 160 AND 191 THEN CHAR(194) + CHAR(@i)
				WHEN @i BETWEEN 192 AND 255 THEN CHAR(195) + CHAR(@i - 64)
				ELSE NULL END,
		@Ansi = CHAR(@i)

  WHILE (CHARINDEX(@value, @Utf8) > 0)
  begin
   SET @value = REPLACE(@value, @Utf8, @Ansi);
  end;

  SET @i += 1
 END;

 RETURN	@value
END;
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[PrintLongText]') AND type in (N'P', N'PC'))
BEGIN
 EXEC dbo.sp_EXECUTEsql @statement = N'CREATE PROCEDURE [Utility].[PrintLongText] AS' 
END;
GO
ALTER PROCEDURE [Utility].[PrintLongText] @msg nvarchar(max), @xmlOutput bit = 0 
AS 
/* ============================================================================================
Proposito: Imprime en pantalla textos nvarchar(max) o nvarchar(max). 
 Resuelve el problema de la presentación en pantalla que esta limitada a una longitud maxima.
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2015-05-01
Fecha actualizacion: 2020-07-15

Parametros:
 @msg: Texto a ser presentado.
 @xmlOutput: Indica si la salida es como texto o XML.
  0: La salida es un texto.
  1: La salida es XML.

Ejemplo:
 declare @text nvarchar(max);
 set @text = '';
 set @text = @text +
'<Batch ProcessAffectedObjects="true" xmlns="http://schemas.microsoft.com/analysisservices/2003/engine"> ' + CHAR(13) + CHAR(10) + 
'	<Parallel> ' + CHAR(13) + CHAR(10) + 
'		<Process xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ddl2="http://schemas.microsoft.com/analysisservices/2003/engine/2" xmlns:ddl2_2="http://schemas.microsoft.com/analysisservices/2003/engine/2/2" xmlns:ddl100_100="http://schemas.microsoft.com/analysisservices/2008/engine/100/100" xmlns:ddl200="http://schemas.microsoft.com/analysisservices/2010/engine/200" xmlns:ddl200_200="http://schemas.microsoft.com/analysisservices/2010/engine/200/200" xmlns:ddl300="http://schemas.microsoft.com/analysisservices/2011/engine/300" xmlns:ddl300_300="http://schemas.microsoft.com/analysisservices/2011/engine/300/300" xmlns:ddl400="http://schemas.microsoft.com/analysisservices/2012/engine/400" xmlns:ddl400_400="http://schemas.microsoft.com/analysisservices/2012/engine/400/400"> ' + CHAR(13) + CHAR(10) + 
'			<Object> ' + CHAR(13) + CHAR(10) + 
'				<DatabaseID>MiBaseDatosOLAP</DatabaseID> ' + CHAR(13) + CHAR(10) + 
'				<DimensionID>DimDate</DimensionID> ' + CHAR(13) + CHAR(10) + 
'			</Object> ' + CHAR(13) + CHAR(10) + 
'			<Type>ProcessUpdate</Type> ' + CHAR(13) + CHAR(10) + 
'			<WriteBackTableCreation>UseExisting</WriteBackTableCreation> ' + CHAR(13) + CHAR(10) + 
'		</Process> ' + CHAR(13) + CHAR(10) + 
'		<Process xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ddl2="http://schemas.microsoft.com/analysisservices/2003/engine/2" xmlns:ddl2_2="http://schemas.microsoft.com/analysisservices/2003/engine/2/2" xmlns:ddl100_100="http://schemas.microsoft.com/analysisservices/2008/engine/100/100" xmlns:ddl200="http://schemas.microsoft.com/analysisservices/2010/engine/200" xmlns:ddl200_200="http://schemas.microsoft.com/analysisservices/2010/engine/200/200" xmlns:ddl300="http://schemas.microsoft.com/analysisservices/2011/engine/300" xmlns:ddl300_300="http://schemas.microsoft.com/analysisservices/2011/engine/300/300" xmlns:ddl400="http://schemas.microsoft.com/analysisservices/2012/engine/400" xmlns:ddl400_400="http://schemas.microsoft.com/analysisservices/2012/engine/400/400"> ' + CHAR(13) + CHAR(10) + 
'			<Object> ' + CHAR(13) + CHAR(10) + 
'				<DatabaseID>MiBaseDatosOLAP</DatabaseID> ' + CHAR(13) + CHAR(10) + 
'				<DimensionID>DimGeografia</DimensionID> ' + CHAR(13) + CHAR(10) + 
'			</Object> ' + CHAR(13) + CHAR(10) + 
'			<Type>ProcessUpdate</Type> ' + CHAR(13) + CHAR(10) + 
'			<WriteBackTableCreation>UseExisting</WriteBackTableCreation> ' + CHAR(13) + CHAR(10) + 
'		</Process> ' + CHAR(13) + CHAR(10) + 
'		<Process xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ddl2="http://schemas.microsoft.com/analysisservices/2003/engine/2" xmlns:ddl2_2="http://schemas.microsoft.com/analysisservices/2003/engine/2/2" xmlns:ddl100_100="http://schemas.microsoft.com/analysisservices/2008/engine/100/100" xmlns:ddl200="http://schemas.microsoft.com/analysisservices/2010/engine/200" xmlns:ddl200_200="http://schemas.microsoft.com/analysisservices/2010/engine/200/200" xmlns:ddl300="http://schemas.microsoft.com/analysisservices/2011/engine/300" xmlns:ddl300_300="http://schemas.microsoft.com/analysisservices/2011/engine/300/300" xmlns:ddl400="http://schemas.microsoft.com/analysisservices/2012/engine/400" xmlns:ddl400_400="http://schemas.microsoft.com/analysisservices/2012/engine/400/400"> ' + CHAR(13) + CHAR(10) + 
'			<Object> ' + CHAR(13) + CHAR(10) + 
'				<DatabaseID>MiBaseDatosOLAP</DatabaseID> ' + CHAR(13) + CHAR(10) + 
'				<DimensionID>DimGeografiaOperativa</DimensionID> ' + CHAR(13) + CHAR(10) + 
'			</Object> ' + CHAR(13) + CHAR(10) + 
'			<Type>ProcessUpdate</Type> ' + CHAR(13) + CHAR(10) + 
'			<WriteBackTableCreation>UseExisting</WriteBackTableCreation> ' + CHAR(13) + CHAR(10) + 
'		</Process> ' + CHAR(13) + CHAR(10) + 
'		<Process xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ddl2="http://schemas.microsoft.com/analysisservices/2003/engine/2" xmlns:ddl2_2="http://schemas.microsoft.com/analysisservices/2003/engine/2/2" xmlns:ddl100_100="http://schemas.microsoft.com/analysisservices/2008/engine/100/100" xmlns:ddl200="http://schemas.microsoft.com/analysisservices/2010/engine/200" xmlns:ddl200_200="http://schemas.microsoft.com/analysisservices/2010/engine/200/200" xmlns:ddl300="http://schemas.microsoft.com/analysisservices/2011/engine/300" xmlns:ddl300_300="http://schemas.microsoft.com/analysisservices/2011/engine/300/300" xmlns:ddl400="http://schemas.microsoft.com/analysisservices/2012/engine/400" xmlns:ddl400_400="http://schemas.microsoft.com/analysisservices/2012/engine/400/400"> ' + CHAR(13) + CHAR(10) + 
'			<Object> ' + CHAR(13) + CHAR(10) + 
'				<DatabaseID>MiBaseDatosOLAP</DatabaseID> ' + CHAR(13) + CHAR(10) + 
'				<DimensionID>DimCliente</DimensionID> ' + CHAR(13) + CHAR(10) + 
'			</Object> ' + CHAR(13) + CHAR(10) + 
'			<Type>ProcessUpdate</Type> ' + CHAR(13) + CHAR(10) + 
'			<WriteBackTableCreation>UseExisting</WriteBackTableCreation> ' + CHAR(13) + CHAR(10) + 
'		</Process> ' + CHAR(13) + CHAR(10) + 
'	</Parallel> ' + CHAR(13) + CHAR(10) + 
'</Batch>';

EXECUTE [Utility].[PrintLongText] @text, 1;
EXECUTE [Utility].[PrintLongText] @text, 0;
EXECUTE [Utility].[PrintLongText] NULL, 0;
============================================================================================ */
BEGIN 
 SET NOCOUNT ON; 
 DECLARE @MsgLen int, @CurrLineStartIdx int = 1, @CurrLineEndIdx int, @CurrLineLen int, @SkipCount int;

 if (@xmlOutput = 1)
 begin
  SELECT [processing-instruction(Root)]= @msg FOR XML PATH(''),TYPE;
  return;
 end;
 
 -- Normalise line end characters
 SET @msg = REPLACE(@msg, char(13) + char(10), char(10)); 
 SET @msg = REPLACE(@msg, char(13), char(10)); 
 
 -- Store length of the normalised string. 
 SET @MsgLen = LEN(@msg); 
 
 -- Special case: Empty string. 
 IF (@MsgLen = 0) 
 BEGIN 
  PRINT ''; 
  RETURN; 
 END 
 
 -- Find the end of next substring to print. 
 SET @CurrLineEndIdx = CHARINDEX(CHAR(10), @msg); 
 IF (@CurrLineEndIdx BETWEEN 1 AND 4000) 
 BEGIN 
  SET @CurrLineEndIdx = @CurrLineEndIdx - 1;
  SET @SkipCount = 2; 
 END 
 ELSE 
 BEGIN 
  SET @CurrLineEndIdx = 4000; 
  SET @SkipCount = 1; 
 END 
 
 -- Loop: Print current substring, identify next substring. 
 WHILE (@CurrLineStartIdx < @MsgLen)
 BEGIN 
  -- Print substring. 
  PRINT SUBSTRING(@msg, @CurrLineStartIdx, (@CurrLineEndIdx - @CurrLineStartIdx)+1); 
  
  -- Move to start of next substring. 
  SET @CurrLineStartIdx = @CurrLineEndIdx + @SkipCount; 
  
  -- Find the end of next substring to print. 
  SET @CurrLineEndIdx = CHARINDEX(CHAR(10), @msg, @CurrLineStartIdx); 
  SET @CurrLineLen = @CurrLineEndIdx - @CurrLineStartIdx; 
  
  -- Find bounds of next substring to print. 
  IF (@CurrLineLen BETWEEN 1 AND 4000) 
  BEGIN 
   SET @CurrLineEndIdx = @CurrLineEndIdx - 1;
   SET @SkipCount = 2; 
  END 
  ELSE 
  BEGIN 
   SET @CurrLineEndIdx = @CurrLineStartIdx + 4000; 
   SET @SkipCount = 1; 
  END 
 END 
END 
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[fnString_AddPad]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
 EXEC('CREATE FUNCTION [Utility].[fnString_AddPad] (@value nvarchar(max), @length integer, @caracterPad nchar(1))
RETURNS nvarchar(max)
AS
BEGIN
 RETURN(@value);
END');
GO
ALTER FUNCTION [Utility].[fnString_AddPad] (@value nvarchar(max), @length integer, @caracterPad nchar(1))
RETURNS nvarchar(max)
AS
/* ============================================================================================
Proposito: Retorna una cadena llenada con el caracter pad dado hasta la longitud dada.
 Si la longitud de la cadena es mayor a la longitud dada, entonces es retornada la misma cadena.
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2009-10-14
Fecha actualizacion: 2020-07-15

Parametros:  
 @value: texto origen
 @length: longitud máxima
 @caracterPad: Caracter pad, si no es suministrado se usa espacio en blanco
 
Retorno:
 Texto de la longitud dada, llena con caracteres al inicio si hace falta
 
Ejemplo:
 Select [Utility].[fnString_AddPad] ('ABC', 6, '0');
 Select [Utility].[fnString_AddPad] ('ABCDEFGHIJKLMN', 6, '0');
 Select [Utility].[fnString_AddPad] (Null, 6, '0');
============================================================================================ */
BEGIN
 Declare @tempo nvarchar(max);
 if @length is null or @length <= 0 or @length > 8000
  set @length = 8000
  
 if @caracterPad is null or @caracterPad = ''
  set @caracterPad = ' '
 
 if Len(@value) < @length
  set @tempo = Right(REPLICATE(@caracterPad, @length) + @value, @length)
 else
  set @tempo = @value 

 RETURN(@tempo)
END;
GO

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[fnString_Split]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
 EXEC('CREATE FUNCTION [Utility].[fnString_Split] ()
RETURNS @TableResultado TABLE 
(
 [Id] int identity(1,1),
 [Value] varchar(max)
)
AS
BEGIN
 RETURN;
END');
GO

ALTER FUNCTION [Utility].[fnString_Split] (@stringSource varchar(max), @delimiter varchar(5)) 
RETURNS @Results table 
(  
 [Id] int identity(1,1),
 [Value] varchar(max)
) 
/* ============================================================================================
Proposito: Separa un texto por un delimitador y retorna una tabla con las partes.
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2016-09-12
Fecha actualizacion: 2020-07-15

IMPORTANTE: A partir de SQL 2016 utilice funcion del motor: STRING_SPLIT
Ejemplo: SELECT [value] FROM STRING_SPLIT('1,2,3,4,4', ',');


Parametros:
 @stringSource: Texto origen a ser divido
 @delimiter: separador
 
Retorno: 
 Id: Consecutivo identificador.
 Value: Dato.

Ejemplo:
Select * from [Utility].[fnString_Split] ('1,2,3,4,4', ',')
Select * from [Utility].[fnString_Split] ('1 2 3 4', ' ')
Select * from [Utility].[fnString_Split] ('1 2 3 4', '')
============================================================================================ */
As 
begin
 declare @tempString varchar(max), @CharIndex int      
 
 set @stringSource = isnull(@stringSource,'')     
 set @delimiter = isnull(@delimiter,'')      
 set @tempString = @stringSource
 set @CharIndex = 0
 set @CharIndex = charindex(@delimiter, @tempString)     
 
 while @CharIndex != 0 
 begin              
  insert into @Results ([Value]) 
  values (ltrim(rtrim(substring(@tempString, 0, @CharIndex))));
  set @tempString = substring(@tempString, @CharIndex + 1, len(@tempString) - @CharIndex)
  set @CharIndex = charindex(@delimiter, @tempString)
 end
 
 if @tempString != '' 
 begin  
  insert into @Results ([Value])
  values (ltrim(rtrim(@tempString)));
 end
 
 return
end 
GO

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[GetParameters_SPFunction]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
 EXEC('CREATE FUNCTION [Utility].[GetParameters_SPFunction] (@schemaName nvarchar (128), @itemName nvarchar(128))
RETURNS @TableResult TABLE 
(
    [Params] nvarchar(max)
  , [SQLAaction] nvarchar(max)
)
AS
BEGIN
 RETURN;
END');
GO

ALTER FUNCTION [Utility].[GetParameters_SPFunction] (@schemaName nvarchar (128), @itemName nvarchar(128))
RETURNS @TableResult TABLE 
(
    [Params] nvarchar(max)
  , [SQLAaction] nvarchar(max)
) 
AS
/* ============================================================================================
Proposito: Retorna parametros de programación de recarga de datos.
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2016-07-26
Fecha actualizacion: 2020-07-15

PARAMETROS:
 @schemaName: Nombre de esquema.
 @itemName: Nombre de procedimiento almacenado o funcion.

EJEMLPO:
 SELECT [Params], [SQLAaction] FROM [Utility].[GetParameters_SPFunction]('Utility', 'fnString_AddPad');

 SELECT PARAMETER_NAME, DATA_TYPE, character_maximum_length,* 
 FROM information_schema.parameters
 WHERE specific_schema = 'Utility' AND specific_name = 'fnString_AddPad' AND PARAMETER_NAME != ''
 ORDER BY Ordinal_Position;
============================================================================================ */
BEGIN
 DECLARE @params nvarchar(4000) = '', @Names nvarchar(4000) = '';
 DECLARE @tmpParameterDetails TABLE (
  [ParamName] nvarchar (128),
  [DataType] nvarchar (128), 
  [Length] int);

 INSERT @tmpParameterDetails ([ParamName], [DataType], [Length])
 SELECT PARAMETER_NAME, DATA_TYPE, character_maximum_length 
 FROM information_schema.parameters
 WHERE specific_schema = @schemaName AND specific_name = @itemName AND PARAMETER_NAME != ''
 ORDER BY Ordinal_Position;

 SET @params = @params +
                (SELECT STUFF(
                    (SELECT ','+ [ParamName] + ' ' + [DataType] + ISNULL('(' + CAST(Replace([Length], '-1', 'max') AS varchar(6)) + ')','')
                     FROM @tmpParameterDetails
                     FOR XML PATH (''))
                 ,1, 1, ''));

 SET @Names = 'SELECT ' + (SELECT STUFF(
                    (SELECT ',' + [ParamName]
                     FROM @tmpParameterDetails
                     FOR XML PATH (''))
                 ,1, 1, ''));

 INSERT INTO @TableResult ([Params], [SQLAaction]) VALUES (@params, @Names);
 RETURN; 
END
GO

/* ========================================================================== 
Funciones manejo de errores
========================================================================== */
IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[GetErrorCurrentToString]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
 EXEC('CREATE FUNCTION [Utility].[GetErrorCurrentToString] ()
RETURNS nvarchar(max)
AS
BEGIN
 RETURN('''');
END');
GO
ALTER FUNCTION [Utility].[GetErrorCurrentToString] ()
RETURNS nvarchar(max)
WITH EXECUTE AS OWNER
AS
/* ============================================================================================
Proposito: Retorna el mensaje de error retornado por el sistema
Empresa:  
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2011-01-31
Fecha actualizacion: 2020-07-15

RETORNO:
 [Message]: Mensaje de error
 [Severity]: Severidad. 10: Informativo, 16: Error 
 [State]: State

EJEMLPO:
 SELECT [Utility].[GetErrorCurrentToString]();
============================================================================================ */
BEGIN
 Declare @errorMessage nvarchar(max), @errorSeverity int, @errorState int, @Error_Number int

 SELECT  @errorSeverity = ERROR_SEVERITY(), @errorState = ERROR_STATE()
 SELECT @Error_Number = ERROR_NUMBER()

  set @errorMessage = 'Error No. ' +  Convert(nvarchar, ERROR_NUMBER()) + ': ' + ERROR_MESSAGE() + ', Linea: ' + CONVERT(nvarchar(5), ERROR_LINE())
    + ', Procedencia: ' + ISNULL(ERROR_PROCEDURE(), '-') + ', Severidad: ' + convert(nvarchar, ISNULL(ERROR_SEVERITY(), '-'))
    + ', State: ' + Convert(nvarchar, ISNULL(ERROR_STATE(), '-'));
 
 RETURN(@errorMessage);
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Utility].[spSubscription]') AND type in (N'P', N'PC'))
BEGIN
 EXEC dbo.sp_EXECUTEsql @statement = N'CREATE PROCEDURE [Utility].[spSubscription] AS' 
END
GO
Alter PROCEDURE [Utility].[spSubscription] 
    @FileName varchar(100) 
AS
/* ============================================================================================
Proposito: Retorna el listado filtrado de las supscripciones
Empresa:  
Desarrollador: Werleman Tamayo Restrepo
Fecha: 2018-09-15
Fecha actualizacion: 2018-09-15

RETORNO:
 [Message]: supscripciones
 
PARAMETROS:
 @FileName : Nombre de reporte.

EJEMPLO:
 EXEC [Utility].[SPSubscription] 'STN_IDO_Auto_Dia';
 EXEC [Utility].[SPSubscription] 'No existe';
 EXEC [Utility].[SPSubscription] NULL;
============================================================================================ */

 begin
 if (@FileName='STN_IDO_Auto_Dia' or @FileName= 'Gen_Auto_IDO_Dia')

   SELECT  concat([FileName],'-',iif([DateName]='', left( CONVERT(char(10),DATEADD(day, -1, CONVERT (date, GETDATE())),121),10),[DateName])) as filename2 ,
        iif([DateName]='',left( CONVERT(char(10),DATEADD(day, -1, CONVERT (date, GETDATE())),121),10),[DateName])  as datename,
        FileName,
        Path,
	    RenderFormat,
        WriteMode,
        FileExtension,
        UserName,
        Password,
        FileShareAccount,
        DateName   
		FROM Utility.Subscription
		WHERE FileName =@FileName

end 
 begin
 if (@FileName='Gen_Auto_IDO_Mes' or @FileName= 'STN_IDO_Auto_Mes')

SELECT  concat([FileName],'-',iif([DateName]='', LEFT(CONVERT(char(10),DATEADD(Month, -1, CONVERT (date, GETDATE())),121),7),[DateName])) as filename2 ,
        iif([DateName]='',concat('[DimFecha].[Mes].&[',LEFT(CONVERT(char(10),DATEADD(Month, -1, CONVERT (date, GETDATE())),121),4),']&[',Month(CONVERT(char(30),DATEADD(Month, -1, CONVERT (date, GETDATE())),121)),']'),[DateName])  as datename,
        FileName,
        Path,
	RenderFormat,
        WriteMode,
        FileExtension,
        UserName,
        Password,
        FileShareAccount,
        DateName   

FROM Utility.Subscription
     WHERE FileName =@FileName
 
end 
GO

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - End script: A09SP_Util_General.sql'
PRINT '------------------------------------------------------------------------'
GO


