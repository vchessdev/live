@echo off
chcp 65001 >nul

echo Cleaning old files
del /q stream.m3u8 2>nul
del /q segment_*.ts 2>nul

echo ==========================================
echo   STARTING LIVE STREAM
echo ==========================================

REM Chạy FFmpeg ở cửa sổ riêng
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
echo   Ctrl+C to stop
echo ==========================================

REM Auto push loop chính
:loop
if exist stream.m3u8 (
    git add -A 2>nul
    git commit -m "Live %time:~0,8%" --quiet 2>nul
    git push origin main --quiet 2>nul
    echo [%time:~0,8%] Pushed
)

timeout /t 2 /nobreak >nul
goto loop