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

## 相关项目

- [PipelineAlertManager](https://github.com/Howard-Zjun/PipelineAlertManager)：事件驱动的通知调度与展示组件。
