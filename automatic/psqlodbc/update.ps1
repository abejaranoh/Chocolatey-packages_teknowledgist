import-module chocolatey-au

function global:au_GetLatest {
   $ReleasesURL = 'https://www.postgresql.org/ftp/odbc/releases/'
   $ReleasesPage = Invoke-WebRequest -Uri $ReleasesURL

   $LatestDIR = $ReleasesPage.links |
               Where-Object {$_.innertext -match '-[0-9_]+$'} |
               Select-Object -ExpandProperty href -first 1

   $LatestPage = Invoke-WebRequest -Uri "$ReleasesURL/$LatestDIR"
   $URLs = $LatestPage.links | 
               Where-Object {$_.innertext -match '\.msi$'} | 
               Select-Object -ExpandProperty href

   $url64 = $URLs | Where-Object {$_ -match '_x64'}
   $url32 = $URLs | Where-Object {$_ -match '_x86'}

   $Version = $url64 -replace '.*/REL-([0-9_]+)/.*','$1' -replace '_','.'

   return @{ 
            Version  = $Version
            URL64    = $url64
            URL32    = $url32
           }
}

function global:au_SearchReplace {
   @{
      "tools\VERIFICATION.txt" = @{
         "(^Version\s+:).*"      = "`${1} $($Latest.Version)"
         "(^32-bit URL\s+:).*"      = "`${1} $($Latest.URL32)"
         "(^32-bit Checksum\s+:).*" = "`${1} $($Latest.Checksum32)"
         "(^64-bit URL\s+:).*"      = "`${1} $($Latest.URL64)"
         "(^64-bit Checksum\s+:).*" = "`${1} $($Latest.Checksum64)"
      }
   }
}

function global:au_BeforeUpdate() { 
   Write-host "Downloading psqlodbc $($Latest.AppVersion) zip files"
   Get-RemoteFiles -Purge -NoSuffix
}

Update-Package -ChecksumFor none
