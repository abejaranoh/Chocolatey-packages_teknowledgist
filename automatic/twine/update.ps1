import-module chocolatey-au

function global:au_GetLatest {
   $Repo = 'https://github.com/klembot/twinejs'
   $Release = Get-LatestReleaseOnGitHub -URL $Repo

   $version = $Release.Tag.trim('v.')
   $Asset = $Release.Assets | Where-Object {$_.FileName -match '\.exe$'} | Select-Object -First 1 

   return @{ 
      Version = $version
      URL32   = $Asset.DownloadURL
   }
}


function global:au_SearchReplace {
   @{
      "legal\VERIFICATION.md" = @{
            "(^- Version *:).*" = "`${1} $($Latest.Version)"
            "(^- URL *:).*"     = "`${1} $($Latest.URL32)"
            "(^- SHA256 *:).*" = "`${1} $($Latest.Checksum32)"
      }
   }
}

function global:au_BeforeUpdate() { 
   Write-host "Downloading Twine v$($Latest.Version) installer."
   Get-RemoteFiles -Purge -nosuffix
}

update -ChecksumFor none