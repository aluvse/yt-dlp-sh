# ==========================================================
# YT-DLP PowerShell Downloader
# Settings
# ==========================================================

$YT_DLP_DIR   = "C:\YOUR_PATH_TO\ytdlp"
$FFMPEG_DIR   = "C:\YOUR_PATH_TO\ffmpeg\bin"
$DENO_EXE     = "C:\YOUR_PATH_TO\.deno\bin\deno.exe"

$SAVE_DIR     = Split-Path -Parent $MyInvocation.MyCommand.Definition
$YT_DLP_EXE   = Join-Path $YT_DLP_DIR "yt-dlp.exe"

# ==========================================================
# Environment Check
# ==========================================================

if (-not (Test-Path $YT_DLP_EXE)) {
    Write-Host "ERROR: yt-dlp.exe not found at $YT_DLP_DIR" -ForegroundColor Red
    pause ; exit
}

# ==========================================================
# User Input
# ==========================================================

Write-Host "1. Enter URL(s) and press [ENTER]" -ForegroundColor Cyan
$inputRaw = Read-Host ">"
$urls = $inputRaw -split '\s+' | Where-Object { $_ -match '^https?://' }

if ($urls.Count -eq 0) {
    Write-Host "No valid URLs detected." -ForegroundColor Red
    pause ; exit
}

Write-Host "`n2. Select Quality:" -ForegroundColor Cyan
Write-Host "[1] 1080p | [2/ENTER] 720p | [3/BS] 480p | [4] 360p | [5] 144p"

$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
$vk = $key.VirtualKeyCode

$resolution = if ($vk -eq 49) { 1080 }
elseif ($vk -eq 50 -or $vk -eq 13) { 720 }
elseif ($vk -eq 51 -or $vk -eq 8) { 480 }
elseif ($vk -eq 52) { 360 }
elseif ($vk -eq 53) { 144 }
else { 720 }

Write-Host "`nTarget Resolution: ${resolution}p" -ForegroundColor Cyan

# ==========================================================
# Download Process
# ==========================================================

# Codec priority: AV1 > VP9 > AVC (H.264)
$format = "bestvideo[height<=$resolution][vcodec^=av01]+bestaudio/best[height<=$resolution]/" +
          "bestvideo[height<=$resolution][vcodec^=vp9]+bestaudio/best[resolution<=$resolution]/" +
          "best[height<=$resolution]"

foreach ($url in $urls) {
    Write-Host "`n[*] Processing: $url" -ForegroundColor Yellow
    
    & $YT_DLP_EXE `
        -f $format `
        --continue `
        --no-overwrites `
        --hls-prefer-native `
        --merge-output-format mkv `
        --ffmpeg-location "$FFMPEG_DIR" `
        --js-runtimes "deno:$DENO_EXE" `
        --fixup warn `
        -o "$SAVE_DIR\%(title)s.%(ext)s" `
        $url
}

Write-Host "`n[!] All tasks completed." -ForegroundColor Green
pause