param(
    [string]$MinecraftRoot = $PSScriptRoot,
    [string]$Manifest = (Join-Path $PSScriptRoot 'neofftv-waypoints.json'),
    [string[]]$ServerFolders = @()
)
$ErrorActionPreference = 'Stop'
$utf8 = New-Object Text.UTF8Encoding($false)
$data = Get-Content -LiteralPath $Manifest -Raw -Encoding UTF8 | ConvertFrom-Json
if ($data.schema -ne 1) { throw 'Unsupported waypoint manifest' }
if (!$ServerFolders.Count) { $ServerFolders = @($data.servers) }
$MinecraftRoot = [IO.Path]::GetFullPath($MinecraftRoot)
$backupRoot = Join-Path $MinecraftRoot ('neofftv-backups/waypoints/'+(Get-Date -Format 'yyyyMMdd-HHmmss-fff'))
$changes = 0
$migrationPath = Join-Path $MinecraftRoot '.neofftv-waypoint-migrations.json'
$migrated = @()
if (Test-Path -LiteralPath $migrationPath) { $migrated = Get-Content -LiteralPath $migrationPath -Raw -Encoding UTF8 | ConvertFrom-Json }
$newMigrations = New-Object 'System.Collections.Generic.List[string]'
foreach ($entry in $migrated) { $newMigrations.Add([string]$entry) }

function Read-Lines([string]$Path) {
    if (Test-Path -LiteralPath $Path) { return [IO.File]::ReadAllLines($Path, [Text.Encoding]::UTF8) }
    return @()
}

function Write-Changed([string]$Path, [string[]]$Lines) {
    $text = ($Lines -join "`n") + "`n"
    if ((Test-Path -LiteralPath $Path) -and [IO.File]::ReadAllText($Path) -ceq $text) { return }
    $parent = Split-Path -Parent $Path
    [IO.Directory]::CreateDirectory($parent) | Out-Null
    if (Test-Path -LiteralPath $Path) {
        $relative = $Path.Substring($MinecraftRoot.Length).TrimStart('\','/')
        $backup = Join-Path $backupRoot $relative
        [IO.Directory]::CreateDirectory((Split-Path -Parent $backup)) | Out-Null
        [IO.File]::Copy($Path, $backup, $false)
    }
    $temp = $Path + '.neofftv-tmp'
    [IO.File]::WriteAllText($temp, $text, $utf8)
    if (Test-Path -LiteralPath $Path) { [IO.File]::Replace($temp,$Path,($Path+'.neofftv-old')); Remove-Item -LiteralPath ($Path+'.neofftv-old') }
    else { [IO.File]::Move($temp,$Path) }
    $script:changes++
}

foreach ($server in $ServerFolders) {
    if ($server -notmatch '^Multiplayer_[^/\\]+$') { throw 'Invalid server folder' }
    $root = Join-Path $MinecraftRoot ('xaero/minimap/'+$server)
    $configPath = Join-Path $root 'config.txt'
    $config = @(Read-Lines $configPath)
    # A fixed world ID is necessary: the server's Xaero numeric ID overrides
    # defaultMultiworldId otherwise. Dimensions still remain strictly separate.
    $settings = [ordered]@{
        usingMultiworldDetection='false'; ignoreServerLevelId='true';
        defaultMultiworldId=[string]$data.worldId; teleportationEnabled='true'
    }
    $config = @($config | Where-Object { !$settings.Contains(($_ -split ':',2)[0]) })
    foreach ($key in $settings.Keys) { $config += $key+':'+$settings[$key] }
    foreach ($world in $data.worlds) {
        if ($world.folder -notmatch '^dim%[a-zA-Z0-9%$-]+$') { throw 'Invalid dimension folder' }
        $type = 'dimensionType:'+($world.dimension -replace ':','$')+':minecraft$overworld'
        if (!($config | Where-Object { $_.StartsWith('dimensionType:'+($world.dimension -replace ':','$')+':') })) { $config += $type }
        $folder = Join-Path $root $world.folder
        $target = Join-Path $folder ($data.worldId+'_'+$data.worldName+'.txt')
        $files = @(Get-ChildItem -LiteralPath $folder -Filter '*.txt' -File -ErrorAction SilentlyContinue | Where-Object { $_.BaseName -eq 'waypoints' -or $_.BaseName.Contains('_') })
        $targetLines = @(Read-Lines $target)
        $personal = New-Object 'System.Collections.Generic.List[string]'
        $sets = New-Object 'System.Collections.Generic.List[string]'
        $selected = [string]$world.set
        foreach ($line in $targetLines) {
            if ($line.StartsWith('sets:')) { $selected = ($line -split ':')[1] }
        }
        $sets.Add($selected)
        $sets.Add([string]$world.set)
        $sets.Add('gui.xaero_default')
        # Import private points from previous numeric/spawn-derived world IDs.
        # Original files stay recoverable; duplicate IDs must not shadow the new file.
        foreach ($file in $files) {
            $relativeSource = $file.FullName.Substring($MinecraftRoot.Length).TrimStart('\','/')
            if ($file.FullName -ne $target -and $migrated -ccontains $relativeSource) { continue }
            if ($file.FullName -ne $target) { $newMigrations.Add($relativeSource) }
            foreach ($line in (Read-Lines $file.FullName)) {
                if ($line.StartsWith('sets:')) {
                    foreach ($set in ($line -split ':' | Select-Object -Skip 1)) { $sets.Add($set) }
                } elseif ($line.StartsWith('waypoint:')) {
                    $fields = $line -split ':'
                    if ($fields.Count -lt 10) { $personal.Add($line); continue }
                    $owned = $fields[9] -ceq $world.set
                    if ($world.folder -eq 'dim%0' -and $fields[1] -cin @($world.rows | ForEach-Object { ($_ -split ':')[1] })) { $owned = $true }
                    # The old aquapark template is unrelated to these dimensions.
                    # Keep its original file, but don't import it into the hospital set.
                    if (@($data.obsoleteRows) -ccontains $line) { continue }
                    if (!$owned) { $personal.Add($line); $sets.Add($fields[9]) }
                } elseif ($line -and !$line.StartsWith('#')) { $personal.Add($line) }
            }
        }
        $lines = @(('sets:'+(($sets | Select-Object -Unique) -join ':')))
        $lines += '# NeoFFTV managed set; personal sets are preserved.'
        $lines += @($personal | Select-Object -Unique)
        $lines += @($world.rows)
        Write-Changed $target $lines
        # Xaero considers mw-hospitals_Szpitale and mw-hospitals_NeoFFTV the SAME
        # world; two files would make load order select stale data. Retire only
        # that exact old ID after importing its contents and backing it up.
        foreach ($file in $files) {
            if ($file.FullName -eq $target) { continue }
            if (($file.BaseName -split '_')[0] -ceq $data.worldId) {
                $relative = $file.FullName.Substring($MinecraftRoot.Length).TrimStart('\','/')
                $backup = Join-Path $backupRoot $relative
                [IO.Directory]::CreateDirectory((Split-Path -Parent $backup)) | Out-Null
                [IO.File]::Move($file.FullName, $backup)
                $script:changes++
            }
        }
    }
    $connection = 'connection:dim%0/'+$data.worldId+':dim%neofftv$pizza/'+$data.worldId
    if ($config -cnotcontains $connection) { $config += $connection }
    Write-Changed $configPath @($config | Sort-Object -Unique)
}
if ($newMigrations.Count -gt 0) { Write-Changed $migrationPath @((ConvertTo-Json -InputObject @($newMigrations | Select-Object -Unique))) }
Write-Host ('[NeoFFTV] Waypointy: '+(($data.worlds | ForEach-Object { $_.rows.Count } | Measure-Object -Sum).Sum)+' punktow, zmienione pliki: '+$changes)
