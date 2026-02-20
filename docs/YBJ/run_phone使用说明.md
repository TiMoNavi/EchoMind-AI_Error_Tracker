# run_phone.ps1 使用说明

脚本路径：`mistake_book/run_phone.ps1`

## 一键全自动（推荐）

在 PowerShell 执行：

```powershell
cd "d:\AI\AI+high school homework\mistake_book"
powershell -ExecutionPolicy Bypass -File .\run_phone.ps1
```

它会自动完成：

1. 关闭当前项目残留的 Flutter/Dart 前端进程
2. 关闭当前运行中的模拟器
3. 启动 `Pixel_8_API_35` 模拟器
4. 等待设备上线
5. 执行 `flutter run -d emulator-xxxx`

## 只检查到设备就绪（不启动前端）

```powershell
powershell -ExecutionPolicy Bypass -File .\run_phone.ps1 -NoRun
```

## 换成 Fold / Tablet 模拟器

```powershell
powershell -ExecutionPolicy Bypass -File .\run_phone.ps1 -EmulatorName Pixel_Fold_API_35
powershell -ExecutionPolicy Bypass -File .\run_phone.ps1 -EmulatorName Pixel_Tablet_API_35
```

## 调整设备等待超时（秒）

```powershell
powershell -ExecutionPolicy Bypass -File .\run_phone.ps1 -DeviceTimeoutSec 240
```

## 如果你看到 “Running multiple emulators with the same AVD”

这是旧模拟器进程还没完全退出造成的冲突。新版 `run_phone.ps1` 已经自动做了：

1. 关闭旧模拟器（ADB + 进程级）
2. 重启 ADB
3. 启动失败自动重试一次
4. 等待 `boot_completed=1` 再启动前端

所以正常情况下直接重跑同一条命令即可。


2. **保持这个终端不要关** ，然后改代码。
3. 改完后在这个终端里用：

* **r**：热重载（最快，推荐日常）
* **R**：热重启（改动较大时）
* **q**：退出运行

什么时候才需要再跑脚本：

1. 你把 **flutter run** 终端关了
2. 模拟器挂了/离线了
3. 改了 [pubspec.yaml](https://file+.vscode-resource.vscode-cdn.net/c%3A/Users/Administrator/.vscode/extensions/openai.chatgpt-0.5.76-win32-x64/webview/#)、原生配置、插件依赖后需要完整重启
