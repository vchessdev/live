@echo off
chcp 65001 >nul

set REPO_PATH=D:\Documents\live

cd /d %REPO_PATH%

REM Config git
git config user.email "stream@local"
git config user.name "Stream Bot"

:loop
git add stream.m3u8 segment_*.ts 2>nul
git diff --cached --quiet
if errorlevel 1 (
    git commit -m "Live %date:~-10% %time:~0,8%" --quiet
    git push origin main --quiet
)

timeout /t 1
goto loop