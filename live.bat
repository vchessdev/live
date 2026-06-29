@echo off
chcp 65001 >nul

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

pause