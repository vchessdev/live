@echo off
chcp 65001 >nul

:loop
git add stream.m3u8 segment_*.ts 2>nul
git diff --cached --quiet

if errorlevel 1 (
    git commit -m "Live %date:~-10% %time:~0,8%" --quiet
    git push origin main --quiet
    echo [%time:~0,8%] Pushed
)

timeout /t 2 /nobreak >nul
goto loop