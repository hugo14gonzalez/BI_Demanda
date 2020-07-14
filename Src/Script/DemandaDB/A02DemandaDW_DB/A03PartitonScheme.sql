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
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - Start script: A03PartitonScheme.sql'
PRINT '------------------------------------------------------------------------'
GO

USE [$(DATABASE_NAME_DW)];

/* ========================================================================== 
Funciones de particion - mensual
========================================================================== */
/* select (2010 % 12) => Inicia en filegroup: 6 */
IF NOT EXISTS (SELECT * FROM sys.partition_functions WHERE name = N'pfFactDemandaPerdida')
CREATE PARTITION FUNCTION [pfFactDemandaPerdida](int) AS RANGE RIGHT FOR VALUES 
(20000101, 20000201, 20000301, 20000401, 20000501, 20000601, 20000701, 20000801, 20000901, 20001001, 20001101, 20001201, 
 20010101, 20010201, 20010301, 20010401, 20010501, 20010601, 20010701, 20010801, 20010901, 20011001, 20011101, 20011201, 
 20020101, 20020201, 20020301, 20020401, 20020501, 20020601, 20020701, 20020801, 20020901, 20021001, 20021101, 20021201, 
 20030101, 20030201, 20030301, 20030401, 20030501, 20030601, 20030701, 20030801, 20030901, 20031001, 20031101, 20031201, 
 20040101, 20040201, 20040301, 20040401, 20040501, 20040601, 20040701, 20040801, 20040901, 20041001, 20041101, 20041201, 
 20050101, 20050201, 20050301, 20050401, 20050501, 20050601, 20050701, 20050801, 20050901, 20051001, 20051101, 20051201, 
 20060101, 20060201, 20060301, 20060401, 20060501, 20060601, 20060701, 20060801, 20060901, 20061001, 20061101, 20061201, 
 20070101, 20070201, 20070301, 20070401, 20070501, 20070601, 20070701, 20070801, 20070901, 20071001, 20071101, 20071201, 
 20080101, 20080201, 20080301, 20080401, 20080501, 20080601, 20080701, 20080801, 20080901, 20081001, 20081101, 20081201, 
 20090101, 20090201, 20090301, 20090401, 20090501, 20090601, 20090701, 20090801, 20090901, 20091001, 20091101, 20091201,  
 20100101, 20100201, 20100301, 20100401, 20100501, 20100601, 20100701, 20100801, 20100901, 20101001, 20101101, 20101201, 
 20110101, 20110201, 20110301, 20110401, 20110501, 20110601, 20110701, 20110801, 20110901, 20111001, 20111101, 20111201, 
 20120101, 20120201, 20120301, 20120401, 20120501, 20120601, 20120701, 20120801, 20120901, 20121001, 20121101, 20121201, 
 20130101, 20130201, 20130301, 20130401, 20130501, 20130601, 20130701, 20130801, 20130901, 20131001, 20131101, 20131201, 
 20140101, 20140201, 20140301, 20140401, 20140501, 20140601, 20140701, 20140801, 20140901, 20141001, 20141101, 20141201, 
 20150101, 20150201, 20150301, 20150401, 20150501, 20150601, 20150701, 20150801, 20150901, 20151001, 20151101, 20151201, 
 20160101, 20160201, 20160301, 20160401, 20160501, 20160601, 20160701, 20160801, 20160901, 20161001, 20161101, 20161201,
 20170101, 20170201, 20170301, 20170401, 20170501, 20170601, 20170701, 20170801, 20170901, 20171001, 20171101, 20171201,
 20180101, 20180201, 20180301, 20180401, 20180501, 20180601, 20180701, 20180801, 20180901, 20181001, 20181101, 20181201,
 20190101, 20190201, 20190301, 20190401, 20190501, 20190601, 20190701, 20190801, 20190901, 20191001, 20191101, 20191201,
 20200101);
GO

/* ========================================================================== 
Esquemas de particion - Mensual
========================================================================== */
/* select (2000 % 10) + 1 => Inicia en secuencia: 1, mes 1 */
IF NOT EXISTS (SELECT * FROM sys.partition_schemes WHERE name = N'psFactDemandaPerdida_dat')
 CREATE PARTITION SCHEME [psFactDemandaPerdida_dat] AS PARTITION [pfFactDemandaPerdida] TO 
 ([fgFactDemandaPerdida_1_1_dat], [fgFactDemandaPerdida_1_2_dat], [fgFactDemandaPerdida_1_3_dat], [fgFactDemandaPerdida_1_4_dat], [fgFactDemandaPerdida_1_5_dat], [fgFactDemandaPerdida_1_6_dat], [fgFactDemandaPerdida_1_7_dat], [fgFactDemandaPerdida_1_8_dat], [fgFactDemandaPerdida_1_9_dat], [fgFactDemandaPerdida_1_10_dat], [fgFactDemandaPerdida_1_11_dat], [fgFactDemandaPerdida_1_12_dat] 
, [fgFactDemandaPerdida_2_1_dat], [fgFactDemandaPerdida_2_2_dat], [fgFactDemandaPerdida_2_3_dat], [fgFactDemandaPerdida_2_4_dat], [fgFactDemandaPerdida_2_5_dat], [fgFactDemandaPerdida_2_6_dat], [fgFactDemandaPerdida_2_7_dat], [fgFactDemandaPerdida_2_8_dat], [fgFactDemandaPerdida_2_9_dat], [fgFactDemandaPerdida_2_10_dat], [fgFactDemandaPerdida_2_11_dat], [fgFactDemandaPerdida_2_12_dat] 
, [fgFactDemandaPerdida_3_1_dat], [fgFactDemandaPerdida_3_2_dat], [fgFactDemandaPerdida_3_3_dat], [fgFactDemandaPerdida_3_4_dat], [fgFactDemandaPerdida_3_5_dat], [fgFactDemandaPerdida_3_6_dat], [fgFactDemandaPerdida_3_7_dat], [fgFactDemandaPerdida_3_8_dat], [fgFactDemandaPerdida_3_9_dat], [fgFactDemandaPerdida_3_10_dat], [fgFactDemandaPerdida_3_11_dat], [fgFactDemandaPerdida_3_12_dat] 
, [fgFactDemandaPerdida_4_1_dat], [fgFactDemandaPerdida_4_2_dat], [fgFactDemandaPerdida_4_3_dat], [fgFactDemandaPerdida_4_4_dat], [fgFactDemandaPerdida_4_5_dat], [fgFactDemandaPerdida_4_6_dat], [fgFactDemandaPerdida_4_7_dat], [fgFactDemandaPerdida_4_8_dat], [fgFactDemandaPerdida_4_9_dat], [fgFactDemandaPerdida_4_10_dat], [fgFactDemandaPerdida_4_11_dat], [fgFactDemandaPerdida_4_12_dat] 
, [fgFactDemandaPerdida_5_1_dat], [fgFactDemandaPerdida_5_2_dat], [fgFactDemandaPerdida_5_3_dat], [fgFactDemandaPerdida_5_4_dat], [fgFactDemandaPerdida_5_5_dat], [fgFactDemandaPerdida_5_6_dat], [fgFactDemandaPerdida_5_7_dat], [fgFactDemandaPerdida_5_8_dat], [fgFactDemandaPerdida_5_9_dat], [fgFactDemandaPerdida_5_10_dat], [fgFactDemandaPerdida_5_11_dat], [fgFactDemandaPerdida_5_12_dat] 
, [fgFactDemandaPerdida_6_1_dat], [fgFactDemandaPerdida_6_2_dat], [fgFactDemandaPerdida_6_3_dat], [fgFactDemandaPerdida_6_4_dat], [fgFactDemandaPerdida_6_5_dat], [fgFactDemandaPerdida_6_6_dat], [fgFactDemandaPerdida_6_7_dat], [fgFactDemandaPerdida_6_8_dat], [fgFactDemandaPerdida_6_9_dat], [fgFactDemandaPerdida_6_10_dat], [fgFactDemandaPerdida_6_11_dat], [fgFactDemandaPerdida_6_12_dat] 
, [fgFactDemandaPerdida_7_1_dat], [fgFactDemandaPerdida_7_2_dat], [fgFactDemandaPerdida_7_3_dat], [fgFactDemandaPerdida_7_4_dat], [fgFactDemandaPerdida_7_5_dat], [fgFactDemandaPerdida_7_6_dat], [fgFactDemandaPerdida_7_7_dat], [fgFactDemandaPerdida_7_8_dat], [fgFactDemandaPerdida_7_9_dat], [fgFactDemandaPerdida_7_10_dat], [fgFactDemandaPerdida_7_11_dat], [fgFactDemandaPerdida_7_12_dat] 
, [fgFactDemandaPerdida_8_1_dat], [fgFactDemandaPerdida_8_2_dat], [fgFactDemandaPerdida_8_3_dat], [fgFactDemandaPerdida_8_4_dat], [fgFactDemandaPerdida_8_5_dat], [fgFactDemandaPerdida_8_6_dat], [fgFactDemandaPerdida_8_7_dat], [fgFactDemandaPerdida_8_8_dat], [fgFactDemandaPerdida_8_9_dat], [fgFactDemandaPerdida_8_10_dat], [fgFactDemandaPerdida_8_11_dat], [fgFactDemandaPerdida_8_12_dat] 
, [fgFactDemandaPerdida_9_1_dat], [fgFactDemandaPerdida_9_2_dat], [fgFactDemandaPerdida_9_3_dat], [fgFactDemandaPerdida_9_4_dat], [fgFactDemandaPerdida_9_5_dat], [fgFactDemandaPerdida_9_6_dat], [fgFactDemandaPerdida_9_7_dat], [fgFactDemandaPerdida_9_8_dat], [fgFactDemandaPerdida_9_9_dat], [fgFactDemandaPerdida_9_10_dat], [fgFactDemandaPerdida_9_11_dat], [fgFactDemandaPerdida_9_12_dat] 
, [fgFactDemandaPerdida_10_1_dat], [fgFactDemandaPerdida_10_2_dat], [fgFactDemandaPerdida_10_3_dat], [fgFactDemandaPerdida_10_4_dat], [fgFactDemandaPerdida_10_5_dat], [fgFactDemandaPerdida_10_6_dat], [fgFactDemandaPerdida_10_7_dat], [fgFactDemandaPerdida_10_8_dat], [fgFactDemandaPerdida_10_9_dat], [fgFactDemandaPerdida_10_10_dat], [fgFactDemandaPerdida_10_11_dat], [fgFactDemandaPerdida_10_12_dat] 
, [fgFactDemandaPerdida_1_1_dat], [fgFactDemandaPerdida_1_2_dat], [fgFactDemandaPerdida_1_3_dat], [fgFactDemandaPerdida_1_4_dat], [fgFactDemandaPerdida_1_5_dat], [fgFactDemandaPerdida_1_6_dat], [fgFactDemandaPerdida_1_7_dat], [fgFactDemandaPerdida_1_8_dat], [fgFactDemandaPerdida_1_9_dat], [fgFactDemandaPerdida_1_10_dat], [fgFactDemandaPerdida_1_11_dat], [fgFactDemandaPerdida_1_12_dat] 
, [fgFactDemandaPerdida_2_1_dat], [fgFactDemandaPerdida_2_2_dat], [fgFactDemandaPerdida_2_3_dat], [fgFactDemandaPerdida_2_4_dat], [fgFactDemandaPerdida_2_5_dat], [fgFactDemandaPerdida_2_6_dat], [fgFactDemandaPerdida_2_7_dat], [fgFactDemandaPerdida_2_8_dat], [fgFactDemandaPerdida_2_9_dat], [fgFactDemandaPerdida_2_10_dat], [fgFactDemandaPerdida_2_11_dat], [fgFactDemandaPerdida_2_12_dat] 
, [fgFactDemandaPerdida_3_1_dat], [fgFactDemandaPerdida_3_2_dat], [fgFactDemandaPerdida_3_3_dat], [fgFactDemandaPerdida_3_4_dat], [fgFactDemandaPerdida_3_5_dat], [fgFactDemandaPerdida_3_6_dat], [fgFactDemandaPerdida_3_7_dat], [fgFactDemandaPerdida_3_8_dat], [fgFactDemandaPerdida_3_9_dat], [fgFactDemandaPerdida_3_10_dat], [fgFactDemandaPerdida_3_11_dat], [fgFactDemandaPerdida_3_12_dat] 
, [fgFactDemandaPerdida_4_1_dat], [fgFactDemandaPerdida_4_2_dat], [fgFactDemandaPerdida_4_3_dat], [fgFactDemandaPerdida_4_4_dat], [fgFactDemandaPerdida_4_5_dat], [fgFactDemandaPerdida_4_6_dat], [fgFactDemandaPerdida_4_7_dat], [fgFactDemandaPerdida_4_8_dat], [fgFactDemandaPerdida_4_9_dat], [fgFactDemandaPerdida_4_10_dat], [fgFactDemandaPerdida_4_11_dat], [fgFactDemandaPerdida_4_12_dat] 
, [fgFactDemandaPerdida_5_1_dat], [fgFactDemandaPerdida_5_2_dat], [fgFactDemandaPerdida_5_3_dat], [fgFactDemandaPerdida_5_4_dat], [fgFactDemandaPerdida_5_5_dat], [fgFactDemandaPerdida_5_6_dat], [fgFactDemandaPerdida_5_7_dat], [fgFactDemandaPerdida_5_8_dat], [fgFactDemandaPerdida_5_9_dat], [fgFactDemandaPerdida_5_10_dat], [fgFactDemandaPerdida_5_11_dat], [fgFactDemandaPerdida_5_12_dat] 
, [fgFactDemandaPerdida_6_1_dat], [fgFactDemandaPerdida_6_2_dat], [fgFactDemandaPerdida_6_3_dat], [fgFactDemandaPerdida_6_4_dat], [fgFactDemandaPerdida_6_5_dat], [fgFactDemandaPerdida_6_6_dat], [fgFactDemandaPerdida_6_7_dat], [fgFactDemandaPerdida_6_8_dat], [fgFactDemandaPerdida_6_9_dat], [fgFactDemandaPerdida_6_10_dat], [fgFactDemandaPerdida_6_11_dat], [fgFactDemandaPerdida_6_12_dat] 
, [fgFactDemandaPerdida_7_1_dat], [fgFactDemandaPerdida_7_2_dat], [fgFactDemandaPerdida_7_3_dat], [fgFactDemandaPerdida_7_4_dat], [fgFactDemandaPerdida_7_5_dat], [fgFactDemandaPerdida_7_6_dat], [fgFactDemandaPerdida_7_7_dat], [fgFactDemandaPerdida_7_8_dat], [fgFactDemandaPerdida_7_9_dat], [fgFactDemandaPerdida_7_10_dat], [fgFactDemandaPerdida_7_11_dat], [fgFactDemandaPerdida_7_12_dat] 
, [fgFactDemandaPerdida_8_1_dat], [fgFactDemandaPerdida_8_2_dat], [fgFactDemandaPerdida_8_3_dat], [fgFactDemandaPerdida_8_4_dat], [fgFactDemandaPerdida_8_5_dat], [fgFactDemandaPerdida_8_6_dat], [fgFactDemandaPerdida_8_7_dat], [fgFactDemandaPerdida_8_8_dat], [fgFactDemandaPerdida_8_9_dat], [fgFactDemandaPerdida_8_10_dat], [fgFactDemandaPerdida_8_11_dat], [fgFactDemandaPerdida_8_12_dat] 
, [fgFactDemandaPerdida_9_1_dat], [fgFactDemandaPerdida_9_2_dat], [fgFactDemandaPerdida_9_3_dat], [fgFactDemandaPerdida_9_4_dat], [fgFactDemandaPerdida_9_5_dat], [fgFactDemandaPerdida_9_6_dat], [fgFactDemandaPerdida_9_7_dat], [fgFactDemandaPerdida_9_8_dat], [fgFactDemandaPerdida_9_9_dat], [fgFactDemandaPerdida_9_10_dat], [fgFactDemandaPerdida_9_11_dat], [fgFactDemandaPerdida_9_12_dat] 
, [fgFactDemandaPerdida_10_1_dat], [fgFactDemandaPerdida_10_2_dat], [fgFactDemandaPerdida_10_3_dat], [fgFactDemandaPerdida_10_4_dat], [fgFactDemandaPerdida_10_5_dat], [fgFactDemandaPerdida_10_6_dat], [fgFactDemandaPerdida_10_7_dat], [fgFactDemandaPerdida_10_8_dat], [fgFactDemandaPerdida_10_9_dat], [fgFactDemandaPerdida_10_10_dat], [fgFactDemandaPerdida_10_11_dat], [fgFactDemandaPerdida_10_12_dat] 
, [fgFactDemandaPerdida_1_1_dat], [fgFactDemandaPerdida_1_2_dat]);
GO
IF NOT EXISTS (SELECT * FROM sys.partition_schemes WHERE name = N'psFactDemandaPerdida_ind')
 CREATE PARTITION SCHEME [psFactDemandaPerdida_ind] AS PARTITION [pfFactDemandaPerdida] TO 
 ([fgFactDemandaPerdida_1_1_ind], [fgFactDemandaPerdida_1_2_ind], [fgFactDemandaPerdida_1_3_ind], [fgFactDemandaPerdida_1_4_ind], [fgFactDemandaPerdida_1_5_ind], [fgFactDemandaPerdida_1_6_ind], [fgFactDemandaPerdida_1_7_ind], [fgFactDemandaPerdida_1_8_ind], [fgFactDemandaPerdida_1_9_ind], [fgFactDemandaPerdida_1_10_ind], [fgFactDemandaPerdida_1_11_ind], [fgFactDemandaPerdida_1_12_ind] 
, [fgFactDemandaPerdida_2_1_ind], [fgFactDemandaPerdida_2_2_ind], [fgFactDemandaPerdida_2_3_ind], [fgFactDemandaPerdida_2_4_ind], [fgFactDemandaPerdida_2_5_ind], [fgFactDemandaPerdida_2_6_ind], [fgFactDemandaPerdida_2_7_ind], [fgFactDemandaPerdida_2_8_ind], [fgFactDemandaPerdida_2_9_ind], [fgFactDemandaPerdida_2_10_ind], [fgFactDemandaPerdida_2_11_ind], [fgFactDemandaPerdida_2_12_ind] 
, [fgFactDemandaPerdida_3_1_ind], [fgFactDemandaPerdida_3_2_ind], [fgFactDemandaPerdida_3_3_ind], [fgFactDemandaPerdida_3_4_ind], [fgFactDemandaPerdida_3_5_ind], [fgFactDemandaPerdida_3_6_ind], [fgFactDemandaPerdida_3_7_ind], [fgFactDemandaPerdida_3_8_ind], [fgFactDemandaPerdida_3_9_ind], [fgFactDemandaPerdida_3_10_ind], [fgFactDemandaPerdida_3_11_ind], [fgFactDemandaPerdida_3_12_ind] 
, [fgFactDemandaPerdida_4_1_ind], [fgFactDemandaPerdida_4_2_ind], [fgFactDemandaPerdida_4_3_ind], [fgFactDemandaPerdida_4_4_ind], [fgFactDemandaPerdida_4_5_ind], [fgFactDemandaPerdida_4_6_ind], [fgFactDemandaPerdida_4_7_ind], [fgFactDemandaPerdida_4_8_ind], [fgFactDemandaPerdida_4_9_ind], [fgFactDemandaPerdida_4_10_ind], [fgFactDemandaPerdida_4_11_ind], [fgFactDemandaPerdida_4_12_ind] 
, [fgFactDemandaPerdida_5_1_ind], [fgFactDemandaPerdida_5_2_ind], [fgFactDemandaPerdida_5_3_ind], [fgFactDemandaPerdida_5_4_ind], [fgFactDemandaPerdida_5_5_ind], [fgFactDemandaPerdida_5_6_ind], [fgFactDemandaPerdida_5_7_ind], [fgFactDemandaPerdida_5_8_ind], [fgFactDemandaPerdida_5_9_ind], [fgFactDemandaPerdida_5_10_ind], [fgFactDemandaPerdida_5_11_ind], [fgFactDemandaPerdida_5_12_ind] 
, [fgFactDemandaPerdida_6_1_ind], [fgFactDemandaPerdida_6_2_ind], [fgFactDemandaPerdida_6_3_ind], [fgFactDemandaPerdida_6_4_ind], [fgFactDemandaPerdida_6_5_ind], [fgFactDemandaPerdida_6_6_ind], [fgFactDemandaPerdida_6_7_ind], [fgFactDemandaPerdida_6_8_ind], [fgFactDemandaPerdida_6_9_ind], [fgFactDemandaPerdida_6_10_ind], [fgFactDemandaPerdida_6_11_ind], [fgFactDemandaPerdida_6_12_ind] 
, [fgFactDemandaPerdida_7_1_ind], [fgFactDemandaPerdida_7_2_ind], [fgFactDemandaPerdida_7_3_ind], [fgFactDemandaPerdida_7_4_ind], [fgFactDemandaPerdida_7_5_ind], [fgFactDemandaPerdida_7_6_ind], [fgFactDemandaPerdida_7_7_ind], [fgFactDemandaPerdida_7_8_ind], [fgFactDemandaPerdida_7_9_ind], [fgFactDemandaPerdida_7_10_ind], [fgFactDemandaPerdida_7_11_ind], [fgFactDemandaPerdida_7_12_ind] 
, [fgFactDemandaPerdida_8_1_ind], [fgFactDemandaPerdida_8_2_ind], [fgFactDemandaPerdida_8_3_ind], [fgFactDemandaPerdida_8_4_ind], [fgFactDemandaPerdida_8_5_ind], [fgFactDemandaPerdida_8_6_ind], [fgFactDemandaPerdida_8_7_ind], [fgFactDemandaPerdida_8_8_ind], [fgFactDemandaPerdida_8_9_ind], [fgFactDemandaPerdida_8_10_ind], [fgFactDemandaPerdida_8_11_ind], [fgFactDemandaPerdida_8_12_ind] 
, [fgFactDemandaPerdida_9_1_ind], [fgFactDemandaPerdida_9_2_ind], [fgFactDemandaPerdida_9_3_ind], [fgFactDemandaPerdida_9_4_ind], [fgFactDemandaPerdida_9_5_ind], [fgFactDemandaPerdida_9_6_ind], [fgFactDemandaPerdida_9_7_ind], [fgFactDemandaPerdida_9_8_ind], [fgFactDemandaPerdida_9_9_ind], [fgFactDemandaPerdida_9_10_ind], [fgFactDemandaPerdida_9_11_ind], [fgFactDemandaPerdida_9_12_ind] 
, [fgFactDemandaPerdida_10_1_ind], [fgFactDemandaPerdida_10_2_ind], [fgFactDemandaPerdida_10_3_ind], [fgFactDemandaPerdida_10_4_ind], [fgFactDemandaPerdida_10_5_ind], [fgFactDemandaPerdida_10_6_ind], [fgFactDemandaPerdida_10_7_ind], [fgFactDemandaPerdida_10_8_ind], [fgFactDemandaPerdida_10_9_ind], [fgFactDemandaPerdida_10_10_ind], [fgFactDemandaPerdida_10_11_ind], [fgFactDemandaPerdida_10_12_ind] 
, [fgFactDemandaPerdida_1_1_ind], [fgFactDemandaPerdida_1_2_ind], [fgFactDemandaPerdida_1_3_ind], [fgFactDemandaPerdida_1_4_ind], [fgFactDemandaPerdida_1_5_ind], [fgFactDemandaPerdida_1_6_ind], [fgFactDemandaPerdida_1_7_ind], [fgFactDemandaPerdida_1_8_ind], [fgFactDemandaPerdida_1_9_ind], [fgFactDemandaPerdida_1_10_ind], [fgFactDemandaPerdida_1_11_ind], [fgFactDemandaPerdida_1_12_ind] 
, [fgFactDemandaPerdida_2_1_ind], [fgFactDemandaPerdida_2_2_ind], [fgFactDemandaPerdida_2_3_ind], [fgFactDemandaPerdida_2_4_ind], [fgFactDemandaPerdida_2_5_ind], [fgFactDemandaPerdida_2_6_ind], [fgFactDemandaPerdida_2_7_ind], [fgFactDemandaPerdida_2_8_ind], [fgFactDemandaPerdida_2_9_ind], [fgFactDemandaPerdida_2_10_ind], [fgFactDemandaPerdida_2_11_ind], [fgFactDemandaPerdida_2_12_ind] 
, [fgFactDemandaPerdida_3_1_ind], [fgFactDemandaPerdida_3_2_ind], [fgFactDemandaPerdida_3_3_ind], [fgFactDemandaPerdida_3_4_ind], [fgFactDemandaPerdida_3_5_ind], [fgFactDemandaPerdida_3_6_ind], [fgFactDemandaPerdida_3_7_ind], [fgFactDemandaPerdida_3_8_ind], [fgFactDemandaPerdida_3_9_ind], [fgFactDemandaPerdida_3_10_ind], [fgFactDemandaPerdida_3_11_ind], [fgFactDemandaPerdida_3_12_ind] 
, [fgFactDemandaPerdida_4_1_ind], [fgFactDemandaPerdida_4_2_ind], [fgFactDemandaPerdida_4_3_ind], [fgFactDemandaPerdida_4_4_ind], [fgFactDemandaPerdida_4_5_ind], [fgFactDemandaPerdida_4_6_ind], [fgFactDemandaPerdida_4_7_ind], [fgFactDemandaPerdida_4_8_ind], [fgFactDemandaPerdida_4_9_ind], [fgFactDemandaPerdida_4_10_ind], [fgFactDemandaPerdida_4_11_ind], [fgFactDemandaPerdida_4_12_ind] 
, [fgFactDemandaPerdida_5_1_ind], [fgFactDemandaPerdida_5_2_ind], [fgFactDemandaPerdida_5_3_ind], [fgFactDemandaPerdida_5_4_ind], [fgFactDemandaPerdida_5_5_ind], [fgFactDemandaPerdida_5_6_ind], [fgFactDemandaPerdida_5_7_ind], [fgFactDemandaPerdida_5_8_ind], [fgFactDemandaPerdida_5_9_ind], [fgFactDemandaPerdida_5_10_ind], [fgFactDemandaPerdida_5_11_ind], [fgFactDemandaPerdida_5_12_ind] 
, [fgFactDemandaPerdida_6_1_ind], [fgFactDemandaPerdida_6_2_ind], [fgFactDemandaPerdida_6_3_ind], [fgFactDemandaPerdida_6_4_ind], [fgFactDemandaPerdida_6_5_ind], [fgFactDemandaPerdida_6_6_ind], [fgFactDemandaPerdida_6_7_ind], [fgFactDemandaPerdida_6_8_ind], [fgFactDemandaPerdida_6_9_ind], [fgFactDemandaPerdida_6_10_ind], [fgFactDemandaPerdida_6_11_ind], [fgFactDemandaPerdida_6_12_ind] 
, [fgFactDemandaPerdida_7_1_ind], [fgFactDemandaPerdida_7_2_ind], [fgFactDemandaPerdida_7_3_ind], [fgFactDemandaPerdida_7_4_ind], [fgFactDemandaPerdida_7_5_ind], [fgFactDemandaPerdida_7_6_ind], [fgFactDemandaPerdida_7_7_ind], [fgFactDemandaPerdida_7_8_ind], [fgFactDemandaPerdida_7_9_ind], [fgFactDemandaPerdida_7_10_ind], [fgFactDemandaPerdida_7_11_ind], [fgFactDemandaPerdida_7_12_ind] 
, [fgFactDemandaPerdida_8_1_ind], [fgFactDemandaPerdida_8_2_ind], [fgFactDemandaPerdida_8_3_ind], [fgFactDemandaPerdida_8_4_ind], [fgFactDemandaPerdida_8_5_ind], [fgFactDemandaPerdida_8_6_ind], [fgFactDemandaPerdida_8_7_ind], [fgFactDemandaPerdida_8_8_ind], [fgFactDemandaPerdida_8_9_ind], [fgFactDemandaPerdida_8_10_ind], [fgFactDemandaPerdida_8_11_ind], [fgFactDemandaPerdida_8_12_ind] 
, [fgFactDemandaPerdida_9_1_ind], [fgFactDemandaPerdida_9_2_ind], [fgFactDemandaPerdida_9_3_ind], [fgFactDemandaPerdida_9_4_ind], [fgFactDemandaPerdida_9_5_ind], [fgFactDemandaPerdida_9_6_ind], [fgFactDemandaPerdida_9_7_ind], [fgFactDemandaPerdida_9_8_ind], [fgFactDemandaPerdida_9_9_ind], [fgFactDemandaPerdida_9_10_ind], [fgFactDemandaPerdida_9_11_ind], [fgFactDemandaPerdida_9_12_ind] 
, [fgFactDemandaPerdida_10_1_ind], [fgFactDemandaPerdida_10_2_ind], [fgFactDemandaPerdida_10_3_ind], [fgFactDemandaPerdida_10_4_ind], [fgFactDemandaPerdida_10_5_ind], [fgFactDemandaPerdida_10_6_ind], [fgFactDemandaPerdida_10_7_ind], [fgFactDemandaPerdida_10_8_ind], [fgFactDemandaPerdida_10_9_ind], [fgFactDemandaPerdida_10_10_ind], [fgFactDemandaPerdida_10_11_ind], [fgFactDemandaPerdida_10_12_ind] 
, [fgFactDemandaPerdida_1_1_ind], [fgFactDemandaPerdida_1_2_ind]);
GO

/* ====================================================================================
 Verificar funciones y esquemas de partición
==================================================================================== */
/* Limites minimo y máximo de esquemas de partición
select ps.name as EsquemaParticion, 
 Min(prv.boundary_id) as MinIdParticion,
 Max(prv.boundary_id) as MaxIdParticion,
 Min(prv.[value]) as LimiteMin, Max(prv.[value]) as LimiteMax, 
 Min(Case When pfn.boundary_value_on_right = 0 Then 'L' Else 'R' End) As TipoRango,
 Min(UPPER(t.name)) As TipoDatos
from sys.partition_schemes ps
 inner join sys.partition_functions pfn on ps.function_id = pfn.function_id
 inner join sys.destination_data_spaces as dds on dds.partition_scheme_id = ps.data_space_id and dds.destination_id <= pfn.fanout
 inner join sys.filegroups as fg on fg.data_space_id = dds.data_space_id
 left join sys.partition_range_values prv on pfn.function_id = prv.function_id and prv.boundary_id = dds.destination_id
 inner join sys.partition_parameters pp on pfn.function_id = pp.function_id 
 inner join sys.types t on pp.system_type_id = t.system_type_id
Where ps.name not like '%_ind' 
Group by ps.name
order by ps.name;
*/

/* File groups
select prv.boundary_id as IdParticion, ps.name as EsquemaParticion, fg.name as NombreFileGroup, 
 prv.[value] as Limite, Case When pfn.boundary_value_on_right = 0 Then 'L' Else 'R' End As TipoRango,
 UPPER(t.name) As TipoDatos
from sys.partition_schemes ps
 inner join sys.partition_functions pfn on ps.function_id = pfn.function_id
 inner join sys.destination_data_spaces as dds on dds.partition_scheme_id = ps.data_space_id and dds.destination_id <= pfn.fanout
 inner join sys.filegroups as fg on fg.data_space_id = dds.data_space_id
 left join sys.partition_range_values prv on pfn.function_id = prv.function_id and prv.boundary_id = dds.destination_id
 inner join sys.partition_parameters pp on pfn.function_id = pp.function_id 
 inner join sys.types t on pp.system_type_id = t.system_type_id
Where ps.name not like '%_ind' 
order by ps.name, prv.boundary_id;
*/ 

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - End script: A03PartitonScheme.sql'
PRINT '------------------------------------------------------------------------'
GO