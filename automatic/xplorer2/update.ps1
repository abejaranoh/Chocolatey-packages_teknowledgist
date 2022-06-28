import-module au

function global:au_GetLatest {
   $MainPage = 'https://www.zabkat.com'
   $PageContent = Invoke-WebRequest -Uri "$MainPage/alldown.htm"
   $section = $PageContent.RawContent -split 'hredge' | Where-Object {$_ -match 'lite'}
   $line = $section.split('<>') | Where-Object {$_ -match 'Latest version'}

   $Version = $line -replace '[^0-9.]',''
   
   $null = $section.split('<>') | ? {$_ -match 'href="(.*)"'} |select -first 1
   $url32 = "http://zabkat.com/dl/$($Matches[1])"

   return @{ 
      Version    = $Version
      ManualURL  = $url32
   }
}


function global:au_SearchReplace {
    @{
        "tools\chocolateyInstall.ps1" = @{
            "(^[$]URL\s*=\s*)('.*')"        = "`$1'$($Latest.URL32)'"
            "(^[$]Checksum\s*=\s*)('.*')"   = "`$1'$($Latest.Checksum32)'"
        }
    }
}

function global:au_BeforeUpdate() { 
   Write-host "Downloading Xplorer2 Lite $($Latest.Version) installer file"
   Write-warning "The zabcat.com site won't allow proper download.  " +
                  "It must be manually downloaded from:`n " +
                  $($Latest.ManualURL32)
}

update -ChecksumFor none
