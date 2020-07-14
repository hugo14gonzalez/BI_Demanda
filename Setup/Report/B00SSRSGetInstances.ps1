clear-host;
write-host "==========================================================================" -f "Cyan"
write-host "POWERSHELL QUERY INSTANCES SSRS" -f "Cyan"
write-host "==========================================================================" -f "Cyan"  
if ($PSScriptRoot -eq $null) {
 $pathMain = split-path -parent $MyInvocation.MyCommand.Definition;
} else {
 $pathMain = $PSScriptRoot;
}
$modulePath = [System.IO.Path]::Combine($pathMain, "MainDeploymentRS.psm1"); # ruta actual de este script
Import-Module $modulePath;

$computerSSRS = $env:computername;
$computerSSRS = $computerSSRS + "\SSRS";

write-host "Ingrese el nombre del servidor SQL Reporting Services (Presione 'Enter' para utilizar el valor por defecto): " -f "Cyan"
write-host $computerSSRS": " -NoNewLine -f "Cyan"
$tmp = Read-Host 
if ($tmp -ne "") { 
 $computerSSRS = $tmp; 
}
write-host;

$rsconfig = SSRSGetInstances $computerSSRS "";
if ($rsconfig -ne $null) {
 
 $rsconfig;

 $i = 0;
 foreach($item in $rsconfig) {
  if($item.DatabaseServerName.Contains("\")) {
    $computer = $item.DatabaseServerName.Split("\")[0]
    $SSRSInstance = $item.DatabaseServerName.Split("\")[1]
    $urlReportManager = "http://$computer/Reports_$SSRSInstance";
    $urlReportService = "http://$computer/Reportserver_$SSRSInstance";
    $isDefaultInstance = $false;
  } else {
    $computer = $item.DatabaseServerName
    $SSRSInstance = "MSSQLSERVER"
    $urlReportManager = "http://$computer/Reports";
    $urlReportService = "http://$computer/Reportserver";
    $isDefaultInstance = $true;
  }
  $isInitialized = $item.IsInitialized

  write-host "Computer:            " $computer -f "Cyan";
  write-host "Instance:            " $SSRSInstance -f "Cyan";
  write-host "Is default instance: " $isDefaultInstance -f "Cyan";
  write-host "URL Report manager:  " $urlReportManager -f "Cyan";
  write-host "URL Webservice:      " $urlReportService -f "Cyan";
  write-host "Is initialized:      " $isInitialized -f "Cyan";
  write-host "" -f "Cyan";
  $i++;
 }
}

#$ipV4 = Test-Connection -ComputerName (hostname) -Count 1  | Select -ExpandProperty IPV4Address 
#$ipV4 = Test-Connection -ComputerName ($computerSSRS) -Count 1  | Select -ExpandProperty IPV4Address 
#write-host "IP address:          " $ipV4.IPAddressToString -f "Cyan";
#$user = $(Get-WMIObject -class Win32_ComputerSystem | select username).username | split-path -Leaf;

write-host ("");
write-host "Process finish. Removing modules" -f "Cyan";
Remove-Module -name "MainDeploymentRS" -Force;

write-host ("");
Read-Host -Prompt "Press Enter to exit PS ...";

exit;
