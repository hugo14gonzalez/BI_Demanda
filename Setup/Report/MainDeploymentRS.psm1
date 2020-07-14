<# ========================================================================== 
PowerShell Funciones para Despliegue de Reporting Services
Empresa: 
Desarrollador: Hugo Gonzalez Olaya
Fecha: 2016-10-01
Fecha actualizacion: 2018-07-15
Email: hugo14.gonzalez@gmail.com

Links:
https://gist.github.com/Jonesie/9005796
https://gist.github.com/jstangroome/3043878
http://hindenes.com/trondsworking/2013/04/06/sql-reporting-services-ssrs-powershell-module/
http://randypaulo.wordpress.com/2012/02/21/how-to-install-deploy-ssrs-rdl-using-powershell/
https://www.mssqltips.com/sqlservertip/4429/sql-server-reporting-services-data-source-deployment-automation-with-powershell/

PS Tips: https://www.mssqltips.com/sql-server-tip-category/81/powershell/
RS.exe Utility (SSRS): https://msdn.microsoft.com/en-us/library/ms162839.aspx
========================================================================== #>

<# ========================================================================== 
FUNCTIONS LIST:
- SSRSCreateWebServiceProxy
- SSRSGetDataSourceInfo_FromFile
- SSRSGetDataSourceInfo_FromSSRS
- SSRSGetInstances
- SSRSGetItem
- SSRSNormalizeFolderName
- SSRSPublishDataSet
- SSRSPublishDataSource
- SSRSPublishDataSource_WithoutFile
- SSRSPublishFolder
- SSRSPublishReport
- SSRSPublishReport_Directory
- SSRSPublishResource
- SSRSRemoveFolder
- SSRSRemoveItem
- SSRSSetDataset
- SSRSSetDatasource
========================================================================== #>

<# ========================================================================== 
SSRSCreateWebServiceProxy
========================================================================== #>
<#
Propósito: Crea objeto proxy [New-WebServiceProxy] para realizar operaciones en SSRS.
Empresa: 
Desarrollador: Hugo González Olaya
Fecha: 2016-10-01
Fecha actualizacion: 2016-10-01

Parametros:
-$webServiceUrl: URL SQL Report manager.
 URL report manager (este es el que tenemos que utilizar): http://myreportserver/Reports_MySQLInstance
 URL web service: http://myreportserver/Reportserver_MySQLInstance
-$filePath: Archivo a ser desplegado.
-$credential: Credenciales de conexion al servidor de reportes.
-$versionWebService: Numero que va dentro de la URL del servicio. Ejemplo URL: "http://myreportserver/reportserver/ReportService2010.asmx?WSDL" 
 Para SQL 2005: 2005
 Para las demas versiones: 2010.

Ejemplo:
$user = "username";
$pass = ConvertTo-SecureString -AsPlainText -Force -String "password";
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $user, $pass;

$cred = Get-Credential -Message 'Enter credentials for the SSRS web service';
$ssrsProxy = SSRSCreateWebServiceProxy -webServiceUrl "http://myreportserver/reportserver" -Credential $cred -Verbose;
$ssrsProxy = SSRSCreateWebServiceProxy -webServiceUrl "http://myreportserver/reportserver" -Credential (get-credential) -Verbose;
$ssrsProxy = SSRSCreateWebServiceProxy -webServiceUrl "http://myreportserver/reportserver" -Verbose;
#>
function SSRSCreateWebServiceProxy
(
  [Parameter(Mandatory = $true)]
  [Alias('url')]
  [string]$webServiceUrl
 
 ,[Parameter(Mandatory = $false)]
  [System.Management.Automation.PSCredential]$credential = $null

 ,[Parameter(Mandatory = $false)]
  [Alias('verion')]
  [string]$versionWebService = "2010"
)
{
 if ($webServiceUrl -notmatch 'asmx') {
    $webServiceUrl = "$webServiceUrl/ReportService$versionWebService.asmx?WSDL";
 }

 $assembly = [AppDomain]::CurrentDomain.GetAssemblies() | Where-Object { $_.GetType('SSRS.ReportingService$versionWebService.ReportingService$versionWebService') };
 if (($assembly | Measure-Object).Count -gt 1) {
	throw 'AppDomain contains multiple definitions of the same type. Restart PowerShell host.'
 }

 if (-not $assembly) {
  $nameSpaceProxy = "SSRS.ReportService$versionWebService"; 
  #$nameSpaceProxy = "SSRS.ReportingService$versionWebService"; 
 } else {
  $nameSpaceProxy = "SSRS.ReportService$versionWebService.ReportService$versionWebService"; 
  #$nameSpaceProxy = "SSRS.ReportingService$versionWebService.ReportingService$versionWebService"; 
 }

 #Create Proxy
 Write-Verbose "[SSRSCreateWebServiceProxy()] Creating Proxy, connecting to: $webServiceUrl";

 if ($credential) {
  $ssrsProxy = New-WebServiceProxy -Uri $webServiceUrl -Credential $credential -ErrorAction 0;
  #$ssrsProxy = New-WebServiceProxy -Uri $webServiceUrl -Credential $credential -ErrorAction 0 -Namespace $nameSpaceProxy;
 } else {
  $ssrsProxy = New-WebServiceProxy -Uri $webServiceUrl -UseDefaultCredential -ErrorAction 0;
  #$ssrsProxy = New-WebServiceProxy -Uri $webServiceUrl -UseDefaultCredential -ErrorAction 0 -Namespace $nameSpaceProxy;
 }

 #Test that we're connected
 $members = $ssrsProxy | get-member -ErrorAction 0
 if (!($members)) {
   $msg = "Could not connect to the Reporting Service: '{0}'" -f $webServiceUrl;
   Write-Error $msg;
   Break;
 }

 return $ssrsProxy;
}

<# ========================================================================== 
SSRSGetDataSourceInfo_FromFile
========================================================================== #>
<#
Propósito: Retorna informacion de un archivo datasource SSRS *.RDS.
Empresa: 
Desarrollador: Hugo González Olaya
Fecha: 2016-10-01
Fecha actualizacion: 2016-10-01

Parametros:
-$filePath: archivo datasource *.RDS.

Ejemplo:
$dataSourceInfo = SSRSGetDataSourceInfo_FromFile -filePath "C:\MyDatasource1.rds";
#>
function SSRSGetDataSourceInfo_FromFile
{
param
(
 [ValidateScript({ Test-Path $_ })]
  [Parameter(Mandatory = $true)]
  [Alias('rds', 'file')]
  [string]$filePath
)
 try 
 {
  [xml]$xmldata = Get-Content $filePath;
  $connProps = $xmldata.RptDataSource.ConnectionProperties;
  
  $dataSourceName = $xmldata.RptDataSource.Name;
  $extension = $connProps.Extension; 
  $connectString = $connProps.ConnectString;
  $integratedSecurity = $connProps.IntegratedSecurity;

  if ([Convert]::ToBoolean($connProps.IntegratedSecurity))  {
   $credentialRetrieval = 'Integrated';
  }  else  {
   $credentialRetrieval = $connProps.CredentialRetrieval;
  }

  [PSCustomObject]@{
  'File' = $filePath;
  'Name' = $dataSourceName;
  'Extension' = $connProps.Extension;
  'ConnectString' = $connProps.ConnectString;
  'UserName' = $connProps.UserName;
  }
 } catch {
  $msg = "[SSRSGetDataSourceInfo_FromFile()] Error al consultar archivo: '{0}', Message: '{1}'. Linea: '{2}'" -f $filePath, $_.Exception.Message, $_.InvocationInfo.ScriptLineNumber;
  Write-Error $msg;
 } 
}

<# ========================================================================== 
SSRSGetDataSourceInfo_FromSSRS
========================================================================== #>
<#
Propósito: Chequea si un datasource SSRS es valido: que exista y que sea operacional.
Empresa: 
Desarrollador: Hugo González Olaya
Fecha: 2016-10-01
Fecha actualizacion: 2016-10-01

Parametros:
-$ssrsProxy: Instancia proxy de conexion a SSRS.
-$datasource: Ruta completa y nombre del datasource. Ejemplo: \MyApp\DataSources\MyDataSource1
-$noTest: Indica si realiza un test para validar que el datasource es operacional.

Ejemplo:
$ssrsProxy = SSRSCreateWebServiceProxy -webServiceUrl "http://myreportserver/reportserver";
SSRSGetDataSourceInfo_FromSSRS -ssrsProxy $ssrsProxy -datasource "\MyApp\DataSources\MyDataSource1" -NoTest;
SSRSGetDataSourceInfo_FromSSRS -ssrsProxy $ssrsProxy -datasource "\MyApp\DataSources\MyDataSource1";
#>
function SSRSGetDataSourceInfo_FromSSRS
{
param
(
  [Parameter(Mandatory = $true)]
  [object]$ssrsProxy

 ,[Parameter(Mandatory = $true)]
  [string]$datasource

 ,[Parameter(Mandatory = $false)]
  [switch]$noTest
)
 $datasource = SSRSNormalizeFolderName $datasource
 try
 {
  $reportType = $ssrsProxy.getitemtype($datasource);
  if ($reportType -eq 'DataSource') {
   $validObject = $ssrsProxy.Getdatasourcecontents($datasource);
   
   if ($validObject.gettype().name -eq 'DataSourceDefinitionOrReference' -or 'DataSourceDefinition')  {
    if ($noTest.IsPresent) {
     $validConnect = $false;
    } else  {
     $tempRef = $true; # have to initialize a variable so it can be used as a reference in the next method call
     $validConnect = $ssrsProxy.TestConnectForItemDataSource($datasource, $datasource, ($validObject.username), ($validObject.password), ([ref]$tempRef));
    }
    $validObject | Add-Member -type NoteProperty -Name 'Valid' -Value $validConnect;
    $validObject | Add-Member -Type NoteProperty -Name 'DataSource' -Value $datasource;
    
    [pscustomobject]$validObject;
   } else  {
    $invalid = 'invalidobject or permssion';
    [pscustomobject]@{
     'Extension' = $invalid
     'ConnectString' = $invalid
     'UseOriginalConnectString' = $false
     'OriginalConnectStringExpressionBased' = $false
     'CredentialRetrieval' = $invalid
     'ImpersonateUserSpecified' = $false
     'WindowsCredentials' = $false
     'Prompt' = $invalid
     'UserName' = $invalid
     'Password' = $invalid
     'Enabled' = $false
     'EnabledSpecified' = $false
     'Valid' = $false
     }
    }
   }
  } catch {
   $msg = "[SSRSGetDataSourceInfo_FromSSRS()] Error al validar el datasource: '{0}'. Message: '{1}'. Linea: '{2}'" -f $datasource, $_.Exception.Message, $_.InvocationInfo.ScriptLineNumber;
   Write-Error $msg;
  }
}

<# ========================================================================== 
SSRSGetInstances
========================================================================== #>
<#
Propósito: Retorna instancia SSRS.
Empresa: 
Desarrollador: Hugo González Olaya
Fecha: 2016-10-01
Fecha actualizacion: 2016-10-01

Parametros:
-$instanceSSRS: Instancia SSRS. Si no suministra este valor retorna lista con todas las instancias.
 No incluya el nombre del computador en el nombre de la instancia. 
 Por ejemplo: MyComputer\MySQLInstance, la instancia SSRS es: MySQLInstance.
-$computerName: Computador local o remoto en el cual buscar la instancia SSRS.

Retorna:
 Una o varias instancias SSRS.

Ejemplo:
$rsconfig = SSRSGetInstances;
$rsconfig = SSRSGetInstances "MyComputer1" "";
$rsconfig = SSRSGetInstances "MyComputer1" "SQL2016";
#>
function SSRSGetInstances {
param
(
  	 [parameter(Mandatory = $false)]
     [Alias('server', 'computer')]
	 [string] $computerName = $env:COMPUTERNAME

    ,[parameter(Mandatory = $false)]
     [Alias('SSRS', 'name', 'instance')]
	 [string] $instanceSSRS
)
 if(($computerName -eq $null) -or ($computerName -eq '') -or ($computerName -eq '.') -or ($computerName -eq 'Localhost') ) { 
    $computerName = $env:COMPUTERNAME;
 }

 write-host "Instances SSRS to computer:" $computerName -f "Cyan";
 $ReportingWMIInstances = @()
 $ReportingWMIInstances += Get-WmiObject -Namespace 'Root\Microsoft\SqlServer\ReportServer' -Class '__Namespace' -ErrorAction 0 -ComputerName $computerName
 if ($ReportingWMIInstances.count -lt 1) {
    Write-Error "Couldn't find any SQL Server Reporting Instances on this computer";
 }
 $ReportingInstances = @()
 Foreach ($ReportingWMIInstance in $ReportingWMIInstances) {
    $WMIInstanceName = $ReportingWMIInstance.Name
    $InstanceDisplayName = $WMIInstanceName.Replace('RS_', '')
    write-host $InstanceDisplayName -f "Cyan";

    $instanceSSRSSpace = "Root\Microsoft\SqlServer\ReportServer\$WMIInstanceName"
    $VersionInstance = get-wmiobject -Namespace $instanceSSRSSpace -class '__Namespace' -ErrorAction 0 -ComputerName $computerName
    $VersionInstanceName = $VersionInstance.Name
    $AdminNameSpace = "root\Microsoft\SqlServer\ReportServer\$WMIInstanceName\$VersionInstanceName\Admin";

    $filterInstance = "InstanceName='" + $InstanceDisplayName + "'";
    
    $ConfigSetting = get-wmiobject -namespace $AdminNameSpace -class 'MSReportServer_ConfigurationSetting' -ComputerName $computerName -filter $filterInstance; 
    #$ConfigSetting | add-member -MemberType NoteProperty -Name 'InstanceAdminNameSpace' -Value $AdminNameSpace;

    if ($ConfigSetting -ne $null)  {
     if ($computerName -ne $env:computername)   {
      if ($ConfigSetting.PathName -match '\w:')  {
        $driveletter = ($matches.values).trim(':')
        $configSettingPath = $ConfigSetting.pathname -replace '\w:', "\\$computerName\$driveletter$"
      }
      [xml]$ReportServerInstanceConfig = Get-content $configSettingPath
     } else {
      [xml]$ReportServerInstanceConfig = Get-content $ConfigSetting.PathName
     }
     $ConfigSetting | add-member -MemberType NoteProperty -Name 'ConfigFileSettings' -Value $ReportServerInstanceConfig;
     $ReportingInstances += $ConfigSetting;
    }
 }
 
 write-host "" -f "Cyan";
 if ($instanceSSRS) {
    $ReportingInstances = $ReportingInstances | Where-Object { $_.InstanceName -like $instanceSSRS }
 }

 return $ReportingInstances;
}

<# ========================================================================== 
SSRSGetItem
========================================================================== #>
<#
Propósito: Retorna elementos de reporte SSRS.
Empresa: 
Desarrollador: Hugo González Olaya
Fecha: 2016-10-01
Fecha actualizacion: 2016-10-01

Parametros:
-$ssrsProxy: Instancia proxy de conexion a SSRS.
-$itemName: Nombre del elemento de reporte a ser buscado. Si no es especificado retorna todo.
-$folderPath: Folder en el cual buscar los objetos.
-$type: Tipo de elemento a ser buscado. Ejemplo: 'ALL', 'Component', 'DataSource', 'DataSet', 'Folder', 'LinkedReport', 'Model', 'Resource', 'Report'.
-$recurse: Indica si busca en forma recursiva en las subcarpetas del folder especificado.

Ejemplo:
$ssrsProxy = SSRSCreateWebServiceProxy -webServiceUrl "http://myreportserver/reportserver";
$allitems = SSRSGetItem -ssrsProxy $ssrsProxy -itemName "MyReport" -folderPath "MyFolder" -recurse;
$allitems = SSRSGetItem -ssrsProxy $ssrsProxy -itemName "MyReport" -folderPath "MyFolder" -type "Report" -recurse;
#>
function SSRSGetItem {
param
(
  [Parameter(Mandatory = $true)]
  [object]$ssrsProxy

 ,[Parameter(Mandatory = $false)]
  [Alias('name', 'identity')]
  [string]$itemName = $null

 ,[Parameter(Mandatory = $false)]
  [Alias('folder', 'path')]
  [string]$folderPath = '/'

 ,[Parameter(Mandatory = $false)]
  [ValidateSet('ALL', 'Component', 'DataSource', 'DataSet', 'Folder', 'LinkedReport', 'Model', 'Resource', 'Report')]
  [Alias('TypeName', 'ItemType')]
  [string]$type = 'ALL'

 ,[Parameter(Mandatory = $false)]
  [switch]$recurse
)
 try
 {
  $folderPath = SSRSNormalizeFolderName -Folder $folderPath;
  $allitems = $ssrsProxy.ListChildren($folderPath, $recurse);
  if ($itemName) {
   $allitems = $allitems | Where-Object { $_.Name -like $itemName };
  }
  if ($type -and $type -ne 'ALL')  {
   $allitems = $allitems | Where-Object { $_.TypeName -eq $type };
  }

   return $allitems;
  } catch {
   return $null;
  }
}

<# ========================================================================== 
SSRSNormalizeFolderName
========================================================================== #>
<#
Propósito: Asegura que el nombre de un folder SSRS inicia con un solo slash (/).
Empresa: 
Desarrollador: Hugo González Olaya
Fecha: 2016-10-01
Fecha actualizacion: 2016-10-01

Parametros:
-$folder: Nombre de folder a ser normalizado.

Ejemplo:
SSRSNormalizeFolderName -Folder "MyFolder";
SSRSNormalizeFolderName -Folder "MyFolder/MySubFolder";
#>
function SSRSNormalizeFolderName
{
param
(
  [Parameter(Mandatory = $true)]
  [string]$folder
)
 if (-not $folder.StartsWith('/')) {
  $folder = '/' + $folder;
 } elseif ($folder -match '//') {
  $folder = $folder.replace('//','/');
 }
	
 return $folder;
}


<# ========================================================================== 
SSRSPublishDataSet
========================================================================== #>
<#
Propósito: Publica archivos data set en SSRS.
Empresa: 
Desarrollador: Hugo González Olaya
Fecha: 2016-10-01
Fecha actualizacion: 2016-10-01

Parametros:
-$ssrsProxy: Instancia proxy de conexion a SSRS.
-$filePath: Archivo a ser desplegado.
-$folderPath: Carpeta en la cual desplegar el archivo. Si el parametro es omitido, los archivos seran colocados en una carpeta llamada "DataSets".
-$itemName: Nombre del DataSet, si esta en blanco utiliza el nombre del archivo sin extension. 
-$dataSourceMappings: Arreglo con mapeo de nombres de datasourc [NombreEnReporte, NombreDestino]. 
-$dataSourceFolderTarget: Folder del data source destino en SSRS. Ejemplo /MyApp/DataSources. 
 Si no es suministrado busca ruta en la carpeta del dataset, en la anterior o en la principal del servidor.
-$overwrite: Indica si sobrescribir el objeto en caso que exista.

Ejemplo:
$ssrsProxy = SSRSCreateWebServiceProxy -webServiceUrl "http://myreportserver/reportserver";
$dataSourceMappings = @{};
$dataSourceMappings.Add("ds1", "ds1");
$dataSetMappings.Add("ds2", "ds2");
SSRSPublishDataSet -ssrsProxy $ssrsProxy -filePath "C:\MyDataSet.rsd" -folderPath "/MyApp/DataSets" -dataSourceMappings $dataSourceMappings -dataSourceFolderTarget "/MyApp/DataSources" -overwrite -Verbose;
#>
function SSRSPublishDataSet
{
param
(
  [Parameter(Mandatory = $true)]
  [object]$ssrsProxy

 ,[ValidateScript({ Test-Path $_ })]
  [Parameter(Mandatory = $true)]
  [Alias('rsd', 'file')]
  [string]$filePath

 ,[Parameter(Mandatory = $false)]
  [Alias('folder', 'path')]
  [string]$folderPath = 'DataSets'

 ,[Parameter(Mandatory = $false)]
  [Alias('name')]
  [string]$itemName = $null  

 ,[Parameter(Mandatory = $false, ValueFromPipeline = $true)]
  [array]$dataSourceMappings = $null  

 ,[Parameter(Mandatory = $false)]
  [string]$dataSourceFolderTarget  

 ,[Parameter(Mandatory = $false)]
  [switch]$overwrite = $false
) 
 try
 {  
  $folderPath = SSRSNormalizeFolderName -Folder $folderPath;
  SSRSPublishFolder -ssrsProxy $ssrsProxy -Folder $folderPath;

  $msg = "[SSRSPublishDataSet()] Start creating dataset: {0}" -f $itemName;
  Write-verbose $msg;

  if (!($itemName)) { 
   $itemName = [System.IO.Path]::GetFileNameWithoutExtension($filePath); 
  }

  $byteArray = Get-Content $filePath -encoding byte;
  
  $additionalProperties = $null;
  $uploadWarnings = $null;
  
  try {
   $itemResult = $ssrsProxy.CreateCatalogItem('DataSet', $itemName, $folderPath, $overwrite, $byteArray, $additionalProperties, [ref]$uploadWarnings) | Out-Null;
<#   
   if ($uploadWarnings) {
	foreach ($warn in $uploadWarnings) {
	 Write-Warning $warn.Message
	}
   }
#>   
  } catch [System.Web.Services.Protocols.SoapException] {
     if ($_.Exception.Detail.InnerText -match "[^rsItemAlreadyExists400]") {
      $msg = "[SSRSPublishDataSet()] Dataset: {0} already exists. Proccesss continua." -f $itemName;
      write-host $msg -f "Magenta";
     } else {
      $msg = "[SSRSPublishDataSet()] Error creating Dataset: {0}. Proccesss continua. Message: '{1}'" -f $itemName, $_.Exception.Detail.InnerText
      write-host $msg -f "Magenta";
     }
    } catch {
       $msg = "[SSRSPublishDataSet()] Error creating Dataset: {0}. Proccesss continua. DataSet: '{0}', Message: '{1}'" -f $itemName, $_.Exception.Message;
       write-host $msg -f "Magenta";
  }
  
  $itemResult = SSRSGetItem -ssrsProxy $ssrsProxy -itemName $itemName -folderPath $folderPath -type "DataSet";
  $itemResult = $itemResult | Sort-Object ModifiedDate -Descending | Select-Object -first 1;
  
  $objdataSource = $ssrsProxy.GetItemDataSources($itemResult.path);
  if ($objdataSource) {
   [xml]$xmldata = Get-content $filePath;
   $datasourceName = $xmldata.SharedDataSet.DataSet.query.DataSourceReference;
   
   if($dataSourceMappings){
    $dataSourceNameTarget = $dataSourceMappings."$datasourceName";
   }
   if (!($dataSourceNameTarget)){
    $dataSourceNameTarget = $datasourceName;
   }
   
   if($dataSourceFolderTarget) {
     $dataSourceFolderTarget = SSRSNormalizeFolderName -Folder $dataSourceFolderTarget;
     $ds = (SSRSGetItem -ssrsProxy $ssrsProxy -itemName $dataSourceNameTarget -folderPath $dataSourceFolderTarget -type "DataSource" -recurse) | Select-Object -first 1;
   } else {
    # find datasource in folder path
    $ds = (SSRSGetItem -ssrsProxy $ssrsProxy -itemName $dataSourceNameTarget -folderPath $folderPath -type "DataSource" -recurse) | Select-Object -first 1;
    if(!($ds))  {
	 # find datasource in folder parent
     $parts = $folderPath.Split('/' ,[System.StringSplitOptions]::RemoveEmptyEntries);
     $parent = $parts[0..($parts.Length-2)] -join '/'
     $ds = (SSRSGetItem -ssrsProxy $ssrsProxy -itemName $dataSourceNameTarget -folderPath $parent -type "DataSource" -recurse) | Select-Object -first 1;
    }
    #if(!($ds) -and $parent -ne "/") {
	# find datasource in folder main
	# $parent = "/";
    # $ds = (SSRSGetItem -ssrsProxy $ssrsProxy -itemName $dataSourceNameTarget -folderPath $parent -type "DataSource" -recurse) | Select-Object -first 1;
	#}
    if($ds) {
	 $dataSourceFolderTarget = $parent;
     $dataSourceFolderTarget = SSRSNormalizeFolderName -Folder $dataSourceFolderTarget;
    }	
   }
   
   if($ds) {
	$msg = "[SSRSPublishDataSet()] Setting dataset's dataSource: {0}. Dasource source: {1}. Datasource target: {2}/{3}" -f $itemResult.Name, $datasourceName, $dataSourceFolderTarget, $dataSourceNameTarget;
    Write-verbose $msg;

    #SSRSSetDatasource -ssrsProxy $ssrsProxy -reportPath $itemResult.Path -dataSourceName $datasourceName -dataSourceNameTarget $dataSourceNameTarget -dataSourceFolderTarget $dataSourceFolderTarget;
    SSRSSetDatasource -ssrsProxy $ssrsProxy -reportPath $itemResult.Path -dataSourceName "DataSetDataSource" -dataSourceNameTarget $dataSourceNameTarget -dataSourceFolderTarget $dataSourceFolderTarget;
   } else {
	$msg = "[SSRSPublishDataSet()] Warning dataSource not found to dataset: {0}. Dasource source: {1}. Datasource target: {2}/{3}" -f $itemResult.Name, $datasourceName, $dataSourceFolderTarget, $dataSourceNameTarget;
    write-host $msg -f "Magenta";
   }
  }

  $msg = "[SSRSPublishDataSet()] End create dataset: {0}" -f $itemName;
  Write-verbose $msg;
 
  return $itemResult;
 } catch [System.IO.IOException] {
  $msg = "[SSRSPublishDataSet()] Error while reading file : '{0}', Message: '{1}'" -f $filePath, $_.Exception.Message;
  Write-Error $msg;
 } catch [System.Web.Services.Protocols.SoapException] {
    if ($_.Exception.Detail.InnerText -match "[^rsItemAlreadyExists400]") {
     $msg = "[SSRSPublishDataSet()] DataSet: {0} already exists." -f $filePath;
     write-host $msg -f "Magenta";
    } else {
     $msg = "[SSRSPublishDataSet()] Error creating DataSet: {0}. Message: '{1}'" -f $filePath, $_.Exception.Detail.InnerText
     Write-Error $msg;
    }
 } catch {
  $msg = "[SSRSPublishDataSet()] Error publish file: '{0}', Message: '{1}'" -f $filePath, $_.Exception.Message;
  Write-Error $msg;
 }
}

<# ========================================================================== 
SSRSPublishDataSource
========================================================================== #>
<#
Propósito: Publica datasource SSRS.
Empresa: 
Desarrollador: Hugo González Olaya
Fecha: 2016-10-01
Fecha actualizacion: 2016-10-01

Parametros:
-$ssrsProxy: Instancia proxy de conexion a SSRS.
-$filePath: Archivo data source *.RDS.
-$folderPath: Folder en el cual crear el datasource. Ejemplo /MyApp/DataSources/MyDataSource.
-$connectString: Cadena de conexion al origen de datos.
-$credentialRetrieval: Modeo de recuperacion de las credenciales:
 None = Credentials are not required
 Store = Credentials stored securely in the report server requires setting the username and password and optional params are impersonate and windowsCredentials
 Prompt = Credentials supplied by the user running the report
 Integrated = Windows integrated security
-$windowsCredentials: Cuando utiliza $credentialRetrieval = 'Store', el datasource 'Utiliza credenciales de Windows cuando se conecta al data source'.
-$credential: Credenciales en caso que las credenciales sean almacenados en el servidor de reportes.
 Si $windowsCredentials = true, utiliza usuario de dominio: Domain\MyUser, de lo contario es un usuario del servidor de base de datos.
-$overwrite: Indica si sobrescribe el datasource en caso que exista.

Ejemplo:
$cred = Get-Credential -Message 'Enter credentials to autentication to data source';
$ssrsProxy = SSRSCreateWebServiceProxy -webServiceUrl "http://myreportserver/reportserver";
$itemResult = SSRSPublishDataSource -ssrsProxy $ssrsProxy -filePath "C:\MyDatasource1.rds" -folderPath "/MyApp/DataSources" 
 -connectString "Data Source=MySQLInstance;Initial Catalog=MyDataBase;Integrated Security=True;" 
 -credentialRetrieval "Store" -windowsCredentials $false -Credential $cred -overwrite -Verbose;
#>
function SSRSPublishDataSource (
  [Parameter(Mandatory = $true)]
  [object]$ssrsProxy
 
 ,[ValidateScript({ Test-Path $_ })]
  [Parameter(Mandatory = $true)]
  [Alias('rds', 'file')]
  [string]$filePath
 
 ,[Parameter(Mandatory = $true)]
  [Alias('folder', 'path')]
  [string]$folderPath
 
 ,[Parameter(Mandatory = $false)]
  [string]$connectString

 ,[Parameter(Mandatory = $false)]
  [ValidateSet('None', 'Prompt', 'Integrated', 'Store')]
  [string]$credentialRetrieval = 'Store'

 ,[Parameter(Mandatory = $false)]
  [boolean]$windowsCredentials = $false

 ,[Parameter(Mandatory = $false)]
  [System.Management.Automation.PSCredential]$credential = $null
 
 ,[Parameter(Mandatory = $false)]
  [switch]$overwrite
) 
{
 try 
 {
  $msg = "[SSRSPublishDataSource()] Start creating datasouce: {0}" -f $filePath;
  Write-verbose $msg;

  $folderPath = SSRSNormalizeFolderName -Folder $folderPath;

  [xml]$xmldata = Get-Content -Path $filePath;
  $dataSourceName = $xmldata.RptDataSource.Name;

  $connProps = $xmldata.RptDataSource.ConnectionProperties;
  if (!($connectString))  {
   $connectString = $connProps.ConnectString;
  } 
  
  $proxyNameSpace = $ssrsproxy.Gettype().Namespace;
  $datasourceDefType = "$proxyNameSpace.DataSourceDefinition"; 

  $datasourceDef = New-Object($datasourceDefType);
  $datasourceDef.Extension = $connProps.Extension; 
  $datasourceDef.ConnectString = $connectString;
  
  if ([Convert]::ToBoolean($connProps.IntegratedSecurity))  {
   $datasourceDef.CredentialRetrieval = 'Integrated';
  }
    
  $datasourceDef.CredentialRetrieval = $credentialRetrieval;
  if ($credentialRetrieval -eq 'Store') {
   $objCredentialRetrieval = new-object("$proxyNameSpace.CredentialRetrievalEnum");
   $objCredentialRetrieval.value__ = 1; # Stored
   $datasourceDef.CredentialRetrieval = $objCredentialRetrieval;
   $datasourceDef.WindowsCredentials = $windowsCredentials;
   if ($credential) {
    $datasourceDef.UserName = $credential.UserName;
    $datasourceDef.Password = $credential.GetNetworkCredential().password;
   }
  }
 
  $additionalProperties = $null;
  $itemResult = $ssrsProxy.CreateDataSource($dataSourceName, $folderPath, $overwrite, $datasourceDef, $additionalProperties);
  
  $itemResult = SSRSGetItem -ssrsProxy $ssrsProxy -itemName $dataSourceName -folderPath $folderPath -type "DataSource";
  $itemResult = $itemResult | Sort-Object ModifiedDate -Descending | Select-Object -first 1;  
  
  $msg = "[SSRSPublishDataSource()] End create datasouce: {0}" -f $dataSourceName;
  Write-verbose $msg;
  
  return $itemResult;
 } catch [System.IO.IOException] {
  $msg = "[SSRSPublishDataSource()] Error while reading file: '{0}', Message: '{1}'. Linea: '{2}'" -f $filePath, $_.Exception.Message, $_.InvocationInfo.ScriptLineNumber;
  Write-Error $msg;
 } catch [System.Web.Services.Protocols.SoapException] {
    if ($_.Exception.Detail.InnerText -match "[^rsItemAlreadyExists400]") {
     $msg = "[SSRSPublishDataSource()] DataSource: {0} already exists." -f $filePath;
     write-host $msg -f "Magenta";
    } else {
     $msg = "[SSRSPublishDataSource()] Error creating DataSource: {0}. Message: '{1}'" -f $filePath, $_.Exception.Detail.InnerText
     Write-Error $msg;
    }
 } catch {
  $msg = "[SSRSPublishDataSource()] Error publish file: '{0}', Message: '{1}'. Linea: '{2}'" -f $filePath, $_.Exception.Message, $_.InvocationInfo.ScriptLineNumber;
  Write-Error $msg;
 } 
}

<# ========================================================================== 
SSRSPublishDataSource_WithoutFile
========================================================================== #>
<#
Propósito: Crea un datasource SSRS.
Empresa: 
Desarrollador: Hugo González Olaya
Fecha: 2016-10-01
Fecha actualizacion: 2016-10-01

Parametros:
-$ssrsProxy: Instancia proxy de conexion a SSRS.
-$dataSourceName: Nombre del datasource.
-$folderPath: Folder en el cual crear el datasource. Ejemplo /MyApp/DataSources/MyDataSource.
-$extension: Tipo de datasource.
 'SQL' = SQL Server Connection
 'SQLAZURE' = SQL Azure Connection
 'OLEDB' = OLEDB connection 
 others: 'OLEDB-MD','ORACLE','ODBC','XML','SHAREPOINTLIST','SAPBW','ESSBASE','Report Server FileShare','NULL',
         'WORDOPENXML','WORD','IMAGE','RPL','EXCELOPENXML','EXCEL','MHTML','HTML4.0','RGDI','PDF','ATOM','CSV','NULL','XML'
-$connectString: Cadena de conexion al origen de datos.
-$credentialRetrieval: Modeo de recuperacion de las credenciales:
 None = Credentials are not required
 Store = Credentials stored securely in the report server requires setting the username and password and optional params are impersonate and windowsCredentials
 Prompt = Credentials supplied by the user running the report
 Integrated = Windows integrated security
-$windowsCredentials: Cuando utiliza $credentialRetrieval = 'Store', el datasource 'Utiliza credenciales de Windows cuando se conecta al data source'.
-$credential: Credenciales en caso que las credenciales sean almacenados en el servidor de reportes.
 Si $windowsCredentials = true, utiliza usuario de dominio: Domain\MyUser, de lo contario es un usuario del servidor de base de datos.
-$impersonateUser: Utilice true para utilizar 'impersonalizar el usuario autenticado despues que una conexion ha sido realizada al data source'.
-$overwrite: Indica si sobrescribe el datasource en caso que exista.

Ejemplo:
$cred = Get-Credential -Message 'Enter credentials to autentication to data source';
$ssrsProxy = SSRSCreateWebServiceProxy -webServiceUrl "http://myreportserver/reportserver";
SSRSPublishDataSource_WithoutFile -ssrsProxy $ssrsProxy -dataSourceName "MyDatasource1" -folderPath "/MyApp/DataSources" -Extension "SQL"
 -connectionString "Data Source=MySQLInstance;Initial Catalog=MyDataBase;Integrated Security=True;" 
 -credentialRetrieval "Store" -windowsCredentials $false -Credential $cred -impersonateuser $false -overwrite -Verbose;
#>
function SSRSPublishDataSource_WithoutFile
{
[CmdletBinding()]
param
(
  [Parameter(Mandatory = $true)]
  [object]$ssrsProxy

 ,[Parameter(Mandatory = $false)]
  [Alias('datasource')]
  [string]$dataSourceName

 ,[Parameter(Mandatory = $true)]
  [Alias('folder', 'path')]
  [string]$folderPath

 ,[Parameter(Mandatory = $true)]
  [ValidateSet('SQL','SQLAZURE','OLEDB','OLEDB-MD','ORACLE','ODBC','XML','SHAREPOINTLIST','SAPBW','ESSBASE','Report Server FileShare','NULL','WORDOPENXML','WORD','IMAGE','RPL','EXCELOPENXML','EXCEL','MHTML','HTML4.0','RGDI','PDF','ATOM','CSV','NULL','XML')]
  [string]$extension = 'SQL'

 ,[Parameter(Mandatory = $true)]
  [string]$connectString

 ,[Parameter(Mandatory = $false)]
  [ValidateSet('None', 'Prompt', 'Integrated', 'Store')]
  [string]$credentialRetrieval = 'Store'

 ,[Parameter(Mandatory = $false)]
  [boolean]$windowsCredentials = $false
  
 ,[Parameter(Mandatory = $false)]
  [System.Management.Automation.PSCredential]$credential = $null

 ,[Parameter(Mandatory = $false)]
  [boolean]$impersonateUser = $false 

 ,[Parameter(Mandatory = $false)]
  [switch]$overwrite
)
 try 
 {
  $msg = "[SSRSPublishDataSource_WithoutFile()] Start creating datasource: {0}" -f $dataSourceName;
  Write-verbose $msg;

  $folderPath = SSRSNormalizeFolderName -Folder $folderPath;

  $proxyNameSpace = $ssrsproxy.gettype().Namespace;
  $datasourceDef = New-Object("$proxyNameSpace.DataSourceDefinition") ;
  $datasourceDef.connectstring = $connectString;
  $datasourcedef.Extension = $extension;
  
  if ($credentialRetrieval -eq 'Store') {
   $datasourceDef.CredentialRetrieval = $credentialRetrieval;
   $datasourceDef.WindowsCredentials = $windowsCredentials;
   if ($credential) {
    $datasourceDef.UserName = $credential.UserName;
    $datasourceDef.Password = $credential.GetNetworkCredential().password;
   }
  }

  $datasourceDefHash = @{
    'ConnectString' = $connectString; 
    'UserName' = $username; 
    'Password' = $password; 
    'WindowsCredentials' = $windowsCredentials; 
    'Enabled' = $true; 
    'Extension' = $extension; 
    'ImpersonateUser' = $impersonateUser; 
    'ImpersonateUserSpecified' = $true; 
    'CredentialRetrieval' = $credentialRetrieval
  }
  
  $additionalProperties = $null;
  $itemResult = $ssrsProxy.CreateDataSource($dataSourceName, $folderPath, $overwrite, $datasourceDef, $additionalProperties);
  
  $itemResult = SSRSGetItem -ssrsProxy $ssrsProxy -itemName $dataSourceName -folderPath $folderPath -type "DataSource";
  $itemResult = $itemResult | Sort-Object ModifiedDate -Descending | Select-Object -first 1;  
  
  $msg = "[SSRSPublishDataSource_WithoutFile()] End create datasource: {0}" -f $dataSourceName;
  Write-verbose $msg;
  
  return $itemResult;
 } catch [System.Web.Services.Protocols.SoapException] {
    if ($_.Exception.Detail.InnerText -match "[^rsItemAlreadyExists400]") {
     $msg = "[SSRSPublishDataSource_WithoutFile()] DataSource: {0} already exists." -f $dataSourceName;
     write-host $msg -f "Magenta";
    } else {
     $msg = "[SSRSPublishDataSource_WithoutFile()] Error creating DataSource: {0}. Message: '{1}'" -f $dataSourceName, $_.Exception.Detail.InnerText
     Write-Error $msg;
    }
 } catch {
  $msg = "[SSRSPublishDataSource_WithoutFile()] Error creating datasource: '{0}'. Message: '{1}'. Linea: '{2}'" -f $dataSourceName, $_.Exception.Message, $_.InvocationInfo.ScriptLineNumber;
  Write-Error $msg;
 }
}

<# ========================================================================== 
SSRSPublishFolder
========================================================================== #>
<#
Propósito: Crea folder SSRS.
Empresa: 
Desarrollador: Hugo González Olaya
Fecha: 2016-10-01
Fecha actualizacion: 2016-10-01

Parametros:
-$ssrsProxy: Instancia proxy de conexion a SSRS.
-$folder: Folder a ser creado.

Ejemplo:
$ssrsProxy = SSRSCreateWebServiceProxy -webServiceUrl "http://myreportserver/reportserver";
SSRSPublishFolder -ssrsProxy $ssrsProxy -folder "MyFolder1" -Verbose;
SSRSPublishFolder -ssrsProxy $ssrsProxy -folder "MyFolder2\MyFolder3" -Verbose;
#>
function SSRSPublishFolder
{
param
(
  [Parameter(Mandatory = $true)]
  [object]$ssrsProxy

 ,[Parameter(Mandatory = $true)]
  [Alias('name', 'path', 'folderPath')]
  [string]$folder
)
 $folder = SSRSNormalizeFolderName -Folder $folder;
 try
 {
  if ($ssrsProxy.GetItemType($folder) -ne 'Folder')  {
   $parts = $folder -split '/';
   $leaf = $parts[-1];
   $parent = $parts[0..($parts.Length-2)] -join '/'
   
   if ($parent)  {
    SSRSPublishFolder -ssrsProxy $ssrsProxy -folder $parent;
   } else  {
    $parent = '/'
   }        
   $msg = "[SSRSPublishFolder()] Start creating folder: '{0}'. Parent: '{1}'" -f $leaf, $parent;
   Write-Verbose $msg;

   $itemResult = $ssrsProxy.CreateFolder($leaf, $parent, $null);

   $msg = "[SSRSPublishFolder()] End create folder: '{0}/{1}'" -f $parent, $leaf;
   Write-Verbose $msg;
  }
 } catch [System.Web.Services.Protocols.SoapException] {
  if ($_.Exception.Detail.InnerText -match '[^rsItemAlreadyExists400]') {
	Write-Verbose "[SSRSPublishFolder()] Error creating folder: $folder, folder cant exists."
	$msg = "Error creating folder: '{0}'. Msg: '{1}'" -f $folder, $_.Exception.Detail.InnerText;
	Write-Error $msg;
  } else {
	$msg = "Error creating folder: '{0}'. Msg: '{1}'" -f $folder, $_.Exception.Detail.InnerText;
	Write-Error $msg;
  }
 }
}

<# ========================================================================== 
SSRSPublishReport
========================================================================== #>
<#
Propósito: Despliega reporte SSRS.
Empresa: 
Desarrollador: Hugo González Olaya
Fecha: 2016-10-01
Fecha actualizacion: 2016-10-01

Parametros:
-$ssrsProxy: Instancia proxy de conexion a SSRS.
-$filePath: Archivo a ser desplegado.
-$folderPath: Folder en el cual desplegar el archivo.
-$itemName: Nombre del reporte, si esta en blanco utiliza el nombre del archivo sin extension RDL. 
-$dataSourceMappings: Arreglo con mapeo de nombres de datasource [NombreEnReporte, NombreDestino]. 
-$dataSourceFolderTarget: Folder del data source destino en SSRS. Ejemplo /MyApp/DataSources. 
-$dataSetMappings: Arreglo con mapeos de datasets [NombreEnReporte, NombreDestino]
-$dataSetFolderTarget: Folder del data set destino en SSRS. Ejemplo /MyApp/DataSets.
-$overwrite: Indica si debe sobrescribir el reporte en caso que exista.

Ejemplo:
$ssrsProxy = SSRSCreateWebServiceProxy -webServiceUrl "http://myreportserver/reportserver";
$dataSourceMappings = @{};
$dataSourceMappings.Add("ds1", "ds1");
$dataSetMappings.Add("ds2", "ds2");
$dataSetMappings = @{};
$dataSetMappings.Add("DataSet1", "SharDataSet1");
$dataSetMappings.Add("DataSet2", "SharDataSet2");
SSRSPublishReport -ssrsProxy $ssrsProxy -filePath "C:\MyReport.rdl" -folderPath "/MyApp" -dataSourceMappings $dataSourceMappings -dataSourceFolderTarget "/MyApp/DataSources" -dataSetMappings $dataSetMappings -dataSetFolderTarget "/MyApp/DataSets" -overwrite -Verbose;
#>
function SSRSPublishReport
{
param
(
  [Parameter(Mandatory = $true)]
  [object]$ssrsProxy

 ,[ValidateScript({ Test-Path $_ })]
  [Parameter(Mandatory = $true)]
  [Alias('rdl')]
  [string]$filePath
 
 ,[Parameter(Mandatory = $false)]
  [Alias('folder')]
  [string]$folderPath = ''

 ,[Parameter(Mandatory = $false)]
  [Alias('name')]
  [string]$itemName = ''

 ,[Parameter(Mandatory = $false, ValueFromPipeline = $true)]
  [array]$dataSourceMappings = $null  

 ,[Parameter(Mandatory = $false)]
  [string]$dataSourceFolderTarget = $null 

 ,[Parameter(Mandatory = $false, ValueFromPipeline = $true)]
  [array]$dataSetMappings = $null
  
 ,[Parameter(Mandatory = $false)]
  [string]$dataSetFolderTarget = $null

 ,[Parameter(Mandatory = $false)]
  [switch]$overwrite = $false
)
 $folderPath = SSRSNormalizeFolderName -Folder $folderPath;
 SSRSPublishFolder -ssrsProxy $ssrsProxy -Folder $folderPath;
 
 try
 {
  $msg = "[SSRSPublishReport()] Start creating report: {0}" -f $itemName;
  Write-verbose $msg;

  if (!($itemName)) {
   $itemName = [System.IO.Path]::GetFileNameWithoutExtension($filePath); 
  }

  $byteArray = Get-Content $filePath -encoding byte;  
  $uploadWarnings = $null;
  
  try {
   if ($ssrsProxy.Url.Contains('ReportService2005.asmx') -or $ssrsProxy.Url.Contains('ReportService2006.asmx')) {
	$itemResult = $ssrsProxy.CreateReport($itemName, $folderPath, $overwrite, $byteArray, $null);
   } else {
    $itemResult = $ssrsProxy.CreateCatalogItem('Report', $itemName, $folderPath, $overwrite, $byteArray, $null, [ref]$uploadWarnings) | Out-Null;
   }
<#   
   if ($uploadWarnings) {
	foreach ($warn in $uploadWarnings) {
	 Write-Warning $warn.Message
	}
   }
#>   
  } catch [System.Web.Services.Protocols.SoapException] {
     if ($_.Exception.Detail.InnerText -match "[^rsItemAlreadyExists400]") {
      $msg = "[SSRSPublishReport()] Report: {0} already exists. Proccesss continua." -f $itemName;
      write-host $msg -f "Magenta";
     } else {
      $msg = "[SSRSPublishReport()] Error creating report: {0}. Proccesss continua. Message: '{1}'" -f $itemName, $_.Exception.Detail.InnerText
      write-host $msg -f "Magenta";
     }
    } catch {
       $msg = "[SSRSPublishReport()] Error creating report: {0}. Proccesss continua. DataSet: '{0}', Message: '{1}'" -f $itemName, $_.Exception.Message;
       write-host $msg -f "Magenta";
  }
   
  $itemResult = SSRSGetItem -ssrsProxy $ssrsProxy -itemName $itemName -folderPath $folderPath -type "Report";
  $itemResult = $itemResult | Sort-Object ModifiedDate -Descending | Select-Object -first 1;

  $dataSources = $ssrsProxy.GetItemDataSources($itemResult.path);
  foreach ($itemDS in $datasources)  {
   if($dataSourceMappings){
    #$dataSourceNameTarget = $dataSourceMappings[$itemDS.Name];
    $dataSourceNameTarget = $dataSourceMappings."$itemDS.Name";
   }
   if (!($dataSourceNameTarget)){
    $dataSourceNameTarget = $itemDS.Name;
   }
   
   if($dataSourceFolderTarget) {
     $dataSourceFolderTarget = SSRSNormalizeFolderName -Folder $dataSourceFolderTarget;
     $ds = (SSRSGetItem -ssrsProxy $ssrsProxy -itemName $dataSourceNameTarget -folderPath $dataSourceFolderTarget -type "DataSource" -recurse) | Select-Object -first 1;
   } else {
    # find datasource in folder path
    $ds = (SSRSGetItem -ssrsProxy $ssrsProxy -itemName $dataSourceNameTarget -folderPath $folderPath -type "DataSource" -recurse) | Select-Object -first 1;
    if(!($ds))  {
	 # find datasource in folder parent
     $parts = $folderPath.Split('/' ,[System.StringSplitOptions]::RemoveEmptyEntries);
     $parent = $parts[0..($parts.Length-2)] -join '/'
     $ds = (SSRSGetItem -ssrsProxy $ssrsProxy -itemName $dataSourceNameTarget -folderPath $parent -type "DataSource" -recurse) | Select-Object -first 1;
    }
    #if(!($ds) -and $parent -ne "/") {
	# find datasource in folder main
	# $parent = "/";
    # $ds = (SSRSGetItem -ssrsProxy $ssrsProxy -itemName $dataSourceNameTarget -folderPath $parent -type "DataSource" -recurse) | Select-Object -first 1;
	#}
    if($ds) {
	 $dataSourceFolderTarget = $parent;
     $dataSourceFolderTarget = SSRSNormalizeFolderName -Folder $dataSourceFolderTarget;
    }	
   } 
   
   if($ds) {
    $msg = "[SSRSPublishReport()] Setting report's dataSource: {0}. Dasource source: {1}. Datasource target: {2}/{3}" -f $itemResult.Name, $itemDS.Name, $dataSourceFolderTarget, $dataSourceNameTarget;
    Write-verbose $msg;

    SSRSSetDatasource -ssrsProxy $ssrsProxy -reportPath $itemResult.Path -dataSourceName $itemDS.Name -dataSourceNameTarget $dataSourceNameTarget -dataSourceFolderTarget $dataSourceFolderTarget;
   } else {
	$msg = "[SSRSPublishReport()] Warning dataSource not found to report: {0}. Dasource source: {1}. Datasource target: {2}/{3}" -f $itemResult.Name, $itemDS.Name, $dataSourceFolderTarget, $dataSourceNameTarget;
    write-host $msg -f "Magenta";
   }
  }
  
  $DataSetReferences = @();
  $DataSetReferences += $ssrsProxy.GetItemReferences($itemResult.path, 'DataSet') | Where-Object { $_.Reference -eq $null };
  $newItemReferences = @();
  foreach ($itemDSet in $DataSetReferences) {
   $dataSetFolderTarget = SSRSNormalizeFolderName -Folder $dataSetFolderTarget;
   $msg = "[SSRSPublishReport()] Setting report's dataset: {0}. Dataset: {1}." -f $itemResult.Name, $itemDSet.Name;
   Write-verbose $msg;

   SSRSSetDataset -ssrsProxy $ssrsProxy -reportPath $itemResult.Path -dataSetName $itemDSet.Name -dataSetMappings $dataSetMappings -dataSetFolderTarget $dataSetFolderTarget;
  }

  $msg = "[SSRSPublishReport()] End create report: {0}" -f $itemName;
  Write-verbose $msg;
  
  return $itemResult;
 } catch [System.IO.IOException] {
  $msg = "[SSRSPublishReport()] Error while reading file: '{0}', Message: '{1}'. Linea: '{2}'" -f $filePath, $_.Exception.Message, $_.InvocationInfo.ScriptLineNumber;
  Write-Error $msg;
 } catch [System.Web.Services.Protocols.SoapException] {
    if ($_.Exception.Detail.InnerText -match "[^rsItemAlreadyExists400]") {
     $msg = "[SSRSPublishReport()] Report: {0} already exists." -f $ReportName;
     Write-Error $msg;
    } else {
     $msg = "[SSRSPublishReport()] Error creating Report: {0}. Message: '{1}'" -f $ReportName, $_.Exception.Detail.InnerText
     Write-Error $msg;
    }
 } catch {
  $msg = "[SSRSPublishReport()] Error publish file (or config dataSource or config dataSet): '{0}', Message: '{1}'. Linea: '{2}'" -f $filePath, $_.Exception.Message, $_.InvocationInfo.ScriptLineNumber;
  Write-Error $msg;
 }
}

<# ========================================================================== 
SSRSPublishReport_Directory
========================================================================== #>
<#
Propósito: Despliega todos los reportes contenidos en una carpeta en el servidor de reportes SSRS.
 Esta funcion no descarga datasource o dataset, pero cualquier referencia a estos sera revinculados a datasources en el servidor, si estos existen.
Empresa: 
Desarrollador: Hugo González Olaya
Fecha: 2016-10-01
Fecha actualizacion: 2016-10-01

Parametros:
-$ssrsProxy: Instancia proxy de conexion a SSRS.
-$directory: Directorio en disco con los archivos a ser desplegados.
-$folderPath: Folder en el cual desplegar los reportes.
-$filterInclude: Lista de archivo a ser publicados. Ejemplo: "*.*", "*.rdl"
-$filterExclude: Lista de valores seprada por coma, utilizada como filtro para excluir archivos, el valor por defecto es: "*.rptproj, *.user, *.vspscc, *Backup.*, *.rds, *.rsd". 
 Ejemplo: "*.rds, *.rsd"
-$dataSourceMappings: Arreglo con mapeo de nombres de datasource [NombreEnReporte, NombreDestino]. 
-$dataSourceFolderTarget: Folder del data source destino en SSRS. Ejemplo /MyApp/DataSources. 
-$dataSetMappings: Arreglo con mapeos de datasets [NombreEnReporte, NombreDestino]
-$dataSetFolderTarget: Folder del data set destino en SSRS. Ejemplo /MyApp/DataSets.
-$recurse: Indica si busca en forma recursiva en las subcarpetas del folder especificado.
-$overwrite: Indica si debe sobrescribir el elemento en caso que exista.

Ejemplo:
$ssrsProxy = SSRSCreateWebServiceProxy -webServiceUrl "http://myreportserver/reportserver";
$dataSourceMappings = @{};
$dataSourceMappings.Add("ds1", "ds1");
$dataSetMappings.Add("ds2", "ds2");
$dataSetMappings = @{};
$dataSetMappings.Add("DataSet1", "SharDataSet1");
$dataSetMappings.Add("DataSet2", "SharDataSet2");
SSRSPublishReport_Directory -ssrsProxy $ssrsProxy -directory "C:\MyReportFiles\*" -folderPath "/MyApp" -dataSourceMappings $dataSourceMappings -dataSourceFolderTarget "/MyApp/DataSources" -dataSetMappings $dataSetMappings -dataSetFolderTarget "/MyApp/DataSets" -overwrite -recurse -Verbose;
#>
Function SSRSPublishReport_Directory
{
param
(
  [Parameter(Mandatory = $true)]
  [object]$ssrsProxy

 ,[ValidateScript({ Test-Path $_ })]
  [Parameter(Mandatory = $true)]
  [string]$directory

 ,[Parameter(Mandatory = $false)]
  [Alias('folder', 'path')]
  [string]$folderPath = ''

 ,[parameter(Mandatory = $false)]
  [Alias('Include')]
  [string] $filterInclude = "*.*"

 ,[parameter(Mandatory = $false)]
  [Alias('Exclude')]
  [string] $filterExclude = "*.rptproj,*.user,*.vspscc,*Backup*.*,*.rds,*.rxsd"

 ,[Parameter(Mandatory = $false, ValueFromPipeline = $true)]
  [array]$dataSourceMappings = $null  

 ,[Parameter(Mandatory = $false)]
  [string]$dataSourceFolderTarget = $null 

 ,[Parameter(Mandatory = $false, ValueFromPipeline = $true)]
  [array]$dataSetMappings = $null
  
 ,[Parameter(Mandatory = $false)]
  [string]$dataSetFolderTarget = $null

 ,[Parameter(Mandatory = $false)]
  [switch]$overwrite = $false

 ,[Parameter(Mandatory = $false)]
  [switch]$recurse
)
 $msg = "[SSRSPublishReport_Directory()] Start creating items from directory: {0}" -f $directory;
 Write-verbose $msg;

 if (-not $directory.EndsWith('*')) {
  $directory = [System.IO.Path]::Combine($directory, "*");
 }
 
 $arrDir = @($directory.split(',')); 
 $arrIncludes = @($filterInclude.split(',')); 
 $arrExcludes = @($filterExclude.split(',')); 

 for ($i = 0; $i -lt $arrDir.count; $i++) {
  $arrDir[$i] = $arrDir[$i] -replace(" ","");
 }
 for ($i = 0; $i -lt $arrIncludes.count; $i++) {
  $arrIncludes[$i] = $arrIncludes[$i] -replace(" ","");
 }
 for ($i = 0; $i -lt $arrExcludes.count; $i++) {
  $arrExcludes[$i] = $arrExcludes[$i] -replace(" ","");
 }

 #foreach ($key in $dataSetMappings.Keys.GetEnumerator()){
  #Write-Host $dataSetMappings[$key];
  #Write-Host $dataSetMappings."$key";
 #}

 $allFiles = Get-childitem -Path $arrDir -Recurse: $recurse -Force -Include $arrIncludes -Exclude $arrExcludes | Sort-Object Name;
 
 foreach ($item in $allFiles) {
  $msg = "[SSRSPublishReport_Directory()] Publish item: {0}" -f $item.FullName;
  Write-Verbose $msg;
  
  $item | add-member -MemberType NoteProperty -Name 'TargetFolder' -Value $folderPath -force;
  $ext = [System.IO.Path]::GetExtension($item.FullName);
  $fileName = [System.IO.Path]::GetFileName($item.FullName);

  if (($ext -eq ".rdl") -or ($ext -eq ".rdlc"))
  {
   $itemResult = SSRSPublishReport -ssrsProxy $ssrsProxy -filePath $item.FullName -folderPath $item.TargetFolder -dataSourceMappings $dataSourceMappings -dataSourceFolderTarget $dataSourceFolderTarget -dataSetMappings $dataSetMappings -dataSetFolderTarget $dataSetFolderTarget -overwrite: $overwrite ;
   $msg = "[SSRSPublishReport_Directory()] Published report: {0}." -f $fileName;
   write-host $msg -f "Green";
  } elseif ($ext -eq ".rsd") {
   $itemResult = SSRSPublishDataSet -ssrsProxy $ssrsProxy -filePath $item.FullName -folderPath $item.TargetFolder -dataSourceMappings $dataSourceMappings -dataSourceFolderTarget $dataSourceFolderTarget -overwrite: $overwrite;
   $msg = "[SSRSPublishReport_Directory()] Published dataSet: {0}." -f $fileName;
   write-host $msg -f "Green";
  } elseif ($ext -eq ".rds") {
   $msg = "[SSRSPublishReport_Directory()] This method not allowed to publish the data source: {0}. Use method: SSRSPublishDataSource()." -f $fileName;
   Write-Verbose $msg;
   write-host $msg -f "Magenta";
  } else {
   if ($ext -contains ".ico", ".bmp", ".dib", ".gif", ".jpg", ".jpeg", ".jpe", ".jfif", ".png", ".tif", ".tiff") {
    $mime = "image/" + $ext.Replace(".", ""); 
   } elseif ($ext -contains ".xml") {
    $mime = "text/" + $ext.Replace(".", ""); 
   } elseif($ext -contains ".txt", ".doc", ".pdf") {
    $mime = "text/" + $ext.Replace(".", ""); 
   } else {
    $mime = "application/" + $ext.Replace(".", ""); 
   }
   $itemResult =SSRSPublishResource -ssrsProxy $ssrsProxy -filePath $item.FullName -mimeType $mime -folderPath $item.TargetFolder -overwrite;
   $msg = "[SSRSPublishReport_Directory()] Published resource: {0}." -f $fileName;
   write-host $msg -f "Green";
  }
 }	

 $msg = "[SSRSPublishReport_Directory()] End create items from directory: {0}" -f $directory;
 Write-verbose $msg;
}

<# ========================================================================== 
SSRSPublishResource
========================================================================== #>
<#
Propósito: Despliega recurso SSRS.
Empresa: 
Desarrollador: Hugo González Olaya
Fecha: 2016-10-01
Fecha actualizacion: 2016-10-01

Parametros:
-$ssrsProxy: Instancia proxy de conexion a SSRS.
-$filePath: Archivo a ser desplegado.
-$mimeType: Mime type del archivo. Ejemplo: "image/jpeg"
-$folderPath: Folder en el cual desplegar el archivo.
-$resourceName: Nombre del recurso, si esta en blanco utiliza el nombre del archivo. 
-$overwrite: Indica si debe sobrescribir el reporte en caso que exista.

Ejemplo:
$ssrsProxy = SSRSCreateWebServiceProxy -webServiceUrl "http://myreportserver/reportserver";
SSRSPublishResource -ssrsProxy $ssrsProxy -filePath "C:\MyResource.jpeg" -mimeType "image/jpeg" -folderPath "/MyApp" -overwrite -Verbose;
#>
function SSRSPublishResource
{
param
(
  [Parameter(Mandatory = $true)]
  [object]$ssrsProxy

 ,[ValidateScript({ Test-Path $_ })]
  [Parameter(Mandatory = $true)]
  [Alias('resorce')]
  [string]$filePath
 
 ,[parameter(Mandatory=$true)]
  [Alias('mime', 'type')]
  [string]$mimeType

 ,[Parameter(Mandatory = $false)]
  [Alias('folder')]
  [string]$folderPath = ''

 ,[Parameter(Mandatory = $false)]
  [Alias('name')]
  [string]$resourceName = ''

 ,[Parameter(Mandatory = $false)]
  [switch]$overwrite = $false
)
 $folderPath = SSRSNormalizeFolderName -Folder $folderPath;
 SSRSPublishFolder -ssrsProxy $ssrsProxy -Folder $folderPath;
 $ext = [System.IO.Path]::GetExtension($filePath);
 
 try
 {
  $msg = "[SSRSPublishResource()] Start creating resource: {0}" -f $filePath;
  Write-verbose $msg;

  $fileName = [System.IO.Path]::GetFileName($filePath);

  if (!($resourceName)) {
   $resourceName = $fileName;
  }

  $byteArray = Get-Content $filePath -encoding byte;
  
  $proxyNameSpace = $ssrsproxy.Gettype().Namespace;
  $propertyDefType = "$proxyNameSpace.Property"; 

  $descProp = New-Object($propertyDefType);
  $descProp.Name = 'Description';
  $descProp.Value = '';
  
  $hiddenProp = New-Object($propertyDefType);
  $hiddenProp.Name = 'Hidden';
  if ($fileName.StartsWith('_')) {
    $hiddenProp.Value = 'true';
  } else {
   $hiddenProp.Value = 'false';
  }
  
  $mimeProp = New-Object($propertyDefType);
  $mimeProp.Name = 'MimeType';
  $mimeProp.Value = $mimeType;
        
  $additionalProperties = @($descProp, $hiddenProp, $mimeProp);
                   
  $uploadWarnings = $null
  if ($ssrsProxy.Url.Contains('ReportService2005.asmx') -or $ssrsProxy.Url.Contains('ReportService2006.asmx')) {
   $itemResult = $ssrsProxy.CreateResource($resourceName, $folderPath, $overwrite, $byteArray, $mimeType, $null);
  } else {
   $itemResult = $ssrsProxy.CreateCatalogItem('Resource', $resourceName, $folderPath, $overwrite, $byteArray, $additionalProperties, [ref]$uploadWarnings) | Out-Null;
  }
  $itemResult = SSRSGetItem -ssrsProxy $ssrsProxy -itemName $resourceName -folderPath $folderPath -type "Resource";

  $msg = "[SSRSPublishResource()] End create resource: {0}" -f $filePath;
  Write-verbose $msg;

  return $itemResult;
 } catch [System.IO.IOException] {
  $msg = "[SSRSPublishResource()] Error while reading file: '{0}', Message: '{1}'. Linea: '{2}'" -f $filePath, $_.Exception.Message, $_.InvocationInfo.ScriptLineNumber;
  Write-Error $msg;
 } catch [System.Web.Services.Protocols.SoapException] {
  $msg = "[SSRSPublishResource()] Error while uploading file: '{0}', Message: '{1}'. Linea: '{2}'" -f $filePath, $_.Exception.Detail.InnerText, $_.InvocationInfo.ScriptLineNumber;
  Write-Error $msg;
 } catch {
  $msg = "[SSRSPublishResource()] Error publish resource file: '{0}', Message: '{1}'. Linea: '{2}'" -f $filePath, $_.Exception.Message, $_.InvocationInfo.ScriptLineNumber;
  Write-Error $msg;
 }
}

<# ========================================================================== 
SSRSRemoveFolder
========================================================================== #>
<#
Propósito: Remueve un folder SSRS y todos los elementos que contiene.
Empresa: 
Desarrollador: Hugo González Olaya
Fecha: 2016-10-01
Fecha actualizacion: 2016-10-01

Parametros:
-$ssrsProxy: Instancia proxy de conexion a SSRS.
-$folderName: Forder a ser removido.
-$folderPath: Folder en el cual buscar los objetos.

Ejemplo:
$ssrsProxy = SSRSCreateWebServiceProxy -webServiceUrl "http://myreportserver/reportserver";
SSRSRemoveFolder -ssrsProxy $ssrsProxy -folderName "MyFolder1/MySubFolder" -folderPath "MyFolder3" -Verbose;
SSRSRemoveFolder -ssrsProxy $ssrsProxy -folderName "MyFolder2" -Verbose;
#>
function SSRSRemoveFolder
{
param
(
  [Parameter(Mandatory = $true)]
  [object]$ssrsProxy

 ,[Parameter(Mandatory = $true)]
  [Alias('name', 'Item')]
  [string]$folderName

 ,[Parameter(Mandatory = $false)]
  [Alias('folder', 'path')]
  [string]$folderPath = '/'
)
 try
 {
  $folderPath = SSRSNormalizeFolderName -Folder $folderPath;
  $f = "$folderPath/$folderName";
  $f = SSRSNormalizeFolderName -Folder $f;

  $allitems = SSRSGetItem -ssrsProxy $ssrsProxy -itemName $folderName -folderPath $folderPath -type "Folder";

  if ($allitems) {
   Write-Verbose "[SSRSRemoveFolder()] Deleting: $f";
   $ssrsProxy.DeleteItem($f)
   Write-Verbose '[SSRSRemoveFolder()] Delete Success.'
  } else {
   Write-Verbose "[SSRSRemoveFolder()] Foder not found: $f";
  }
 } catch [System.Web.Services.Protocols.SoapException] {
  $msg = "[SSRSRemoveFolder()] Error while deleting folder: '{0}', Message: '{1}'" -f $folder, $_.Exception.Message;
  Write-Error $msg
 }	
}


<# ========================================================================== 
SSRSRemoveItem
========================================================================== #>
<#
Propósito: Remueve elemento de reporte SSRS.
Empresa: 
Desarrollador: Hugo González Olaya
Fecha: 2016-10-01
Fecha actualizacion: 2016-10-01

Parametros:
-$ssrsProxy: Instancia proxy de conexion a SSRS.
-$itemName: Nombre del elemento de reporte a ser buscado. Si no es especificado retorna todo.
-$type: Tipo de elemento a ser buscado. Ejemplo: 'ALL', 'Component', 'DataSource', 'DataSet', 'Folder', 'LinkedReport', 'Model', 'Resource', 'Report'.

Ejemplo:
$ssrsProxy = SSRSCreateWebServiceProxy -webServiceUrl "http://myreportserver/reportserver";
SSRSRemoveItem -ssrsProxy $ssrsProxy -itemName "MyReport";
SSRSRemoveItem -ssrsProxy $ssrsProxy -itemName "MyReport" -type "Report";
#>
function SSRSRemoveItem
{
[CmdletBinding(ConfirmImpact = 'High', SupportsShouldProcess = $true)]
[OutputType([String])]
param
(
  [Parameter(Mandatory = $true)]
  [object]$ssrsProxy

 ,[Parameter(Mandatory = $true)]
  [Alias('name', 'identity', 'item')]
  [string]$itemName = $null

 ,[Parameter(Mandatory = $true)]
  [ValidateSet('ALL', 'Component', 'DataSource', 'DataSet', 'Folder', 'LinkedReport', 'Model', 'Resource', 'Report')]
  [Alias('TypeName', 'ItemType')]
  [string]$type = 'ALL'
   
 ,[Parameter(Mandatory = $false)]
  [switch]$overwrite
)
 $allitems = $ssrsProxy.ListChildren('/', $true);
 if ($type -and $type -ne 'ALL') {
	$allitems = $allitems | Where-Object { $_.TypeName -like $type }
 }
 if ($itemName) {
  $allitems = $allitems | Where-Object { $_.Name -like $itemName };
 }
 
 if ($itemName -eq $null) {
  $itemResult = $allitems.Path;
 } else {
  $itemResult = $allitems | Where-Object { $_.Name -eq $itemName };
  $itemResultPath = $itemResult.Path;
 }
 
 if($overwrite) {			
  foreach ($item in $itemResultPath) {
   Write-Verbose "[SSRSRemoveItem()] Removing $item";
   $ssrsProxy.deleteitem($item);
  }
 } elseIf ($psCmdlet.shouldProcess($itemResultpath, 'Remove SSRS Item')) {
  foreach ($item in $itemResultPath) {
   Write-Verbose "[SSRSRemoveItem()] Removing $item";
   $ssrsProxy.deleteitem($item)
  }
 }
}

<# ========================================================================== 
SSRSSetDataset
========================================================================== #>
<#
Propósito: Asocia un dataset a un reporte SSRS.
Empresa: 
Desarrollador: Hugo González Olaya
Fecha: 2018-07-15
Fecha actualizacion: 2018-07-15

Parametros:
-$ssrsProxy: Instancia proxy de conexion a SSRS.
-$reportPath: Ruta en SSRS del reporte.
-$dataSetName: Nombre del data set del reporte a ser establecido. Ejemplo: MyDataSetReport.
-$dataSetMappings: Arreglo con mapeos de datasets [NombreEnReporte, NombreDestino]
-$dataSetFolderTarget: Folder del data set destino en SSRS. Ejemplo /MyApp/DataSets.

Ejemplo:
$ssrsProxy = SSRSCreateWebServiceProxy -webServiceUrl "http://myreportserver/reportserver";
$dataSetMappings = @{};
$dataSetMappings.Add("DataSet1", "SharDataSet1");
$dataSetMappings.Add("DataSet2", "SharDataSet2");
SSRSSetDataset -ssrsProxy $ssrsProxy -reportPath "/MyApp/MyReport" -dataSetName "DataSet1" -dataSetMappings $dataSetMappings -dataSetFolderTarget "/MyApp/DataSets" -Verbose;
#>
function SSRSSetDataset (
  [Parameter(Mandatory = $true)]
  [object]$ssrsProxy

 ,[Parameter(Mandatory = $true)]
  [string]$reportPath
  
 ,[Parameter(Mandatory = $true)]
  [string]$dataSetName

 ,[Parameter(Mandatory = $false, ValueFromPipeline = $true)]
  [array]$dataSetMappings
  
 ,[Parameter(Mandatory = $true)]
  [string]$dataSetFolderTarget
  )
{
 try 
 {
  $msg = "[SSRSSetDataset()] Start setting dataset: {0}" -f $dataSetName;
  Write-verbose $msg;

  $dataSets = @();
  $dataSets += $ssrsProxy.GetItemReferences($reportPath, 'DataSet');
  $dataSetReference = $dataSets | Where-Object { $_.Name -eq $dataSetName } | Select-Object -first 1;
  if (!($dataSetReference)) {
   $msg = "[SSRSSetDataset()] Item: {0}, dataset not found: {1}" -f $reportPath, $dataSetName; 
   Write-Verbose $msg;
   write-host $msg -f "Magenta";
   return;
  }
  
  if ($dataSetMappings) {
   #$dataSetNameTarget = $dataSetMappings[$dataSetName];
   $dataSetNameTarget = $dataSetMappings."$dataSetName";
  }
  if(!($dataSetNameTarget)) {
   $dataSetNameTarget = $dataSetName;
  }

  $msg = "[SSRSSetDataset()] Setting report's dataset: {0}. Dataset source: {1}. Dataset target: {2}/{3}" -f $reportPath, $dataSetName, $dataSetFolderTarget, $dataSetNameTarget;
  Write-verbose $msg;

  $dataSetFolderTarget = SSRSNormalizeFolderName -Folder $dataSetFolderTarget;
  $ds = (SSRSGetItem -ssrsProxy $ssrsProxy -itemName $dataSetNameTarget -folderPath $dataSetFolderTarget -type "DataSet" -recurse) | Select-Object -first 1;
  if (!($ds)) {
   $msg = "[SSRSSetDataset()] Dataset not found: {0}/{1}" -f $dataSetFolderTarget, $dataSetNameTarget; 
   Write-Verbose $msg;
   write-host $msg -f "Magenta";
   return;
  }

  $proxyNamespace = $dataSetReference.GetType().Namespace;
  $dataSetReference = New-Object "$($proxyNamespace).ItemReference";
  $dataSetReference.Name = $dataSetName;
  $dataSetReference.Reference = $ds.Path;
  $ssrsProxy.SetItemReferences($reportPath, @($dataSetReference));
  
  $msg = "[SSRSSetDataset()] End set dataset: {0}" -f $dataSetName;
  Write-verbose $msg;
 } catch {
  $msg = "[SSRSSetDataset()] Error set data set: '{0}' from report: '{1}', to dataset target: {2}/{3}, Message: '{4}'. Linea: '{5}'" -f $dataSetName, $reportPath, $dataSetFolderTarget, $dataSetNameTarget, $_.Exception.Message, $_.InvocationInfo.ScriptLineNumber;
  Write-Error $msg;
 } 
}


<# ========================================================================== 
SSRSSetDatasource
========================================================================== #>
<#
Propósito: Asocia un data source a un reporte SSRS.
Empresa: 
Desarrollador: Hugo González Olaya
Fecha: 2016-10-01
Fecha actualizacion: 2016-10-01

Parametros:
-$ssrsProxy: Instancia proxy de conexion a SSRS.
-$reportPath: Ruta en SSRS del reporte.
-$dataSourceName: Nombre del data source del reporte a ser establecido. Ejemplo: MyDataSourceReport.
-$dataSourceNameTarget: Nombre del data source destino en SSRS. Ejemplo MyDataSourceTarget.
-$dataSourceFolderTarget: Folder del data source destino en SSRS. Ejemplo /MyApp/DataSources.

Ejemplo:
$ssrsProxy = SSRSCreateWebServiceProxy -webServiceUrl "http://myreportserver/reportserver";
SSRSSetDatasource -ssrsProxy $ssrsProxy -reportPath "/MyApp/MyReport" -dataSourceName "MyDataSourceReport" -dataSourceNameTarget "MyDataSourceTarget" -dataSourceFolderTarget "/MyApp/DataSources" -Verbose;
#>
function SSRSSetDatasource (
  [Parameter(Mandatory = $true)]
  [object]$ssrsProxy

 ,[Parameter(Mandatory = $true)]
  [string]$reportPath
  
 ,[Parameter(Mandatory = $true)]
  [string]$dataSourceName
  
 ,[Parameter(Mandatory = $true)]
  [string]$dataSourceNameTarget

 ,[Parameter(Mandatory = $true)]
  [string]$dataSourceFolderTarget
  )
{
 try 
 {
  $msg = "[SSRSSetDatasource()] Start setting datasource: {0}" -f $dataSourceName;
  Write-verbose $msg;

  $objDataSource = $ssrsProxy.GetItemDataSources($reportPath);
  $dataSourceReference = $objDataSource | Where-Object { $_.Name -eq $dataSourceName } | Select-Object -first 1;
  if (!($dataSourceReference)) {
   $msg = "[SSRSSetDatasource()] Item: {0} not found data source: {1}" -f $reportPath, $dataSourceName; 
   Write-Verbose $msg;
   write-host $msg -f "Magenta";
   return;
  }

  $dataSourceFolderTarget = SSRSNormalizeFolderName -Folder $dataSourceFolderTarget;
  $ds = (SSRSGetItem -ssrsProxy $ssrsProxy -itemName $dataSourceNameTarget -folderPath $dataSourceFolderTarget -type "DataSource") | Select-Object -first 1;
  if (!($ds)) {
   $msg = "[SSRSSetDatasource()] Data source not found: {0}/{1}" -f $dataSourceFolderTarget, $dataSourceName; 
   Write-Verbose $msg;
   write-host $msg -f "Magenta";
   return;
  }
    
  $proxyNamespace = $dataSourceReference.GetType().Namespace;
  $dataSourceReference = New-Object ("$proxyNamespace.DataSource");
  $dataSourceReference.Name = $dataSourceName;
  $dataSourceReference.Item = New-Object ("$proxyNamespace.DataSourceReference");
  $dataSourceReference.Item.Reference = $ds.Path;
  $dataSourceReference.item = $dataSourceReference.Item
  $ssrsProxy.SetItemDataSources($reportPath, $dataSourceReference);

  $msg = "[SSRSSetDatasource()] End set datasource: {0}" -f $dataSourceName;
  Write-verbose $msg;
 } catch {
  $msg = "[SSRSSetDatasource()] Error set data source: '{0}' from report: '{1}', to data source target: {2}/{3}, Message: '{4}'. Linea: '{5}'" -f $dataSourceName, $reportPath, $dataSourceFolderTarget, $dataSourceNameTarget, $_.Exception.Message, $_.InvocationInfo.ScriptLineNumber;
  Write-Error $msg;
 } 
}
