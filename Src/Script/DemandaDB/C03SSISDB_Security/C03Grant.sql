﻿/* ========================================================================== 
Proyecto: DemandaBI
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya 
Fecha: 2020-07-15
Fecha actualizacion: 2020-07-15
========================================================================== */ 

/* ========================================================================== 
VARIABLES PARA INSTALAR:
$(DATABASE_NAME_SSISDB): Nombre de la base de datos. Ejemplo: SSISDB
========================================================================== */

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - Start script: C03Grant.sql'
PRINT '------------------------------------------------------------------------'
GO

USE [$(DATABASE_NAME_SSISDB)];
GO


PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - End script: C03Grant.sql'
PRINT '------------------------------------------------------------------------'
GO