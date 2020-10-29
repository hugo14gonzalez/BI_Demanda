/* ========================================================================== 
Proyecto: DemandaBI
Empresa:  
Desarrollador: Hugo Gonzalez Olaya 
Fecha: 2020-07-15
Fecha actualizacion: 2020-07-15
========================================================================== */ 

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - Start script: D01Agent.sql'
PRINT '------------------------------------------------------------------------'
GO

/* ========================================================================== 
HABILITAR SQL SERVER AGENT
========================================================================== */
sp_configure 'show advanced options', 1
GO
RECONFIGURE WITH OVERRIDE
GO
sp_configure 'Agent XPs', 1
GO
RECONFIGURE WITH OVERRIDE
GO
sp_configure 'show advanced options', 0
GO
RECONFIGURE WITH OVERRIDE
GO

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - End script: D01Agent.sql'
PRINT '------------------------------------------------------------------------'
GO