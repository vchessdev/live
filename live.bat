@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo Cleaning old files
del /q stream.m3u8 2>nul
del /q segment_*.ts 2>nul
del /q playlist.m3u 2>nul

start "FFmpeg Stream" cmd /k ^
ffmpeg -hide_banner -loglevel warning ^
  -f gdigrab -framerate 30 -i desktop ^
  -i logo.png ^
  -filter_complex "[1:v]scale=120:-1[logo];[0:v][logo]overlay=main_w-overlay_w-20:main_h-overlay_h-20" ^
  -c:v libx264 -preset ultrafast -tune zerolatency -b:v 1500k ^
  -an ^
  -hls_time 2 ^
  -hls_list_size 10 ^
  -hls_flags delete_segments+program_date_time ^
  -hls_segment_type mpegts ^
  -hls_segment_filename "segment_%%03d.ts" ^
  -y stream.m3u8

timeout /t 5

echo ==========================================
echo   AUTO PUSH STARTED
echo ==========================================

:loop
REM Tạo timestamp
for /f "delims=" %%A in ('powershell -Command "[System.DateTime]::Now.Ticks"') do set timestamp=%%A

if exist stream.m3u8 (
    REM Tạo playlist.m3u với timestamp
    (
        echo #EXTM3U
        echo #EXTINF:-1 tvg-chno="1" tvg-name="My Live" tvg-logo="logo.png",My Live Stream
        echo https://raw.githubusercontent.com/vchessdev/live/main/stream.m3u8?t=!timestamp!
    ) > playlist.m3u
    
    REM Push lên GitHub
    git add -A 2>nul
    git commit -m "Live !timestamp!" --quiet 2>nul
    git push origin main --quiet 2>nul
    
    echo [%time:~0,8%] Pushed ?t=!timestamp!
)

timeout /t 2 /nobreak >nul
goto loop