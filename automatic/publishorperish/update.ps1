import-module au

function global:au_GetLatest {
   $DownURL = 'https://harzing.com/resources/publish-or-perish/windows'
   $PageCode = Invoke-WebRequest -Uri $DownURL

   $vline = $PageCode.AllElements | 
                  Where-Object {$_.tagname -eq 'p' -and $_.innertext -match '^version'} | 
                  Select-Object -first 1 -ExpandProperty innertext

   $Version = $vline.split() | Where-Object {$_ -match '^[0-9.]+' -and $_ -match '\.'} |
                  Select-Object -First 1
   
   $URL32 = 'https://harzing.com/download/PoP8Setup.exe'

   return @{ 
            Version  = $Version
            URL32    = $URL32
           }
}

function global:au_SearchReplace {
   @{
      "tools\chocolateyInstall.ps1" = @{
         "(^   url\s*=\s*)('.*')"        = "`$1'$($Latest.URL32)'"
         "(^   Checksum\s*=\s*)('.*')"   = "`$1'$($Latest.Checksum32)'"
      }
   }
}

Update-Package -ChecksumFor all
