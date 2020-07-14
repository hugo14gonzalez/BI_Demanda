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
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - Start script: B02Data_DW.sql'
PRINT '------------------------------------------------------------------------'
GO

USE [$(DATABASE_NAME_DW)];

/* ========================================================================== 
DATOS PARA CARGA DE DIMENSIONES MANUALES
========================================================================== */

/* ============================================================================================
SELECT * FROM [DW].[DimMercado];
============================================================================================ */
IF NOT EXISTS(SELECT * FROM [DW].[DimMercado] WHERE [MercadoSKId] = 1) 
BEGIN 
 SET IDENTITY_INSERT [DW].[DimMercado] ON;

 INSERT INTO [DW].[DimMercado]([MercadoSKId],[Mercado],[BitacoraId])
 VALUES(1, 'INTERMEDIACION', 0); 

 SET IDENTITY_INSERT [DW].[DimMercado] OFF;
END;
GO

IF NOT EXISTS(SELECT * FROM [DW].[DimMercado] WHERE [MercadoSKId] = 2) 
BEGIN 
 SET IDENTITY_INSERT [DW].[DimMercado] ON;

 INSERT INTO [DW].[DimMercado]([MercadoSKId],[Mercado],[BitacoraId])
 VALUES(2, 'NO REGULADO', 0); 

 SET IDENTITY_INSERT [DW].[DimMercado] OFF;
END;
GO

IF NOT EXISTS(SELECT * FROM [DW].[DimMercado] WHERE [MercadoSKId] = 3) 
BEGIN 
 SET IDENTITY_INSERT [DW].[DimMercado] ON;

 INSERT INTO [DW].[DimMercado]([MercadoSKId],[Mercado],[BitacoraId])
 VALUES(3, 'REGULADO', 0); 

 SET IDENTITY_INSERT [DW].[DimMercado] OFF;
END;
GO

IF NOT EXISTS(SELECT * FROM [DW].[DimMercado] WHERE [MercadoSKId] = 4) 
BEGIN 
 SET IDENTITY_INSERT [DW].[DimMercado] ON;

 INSERT INTO [DW].[DimMercado]([MercadoSKId],[Mercado],[BitacoraId])
 VALUES(4, 'CONSUMOS', 0); 

 SET IDENTITY_INSERT [DW].[DimMercado] OFF;
END;
GO

IF NOT EXISTS(SELECT * FROM [DW].[DimMercado] WHERE [MercadoSKId] = 5) 
BEGIN 
 SET IDENTITY_INSERT [DW].[DimMercado] ON;

 INSERT INTO [DW].[DimMercado]([MercadoSKId],[Mercado],[BitacoraId])
 VALUES(5, 'AMBOS', 0); 

 SET IDENTITY_INSERT [DW].[DimMercado] OFF;
END;
GO

/* ========================================================================== 
SELECT * FROM [DW].[DimPeriodo];
========================================================================== */
EXECUTE [DW].[spLoadDimPeriod] 1;
GO

/* ============================================================================================
SELECT * FROM [Utility].[SpecialDate];

https://www.calendariodecolombia.com/calendario-2011.html
https://dias-festivos.eu/archivo/mundial/2012/
https://dias-festivos.eu/archivo/colombia/2012/
============================================================================================ */
-- 2000
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20000101')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20000101', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20000110')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20000110', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20000320')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20000320', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20000420')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20000420', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20000421')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20000421', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20000501')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20000501', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20000605')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20000605', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20000626')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20000626', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20000703')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20000703', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20000720')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20000720', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20000807')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20000807', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20000821')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20000821', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20001016')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20001016', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20001106')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20001106', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20001113')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20001113', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20001208')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20001208', 'Festivo');
END
GO
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20001225')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20001225', 'Festivo');
END
GO

-- 2001
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20010101')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20010101', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20010108')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20010108', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20010319')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20010319', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20010412')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20010412', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20010413')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20010413', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20010501')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20010501', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20010528')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20010528', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20010618')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20010618', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20010625')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20010625', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20010702')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20010702', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20010720')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20010720', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20010807')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20010807', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20010820')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20010820', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20011015')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20011015', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20011105')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20011105', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20011112')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20011112', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20011208')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20011208', 'Festivo');
END
GO
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20011225')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20011225', 'Festivo');
END
GO

-- 2002
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20020101')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20020101', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20020107')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20020107', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20020325')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20020325', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20020328')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20020328', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20020329')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20020329', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20020501')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20020501', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20020513')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20020513', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20020603')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20020603', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20020610')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20020610', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20020701')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20020701', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20020720')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20020720', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20020807')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20020807', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20020819')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20020819', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20021014')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20021014', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20021104')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20021104', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20021111')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20021111', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20021208')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20021208', 'Festivo');
END
GO
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20021225')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20021225', 'Festivo');
END
GO

-- 2003
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20030101')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20030101', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20030106')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20030106', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20030324')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20030324', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20030417')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20030417', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20030418')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20030418', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20030501')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20030501', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20030602')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20030602', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20030623')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20030623', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20030630')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20030630', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20030720')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20030720', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20030807')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20030807', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20030818')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20030818', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20031013')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20031013', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20031103')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20031103', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20031117')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20031117', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20031208')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20031208', 'Festivo');
END
GO
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20031225')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20031225', 'Festivo');
END
GO

-- 2004
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20040101')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20040101', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20040112')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20040112', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20040322')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20040322', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20040408')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20040408', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20040409')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20040409', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20040501')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20040501', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20040524')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20040524', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20040614')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20040614', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20040621')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20040621', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20040705')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20040705', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20040720')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20040720', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20040807')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20040807', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20040816')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20040816', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20041018')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20041018', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20041101')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20041101', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20041115')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20041115', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20041208')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20041208', 'Festivo');
END
GO
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20041225')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20041225', 'Festivo');
END
GO

-- 2005
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20050101')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20050101', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20050110')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20050110', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20050321')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20050321', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20050324')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20050324', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20050325')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20050325', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20050501')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20050501', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20050509')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20050509', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20050530')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20050530', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20050606')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20050606', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20050704')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20050704', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20050720')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20050720', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20050807')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20050807', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20050815')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20050815', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20051017')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20051017', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20051107')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20051107', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20051114')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20051114', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20051208')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20051208', 'Festivo');
END
GO
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20051225')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20051225', 'Festivo');
END
GO

-- 2006
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20060101')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20060101', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20060109')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20060109', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20060320')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20060320', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20060413')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20060413', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20060414')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20060414', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20060501')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20060501', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20060529')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20060529', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20060619')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20060619', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20060626')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20060626', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20060703')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20060703', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20060720')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20060720', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20060807')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20060807', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20060821')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20060821', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20061016')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20061016', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20061106')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20061106', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20061113')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20061113', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20061208')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20061208', 'Festivo');
END
GO
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20061225')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20061225', 'Festivo');
END
GO

-- 2007
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20070101')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20070101', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20070108')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20070108', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20070319')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20070319', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20070405')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20070405', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20070406')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20070406', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20070501')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20070501', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20070521')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20070521', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20070611')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20070611', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20070628')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20070628', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20070702')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20070702', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20070720')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20070720', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20070807')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20070807', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20070820')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20070820', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20071015')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20071015', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20071105')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20071105', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20071112')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20071112', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20071208')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20071208', 'Festivo');
END
GO
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20071225')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20071225', 'Festivo');
END
GO

-- 2008
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20080101')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20080101', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20080107')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20080107', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20080320')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20080320', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20080321')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20080321', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20080324')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20080324', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20080501')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20080501', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20080505')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20080505', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20080526')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20080526', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20080602')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20080602', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20080630')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20080630', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20080720')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20080720', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20080807')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20080807', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20080818')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20080818', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20081013')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20081013', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20081103')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20081103', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20081117')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20081117', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20081208')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20081208', 'Festivo');
END
GO
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20081225')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20081225', 'Festivo');
END
GO

-- 2009
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20090101')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20090101', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20090112')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20090112', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20090323')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20090323', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20090409')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20090409', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20090410')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20090410', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20090501')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20090501', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20090525')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20090525', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20090615')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20090615', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20090622')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20090622', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20090629')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20090629', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20090720')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20090720', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20090807')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20090807', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20090817')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20090817', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20091012')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20091012', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20091102')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20091102', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20091116')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20091116', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20091208')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20091208', 'Festivo');
END
GO
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20091225')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20091225', 'Festivo');
END
GO

-- 2010
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20100101')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20100101', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20100111')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20100111', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20100322')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20100322', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20100401')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20100401', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20100402')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20100402', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20100404')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20100404', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20100501')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20100501', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20100517')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20100517', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20100607')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20100607', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20100614')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20100614', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20100705')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20100705', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20100720')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20100720', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20100807')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20100807', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20100816')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20100816', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20101018')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20101018', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20101101')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20101101', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20101115')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20101115', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20101208')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20101208', 'Festivo');
END
GO
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20101225')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20101225', 'Festivo');
END
GO

-- 2011
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20110101')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20110101', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20110110')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20110110', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20110321')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20110321', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20110421')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20110421', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20110422')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20110422', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20110424')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20110424', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20110501')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20110501', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20110605')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20110605', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20110627')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20110627', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20110704')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20110704', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20110720')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20110720', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20110807')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20110807', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20110815')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20110815', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20111017')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20111017', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20111107')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20111107', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20111114')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20111114', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20111208')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20111208', 'Festivo');
END
GO
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20111225')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20111225', 'Festivo');
END
GO

-- 2012
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20120101')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20120101', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20120109')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20120109', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20120319')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20120319', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20120405')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20120405', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20120406')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20120406', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20120408')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20120408', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20120501')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20120501', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20120521')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20120521', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20120611')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20120611', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20120618')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20120618', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20120702')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20120702', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20120720')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20120720', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20120807')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20120807', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20120820')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20120820', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20121015')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20121015', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20121105')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20121105', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20121112')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20121112', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20121208')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20121208', 'Festivo');
END
GO
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20121225')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20121225', 'Festivo');
END
GO

-- 2013
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20130101')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20130101', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20130107')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20130107', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20130325')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20130325', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20130328')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20130328', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20130329')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20130329', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20130331')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20130331', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20130501')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20130501', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20130513')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20130513', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20130603')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20130603', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20130610')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20130610', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20130701')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20130701', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20130720')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20130720', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20130807')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20130807', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20130819')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20130819', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20131014')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20131014', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20131104')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20131104', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20131111')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20131111', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20131208')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20131208', 'Festivo');
END
GO
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20131225')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20131225', 'Festivo');
END
GO

-- 2014
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20140101')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20140101', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20140106')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20140106', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20140324')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20140324', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20140417')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20140417', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20140418')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20140418', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20140420')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20140420', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20140501')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20140501', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20140602')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20140602', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20140623')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20140623', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20140630')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20140630', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20140720')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20140720', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20140807')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20140807', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20140818')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20140818', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20141013')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20141013', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20141103')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20141103', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20141117')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20141117', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20141208')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20141208', 'Festivo');
END
GO
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20141225')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20141225', 'Festivo');
END
GO

-- 2015
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20150101')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20150101', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20150112')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20150112', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20150323')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20150323', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20150402')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20150402', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20150403')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20150403', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20150405')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20150405', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20150501')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20150501', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20150518')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20150518', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20150608')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20150608', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20150615')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20150615', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20150629')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20150629', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20150720')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20150720', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20150807')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20150807', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20150817')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20150817', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20151012')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20151012', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20151102')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20151102', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20151116')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20151116', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20151208')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20151208', 'Festivo');
END
GO
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20151225')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20151225', 'Festivo');
END
GO

-- 2016
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20160101')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20160101', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20160111')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20160111', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20160321')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20160321', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20160324')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20160324', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20160325')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20160325', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20160327')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20160327', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20160501')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20160501', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20160509')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20160509', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20160530')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20160530', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20160606')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20160606', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20160704')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20160704', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20160720')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20160720', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20160807')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20160807', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20160815')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20160815', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20161017')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20161017', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20161107')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20161107', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20161114')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20161114', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20161208')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20161208', 'Festivo');
END
GO
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20161225')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20161225', 'Festivo');
END
GO

-- 2017
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20170101')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20170101', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20170109')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20170109', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20170320')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20170320', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20170413')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20170413', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20170414')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20170414', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20170416')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20170416', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20170501')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20170501', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20170529')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20170529', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20170619')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20170619', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20170626')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20170626', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20170703')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20170703', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20170720')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20170720', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20170807')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20170807', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20170821')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20170821', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20171016')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20171016', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20171106')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20171106', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20171113')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20171113', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20171208')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20171208', 'Festivo');
END
GO
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20171225')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20171225', 'Festivo');
END
GO

--2018
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20180101')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20180101', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20180108')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20180108', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20180319')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20180319', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20180329')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20180329', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20180430')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20180430', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20180401')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20180401', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20180501')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20180501', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20180514')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20180514', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20180604')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20180604', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20180611')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20180611', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20180702')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20180702', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20180720')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20180720', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20180807')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20180807', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20180820')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20180820', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20181015')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20181015', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20181105')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20181105', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20181112')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20181112', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20181208')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20181208', 'Festivo');
END
GO
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20181225')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20181225', 'Festivo');
END
GO

--2019
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20190101')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20190101', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20190107')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20190107', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20190325')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20190325', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20190418')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20190418', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20190419')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20190419', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20190501')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20190501', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20190603')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20190603', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20190624')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20190624', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20190701')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20190701', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20190720')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20190720', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20190807')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20190807', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20190819')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20190819', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20191014')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20191014', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20191104')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20191104', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20191111')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20191111', 'Festivo');
END
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20191208')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20191208', 'Festivo');
END
GO
IF NOT EXISTS(SELECT * FROM [Utility].[SpecialDate] WHERE [DateId] = '20191225')
BEGIN
 INSERT INTO [Utility].[SpecialDate] ([DateId], [Type]) VALUES('20191225', 'Festivo');
END
GO

/* ============================================================================================
SELECT * FROM [DW].[DimFecha];
============================================================================================ */
Declare @dateStart date, @dateEnd date;
Set @dateStart = convert(date, '1900-01-01', 120);
set @dateEnd = convert(date, Convert(nvarchar, Year(GetDate()) + 2) + '-01-01', 120);
EXECUTE [DW].[spLoadDimDate] @dateStart, @dateEnd, 1;
GO

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - End script: B02Data_DW.sql'
PRINT '------------------------------------------------------------------------'
GO