﻿$ErrorActionPreference = 'Stop'

$toolsDir = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"
$FolderOfPackage = Split-Path -Parent $toolsDir

$packageArgs = @{
   packageName   = $env:ChocolateyPackageName
   unzipLocation = "$FolderOfPackage\v$env:ChocolateyPackageVersion"
   url           = 'http://www.angusj.com/resourcehacker/resource_hacker.zip'
   checksum      = 'D158BEBC2993CF6BEBF2C23A93572A68544C2BA5AE056538F70A58075C9392D6'
   checksumType  = 'sha256'
}

Install-ChocolateyZipPackage @packageArgs
