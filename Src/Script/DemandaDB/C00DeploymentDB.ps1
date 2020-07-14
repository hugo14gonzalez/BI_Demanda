clear-host;
<# ==========================================================================
POWERSHELL DEPLOYMENT SCRIPTS DATABASES SQL SERVER

- Si hay error por restriccion en ejecucion de PowerShell (PS), ejecute desde PS con privilegios de administracion:
Set-ExecutionPolicy Unrestricted

- Para menos privilegios: set-executionpolicy remotesigned
- Para obtener ayuda: get-help about_signing
- Para encontrar la politica actual: get-executionpolicy
- Al terminar para retornar las politicas de seguridad: Set-ExecutionPolicy Restricted
========================================================================== #>
if ($PSScriptRoot -eq $null)
{
 $pathMain = split-path -parent $MyInvocation.MyCommand.Definition;
}
else
{
 $pathMain = $PSScriptRoot;
}
$modulePath = [System.IO.Path]::Combine($pathMain, "MainDeploymentDB.psm1"); # ruta actual de este script

write-host ("");
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

write-host ("");
write-host "Escriba un numero para seleccionar la base de datos a instalar y presione <Enter>" -f "Cyan";
write-host "1: DemandaDW, 2: Demanda_ETL: " -NoNewLine -f "Cyan";
$askForDeployment = Read-Host;
switch ($askForDeployment)
{
 1 { $dbDeploy = "DemandaDW"; }
 2 { $dbDeploy = "Demanda_ETL"; }
 default { $dbDeploy = "DemandaDW"; }
}

<# $trustedConnection: Modo de autenticación al servidor SQL Server. El usuario debe tener privilegios para poder ejecutar los scripts.
$true: Autenticación de confianza, utiliza las credenciales del sistema operativo del usuario actual. (Recomendado)
$false: Autenticación SQL Server. El programa abre un cuadro de diálogo para escribir las credenciales. #>
switch ($envDeploy.ToLower()) {
 "produccion"
 {
  $trustedConnection = $true;  
  switch ($dbDeploy.ToLower()) {
   "DemandaDW"
   {
    $serverSQLName = "MVMOAN172A\SQL2019";  # Nombre de instancia SQL Server de despliegue. Tambien puede usar la IP.
    $fileDeployment = "A00DeploymentDB_Produccion.sql"; 
   }
   "Demanda_ETL"
   {
    $serverSQLName = "MVMOAN172A\SQL2019";  # Nombre de instancia SQL Server de despliegue. Tambien puede usar la IP.
    $fileDeployment = "A01DeploymentETL_Produccion.sql";  
   }
   default
   {
    $serverSQLName = "HUGO\SQL2019";  # Nombre de instancia SQL Server de despliegue. Tambien puede usar la IP.
    $fileDeployment = "A00DeploymentDB_Produccion.sql"; 
   }
  }
 }
 "pruebas"
 {
  $trustedConnection = $true;  
  switch ($dbDeploy.ToLower()) {
   "DemandaDW"
   {
    $serverSQLName = "HUGO\SQL2019";  # Nombre de instancia SQL Server de despliegue. Tambien puede usar la IP.
    $fileDeployment = "A00DeploymentDB_Desarrollo.sql"; 
   }
   "Demanda_ETL"
   {
    $serverSQLName = "HUGO\SQL2019";  # Nombre de instancia SQL Server de despliegue. Tambien puede usar la IP.
    $fileDeployment = "A01DeploymentETL_Desarrollo.sql";  
   }
   default
   {
    $serverSQLName = "HUGO\SQL2019";  # Nombre de instancia SQL Server de despliegue. Tambien puede usar la IP.
    $fileDeployment = "A00DeploymentDB_Desarrollo.sql"; 
   }
  }
 }
 "desarrollo"
 {
  $trustedConnection = $true;  
  switch ($dbDeploy.ToLower()) {
   "DemandaDW"
   {
    $serverSQLName = "HUGO\SQL2019";  # Nombre de instancia SQL Server de despliegue. Tambien puede usar la IP.
    $fileDeployment = "A00DeploymentDB_Desarrollo.sql"; 
   }
   "Demanda_ETL"
   {
    $serverSQLName = "HUGO\SQL2019";  # Nombre de instancia SQL Server de despliegue. Tambien puede usar la IP.
    $fileDeployment = "A01DeploymentETL_Desarrollo.sql";  
   }
   default
   {
    $serverSQLName = "HUGO\SQL2019";  # Nombre de instancia SQL Server de despliegue. Tambien puede usar la IP.
    $fileDeployment = "A00DeploymentDB_Desarrollo.sql"; 
   }
  }
 }
 "desarrollo_azure"
 {
  $trustedConnection = $true;  
  switch ($dbDeploy.ToLower()) {
   "DemandaDW"
   {
    $serverSQLName = "HUGO\SQL2019";  # Nombre de instancia SQL Server de despliegue. Tambien puede usar la IP.
    $fileDeployment = "A00DeploymentDB_Desarrollo.sql"; 
   }
   "Demanda_ETL"
   {
    $serverSQLName = "HUGO\SQL2019";  # Nombre de instancia SQL Server de despliegue. Tambien puede usar la IP.
    $fileDeployment = "A01DeploymentETL_Desarrollo.sql";  
   }
   default
   {
    $serverSQLName = "HUGO\SQL2019";  # Nombre de instancia SQL Server de despliegue. Tambien puede usar la IP.
    $fileDeployment = "A00DeploymentDB_Desarrollo.sql"; 
   }
  }
 }
 default
 {
  $trustedConnection = $true;  
  switch ($dbDeploy.ToLower()) {
   "DemandaDW"
   {
    $serverSQLName = "HUGO\SQL2019";  # Nombre de instancia SQL Server de despliegue. Tambien puede usar la IP.
    $fileDeployment = "A00DeploymentDB_Desarrollo.sql"; 
   }
   "Demanda_ETL"
   {
    $serverSQLName = "HUGO\SQL2019";  # Nombre de instancia SQL Server de despliegue. Tambien puede usar la IP.
    $fileDeployment = "A01DeploymentETL_Desarrollo.sql";  
   }
   default
   {
    $serverSQLName = "HUGO\SQL2019";  # Nombre de instancia SQL Server de despliegue. Tambien puede usar la IP.
    $fileDeployment = "A00DeploymentDB_Desarrollo.sql"; 
   }
  }
 }
}

$resultPath = $pathMain;
$pathDeployment = [System.IO.Path]::Combine($pathMain, "A00Deployment");
$filePath = [System.IO.Path]::Combine($pathDeployment, $fileDeployment); 

if(-not(Test-Path -Path $filePath)) {
 throw "File or directory not found at {0}" -f $filePath; 
}

# En caso de error detener la ejecucion: $false/$true
$stopInError = $false;

if ($trustedConnection) {
 $userName = "";
 $password = "";
} else {
 write-host "Suministre las credenciales de autenticación en el servidor SQL Server:" $serverSQLName -f "Cyan";
 $credential = Get-Credential;
 $userName = $credential.UserName;
 $password = $credential.GetNetworkCredential().password;
}

write-host ("");
write-host "Ambiente:                       $envDeploy" -f "Cyan";
write-host "Base de datos:                  $dbDeploy" -f "Cyan";
write-host "Script despliegue:              $fileDeployment" -f "Cyan";
write-host "Servidor SQL Server:            $serverSQLName" -f "Cyan";
write-host "Ruta archivos log:              $resultPath" -f "Cyan";
write-host "Ruta script maestro despliegue: $filePath" -f "Cyan";

write-host ("");
write-host "=====================================================" -f "Magenta"
write-host "Confirmar despliegue en ambiente: " $envDeploy -f "Magenta"
write-host "NOTA: Antes de instalar recuerde cambiar las variables del script despliegue." -f "Magenta"
write-host "=====================================================" -f "Magenta"  
write-host "Esta seguro que quiere desplegar los scripts de base de datos [y/n]? " -NoNewLine -f "Magenta";
$confirmation = Read-Host;
if ($confirmation -ne 'y') { exit; }
Import-Module $modulePath;

# En script despliegue establecer ruta de scripts 
ReplaceCmdletParameterValueInFile $filePath "PATH_DEPLOYMENT" $pathMain;

$databaseName = ""; # Debe estar en blanco, cada script debe establecer el contexto de base de datos
ExecuteScript_InvokeSqlCmd $filePath $resultPath $serverSQLName $databaseName $trustedConnection $userName $password $stopInError;

write-host ("");
write-host "Process finish. Removing modules" -f "Cyan";
Remove-Module -name "MainDeploymentDB" -Force;

write-host ("");
Read-Host -Prompt "Press Enter to exit PS ...";

exit;