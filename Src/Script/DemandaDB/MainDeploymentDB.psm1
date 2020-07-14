<# ========================================================================== 
PowerShell Funciones para Despliegue de bases de datos
Empresa: 
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2016-10-01
Fecha actualizacion: 2017-10-01
Email: hugo14.gonzalez@gmail.com

Links: 
Start-iseTranscrip:
https://blogs.technet.microsoft.com/heyscriptingguy/2010/09/25/create-a-transcript-of-commands-from-the-windows-powershell-ise/
http://stackoverflow.com/questions/5032075/powershell-start-transcript-this-host-does-not-support-transcription
========================================================================== #>

<# ========================================================================== 
FUNCTIONS LIST:

-DeploymentDatabase
-GenerateScriptDeploymentDB 
-GetFileEncoding
-LoadModuleSafe
-OpenFileWithTextEditor
-ReplaceCmdletParameterValueInFile
-SetFileEncoding
-SetFileEncoding_Directory
-Start-iseTranscript
========================================================================== #>


<# ========================================================================== 
ExecuteScript_InvokeSqlCmd
========================================================================== #>
<#
Propósito: Ejecuta script de base de datos SQL Server.
 El trabajo es delegado en el comando: invoke-sqlcmd.
Empresa: 
Desarrollador: Hugo González Olaya
Fecha: 2016-10-01
Fecha actualizacion: 2017-10-01

Parametros:
-$filePath: Ruta y nombre del script de despliegue. Alias: fullName, name, path.
-$resultPath: Ruta de archivos log de resultados. Si la ruta esta en blanco o no existe utiliza la misma ruta del script de despliegue.
-$serverSQLName: Nombre de instancia SQL. Alias: server.
-$databaseName: Nombre de base de datos SQL Server, puede estar en blanco. Alias: database.
-$trustedConnection: true: Indica utilizar autenticación de confianza. false: Indica autenticacion SQL, requiere usuario y password.
-$userName: Usuario para autenticacion en SQL. Alias: user.
-$password: Contraseña para autenticacion en SQL.
-$stopInError: Indica si debe detener la ejecucion en caso de error o continuar. true: Indica detener en case de error. false: Indica continuar.

Ejemplo:
ExecuteScript_InvokeSqlCmd "C:\Ruta\A00DeploymentDB.sql" `
 "C:\Ruta" "MySQLServer\SQL2017" "" $true "" "" $false;

NOTAS:
Si tiene estas advertencias al cargar modulos:
El servidor RPC no está disponible. (Excepción de HRESULT: 0x800706BA)
Suba los servicios: 
-Llamada a procedimiento remoto (RPC)              | Remote procedure call (RPC) 
-Ubicador de llamada a procedimiento remoto (RPC)  | Remote procedure call (RPC)  Locator
#>
function ExecuteScript_InvokeSqlCmd {
Param (
  	 [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
     [Alias('fullName', 'name', 'path')]
	 [string] $filePath
  	,[parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
	 [string] $resultPath
  	,[parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
     [Alias('server')]
	 [string] $serverSQLName
  	,[parameter(Mandatory = $false)]
     [Alias('database')]
	 [string] $databaseName
  	,[parameter(Mandatory = $false)]
	 [boolean] $trustedConnection = $true
  	,[parameter(Mandatory = $false)]
     [Alias('user')]
	 [string] $userName = ""
  	,[parameter(Mandatory = $false)]
	 [string] $password = ""
  	,[parameter(Mandatory = $false)]
	 [boolean] $stopInError = $false
)
 write-host ""
 write-host "Importando modulos SQL Server. Por favor espere, esto puede demorar ... " -f "Cyan";
 write-host ""

 $SqlServerOK = $false;
 try {
  write-host "Intentando cargar modulo: 'SqlServer' (SQL 2016 o superior) ... " -f "Cyan";
  if (!(LoadModuleSafe ("SqlServer"))) {
   write-host "No fue posible cargar el modulo: 'SqlServer'. Intentando cargar modulo: 'SQLPS' (SQL 2012 y SQL 2014) ... " -f "yellow";
   if (!(LoadModuleSafe ("SQLPS"))) {
    write-host "No fue posible cargar el modulo: 'SQLPS'. Intentando cargar modulo: SqlServerCmdletSnapin100 y SqlServerProviderSnapin100' (SQL 2008 R2 o inferior) ... " -f "yellow";
    Add-PSSnapin SqlServerCmdletSnapin100   
    Add-PSSnapin SqlServerProviderSnapin100
    write-host "Modulo cargado: 'SqlServerCmdletSnapin100 y SqlServerProviderSnapin100' (SQL 2008 R2 o inferior)" -f "yellow";
   } else {
    write-host "Modulo cargado: 'SQLPS' (SQL 2012 y SQL 2014)" -f "yellow";
   }
  } else {
   $SqlServerOK = $true;
   write-host "Modulo cargado: 'SqlServer' (SQL 2016 o superior)" -f "Cyan";
  }
 } catch {
   $msg = "No fue posible cargar modulo. Es probable que no tenga instalada herramientas cliente SQL Server o que no tenga permisos de aministrador. Message: '{0}'. Line: '{1}'" -f $_.Exception.Message, $_.InvocationInfo.ScriptLineNumber;
   Write-Error $msg;
 }
 write-host ("")

 try {
  if (-not(Test-Path -Path $filePath)) {
   throw "File or directory not found at {0}" -f $filePath; 
  }

  if ($stopInError -eq $true) { 
   $errAction = "Stop"; 
  } else { 
   $errAction = "SilentlyContinue"; 
  }

  if ($Host.Name -eq "Windows PowerShell ISE Host") {
   $ISE=$true;
  } else {
   $ISE=$false;
  }

  $ErrorActionPreference = "Stop"
  $errorMessage = "";
  $sqlerr = $null;
  $encoding = "UTF8";

  $dirDeployment = [IO.Path]::GetDirectoryName($filePath);
  $fnWithoutExt = [System.IO.Path]::GetFileNameWithoutExtension($filePath);

  if ( ($resultPath -eq "") -or (-not(Test-Path -Path $filePath)) ) {
   $resultPath = $dirDeployment;
  }
 
  $fileOut = [System.IO.Path]::Combine($resultPath, $fnWithoutExt + "_Out.log");
  $fileError = [System.IO.Path]::Combine($resultPath, $fnWithoutExt + "_Err.log");
  $fileOut_PS = [System.IO.Path]::Combine($resultPath, $fnWithoutExt + "_PS.log");
  
  try {			
   if (Test-Path $fileError) { 
    Remove-Item $fileError -force; 
   }
   if (Test-Path $fileOut) { 
    Remove-Item $fileOut -force;
   }
   if (Test-Path $fileOut_PS) { 
    Remove-Item $fileOut_PS -force; 
   }
  } catch {
   write-host "Error al borar archivo de log, es probable que este abierto. El proceso continua." -f "red" -BackgroundColor "Yellow";
  }

  #Iniciar archivo log 
  try {
   if ($Host.Version.Major -ge 4) {
    Start-Transcript -path $fileOut_PS -append -force;
   } else {
    write-host "Esta versión de PowerShell no permite genera archivo log, el proceso continua." -f "Cyan";
   }
  } catch {
   write-host "Error al crear archivo de log, el proceso continua sin dejar log." -f "red" -BackgroundColor "Yellow";
  }

  write-host ("")
  write-host "==========================================================================" -f "Cyan"
  write-host "Inicio despliegue:" $(get-date -format "yyyy-MM-dd HH:mm:ss") "PC:" $env:COMPUTERNAME". Usuario:" $(whoami)". Por favor espere ..." -f "Cyan"
  write-host "==========================================================================" -f "Cyan"  
  if ($SqlServerOK -eq $true) {
   $cnString = "Data Source=$serverSQLName;"

   if ($databaseName.Length -gt 0) { 
    $cnString += "Initial Catalog=$databaseName;"; 
   }
   if ($trustedConnection -eq $true) { 
    $cnString += "Integrated Security=True;"; 
   } else { 
    $cnString += "User ID=$userName; Password=$password;"; 
   }

   invoke-sqlcmd -ConnectionString $cnString -Verbose -ErrorAction $errAction -OutputSqlErrors $true -ErrorVariable sqlerr -QueryTimeout 0 -inputFile $filePath | out-File -filepath $fileOut -Encoding $encoding -force -Append;
  } else {
   if ($databaseName.Length -gt 0) {
    if ($trustedConnection -eq $true) { 
     invoke-sqlcmd -ServerInstance $serverSQLName -Database $databaseName -Verbose -ErrorAction $errAction -OutputSqlErrors $true -ErrorVariable sqlerr -QueryTimeout 0 -inputFile $filePath | out-File -filepath $fileOut -Encoding $encoding -force -Append;
    } else {
     invoke-sqlcmd -ServerInstance $serverSQLName -Username $userName -Password $password -Verbose -ErrorAction $errAction -OutputSqlErrors $true -ErrorVariable sqlerr -QueryTimeout 0 -inputFile $filePath | out-File -filepath $fileOut -Encoding $encoding -force -Append;
    }
   } else {
    if ($trustedConnection -eq $true) { 
     invoke-sqlcmd -ServerInstance $serverSQLName -Verbose -ErrorAction $errAction -OutputSqlErrors $true -ErrorVariable sqlerr -QueryTimeout 0 -inputFile $filePath | out-File -filepath $fileOut -Encoding $encoding -force -Append;
    } else {
     invoke-sqlcmd -ServerInstance $serverSQLName -Username $userName -Password $password -Verbose -ErrorAction $errAction -OutputSqlErrors $true -ErrorVariable sqlerr -QueryTimeout 0 -inputFile $filePath | out-File -filepath $fileOut -Encoding $encoding -force -Append;
    }
   }
  }

  if($sqlerr -ne $null) {
   $errorMessage = "Proceso terminado, pero con excepciones o advertencias. Revise los archivos de log.";
   write-host $errorMessage -f "Green";
   throw New-Object System.Exception ($errorMessage);
  }
 
  write-host ("");
  write-host "Proceso terminado en forma satisfactoria!" -f "Green";
 } catch {
  write-host ("")
  $msg = "Proceso terminado con error. Message: '{0}'. Line: '{1}'" -f $_.Exception.Message, $_.InvocationInfo.ScriptLineNumber;
  Write-Error $msg;
 } finally {
  $ErrorActionPreference = "Continue"
 }

 try {
  if($sqlerr -ne $null) {
    $sqlerr | Out-File $FileError -Encoding "UTF8" -Append -force;
    $sqlerr = $null;
  } 
 } catch {
  write-host ("");
  $msg = "ADVERTENCIA. No fue posible escribir en el archivo log de errores. Message: '{0}'. Line: '{1}'" -f $_.Exception.Message, $_.InvocationInfo.ScriptLineNumber;
  Write-Error $msg;
 }

 write-host ("")
 write-host "Fin deployment:" $(get-date -format "yyyy-MM-dd HH:mm:ss") -f "Cyan"

 try {
  if ($Host.Version.Major -ge 4) {
   Stop-Transcript;
  } else {
   Start-iseTranscript -logname $fileOut_PS;
  }
 } catch {
  write-host ("");
  $msg = "ADVERTENCIA. Error al generar archivo de log. El proceso continua. Message: '{0}'. Line: '{1}'" -f $_.Exception.Message, $_.InvocationInfo.ScriptLineNumber;
  Write-Error $msg;
 }


 try {
  write-host ("");
  if (Test-Path $fileOut_PS) { 
   OpenFileWithTextEditor($fileOut_PS); 
  }
  if (Test-Path $fileError) { 
   OpenFileWithTextEditor($fileError); 
  }
  if (Test-Path $fileOut) { 
   OpenFileWithTextEditor ($fileOut); 
  }
 } catch {
  $msg = "ADVERTENCIA. No fue posible abrir el archivo log de errores. El proceso continua. Message: '{0}'. Line: '{1}'" -f $_.Exception.Message, $_.InvocationInfo.ScriptLineNumber;
  Write-Error $msg;
 }
}


# ========================================================================== 
# GenerateScriptDeploymentDB
# ========================================================================== 
<#
Propósito: Genera archivo script par despliegue de objetos de base de datos SQL Server.
Empresa: 
Desarrollador: Hugo González Olaya
Fecha: 2016-10-01
Fecha actualizacion: 2017-10-01

Parametros:
-$pathDeployment: Ruta donde están los scripts (*.sql) para despliegue de objetos de base de datos. Alias: path.
-$fileDeployment: Nombre del script de despliegue (*.sql) a ser generado. Alias: name.

Ejemplo:
GenerateScriptDeploymentDB "C:\Ruta", "A00DeploymentDB.sql";
#>
function GenerateScriptDeploymentDB {
Param (
  	 [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
     [Alias('path')]
	 [string] $pathDeployment
  	,[parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
     [Alias('name')]
	 [string] $fileDeployment
)
 $newLine = "`r`n";
 $fullPath = [System.IO.Path]::Combine($pathDeployment, $fileDeployment);
 $filterFiles = "*.sql"; # Exclude: *.ssmssqlproj, *.sqlproj
 $fnWithoutExt = [System.IO.Path]::GetFileNameWithoutExtension($fileDeployment);

 if(Test-Path -Path $fullPath) {
  Remove-Item $fullPath -Force;
 }

 $content = "/* ==========================================================================" + $newLine;
 $content += "Proyecto:" + $newLine;
 $content += "Empresa: " + $newLine;
 $content += "Desarrollador: Hugo Gonzalez Olaya" + $newLine;
 $content += "Fecha: " + $(get-date -format "yyyy-MM-dd") + $newLine;
 $content += "Fecha actualizacion: " + $(get-date -format "yyyy-MM-dd") + $newLine;
 $content += "========================================================================== */" + $newLine;
 $content += "/* ==========================================================================" + $newLine;
 $content += "Script maestro de despliegue con scripts, a ser ejecutado en el orden escrito, utilizando PowerShell." + $newLine;
 $content += "Debe modificar las variables segun el entorno (Produccion, pruebas, desarrollo)." + $newLine;
 $content += "" + $newLine;
 $content += ":setvar MiVariable ""Valor""            : Creacion de variables" + $newLine;
 $content += "`$(MiVariable)                         : Utilizar variable en scripts *.sql" + $newLine;
 $content += ":r ""Path\MiScript.sql""                : Script a ser desplegado" + $newLine;
 $content += ":r "".\MiScript.sql""                   : Ejemplo ruta relativa" + $newLine;
 $content += ":r `$(PATH_DEPLOYMENT)""\A01CreaDB.sql"" : Ejemplo ruta absoluta" + $newLine;
 $content += "========================================================================== */" + $newLine;
 $content += "/* ==========================================================================" + $newLine;
 $content += "DEFINICION DE VARIABLES DE DESPLIEGUE: `$(MiVariable)" + $newLine;
 $content += "" + $newLine;
 $content += "========================================================================== */" + $newLine;
 $content += ":setvar PATH_DEPLOYMENT """ + $pathDeployment + """" + $newLine;
 $content += "" + $newLine;
 $content += "PRINT '----------------------------------------------------';" + $newLine;
 $content += "PRINT 'START DEPLOYMENT: " + $fileDeployment + "';" + $newLine;
 $content += "PRINT '----------------------------------------------------';" + $newLine;
 $content += "PRINT 'Despliegue en el servidor: ' + @@SERVERNAME + '. Desde el computador: ' + Convert(nvarchar(200), HOST_NAME());" + $newLine;
 $content += "PRINT 'Fecha inicio: ' + Convert(varchar(20), GetDate(), 120);" + $newLine;
 $content += "PRINT 'Ruta despliegue: `$(PATH_DEPLOYMENT)';" + $newLine;
 $content += "PRINT '';" + $newLine;
 $content += "GO" + $newLine;
 $content += "" + $newLine;
 $content += ":on ERROR EXIT" + $newLine;
 $content += "" + $newLine;
 $content += "/* ==========================================================================" + $newLine;
 $content += "SCRIPTS A DESPLEGAR (:r )" + $newLine;
 $content += "========================================================================== */" + $newLine;

 write-host ""; 
 write-host "Archivos referenciados en el script:" -f "Cyan"; 
 $dirParentPrevious = "";
 foreach ($item in Get-ChildItem -Path $pathDeployment -Recurse -Force -filter $filterFiles) {  
  $dirFile = [IO.Path]::GetDirectoryName($item.FullName);
  $fn = [System.IO.Path]::GetFileName($item.FullName);
  $ext = [System.IO.Path]::GetExtension($item.FullName);  
  $dirParent = $dirFile.replace($pathDeployment, "");
  $dirParentName = Split-Path $dirParent -Leaf; 

  if (($ext -in ".ssmssqlproj", ".sqlproj") -or ($fn -eq $fileDeployment) -or ($dirParentName -in "Z01Test", "Z02Test", "Z03Test")) {
   continue;
  }

  write-host $item.FullName -f "Cyan"; 
  if ($dirParent -ne $dirParentPrevious) {
   if ($dirParentPrevious -ne "") {
    $content += "" + $newLine;
    write-host "..." -f "Cyan"; 
   }
   $dirParentPrevious = $dirParent;
  }
  $content += ":r `$(PATH_DEPLOYMENT)""" + $dirParent + "\" + $fn + """" + $newLine;
 }
 $content += "GO" + $newLine;
 $content += "" + $newLine;
 $content += "PRINT '';" + $newLine;
 $content += "PRINT 'Fecha fin: ' + Convert(varchar(20), GetDate(), 120);" + $newLine;
 $content += "PRINT '----------------------------------------------------';" + $newLine;
 $content += "PRINT 'END DEPLOYMENT: " + $fileDeployment + "'" + $newLine;
 $content += "PRINT '----------------------------------------------------';" + $newLine;
 $content += "GO" + $newLine;
 $content | Out-File -filepath $fullPath -Force -Encoding "UTF8";
}

<# ========================================================================== 
GetFileEncoding
========================================================================== #>
<#
Propósito: Encuentra el encoding de un archivo buscando Byte Order Mark (BOM).
 Si no lo encuentra retorna el enconding por defecto.
Empresa: 
Desarrollador: Hugo González Olaya
Fecha: 2016-10-01
Fecha actualizacion: 2017-10-01

Parametros:
-$filePath: Ruta del archivo. Alias: fullName, name, path.
-$defaultEncoding: Encoding por defecto, utilizado en caso que no encuentre el encoding de un archivo.
 Los valores permitidos son: "ASCII", "BigEndianUnicode", "Default", "Unicode", "UTF32", "UTF7", "UTF8", "Byte"
 En lo posible solo utilice uno de estos dos: ASCII, UTF7. El valor por defecto es: ASCII.

Ejemplo:
write-host "Encoding_ANSI.txt:        " $(GetFileEncoding "C:\Ruta\Encoding_ANSI.txt" "ASCII");
write-host "Encoding_UTF8.txt         " $(GetFileEncoding "C:\Ruta\Encoding_UTF8.txt" "UTF7");

NOTAS: La funcion no encuentra el enconding para archivos ASCII (ANSI).
Tampoco funciona para detectar archivos UTF7 (Unicode sin BOM), la trama de los 4 primeros bytes es diferente para cada archivo.
#>
function GetFileEncoding
{
 Param (
  	 [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
     [Alias('fullName', 'name', 'path')]
	 [string] $filePath
	,[parameter(Mandatory = $false)]
     [ValidateSet("ASCII", "BigEndianUnicode", "Default", "Unicode", "UTF32", "UTF7", "UTF8", "Byte")]
	 [string] $defaultEncoding = 'ASCII' 
 )
 [byte[]]$byte = get-content -Encoding byte -ReadCount 4 -TotalCount 4 -Path $filePath;
 #Write-Host Bytes: $byte[0] $byte[1] $byte[2] $byte[3];

 if(!$byte) { return 'UTF8' }

 # EF BB BF (UTF8)
 if ( $byte[0] -eq 0xef -and $byte[1] -eq 0xbb -and $byte[2] -eq 0xbf ) { $encoding = 'UTF8'; }
 # FE FF (UTF-16 Big-Endian)
 elseif ($byte[0] -eq 0xfe -and $byte[1] -eq 0xff) { $encoding = 'BigEndianUnicode'; }
 # FF FE (UTF-16 Little-Endian)
 elseif ($byte[0] -eq 0xff -and $byte[1] -eq 0xfe) { $encoding = 'Unicode'; }
 # 00 00 FE FF (UTF32 Big-Endian)
 elseif ($byte[0] -eq 0 -and $byte[1] -eq 0 -and $byte[2] -eq 0xfe -and $byte[3] -eq 0xff) { $encoding = 'UTF32-be'; }
 # FE FF 00 00 (UTF32 Little-Endian)
 elseif ($byte[0] -eq 0xfe -and $byte[1] -eq 0xff -and $byte[2] -eq 0 -and $byte[3] -eq 0) { $encoding = 'UTF32-le'; }
 # 2B 2F 76 (38 | 38 | 2B | 2F)
 elseif ( (($byte[0] -eq 0x2b -and $byte[1] -eq 0x2f -and $byte[2] -eq 0x76) -and ($byte[3] -eq 0x38 -or $byte[3] -eq 0x39 -or $byte[3] -eq 0x2b -or $byte[3] -eq 0x2f)) )
 # -or ($byte[0] -eq 0x45 -and $byte[1] -eq 0x4a -and $byte[2] -eq 0x45 -and $byte[3] -eq 0x4d)
 { $encoding = 'UTF7';} 
 # F7 64 4C (UTF-1)
 elseif ( $byte[0] -eq 0xf7 -and $byte[1] -eq 0x64 -and $byte[2] -eq 0x4c ) { $encoding = 'Unicode'; }
 # DD 73 66 73 (UTF-EBCDIC)
 elseif ($byte[0] -eq 0xdd -and $byte[1] -eq 0x73 -and $byte[2] -eq 0x66 -and $byte[3] -eq 0x73) { $encoding = 'Unicode'; }
 # 0E FE FF (SCSU)
 elseif ( $byte[0] -eq 0x0e -and $byte[1] -eq 0xfe -and $byte[2] -eq 0xff ) { $encoding = 'SCSU'; }
 # FB EE 28 (BOCU-1)
 elseif ( $byte[0] -eq 0xfb -and $byte[1] -eq 0xee -and $byte[2] -eq 0x28 ) { $encoding = 'BOCU-1'; }
 # 84 31 95 33 (GB-18030)
 elseif ($byte[0] -eq 0x84 -and $byte[1] -eq 0x31 -and $byte[2] -eq 0x95 -and $byte[3] -eq 0x33) { $encoding = 'GB-18030'; }
 else { 
  $encoding = $defaultEncoding;
 }
 
 return $encoding;
}


<# ========================================================================== 
LoadModuleSafe
========================================================================== #>
<#
Propósito: Carga modulo, en caso de fallo no genera error.
 Retorna true si el proceso es satisfactorio, de lo contrario retorna false.
Empresa: 
Desarrollador: Hugo González Olaya
Fecha: 2016-10-01
Fecha actualizacion: 2016-10-01

Parametros:
-$name: Nombre del modulo. Alias: Module.

Ejemplo:
LoadModuleSafe ("SqlServer");
#>
function LoadModuleSafe {
param (
  	 [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
     [Alias('Module')]
	 [string] $name
)
 $retVal = $true;
 $installModule = $true;
 $overWrite = $true;

 try {
  # Si esta cargado no necesita importarlo
  if(Get-Module -Name $name) {
   $retVal = $true;
  } else {
   # si existe importarlo
   if ( Get-Module -ListAvailable | Where-Object { $_.name -eq $name } ) {
    Import-Module -Name $name;
   } else { 
    # Si no existe el modulo instalarlo
    if ($installModule) {
     if ($overWrite ) {
      try{
       Install-Module -Name $name -AllowClobber; # Si inicio PS como administrador
      } catch { 
       Install-Module -Name $name -Scope CurrentUser -AllowClobber;     
      }     
     } else {
      try {
       Install-Module -Name $name;  # Si inicio PS como administrador
      } catch {
       Install-Module -Name $name -Scope CurrentUser;
      }
     }
    } else {
     $retVal = $false;
    }
   }
  }
 } catch {
  $retVal = $false;
  #write-host "Excepcion in LoadModuleSafe: " $_.Exception.ToString() -f "red"
 } 

 return $retVal;
}

# ========================================================================== 
# OpenFileWithTextEditor
# ========================================================================== 
<#
Propósito: Abre el archivo especificado con la aplicacion con la cual este asociada en el sistema operativo.
Empresa: 
Desarrollador: Hugo González Olaya
Fecha: 2016-10-01
Fecha actualizacion: 2017-10-01

Parametros:
-$filePath: Ruta del archivo. Alias: fullName, name, path.

Ejemplo:
OpenFileWithTextEditor "C:\Ruta\Encoding_ANSI.txt";
#>
function OpenFileWithTextEditor {
param (
  	 [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
     [Alias('fullName', 'name', 'path')]
	 [string] $filePath
)
 try {
  Invoke-Item $filePath
 } catch {
  $msg = "Excepcion. Message: '{0}'. Line: '{1}'" -f $_.Exception.Message, $_.InvocationInfo.ScriptLineNumber;
  Write-Error $msg;
 }
}

# ========================================================================== 
# ReplaceCmdletParameterValueInFile
# ========================================================================== 
<#
Propósito: Cambia el valor de variable en script de despliegue SQL Server.
Empresa: 
Desarrollador: Hugo González Olaya
Fecha: 2018-07-15
Fecha actualizacion: 2018-07-15

Parametros:
-$file: Ruta y nombre del archivo
-$key: Variable.
-$value: Nuevo valor

Ejemplo:
D:\Temp\Setup\Script\MySolutionDB\A00Deployment\A00Deployment.sql

:setvar PATH_DEPLOYMENT "D:\Temp\Setup\Script\MySolutionDB"
........

$scriptfile = "C:\PowershellTest\UpdateImagesLocation.sql"

ReplaceCmdParameterValueInFile "D:\Temp\Setup\Script\MySolutionDB\A00Deployment\A00Deployment.sql" "PATH_DEPLOYMENT" "'C:\Temp\Setup\Script\MySolutionDB'";

$linkElement = "<a href=`"https://www.MyDomain.com/`" title='Simple quotes here'>A Link</a>"
$linkElement -Match "<a href=`"([^`"]+)`" title='([^']+)'>(.*?)</a>"
$Matches
#$Matches: array, 1 item = entire link, 2 = href attribute, 3 = title attribute, 4 = text of the link
#>
function ReplaceCmdletParameterValueInFile( $file, $key, $value ) {
 try
 {
  if(-not(Test-Path -Path $file)) {
   throw "File or directory not found at {0}" -f $file; 
  } 

  $matchQuoteDouble = ":setvar\s*$key\s*`"([^`"]+)`""; 
  $matchQuoteSingle = ":setvar\s*$key\s*'([^']+)'"; 
  $lineQuoteDouble = ":setvar $key `"$value`"";
  $lineQuoteSingle = ":setvar $key '$value'";
  $content = Get-Content $file;
  
  if ( $content -match $matchQuoteDouble) {
   $content -replace $matchQuoteDouble, $lineQuoteDouble | Set-Content $file;     
   write-host "VARIABLE MODIFICADA $lineQuoteDouble" -f "Cyan";
  } elseif ( $content -match $matchQuoteSingle) {
     $content -replace $matchQuoteSingle, $lineQuoteSingle | Set-Content $file;     
     write-host "VARIABLE MODIFICADA $lineQuoteSingle" -f "Cyan";
  } else {
	#Add-Content $file $lineQuoteDouble;
    write-host "VARIABLE NO ENCONTRADA $lineQuoteDouble" -f "Cyan";
  }
 } catch {
  $msg = "Error al remplazar variable en archivo. Archivo: '{0}'. Variable: {1}. Message: '{2}'. Line: '{3}'" -f $file, $key, $_.Exception.Message, $_.InvocationInfo.ScriptLineNumber;
  Write-Error $msg;
 }
}

<# ========================================================================== 
SetFileEncoding
========================================================================== #>
<#
Propósito: Cambia el encoding de un archivo. 
Genera un nuevo archivo en la ruta temporal del disco: [System.IO.Path]::GetTempPath() y luego lo mueve en la ruta y nombre destino.
Empresa: 
Desarrollador: Hugo González Olaya
Fecha: 2016-10-01
Fecha actualizacion: 2017-10-01

Parametros:
-$fileSource: Ruta y nombre del archivo origen. Alias: fullName, name, path.
-$encodingTarget: Nuevo encoding del archivo destino.
 Los valores permitidos son: "ASCII", "BigEndianUnicode", "Default", "Unicode", "UTF32", "UTF7", "UTF8", "Byte"
 Los siguientes enconding destino: "ASCII", "OEM", "String", "ANSI", son cambiados por: "Default", porque casos como: ASCII presentan errores de conversion. 
-$fileTarget: Ruta y nombre del archivo destino. Si no lo suministra utiliza el archivo origen, esto sobrescribe el archivo orgen con un nuevo encoding.
-$defaultEncoding: Encoding por defecto, utilizado en la funcion: Get-Encoding, en caso que no encuentre el encoding del archivo origen.
 Los valores permitidos son: "ASCII", "BigEndianUnicode", "Default", "Unicode", "UTF32", "UTF7", "UTF8", "Byte"
 En lo posible solo utilice uno de estos dos: ASCII, UTF7. El valor por defecto es: ASCII.

Ejemplo:
SetFileEncoding "C:\Ruta\Encoding_ANSI.txt" "UTF7" "C:\Ruta\Encoding_ANSI_UTF7.log" "ASCII");
SetFileEncoding "C:\Ruta\Encoding_UTF7_No_Bom.txt" "Default" "C:\Ruta\Encoding_UTF7_No_Bom_Default.log" "UTF7");
SetFileEncoding "C:\Ruta\Encoding_UTF7_No_Bom.txt" "UTF8" "C:\Ruta\Encoding_UTF7_No_Bom_UTF8.log" "UTF7");
SetFileEncoding "C:\Ruta\Encoding_UTF7_No_Bom.txt" "BigEndianUnicode" "C:\Ruta\Encoding_UTF7_No_Bom_BigEndianUnicode.log" "ASCII");
SetFileEncoding "C:\Ruta\Encoding_UTF7_No_Bom.txt" "Unicode" "C:\Ruta\Encoding_UTF7_No_Bom_Unicode.log" "ASCII");

NOTAS:
-Default:          Representa: ANSI y ASCII. 
-BigEndianUnicode: Representa UCS 2 big.
-Unicode:          Representa UCS 2 little.
-UTF7:             Representa Unicode sin bom.
-UTF8:             Representa unicode, en lo posible utilice este formato como destino en lugar de: UTF7, y mejor que: BigEndianUnicode y Unicode. 
#>
function SetFileEncoding {
 param (
  	 [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
     [Alias('fullName', 'name', 'path')]
     [string] $fileSource
	,[parameter(Mandatory = $true)]
     [ValidateSet("ASCII", "BigEndianUnicode", "Default", "Unicode", "UTF32", "UTF7", "UTF8", "Byte")]
     [string] $encodingTarget
	,[parameter(Mandatory = $false)][string] $fileTarget
	,[parameter(Mandatory = $false)]
     [ValidateSet("ASCII", "BigEndianUnicode", "Default", "Unicode", "UTF32", "UTF7", "UTF8", "Byte")]
     [string] $defaultEncoding = 'ASCII'
 )
 try
 {
  if(-not(Test-Path -Path $fileSource)) {
   throw "File or directory not found at {0}" -f $fileSource;
  }
  
  if ($fileTarget.Length -eq 0) { 
   $fileTarget = $fileSource; 
  }
  
  #Modifica el encoding destino 
  if ($encodingTarget -in "ASCII", "OEM", "String", "ANSI") {
   $encodingTarget = "Default";
  }

  $encoding = GetFileEncoding $fileSource $defaultEncoding;
  
  # Estos dos encoding se comporta igual a: UTF32
  if (($encoding -eq 'UTF32-be') -or ($encoding -eq 'UTF32-le')) {
   $encoding -eq 'UTF32';
  }

  #Si el enconding origen es igual al destino y la ruta destino es diferente, no requiere conversion.
  #Pero como la funcion que encuentra el encoding no detecta archivos UTF7 y ANSI, estos deben ser validados.
  if (($encoding -eq $encodingTarget) -and ($encoding -Notin "UTF7", "Default", "ASCII", "OEM", "String")) {
   if ($fileSource -ne $fileTarget) {
    # write-host "Only copy without transformation" -f "Green";
    Copy-Item -Path $fileSource -Destination $fileTarget -Force;
   }   
   return;
  }

  # Nombre del archivo temporal con cambio de enconding
  $dirTemp = [System.IO.Path]::GetTempPath();
  $dirFile = [IO.Path]::GetDirectoryName($fileSource);
  $fn = [System.IO.Path]::GetFileName($fileSource);
  $fnWithoutExt = [System.IO.Path]::GetFileNameWithoutExtension($fileSource);
  $ext = [System.IO.Path]::GetExtension($fileSource);

  $fileTemp = "TempEncode_" + $fn;
  $fileTemp = [System.IO.Path]::Combine($dirTemp, $fileTemp);

  switch ($encodingTarget.ToLower()) {
  "utf7" {    
    $Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding($False);

    if ($encoding -in "ASCII", "Default", "OEM", "string") {
     if ($defaultEncoding -in "ASCII", "Default", "OEM", "string") {
      $enc_ASCII = [system.Text.Encoding]::ASCII;
      $bytes_ASCII = [System.IO.File]::ReadAllBytes($fileSource);
      $contentCheck_ASCII = $enc_ASCII.GetString($bytes_ASCII);

      $content_UTF7 = [System.IO.File]::ReadAllText($fileSource, $Utf8NoBomEncoding);
      $bytes_UTF7 = $enc_ASCII.GetBytes($content_UTF7);
      $contentCheck_UTF7 = $enc_ASCII.GetString($bytes_UTF7);

      if ($contentCheck_ASCII -ne $contentCheck_UTF7) {
       Copy-Item -Path $fileSource -Destination $fileTemp -Force;
      } else {
       $content = Get-Content $fileSource;
       [System.IO.File]::WriteAllLines($fileTemp, $content, $Utf8NoBomEncoding);
      }          	 
     } else {
      $content = Get-Content $fileSource;
      [System.IO.File]::WriteAllLines($fileTemp, $content, $Utf8NoBomEncoding);
     }  
    }
    elseif ($encoding.ToLower() -eq "utf7") {
     if ($defaultEncoding -in "UTF7") {
      $enc_ASCII = [system.Text.Encoding]::ASCII;
      $bytes_ASCII = [System.IO.File]::ReadAllBytes($fileSource);
      $contentCheck_ASCII = $enc_ASCII.GetString($bytes_ASCII);

      $content_UTF7 = [System.IO.File]::ReadAllText($fileSource, $Utf8NoBomEncoding);
      $bytes_UTF7 = $enc_ASCII.GetBytes($content_UTF7);
      $contentCheck_UTF7 = $enc_ASCII.GetString($bytes_UTF7);

      if ($contentCheck_ASCII -eq $contentCheck_UTF7) {
       $content = Get-Content $fileSource;
       [System.IO.File]::WriteAllLines($fileTemp, $content, $Utf8NoBomEncoding);
      } else {
       $content = [System.IO.File]::ReadAllText($fileSource, $Utf8NoBomEncoding);
       [System.IO.File]::WriteAllLines($fileTemp, $content, $Utf8NoBomEncoding);
      }
     } else {
      $content = [System.IO.File]::ReadAllText($fileSource, $Utf8NoBomEncoding);
      [System.IO.File]::WriteAllLines($fileTemp, $content, $Utf8NoBomEncoding);
     }
    } else {
     $content = Get-Content $fileSource;
     [System.IO.File]::WriteAllLines($fileTemp, $content, $Utf8NoBomEncoding);
    }
   }

  default {
#   {$_ -in "default", "oem", "string"} {
    if ($encoding -in "ASCII", "Default", "OEM", "string") {
     if ($defaultEncoding -in "ASCII", "Default", "OEM", "string") {
      $Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding($False);
      $enc_ASCII = [system.Text.Encoding]::ASCII;
      $bytes_ASCII = [System.IO.File]::ReadAllBytes($fileSource);
      $contentCheck_ASCII = $enc_ASCII.GetString($bytes_ASCII);

      $content_UTF7 = [System.IO.File]::ReadAllText($fileSource, $Utf8NoBomEncoding);
      $bytes_UTF7 = $enc_ASCII.GetBytes($content_UTF7);
      $contentCheck_UTF7 = $enc_ASCII.GetString($bytes_UTF7);

      if ($contentCheck_ASCII -ne $contentCheck_UTF7) {
       $content = [System.IO.File]::ReadAllText($fileSource, $Utf8NoBomEncoding);
       $content | Set-Content $fileTemp -Force -Encoding $encodingTarget;
      } else {
       Get-Content $fileSource | Set-Content $fileTemp -Force -Encoding $encodingTarget;
      }   	 
     } else {
      Get-Content $fileSource | Set-Content $fileTemp -Force -Encoding $encodingTarget;
     }   	 
    }
    elseif ($encoding -eq "UTF7") {     
     $Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding($False);
      
     if ($defaultEncoding -in "UTF7") {
      $enc_ASCII = [system.Text.Encoding]::ASCII;
      $bytes_ASCII = [System.IO.File]::ReadAllBytes($fileSource);
      $contentCheck_ASCII = $enc_ASCII.GetString($bytes_ASCII);

      $content_UTF7 = [System.IO.File]::ReadAllText($fileSource, $Utf8NoBomEncoding);
      $bytes_UTF7 = $enc_ASCII.GetBytes($content_UTF7);
      $contentCheck_UTF7 = $enc_ASCII.GetString($bytes_UTF7);

      if ($contentCheck_ASCII -eq $contentCheck_UTF7) {
       if ($encodingTarget -in "default", "oem", "string") {
        Copy-Item -Path $fileSource -Destination $fileTemp -Force;
       } else {
        Get-Content $fileSource | Out-File $fileTemp -Encoding $encodingTarget -Force;
       }
      } else {
       $content = [System.IO.File]::ReadAllText($fileSource, $Utf8NoBomEncoding);
       $content | Set-Content $fileTemp -Force -Encoding $encodingTarget;
      }
     } else {
      $content = [System.IO.File]::ReadAllText($fileSource, $Utf8NoBomEncoding);
      $content | Set-Content $fileTemp -Force -Encoding $encodingTarget;
     }
    } else {
     Get-Content $fileSource | Out-File $fileTemp -Encoding $encodingTarget -Force;
    }
   }
  }

  # Copiar al destino y borrar archivo temporal
  Copy-Item -Path $fileTemp -Destination $fileTarget -Force;
  Remove-Item $fileTemp -Force;
 } catch {
  $msg = "Error al cambiar encoding. Message: '{0}'. Line: '{1}'" -f $_.Exception.Message, $_.InvocationInfo.ScriptLineNumber;
  Write-Error $msg;
 }
}

<# ========================================================================== 
SetFileEncoding_Directory
========================================================================== #>
<#
Propósito: Cambia el encoding de los archivos de un directorio, utilizando la función: SetFileEncoding. 
Empresa: 
Desarrollador: Hugo González Olaya
Fecha: 2016-10-01
Fecha actualizacion: 2017-10-01

Parametros:
-$pathSource: Ruta de archivos origen selecciados por el filtro especificado, tambien son procesadas las subcarpetas. Alias: fullName, name, path.
-$encodingTarget: Nuevo encoding de los archivos destino.
 Los valores permitidos son: "ASCII", "BigEndianUnicode", "Default", "Unicode", "UTF32", "UTF7", "UTF8", "Byte"
-$filterFiles: Filtro para seleccionar archivos a procesar, el valor por defecto son todo los archivos: "*.*". Ejemplo: "*.txt", "*.sql" 
-$pathTarget: Ruta destino. Por defecto esta en blanco.
-$fileTargetSufix: Sufijo adicionado al final de los archivos destino. Por defecto esta en blanco.
-$fileTargetExt: Nueva extension para los archivos destino. Por defecto esta en blanco que indica utilizar el mismo valor del archivo origen.
 Recuerde incluir un punto si va a cambiar la extension. Ejemplo: ".log", ".tmp".
-$defaultEncoding: Encoding por defecto, utilizado en la funcion: Get-Encoding, en caso que no encuentre el encoding del archivo origen.
 Los valores permitidos son: "ASCII", "BigEndianUnicode", "Default", "Unicode", "UTF32", "UTF7", "UTF8", "Byte"
 En lo posible solo utilice uno de estos dos: ASCII, UTF7. El valor por defecto es: ASCII.

Ejemplo:
SetFileEncoding_Directory "C:\Ruta" "UTF8" "*.txt" "_UTF8", ".Log", "ASCII");

NOTAS:
Si no suministra ruta destino, sufijo y extension, el archivo origen es sobrescrito con el encoding destino.

-Default:          Representa: ANSI y ASCII. 
-BigEndianUnicode: Representa UCS 2 big.
-Unicode:          Representa UCS 2 little.
-UTF7:             Representa Unicode sin bom.
-UTF8:             Representa unicode, en lo posible utilice este formato como destino en lugar de: UTF7, y mejor que: BigEndianUnicode y Unicode. 
#>
function SetFileEncoding_Directory {
 param (
  	 [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
     [Alias('FullName', 'Name', 'Path')]
	 [string] $pathSource
	,[parameter(Mandatory = $true)]
     [ValidateSet("ASCII", "BigEndianUnicode", "Default", "Unicode", "UTF32", "UTF7", "UTF8", "Byte")]
     [string] $encodingTarget
	,[parameter(Mandatory = $false)][string] $filterFiles = "*.*"
	,[parameter(Mandatory = $false)][string] $pathTarget = ""
	,[parameter(Mandatory = $false)][string] $fileTargetSufix = ""
	,[parameter(Mandatory = $false)][string] $fileTargetExt = ""
	,[parameter(Mandatory = $false)]
     [ValidateSet("ASCII", "BigEndianUnicode", "Default", "Unicode", "UTF32", "UTF7", "UTF8", "Byte")]
     [string] $defaultEncoding = 'ASCII'
 )
 if(-not(Test-Path -Path $pathSource)){
  throw "File or directory not found at {0}" -f $pathSource; 
 }

 foreach ($item in Get-ChildItem -Path $pathSource -Recurse -Force -filter $filterFiles) {  
  $dirFile = [IO.Path]::GetDirectoryName($item.FullName);
  $fn = [System.IO.Path]::GetFileName($item.FullName);
  $fnWithoutExt = [System.IO.Path]::GetFileNameWithoutExtension($item.FullName);
  $ext = [System.IO.Path]::GetExtension($item.FullName);

  if ($fileTargetExt.Length -ne 0) {
   $ext = $fileTargetExt;
  }
  if ($pathTarget.Length -eq 0) {
   $pathNewFile = $dirFile;
  } 
  else {
   $pathNewFile = $pathTarget;
  } 

  $fileTarget = $fnWithoutExt + $fileTargetSufix + $ext;
  $fileTarget = [System.IO.Path]::Combine($pathNewFile, $fileTarget);

  Write-host $item.FullName " ... " -f "Cyan";

  SetFileEncoding $item.FullName $encodingTarget $fileTarget $defaultEncoding;
 }
}

<# ========================================================================== 
Start-iseTranscript
========================================================================== #>
<#
Propósito: Guarda la salida de la consolo PS ISE en un archivo plano.
Empresa: 
Desarrollador: Hugo González Olaya
Fecha: 2016-10-01
Fecha actualizacion: 2016-10-01

Parametros:
-$logname: Ruta y nombre del archivo log. Ejemplo: C:\Log.log

Ejemplo:
Start-iseTranscript -logname “C:\Log.log”;

NOTAS:
-Este cmdlet fue creado para resolver el error: 
 System.Management.Automation.PSNotSupportedException: Este host no admite la transcripción. 
 This host does not support transcription.

-Windows PS v4 ISE e inferiores no soportan transcription. Debe utilizar la linea de comandos para ejecutar el commandlet.

-El contenido completo de la consola sera escrito en el archivo log. Esto significa que si ejecuta el script varias veces y no limpia el panel de salida, puede tener el resultado de varias ejecuciones.
#>
function Start-iseTranscript
{
Param(
  [parameter(Mandatory = $true)]
  [Alias('filePath', 'name', 'log')]
  [string] $logname
 )
 $transcriptHeader = @”
**************************************
Windows PowerShell ISE Transcript Start
Start Time: $(get-date -format "yyyy-MM-dd HH:mm:ss")
UserName: $(whoami)
ComputerName: $env:COMPUTERNAME
Windows version: $((Get-WmiObject win32_operatingsystem).version)
**************************************
Transcript started. Output file is $logname
“@
 $transcriptHeader >> $logname;

 #$psISE.CurrentPowerShellTab.Output.Text >> $logname;
 $psISE.CurrentPowerShellTab.ConsolePane.Text >> $logname

 #Keep current Prompt
 if ($Global:__promptDef -eq $null)
 {
   $Global:__promptDef =  (gci Function:Prompt).Definition
   $promptDef = (gci Function:Prompt).Definition
 } 
 else
 {
  $promptDef = $Global:__promptDef
 }

  $newPromptDef = @'

if ($Host.Version.Major -ge 4)
{
  if ($Global:_LastText -ne $psISE.CurrentPowerShellTab.ConsolePane.Text)
  {
    Compare-Object -ReferenceObject ($Global:_LastText.Split("`n")) -DifferenceObject ($psISE.CurrentPowerShellTab.ConsolePane.Text.Split("`n"))|?{$_.SideIndicator -eq "=>"}|%{ 
$_.InputObject.TrimEnd()}|Out-File -FilePath ($Global:_DSTranscript) -Append
    $Global:_LastText = $psISE.CurrentPowerShellTab.ConsolePane.Text
  }
} else {
  if ($Global:_LastText -ne $psISE.CurrentPowerShellTab.Output.Text)
  {
    Compare-Object -ReferenceObject ($Global:_LastText.Split("`n")) -DifferenceObject ($psISE.CurrentPowerShellTab.Output.Text.Split("`n"))|?{$_.SideIndicator -eq "=>"}|%{ 
$_.InputObject.TrimEnd()}|Out-File -FilePath ($Global:_DSTranscript) -Append
    $Global:_LastText = $psISE.CurrentPowerShellTab.Output.Text
  }
} 

'@ + $promptDef;

 if ($Host.Version.Major -ge 4) {
  $Global:_LastText = $psISE.CurrentPowerShellTab.ConsolePane.Text;
 } else {
  $Global:_LastText = $psISE.CurrentPowerShellTab.Output.Text;
 }
 New-Item -Path Function: -Name "Global:Prompt" -Value ([ScriptBlock]::Create($newPromptDef)) -Force|Out-Null;
}

function Start-iseTranscript2
{
Param(
  [parameter(Mandatory = $true)]
  [Alias('filePath', 'name', 'log')]
  [string] $logname
 )
  $transcriptHeader = @"
**************************************
Windows PowerShell ISE Transcript Start
Start Time: $(get-date -format "yyyy-MM-dd HH:mm:ss")
UserName: $(whoami)
ComputerName: $env:COMPUTERNAME
Windows version: $((Get-WmiObject win32_operatingsystem).version)
**************************************
Transcript started. Output file is $logname
"@
 $transcriptHeader >> $logname;
 
 $psISE.CurrentPowerShellTab.ConsolePane.Text >> $logname;
}
