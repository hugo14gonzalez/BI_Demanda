/* ========================================================================== 
Proyecto: DemandaBI
Empresa:  
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
$(DATABASE_SERVERNAME_DW): Nombre de la instancia del servidor SQL Server DW. Ejemplo: MISERVIDOR, MISERVIDOR\SQL2019

$(DATABASE_PATH_LOG_DW): Ruta archivo log de transacciones *.ldf. Ejemplo: D:\MSDB\DemandaDW
$(DATABASE_PATH_PRIMARY_DW): Ruta archivo principal de base datos *.mdf. Ejemplo: D:\MSDB\DemandaDW
$(DATABASE_PATH_DEMANDADW_DAT): Ruta file group tablas no particionadas (datos e indice clusterado) *.ndf. Ejemplo: D:\MSDB\DemandaDW
$(DATABASE_PATH_DEMANDADW_IND): Ruta file group tablas no particionadas (indices) *.ndf. Ejemplo: D:\MSDB\DemandaDW

$(DATABASE_PATH_DEMANDA_DAT): Ruta file group demanda particion (datos e indice clusterado) *.ndf. Ejemplo: D:\MSDB\DemandaDW
$(DATABASE_PATH_DEMANDA_IND): Ruta file group demanda particion (indices) *.ndf. Ejemplo: D:\MSDB\DemandaDW

$(DATABASE_OPERATORMAILBOX): Buzón de correo para recibir notificaciones. Ejemplo: MiUsuario1@MiDominio.com.co;MiUsuario2@MiDominio.com.co
$(DATABASE_MAILPROFILENAME): Nombre de perfil de correo para configurar el servicio de mail, recomendado el mismo nombre de instancia SQL Server. Ejemplo: NotificacionesSQL, MISERVIDOR\SQL2019
$(DATABASE_MAILBOX): Buzón de correo usado para configurar el servicio de mail. Ejemplo: MiUsuario1@MiDominio.com.co
$(DATABASE_MAILIP): Dirección IP del servidor de correo. Ejemplo: 172.10.1.2

$(DATABASE_OWNER): Propietario de la base de datos.
 Usualmente es el usuario SQL: SA, de lo contario utilice la cuenta tecnica de red para administrar servicios SQL. 
 Ejemplo: SA, MiDominio\MiUsuarioAdminSQL

$(DATABASEOLAP_SERVERNAME_Demanda_OLAP): Nombre de la instancia del servidor SQL Server Analysis Services. Ejemplo: MISERVIDOR, MISERVIDOR\SQL2019
$(DATABASEOLAP_NAME_DEMANDA_OLAP): Nombre de la base de datos SQL Server Analysis Services. Ejemplo: Demanda_OLAP
$(DATABASEOLAP_STORAGEPATH): Ruta de almacenamiento de objetos de base de datos SQL Server Analysis Services. Ejemplo: C:\MSDB\Demanda_OLAP\

$(DATABASE_USR_DEMANDADW_PASSWORD_DW): Contraseña para el usuario: USR_DemandaDW, en el servidor DW. Ejemplo: <REPLACE_ME>
$(DATABASE_PROXYWINDOWSUSER): Usuario de Windows usado para crear cuenta proxy. Ejemplo: MiDominio\MiUsuario
$(DATABASE_PROXYPASSWORD): Contraseña del usuario de Windows usado para crear cuenta proxy. Ejemplo: <REPLACE_ME>

$(LINKSERVER_NAME_Demanda_OLAP): Nombre del servidor vinculado a la base de datos SQL Server Analysis Services. Ejemplo: Demanda_OLAP
========================================================================== */ 

/* IMPORTANTE: Establer ruta principal de scripts, esta variable es modificada por script PowerShell */
:setvar PATH_DEPLOYMENT "D:\Hugo\DirProject\DemandaBI\Src\Script\DemandaDB"

:setvar DATABASE_NAME_DW "DemandaDW"

:setvar DATABASE_SERVERNAME_DW "MVMOAN172A\SQL2019"
:setvar DATABASE_NAME_SSISDB "SSISDB"

:setvar DATABASE_PATH_LOG_DW "D:\MSDB\DemandaDW"
:setvar DATABASE_PATH_PRIMARY_DW "D:\MSDB\DemandaDW"
:setvar DATABASE_PATH_DEMANDADW_DAT "D:\MSDB\DemandaDW"
:setvar DATABASE_PATH_DEMANDADW_IND "D:\MSDB\DemandaDW"

/* Produccion: D:\MSDB\DemandaDW, Desarrollo: C:\MSDB\DemandaDW */
:setvar DATABASE_PATH_DEMANDA_DAT "D:\MSDB\DemandaDW"
:setvar DATABASE_PATH_DEMANDA_IND "D:\MSDB\DemandaDW"

:setvar DATABASE_OPERATORMAILBOX "MiUsuarioCorreo@MiDominio.com"

:setvar DATABASE_MAILPROFILENAME "NotificacionesSQL"
:setvar DATABASE_MAILBOX "MiUsuarioCorreo@MiDominio.com"
:setvar DATABASE_MAILIP "172.10.1.2"

:setvar DATABASE_OWNER "SA"

/* Produccion: MVMOAN172A\SQL2019, Desarrollo: HUGO\SQL2019 */
:setvar DATABASEOLAP_SERVERNAME_Demanda_OLAP "MVMOAN172A\SQL2019"
:setvar DATABASEOLAP_NAME_DEMANDA_OLAP "Demanda_OLAP"

:setvar DATABASEOLAP_STORAGEPATH "D:\MSDB\Demanda_OLAP\"

:setvar DATABASE_USR_DEMANDADW_PASSWORD_DW "USR_DemandaDW00*"

/* Produccion: MVM\hugo.gonzalez, Desarrollo: HUGO\Hugo */
:setvar DATABASE_PROXYWINDOWSUSER "MVM\hugo.gonzalez"
:setvar DATABASE_PROXYPASSWORD "Cristian++05"

:setvar LINKSERVER_NAME_Demanda_OLAP "Demanda_OLAP"

PRINT '------------------------------------------------------------------------';
PRINT 'START DEPLOYMENT: A00DeploymentDB_Produccion.sql';
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
:r $(PATH_DEPLOYMENT)"\A01Uti_DB\A01CreaDB.sql" 
:r $(PATH_DEPLOYMENT)"\A01Uti_DB\A02Schema.sql" 
:r $(PATH_DEPLOYMENT)"\A01Uti_DB\A03Table_Util.sql" 
:r $(PATH_DEPLOYMENT)"\A01Uti_DB\A04Table_UtilCube.sql" 
:r $(PATH_DEPLOYMENT)"\A01Uti_DB\A05Table_Audi.sql" 
:r $(PATH_DEPLOYMENT)"\A01Uti_DB\A06FK_Util.sql" 
:r $(PATH_DEPLOYMENT)"\A01Uti_DB\A07FK_UtilCube.sql" 
:r $(PATH_DEPLOYMENT)"\A01Uti_DB\A08FK_Audi.sql" 
:r $(PATH_DEPLOYMENT)"\A01Uti_DB\A09SP_Util_General.sql" 
:r $(PATH_DEPLOYMENT)"\A01Uti_DB\A10SP_Util_Date.sql" 
:r $(PATH_DEPLOYMENT)"\A01Uti_DB\A11SP_Audi.sql" 
:r $(PATH_DEPLOYMENT)"\A01Uti_DB\A12SP_Util_Prog.sql" 
:r $(PATH_DEPLOYMENT)"\A01Uti_DB\A13SP_Util_Cube.sql" 
:r $(PATH_DEPLOYMENT)"\A01Uti_DB\A14SP_Util_Load.sql" 
:r $(PATH_DEPLOYMENT)"\A01Uti_DB\A15SPUtil_OLAP.sql" 

:r $(PATH_DEPLOYMENT)"\A02DemandaDW_DB\A01CreaDB.sql" 
:r $(PATH_DEPLOYMENT)"\A02DemandaDW_DB\A02Schema.sql" 
:r $(PATH_DEPLOYMENT)"\A02DemandaDW_DB\A03PartitonScheme.sql" 
:r $(PATH_DEPLOYMENT)"\A02DemandaDW_DB\A04BrokerCLR.sql" 
:r $(PATH_DEPLOYMENT)"\A02DemandaDW_DB\A05Table_Dim.sql" 
:r $(PATH_DEPLOYMENT)"\A02DemandaDW_DB\A06Table_Fact.sql" 
:r $(PATH_DEPLOYMENT)"\A02DemandaDW_DB\A07Table_Stg.sql" 
:r $(PATH_DEPLOYMENT)"\A02DemandaDW_DB\A08FK_DW.sql" 
:r $(PATH_DEPLOYMENT)"\A02DemandaDW_DB\A09View.sql" 
:r $(PATH_DEPLOYMENT)"\A02DemandaDW_DB\A10SP_Stg.sql" 
:r $(PATH_DEPLOYMENT)"\A02DemandaDW_DB\A11SP_DWInfe.sql" 
:r $(PATH_DEPLOYMENT)"\A02DemandaDW_DB\A12SP_DW_Dim1.sql" 
:r $(PATH_DEPLOYMENT)"\A02DemandaDW_DB\A13SP_DW_Dim2.sql" 
:r $(PATH_DEPLOYMENT)"\A02DemandaDW_DB\A14SP_DW_Fact.sql" 

:r $(PATH_DEPLOYMENT)"\B01Uti_Data\B01Data_Util.sql" 
:r $(PATH_DEPLOYMENT)"\B01Uti_Data\B02Data_Audi.sql" 

:r $(PATH_DEPLOYMENT)"\B02DemandaDW_Data\B01Data_NA.sql" 
:r $(PATH_DEPLOYMENT)"\B02DemandaDW_Data\B02Data_DW.sql" 
:r $(PATH_DEPLOYMENT)"\B02DemandaDW_Data\B03Data_Stg.sql" 

:r $(PATH_DEPLOYMENT)"\C01Uti_Security\C01Login.sql" 
:r $(PATH_DEPLOYMENT)"\C01Uti_Security\C02User.sql" 
:r $(PATH_DEPLOYMENT)"\C01Uti_Security\C03Rol.sql" 
:r $(PATH_DEPLOYMENT)"\C01Uti_Security\C04Grant.sql" 

:r $(PATH_DEPLOYMENT)"\C02DemandaDW_Security\C01Login.sql" 
:r $(PATH_DEPLOYMENT)"\C02DemandaDW_Security\C02User.sql" 
:r $(PATH_DEPLOYMENT)"\C02DemandaDW_Security\C03Rol.sql" 
:r $(PATH_DEPLOYMENT)"\C02DemandaDW_Security\C04Grant.sql" 
:r $(PATH_DEPLOYMENT)"\C02DemandaDW_Security\C05Proxy.sql" 
:r $(PATH_DEPLOYMENT)"\C02DemandaDW_Security\C06LinkServer.sql" 

:r $(PATH_DEPLOYMENT)"\D01SQLAgent\D01Agent.sql" 
:r $(PATH_DEPLOYMENT)"\D01SQLAgent\D02Mail.sql" 
:r $(PATH_DEPLOYMENT)"\D01SQLAgent\D03Operator.sql" 
GO
 
PRINT '';
PRINT 'Fecha fin: ' + Convert(nvarchar(20), GetDate(), 120);
PRINT '------------------------------------------------------------------------';
PRINT 'END DEPLOYMENT: A00DeploymentDB_Produccion.sql'
PRINT '------------------------------------------------------------------------';
GO
