clear-host;
<# ==========================================================================
POWERSHELL DEPLOYMENT REPORTS SQL REPORTING SERVICES

- Si hay error por restriccion en ejecucion de PowerShell (PS), ejecute desde PS con privilegios de administracion:
Set-ExecutionPolicy Unrestricted

- Para menos privilegios: set-executionpolicy remotesigned
- Para obtener ayuda: get-help about_signing
- Para encontrar la politica actual: get-executionpolicy
- Al terminar para retornar las politicas de seguridad: Set-ExecutionPolicy Restricted
========================================================================== #>
#Ruta de archivos de despliegue
if ($PSScriptRoot -eq $null)
{
 $pathMain = split-path -parent $MyInvocation.MyCommand.Definition;
}
else
{
 $pathMain = $PSScriptRoot;
}
$modulePath = [System.IO.Path]::Combine($pathMain, "MainDeploymentRS.psm1"); # ruta actual de este script

write-host "Escriba un numero para seleccionar el ambiente de despliegue y presione <Enter>" -f "Cyan";
write-host "1: PRODUCCION, 2: PRUEBAS, 3: DESARROLLO, 4: DESARROLLO_AZURE: " -NoNewLine -f "Cyan";
$askForDeployment = Read-Host;
switch ($askForDeployment)
{
 1 { $envDeploy = "PRODUCCION"; }
 2 { $envDeploy = "PRUEBAS"; }
 3 { $envDeploy = "DESARROLLO"; }
 4 { $envDeploy = "DESARROLLO_AZURE"; }
 default { $envDeploy = "PRUEBAS"; }
}

#Archivo log
$fnWithoutExt = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name);
$resultPath = $pathMain;
$fileOut_PS = [System.IO.Path]::Combine($resultPath, $fnWithoutExt + "_PS.log");

try {			
 if (Test-Path $fileOut_PS) { 
  Remove-Item $fileOut_PS -force;
 }
} catch {
 write-host "Error al borar archivo de log, es probable que este abierto. El proceso continua." -f "red" -BackgroundColor "Yellow";
}

#Iniciar archivo log 
try
{
 if ($Host.Version.Major -ge 4)
 {
  Start-Transcript -path $fileOut_PS -append -force;
 }
 else
 {
  write-host "Esta versión de PowerShell no permite genera archivo log, el proceso continua." -f "Cyan";
 }
}
catch
{
 write-host "Error al crear archivo de log, el proceso continua sin dejar log." -f "red" -BackgroundColor "Yellow";
}

switch ($envDeploy.ToLower())
{
 "produccion"
 {
  $computerSSRSDeployment = "MVMOAN172A";  # Nombre del computador donde esta instalado SQL Reporting Services.
  $SSRSinstanceName = "";                  # Nombre de la instancia SQL Reporting Service. No incluya el nombre del computador. Puede estar en blanco ("") cuando es la instancia por defecto.
  $serverToDataSource_OLAP = "MVMOAN172A\SQL2019";  # Nombre de la instancia SQL que contiene la base de datos Demanda_OLAP. Nombre de computador y la instancia o solo el nombre de computador si es la instancia por defecto.
  $databaseToDataSource_OLAP = "Demanda_OLAP"; # Nombre de la base de datos Demanda_OLAP
  $serverToDataSource_SQL = "MVMOAN172A\SQL2019";  # Nombre de la instancia SQL que contiene la base de datos DemandaDW. Nombre de computador y la instancia o solo el nombre de computador si es la instancia por defecto.
  $databaseToDataSource_SQL = "DemandaDW"; # Nombre de la base de datos DemandaDW
  
  $userConnectionSSRS = "mvm\hugo.gonzalez";  # Usuario de red para conectarse al servidor SSRS, con permisos de administracion en SQL Server, para instalar reportes.
  $passwordConnectionSSRS = "Cristian++05"; # Password de usuario de red para conectarse al servidor SSRS.
  $userDataSource_OLAP = "mvm\hugo.gonzalez"; # Usuario de red para cadena de conexion a la base de datos OLAP. Puede usar la cuenta de rede configurada como proxy en el motor SQL. 
  $passwordDataSource_OLAP = "Cristian++05"; # Password de usuario de red para cadena de conexion a la base de datos OLAP. 
  $userDataSource_SQL = "USR_DemandaDW"; # Usuario SQL para cadena de conexion a la bodega de datos: DemandaDW.
  $passwordDataSource_SQL = "USR_DemandaDW00*"; # Password de usuario SQL para cadena de conexion a la bodega de datos: DemandaDW.
 }
 "pruebas"
 {
  $computerSSRSDeployment = "MVMOAN172A";  # Nombre del computador donde esta instalado SQL Reporting Services.
  $SSRSinstanceName = "";                  # Nombre de la instancia SQL Reporting Service. No incluya el nombre del computador. Puede estar en blanco ("") cuando es la instancia por defecto.
  $serverToDataSource_OLAP = "MVMOAN172A\SQL2019";  # Nombre de la instancia SQL que contiene la base de datos Demanda_OLAP. Nombre de computador y la instancia o solo el nombre de computador si es la instancia por defecto.
  $databaseToDataSource_OLAP = "Demanda_OLAP"; # Nombre de la base de datos Demanda_OLAP
  $serverToDataSource_SQL = "MVMOAN172A\SQL2019";  # Nombre de la instancia SQL que contiene la base de datos DemandaDW. Nombre de computador y la instancia o solo el nombre de computador si es la instancia por defecto.
  $databaseToDataSource_SQL = "DemandaDW"; # Nombre de la base de datos DemandaDW
  
  $userConnectionSSRS = "mvm\hugo.gonzalez";  # Usuario de red para conectarse al servidor SSRS, con permisos de administracion en SQL Server, para instalar reportes.
  $passwordConnectionSSRS = "Cristian++05"; # Password de usuario de red para conectarse al servidor SSRS.
  $userDataSource_OLAP = "mvm\hugo.gonzalez"; # Usuario de red para cadena de conexion a la base de datos OLAP. Puede usar la cuenta de rede configurada como proxy en el motor SQL. 
  $passwordDataSource_OLAP = "Cristian++05"; # Password de usuario de red para cadena de conexion a la base de datos OLAP. 
  $userDataSource_SQL = "USR_DemandaDW"; # Usuario SQL para cadena de conexion a la bodega de datos: DemandaDW.
  $passwordDataSource_SQL = "USR_DemandaDW00*"; # Password de usuario SQL para cadena de conexion a la bodega de datos: DemandaDW.
 }
 "desarrollo"
 {
  $computerSSRSDeployment = "HUGO";     # Nombre del computador donde esta instalado SQL Reporting Services.
  $SSRSinstanceName = "";                      # Nombre de la instancia SQL Reporting Service. No incluya el nombre del computador. Puede estar en blanco ("") cuando es la instancia por defecto.
  $serverToDataSource_OLAP = "HUGO";     # Nombre de la instancia SQL que contiene la base de datos Demanda_OLAP. Nombre de computador y la instancia o solo el nombre de computador si es la instancia por defecto.
  $databaseToDataSource_OLAP = "Demanda_OLAP"; # Nombre de la base de datos Demanda_OLAP
  $serverToDataSource_SQL = "HUGO";  # Nombre de la instancia SQL que contiene la base de datos DemandaDW. Nombre de computador y la instancia o solo el nombre de computador si es la instancia por defecto.
  $databaseToDataSource_SQL = "DemandaDW"; # Nombre de la base de datos DemandaDW
  
  $userConnectionSSRS = "HUGO\hugo"; # Usuario de red para conectarse al servidor SSRS, con permisos de administracion en SQL Server, para instalar reportes.
  $passwordConnectionSSRS = ""; # Password de usuario de red para conectarse al servidor SSRS. 
  $userDataSource_OLAP = $userConnectionSSRS; # Usuario de red para cadena de conexion a la base de datos OLAP. Puede usar la cuenta de rede configurada como proxy en el motor SQL. 
  $passwordDataSource_OLAP = $passwordConnectionSSRS; # Password de usuario de red para cadena de conexion a la base de datos OLAP. 
  $userDataSource_SQL = "USR_DemandaDW"; # Usuario SQL para cadena de conexion a la bodega de datos: DemandaDW.
  $passwordDataSource_SQL = "USR_DemandaDW00*W"; # Password de usuario SQL para cadena de conexion a la bodega de datos: DemandaDW. 
 }
 "desarrollo_azure"
 {
  $computerSSRSDeployment = "HUGO";     # Nombre del computador donde esta instalado SQL Reporting Services.
  $SSRSinstanceName = "";                      # Nombre de la instancia SQL Reporting Service. No incluya el nombre del computador. Puede estar en blanco ("") cuando es la instancia por defecto.
  $serverToDataSource_OLAP = "HUGO";     # Nombre de la instancia SQL que contiene la base de datos Demanda_OLAP. Nombre de computador y la instancia o solo el nombre de computador si es la instancia por defecto.
  $databaseToDataSource_OLAP = "Demanda_OLAP"; # Nombre de la base de datos Demanda_OLAP
  $serverToDataSource_SQL = "HUGO";  # Nombre de la instancia SQL que contiene la base de datos DemandaDW. Nombre de computador y la instancia o solo el nombre de computador si es la instancia por defecto.
  $databaseToDataSource_SQL = "DemandaDW"; # Nombre de la base de datos DemandaDW
  
  $userConnectionSSRS = "HUGO\hugo"; # Usuario de red para conectarse al servidor SSRS, con permisos de administracion en SQL Server, para instalar reportes.
  $passwordConnectionSSRS = ""; # Password de usuario de red para conectarse al servidor SSRS. 
  $userDataSource_OLAP = $userConnectionSSRS; # Usuario de red para cadena de conexion a la base de datos OLAP. Puede usar la cuenta de rede configurada como proxy en el motor SQL. 
  $passwordDataSource_OLAP = $passwordConnectionSSRS; # Password de usuario de red para cadena de conexion a la base de datos OLAP. 
  $userDataSource_SQL = "USR_DemandaDW"; # Usuario SQL para cadena de conexion a la bodega de datos: DemandaDW.
  $passwordDataSource_SQL = "USR_DemandaDW00*"; # Password de usuario SQL para cadena de conexion a la bodega de datos: DemandaDW. 
 }
 default
 {
  $computerSSRSDeployment = "MVMOAN172A";  # Nombre del computador donde esta instalado SQL Reporting Services.
  $SSRSinstanceName = "";                  # Nombre de la instancia SQL Reporting Service. No incluya el nombre del computador. Puede estar en blanco ("") cuando es la instancia por defecto.
  $serverToDataSource_OLAP = "MVMOAN172A\SQL2019";  # Nombre de la instancia SQL que contiene la base de datos Demanda_OLAP. Nombre de computador y la instancia o solo el nombre de computador si es la instancia por defecto.
  $databaseToDataSource_OLAP = "Demanda_OLAP"; # Nombre de la base de datos Demanda_OLAP
  $serverToDataSource_SQL = "MVMOAN172A\SQL2019";  # Nombre de la instancia SQL que contiene la base de datos DemandaDW. Nombre de computador y la instancia o solo el nombre de computador si es la instancia por defecto.
  $databaseToDataSource_SQL = "DemandaDW"; # Nombre de la base de datos DemandaDW
  
  $userConnectionSSRS = "mvm\hugo.gonzalez";  # Usuario de red para conectarse al servidor SSRS, con permisos de administracion en SQL Server, para instalar reportes.
  $passwordConnectionSSRS = "Cristian++05"; # Password de usuario de red para conectarse al servidor SSRS.
  $userDataSource_OLAP = "mvm\hugo.gonzalez"; # Usuario de red para cadena de conexion a la base de datos OLAP. Puede usar la cuenta de rede configurada como proxy en el motor SQL. 
  $passwordDataSource_OLAP = "Cristian++05"; # Password de usuario de red para cadena de conexion a la base de datos OLAP. 
  $userDataSource_SQL = "USR_DemandaDW"; # Usuario SQL para cadena de conexion a la bodega de datos: DemandaDW.
  $passwordDataSource_SQL = "USR_DemandaDW00*"; # Password de usuario SQL para cadena de conexion a la bodega de datos: DemandaDW.
 }
}

if ($SSRSinstanceName) {
 $serverSSRS = "$computerSSRSDeployment\$SSRSinstanceName";
 $SSRSWebServices = "http://$computerSSRSDeployment/Reportserver_$SSRSinstanceName";
} else {
 $serverSSRS = $computerSSRSDeployment;
 $SSRSWebServices = "http://$computerSSRSDeployment/Reportserver";
}

# Nombres de los datasources a ser instalados
$ds_OLAP = "dsDemanda_OLAP";
$ds_SQL = "dsDemandaDW";

write-host "";
write-host "==========================================================================" -f "Cyan";
write-host "Credenciales de conexion a Reporting Services y para Datasours" -f "Cyan";
write-host "==========================================================================" -f "Cyan";
$cnxStringDataSource_OLAP = "Data Source=$serverToDataSource_OLAP;Initial Catalog=$databaseToDataSource_OLAP;";
$cnxStringDataSource_SQL = "Data Source=$serverToDataSource_SQL;Initial Catalog=$databaseToDataSource_SQL;";

write-host "Usuario de dominio de conexion a Reporting Services: " $userConnectionSSRS -f "Cyan";
write-host "Si no suministra las credenciales, son utilizas las definidos en este script.";
write-host "Desea ingresar las credenciales de conexion a Reporting Services [y/n]: " -NoNewLine -f "Cyan";
$askForCredentials = Read-Host;
if ($askForCredentials -eq "y") 
{
 write-host "Suministre las credenciales del usurio de dominio [MiDominio\MiUsuario] de conexion a Reporting Services: " $serverSSRS -f "Cyan";
 $credentialSSRS = Get-Credential -Message 'Enter credentials [MyDomain\MyUser]';
 $userConnectionSSRS = $credentialSSRS.UserName;
 $passwordCred_SSRS = $credentialSSRS.GetNetworkCredential().password;
}
else 
{
 $passwordCred_SSRS = ConvertTo-SecureString -AsPlainText -Force -String $passwordConnectionSSRS;
 $credentialSSRS = new-object -typename System.Management.Automation.PSCredential -argumentlist $userConnectionSSRS, $passwordCred_SSRS;
}

write-host "";
write-host "Data source: $ds_OLAP. Usuario de dominio de conexion a la base de datos OLAP: " $userDataSource_OLAP -f "Cyan";
write-host "Si no suministra las credenciales, son utilizas las definidos en este script.";
write-host "Desea ingresar las credenciales para este data sources [y/n]: " -NoNewLine -f "Cyan";
$askForCredentials = Read-Host;
if ($askForCredentials -eq "y") 
{
 write-host "Suministre las credenciales del usurio de dominio [MiDominio\MiUsuario] para la conexion OLAP del data source: " $ds_OLAP -f "Cyan";
 $credentialDataSource_OLAP = Get-Credential -Message 'Enter credentials [MyDomain\MyUser]';
 $userDataSource_OLAP = $credentialDataSource_OLAP.UserName;
 $passwordCred_OLAP = $credentialDataSource_OLAP.GetNetworkCredential().password;
}
else 
{
 $passwordCred_OLAP = ConvertTo-SecureString -AsPlainText -Force -String $passwordDataSource_OLAP;
 $credentialDataSource_OLAP = new-object -typename System.Management.Automation.PSCredential -argumentlist $userDataSource_OLAP, $passwordCred_OLAP;
}

write-host "";
write-host "Data source: $ds_SQL. Usuario (base datos) de conexion al motor SQL: " $userDataSource_SQL -f "Cyan";
write-host "Si no suministra las credenciales, son utilizas las definidos en este script.";
write-host "Desea ingresar las credenciales para este data sources [y/n]: " -NoNewLine -f "Cyan";
$askForCredentials = Read-Host;
if ($askForCredentials -eq "y") 
{
 write-host "Suministre las credenciales del usurio (base de datos) para la conexion al motor SQL: " $ds_SQL -f "Cyan";
 $credentialDataSource_SQL = Get-Credential -Message 'Enter credentials [MyUserDataBase]';
 $userDataSource_SQL = $credentialDataSource_SQL.UserName;
 $passwordCred_SQL = $credentialDataSource_SQL.GetNetworkCredential().password;
}
else 
{
 $passwordCred_SQL = ConvertTo-SecureString -AsPlainText -Force -String $passwordDataSource_SQL;
 $credentialDataSource_SQL = new-object -typename System.Management.Automation.PSCredential -argumentlist $userDataSource_SQL, $passwordCred_SQL;
}

<# ==========================================================================
FOLDERS SSRS
========================================================================== #>
# Carpetas de reportes a ser desplegadas
$report_Group = @("DemandaBI", "DemandaBI/Auditoria");

# $true: Para desplegar, $false: para no desplegar
$report_deploy = @($true, $true);

#Folder Reporting Services
$folderPath_Report = @();

#Ruta archivos *.rdl, *.rds, etc, a ser instalados
$filePath = @();

$dataSetMappings = @{};
$dataSourceMappings = @{};
$dataSourceName_OLAP = @();
$dataSourceName_SQL = @();
$filePath_DataSource_OLAP = @();
$filePath_DataSource_SQL = @();
$filePath_Image1 = @();
$filePath_Image2 = @();
$folderPath_DataSources = @();
$folderPath_DataSet = @();
$folderPath_Image = @();

write-host "";
write-host "==========================================================================" -f "Cyan";
write-host "Ruta archivos despliegue: " -f "Cyan";
write-host "==========================================================================" -f "Cyan";
for ($i=0; $i -lt $report_Group.length; $i++) 
{
 switch ($envDeploy.ToLower())
 {
  "produccion"
  {
   $folderPath_Report += $report_Group[$i];
  }
  "pruebas"
  {
   $folderPath_Report += "PRUEBAS/" + $report_Group[$i];
  }
  "desarrollo"
  {
   $folderPath_Report += $report_Group[$i];
  }
  "desarrollo_azure"
  {
   $folderPath_Report += $report_Group[$i];
  }
  default
  {
   $folderPath_Report += $report_Group[$i];
  }
 }

 $filePath += [System.IO.Path]::Combine($pathMain, $report_Group[$i].Replace("/", "\"));

 if ($report_deploy[$i] -eq $true)
 {
  write-host $filePath[$i] -f "Cyan";
  if(-not(Test-Path -Path $filePath[$i]))
  {
   throw "File or directory not found at {0}" -f $filePath[$i]; 
  }
 }

 $dataSourceName_OLAP += $ds_OLAP;
 $dataSourceName_SQL += $ds_SQL;
 $filePath_DataSource_OLAP += [System.IO.Path]::Combine($filePath[$i], "$ds_OLAP.rds");
 $filePath_DataSource_SQL += [System.IO.Path]::Combine($filePath[$i], "$ds_SQL.rds");
 $filePath_Image1 += [System.IO.Path]::Combine($filePath[$i], "LogoEnterprise.png");
 #$filePath_Image2 += [System.IO.Path]::Combine($filePath[$i], "DemandaComercial.png");
 $folderPath_DataSources += $folderPath_Report[$i] + "/DataSources";
 $folderPath_DataSet += $folderPath_Report[$i] + "/DataSets";
 $folderPath_Image += $folderPath_Report[$i] + "/Images";
}

$dataSourceMappings.Add($ds_SQL, $ds_SQL); 
$dataSourceMappings.Add($ds_OLAP, $ds_OLAP); 

$dataSetMappings.Add("dataSetActividadAgente", "dataSetActividadAgente");
$dataSetMappings.Add("dataSetAgentePorActividad", "dataSetAgentePorActividad");
$dataSetMappings.Add("dataSetCurrentMonth", "dataSetCurrentMonth");
$dataSetMappings.Add("dataSetCurrentYear", "dataSetCurrentYear");
$dataSetMappings.Add("dataSetDate_Cube", "dataSetDate_Cube");
$dataSetMappings.Add("dataSetFullMonth", "dataSetFullMonth");
$dataSetMappings.Add("dataSetMonth_Cube", "dataSetMonth_Cube"); 
$dataSetMappings.Add("dataSetYear_Cube", "dataSetYear_Cube");
$dataSetMappings.Add("dataSetYearMonth_Cube", "dataSetYearMonth_Cube");
 
write-host "";
write-host "Computador SQL Reporting Services:                   " $computerSSRSDeployment -f "Cyan";
write-host "Instancia SSRS (en blanco instancia por defecto):    " $SSRSinstanceName -f "Cyan";
write-host "URL de servicio web SSRS:                            " $SSRSWebServices -f "Cyan";
write-host "Usuario de dominio de conexion a Reporting Services: " $userConnectionSSRS -f "Cyan";
write-host "Data source: $ds_OLAP. Usuario de conexion: " $userDataSource_OLAP -f "Cyan";
write-host "Data source: $ds_SQL. Usuario de conexion:  " $userDataSource_SQL -f "Cyan";

write-host "";
write-host "=====================================================" -f "Magenta"
write-host "Confirmar despliegue en ambiente: " $envDeploy -f "Magenta"
write-host "=====================================================" -f "Magenta"  
write-host "Esta seguro que quiere desplegar los reportes [y/n]? " -NoNewLine -f "Magenta";
$confirmation = Read-Host;
if ($confirmation -ne 'y') 
{ exit; }

write-host ("");
write-host "==========================================================================" -f "Cyan"
write-host "Inicio despliegue SSRS:" $(get-date -format "yyyy-MM-dd HH:mm:ss") "Ambiente:" $envDeploy " PC:" $env:COMPUTERNAME". Usuario:" $(whoami) -f "Cyan"
write-host "==========================================================================" -f "Cyan"  
Import-Module $modulePath;

write-host "";
write-host "==========================================================================" -f "Cyan"
write-host "Crear SSRS proxy" -f "Cyan"
write-host "==========================================================================" -f "Cyan"  
#$ssrsProxy = SSRSCreateWebServiceProxy -webServiceUrl $SSRSWebServices -Credential $credentialSSRS -Verbose -versionWebService "2005";
$ssrsProxy = SSRSCreateWebServiceProxy -webServiceUrl $SSRSWebServices -Credential $credentialSSRS -Verbose;

if ($ssrsProxy) {
 write-host "Proxy SSRS creado en forma satisfactoria" -f "Cyan";
} else {
 write-host "No fue posible crear proxy SSRS. El proceso sera suspendido." -f "Magenta";
 exit;
}

for ($i=0; $i -lt $report_Group.length; $i++) {
 if ($report_deploy[$i] -eq $true) {
  write-host ""
  write-host "==========================================================================" -f "Cyan"
  write-host "DESPLIEGUE EN FOLDER [$i]: " $report_Group[$i] -f "Cyan"
  write-host "==========================================================================" -f "Cyan"  
  write-host "Folder para instalar reportes: " $folderPath_Report[$i] -f "Cyan";

  write-host "";
  write-host "==========================================================================" -f "Cyan"
  write-host "Publicar folder SSRS [$i]" -f "Cyan"
  write-host "==========================================================================" -f "Cyan"  
  SSRSPublishFolder -ssrsProxy $ssrsProxy -folder $folderPath_Report[$i] -Verbose;
  SSRSPublishFolder -ssrsProxy $ssrsProxy -folder $folderPath_DataSources[$i] -Verbose;
  SSRSPublishFolder -ssrsProxy $ssrsProxy -folder $folderPath_Image[$i] -Verbose;
  SSRSPublishFolder -ssrsProxy $ssrsProxy -folder $folderPath_DataSet[$i] -Verbose;

  write-host "" -f "Cyan";
  write-host "Folders in: " $folderPath_Report[$i] -f "Cyan";
  $allitems = SSRSGetItem -ssrsProxy $ssrsProxy -folderPath $folderPath_Report[$i] -type "Folder" -recurse;
  foreach($item in $allitems) {
   $msg = "{0} `t{1} `t`t{2}" -f $item.TypeName, $item.Name, $item.Path;
   write-host $msg -f "Cyan";
  }

  write-host "";
  write-host "==========================================================================" -f "Cyan"
  write-host "Publicar datasource SSRS [$i]: " $report_Group[$i] -f "Cyan"
  write-host "==========================================================================" -f "Cyan"
  if ($report_Group[$i].ToLower() -eq "demandabi/auditoria") {  
   $itemResult = SSRSPublishDataSource -ssrsProxy $ssrsProxy -filePath $filePath_DataSource_SQL[$i] -folderPath $folderPath_DataSources[$i] -connectString $cnxStringDataSource_SQL -credentialRetrieval "Store" -windowsCredentials $false -Credential $credentialDataSource_SQL -Verbose;
  } else {
   $itemResult = SSRSPublishDataSource -ssrsProxy $ssrsProxy -filePath $filePath_DataSource_OLAP[$i] -folderPath $folderPath_DataSources[$i] -connectString $cnxStringDataSource_OLAP -credentialRetrieval "Store" -windowsCredentials $true -Credential $credentialDataSource_OLAP -Verbose;

   $itemResult = SSRSPublishDataSource -ssrsProxy $ssrsProxy -filePath $filePath_DataSource_SQL[$i] -folderPath $folderPath_DataSources[$i] -connectString $cnxStringDataSource_SQL -credentialRetrieval "Store" -windowsCredentials $false -Credential $credentialDataSource_SQL -Verbose;
  }
   
  write-host "" -f "Cyan";
  write-host "DataSources in: " $folderPath_Report[$i] -f "Cyan";
  $allitems = SSRSGetItem -ssrsProxy $ssrsProxy -folderPath $folderPath_Report[$i] -type "DataSource" -recurse;
  foreach($item in $allitems) {
   $msg = "{0} `t{1} `t`t{2}" -f $item.TypeName, $item.Name, $item.Path;
   write-host $msg -f "Cyan";
  }

  write-host "";
  write-host "==========================================================================" -f "Cyan"
  write-host "Validar datasource SSRS [$i]: " $report_Group[$i] -f "Cyan"
  write-host "==========================================================================" -f "Cyan"
  if ($report_Group[$i].ToLower() -eq "demandabi/auditoria") {  
   $msg = $folderPath_DataSources[$i] + "/" + $dataSourceName_SQL[$i];
   write-host $msg -f "Cyan";
   $dataSourceInfo = SSRSGetDataSourceInfo_FromSSRS -ssrsProxy $ssrsProxy -datasource $msg;
   $dataSourceInfo;
  } else {
   $msg = $folderPath_DataSources[$i] + "/" + $dataSourceName_OLAP[$i];
   write-host $msg -f "Cyan";
   $dataSourceInfo = SSRSGetDataSourceInfo_FromSSRS -ssrsProxy $ssrsProxy -datasource $msg;
   $dataSourceInfo;

   $msg = $folderPath_DataSources[$i] + "/" + $dataSourceName_SQL[$i];
   write-host $msg -f "Cyan";
   $dataSourceInfo = SSRSGetDataSourceInfo_FromSSRS -ssrsProxy $ssrsProxy -datasource $msg;
   $dataSourceInfo;
  } 
    
  write-host "";
  write-host "==========================================================================" -f "Cyan"
  write-host "Publicar recursos SSRS [$i]: " $report_Group[$i] -f "Cyan"
  write-host "==========================================================================" -f "Cyan"
  $itemResult =SSRSPublishResource -ssrsProxy $ssrsProxy -filePath $filePath_Image1[$i] -mimeType "image/png" -folderPath $folderPath_Image[$i] -overwrite -Verbose;
# $itemResult =SSRSPublishResource -ssrsProxy $ssrsProxy -filePath $filePath_Image2[$i] -mimeType "image/png" -folderPath $folderPath_Image[$i] -overwrite -Verbose;

  write-host "" -f "Cyan";
  write-host "Resources in: " $folderPath_Report[$i] -f "Cyan";
  $allitems = SSRSGetItem -ssrsProxy $ssrsProxy -folderPath $folderPath_Report[$i] -type "Resource" -recurse;
  foreach($item in $allitems) {
   $msg = "{0} `t{1} `t`t{2}" -f $item.TypeName, $item.Name, $item.Path;
   write-host $msg -f "Cyan";
  }

  write-host "";
  write-host "==========================================================================" -f "Cyan"
  write-host "Publicar dataset SSRS [$i]: " $report_Group[$i] -f "Cyan"
  write-host "==========================================================================" -f "Cyan"
  if ($report_Group[$i].ToLower() -ne "auditoria") {  
   SSRSPublishReport_Directory -ssrsProxy $ssrsProxy -directory $filePath[$i] -folderPath $folderPath_DataSet[$i] -filterInclude "*.rsd" -dataSourceMappings $dataSourceMappings -dataSourceFolderTarget $folderPath_DataSources[$i] -dataSetMappings $dataSetMappings -dataSetFolderTarget $folderPath_DataSet[$i] -Verbose;

   write-host "" -f "Cyan";
   write-host "DataSets in SSRS:" -f "Cyan";
   $allitems = SSRSGetItem -ssrsProxy $ssrsProxy -folderPath $folderPath_Report[$i] -type "DataSet" -recurse;
   foreach($item in $allitems) {
    $msg = "{0} `t{1} `t`t{2}" -f $item.TypeName, $item.Name, $item.Path;
    write-host $msg -f "Cyan";
   }  
  }
  
  write-host "";
  write-host "==========================================================================" -f "Cyan"
  write-host "Publicar reportes SSRS [$i]: " $report_Group[$i] -f "Cyan"
  write-host "==========================================================================" -f "Cyan"
  SSRSPublishReport_Directory -ssrsProxy $ssrsProxy -directory $filePath[$i] -folderPath $folderPath_Report[$i] -filterInclude "*.rdl" -dataSourceMappings $dataSourceMappings -dataSourceFolderTarget $folderPath_DataSources[$i] -dataSetMappings $dataSetMappings -dataSetFolderTarget $folderPath_DataSet[$i] -overwrite -Verbose;

  write-host "" -f "Cyan";
  write-host "Reports in: " $folderPath_Report[$i] -f "Cyan";
  $allitems = SSRSGetItem -ssrsProxy $ssrsProxy -folderPath $folderPath_Report[$i] -type "Report" -recurse;
  foreach($item in $allitems) {
   $msg = "{0} `t{1} `t`t{2}" -f $item.TypeName, $item.Name, $item.Path;
   write-host $msg -f "Cyan";
  }
 }
}

write-host ("");
write-host "Process finish. Removing modules" -f "Cyan";
Remove-Module -name "MainDeploymentRS" -Force;

write-host ("")
write-host "End deployment:" $(get-date -format "yyyy-MM-dd HH:mm:ss") -f "Cyan"

try
{
 if ($Host.Version.Major -ge 4) {
  Stop-Transcript;
 } else {
  Start-iseTranscript -logname $fileOut_PS;
 }
} catch {
  write-host ("");
  write-host "Error al generar archivo de log. El proceso continua." -f "red" -BackgroundColor "Yellow";
}

try
{
  if (Test-Path $fileOut_PS) {
   Invoke-Item $fileOut_PS;
  }
} catch {
  write-host ("");
  write-host "Error al abrir archivo de log de errores: " -f "red" -BackgroundColor "Yellow";
  write-host "Excepcion: " $_.Exception.Message -f "red";
}

write-host ("");
Read-Host -Prompt "Press Enter to exit PS ...";

exit;
