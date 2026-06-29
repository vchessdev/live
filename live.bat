@echo off
chcp 65001 >nul

REM Khởi tạo M3U8
(
echo #EXTM3U
echo #EXT-X-VERSION:3
echo #EXT-X-TARGETDURATION:3
echo #EXT-X-MEDIA-SEQUENCE:0
echo #EXT-X-PLAYLIST-TYPE:EVENT
) > stream.m3u8

REM Chạy FFmpeg
ffmpeg -hide_banner -loglevel warning ^
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

REM Auto push
:loop
git add -A 2>nul
git commit -m "." --quiet 2>nul
git push origin main --quiet 2>nul
timeout /t 2 /nobreak >nul
goto loop