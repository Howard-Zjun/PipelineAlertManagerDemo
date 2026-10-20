import UIKit
import PipelineAlertManager
import MyBaseExtension
import SnapKit

class NoteMsgViewController: PiplineItemViewController {

    struct MsgConfig {
        
        var title: String?
        
        var message: String
        
        var okText: String?
        
        var cancelText: String?
        
        var okHandle: (() -> Void)?
        
        var cancelHandle: (() -> Void)?
        
        var linkBlock: ((URL) -> Void)?
        
        init(title: String? = nil,
             message: String,
             okText: String? = nil,
             cancelText: String? = nil,
             okHandle: (() -> Void)? = nil,
             cancelHandle: (() -> Void)? = nil,
             linkBlock: ((URL) -> Void)? = nil) {
            self.title = title
            self.message = message
            self.okText = okText
            self.cancelText = cancelText
            self.okHandle = okHandle
            self.cancelHandle = cancelHandle
            self.linkBlock = linkBlock
        }
    }
    
    let config: MsgConfig
    
    var observation: NSKeyValueObservation?

    lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.layer.cornerRadius = 10
        contentView.backgroundColor = .white
        return contentView
    }()
    
    lazy var titleLabel = {
        let lab = UILabel()
        lab.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        lab.font = UIFont.boldSystemFont(ofSize: 17)
        lab.textAlignment = .center
        lab.numberOfLines = 0
        lab.text = config.title
        return lab
    }()
    
    lazy var messageTextView = {
        let messageTextView = DisRangeAbleTextView()
        if config.title != nil {
            messageTextView.font = .systemFont(ofSize: 17)
        } else {
            messageTextView.font = .systemFont(ofSize: 17, weight: .bold)
        }
        messageTextView.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        messageTextView.textAlignment = .center
        messageTextView.isEditable = false
        messageTextView.linkTextAttributes = .init()
        messageTextView.delegate = self
        messageTextView.text = config.message
        return messageTextView
    }()
    
    lazy var cancelBtn: UIButton = {
        let cancelBtn = UIButton()
        cancelBtn.backgroundColor = .white
        cancelBtn.layer.borderColor = UIColor(hex: 0x3F87FF).cgColor
        cancelBtn.layer.borderWidth = 1
        cancelBtn.layer.cornerRadius = 25
        cancelBtn.titleLabel?.font = .systemFont(ofSize: 16)
        cancelBtn.setTitleColor(.init(hex: 0x3F87FF), for: .normal)
        cancelBtn.addTarget(self, action: #selector(cancelHandle), for: .touchUpInside)
        return cancelBtn
    }()
    
    lazy var okBtn: UIButton = {
        let okBtn = UIButton()
        okBtn.backgroundColor = .init(hex: 0x3F87FF)
        okBtn.layer.cornerRadius = 25
        okBtn.titleLabel?.font = .systemFont(ofSize: 16)
        okBtn.setTitleColor(.white, for: .normal)
        okBtn.addTarget(self, action: #selector(okHandle), for: .touchUpInside)
        return okBtn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .init(hex: 0x000000, a: 0.65)
        view.addSubview(contentView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(messageTextView)
        if let cancelText = config.cancelText {
            cancelBtn.setTitle(cancelText, for: .normal)
            contentView.addSubview(cancelBtn)
        }
        if let okText = config.okText {
            okBtn.setTitle(okText, for: .normal)
            contentView.addSubview(okBtn)
        }
        
        contentView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(300)
        }
        titleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalToSuperview().inset(20)
        }
        messageTextView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(titleLabel.snp.bottom).offset(15)
            make.height.equalTo(0)
        }
        if config.cancelText != nil && config.okText != nil {
            cancelBtn.snp.makeConstraints { make in
                make.size.equalTo(CGSize(width: 100, height: 50))
                make.bottom.equalToSuperview().inset(25)
                make.top.equalTo(messageTextView.snp.bottom).offset(25)
                make.centerX.equalToSuperview().offset(-60)
            }
            okBtn.snp.makeConstraints { make in
                make.size.equalTo(CGSize(width: 100, height: 50))
                make.bottom.equalToSuperview().inset(25)
                make.top.equalTo(messageTextView.snp.bottom).offset(25)
                make.centerX.equalToSuperview().offset(60)
            }
        } else if config.cancelText != nil {
            cancelBtn.snp.makeConstraints { make in
                make.size.equalTo(CGSize(width: 100, height: 50))
                make.bottom.equalToSuperview().inset(25)
                make.top.equalTo(messageTextView.snp.bottom).offset(25)
                make.centerX.equalToSuperview()
            }
        } else if config.okText != nil {
            okBtn.snp.makeConstraints { make in
                make.size.equalTo(CGSize(width: 100, height: 50))
                make.bottom.equalToSuperview().inset(25)
                make.top.equalTo(messageTextView.snp.bottom).offset(25)
                make.centerX.equalToSuperview()
            }
        }
        
        observation = messageTextView.observe(\.contentSize, options: [.initial, .new]) { [weak self] tv, change in
            guard let self = self else { return }
            
            let aHeight = messageTextView.contentSize.height
            messageTextView.snp.updateConstraints { make in
                make.height.equalTo(aHeight > 500 ? 500 : aHeight)
            }
        }
    }
    
    deinit {
        observation?.invalidate()
        observation = nil
    }
    
    init(config: MsgConfig) {
        self.config = config
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NoteMsgViewController {
    
    @objc func okHandle() {
        dismiss(animated: true, completion: config.okHandle)
    }
    
    @objc func cancelHandle() {
        dismiss(animated: true, completion: config.cancelHandle)
    }
}

extension NoteMsgViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        config.linkBlock?(URL)
        return true
    }
}

class DisRangeAbleTextView: UITextView {
    
    override var canBecomeFirstResponder: Bool {
        false
    }
}
