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

$(DATABASE_SERVERNAME_DW): Nombre de la instancia del servidor SQL Server DW. Ejemplo: MISERVIDOR\SQL2019
$(DATABASEOLAP_SERVERNAME_Demanda_OLAP): Nombre de la instancia del servidor SQL Server Analysis Services. Ejemplo: MISERVIDOR\SQL2019
$(DATABASEOLAP_NAME_DEMANDA_OLAP): Nombre de la base de datos SQL Server Analysis Services. Ejemplo: Demanda_OLAP

$(DATABASE_USR_DEMANDADW_PASSWORD_DW): Password para el usuario: USR_DemandaDW, en el servidor DW. Ejemplo: <REPLACE_ME>

$(SSISDB_FOLDER): Carpeta de despliegue de paquetes (ETLs) en el catalogo SSISDB. Ejemplo: Demanda
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

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - Start script: A02SSIS_Parameters.sql'
PRINT '------------------------------------------------------------------------'
GO

USE [SSISDB];
/* ====================================================================================
 PARAMETROS
==================================================================================== */

--Global definitions:
---------------------
DECLARE @destinationFolderReplacements      nvarchar(max)   = NULL      -- Specify destination folder replacements.
DECLARE @processReferences                  bit             = 1        -- Specify whether to process references
DECLARE @destinationEnvironmentReplacements nvarchar(max)   = NULL      -- Specify destination environment replacements.
 
 
--Declaration Definitions:
--------------------------
DECLARE
     @folder_name           nvarchar(128)
    ,@project_name          nvarchar(128)
    ,@object_type           smallint
    ,@object_name           nvarchar(260)
    ,@parameter_name        nvarchar(128)
    ,@value_type            char(1)
    ,@parameter_value       sql_variant
    ,@reference_type        char(1)
    ,@environment_name      nvarchar(128)
    ,@environment_folder    nvarchar(128)

DECLARE @parameters TABLE (
     folder_name        nvarchar(128)
    ,project_name       nvarchar(128)
    ,object_type        smallint
    ,object_name        nvarchar(260)
    ,parameter_name     nvarchar(128)
    ,value_type         char(1)
    ,parameter_value    sql_variant
)

DECLARE @references TABLE (
     folder_name                nvarchar(128)
    ,project_name               nvarchar(128)
    ,reference_type             char(1)
    ,environment_folder_name    nvarchar(128)
    ,environment_name           nvarchar(128)
)


SET NOCOUNT ON;

-- =================================================================================
-- Folder: Demanda
-- =================================================================================
SET @folder_name = '$(SSISDB_FOLDER)';
-- *********************************************************************************
-- Project: DemandaBI_Datos_SSIS
-- *********************************************************************************
SET @project_name = '$(SSISDB_PROJECT_DATA)';
-- *********************************************************************************
-- Object: pkgDemandaBI.dtsx
-- --------------------------------------------------------------------------------
SET @object_name = N'pkgDemandaBI.dtsx'
SET @object_type = 30   -- Package
-- --------------------------------------------------------------------------------
SET @parameter_name     = N'FechaFactFin'
SET @value_type         = 'V' --Value
SET @parameter_value    = CONVERT(datetime, N'2019-11-01T00:00:00');
INSERT INTO @parameters(folder_name, project_name, object_type, object_name, parameter_name, value_type, parameter_value) VALUES (@folder_name, @project_name, @object_type, @object_name, @parameter_name, @value_type, @parameter_value) 
-- ---------------
SET @parameter_name     = N'FechaFactIni'
SET @value_type         = 'V' --Value
SET @parameter_value    = CONVERT(datetime, N'2019-10-01T00:00:00');
INSERT INTO @parameters(folder_name, project_name, object_type, object_name, parameter_name, value_type, parameter_value) VALUES (@folder_name, @project_name, @object_type, @object_name, @parameter_name, @value_type, @parameter_value) 
-- ---------------
SET @parameter_name     = N'FolderDestino'
SET @value_type         = 'V' --Value
SET @parameter_value    = N'D:\Temp\DemandaBI';
INSERT INTO @parameters(folder_name, project_name, object_type, object_name, parameter_name, value_type, parameter_value) VALUES (@folder_name, @project_name, @object_type, @object_name, @parameter_name, @value_type, @parameter_value) 
-- *********************************************************************************
-- Project: DemandaBI_SSIS
-- *********************************************************************************
SET @project_name = '$(SSISDB_PROJECT)';
-- *********************************************************************************
-- Object: DemandaBI_SSIS
-- --------------------------------------------------------------------------------
SET @object_name = '$(SSISDB_PROJECT)';
SET @object_type = 20   -- Project
-- --------------------------------------------------------------------------------
SET @parameter_name     = N'dsDemanda_OLAP_ConnectionString'
SET @value_type         = 'V' --Value
SET @parameter_value    = N'Data Source=$(DATABASEOLAP_SERVERNAME_Demanda_OLAP);Initial Catalog=$(DATABASEOLAP_NAME_DEMANDA_OLAP);Provider=MSOLAP.8;Integrated Security=SSPI;Impersonation Level=Impersonate';
INSERT INTO @parameters(folder_name, project_name, object_type, object_name, parameter_name, value_type, parameter_value) VALUES (@folder_name, @project_name, @object_type, @object_name, @parameter_name, @value_type, @parameter_value) 
-- ---------------
SET @parameter_name     = N'dsDemandaDW_ConnectionString'
SET @value_type         = 'V' --Value
SET @parameter_value    = N'Data Source=$(DATABASE_SERVERNAME_DW);User ID=USR_DemandaDW;Initial Catalog=$(DATABASE_NAME_DW);Provider=SQLNCLI11.1;Persist Security Info=True;Auto Translate=False;';
INSERT INTO @parameters(folder_name, project_name, object_type, object_name, parameter_name, value_type, parameter_value) VALUES (@folder_name, @project_name, @object_type, @object_name, @parameter_name, @value_type, @parameter_value) 
-- ---------------
SET @parameter_name     = N'dsDemandaDW_Password'
SET @value_type         = 'V' --Value
SET @parameter_value    = N'$(DATABASE_USR_DEMANDADW_PASSWORD_DW)';    -- !! SENSITIVE !!
INSERT INTO @parameters(folder_name, project_name, object_type, object_name, parameter_name, value_type, parameter_value) VALUES (@folder_name, @project_name, @object_type, @object_name, @parameter_name, @value_type, @parameter_value) 
-- ---------------
SET @parameter_name     = N'FolderError'
SET @value_type         = 'V' --Value
SET @parameter_value    = N'$(SSISDB_PATH_ERROR)';
INSERT INTO @parameters(folder_name, project_name, object_type, object_name, parameter_name, value_type, parameter_value) VALUES (@folder_name, @project_name, @object_type, @object_name, @parameter_name, @value_type, @parameter_value) 
-- ---------------
SET @parameter_name     = N'FolderLog'
SET @value_type         = 'V' --Value
SET @parameter_value    = N'$(SSISDB_PATH_LOG)';
INSERT INTO @parameters(folder_name, project_name, object_type, object_name, parameter_name, value_type, parameter_value) VALUES (@folder_name, @project_name, @object_type, @object_name, @parameter_name, @value_type, @parameter_value) 
-- ---------------
SET @parameter_name     = N'FolderProcesados'
SET @value_type         = 'V' --Value
SET @parameter_value    = N'$(SSISDB_PATH_PROCESADOS)';
INSERT INTO @parameters(folder_name, project_name, object_type, object_name, parameter_name, value_type, parameter_value) VALUES (@folder_name, @project_name, @object_type, @object_name, @parameter_name, @value_type, @parameter_value) 
-- ---------------
SET @parameter_name     = N'FolderSinProcesar'
SET @value_type         = 'V' --Value
SET @parameter_value    = N'$(SSISDB_PATH_SINPROCESAR)';
INSERT INTO @parameters(folder_name, project_name, object_type, object_name, parameter_name, value_type, parameter_value) VALUES (@folder_name, @project_name, @object_type, @object_name, @parameter_name, @value_type, @parameter_value) 
-- --------------------------------------------------------------------------------
-- Object: pkgCubeDimProcess.dtsx
-- --------------------------------------------------------------------------------
SET @object_name = N'pkgCubeDimProcess.dtsx'
SET @object_type = 30   -- Package
-- --------------------------------------------------------------------------------
SET @parameter_name     = N'BitacoraParentId'
SET @value_type         = 'V' --Value
SET @parameter_value    = CONVERT(bigint, N'0');
INSERT INTO @parameters(folder_name, project_name, object_type, object_name, parameter_name, value_type, parameter_value) VALUES (@folder_name, @project_name, @object_type, @object_name, @parameter_name, @value_type, @parameter_value) 
-- ---------------
SET @parameter_name     = N'IsProcessFull'
SET @value_type         = 'V' --Value
SET @parameter_value    = CONVERT(bit, N'0');
INSERT INTO @parameters(folder_name, project_name, object_type, object_name, parameter_name, value_type, parameter_value) VALUES (@folder_name, @project_name, @object_type, @object_name, @parameter_name, @value_type, @parameter_value) 
-- ---------------
SET @parameter_name     = N'ModelCDimId'
SET @value_type         = 'V' --Value
SET @parameter_value    = N'DW_CDim';
INSERT INTO @parameters(folder_name, project_name, object_type, object_name, parameter_name, value_type, parameter_value) VALUES (@folder_name, @project_name, @object_type, @object_name, @parameter_name, @value_type, @parameter_value) 
-- ---------------
SET @parameter_name     = N'QueryId'
SET @value_type         = 'V' --Value
SET @parameter_value    = N'DW_CProcDim';
INSERT INTO @parameters(folder_name, project_name, object_type, object_name, parameter_name, value_type, parameter_value) VALUES (@folder_name, @project_name, @object_type, @object_name, @parameter_name, @value_type, @parameter_value) 
-- ---------------
SET @parameter_name     = N'UseQueryDataBase'
SET @value_type         = 'V' --Value
SET @parameter_value    = CONVERT(bit, N'0');
INSERT INTO @parameters(folder_name, project_name, object_type, object_name, parameter_name, value_type, parameter_value) VALUES (@folder_name, @project_name, @object_type, @object_name, @parameter_name, @value_type, @parameter_value) 
-- --------------------------------------------------------------------------------
-- Object: pkgCubePartitionCreate.dtsx
-- --------------------------------------------------------------------------------
SET @object_name = N'pkgCubePartitionCreate.dtsx'
SET @object_type = 30   -- Package
-- --------------------------------------------------------------------------------
SET @parameter_name     = N'BitacoraParentId'
SET @value_type         = 'V' --Value
SET @parameter_value    = CONVERT(bigint, N'0');
INSERT INTO @parameters(folder_name, project_name, object_type, object_name, parameter_name, value_type, parameter_value) VALUES (@folder_name, @project_name, @object_type, @object_name, @parameter_name, @value_type, @parameter_value) 
-- --------------------------------------------------------------------------------
-- Object: pkgCubePartitionProcess.dtsx
-- --------------------------------------------------------------------------------
SET @object_name = N'pkgCubePartitionProcess.dtsx'
SET @object_type = 30   -- Package
-- --------------------------------------------------------------------------------
SET @parameter_name     = N'BitacoraParentId'
SET @value_type         = 'V' --Value
SET @parameter_value    = CONVERT(bigint, N'0');
INSERT INTO @parameters(folder_name, project_name, object_type, object_name, parameter_name, value_type, parameter_value) VALUES (@folder_name, @project_name, @object_type, @object_name, @parameter_name, @value_type, @parameter_value) 
-- ---------------
SET @parameter_name     = N'IsProcessFull'
SET @value_type         = 'V' --Value
SET @parameter_value    = CONVERT(bit, N'1');
INSERT INTO @parameters(folder_name, project_name, object_type, object_name, parameter_name, value_type, parameter_value) VALUES (@folder_name, @project_name, @object_type, @object_name, @parameter_name, @value_type, @parameter_value) 
-- --------------------------------------------------------------------------------
-- Object: pkgDimAgente.dtsx
-- --------------------------------------------------------------------------------
SET @object_name = N'pkgDimAgente.dtsx'
SET @object_type = 30   -- Package
-- --------------------------------------------------------------------------------
SET @parameter_name     = N'BitacoraParentId'
SET @value_type         = 'V' --Value
SET @parameter_value    = CONVERT(bigint, N'0');
INSERT INTO @parameters(folder_name, project_name, object_type, object_name, parameter_name, value_type, parameter_value) VALUES (@folder_name, @project_name, @object_type, @object_name, @parameter_name, @value_type, @parameter_value) 
-- ---------------
SET @parameter_name     = N'FileData'
SET @value_type         = 'V' --Value
SET @parameter_value    = N'DimAgente.csv';
INSERT INTO @parameters(folder_name, project_name, object_type, object_name, parameter_name, value_type, parameter_value) VALUES (@folder_name, @project_name, @object_type, @object_name, @parameter_name, @value_type, @parameter_value) 
-- ---------------
SET @parameter_name     = N'ModelDimId'
SET @value_type         = 'V' --Value
SET @parameter_value    = N'DW_DDim';
INSERT INTO @parameters(folder_name, project_name, object_type, object_name, parameter_name, value_type, parameter_value) VALUES (@folder_name, @project_name, @object_type, @object_name, @parameter_name, @value_type, @parameter_value) 
-- --------------------------------------------------------------------------------
-- Object: pkgDimCompania.dtsx
-- --------------------------------------------------------------------------------
SET @object_name = N'pkgDimCompania.dtsx'
SET @object_type = 30   -- Package
-- --------------------------------------------------------------------------------
SET @parameter_name     = N'BitacoraParentId'
SET @value_type         = 'V' --Value
SET @parameter_value    = CONVERT(bigint, N'0');
INSERT INTO @parameters(folder_name, project_name, object_type, object_name, parameter_name, value_type, parameter_value) VALUES (@folder_name, @project_name, @object_type, @object_name, @parameter_name, @value_type, @parameter_value) 
-- ---------------
SET @parameter_name     = N'FileData'
SET @value_type         = 'V' --Value
SET @parameter_value    = N'DimCompania.csv';
INSERT INTO @parameters(folder_name, project_name, object_type, object_name, parameter_name, value_type, parameter_value) VALUES (@folder_name, @project_name, @object_type, @object_name, @parameter_name, @value_type, @parameter_value) 
-- ---------------
SET @parameter_name     = N'ModelDimId'
SET @value_type         = 'V' --Value
SET @parameter_value    = N'DW_DDim';
INSERT INTO @parameters(folder_name, project_name, object_type, object_name, parameter_name, value_type, parameter_value) VALUES (@folder_name, @project_name, @object_type, @object_name, @parameter_name, @value_type, @parameter_value) 
-- --------------------------------------------------------------------------------
-- Object: pkgDimGeografia.dtsx
-- --------------------------------------------------------------------------------
SET @object_name = N'pkgDimGeografia.dtsx'
SET @object_type = 30   -- Package
-- --------------------------------------------------------------------------------
SET @parameter_name     = N'BitacoraParentId'
SET @value_type         = 'V' --Value
SET @parameter_value    = CONVERT(bigint, N'0');
INSERT INTO @parameters(folder_name, project_name, object_type, object_name, parameter_name, value_type, parameter_value) VALUES (@folder_name, @project_name, @object_type, @object_name, @parameter_name, @value_type, @parameter_value) 
-- ---------------
SET @parameter_name     = N'FileData'
SET @value_type         = 'V' --Value
SET @parameter_value    = N'DimGeografia.csv';
INSERT INTO @parameters(folder_name, project_name, object_type, object_name, parameter_name, value_type, parameter_value) VALUES (@folder_name, @project_name, @object_type, @object_name, @parameter_name, @value_type, @parameter_value) 
-- ---------------
SET @parameter_name     = N'ModelDimId'
SET @value_type         = 'V' --Value
SET @parameter_value    = N'DW_DDim';
INSERT INTO @parameters(folder_name, project_name, object_type, object_name, parameter_name, value_type, parameter_value) VALUES (@folder_name, @project_name, @object_type, @object_name, @parameter_name, @value_type, @parameter_value) 
-- --------------------------------------------------------------------------------
-- Object: pkgFactDemandaPerdida.dtsx
-- --------------------------------------------------------------------------------
SET @object_name = N'pkgFactDemandaPerdida.dtsx'
SET @object_type = 30   -- Package
-- --------------------------------------------------------------------------------
SET @parameter_name     = N'BitacoraParentId'
SET @value_type         = 'V' --Value
SET @parameter_value    = CONVERT(bigint, N'0');
INSERT INTO @parameters(folder_name, project_name, object_type, object_name, parameter_name, value_type, parameter_value) VALUES (@folder_name, @project_name, @object_type, @object_name, @parameter_name, @value_type, @parameter_value) 
-- ---------------
SET @parameter_name     = N'FormatFolder'
SET @value_type         = 'V' --Value
SET @parameter_value    = N'yyyy/MM';
INSERT INTO @parameters(folder_name, project_name, object_type, object_name, parameter_name, value_type, parameter_value) VALUES (@folder_name, @project_name, @object_type, @object_name, @parameter_name, @value_type, @parameter_value) 
-- ---------------
SET @parameter_name     = N'FormtatFileData'
SET @value_type         = 'V' --Value
SET @parameter_value    = N'FactDemandaPerdida_{yyyyMMdd}.csv';
INSERT INTO @parameters(folder_name, project_name, object_type, object_name, parameter_name, value_type, parameter_value) VALUES (@folder_name, @project_name, @object_type, @object_name, @parameter_name, @value_type, @parameter_value) 
-- --------------------------------------------------------------------------------
-- Object: pkgFull.dtsx
-- --------------------------------------------------------------------------------
SET @object_name = N'pkgFull.dtsx'
SET @object_type = 30   -- Package
-- --------------------------------------------------------------------------------
SET @parameter_name     = N'ModelDimId'
SET @value_type         = 'V' --Value
SET @parameter_value    = N'DW_DDim';
INSERT INTO @parameters(folder_name, project_name, object_type, object_name, parameter_name, value_type, parameter_value) VALUES (@folder_name, @project_name, @object_type, @object_name, @parameter_name, @value_type, @parameter_value) 
-- ---------------
SET @parameter_name     = N'ModelFullId'
SET @value_type         = 'V' --Value
SET @parameter_value    = N'DW_DFull';
INSERT INTO @parameters(folder_name, project_name, object_type, object_name, parameter_name, value_type, parameter_value) VALUES (@folder_name, @project_name, @object_type, @object_name, @parameter_name, @value_type, @parameter_value) 
 
-- =================================================================================
--                            COMMON RUNTIME
-- =================================================================================

DECLARE
     @processFld            bit
    ,@lastFolderName        nvarchar(128)
    ,@fld                   nvarchar(128)
    ,@xml                   xml
    ,@msg                   nvarchar(max)
    ,@oldVal                nvarchar(128)
    ,@newVal                nvarchar(128)
    ,@error                 bit             = 0;
    

--Table for holding folder replacements
DECLARE @folderReplacements TABLE (
    SortOrder       int             NOT NULL    PRIMARY KEY CLUSTERED
    ,OldValue       nvarchar(128)
    ,NewValue       nvarchar(128)
    ,Replacement    nvarchar(4000)
)

--Folder Replacements
SET @xml = N'<i>' + REPLACE(@destinationFolderReplacements, ',', '</i><i>') + N'</i>';
WITH Replacements AS (
    SELECT DISTINCT
        LTRIM(RTRIM(F.value('.', 'nvarchar(128)'))) AS Replacement
        ,ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS Ord
    FROM @xml.nodes(N'/i') T(F)
)
INSERT INTO @folderReplacements(SortOrder, OldValue, NewValue, Replacement)
SELECT
    Ord
    ,LEFT(Replacement, CASE WHEN CHARINDEX('=', Replacement, 1) = 0 THEN 0 ELSE CHARINDEX('=', Replacement, 1) - 1 END) AS OldValue
    ,RIGHT(Replacement, LEN(Replacement) - CHARINDEX('=', Replacement, 1)) AS NewValue
    ,Replacement
FROM Replacements

IF EXISTS(SELECT 1 FROM @folderReplacements WHERE OldValue IS NULL OR OldValue = N'')
BEGIN
    SET @msg = STUFF((SELECT N',' + Replacement FROM @folderReplacements WHERE OldValue IS NULL OR OldValue = N'' FOR XML PATH('')), 1, 1, '')
    SET @error = 1
    RAISERROR(N'Following folder replacements are not valid: %s', 15, 0, @msg) WITH NOWAIT;
    RETURN;
END

    --Table for holding environment replacements
    DECLARE @environmentReplacements TABLE (
        SortOrder       int             NOT NULL    PRIMARY KEY CLUSTERED
        ,OldValue       nvarchar(128)
        ,NewValue       nvarchar(128)
        ,Replacement    nvarchar(4000)
    )
    

    SET @xml = N'<i>' + REPLACE(@destinationEnvironmentReplacements, ',', '</i><i>') + N'</i>';
    WITH Replacements AS (
        SELECT DISTINCT
            LTRIM(RTRIM(F.value('.', 'nvarchar(128)'))) AS Replacement
            ,ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS Ord
        FROM @xml.nodes(N'/i') T(F)
    )
    INSERT INTO @environmentReplacements(SortOrder, OldValue, NewValue, Replacement)
    SELECT
        Ord
        ,LEFT(Replacement, CASE WHEN CHARINDEX('=', Replacement, 1) = 0 THEN 0 ELSE CHARINDEX('=', Replacement, 1) - 1 END) AS OldValue
        ,RIGHT(Replacement, LEN(Replacement) - CHARINDEX('=', Replacement, 1)) AS NewValue
        ,Replacement
    FROM Replacements

    IF EXISTS(SELECT 1 FROM @environmentReplacements WHERE OldValue IS NULL OR OldValue = N'')
    BEGIN
        SET @msg = STUFF((SELECT N',' + Replacement FROM @environmentReplacements WHERE OldValue IS NULL OR OldValue = N'' FOR XML PATH('')), 1, 1, '')
        SET @error = 1
        RAISERROR(N'Following environment replacements are not valid: %s', 15, 0, @msg) WITH NOWAIT;
        RETURN;
    END    
    
 
-- =================================================================================
--                              CONFIGURATION RUNTIME
-- =================================================================================
DECLARE
     @lastProjectName       nvarchar(128)
    ,@lastObjectName        nvarchar(260)
    ,@lastObjectType        smallint
    ,@processProject        bit
    ,@processObject         bit
    ,@reference_id          bigint


RAISERROR(N'', 0, 0) WITH NOWAIT;
RAISERROR(N'#################################################################################', 0, 0) WITH NOWAIT;
RAISERROR(N'                            PROCESSING CONFIGURATIONS', 0, 0) WITH NOWAIT;
RAISERROR(N'#################################################################################', 0, 0) WITH NOWAIT;

SELECT
    @lastFolderName = NULL
    ,@processFld    = NULL

DECLARE cr CURSOR FAST_FORWARD FOR
SELECT
     folder_name
    ,project_name
    ,object_type
    ,object_name
    ,parameter_name
    ,value_type
    ,parameter_value
FROM @parameters

OPEN cr;

FETCH NEXT FROM cr INTO @fld, @project_name, @object_type, @object_name, @parameter_name, @value_type, @parameter_value
WHILE @@FETCH_STATUS = 0
BEGIN
    IF @lastFolderName IS NULL OR @lastFolderName <> @fld
    BEGIN
        SET @processFld = 1
        SET @folder_name = @fld
        SET @lastProjectName = NULL
        IF @lastFolderName IS NOT NULL
            RAISERROR(N'===================================================================', 0, 0) WITH NOWAIT;


        IF EXISTS(SELECT 1 FROM @folderReplacements)
        BEGIN
            DECLARE rc CURSOR FAST_FORWARD FOR
            SELECT
                OldValue
                ,NewValue
            FROM @folderReplacements
            ORDER BY SortOrder

            OPEN rc;
            
            FETCH NEXT FROM rc INTO @oldVal, @newVal

            WHILE @@FETCH_STATUS = 0
            BEGIN
                SET @folder_name = REPLACE(@folder_name, @oldVal, @newVal)
                FETCH NEXT FROM rc INTO @oldVal, @newVal
            END

            CLOSE rc;
            DEALLOCATE rc;
        END


        IF NOT EXISTS(SELECT 1 FROM [SSISDB].[catalog].[folders] f WHERE f.[name] = @folder_name)
        BEGIN
            SET @processFld = 0
            RAISERROR(N'Destination folder [%s] does not exist. Ignoring projects in folder', 11, 0, @folder_name) WITH NOWAIT;
        END
        ELSE
        BEGIN
            RAISERROR(N'Processing folder [%s]', 0, 0, @folder_name) WITH NOWAIT;
        END
        RAISERROR(N'===================================================================', 0, 0) WITH NOWAIT;
    END

    IF @processFld = 1 AND (@lastProjectName IS NULL OR @lastProjectName <> @project_name)
    BEGIN
        SET @processProject = 1;
        SET @lastObjectName = NULL;
        IF @lastProjectName IS NOT NULL
            RAISERROR(N'*******************************************************************', 0, 0) WITH NOWAIT;

        IF NOT EXISTS(
            SELECT
                1
            FROM [SSISDB].[catalog].[projects] p
            INNER JOIN [SSISDB].[catalog].[folders] f ON f.folder_id = p.folder_id
            WHERE
                f.name = @folder_name
                AND
                p.name = @project_name
        )
        BEGIN
            SET @processProject = 0;
            RAISERROR(N'Destination project [%s]\[%s] does not exists. Ignoring project objects', 11, 1, @folder_name, @project_name) WITH NOWAIT;
        END
        ELSE
        BEGIN
            RAISERROR(N'Processing Project: [%s]\[%s]', 0, 0, @folder_name, @project_name) WITH NOWAIT;
        END            
        RAISERROR(N'*******************************************************************', 0, 0) WITH NOWAIT;


        IF @processReferences = 1 AND EXISTS(SELECT 1 FROM @references WHERE folder_name = @fld and project_name = @project_name)
        BEGIN
            DECLARE rc CURSOR FAST_FORWARD FOR
            SELECT
                reference_type
                ,environment_folder_name
                ,environment_name
            FROM @references
            WHERE 
                folder_name = @fld 
                AND
                project_name = @project_name

            OPEN rc;

            FETCH NEXT FROM rc INTO @reference_type, @environment_folder, @environment_name

            WHILE @@FETCH_STATUS = 0
            BEGIN

                IF @reference_type = 'A' AND EXISTS(SELECT 1 FROM @folderReplacements)
                BEGIN
                    DECLARE fr CURSOR FAST_FORWARD FOR
                    SELECT
                        OldValue
                        ,NewValue
                    FROM @folderReplacements
                    ORDER BY SortOrder

                    OPEN fr;
            
                    FETCH NEXT FROM fr INTO @oldVal, @newVal

                    WHILE @@FETCH_STATUS = 0
                    BEGIN
                        SET @environment_folder = REPLACE(@environment_folder, @oldVal, @newVal)
                        FETCH NEXT FROM fr INTO @oldVal, @newVal
                    END

                    CLOSE fr;
                    DEALLOCATE fr;
                END


                IF EXISTS(SELECT 1 FROM @environmentReplacements)
                BEGIN
                    DECLARE re CURSOR FAST_FORWARD FOR
                    SELECT
                        OldValue
                        ,NewValue
                    FROM @environmentReplacements
                    ORDER BY SortOrder

                    OPEN re;
            
                    FETCH NEXT FROM re INTO @oldVal, @newVal

                    WHILE @@FETCH_STATUS = 0
                    BEGIN
                        SET @environment_name = REPLACE(@environment_name, @oldVal, @newVal)
                        FETCH NEXT FROM re INTO @oldVal, @newVal
                    END

                    CLOSE re;
                    DEALLOCATE re;
                END

                IF EXISTS (
                    SELECT
                        1
                    FROM [SSISDB].[catalog].[environment_references] er
                    INNER JOIN [SSISDB].[catalog].[projects] p ON p.project_id = er.project_id
                    INNER JOIN [SSISDB].[catalog].[folders] f ON f.folder_id = p.folder_id
                    WHERE
                        f.name = @folder_name
                        AND
                        p.name = @project_name
                        AND
                        er.reference_type = @reference_type
                        AND
                        (er.environment_folder_name = @environment_folder OR (er.environment_folder_name IS NULL AND @environment_folder IS NULL))
                        AND
                        er.environment_name = @environment_name
                    )

                    BEGIN
                        IF @reference_type = 'A'
                            RAISERROR(N'Reference to environment [%s]\[%s] already exists', 0, 0, @environment_folder, @environment_name) WITH NOWAIT;
                        ELSE
                            RAISERROR(N'Reference to local environment [%s] already exists.', 0, 0, @environment_name) WITH NOWAIT;
                    END
                    ELSE
                    BEGIN
                        IF NOT EXISTS(
                            SELECT 
                                1 
                            FROM [SSISDB].[catalog].[environments] e 
                            INNER JOIN [SSISDB].[catalog].[folders] f on f.folder_id = e.folder_id
                            WHERE
                                e.name = @environment_name
                                AND
                                (
                                    (@reference_type = 'A' AND f.name = @environment_folder)
                                    OR
                                    (@reference_type = 'R' AND f.name = @folder_name)
                                )
                        )
                        BEGIN
                            IF @reference_type = 'A'
                                RAISERROR(N'Referenced environment [%s]\[%s] does not exists', 11, 1, @environment_folder, @environment_name) WITH NOWAIT;
                            ELSE
                                RAISERROR(N'Referenced local environment [%s] does not exists', 11, 2, @environment_name) WITH NOWAIT;                            
                        END
                        ELSE
                        BEGIN
                            IF @reference_type = 'A'
                                RAISERROR(N'Setting Reference to environment [%s]\[%s]', 0, 0, @environment_folder, @environment_name) WITH NOWAIT;
                            ELSE
                                RAISERROR(N'Setting Reference to local environment [%s]', 0, 0, @environment_name) WITH NOWAIT;

                            EXEC [SSISDB].[catalog].[create_environment_reference] @environment_name=@environment_name, @environment_folder_name=@environment_folder, @reference_id=@reference_id OUTPUT, @project_name=@project_name, @folder_name=@folder_name, @reference_type=@reference_type
                        END
                    END
                FETCH NEXT FROM rc INTO @reference_type, @environment_folder, @environment_name
            END
            CLOSE rc;
            DEALLOCATE rc;
            RAISERROR(N'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++', 0, 0) WITH NOWAIT;
        END
    END
    IF @processProject = 1 AND (@lastObjectName IS NULL OR @lastObjectType IS NULL OR @lastObjectName <> @object_name OR @lastObjectType <> @object_type)
    BEGIN
        SET @processObject = 1
        IF @lastObjectName IS NOT NULL
            RAISERROR(N'-------------------------------------------------------------------', 0, 0) WITH NOWAIT;

        IF NOT EXISTS(
            SELECT
                *
            FROM [SSISDB].[catalog].[object_parameters] op
            INNER JOIN [SSISDB].[catalog].[projects] p ON p.project_id = op.project_id
            INNER JOIN [SSISDB].[catalog].folders f ON f.folder_id = p.folder_id
            WHERE
                f.name = @folder_name
                AND
                p.name = @project_name
                AND
                op.object_name = @object_name
                AND
                op.object_type = @object_type
        )
        BEGIN
            SET @processObject = 0;
            RAISERROR(N'Destination Object [%s]\[%s]\[%s] does not exists or does not have any parameters. Ignoring object parameters.', 11, 2, @folder_name, @project_name, @object_name) WITH NOWAIT;
        END
        ELSE
        BEGIN
            RAISERROR(N'Processing Object: [%s]\[%s]\[%s]', 0, 0, @folder_name, @project_name, @object_name) WITH NOWAIT;
        END
        RAISERROR(N'-------------------------------------------------------------------', 0, 0) WITH NOWAIT;
    END

    IF @processObject = 1
    BEGIN        
        RAISERROR(N'Setting Parameter:  [%s]\[%s]\[%s]\[%s]', 0, 0, @folder_name, @project_name, @object_name, @parameter_name) WITH NOWAIT;
        EXEC [SSISDB].[catalog].[set_object_parameter_value] @object_type = @object_type, @folder_name = @folder_name, @project_name = @project_name, @parameter_name = @parameter_name, @parameter_value = @parameter_value, @object_name=@object_name, @value_type = @value_type
    END
        
    SELECT
        @lastFolderName     = @fld
        ,@lastProjectName   = @project_name
        ,@lastObjectName    = @object_name
        ,@lastObjectType    = @object_type


    FETCH NEXT FROM cr INTO @fld, @project_name, @object_type, @object_name, @parameter_name, @value_type, @parameter_value
END

CLOSE cr;
DEALLOCATE cr;


IF @processReferences = 0
BEGIN
    IF EXISTS(SELECT 1 FROM @parameters WHERE value_type = 'R')
        RAISERROR(N'===================================================================', 0, 0) WITH NOWAIT;

    DECLARE fc CURSOR FAST_FORWARD FOR
    SELECT DISTINCT
        folder_name
        ,project_name
    FROM @parameters

    OPEN fc;
    FETCH NEXT FROM fc INTO @folder_name, @project_name

    WHILE @@FETCH_STATUS = 0
    BEGIN

        IF EXISTS(SELECT 1 FROM @folderReplacements)
        BEGIN
            DECLARE rc CURSOR FAST_FORWARD FOR
            SELECT
                OldValue
                ,NewValue
            FROM @folderReplacements
            ORDER BY SortOrder

            OPEN rc;
            
            FETCH NEXT FROM rc INTO @oldVal, @newVal

            WHILE @@FETCH_STATUS = 0
            BEGIN
                SET @folder_name = REPLACE(@folder_name, @oldVal, @newVal)
                FETCH NEXT FROM rc INTO @oldVal, @newVal
            END

            CLOSE rc;
            DEALLOCATE rc;
        END


        RAISERROR(N'DON''T FORGET TO SET ENVIRONMENT REFERENCES for project [%s]\[%s].', 0, 0, @folder_name, @project_name) WITH NOWAIT;
        FETCH NEXT FROM fc INTO @folder_name, @project_name
    END

    CLOSE fc;
    DEALLOCATE fc;    

END
GO

PRINT '------------------------------------------------------------------------'
PRINT Convert(nvarchar(30), GetDate(), 121) + ' - End script: A02SSIS_Parameters.sql'
PRINT '------------------------------------------------------------------------'
GO