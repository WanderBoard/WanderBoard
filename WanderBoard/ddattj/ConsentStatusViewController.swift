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
    var initialAgreedToMarketing = false
    var initialAgreedToThirdParty = false
    
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
            $0.isEnabled = false
        }
        return button
    }()

    private let cancelButton: UIButton = {
        let button = UIButton(type: .system).then {
            $0.setTitle("취소", for: .normal)
            $0.setTitleColor(UIColor.white, for: .normal)
            $0.backgroundColor = .darkGray
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
        view.addSubview(cancelButton)
        
        navigationItem.largeTitleDisplayMode = .never

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PrivacyPolicyTableViewCell.self, forCellReuseIdentifier: PrivacyPolicyTableViewCell.identifier)
        tableView.register(PrivacyPolicySectionHeaderView.self, forHeaderFooterViewReuseIdentifier: PrivacyPolicySectionHeaderView.identifier)
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.showsVerticalScrollIndicator = false

        tableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
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

        cancelButton.snp.makeConstraints {
            $0.left.equalTo(view).inset(32)
            $0.right.equalTo(view).inset(32)
            $0.height.equalTo(50)
            $0.bottom.equalTo(view).inset(60)
        }

        modifyButton.addTarget(self, action: #selector(modifyButtonTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        modifyButton.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
        modifyButton.addTarget(self, action: #selector(buttonTouchUp(_:)), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
        saveButton.addTarget(self, action: #selector(buttonTouchUp(_:)), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
        cancelButton.addTarget(self, action: #selector(buttonTouchUp(_:)), for: .touchUpInside)
        
        fetchConsentStatus()
    }

    private func fetchConsentStatus() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("users").document(uid).getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                self.agreedToMarketing = data?["agreedToMarketing"] as? Bool ?? false
                self.agreedToThirdParty = data?["agreedToThirdParty"] as? Bool ?? false
                self.initialAgreedToMarketing = self.agreedToMarketing
                self.initialAgreedToThirdParty = self.agreedToThirdParty
                
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
        cancelButton.isHidden = false
        saveButton.isHidden = true
        tableView.reloadData()
    }

    @objc private func cancelButtonTapped() {
        agreedToMarketing = initialAgreedToMarketing
        agreedToThirdParty = initialAgreedToThirdParty
        modifyButton.isHidden = false
        cancelButton.isHidden = true
        saveButton.isHidden = true
        tableView.reloadData()
        
        self.navigationController?.popViewController(animated: true)
    }

    @objc private func saveButtonTapped() {
        var message = ""
        if agreedToMarketing != initialAgreedToMarketing {
            message += "마케팅 동의: \(agreedToMarketing ? "동의함" : "동의안함")\n"
        }
        if agreedToThirdParty != initialAgreedToThirdParty {
            message += "제3자 제공 동의: \(agreedToThirdParty ? "동의함" : "동의안함")"
        }
        showAlert(title: "변경 사항", message: message) {
            self.updateConsentStatus()
        }
    }

    private func updateConsentStatus() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userRef = Firestore.firestore().collection("users").document(uid)
        
        let dataToUpdate: [String: Any] = [
            "agreedToMarketing": agreedToMarketing,
            "agreedToThirdParty": agreedToThirdParty
        ]
        
        userRef.setData(dataToUpdate, merge: true) { error in
            if let error = error {
                print("Error updating consent: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    self.modifyButton.isHidden = false
                    self.cancelButton.isHidden = true
                    self.saveButton.isHidden = true
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }

    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default) { _ in
            completion?()
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

    @objc private func buttonTouchDown(_ sender: UIButton) {
        animateButton(sender, transform: CGAffineTransform(scaleX: 0.95, y: 0.95))
    }

    @objc private func buttonTouchUp(_ sender: UIButton) {
        animateButton(sender, transform: CGAffineTransform.identity)
    }

    private func animateButton(_ button: UIButton, transform: CGAffineTransform) {
        UIView.animate(withDuration: 0.1, animations: {
            button.transform = transform
        })
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
        let isEnabled = cancelButton.isHidden == false
        cell.configure(for: indexPath.section + 2, delegate: self, agreeStatus: agreeStatus, disagreeStatus: !agreeStatus, isEnabled: isEnabled)
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let sectionHeaderHeight: CGFloat = 46
        if scrollView.contentOffset.y <= sectionHeaderHeight && scrollView.contentOffset.y >= 0 {
            scrollView.contentInset = UIEdgeInsets(top: -scrollView.contentOffset.y, left: 0, bottom: 0, right: 0)
        } else if scrollView.contentOffset.y >= sectionHeaderHeight {
            scrollView.contentInset = UIEdgeInsets(top: -sectionHeaderHeight, left: 0, bottom: 0, right: 0)
        }
    }
}

extension ConsentStatusViewController: PrivacyPolicyTableViewCellDelegate {
    func didChangeCompletionStatus(for section: Int, completed: Bool) {
        if section == 2 {
            agreedToMarketing = completed
        } else if section == 3 {
            agreedToThirdParty = completed
        }
        
        if agreedToMarketing == initialAgreedToMarketing && agreedToThirdParty == initialAgreedToThirdParty {
            cancelButton.isHidden = false
            saveButton.isHidden = true
        } else {
            cancelButton.isHidden = true
            saveButton.isHidden = false
            saveButton.isEnabled = true
        }
    }
}
