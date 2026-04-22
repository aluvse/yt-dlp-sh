# ==========================================================
# YT-DLP PowerShell Downloader (Stable GitHub Template)
# ==========================================================
# Description: Stable downloader with HLS fixes and codec priority.
# Requirements: yt-dlp, FFmpeg, Deno.
# ==========================================================

# 1. SETUP: Replace with your actual paths
$binPath    = "C:\YOUR_PATH_TO\ytdlp"
$ffmpegBin  = "C:\YOUR_PATH_TO\ffmpeg\bin"
$denoPath   = "C:\YOUR_PATH_TO\.deno\bin\deno.exe" 

# Automatic configuration
$savePath   = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ytDlpExe   = Join-Path $binPath "yt-dlp.exe"

# ==========================================================
# Environment Check
# ==========================================================

if (-not (Test-Path $ytDlpExe)) {
    Write-Host "ERROR: yt-dlp.exe not found. Please check `$binPath in the script." -ForegroundColor Red
    pause ; exit
}

# ==========================================================
# User Input
# ==========================================================

Write-Host "1. Paste link(s) and press ENTER" -ForegroundColor Cyan
$userInput = Read-Host ">"
$urls = $userInput -split '\s+' | Where-Object { $_ -match '^https?://' }

if ($urls.Count -eq 0) {
    Write-Host "No valid URLs detected." -ForegroundColor Red
    pause ; exit
}

Write-Host "`n2. Choose Quality (Press key):" -ForegroundColor Cyan
Write-Host "[1] - 1080p"
Write-Host "[2] / [ENTER]      - 720p" -ForegroundColor Green
Write-Host "[3] / [BACKSPACE] - 480p" -ForegroundColor Yellow
Write-Host "[4] - 360p"
Write-Host "[5] - 144p"

$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
$vk = $key.VirtualKeyCode

if ($vk -eq 49) { $res = 1080 }
elseif ($vk -eq 50 -or $vk -eq 13) { $res = 720 }
elseif ($vk -eq 51 -or $vk -eq 8) { $res = 480 }
elseif ($vk -eq 52) { $res = 360 }
elseif ($vk -eq 53) { $res = 144 }
else { $res = 720 ; Write-Host "Defaulting to 720p" }

Write-Host "`nSelected: ${res}p" -ForegroundColor Cyan

# ==========================================================
# Download Process
# ==========================================================

foreach ($url in $urls) {
    Write-Host "`n[*] Processing: $url" -ForegroundColor Yellow
    
    # Codec priority: AV1 > VP9 > H.264
    $formatStr = "bestvideo[height<=$res][vcodec^=av01]+bestaudio/best[height<=$res]/bestvideo[height<=$res][vcodec^=vp9]+bestaudio/best[height<=$res]/best"
    
    & $ytDlpExe -f $formatStr `
            --continue `
            --no-overwrites `
            --ffmpeg-location "$ffmpegBin" `
            --merge-output-format mkv `
            --hls-prefer-ffmpeg `
            --fixup detect_or_warn `
            --abort-on-unavailable-fragment `
            --socket-timeout 30 `
            --js-runtimes "deno:$denoPath" `
            --fragment-retries 10 `
            -o "$savePath\%(title)s.%(ext)s" `
            $url
}

Write-Host "`n[!] All tasks completed." -ForegroundColor Green
pause
