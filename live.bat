@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

set OUTPUT_PATH=%REPO_PATH%
set SEGMENT_TIME=2
set LOGO_PATH=%REPO_PATH%\logo.png

cd /d %OUTPUT_PATH%

REM Capture màn hình, thêm logo góc dưới phải, output M3U8 low-latency
ffmpeg -f gdigrab -framerate 30 -i desktop ^
  -i %LOGO_PATH% ^
  -filter_complex "[0:v][1:v]scale=iw/8:-1[logo];[0:v][logo]overlay=main_w-main_w/30-overlay_w:main_h-main_h/30-overlay_h:enable='between(t,0,86400)'" ^
  -c:v libx264 -preset ultrafast -b:v 1500k -maxrate 1800k ^
  -hls_time %SEGMENT_TIME% ^
  -hls_list_size 5 ^
  -hls_flags delete_segments+program_date_time ^
  -hls_segment_type mpegts ^
  -hls_segment_filename "segment_%%03d.ts" ^
  -loglevel warning ^
  stream.m3u8

pause