# installs listed modules

function ensurePsGetExists {
    if ((Get-Module PsGet) -eq $null) {
        # install psget
        (new-object Net.WebClient).DownloadString("http://psget.net/GetPsGet.ps1") | iex
    }
}

function installModule($moduleName) {
    if ((Get-Module $moduleName) -eq $null) {
        ensurePsGetExists

        Install-Module $moduleName
    }
}

installModule pscx
installModule Find-String
installModule psake
