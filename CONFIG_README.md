# 配置文件使用说明

## 概述

此Flutter应用支持通过配置文件动态设置API相关参数，而不需要重新编译应用。

## 配置文件位置

### 开发环境
配置文件位于项目根目录：`config.json`

### 生产环境
配置文件必须与可执行文件在同一目录下：

**Windows:**
```
pos_ui_flutter.exe
config.json
data/
flutter_windows.dll
```

**macOS:**
```
pos_ui_flutter.app/
config.json
```

**Linux:**
```
pos_ui_flutter
config.json
```

## 配置文件格式

```json
{
  "api": {
    "baseUrl": "http://localhost:8003/api/v1",
    "apiKey": "your-api-key-here", 
    "terminalId": "demo_tenant-STORE001-1"
  }
}
```

### 配置项说明

- `baseUrl`: API服务器的基础URL
- `apiKey`: API访问密钥
- `terminalId`: 终端设备标识符

## 使用方法

1. **修改配置**: 编辑 `config.json` 文件中的相应值
2. **重启应用**: 配置更改后需要重启应用才能生效
3. **配置验证**: 应用启动时会自动加载并验证配置

## 错误处理

- 如果配置文件不存在或格式错误，应用将使用默认值
- 错误信息会在控制台输出，帮助诊断问题
- 应用不会因配置文件错误而崩溃

## 部署说明

### Windows 部署

1. 构建应用：
   ```bash
   flutter build windows --release
   ```

2. 将 `config.json` 复制到构建输出目录：
   ```bash
   cp config.json build/windows/x64/runner/Release/config.json
   ```

3. 分发整个 Release 文件夹

### 自动部署脚本

你可以创建一个部署脚本来自动化这个过程：

**Windows (deploy.bat):**
```batch
@echo off
echo Building Flutter app...
flutter build windows --release

echo Copying config file...
copy config.json build\windows\x64\runner\Release\config.json

echo Build complete! Files are in build\windows\x64\runner\Release\
```

**macOS/Linux (deploy.sh):**
```bash
#!/bin/bash
echo "Building Flutter app..."
flutter build linux --release  # 或 flutter build macos --release

echo "Copying config file..."
cp config.json build/linux/x64/release/bundle/config.json  # 或相应的macOS路径

echo "Build complete!"
```

## 安全注意事项

- **不要**将包含敏感信息的 `config.json` 文件提交到版本控制系统
- 在生产环境中确保配置文件的访问权限设置合适
- 定期更换API密钥以提高安全性

## 故障排除

### 常见问题

1. **配置未生效**
   - 确认 `config.json` 文件位置正确
   - 检查JSON格式是否有效
   - **重启应用**（重要：配置只在启动时加载）
   - 查看控制台输出，确认是否从本地文件加载

2. **配置文件被忽略**
   - 应用优先从本地文件加载配置
   - 如果本地文件不存在，会从内置资源加载
   - 运行 `reset_config_windows.bat` 重置配置文件

3. **文件权限错误**
   - 确保应用有读取配置文件的权限
   - 检查文件不是只读状态

4. **配置重置**
   - 运行 `reset_config_windows.bat` 重置为默认配置
   - 或手动删除 `config.json` 后重新部署

### 调试方法

1. **查看控制台输出**：
   - 启动应用时注意控制台输出
   - 应该看到类似信息：
     ```
     Configuration loaded from local file: config.json
     Base URL: http://your-server:8003/api/v1
     ```

2. **验证配置文件**：
   - 确保JSON格式正确
   - 使用在线JSON验证器检查格式

3. **测试步骤**：
   - 修改 `baseUrl` 为一个明显错误的地址
   - 重启应用
   - 观察是否出现连接错误 