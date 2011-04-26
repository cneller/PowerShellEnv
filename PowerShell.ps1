$NTIdentity = ([Security.Principal.WindowsIdentity]::GetCurrent())
$NTPrincipal = (new-object Security.Principal.WindowsPrincipal $NTIdentity)
$IsAdmin = ($NTPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))	

$global:shortenPathLength = 3

New-PSDrive -Name Modules -PSProvider FileSystem -root $ProfileDir/Modules | Out-Null

$promptCalls = new-object System.Collections.ArrayList

function prompt {
    $chost = [ConsoleColor]::Green
    $cdelim = [ConsoleColor]::DarkCyan
    $cloc = [ConsoleColor]::Cyan

    write-host ' '

    write-host ([Environment]::MachineName) -n -f $chost
    write-host ' {' -n -f $cdelim
    write-host (shorten-path (pwd).Path) -n -f $cloc
    write-host '} ' -n -f $cdelim

    $promptCalls | foreach { $_.Invoke() }

    write-host "�" -n -f $cloc
    ' '

    $host.UI.RawUI.ForegroundColor = [ConsoleColor]::White
} 

function shorten-path([string] $path = $pwd) {
   $loc = $path.Replace($HOME, '~')
   # remove prefix for UNC paths
   $loc = $loc -replace '^[^:]+::', ''
   # make path shorter like tabs in Vim,
   # handle paths starting with \\ and . correctly
   return ($loc -replace "\\(\.?)([^\\]{$shortenPathLength})[^\\]*(?=\\)",'\$1$2')
} 

function Add-CallToPrompt([scriptblock] $call) {
    [void]$promptCalls.Add($call)
}

function Add-ToPath {
    $args | foreach {
        # the double foreach's are to handle calls like 'add-topath @(path1, path2) path3
        $_ | foreach { $env:Path += ";$(Resolve-Path $_)" }
    }
}

Import-Module Pscx -DisableNameChecking
$Pscx:Preferences['TextEditor'] = "gvim.exe"
$Pscx:Preferences['FileSizeInUnits'] = $true

$vcargs = ?: {$Pscx:Is64BitProcess} {'amd64'} {''}
$VS100VCVarsBatchFile = "${env:VS100COMNTOOLS}..\..\VC\vcvarsall.bat"
Invoke-BatchFile $VS100VCVarsBatchFile $vcargs

# override the PSCX cmdlets with the default cmdlet
Set-Alias Select-Xml Microsoft.PowerShell.Utility\Select-Xml

Push-Location $ProfileDir
# Bring in env-specific functionality (i.e. work-specific dev stuff, etc.)
    If (Test-Path ./EnvSpecificProfile.ps1) { . ./EnvSpecificProfile.ps1 }

# Bring in prompt and other UI niceties
    . ./EyeCandy.ps1

    Update-TypeData ./TypeData/System.Type.ps1xml
    Update-TypeData ./TypeData/System.Diagnostics.Process.ps1xml

    . ./lib/aliases.ps1
    . ./lib/utils.ps1
Pop-Location
