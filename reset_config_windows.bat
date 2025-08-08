@echo off
echo ========================================
echo 配置文件重置脚本
echo ========================================

set "BUILD_DIR=build\windows\x64\runner\Release"

echo.
echo 此脚本将重置配置文件到默认值
echo 构建目录：%BUILD_DIR%
echo.

if not exist "%BUILD_DIR%" (
    echo 错误：构建目录不存在！请先运行 deploy_windows.bat
    pause
    exit /b 1
)

echo 正在重置配置文件...

if exist "%BUILD_DIR%\config.json" (
    del "%BUILD_DIR%\config.json"
    echo 已删除现有配置文件
)

if exist "config.json" (
    copy "config.json" "%BUILD_DIR%\config.json"
    echo 已复制默认配置文件到构建目录
) else (
    echo 创建默认配置文件...
    (
        echo {
        echo   "api": {
        echo     "baseUrl": "http://localhost:8003/api/v1",
        echo     "apiKey": "1px1jTk-rSxJVQB0A89o_N4stNUN_hi22gj9fqtnw4U",
        echo     "terminalId": "demo_tenant-STORE001-1"
        echo   }
        echo }
    ) > "%BUILD_DIR%\config.json"
    echo 已创建默认配置文件
)

echo.
echo ========================================
echo 配置文件重置完成！
echo ========================================
echo.
echo 配置文件位置：%BUILD_DIR%\config.json
echo.
echo 您现在可以编辑配置文件并重启应用
echo ========================================

pause 