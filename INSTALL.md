# iOS dylib 安装

## 设备要求

- arm64 iPhone
- iOS 16.3.1（当前项目目标环境）
- TrollStore 与 TrollFools
- 已安装小黑盒

## 安装步骤

1. 从 GitHub Releases 下载 `HBOriginalImage-vX-iOS16-arm64.zip`。
2. 在 iPhone「文件」App 中解压，得到 `HBOriginalImage.dylib`。
3. 打开 TrollFools，选择小黑盒 App。
4. 选择 Inject Dylib，导入 `HBOriginalImage.dylib`。
5. 注入完成后彻底退出并重新打开小黑盒。
6. 打开帖子图片，检查「查看原图」是否自动触发。

如果 App 闪退或图片浏览异常，在 TrollFools 中移除该 dylib，再重启小黑盒。

## 适用范围与注意事项

- 目标 App：`com.max.xiaoheihe`，分析版本 1.3.393。
- 主要覆盖原生图片浏览器；Flutter 图片查看器不保证支持。
- 新版 App 可能修改类名或按钮逻辑，导致插件失效。
- 插件只触发 App 自身的原图按钮，不绕过账号权限、付费条件或服务端校验。
