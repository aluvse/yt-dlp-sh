# ==========================================================
# YT-DLP PowerShell Downloader (Zero-Loop Architecture)
# ==========================================================
# 1. SETUP: WRITE YOUR PATH
$binPath    = "YOUR_PATH_TO\ytdlp\"
$ffmpegBin  = "YOUR_PATH_TO\ffmpeg\bin"
$denoPath   = "YOUR_PATH_TO\bin\deno.exe" 

$savePath   = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ytDlpExe   = Join-Path $binPath "yt-dlp.exe"

# ==========================================================
# Environment Check
# ==========================================================

if (-not (Test-Path $ytDlpExe)) {
    Write-Host "ERROR: yt-dlp.exe not found." -ForegroundColor Red
    pause ; exit
}

# ==========================================================
# User Input & Quality Logic
# ==========================================================

Write-Host "1. Paste link(s) and press ENTER" -ForegroundColor Cyan
$userInput = Read-Host ">"
$urls = $userInput -split '\s+' | Where-Object { $_ -match '^https?://' }

if ($urls.Count -eq 0) {
    Write-Host "No valid URLs detected." -ForegroundColor Red
    pause ; exit
}

Write-Host "`n2. Select Quality:" -ForegroundColor Cyan
Write-Host "[ENTER] -> 1080p (Default)" -ForegroundColor Green
Write-Host "[BS]    -> 720p" -ForegroundColor Yellow
Write-Host "[0]      -> Audio Only (M4A/AAC)" -ForegroundColor Magenta
Write-Host "--------------------------"
Write-Host "[1] 1440p  [4] 480p"
Write-Host "[2] 1080p  [5] 360p"
Write-Host "[3] 720p   [6] 144p"

$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
$vk = $key.VirtualKeyCode

$audioOnly = $false

if ($vk -eq 48) { 
    $audioOnly = $true 
}
elseif ($vk -eq 49) { $res = 1440 }
elseif ($vk -eq 50 -or $vk -eq 13) { $res = 1080 } 
elseif ($vk -eq 51 -or $vk -eq 8) { $res = 720 }   
elseif ($vk -eq 52) { $res = 480 }
elseif ($vk -eq 53) { $res = 360 }
elseif ($vk -eq 54) { $res = 144 }
else { $res = 1080 ; Write-Host "Defaulting to 1080p" }

if ($audioOnly) {
    Write-Host "`nSelected: Audio Only" -ForegroundColor Magenta
    $formatStr = "bestaudio/best"
    $extraArgs = @("--extract-audio", "--audio-format", "m4a")
} else {
    Write-Host "`nSelected: ${res}p (Max Bitrate Mode)" -ForegroundColor Cyan
    $formatStr = "bestvideo[height<=$res]+bestaudio/best"
    $extraArgs = @(
        "--merge-output-format", "mkv", 
        "--external-downloader-args", "ffmpeg:-loglevel panic",
        "--format-sort", "res:$res,quality"
    )
}

# ==========================================================
# Download Process
# ==========================================================

foreach ($url in $urls) {
    Write-Host "`n[*] Processing: $url" -ForegroundColor Yellow
    
    $isCollection = ($url -like "*list=*" -or $url -like "*/playlists*" -or $url -like "*/@*")
    $outTemplate = if ($isCollection) {
        "./%(uploader)s/%(playlist_title)s/%(playlist_index)s - %(title)s [%(id)s].%(ext)s"
    } else {
        "./%(title)s [%(id)s].%(ext)s"
    }

    $allArgs = @(
        "-f", $formatStr,
        "--continue",
        "--no-overwrites",              
        "--embed-chapters",
        "--cookies", "$savePath\cookies.txt",
        "--ffmpeg-location", $ffmpegBin,
        "--hls-prefer-ffmpeg",
        "--fixup", "detect_or_warn",
        "--abort-on-unavailable-fragment",
        "--socket-timeout", "30",
        "--js-runtimes", "deno:$denoPath",
        "--fragment-retries", "10",
        "--yes-playlist",
        "--output-na-placeholder", "",
        "--restrict-filenames",        
        "-o", $outTemplate
    )

    if ($extraArgs) { $allArgs += $extraArgs }

    & $ytDlpExe $allArgs "$url"
}

Write-Host "`n[!] All tasks completed." -ForegroundColor Green
pause
