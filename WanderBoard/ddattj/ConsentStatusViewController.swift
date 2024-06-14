//
//  ConsentStatusViewController.swift
//  WanderBoard
//
//  Created by David Jang on 6/14/24.
//

import UIKit
import SnapKit
import Then
import FirebaseFirestore
import FirebaseAuth

class ConsentStatusViewController: UIViewController {
    
    var agreedToMarketing = false
    var agreedToThirdParty = false
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .none
        return tableView
    }()

    private let modifyButton: UIButton = {
        let button = UIButton(type: .system).then {
            $0.setTitle("변경", for: .normal)
            $0.setTitleColor(UIColor.white, for: .normal)
            $0.backgroundColor = .black
            $0.layer.cornerRadius = 10
        }
        return button
    }()

    private let saveButton: UIButton = {
        let button = UIButton(type: .system).then {
            $0.setTitle("저장", for: .normal)
            $0.setTitleColor(UIColor.white, for: .normal)
            $0.backgroundColor = .black
            $0.layer.cornerRadius = 10
            $0.isHidden = true
        }
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        view.addSubview(modifyButton)
        view.addSubview(saveButton)
        
        navigationItem.largeTitleDisplayMode = .never

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

        modifyButton.snp.makeConstraints {
            $0.left.equalTo(view).inset(32)
            $0.right.equalTo(view).inset(32)
            $0.height.equalTo(50)
            $0.bottom.equalTo(view).inset(60)
        }

        saveButton.snp.makeConstraints {
            $0.left.equalTo(view).inset(32)
            $0.right.equalTo(view).inset(32)
            $0.height.equalTo(50)
            $0.bottom.equalTo(view).inset(60)
        }

        modifyButton.addTarget(self, action: #selector(modifyButtonTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        navigationController?.navigationBar.largeContentTitle = .none
        
        fetchConsentStatus()
    }

    private func fetchConsentStatus() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userRef = Firestore.firestore().collection("users").document(uid)
        
        userRef.getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                self.agreedToMarketing = data?["agreedToMarketing"] as? Bool ?? false
                self.agreedToThirdParty = data?["agreedToThirdParty"] as? Bool ?? false
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } else {
                print("Document does not exist")
            }
        }
    }

    @objc private func modifyButtonTapped() {
        modifyButton.isHidden = true
        saveButton.isHidden = false
        tableView.reloadData()
    }
    
    @objc private func saveButtonTapped() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userRef = Firestore.firestore().collection("users").document(uid)
        
        userRef.updateData([
            "agreedToMarketing": agreedToMarketing,
            "agreedToThirdParty": agreedToThirdParty
        ]) { error in
            if let error = error {
                print("Error updating consent: \(error)")
            } else {
                DispatchQueue.main.async {
                    self.modifyButton.isHidden = false
                    self.saveButton.isHidden = true
                    self.tableView.reloadData()
                }
            }
        }
    }
}

extension ConsentStatusViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PrivacyPolicyTableViewCell.identifier, for: indexPath) as! PrivacyPolicyTableViewCell
        let agreeStatus = indexPath.section == 0 ? agreedToMarketing : agreedToThirdParty
        cell.configure(for: indexPath.section + 2, delegate: self, agreeStatus: agreeStatus, disagreeStatus: !agreeStatus)
        cell.isUserInteractionEnabled = !saveButton.isHidden
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: PrivacyPolicySectionHeaderView.identifier) as! PrivacyPolicySectionHeaderView
        header.configure(for: section + 2, isCompleted: true)
        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 46
    }
}

extension ConsentStatusViewController: PrivacyPolicyTableViewCellDelegate {
    func didChangeCompletionStatus(for section: Int, completed: Bool) {
        if section == 2 {
            agreedToMarketing = completed
        } else if section == 3 {
            agreedToThirdParty = completed
        }
    }
}
