import UIKit
import PipelineAlertManager

final class ViewController: PipelineAlertHostViewController, UITableViewDataSource, UITableViewDelegate {

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let logView = UITextView()
    private var hasRunChecks = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let titleLabel = UILabel()
        titleLabel.text = "PipelineAlertManager Demo"
        titleLabel.font = .boldSystemFont(ofSize: 22)
        titleLabel.adjustsFontSizeToFitWidth = true

        let detailLabel = UILabel()
        detailLabel.text = "点击场景验证。关闭当前通知后，才会展示下一条。"
        detailLabel.font = .systemFont(ofSize: 14)
        detailLabel.textColor = .secondaryLabel
        detailLabel.numberOfLines = 0

        tableView.dataSource = self
        tableView.delegate = self
        tableView.accessibilityIdentifier = "demo.scenarios"
        tableView.backgroundColor = .clear

        logView.isEditable = false
        logView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        logView.backgroundColor = .secondarySystemBackground
        logView.layer.cornerRadius = 10
        logView.accessibilityIdentifier = "demo.log"
        logView.text = "等待运行用例…"

        let stack = UIStackView(arrangedSubviews: [titleLabel, detailLabel, tableView, logView])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            logView.heightAnchor.constraint(equalToConstant: 130)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        PipelineAlertPresenter.shared.setStrategy(PipelineAlertHostPresentationStrategy())
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        #if DEBUG
        if !hasRunChecks && ProcessInfo.processInfo.arguments.contains("--run-pipeline-checks") {
            hasRunChecks = true
            let passed = runChecks()
            if ProcessInfo.processInfo.arguments.contains("--exit-after-checks") {
                exit(passed ? 0 : 1)
            }
        }
        #endif
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Scenario.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let scenario = Scenario.allCases[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = scenario.title
        cell.detailTextLabel?.text = scenario.detail
        cell.detailTextLabel?.numberOfLines = 0
        cell.accessoryType = .disclosureIndicator
        cell.accessibilityIdentifier = "demo.scenario.\(scenario.rawValue)"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let scenario = Scenario.allCases[indexPath.row]
        logView.text = "用例：\(scenario.title)"
        switch scenario {
        case .checks:
            _ = runChecks()
        case .sequential:
            enqueue([event("通知 1"), event("通知 2"), event("通知 3")])
        case .priority:
            enqueue([
                event("低", priority: .low),
                event("默认", priority: .default),
                event("高", priority: .high),
                event("紧急", priority: .urgent)
            ])
        case .fifo:
            enqueue([event("同优先级 A"), event("同优先级 B"), event("同优先级 C")])
        case .deduplication:
            let id = UUID().uuidString
            enqueue([
                event("旧内容（不应出现）", id: id, priority: .low),
                event("另一条默认通知"),
                event("替换后的新内容", id: id, priority: .urgent)
            ])
        case .cancellation:
            enqueue([event("点击取消继续下一条", allowsCancel: true), event("取消后继续展示")])
        case .restrictedHost:
            showPlainPage(useTopStrategy: false)
        case .topHost:
            showPlainPage(useTopStrategy: true)
        case .fullScreen:
            var fullScreen = event("全屏通知", message: "关闭后，宿主重新出现，继续展示下一条。")
            fullScreen.presentationStyle = .fullScreen
            enqueue([fullScreen, event("宿主恢复后继续展示")])
        }
    }

    private func event(_ title: String, id: String = UUID().uuidString,
                       priority: PipelineAlertPriority = .default,
                       message: String = "关闭当前通知以继续。", allowsCancel: Bool = false) -> DemoAlertEvent {
        DemoAlertEvent(eventID: id, priority: priority, title: title, message: message,
                       allowsCancel: allowsCancel, onCreate: { [weak self] title in
            self?.appendLog("创建弹窗：\(title)")
        }, onAction: { [weak self] action in
            self?.appendLog(action)
        })
    }

    private func enqueue(_ events: [DemoAlertEvent]) {
        events.forEach { PipelineAlertPresenter.shared.enqueue($0) }
    }

    private func showPlainPage(useTopStrategy: Bool) {
        let page = DemoPlainViewController(useTopStrategy: useTopStrategy)
        page.onLog = { [weak self] message in self?.appendLog(message) }
        page.modalPresentationStyle = .fullScreen
        present(page, animated: true)
    }

    private func appendLog(_ message: String) {
        logView.text += "\n" + message
        logView.scrollRangeToVisible(NSRange(location: max(0, logView.text.utf16.count - 1), length: 1))
    }

    private func runChecks() -> Bool {
        let results = DemoChecks.run()
        logView.text = results.map { "\($0.passed ? "PASS" : "FAIL") \($0.name)" }.joined(separator: "\n")
        print(logView.text ?? "")
        let passed = results.allSatisfy(\.passed)
        print("PIPELINE_CHECKS: \(results.filter(\.passed).count)/\(results.count) \(passed ? "PASS" : "FAIL")")
        return passed
    }
}

private enum Scenario: Int, CaseIterable {
    case checks, sequential, priority, fifo, deduplication, cancellation, restrictedHost, topHost, fullScreen

    var title: String {
        switch self {
        case .checks: return "运行自动检查"
        case .sequential: return "逐个展示"
        case .priority: return "优先级排序"
        case .fifo: return "同优先级先进先出"
        case .deduplication: return "同 ID 替换"
        case .cancellation: return "取消后继续"
        case .restrictedHost: return "普通页面阻止通知"
        case .topHost: return "顶层 VC 策略"
        case .fullScreen: return "全屏关闭后恢复"
        }
    }

    var detail: String {
        switch self {
        case .checks: return "验证队列排序、去重、状态和宿主管理"
        case .sequential: return "预期：通知 1 → 通知 2 → 通知 3"
        case .priority: return "预期：紧急 → 高 → 默认 → 低"
        case .fifo: return "预期：A → B → C"
        case .deduplication: return "预期：新内容 → 另一条通知，旧内容不出现"
        case .cancellation: return "预期：取消和确认均能推进等待队列"
        case .restrictedHost: return "普通页面入队，返回宿主后才展示"
        case .topHost: return "普通页面也能接收，返回后恢复限定策略"
        case .fullScreen: return "验证宿主消失、重新出现后的连续展示"
        }
    }
}

private struct DemoAlertEvent: PipelineAlertEvent {
    let eventID: String
    var priority: PipelineAlertPriority = .default
    let timeStamp = Date()
    let title: String
    let message: String
    var allowsCancel = false
    var presentationStyle: UIModalPresentationStyle = .overFullScreen
    var onCreate: ((String) -> Void)?
    var onAction: ((String) -> Void)?

    func makeViewController() -> PiplineItemViewController {
        onCreate?(title)
        let config = NoteMsgViewController.MsgConfig(
            title: title, message: message, okText: "确认", cancelText: allowsCancel ? "取消" : nil,
            okHandle: { onAction?("确认：" + title) },
            cancelHandle: { onAction?("取消：" + title) }
        )
        let viewController = NoteMsgViewController(config: config)
        viewController.modalPresentationStyle = presentationStyle
        return viewController
    }
}

private final class DemoPlainViewController: UIViewController {
    let useTopStrategy: Bool
    var onLog: ((String) -> Void)?
    private var hasEnqueued = false

    init(useTopStrategy: Bool) {
        self.useTopStrategy = useTopStrategy
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        if useTopStrategy {
            PipelineAlertPresenter.shared.setStrategy(PipelineAlertTopViewControllerStrategy())
        }
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = useTopStrategy
            ? "普通页面：顶层 VC 策略\n通知会在此页面展示。"
            : "普通页面：限定宿主策略\n已入队的通知不会在此页面展示。\n返回后应连续展示两条通知。"
        let button = UIButton(type: .system)
        button.setTitle("返回宿主页面", for: .normal)
        button.addTarget(self, action: #selector(close), for: .touchUpInside)
        button.accessibilityIdentifier = "demo.returnToHost"
        let stack = UIStackView(arrangedSubviews: [label, button])
        stack.axis = .vertical
        stack.spacing = 24
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24)
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !hasEnqueued else { return }
        hasEnqueued = true
        for index in 1...2 {
            PipelineAlertPresenter.shared.enqueue(DemoAlertEvent(
                eventID: UUID().uuidString, title: "普通页面通知 \(index)",
                message: useTopStrategy ? "当前使用顶层 VC 展示策略。" : "已返回允许展示通知的宿主。",
                onCreate: { [weak self] title in self?.onLog?("创建弹窗：" + title) }
            ))
        }
        onLog?("普通页面已入队两条通知")
    }

    @objc private func close() {
        dismiss(animated: true)
    }
}

private enum DemoChecks {
    struct Result {
        let name: String
        let passed: Bool
    }

    static func run() -> [Result] {
        func event(_ id: String, _ priority: PipelineAlertPriority = .default, title: String? = nil) -> DemoAlertEvent {
            DemoAlertEvent(eventID: id, priority: priority, title: title ?? id, message: "队列检查")
        }
        func drain(_ scheduler: PipelineAlertScheduler) -> [PipelineAlertContext] {
            var contexts: [PipelineAlertContext] = []
            while let context = scheduler.nextContext() { contexts.append(context) }
            return contexts
        }
        var results: [Result] = []
        let empty = PipelineAlertScheduler()
        results.append(Result(name: "空队列返回 nil", passed: empty.nextContext() == nil))

        let priority = PipelineAlertScheduler()
        [event("low", .low), event("default"), event("high", .high), event("urgent", .urgent)]
            .forEach(priority.enqueue)
        results.append(Result(name: "四档优先级排序", passed: drain(priority).map { $0.event.eventID } == ["urgent", "high", "default", "low"]))

        let fifo = PipelineAlertScheduler()
        [event("a"), event("b"), event("c")].forEach(fifo.enqueue)
        results.append(Result(name: "同优先级保持接收顺序", passed: drain(fifo).map { $0.event.eventID } == ["a", "b", "c"]))

        let dedup = PipelineAlertScheduler()
        [event("a", .low, title: "旧内容"), event("b"), event("a", .urgent, title: "新内容")].forEach(dedup.enqueue)
        let replacements = drain(dedup)
        results.append(Result(name: "同 ID 替换数据并重新排序", passed:
            replacements.map { $0.event.eventID } == ["a", "b"] &&
            (replacements.first?.event as? DemoAlertEvent)?.title == "新内容"))
        results.append(Result(name: "取出事件仍保持等待状态", passed: replacements.allSatisfy { $0.state == .waiting }))

        let hostStrategy = PipelineAlertHostPresentationStrategy()
        let firstHost = UIViewController()
        let secondHost = UIViewController()
        hostStrategy.hostDidAppear(firstHost)
        hostStrategy.hostDidAppear(secondHost)
        hostStrategy.hostDidDisappear(firstHost)
        results.append(Result(name: "旧宿主消失不清除新宿主", passed: hostStrategy.presentingViewController() === secondHost))
        hostStrategy.hostDidDisappear(secondHost)
        results.append(Result(name: "当前宿主消失后停止展示", passed: hostStrategy.presentingViewController() == nil))
        var temporaryHost: UIViewController? = UIViewController()
        hostStrategy.hostDidAppear(temporaryHost!)
        temporaryHost = nil
        results.append(Result(name: "策略不持有宿主页面", passed: hostStrategy.presentingViewController() == nil))
        return results
    }
}
