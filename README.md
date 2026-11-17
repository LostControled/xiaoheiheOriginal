# 小黑盒自动查看原图（iOS）

小黑盒原生图片浏览器插件：检测「查看原图」按钮出现时，自动触发按钮点击。

## 适用范围

- Bundle ID：`com.max.xiaoheihe`
- 分析版本：`1.3.393`
- 目标系统：iOS 16.3.1，arm64
- 注入：TrollFools（TrollStore 环境）
- 当前不保证支持 Flutter 图片页或其他 App 版本

## 下载与安装

- [下载预编译 dylib（ZIP）](dist/HBOriginalImage-iOS16-arm64.zip)
- [安装步骤](INSTALL.md)
- 解压后在 TrollFools 中选择小黑盒并注入 `HBOriginalImage.dylib`，再重启 App。

## 自行构建

需要 macOS 和 Xcode Command Line Tools：

```bash
bash scripts/build-dylib.sh
```

产物：`dist/HBOriginalImage.dylib`

## 发布 GitHub Release

仓库 **Actions → Build and publish iOS dylib → Run workflow**，输入版本标签（例如 `v1.0.1`）。工作流使用 GitHub 支持的 `macos-15` arm64 Runner 编译并创建 Release。

也可在 Mac 上使用 GitHub CLI：

```bash
bash scripts/publish-release.sh v1.0.1
```

## 调试

使用 macOS Console.app 搜索 `HBOriginalImage`。自动触发日志示例：

```
[HBOriginalImage] auto tapped CheckOriginalImageButton (...)
```

## 注意

插件只调用 App 自身的原图按钮，不绕过账号权限、付费条件或服务端校验。预编译包尚未在目标设备完成验证；注入可能造成闪退。若异常，请在 TrollFools 中移除插件并重启 App。
