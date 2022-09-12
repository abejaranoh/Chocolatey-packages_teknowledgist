﻿$ErrorActionPreference = 'Stop'

$toolsDir   = Split-Path -parent $MyInvocation.MyCommand.Definition
$FolderOfPackage = Split-Path -Parent $toolsDir
$InstallerPath = (Get-ChildItem -Path $toolsDir -filter '*.exe' |
                        Sort-Object lastwritetime | Select-Object -Last 1).FullName

if (-not $InstallerPath) {
   $ZipPath = (Get-ChildItem -Path $toolsDir -filter '*.zip').FullName
   Get-ChocolateyUnzip -FileFullPath $ZipPath -Destination $toolsDir
   $InstallerPath = (Get-ChildItem -Path $toolsDir -filter '*.exe').FullName
}

$InstallArgs = @{
   packageName    = $env:ChocolateyPackageName
   FileType       = 'exe'
   File           = "$InstallerPath"
   silentArgs     = "/silent /Extract /dir=`"$FolderOfPackage`""
   validExitCodes = @(0)
}

Install-ChocolateyInstallPackage @InstallArgs
Remove-Item $InstallerPath -ea 0 -force

Get-ChildItem -Path $FolderOfPackage -filter 'setup.exe' -Recurse | 
   ForEach-Object { $null = Remove-Item $_.FullName -Force }


