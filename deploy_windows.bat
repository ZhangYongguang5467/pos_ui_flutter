@echo off
echo ========================================
echo Flutter Windows 构建和部署脚本
echo ========================================

echo.
echo 正在构建 Flutter Windows 应用...
flutter build windows --release

if %ERRORLEVEL% neq 0 (
    echo 构建失败！
    pause
    exit /b 1
)

echo.
echo 构建成功！正在复制配置文件...

set "BUILD_DIR=build\windows\x64\runner\Release"

if not exist "%BUILD_DIR%" (
    echo 错误：构建目录不存在！
    pause
    exit /b 1
)

if exist "config.json" (
    copy "config.json" "%BUILD_DIR%\config.json"
    echo 配置文件已复制到构建目录
) else (
    echo 警告：config.json 文件不存在，将使用默认配置
)

echo.
echo ========================================
echo 部署完成！
echo ========================================
echo.
echo 可执行文件位置：%BUILD_DIR%\pos_ui_flutter.exe
echo 配置文件位置：%BUILD_DIR%\config.json
echo.
echo 部署包内容：
dir /b "%BUILD_DIR%"
echo.
echo 你可以将整个 Release 文件夹分发给用户
echo ========================================

pause 