import-module au

$Release = 'http://www.angusj.com/resourcehacker/'

function global:au_GetLatest {
   $download_page = Invoke-WebRequest -Uri $Release

   $VersionText = $download_page.AllElements |
                        Where-Object {$_.innertext -match '^version'} | 
                        Select-Object -First 1 -ExpandProperty innertext
   $Version = $VersionText -replace '.* ([0-9.]+).*','$1'

   $url = 'http://www.angusj.com/resourcehacker/resource_hacker.zip'

   return @{ Version = $Version; URL = $url }
}


function global:au_SearchReplace {
   @{
      "tools\chocolateyInstall.ps1" = @{
         "(^\s*Checksum\s*=\s*)('.*')" = "`$1'$($Latest.Checksum32)'"
      }
   }
}

Update-Package