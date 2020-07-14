/* ========================================================================== 
Proyecto: DemandaBI
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya 
Fecha: 2020-07-15
Fecha actualizacion: 2020-07-15
========================================================================== */ 

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - Start script: Z05Query.sql'
PRINT '------------------------------------------------------------------------'
GO


SET QUOTED_IDENTIFIER OFF;

/* ========================================================================== 
DIMENSION AGENTE
Campo entre comillas dobles: quotename(A.[desAgente],'"') As [Nombre]
========================================================================== */
SELECT A.[AgenteId],A.[AgenteMemId],A.[desAgente] As [Nombre]
,Upper(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(A.[Actividad], 'á' , 'a') , 'é','e') ,'í','i') ,'ó','o' ) ,'ú','u'), '"', '')) As [Actividad]
,C.[CompaniaId]
,Convert (smallint, CASE WHEN A.[estadoAgente] = 'OPERACION' THEN 1 ELSE 0 END) As [Activo]
,Convert(varchar(10), A.[fchIniRegistro], 120) As [FechaIni]
,CASE WHEN A.[fchFinRegistro] IS NULL THEN '' ELSE Convert(varchar(10), A.[fchFinRegistro] + 1, 120) END As [FechaFin]
FROM [dbo].[DimAgente] A WITH(NOLOCK) 
INNER JOIN [dbo].[DimCompania] C WITH(NOLOCK) ON C.[skCompania] = A.[skCompania]
WHERE A.[AgenteId] <> '0' 
ORDER BY A.[AgenteMemId],A.[fchIniRegistro];

/* ========================================================================== 
DIMENSION COMPANIA
Campo entre comillas dobles: quotename([desCompania],'"') As [Nombre]
========================================================================== */
SELECT [CompaniaId],[desCompania] As [Nombre],[siglaCompania] As [Sigla],[nitCompania] As [Nit]
,Upper(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE([TipoPropiedad], 'á' , 'a') , 'é','e') ,'í','i') ,'ó','o' ) ,'ú','u'), '"', '')) As [TipoPropiedad]
,Convert (smallint, CASE WHEN [estadoCompania] = 'OPERACION' THEN 1 ELSE 0 END) As [Activa]
,Convert(varchar(10), [fchIniRegistro], 120) As [FechaIni]
,CASE WHEN [fchFinRegistro] IS NULL THEN '' ELSE Convert(varchar(10), [fchFinRegistro] + 1, 120) END As [FechaFin]
FROM [dbo].[DimCompania] WITH(NOLOCK) 
WHERE [CompaniaId] <> '0'
ORDER BY [CompaniaId],[fchIniRegistro];

/* ========================================================================== 
DIMENSION GEOGRAFIA
========================================================================== */
SELECT [PaisId]
,Upper(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE([desPais], 'á' , 'a') , 'é','e') ,'í','i') ,'ó','o' ) ,'ú','u'), '"', ''))  As [Pais]
,[DepartamentoId]
,Upper(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE([desDepartamento], 'á' , 'a') , 'é','e') ,'í','i') ,'ó','o' ) ,'ú','u'), '"', '')) As [Departamento]
,[MunicipioId]
,Upper(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE([desMunicipio], 'á' , 'a') , 'é','e') ,'í','i') ,'ó','o' ) ,'ú','u'), '"', '')) As [Municipio]
,[AreaId]
,Upper(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE([desArea], 'á' , 'a') , 'é','e') ,'í','i') ,'ó','o' ) ,'ú','u'), '"', ''))  As [Area]
,[SubAreaId]
,Upper(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE([desSubarea], 'á' , 'a') , 'é','e') ,'í','i') ,'ó','o' ) ,'ú','u'), '"', '')) As [SubArea] 
FROM [dbo].[vDimGeografia] WITH(NOLOCK) 
WHERE [tipoGeografia] = 'MUNICIPIO'
ORDER BY [desPais], [desDepartamento],[desMunicipio];

/* ========================================================================== 
DIMENSION MERCADO
========================================================================== */
SELECT [skMercado] As [MercadoId],[Mercado]
FROM [dbo].[DimMercado] WITH(NOLOCK) 
WHERE [skMercado] <> 0
ORDER BY [skMercado];
/*
MercadoId	Mercado
1	INTERMEDIACION
2	NO REGULADO
3	REGULADO
4	CONSUMOS
5	AMBOS
*/

/* ========================================================================== 
DEMANDA REAL Y PERDIDAS
========================================================================== */
SELECT Min([tiempoId]) FechaMin, Max([tiempoId]) FechaMax
FROM [dbo].[FactDemRealPerdidaEnergia];
/*
FechaMin	FechaMax
2012010101	2015021624
*/

/* Flas por mes en promedio: , Tiempo promedio:  seg */
SELECT Convert(varchar(10), Convert(date, Convert(varchar, D.[tiempoId]/100), 120), 120) As [Fecha], T.[Periodo] 
,AD.[AgenteMemId] As [AgenteMemDisId],M.[Mercado],G.[PaisId],G.[DepartamentoId],G.[MunicipioId] 
,D.[demReal] As [DemandaReal],D.[PerdidaEnergia] 
FROM [dbo].[FactDemRealPerdidaEnergia] D WITH(NOLOCK) 
INNER JOIN [dbo].[DimTiempo] T WITH(NOLOCK) ON T.[skTiempo] = D.[skTiempo] 
INNER JOIN [dbo].[vDimGeografia] G WITH(NOLOCK) ON G.[skGeografia] = D.[skGeografia] 
INNER JOIN [dbo].[DimAgente] AD WITH(NOLOCK) ON AD.[skAgente] = D.[skAgenteDistribuidor] 
INNER JOIN [dbo].[DimSubMercado] S WITH(NOLOCK) ON S.[skSubmercado] = D.[skSubmercado] 
INNER JOIN [dbo].[DimMercado] M WITH(NOLOCK) ON M.[skMercado] = S.[skMercado] 
WHERE D.[tiempoId] >= 2012010101 AND D.[tiempoId] < 2012020101 
ORDER BY D.[tiempoId], T.[Periodo], AD.[AgenteMemId], M.[Mercado];

-- Datos agrupados
WITH [CTD_D] AS
(
SELECT Convert(varchar(10), Convert(date, Convert(varchar, D.[tiempoId]/100), 120), 120) As [Fecha], T.[Periodo] 
,AD.[AgenteMemId] As [AgenteMemDisId],M.[Mercado],D.[skGeografia] 
,Sum(D.[demReal]) As [DemandaReal], Sum(D.[PerdidaEnergia]) [PerdidaEnergia]
FROM [dbo].[FactDemRealPerdidaEnergia] D WITH(NOLOCK) 
INNER JOIN [dbo].[DimTiempo] T WITH(NOLOCK) ON T.[skTiempo] = D.[skTiempo] 
INNER JOIN [dbo].[DimAgente] AD WITH(NOLOCK) ON AD.[skAgente] = D.[skAgenteDistribuidor] 
INNER JOIN [dbo].[DimSubMercado] S WITH(NOLOCK) ON S.[skSubmercado] = D.[skSubmercado] 
INNER JOIN [dbo].[DimMercado] M WITH(NOLOCK) ON M.[skMercado] = S.[skMercado] 
WHERE D.[tiempoId] >= 2012010101 AND D.[tiempoId] < 2012010102
GROUP BY D.[tiempoId], T.[Periodo], AD.[AgenteMemId], M.[Mercado], D.[skGeografia]
)
SELECT D.[Fecha],D.[Periodo],D.[AgenteMemDisId],D.[Mercado]
,G.[PaisId],G.[DepartamentoId],G.[MunicipioId],D.[DemandaReal],D.[PerdidaEnergia]
FROM [CTD_D] D
INNER JOIN [dbo].[vDimGeografia] G WITH(NOLOCK) ON G.[skGeografia] = D.[skGeografia] 
ORDER BY D.[Fecha],D.[Periodo],D.[AgenteMemDisId],D.[Mercado],D.[skGeografia];


select * from [vDimGeografia] --where [skGeografia] = 0 
order by 1

SELECT DATEADD(month, DATEDIFF(month, 0, GetDate()), 0);
SELECT DATEADD(month, DATEDIFF(month, 0, GetDate()) + 1, 0);

/* LISTA DE DIAS A PROCESAR */
Declare @dtDateStart date, @dtDateEnd date;

set @dtDateStart = CONVERT(DATE,'2010-01-01', 120);
set @dtDateEnd =  DATEADD(month, DATEDIFF(month, 0, GetDate()), 0); 

-- set @dtDateStart = ?;
-- set @dtDateEnd =  ?; 

;WITH [CTE_Dates] AS 
(
 SELECT 1 [Id], DATEADD(month, DATEDIFF(month, 0, @dtDateStart), 0) as [FechaIni]
	, DATEADD(month, DATEDIFF(month, 0, @dtDateStart), 0) + 1 As [FechaFin]
 UNION ALL
 SELECT [Id] + 1, DATEADD(DAY, 1, [FechaIni]), DATEADD(DAY, 1, [FechaFin])
 FROM [CTE_Dates] 
 WHERE [FechaFin] < @dtDateEnd 
)
SELECT Convert(varchar(8), [FechaIni], 112) + '00' As [FechaIni], Convert(varchar(8), [FechaFin], 112) + '00' As [FechaFin] 
FROM [CTE_Dates]
ORDER BY [Id]
OPTION (MAXRECURSION 10000);
GO


/* LISTA DE MESES A PROCESAR */
Declare @dtDateStart date, @dtDateEnd date;
Set @dtDateStart = CONVERT(DATE,'2010-01-01', 120);
set @dtDateEnd =  DATEADD(month, DATEDIFF(month, 0, GetDate()), 0); 

;WITH [CTE_Dates] AS 
(
 SELECT 1 [Id], DATEADD(month, DATEDIFF(month, 0, @dtDateStart), 0) as [FechaIni]
	, DATEADD(month, DATEDIFF(month, 0, @dtDateStart) + 1, 0) As [FechaFin]
 UNION ALL
 SELECT [Id] + 1, DATEADD(MONTH, 1, [FechaIni]), DATEADD(MONTH, 1, [FechaFin])
 FROM [CTE_Dates] 
 WHERE [FechaFin] < @dtDateEnd 
)
SELECT Convert(varchar(8), [FechaIni], 112) + '00' As [FechaIni], Convert(varchar(8), [FechaFin], 112) + '00' As [FechaFin] 
FROM [CTE_Dates]
ORDER BY [Id]
OPTION (MAXRECURSION 10000);
GO

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - End script: Z05Query.sql'
PRINT '------------------------------------------------------------------------'
GO
