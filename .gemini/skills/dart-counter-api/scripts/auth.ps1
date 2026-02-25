param(
    [string]$Email = $env:DARTCOUNTER_EMAIL,
    [string]$Password = $env:DARTCOUNTER_PASSWORD
)

if (-not $Email -or -not $Password) {
    Write-Host "Error: DARTCOUNTER_EMAIL and DARTCOUNTER_PASSWORD environment variables must be set." -ForegroundColor Red
    Write-Host "Alternatively, pass them as parameters: .\auth.ps1 -Email 'your@email.com' -Password 'yourpassword'" -ForegroundColor Yellow
    exit 1
}

$body = @{
    login = $Email
    password = $Password
} | ConvertTo-Json

Write-Host "Authenticating with api.dartcounter.net..." -ForegroundColor Cyan

$response = curl.exe -s -X POST https://api.dartcounter.net/login `
    -H "Accept: application/json" `
    -H "Content-Type: application/json" `
    -H "Origin: https://app.dartcounter.net" `
    -d $body

try {
    $jsonResponse = $response | ConvertFrom-Json
    if ($jsonResponse.access_token) {
        # Set the environment variable for the current process
        [Environment]::SetEnvironmentVariable("dartcounter", $jsonResponse.access_token, "Process")
        Write-Host "✅ Login Successful! Bearer token saved to `$env:dartcounter" -ForegroundColor Green
        
        # Display basic user info if available
        if ($jsonResponse.user) {
            $user = $jsonResponse.user
            Write-Host "👤 User: $($user.first_name) $($user.last_name) ($($user.username))" -ForegroundColor Cyan
        }
    } else {
        Write-Host "❌ Login Failed: Could not find access_token in the response." -ForegroundColor Red
        Write-Host "Response: $response" -ForegroundColor Gray
    }
} catch {
    Write-Host "❌ Error parsing response." -ForegroundColor Red
    Write-Host "Response: $response" -ForegroundColor Gray
}
