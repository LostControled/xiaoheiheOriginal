# 小黑盒自动查看原图（iOS）

针对小黑盒 iOS 客户端的实验性插件：当原生图片浏览器中的「查看原图」按钮变为可见时，自动触发按钮点击事件。

## 目标环境

- App：小黑盒，Bundle ID `com.max.xiaoheihe`
- 已分析版本：`1.3.393`
- 目标系统：iOS 16.3.1
- 注入方式：TrollStore 环境下使用 TrollFools 注入 dylib
- 代码：Objective-C Runtime Hook，不依赖 Substrate / ElleKit

> 当前仓库发布的是源码与构建脚本。代码尚未在你的设备上完成运行验证；不同小黑盒版本、Flutter 图片页面或 UI 改版可能不适用。

## 当前覆盖范围

源码监听 `CheckOriginalImageButton` 的 `setHidden:` 和 `setOriginImageBytesSize:`，并对 `HBPhotoGroupView` 的 `updateCheckOriginalImageButtonForCurrentPageIfNeeded` 做兜底处理。

目前不保证覆盖 Flutter 图片查看器，也不保证覆盖使用其他按钮类名的页面。

## 构建 dylib（需要 Mac）

安装 Xcode Command Line Tools 后，在仓库根目录执行：

```bash
bash build.sh
```

构建成功后生成：

```
dist/HBOriginalImage.dylib
```

## 注入

1. 将 `dist/HBOriginalImage.dylib` 传到 iPhone。
2. 在 TrollFools 中选择小黑盒并注入该 dylib。
3. 重启小黑盒，打开帖子图片测试「查看原图」是否自动触发。

注入前建议备份 App。若出现闪退，可在 TrollFools 中移除该 dylib 并重启 App。

## 日志

可通过 macOS Console.app 查看设备日志，搜索 `HBOriginalImage`。正常情况下会看到 Hook 安装日志；成功触发时会出现：

```
[HBOriginalImage] auto tapped CheckOriginalImageButton (...)
```

## 免责声明

仅供个人学习与自用。插件通过调用 App 自身按钮事件工作，不绕过账号权限、付费条件或服务端校验。使用修改或注入代码存在稳定性风险。


## 下载与发布 dylib

- 现成二进制包：[`dist/HBOriginalImage-iOS16-arm64.zip`](dist/HBOriginalImage-iOS16-arm64.zip)
- 安装说明：[`INSTALL.md`](INSTALL.md)
- Mac 构建：`bash scripts/build-dylib.sh`
- Mac 手动发布：`bash scripts/publish-release.sh v1.0.1`
- GitHub Actions：打开仓库 **Actions → Build and publish iOS dylib → Run workflow**，填写版本标签；也可推送 `v*` 标签自动构建并发布 Release。

仓库内的预编译包来自项目已有构建产物，已核对为 arm64 Mach-O；它不是本次在 macOS 上重新编译或真机复测的结果。正式 Release 工作流会在 GitHub macOS Runner 上重新编译源码后上传 dylib 和校验文件。
