# 小黑盒自动查看原图（iOS）

打开小黑盒原生图片浏览器时，自动触发「查看原图」。

## 适用范围

- 小黑盒：分析版本 1.3.393（Bundle ID：`com.max.xiaoheihe`）
- 系统：iOS 16.3.1，arm64
- 注入：TrollFools（需 TrollStore 环境）
- 暂不保证支持 Flutter 图片页或其他 App 版本

## 下载与安装

**[下载最新版 v1.0.1（ZIP）](https://github.com/LostControled/xiaoheiheOriginal/releases/download/v1.0.1/HBOriginalImage-v1.0.1-iOS16-arm64.zip)**

[查看全部 Releases](https://github.com/LostControled/xiaoheiheOriginal/releases)

1. 下载并解压 ZIP。
2. 在 TrollFools 中选择小黑盒，注入 `HBOriginalImage.dylib`。
3. 重启小黑盒。

## 故障排查

如遇闪退或功能无效，在 TrollFools 中移除插件并重启 App。调试时可使用 macOS Console.app 搜索 `HBOriginalImage`。

## 注意

插件只触发 App 自身的原图按钮，不绕过账号权限、付费条件或服务端校验。尚未完成目标设备实测；注入第三方插件存在闪退风险。
