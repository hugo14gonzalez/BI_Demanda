/* ========================================================================== 
Proyecto: DemandaBI
Empresa: Asimatica 
Desarrollador: Hugo Gonzalez Olaya 
Fecha: 2020-07-15
Fecha actualizacion: 2020-07-15
========================================================================== */ 
/* ==========================================================================
Script maestro de despliegue con scripts, a ser ejecutado en el orden escrito, utilizando PowerShell.
Debe modificar las variables segun el entorno (Produccion, pruebas, desarrollo).

:setvar MiVariable "Valor"            : Creacion de variables
$(MiVariable)                         : Utilizar variable en scripts *.sql
:r "Path\MiScript.sql"                : Script a ser desplegado
:r ".\MiScript.sql"                   : Ejemplo ruta relativa
:r $(PATH_DEPLOYMENT)"\A01CreaDB.sql" : Ejemplo ruta absoluta
========================================================================== */
/* ========================================================================== 
DEFINICION DE VARIABLES DE DESPLIEGUE: $(MiVariable)

$(DATABASE_NAME_DW): Nombre de la base de datos. Ejemplo: DemandaDW
$(DATABASE_SERVERNAME_SSIS): Nombre de la instancia del servidor SQL Server donde está el catalogo SSIS. Ejemplo: MISERVIDOR, MISERVIDOR\SQL2019
$(DATABASE_NAME_SSISDB): Nombre de la base de datos de configuracion de ETLs. Ejemplo: SSISDB

$(DATABASE_SERVERNAME_DW): Nombre de la instancia del servidor SQL Server DW. Ejemplo: MISERVIDOR\SQL2019
$(DATABASEOLAP_SERVERNAME_DEMANDA_OLAP): Nombre de la instancia del servidor SQL Server Analysis Services. Ejemplo: MISERVIDOR\SQL2019
$(DATABASEOLAP_NAME_DEMANDA_OLAP): Nombre de la base de datos SQL Server Analysis Services. Ejemplo: Demanda_OLAP

$(DATABASE_PROXYWINDOWSUSER): Usuario de Windows usado para crear cuenta proxy. Ejemplo: MiDominio\MiUsuario
$(DATABASE_USR_DemandaDW_PASSWORD_DW): Contraseña para el usuario: USR_DemandaDW, en el servidor DW. Ejemplo: <REPLACE_ME>

$(SSISDB_FOLDER): Carpeta de despliegue de paquetes (ETLs) en el catálogo SSISDB. Ejemplo: Demanda
$(SSISDB_PROJECT): Nombre de proyecto que contiene los paquetes (ETLs). Ejemplo: DemandaBI_SSIS
$(SSISDB_PROJECT_DATA): Nombre de proyecto que contiene los paquetes (ETLs) para extraer datos. Ejemplo: DemandaBI_Datos_SSIS
$(SSISDB_ENVIRONMENT): Ambiente de despliegue, en el cual configurar variables de paquetes (ETLs). Ejemplo: Produccion, Pruebas, Desarrollo.

$(SSISDB_PATH_ERROR): Carpeta en disco de archivos con error. Ejemplo: \\MISERVIDOR\ETL_Log\DemandaBI\Error, \\MISERVIDOR\ETL_Log\Pruebas\DemandaBI\Error
$(SSISDB_PATH_PROCESADOS): Carpeta en disco de archivos procesados en forma satisfactoria. Ejemplo: \\MISERVIDOR\ETL_Log\DemandaBI\Procesados, \\MISERVIDOR\ETL_Log\Pruebas\DemandaBI\Procesados
$(SSISDB_PATH_SINPROCESAR): Carpeta en disco de archivos sin procesar. Ejemplo: \\MISERVIDOR\ETL_Log\DemandaBI\SinProcesar, \\MISERVIDOR\ETL_Log\Pruebas\DemandaBI\SinProcesar
$(SSISDB_PATH_LOG): Carpeta en disco de log de ETLs. 
 Ejemplo Producción: \\MISERVIDOR\ETL_Log\DemandaBI
 Ejemplo Pruebas: \\MISERVIDOR\ETL_Log\Pruebas\DemandaBI
========================================================================== */ 

/* IMPORTANTE: Establer ruta principal de scripts, esta variable es modificada por script PowerShell */
:setvar PATH_DEPLOYMENT "C:\Hugo\DirProject\DemandaBI\Src\Script\DemandaDB"

/* Produccion: MVMOAN172A\SQL2019, Desarrollo: HUGO\SQL2019 */
:setvar DATABASE_SERVERNAME_DW "HUGO\SQL2019"
:setvar DATABASE_NAME_DW "DemandaDW"

:setvar DATABASE_SERVERNAME_SSIS "HUGO\SQL2019"
:setvar DATABASE_NAME_SSISDB "SSISDB"

:setvar DATABASEOLAP_SERVERNAME_DEMANDA_OLAP "HUGO\SQL2019"
:setvar DATABASEOLAP_NAME_DEMANDA_OLAP "Demanda_OLAP"

/* Produccion: MVM\hugo.gonzalez, Desarrollo: HUGO\Hugo */
:setvar DATABASE_PROXYWINDOWSUSER "HUGO\Hugo"

:setvar DATABASE_USR_DemandaDW_PASSWORD_DW "USR_DemandaDW00*"

/* Produccion, Pruebas, Desarrollo */
:setvar SSISDB_ENVIRONMENT "Produccion"
:setvar SSISDB_FOLDER "Demanda"
:setvar SSISDB_PROJECT "DemandaBI_SSIS"
:setvar SSISDB_PROJECT_DATA "DemandaBI_Datos_SSIS"

/* Produccion: \\MVMOAN172A\ETL_Log\DemandaBI\, Desarrollo: \\Hugo\ETL_Log\DemandaBI\ */
:setvar SSISDB_PATH_ERROR "\\HUGO\ETL_Log\DemandaBI\Error"
:setvar SSISDB_PATH_PROCESADOS "\\HUGO\ETL_Log\DemandaBI\Procesados"
:setvar SSISDB_PATH_SINPROCESAR "\\HUGO\ETL_Log\DemandaBI\SinProcesar"
:setvar SSISDB_PATH_LOG "\\HUGO\ETL_Log\DemandaBI"

PRINT '------------------------------------------------------------------------';
PRINT 'START DEPLOYMENT: A01DeploymentETL_Desarrollo.sql';
PRINT '------------------------------------------------------------------------';
PRINT 'Despliegue en el servidor: ' + @@SERVERNAME + '. Desde el computador: ' + Convert(nvarchar(200), HOST_NAME());
PRINT 'Fecha inicio: ' + Convert(nvarchar(20), GetDate(), 120);
PRINT 'Ruta despliegue: $(PATH_DEPLOYMENT)';
PRINT '';
GO

:on ERROR EXIT

/* ==========================================================================
SCRIPTS A DESPLEGAR (:r )
========================================================================== */
:r $(PATH_DEPLOYMENT)"\A03SSISDB\A01SSIS_Folder.sql" 
:r $(PATH_DEPLOYMENT)"\A03SSISDB\A02SSIS_Parameters.sql" 

:r $(PATH_DEPLOYMENT)"\C03SSISDB_Security\C01User.sql" 
:r $(PATH_DEPLOYMENT)"\C03SSISDB_Security\C02Rol.sql" 
:r $(PATH_DEPLOYMENT)"\C03SSISDB_Security\C03Grant.sql" 

:r $(PATH_DEPLOYMENT)"\D01SQLAgent\D04Jobs.sql" 
GO
 
PRINT '';
PRINT 'Fecha fin: ' + Convert(nvarchar(20), GetDate(), 120);
PRINT '------------------------------------------------------------------------';
PRINT 'END DEPLOYMENT: A01DeploymentETL_Desarrollo.sql'
PRINT '------------------------------------------------------------------------';
GO
