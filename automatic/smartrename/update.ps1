import-module chocolatey-au

function global:au_GetLatest {
   $Repo = 'https://github.com/chrdavis/SmartRename'
   $Release = Get-LatestReleaseOnGitHub -URL $Repo

   $version = $Release.Tag.trim('v.')
   $URL32 = $Release.Assets | Where-Object {$_.FileName -match '32\.msi$'} | Select-Object -First 1 -ExpandProperty DownloadURL
   $URL64 = $Release.Assets | Where-Object {$_.FileName -match '64\.msi$'} | Select-Object -First 1 -ExpandProperty DownloadURL

   return @{ 
      Version = $version
      URL32   = $URL32
      URL64   = $URL64
   }
}


function global:au_SearchReplace {
   @{
      "legal\VERIFICATION.md" = @{
            "(^- Version:).*"     = "`${1} $($Latest.Version)"
            "(^- x86 URL:).*"     = "`${1} $($Latest.URL32)"
            "(^- x86 SHA256+:).*" = "`${1} $($Latest.Checksum32)"
            "(^- x64 URL:).*"     = "`${1} $($Latest.URL64)"
            "(^- x64 SHA256+:).*" = "`${1} $($Latest.Checksum64)"
      }
   }
}

function global:au_BeforeUpdate() { 
   Write-host "Downloading SmartRename $($Latest.Version) installer files"
   Get-RemoteFiles -Purge -nosuffix
}

update -ChecksumFor none
