# yt-dlp-sh

A resilient and minimalist PowerShell script for high-quality batch video downloading. It provides a fail-safe interactive UI that automates complex CLI flags, handles modern codecs, and organizes media library out of the box.

### Features
- **Interactive UI:** Instant resolution selection using hotkeys (`0-6`), `Enter` for 1080p, or `Backspace` for 720p.
- **Resilient Logic:** Smart fallback system. If a requested format is unavailable, the script automatically selects the next best match instead of crashing.
- **Efficient Codecs:** Built-in priority for **AV1** and **VP9**, ensuring the highest visual quality with the smallest possible file size (30-50% savings compared to H.264).
- **Audio Mode:** Dedicated "Audio Only" mode via hotkey `0`, extracting high-quality M4A/AAC.
- **Smart Playlists:** Automatically creates directory structures based on Uploader and Playlist title, maintaining proper indexing.
- **Preview Support:** Forces MKV container to allow watching files while the download is still in progress.
- **Stability:** Robust HLS fragment handling, custom socket timeouts, and fragment retries for unstable connections.

### Getting Started

1. **Clone the repository:**
```powershell
git clone https://github.com/aluvse/yt-dlp-sh
cd yt-dlp-sh
   
```


2. **Setup Paths:**
Open `run.ps1` and set your local paths for the required binaries:
```powershell
$binPath    = "C:\path\to\ytdlp\"
$ffmpegBin  = "C:\path\to\ffmpeg\bin"
$denoPath   = "C:\path\to\deno.exe"

```


3. **Authentication (Optional):**
Place your `cookies.txt` in the root folder to download private videos or bypass age restrictions.
4. **Launch:**
```powershell
./run.ps1

```



### 📦 Requirements

The script relies on these industry-standard tools:

* [yt-dlp](https://github.com/yt-dlp/yt-dlp) — The core engine for video extraction.
* [FFmpeg](https://ffmpeg.org/) — For muxing video and audio streams.
* [Deno](https://deno.land/) — Recommended JS runtime to handle YouTube's signature challenges and player updates.

### 🛠 Tech Stack

* **Language:** PowerShell
* **Target:** Windows (Cross-platform yt-dlp core)
* **Logic:** Fallback-oriented format sorting

---

*Disclaimer: This tool is for personal use only. Please respect the content creators and YouTube's Terms of Service.*

