param(
    [Parameter(Mandatory=$true)]
    [string]$Endpoint,
    [string]$Method = "GET",
    [string]$Params = "",
    [string]$Data = ""
)

# REF: This is the known good URL that we're constructing
#https://api.dartcounter.net/matches/opensearch?from_date=Thu%20Jan%2001%202026%2000%3A00%3A00%20GMT%2B0000&to_date=Thu%20Dec%2031%202026%2023%3A59%3A59%20GMT%2B0000&is_verified=true&limit=25&page=1

$token = $env:dartcounter
if (-not $token) {
    Write-Host "Error: environment variable 'dartcounter' is not set." -ForegroundColor Red
    exit 1
}

$baseUrl = "https://api.dartcounter.net"
$url = "$baseUrl/$($Endpoint.TrimStart('/'))"
Write-Verbose "Constructed endpoint URL: $url"

# Append params to URL if provided
if ($Params) {
    try {
        $jsonParams = $Params | ConvertFrom-Json
        $queryString = ($jsonParams.psobject.properties | ForEach-Object { "$($_.Name)=$([uri]::EscapeDataString($_.Value))" }) -join "&"

        Write-Verbose "Constructed query string: $queryString"

        $url = @($url, "?", $queryString) -join ""
        Write-Verbose "Constructed full URL: $url"
    } catch {
        Write-Host "Error parsing Params JSON." -ForegroundColor Yellow
    }
} else {
    Write-Verbose "No Params provided, using good defaults"
    $queryString = "from_date=Sun%20Jan%2001%202023%2000%3A00%3A00%20GMT%2B0000&to_date=$([uri]::EscapeDataString((Get-Date).ToString('ddd MMM dd yyyy HH:mm:ss ''GMT''zz00')))&is_verified=true&limit=360&page=1"
    $url = @($url, "?", $queryString) -join ""
    Write-Verbose "Constructed full URL: $url"
}

$headers = @{
    "Authorization" = "Bearer $token"
    "Accept" = "application/json"
    "Content-Type" = "application/json"
}

try {
    if ($Method -eq "POST" -and $Data) {
        $response = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body $Data -ErrorAction Stop
    } else {
        $response = Invoke-RestMethod -Uri $url -Method Get -Headers $headers -ErrorAction Stop
    }
    $response | ConvertTo-Json -Depth 10
} catch {
    Write-Host "Error fetching $url : $_" -ForegroundColor Red
    if ($_.ErrorDetails.Message) {
        Write-Host "Response Details: $($_.ErrorDetails.Message)" -ForegroundColor Gray
    }
    exit 1
}
