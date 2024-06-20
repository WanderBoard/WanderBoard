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
    
    var isModal: Bool = true
    private var sectionExpandedStatus = [false, false]
    
    private let topBar: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.layer.cornerRadius = 2
        return view
    }()
    
    let bottomLogo = UIImageView().then {
        $0.image = UIImage(named: "logo")?.withTintColor(.lightgray)
    }
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .none
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PrivacyPolicyTableViewCell.self, forCellReuseIdentifier: PrivacyPolicyTableViewCell.identifier)
        tableView.register(PrivacyPolicySectionHeaderView.self, forHeaderFooterViewReuseIdentifier: PrivacyPolicySectionHeaderView.identifier)
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.showsVerticalScrollIndicator = false
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        
        view.addSubview(topBar)
        view.addSubview(tableView)
        view.addSubview(bottomLogo)
        
        if isModal {
            view.addSubview(topBar)
            topBar.snp.makeConstraints {
                $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
                $0.centerX.equalTo(view)
                $0.width.equalTo(60)
                $0.height.equalTo(4)
            }
            tableView.snp.makeConstraints {
                $0.top.equalTo(topBar.snp.bottom).offset(16)
                $0.left.equalTo(view).offset(32)
                $0.right.equalTo(view).offset(-32)
                $0.bottom.equalTo(view).offset(-80)
            }
        } else {
            tableView.snp.makeConstraints {
                $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
                $0.left.equalTo(view).offset(32)
                $0.right.equalTo(view).offset(-32)
                $0.bottom.equalTo(view).offset(-80)
            }
        }
        
        bottomLogo.snp.makeConstraints {
            $0.bottom.equalTo(view.snp.bottom).offset(-36)
            $0.width.equalTo(135)
            $0.height.equalTo(18)
            $0.centerX.equalToSuperview()
        }
    }
}

extension TermsOfServiceViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionExpandedStatus[section] ? 1 : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PrivacyPolicyTableViewCell.identifier, for: indexPath) as! PrivacyPolicyTableViewCell
        let scripts = [
            PrivacyPolicyScripts.termsOfService,
            PrivacyPolicyScripts.privacyPolicy
        ]
        cell.configure(for: indexPath.section, delegate: nil, scriptText: scripts[indexPath.section], agreeStatus: false, disagreeStatus: false, isEnabled: false)
        cell.agreeCheckBox.isHidden = true
        cell.disagreeCheckBox.isHidden = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: PrivacyPolicySectionHeaderView.identifier) as! PrivacyPolicySectionHeaderView
        header.configure(for: section, isCompleted: false, isExpanded: sectionExpandedStatus[section])
        header.delegate = self
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 46
    }
}

extension TermsOfServiceViewController: PrivacyPolicySectionHeaderViewDelegate {
    func didTapHeader(in section: Int) {
        sectionExpandedStatus[section].toggle()
        tableView.reloadSections(IndexSet(integer: section), with: .automatic)
    }
}
