# PipelineAlertManager

通过事件驱动通知展示，调度层维护优先级和等待队列，展示层选择宿主并逐个展示。

## 运行 Demo

执行 `pod install`，打开 `PipelineAlertManagerDemo.xcworkspace`，运行 `PipelineAlertManagerDemo`。

`NoteMsgViewController` 和具体事件模型位于 Demo 中，核心模块不依赖 SnapKit 或 MyBaseExtension。

| 场景 | 预期结果 |
| --- | --- |
| 逐个展示 | 关闭通知 1 后展示通知 2，再展示通知 3 |
| 优先级排序 | 紧急 → 高 → 默认 → 低 |
| 同优先级先进先出 | A → B → C |
| 同 ID 替换 | 仅展示替换后的内容，并按新优先级排序 |
| 取消后继续 | 点击取消后继续下一条 |
| 普通页面阻止通知 | 普通页面不展示，返回宿主后展示等待通知 |
| 顶层 VC 策略 | 可以在未继承宿主基类的普通页面展示 |
| 全屏关闭后恢复 | 宿主重新出现后继续下一条 |

## 自动检查

点击 Demo 中的“运行自动检查”，结果显示在页面底部和 Xcode 控制台。

检查覆盖空队列、四档优先级、同级顺序、ID 替换、context 初始状态、宿主身份匹配、宿主退出和弱引用，共 8 项。

Debug 启动参数 `--run-pipeline-checks` 可在页面出现后自动执行检查；同时添加 `--exit-after-checks` 时，根据结果以退出码 0 或 1 结束进程。成功输出为 `PIPELINE_CHECKS: 8/8 PASS`。

自动检查验证队列和宿主管理逻辑；真实转场与展示顺序通过上面的 Demo 场景操作验证。
