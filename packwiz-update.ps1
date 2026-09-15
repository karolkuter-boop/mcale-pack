param([switch]$ResolveOnly)
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$PackRepo = 'karolkuter-boop/mcale-pack'
$PackBranch = 'hospital'

function Resolve-PackCommit {
    param([string]$Repo, [string]$Branch, [switch]$SkipApi)
    $headers = @{'User-Agent'='NeoFFTV-Prism'; 'Cache-Control'='no-cache'}
    for ($attempt=0; $attempt -lt 2; $attempt++) {
        if (-not $SkipApi) {
            try {
                $ref = Invoke-RestMethod -UseBasicParsing -TimeoutSec 12 -Headers $headers -Uri "https://api.github.com/repos/$Repo/git/ref/heads/$Branch"
                if ($ref.ref -ne "refs/heads/$Branch" -or $ref.object.type -ne 'commit' -or $ref.object.sha -notmatch '^[0-9a-f]{40}$') { throw 'Invalid branch reference' }
                return [string]$ref.object.sha
            } catch { [Console]::Error.WriteLine('[NeoFFTV] GitHub API: '+$_.Exception.Message) }
        }
        # Git smart HTTP advertises branch tips without the REST API or a local Git installation.
        try {
            $response = Invoke-WebRequest -UseBasicParsing -TimeoutSec 15 -Headers $headers -Uri "https://github.com/$Repo.git/info/refs?service=git-upload-pack"
            $body = if ($response.Content -is [byte[]]) { [Text.Encoding]::UTF8.GetString($response.Content) } else { [string]$response.Content }
            $matches = [regex]::Matches($body, '(?m)^[0-9a-f]{4}([0-9a-f]{40}) refs/heads/'+[regex]::Escape($Branch)+'(?:\x00[^\n]*)?\r?$')
            if ($matches.Count -ne 1) { throw 'Git response does not contain one exact branch reference' }
            [Console]::Error.WriteLine('[NeoFFTV] Wersja potwierdzona przez zapasowe polaczenie GitHub Git.')
            return $matches[0].Groups[1].Value
        } catch { [Console]::Error.WriteLine('[NeoFFTV] GitHub Git: '+$_.Exception.Message) }
        if ($attempt -eq 0) { Start-Sleep -Seconds 2 }
    }
    throw 'Nie mozna potwierdzic aktualnej wersji paczki. Gra nie zostala uruchomiona.'
}

function Find-PackJava {
    $candidates = @()
    if ($env:INST_JAVA) { $candidates += $env:INST_JAVA }
    foreach ($root in @((Join-Path $PSScriptRoot '../../..'),(Join-Path $env:APPDATA 'PrismLauncher'),(Join-Path $env:LOCALAPPDATA 'PrismLauncher'))) {
        $candidates += Get-ChildItem -Path (Join-Path $root 'java/*/bin/java.exe') -ErrorAction SilentlyContinue | ForEach-Object FullName
    }
    if ($env:JAVA_HOME) { $candidates += Join-Path $env:JAVA_HOME 'bin/java.exe' }
    $onPath = Get-Command java.exe -ErrorAction SilentlyContinue
    if ($onPath) { $candidates += $onPath.Source }
    foreach ($candidate in $candidates) {
        $console = $candidate -replace 'javaw\.exe$','java.exe'
        if (Test-Path -LiteralPath $console -PathType Leaf) { return $console }
    }
    throw 'Brak Javy. W Prism wlacz automatyczne pobieranie Javy 21.'
}

if ($MyInvocation.InvocationName -eq '.') { return }
try {
    $ref = Resolve-PackCommit -Repo $PackRepo -Branch $PackBranch
    if ($ResolveOnly) { Write-Output $ref; exit 0 }
    $java = Find-PackJava
    $bootstrap = Join-Path $PSScriptRoot 'packwiz-installer-bootstrap.jar'
    if (-not (Test-Path -LiteralPath $bootstrap)) { throw 'Brak packwiz-installer-bootstrap.jar. Zaimportuj aktualny ZIP instancji.' }
    Write-Host "[NeoFFTV] Kanal hospital (szpitale + pizza), commit $ref"
    Push-Location $PSScriptRoot
    try {
        & $java '-Dsun.net.client.defaultConnectTimeout=30000' '-Dsun.net.client.defaultReadTimeout=60000' '-jar' $bootstrap '-g' '--side' 'client' "https://raw.githubusercontent.com/$PackRepo/$ref/pack.toml"
        if ($LASTEXITCODE -ne 0) { throw "Aktualizacja Packwiz nie powiodla sie, kod $LASTEXITCODE." }
    } finally { Pop-Location }
    # Run only after Packwiz finishes: these files may just have been updated.
    # Xaero's own mutable files are merged, never overwritten with pack templates.
    & (Join-Path $PSScriptRoot 'sync-waypoints.ps1') -MinecraftRoot $PSScriptRoot
    [IO.File]::WriteAllText((Join-Path $PSScriptRoot '.packwiz-last-success'),$ref+"`r`n")
    Write-Host '[NeoFFTV] Paczka aktualna. Uruchamiam Minecraft.'
    exit 0
} catch {
    [Console]::Error.WriteLine('[NeoFFTV] BLAD: '+$_.Exception.Message)
    exit 1
}
