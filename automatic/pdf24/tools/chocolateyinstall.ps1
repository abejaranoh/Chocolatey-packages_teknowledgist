﻿$ErrorActionPreference = 'Stop'

$toolsDir   = Split-Path -parent $MyInvocation.MyCommand.Definition
$Installer = (Get-ChildItem $toolsDir -Filter '*.msi').FullName

$InstallArgs = @{
   packageName   = $env:ChocolateyPackageName
   softwareName  = "$env:ChocolateyPackageName*"
   fileType      = 'MSI' 
   url           = 'https://download.pdf24.org/pdf24-creator-11.12.1-x86.msi'
   checksum      = 'E8A624DEAC0019FE08DBD0B8DAFE2D9727ACFCB0950E8A7107BCA0D6224142C5'
   url64bit      = 'https://download.pdf24.org/pdf24-creator-11.12.1-x64.msi'
   checksum64    = 'BD29D52E9E9C2E2A3B1C01BACCC30C0D86E8E8CF4F6C156A50EAAFE7BFDCA1F8'
   checksumType  = 'sha256' #default is md5, can also be sha1, sha256 or sha512
   silentArgs    = "/qn /norestart /l*v `"$($env:TEMP)\$($env:chocolateyPackageName).$($env:chocolateyPackageVersion).MsiInstall.log`""
   validExitCodes= @(0, 3010, 1641)
}

# The PDF24 Service depends on the Print Spooler service so make it is up and running 
#    (Stolen from cutepdf package and thanks to bcurran3.)
try {
   $serviceName = 'Spooler'
   $spoolerService = Get-WmiObject -Class Win32_Service -Property StartMode,State -Filter "Name='$serviceName'"
   if ($spoolerService -eq $null) { 
      Write-Warning "The Print Spooler service must be running for PDF24 to install."
      Throw "Service $serviceName was not found" 
   }
   Write-Warning "Print Spooler service state: $($spoolerService.StartMode) / $($spoolerService.State)"
   if ($spoolerService.StartMode -ne 'Auto' -or $spoolerService.State -ne 'Running') {
      Set-Service $serviceName -StartupType Automatic -Status Running
      Write-Warning 'Print Spooler service now set to: Auto / Running'
   }
} catch {
   Throw "Unexpected error while checking Print Spooler service: $($_.Exception.Message)"
}

$pp = Get-PackageParameters

if ($pp['Icon']) { 
   Write-Host 'You have opted for the Desktop Icon.' -ForegroundColor Cyan
   $I = ''
} else { $I = ' DESKTOPICONS=No' } 

if ($pp['Fax']) { 
   Write-Host 'You have opted to include the FaxPrinter.' -ForegroundColor Cyan
   $F = ''
} else { $F = ' FAXPRINTER=No' } 

if ($pp['Basic']) {
   Write-Host 'You requested to configure the PDF Printer feature only.' -ForegroundColor Cyan
   $RegPath = 'HKLM:\SOFTWARE'
   if (-not (Test-Path "$RegPath\PDF24")) {
      $null = New-Item -Path $RegPath -Name 'PDF24' -Force
   }
   $Properties = @(
      'NoTrayIcon',
      'NoOnlineConverter',
      'NoShellContextMenuExtension',
      'NoOnlinePdfTools',
      'NoCloudPrint',
      'NoEmbeddedBrowser',
      'NoPDF24MailInterface',
      'NoScreenCapture',
      'NoFax',
      'NoFaxProfile',
      'NoMail'
   )
   ForEach ($item in $Properties) {
      $null = New-ItemProperty -Path "$RegPath\PDF24" -Name $item -PropertyType DWORD -Value 1 -Force
   }
}

$InstallArgs.silentArgs = "$($InstallArgs.silentArgs)$I$F"

Install-ChocolateyPackage @InstallArgs

