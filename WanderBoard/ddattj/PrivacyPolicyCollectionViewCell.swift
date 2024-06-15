//
//  PrivacyPolicyCollectionViewCell.swift
//  WanderBoard
//
//  Created by 이시안 on 6/3/24.
//

import UIKit
import SnapKit

protocol PrivacyPolicyTableViewCellDelegate: AnyObject {
    func didChangeCompletionStatus(for section: Int, completed: Bool)
}

class PrivacyPolicyTableViewCell: UITableViewCell {
    static let identifier = "PrivacyPolicyTableViewCell"
    
    weak var delegate: PrivacyPolicyTableViewCellDelegate?

    let scriptLabel = UILabel()
    let agreeCheckBox = UIButton(type: .custom)
    let disagreeCheckBox = UIButton(type: .custom)
    private var section: Int = 0
    private var isEnabled: Bool = false

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        contentView.backgroundColor = .white
        scriptLabel.numberOfLines = 0
        scriptLabel.font = UIFont.systemFont(ofSize: 13)
        scriptLabel.textColor = .label
        scriptLabel.lineBreakMode = .byWordWrapping

        contentView.addSubview(scriptLabel)
        contentView.addSubview(agreeCheckBox)
        contentView.addSubview(disagreeCheckBox)

        scriptLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16)
            $0.left.equalToSuperview().inset(16)
            $0.right.equalToSuperview().inset(16)
        }

        agreeCheckBox.setTitle("동의함", for: .normal)
        agreeCheckBox.setTitleColor(.black, for: .normal)
        agreeCheckBox.setImage(UIImage(systemName: "square"), for: .normal)
        agreeCheckBox.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
//        agreeCheckBox.semanticContentAttribute = .forceRightToLeft
        agreeCheckBox.addTarget(self, action: #selector(agreeTapped), for: .touchUpInside)
        
        agreeCheckBox.snp.makeConstraints {
            $0.top.equalTo(scriptLabel.snp.bottom).offset(16)
            $0.right.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(16)
        }
        
        disagreeCheckBox.setTitle("동의안함", for: .normal)
        disagreeCheckBox.setTitleColor(.black, for: .normal)
        disagreeCheckBox.setImage(UIImage(systemName: "square"), for: .normal)
        disagreeCheckBox.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
//        agreeCheckBox.semanticContentAttribute = .forceRightToLeft
        disagreeCheckBox.addTarget(self, action: #selector(disagreeTapped), for: .touchUpInside)
        
        disagreeCheckBox.snp.makeConstraints {
            $0.centerY.equalTo(agreeCheckBox)
            $0.right.equalTo(agreeCheckBox.snp.left).offset(-8)
        }
        
        disagreeCheckBox.isHidden = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        scriptLabel.preferredMaxLayoutWidth = contentView.frame.width - 32
        super.layoutSubviews()
        contentView.layoutIfNeeded()
        scriptLabel.layoutIfNeeded()
    }

    func configure(for section: Int, delegate: PrivacyPolicyTableViewCellDelegate?, agreeStatus: Bool, disagreeStatus: Bool, isEnabled: Bool) {
        self.section = section
        self.delegate = delegate
        self.isEnabled = isEnabled

        let scripts = [
            PrivacyPolicyScripts.termsOfService,
            PrivacyPolicyScripts.privacyPolicy,
            PrivacyPolicyScripts.marketingConsent,
            PrivacyPolicyScripts.thirdPartySharing
        ]

        scriptLabel.text = scripts[section]

        agreeCheckBox.isSelected = agreeStatus
        disagreeCheckBox.isSelected = disagreeStatus

        agreeCheckBox.isUserInteractionEnabled = isEnabled
        disagreeCheckBox.isUserInteractionEnabled = isEnabled

        if isEnabled {
            agreeCheckBox.setTitleColor(.black, for: .normal)
            disagreeCheckBox.setTitleColor(.black, for: .normal)
            agreeCheckBox.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
            agreeCheckBox.setImage(UIImage(systemName: "square"), for: .normal)
            disagreeCheckBox.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
            disagreeCheckBox.setImage(UIImage(systemName: "square"), for: .normal)
        } else {
            agreeCheckBox.setTitleColor(.black, for: .normal)
            disagreeCheckBox.setTitleColor(.black, for: .normal)
            agreeCheckBox.setImage(UIImage(systemName: "checkmark.square.fill")?.withTintColor(UIColor.lightGray, renderingMode: .alwaysOriginal), for: .selected)
            agreeCheckBox.setImage(UIImage(systemName: "square")?.withTintColor(UIColor.lightGray, renderingMode: .alwaysOriginal), for: .normal)
            disagreeCheckBox.setImage(UIImage(systemName: "checkmark.square.fill")?.withTintColor(UIColor.lightGray, renderingMode: .alwaysOriginal), for: .selected)
            disagreeCheckBox.setImage(UIImage(systemName: "square")?.withTintColor(UIColor.lightGray, renderingMode: .alwaysOriginal), for: .normal)
        }

        if section == 2 || section == 3 {
            agreeCheckBox.setTitle("동의함", for: .normal)
            disagreeCheckBox.setTitle("동의안함", for: .normal)
            disagreeCheckBox.isHidden = false
        } else {
            agreeCheckBox.setTitle("동의함", for: .normal)
            disagreeCheckBox.isHidden = true
        }
    }

    
    private func getScriptForSection(_ section: Int) -> String {
        switch section {
        case 0:
            return PrivacyPolicyScripts.termsOfService
        case 1:
            return PrivacyPolicyScripts.privacyPolicy
        case 2:
            return PrivacyPolicyScripts.marketingConsent
        case 3:
            return PrivacyPolicyScripts.thirdPartySharing
        default:
            return ""
        }
    }
    
    @objc private func agreeTapped() {
        if !isEnabled { return }

        if agreeCheckBox.isSelected {
            return
        }

        agreeCheckBox.isSelected = true
        disagreeCheckBox.isSelected = false

        UIView.animate(withDuration: 0.2, animations: {
            self.agreeCheckBox.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }, completion: { _ in
            UIView.animate(withDuration: 0.2, animations: {
                self.agreeCheckBox.transform = CGAffineTransform.identity
            }, completion: { _ in
                if self.section < 2 {
                    self.delegate?.didChangeCompletionStatus(for: self.section, completed: true)
                } else {
                    self.delegate?.didChangeCompletionStatus(for: self.section, completed: true)
                }
            })
        })
    }

    @objc private func disagreeTapped() {
        if !isEnabled { return }

        if disagreeCheckBox.isSelected {
            return
        }

        disagreeCheckBox.isSelected = true
        agreeCheckBox.isSelected = false

        UIView.animate(withDuration: 0.2, animations: {
            self.disagreeCheckBox.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }, completion: { _ in
            UIView.animate(withDuration: 0.2, animations: {
                self.disagreeCheckBox.transform = CGAffineTransform.identity
            }, completion: { _ in
                self.delegate?.didChangeCompletionStatus(for: self.section, completed: false)
            })
        })
    }
}
