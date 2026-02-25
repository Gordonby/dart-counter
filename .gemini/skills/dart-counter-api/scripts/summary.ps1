$token = $env:dartcounter
if (-not $token) {
    Write-Host "Error: environment variable 'dartcounter' is not set." -ForegroundColor Red
    exit 1
}

function Fetch-Data {
    param(
        [string]$Endpoint,
        [string]$Params
    )
    $baseUrl = "https://api.dartcounter.net"
    $trimmedEndpoint = $Endpoint.TrimStart('/')
    $url = "${baseUrl}/${trimmedEndpoint}"
    
    if ($Params) {
        $url = "${url}?${Params}"
    }
    
    $headers = @{
        "Authorization" = "Bearer $token"
        "Accept" = "application/json"
    }
    
    try {
        $response = Invoke-RestMethod -Uri $url -Method Get -Headers $headers -ErrorAction Stop
        return $response
    } catch {
        Write-Host "Error fetching ${Endpoint}: $_" -ForegroundColor Red
        return $null
    }
}

function Persist-Data($Data, [string]$Category) {
    $exportDir = "data/exports/$Category"
    if (-not (Test-Path -Path $exportDir)) {
        New-Item -ItemType Directory -Force -Path $exportDir | Out-Null
    }
    
    $timestamp = (Get-Date).ToString("yyyyMMdd_HHmmss")
    $filename = "$exportDir/${Category}_${timestamp}.json"
    
    $Data | ConvertTo-Json -Depth 10 | Set-Content -Path $filename
    return $filename
}

function Render-AsciiDashboard($Matches, $TargetUserId) {
    if (-not $Matches -or $Matches.Count -eq 0) {
        return "No matches found."
    }
    
    $totalGames = @($Matches).Count
    $sumAvg = 0
    $bestAvg = 0
    $won = 0
    
    foreach ($m in $Matches) {
        $userStats = $m.users | Where-Object { $_.user_id -eq $TargetUserId }
        if ($userStats) {
            $avg = [double]($userStats.three_dart_average)
            if ($avg) {
                $sumAvg += $avg
                if ($avg -gt $bestAvg) { $bestAvg = $avg }
            }
            if ($userStats.result -eq 'won') { $won++ }
        }
    }
    
    $avg3Dart = if ($totalGames -gt 0) { $sumAvg / $totalGames } else { 0 }
    $winPct = if ($totalGames -gt 0) { ($won / $totalGames) * 100 } else { 0 }

    $dashboard = @"
    +--------------------------------------------------+
    |                DARTCOUNTER STATS                 |
    +--------------------------------------------------+
    | TOTAL GAMES:   $("{0,-33}" -f $totalGames) |
    | WIN RATE:      $("{0,-33}" -f "{0:N1}%" -f $winPct) |
    | AVG 3-DART:    $("{0,-33}" -f "{0:N2}" -f $avg3Dart) |
    | BEST AVG:      $("{0,-33}" -f "{0:N2}" -f $bestAvg) |
    +--------------------------------------------------+
    |           RECENT MATCH PERFORMANCE               |
    +--------------------------------------------------+
"@
    
    $dashboard += "`n"
    for ($i = 0; $i -lt [math]::Min(5, $totalGames); $i++) {
        $m = $Matches[$i]
        $userStats = $m.users | Where-Object { $_.user_id -eq $TargetUserId }
        $otherStats = $m.users | Where-Object { $_.user_id -ne $TargetUserId }
        
        $date = if ($m.started_at) { [DateTimeOffset]::FromUnixTimeSeconds($m.started_at).DateTime.ToString("yyyy-MM-dd") } else { "Unknown" }
        $res = if ($userStats -and $userStats.result -eq 'won') { "WON " } else { "LOSS" }
        
        # Calculate legs score
        $legsWon = if ($userStats) { [int]$userStats.checked_legs } else { 0 }
        $legsLost = if ($otherStats) { [int]($otherStats | Measure-Object -Property checked_legs -Sum).Sum } else { 0 }
        $score = "$legsWon-$legsLost"
        
        $avgValue = if ($userStats -and $userStats.three_dart_average) { "{0:N2}" -f $userStats.three_dart_average } else { "0.00" }
        $vsCpu = if ($m.settings -and $m.settings.vs_cpu -eq $true) { "🤖" } else { "  " }
        
        # Main match row with explicit column widths
        $cDate  = "{0,-10}" -f $date
        $cRes   = "{0,-4}"  -f $res
        $cScore = "{0,-5}"  -f $score
        $cAvg   = "AVG: {0,-10}" -f $avgValue
        $cRobot = "{0,-2}"  -f $vsCpu
        
        $dashboard += "    | $cDate | $cRes | $cScore | $cAvg | $cRobot |`n"

        # Show leg breakdown only if more than 1 leg played
        if ($m.legs -and $m.legs.Count -gt 1) {
            $legIndex = 1
            foreach ($leg in $m.legs) {
                $legUser = $leg.users | Where-Object { $_.user_id -eq $TargetUserId }
                if ($legUser -and $legUser.three_dart_average) {
                    $lAvg = "{0:N1}" -f $legUser.three_dart_average
                    $legInfo = " - L${legIndex}: ${lAvg}"
                    
                    $cLDate  = "{0,-10}" -f ""
                    $cLRes   = "{0,-4}"  -f ""
                    $cLScore = "{0,-5}"  -f ""
                    $cLAvg   = "{0,-15}" -f $legInfo
                    $cLRobot = "{0,-2}"  -f ""
                    
                    $dashboard += "    | $cLDate | $cLRes | $cLScore | $cLAvg | $cLRobot |`n"
                }
                $legIndex++
            }
        }
    }
    
    $dashboard += "    +--------------------------------------------------+"
    return $dashboard
}

Write-Host "Fetching latest matches..." -ForegroundColor Cyan
$params = "from_date=Thu%20Jan%2001%202026%2000%3A00%3A00%20GMT%2B0000&to_date=Thu%20Dec%2031%202026%2023%3A59%3A59%20GMT%2B0000&limit=250&page=1&is_verified=true"

$data = Fetch-Data -Endpoint "/matches/opensearch" -Params $params

# For this session, we'll use the authenticated User ID: 15836224
$currentUserId = 15836224

if ($data -and $data.data) {
    $filename = Persist-Data -Data $data -Category "matches"
    Write-Host "Data persisted to: $filename" -ForegroundColor Green
    Write-Host (Render-AsciiDashboard -Matches $data.data -TargetUserId $currentUserId) -ForegroundColor Cyan
} else {
    Write-Host "Failed to retrieve match data." -ForegroundColor Yellow
}
