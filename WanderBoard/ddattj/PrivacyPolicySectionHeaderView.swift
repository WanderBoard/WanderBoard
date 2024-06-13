//
//  PrivacyPolicySectionHeaderView.swift
//  WanderBoard
//
//  Created by David Jang on 6/13/24.
//


import UIKit
import SnapKit

class PrivacyPolicySectionHeaderView: UITableViewHeaderFooterView {
    static let identifier = "PrivacyPolicySectionHeaderView"

    weak var delegate: PrivacyPolicySectionHeaderViewDelegate?
    private let titleLabel = UILabel()
    private var section: Int = 0
    private var isCompleted: Bool = false

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        contentView.addSubview(titleLabel)
        contentView.backgroundColor = .babygray
        contentView.layer.cornerRadius = 10
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(headerTapped))
        addGestureRecognizer(tapGesture)

        titleLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
        }
    }

    func configure(for section: Int, isCompleted: Bool) {
        self.section = section
        self.isCompleted = isCompleted
        let titles = ["이용약관*", "*개인정보처리방침*", "마케팅활용동의 및 광고수신동의", "개인정보 제3자 제공동의"]
        titleLabel.text = titles[section]
    }

    @objc private func headerTapped() {
        delegate?.didTapHeader(in: section)
    }
}

protocol PrivacyPolicySectionHeaderViewDelegate: AnyObject {
    func didTapHeader(in section: Int)
}

