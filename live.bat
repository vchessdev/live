@echo off
chcp 65001 >nul

REM Chạy FFmpeg ở background
start "" ffmpeg -hide_banner -loglevel warning ^
  -f gdigrab -framerate 30 -i desktop ^
  -i logo.png ^
  -filter_complex "[1:v]scale=120:-1[logo];[0:v][logo]overlay=main_w-overlay_w-20:main_h-overlay_h-20" ^
  -c:v libx264 -preset ultrafast -tune zerolatency -b:v 1500k ^
  -an ^
  -hls_time 2 ^
  -hls_list_size 5 ^
  -hls_flags delete_segments ^
  -hls_segment_filename "segment_%%03d.ts" ^
  -y stream.m3u8

REM Chờ FFmpeg tạo file
timeout /t 3

echo ==========================================
echo   LIVE STREAM STARTED
echo   Auto push to GitHub
echo   Ctrl+C to stop
echo ==========================================

REM Auto push loop
:loop
git add -A 2>nul
git diff --cached --quiet
if errorlevel 1 (
    echo [%time:~0,8%] Pushed to GitHub
    git commit -m "Live" --quiet 2>nul
    git push origin main --quiet 2>nul
)
timeout /t 2 /nobreak >nul
goto loop