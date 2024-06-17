//
//  TermsOfServiceViewController.swift
//  WanderBoard
//
//  Created by David Jang on 6/16/24.
//

import UIKit
import SnapKit
import Then

class TermsOfServiceViewController: UIViewController {
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .none
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)

        navigationItem.largeTitleDisplayMode = .never
//        navigationItem.title = "이용약관 및 개인정보처리방침"

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
    }
}

extension TermsOfServiceViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PrivacyPolicyTableViewCell.identifier, for: indexPath) as! PrivacyPolicyTableViewCell
        cell.configure(for: indexPath.section, delegate: nil, agreeStatus: false, disagreeStatus: false, isEnabled: false)
        cell.agreeCheckBox.isHidden = true // Hide the agree button
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: PrivacyPolicySectionHeaderView.identifier) as! PrivacyPolicySectionHeaderView
        header.configure(for: section, isCompleted: false)
        header.delegate = self
        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 46
    }
}

extension TermsOfServiceViewController: PrivacyPolicySectionHeaderViewDelegate {
    func didTapHeader(in section: Int) {

    }
}
