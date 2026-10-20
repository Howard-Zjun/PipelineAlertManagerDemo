# PipelineAlertManagerDemo

PipelineAlertManager 的交互测试 Demo，用于检查通知逐个展示、优先级排序、事件去重和宿主页面限制。

## 依赖

项目通过 CocoaPods 以本地路径引入核心模块，弹窗示例使用 SnapKit 和 MyBaseExtension：

```ruby
pod 'PipelineAlertManager', :path => './PipelineAlertManager'
pod 'SnapKit'
pod 'MyBaseExtension'
```

在仓库根目录安装依赖并打开工作区：

```bash
pod install
open PipelineAlertManagerDemo.xcworkspace
```

运行 `PipelineAlertManagerDemo` Scheme。

## 测试入口

- **交互场景**：在首页选择逐个展示、优先级、同级顺序、ID 替换、取消推进、宿主限制、顶层 VC 或全屏恢复，按页面提示检查结果。
- **自动检查**：点击“运行自动检查”，执行 8 项队列及宿主管理检查，结果显示在页面底部和 Xcode 控制台。

Debug 启动参数 `--run-pipeline-checks` 可自动运行检查；添加 `--exit-after-checks` 可按结果以退出码 0 或 1 结束进程。成功输出为 `PIPELINE_CHECKS: 8/8 PASS`。

## 相关项目

- [PipelineAlertManager](https://github.com/Howard-Zjun/PipelineAlertManager)：事件驱动的通知调度与展示组件。
