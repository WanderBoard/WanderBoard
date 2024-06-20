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
    private var sectionExpandedStatus = [false, false, false, false]
    
    private let topBar: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.layer.cornerRadius = 2
        return view
    }()
    
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
    
    private let allAgreeCheckbox = UIButton(type: .custom)
    private let mandatoryAgreeCheckbox = UIButton(type: .custom)
    private let optionalAgreeCheckbox = UIButton(type: .custom)


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(topBar)
        view.addSubview(tableView)
        view.addSubview(agreeButton)
        
        setupCheckboxes()
        setupConstraints()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PrivacyPolicyTableViewCell.self, forCellReuseIdentifier: PrivacyPolicyTableViewCell.identifier)
        tableView.register(PrivacyPolicySectionHeaderView.self, forHeaderFooterViewReuseIdentifier: PrivacyPolicySectionHeaderView.identifier)
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.showsVerticalScrollIndicator = false
        
//        topBar.snp.makeConstraints {
//            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
//            $0.centerX.equalTo(view)
//            $0.width.equalTo(60)
//            $0.height.equalTo(4)
//        }
//
//        tableView.snp.makeConstraints {
//            $0.top.equalTo(topBar.snp.bottom).offset(16)
//            $0.left.equalTo(view).offset(32)
//            $0.right.equalTo(view).offset(-32)
//            $0.bottom.equalTo(view).offset(-100)
//        }
//
//        agreeButton.snp.makeConstraints {
//            $0.left.equalTo(view).inset(32)
//            $0.right.equalTo(view).inset(32)
//            $0.height.equalTo(50)
//            $0.bottom.equalTo(view).inset(60)
//        }

        agreeButton.addTarget(self, action: #selector(agreeButtonTapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        topBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            $0.centerX.equalTo(view)
            $0.width.equalTo(60)
            $0.height.equalTo(4)
        }

        allAgreeCheckbox.snp.makeConstraints {
            $0.top.equalTo(topBar.snp.bottom).offset(32)
            $0.left.equalTo(view).offset(32)
        }

        mandatoryAgreeCheckbox.snp.makeConstraints {
            $0.top.equalTo(allAgreeCheckbox.snp.bottom).offset(16)
            $0.left.equalTo(view).offset(32)
        }

        optionalAgreeCheckbox.snp.makeConstraints {
            $0.top.equalTo(mandatoryAgreeCheckbox.snp.bottom).offset(8)
            $0.left.equalTo(view).offset(32)
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(optionalAgreeCheckbox.snp.bottom).offset(16)
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
    }
    
    private func setupCheckboxes() {
        allAgreeCheckbox.setTitle("  모두 동의", for: .normal)
        allAgreeCheckbox.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold) // 수정: 폰트 사이즈 및 두께 설정
        allAgreeCheckbox.setTitleColor(.black, for: .normal)
        allAgreeCheckbox.setImage(UIImage(systemName: "circle")?.withRenderingMode(.alwaysTemplate), for: .normal)
        allAgreeCheckbox.setImage(UIImage(systemName: "checkmark.circle.fill")?.withRenderingMode(.alwaysTemplate), for: .selected)
        allAgreeCheckbox.tintColor = .black
        allAgreeCheckbox.addTarget(self, action: #selector(allAgreeTapped), for: .touchUpInside)
        view.addSubview(allAgreeCheckbox)

        mandatoryAgreeCheckbox.setTitle(" (필수) 이용약관 및 개인정보처리방침", for: .normal)
        mandatoryAgreeCheckbox.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular) // 수정: 폰트 사이즈 및 두께 설정
        mandatoryAgreeCheckbox.setTitleColor(.black, for: .normal)
        mandatoryAgreeCheckbox.setImage(UIImage(systemName: "circle")?.withRenderingMode(.alwaysTemplate), for: .normal)
        mandatoryAgreeCheckbox.setImage(UIImage(systemName: "checkmark.circle.fill")?.withRenderingMode(.alwaysTemplate), for: .selected)
        mandatoryAgreeCheckbox.tintColor = .black
        mandatoryAgreeCheckbox.addTarget(self, action: #selector(mandatoryAgreeTapped), for: .touchUpInside)
        view.addSubview(mandatoryAgreeCheckbox)

        optionalAgreeCheckbox.setTitle(" (선택) 마케팅활용동의 외", for: .normal)
        optionalAgreeCheckbox.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular) // 수정: 폰트 사이즈 및 두께 설정
        optionalAgreeCheckbox.setTitleColor(.black, for: .normal)
        optionalAgreeCheckbox.setImage(UIImage(systemName: "circle")?.withRenderingMode(.alwaysTemplate), for: .normal)
        optionalAgreeCheckbox.setImage(UIImage(systemName: "checkmark.circle.fill")?.withRenderingMode(.alwaysTemplate), for: .selected)
        optionalAgreeCheckbox.tintColor = .black
        optionalAgreeCheckbox.addTarget(self, action: #selector(optionalAgreeTapped), for: .touchUpInside)
        view.addSubview(optionalAgreeCheckbox)
    }

    
    @objc private func allAgreeTapped() {
        let isSelected = !allAgreeCheckbox.isSelected
        allAgreeCheckbox.isSelected = isSelected
        mandatoryAgreeCheckbox.isSelected = isSelected
        optionalAgreeCheckbox.isSelected = isSelected

        for i in 0..<4 {
            sectionAgreeStatus[i] = isSelected
            sectionDisagreeStatus[i] = !isSelected
        }
        tableView.reloadData()
        checkCompletionStatus()
    }

    @objc private func mandatoryAgreeTapped() {
        let isSelected = !mandatoryAgreeCheckbox.isSelected
        mandatoryAgreeCheckbox.isSelected = isSelected

        sectionAgreeStatus[0] = isSelected
        sectionAgreeStatus[1] = isSelected  // 수정: 0번과 1번 셀 모두 업데이트
        sectionDisagreeStatus[0] = !isSelected
        sectionDisagreeStatus[1] = !isSelected  // 수정: 0번과 1번 셀 모두 업데이트

        // 수정: 필수 항목이 체크되었는지 여부에 따라 전체 동의 체크박스 상태 변경
        if isSelected {
            allAgreeCheckbox.isSelected = sectionAgreeStatus[2] && sectionAgreeStatus[3] && sectionAgreeStatus[0] && sectionAgreeStatus[1]
        } else {
            allAgreeCheckbox.isSelected = false
        }

        tableView.reloadData()  // 기존 reloadSections에서 reloadData로 변경하여 전체 테이블뷰 갱신
        checkCompletionStatus()
    }


    @objc private func optionalAgreeTapped() {
        let isSelected = !optionalAgreeCheckbox.isSelected
        optionalAgreeCheckbox.isSelected = isSelected

        sectionAgreeStatus[2] = isSelected
        sectionAgreeStatus[3] = isSelected
        sectionDisagreeStatus[2] = !isSelected
        sectionDisagreeStatus[3] = !isSelected

        // 업데이트: 선택 항목이 체크되었는지 여부에 따라 전체 동의 체크박스 상태 변경
        if isSelected {
            allAgreeCheckbox.isSelected = sectionAgreeStatus[0] && sectionAgreeStatus[1]
        } else {
            allAgreeCheckbox.isSelected = false
        }

        tableView.reloadData()
        checkCompletionStatus()
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
        return sectionExpandedStatus[section] ? 1 : 0 // 수정 사항: 확장 상태에 따라 셀 수 결정
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PrivacyPolicyTableViewCell.identifier, for: indexPath) as! PrivacyPolicyTableViewCell
        let scripts = [
            PrivacyPolicyScripts.termsOfService,
            PrivacyPolicyScripts.privacyPolicy,
            PrivacyPolicyScripts.marketingConsent,
            PrivacyPolicyScripts.thirdPartySharing
        ]
        cell.configure(for: indexPath.section, delegate: self, scriptText: scripts[indexPath.section], agreeStatus: sectionAgreeStatus[indexPath.section], disagreeStatus: sectionDisagreeStatus[indexPath.section], isEnabled: true)
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: PrivacyPolicySectionHeaderView.identifier) as! PrivacyPolicySectionHeaderView
        header.configure(for: section, isCompleted: sectionCompletionStatus[section], isExpanded: sectionExpandedStatus[section])
        header.delegate = self
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 46
    }
}

extension PrivacyPolicyViewController: PrivacyPolicySectionHeaderViewDelegate, PrivacyPolicyTableViewCellDelegate {
    func didTapHeader(in section: Int) {
        sectionExpandedStatus[section].toggle()
        tableView.reloadSections(IndexSet(integer: section), with: .automatic)
    }
    
    func didChangeCompletionStatus(for section: Int, completed: Bool) {
        sectionAgreeStatus[section] = completed
        sectionDisagreeStatus[section] = !completed

        // 수정: 필수 체크박스 상태 업데이트
        if section == 0 || section == 1 {
            mandatoryAgreeCheckbox.isSelected = sectionAgreeStatus[0] && sectionAgreeStatus[1]
        }
        
        // 수정: 선택 체크박스 상태 업데이트
        if section == 2 || section == 3 {
            optionalAgreeCheckbox.isSelected = sectionAgreeStatus[2] && sectionAgreeStatus[3]
        }

        // 모든 항목이 선택되었는지 여부에 따라 전체 동의 체크박스 상태 변경
        allAgreeCheckbox.isSelected = sectionAgreeStatus.allSatisfy { $0 }
        
        tableView.reloadSections(IndexSet(integer: section), with: .automatic)
        checkCompletionStatus()
    }
}

