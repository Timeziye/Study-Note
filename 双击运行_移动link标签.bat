@echo off
chcp 65001 >nul
title HTML文件link标签移动工具

echo.
echo ========================================
echo    HTML文件link标签移动工具
echo ========================================
echo.
echo 功能说明：
echo   - 查找以 https://madmaxchow.github.io/openfonts/css/vlook- 开头的link标签
echo   - 将找到的link标签移动到 /style 标签后面
echo   - 避免重复插入相同的link标签
echo.

REM 切换到脚本所在目录
cd /d "%~dp0"

REM 检查是否存在HTML文件
dir /b *.html >nul 2>&1
if errorlevel 1 (
    echo 当前目录下没有找到HTML文件！
    echo.
    echo 请确保：
    echo   1. 将此批处理文件放在包含HTML文件的目录中
    echo   2. 目录中存在 .html 文件
    echo.
    pause
    exit /b 1
)

echo 正在扫描HTML文件...
echo.

REM 运行PowerShell脚本
powershell -ExecutionPolicy Bypass -File "move_link.ps1"

echo.
echo ========================================
echo 处理完成！按任意键退出...
echo ========================================
pause >nul 