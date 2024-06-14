//
//  PrivacyPolicyViewController.swift
//  WanderBoard
//
//  Created by 이시안 on 5/29/24.
//

import UIKit
import SnapKit
import Then

class PrivacyPolicyViewController: BaseViewController {
    var completionHandler: ((Bool, Bool, Bool, Bool) -> Void)?
    
    private var agreedToTerms = false
    private var agreedToPrivacyPolicy = false
    private var agreedToMarketing = false
    private var agreedToThirdParty = false

    private var sectionCompletionStatus = [true, false, false, false]
    private var sectionAgreeStatus = [false, false, false, false]
    private var sectionDisagreeStatus = [false, false, true, true]
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .none
        return tableView
    }()

    private let agreeButton: UIButton = {
        let button = UIButton(type: .system).then {
            $0.setTitle("확인", for: .normal)
            $0.setTitleColor(UIColor.white, for: .normal)
            $0.backgroundColor = .lightGray
            $0.layer.cornerRadius = 10
            $0.isEnabled = false
        }
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        view.addSubview(agreeButton)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PrivacyPolicyTableViewCell.self, forCellReuseIdentifier: PrivacyPolicyTableViewCell.identifier)
        tableView.register(PrivacyPolicySectionHeaderView.self, forHeaderFooterViewReuseIdentifier: PrivacyPolicySectionHeaderView.identifier)
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.showsVerticalScrollIndicator = false

        tableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(32)
            $0.left.equalTo(view).offset(32)
            $0.right.equalTo(view).offset(-32)
            $0.bottom.equalTo(view).offset(-100)
        }

        agreeButton.snp.makeConstraints {
            $0.left.equalTo(view).inset(32)
            $0.right.equalTo(view).inset(32)
            $0.height.equalTo(50)
            $0.bottom.equalTo(view).inset(60)
        }

        agreeButton.addTarget(self, action: #selector(agreeButtonTapped), for: .touchUpInside)
    }

    @objc private func agreeButtonTapped() {
        completionHandler?(sectionAgreeStatus[0], sectionAgreeStatus[1], sectionAgreeStatus[2], sectionAgreeStatus[3])
        dismiss(animated: true, completion: nil)
    }

    private func checkCompletionStatus() {
        let isAllRequiredSectionsCompleted = sectionAgreeStatus[0] && sectionAgreeStatus[1]
        agreeButton.isEnabled = isAllRequiredSectionsCompleted
        agreeButton.backgroundColor = agreeButton.isEnabled ? .black : .lightGray
    }
}

extension PrivacyPolicyViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionCompletionStatus[section] ? 1 : 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PrivacyPolicyTableViewCell.identifier, for: indexPath) as! PrivacyPolicyTableViewCell
        cell.configure(for: indexPath.section, delegate: self, agreeStatus: sectionAgreeStatus[indexPath.section], disagreeStatus: sectionDisagreeStatus[indexPath.section])
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: PrivacyPolicySectionHeaderView.identifier) as! PrivacyPolicySectionHeaderView
        header.configure(for: section, isCompleted: sectionCompletionStatus[section])
        header.delegate = self
        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 46
    }
}

extension PrivacyPolicyViewController: PrivacyPolicySectionHeaderViewDelegate, PrivacyPolicyTableViewCellDelegate {
    func didTapHeader(in section: Int) {
        for index in 0..<sectionCompletionStatus.count {
            sectionCompletionStatus[index] = false
        }
        sectionCompletionStatus[section].toggle()
        tableView.reloadData()
        checkCompletionStatus()
    }

    func didChangeCompletionStatus(for section: Int, completed: Bool) {
        sectionAgreeStatus[section] = completed
        sectionDisagreeStatus[section] = !completed
        sectionCompletionStatus[section] = false
        
        if section < sectionCompletionStatus.count - 1 {
            sectionCompletionStatus[section + 1] = true
        }
        
        tableView.reloadData()
        checkCompletionStatus()
    }
}
