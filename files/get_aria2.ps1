try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
} catch {
    Write-Error "Outdated operating systems are not supported."
    Exit 1
}

$file = 'aria2c.exe'
$url = 'https://uupdump.net/misc/aria2c.exe';
$hash = 'b9cd71b275af11b63c33457b0f43f2f2675937070c563e195f223efd7fa4c74b';

function Test-Existence {
    param (
        [String]$File
    )

    return Test-Path -PathType Leaf -Path "files\$File"
}

function Retrieve-File {
    param (
        [String]$File,
        [String]$Url
    )

    Write-Host -BackgroundColor Black -ForegroundColor Yellow "Downloading ${File}..."
    Invoke-WebRequest -UseBasicParsing -Uri $Url -OutFile "files\$File" -ErrorAction Stop
}

function Test-Hash {
    param (
        [String]$File,
        [String]$Hash
    )

    Write-Host -BackgroundColor Black -ForegroundColor Cyan "Verifying ${File}..."

    $fileHash = (Get-FileHash -Path "files\$File" -Algorithm SHA256 -ErrorAction Stop).Hash
    return ($fileHash.ToLower() -eq $Hash)
}

if((Test-Existence -File $file) -and (Test-Hash -File $file -Hash $hash)) {
    Write-Host -BackgroundColor Black -ForegroundColor Green "Ready."
    Exit 0
}

if(-not (Test-Path -PathType Container -Path "files")) {
    $null = New-Item -Path "files" -ItemType Directory
}

$ProgressPreference = 'SilentlyContinue'

try {
    Retrieve-File -File $file -Url $url
} catch {
    Write-Host "Failed to download $file"
    Write-Host $_
    Exit 1
}

Write-Host -BackgroundColor Black -ForegroundColor Green "Ready."
