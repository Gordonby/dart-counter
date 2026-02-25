param(
    [Parameter(Mandatory=$true)]
    [string]$Endpoint,
    [string]$Method = "GET",
    [string]$Params = "",
    [string]$Data = ""
)

$token = $env:dartcounter
if (-not $token) {
    Write-Host "Error: environment variable 'dartcounter' is not set." -ForegroundColor Red
    exit 1
}

$baseUrl = "https://api.dartcounter.net"
$url = "$baseUrl/$($Endpoint.TrimStart('/'))"

# Append params to URL if provided
if ($Params) {
    try {
        $jsonParams = $Params | ConvertFrom-Json
        $queryString = ($jsonParams.psobject.properties | ForEach-Object { "$($_.Name)=$([uri]::EscapeDataString($_.Value))" }) -join "&"
        $url = "$url?$queryString"
    } catch {
        Write-Host "Error parsing Params JSON." -ForegroundColor Yellow
    }
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
