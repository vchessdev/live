@echo off
chcp 65001 >nul

echo ==========================================
echo   CLEANING OLD FILES
echo ==========================================

REM Xóa file cũ
del /q stream.m3u8 2>nul
del /q segment_*.ts 2>nul

echo Cleaned old files

REM Tạo M3U8 mới
(
echo #EXTM3U
echo #EXT-X-VERSION:3
echo #EXT-X-TARGETDURATION:3
echo #EXT-X-MEDIA-SEQUENCE:0
echo #EXT-X-PLAYLIST-TYPE:EVENT
) > stream.m3u8

echo ==========================================
echo   PUSHING CLEAN STATE TO GITHUB
echo ==========================================

REM Push xóa files
git add -A
git commit -m "Fresh start" --quiet 2>nul
git push origin main --quiet 2>nul

echo Pushed clean state

timeout /t 2

echo ==========================================
echo   STARTING LIVE STREAM
echo ==========================================

REM Chạy FFmpeg
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

REM Chờ FFmpeg generate file
timeout /t 5

echo ==========================================
echo   AUTO PUSH TO GITHUB
echo   Ctrl+C to stop
echo ==========================================

REM Auto push loop
:loop
git add -A 2>nul
git diff --cached --quiet

if errorlevel 1 (
    echo [%time:~0,8%] ^> Pushed segments
    git commit -m "Live %date:~-10% %time:~0,8%" --quiet 2>nul
    git push origin main --quiet 2>nul
)

timeout /t 2 /nobreak >nul
goto loop