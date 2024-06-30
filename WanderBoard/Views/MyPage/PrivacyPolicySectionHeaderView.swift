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
    private let arrowImageView = UIImageView()
    private var section: Int = 0
    private var isCompleted: Bool = false
    private var isExpanded: Bool = false

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupViews()
        updateColor()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        let titleStackView = UIStackView()
        titleStackView.axis = .horizontal
        titleStackView.alignment = .center
        titleStackView.distribution = .equalSpacing
        titleStackView.spacing = 10
        titleStackView.isUserInteractionEnabled = false
        
        contentView.addSubview(titleStackView)
        contentView.layer.cornerRadius = 10
        
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.textColor = .font
        
        arrowImageView.image = UIImage(systemName: "chevron.right")
        arrowImageView.tintColor = .font
        
        titleStackView.addArrangedSubview(titleLabel)
        titleStackView.addArrangedSubview(arrowImageView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(headerTapped))
        addGestureRecognizer(tapGesture)

        titleStackView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(16)
            $0.right.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
        }
    }

    func configure(for section: Int, isCompleted: Bool, isExpanded: Bool) {
        self.section = section
        self.isCompleted = isCompleted
        self.isExpanded = isExpanded
        let titles = ["이용약관*", "개인정보처리방침*", "마케팅활용동의 및 광고 수신동의", "개인정보 제3자 제공동의"]
        titleLabel.text = titles[section]
        updateArrowImage()
    }
    
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    private func updateArrowImage() {
        let imageName = isExpanded ? "chevron.down" : "chevron.right"
        arrowImageView.image = UIImage(systemName: imageName)
    }

    @objc private func headerTapped() {
        isExpanded.toggle()
        updateArrowImage()
        delegate?.didTapHeader(in: section)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateColor()
        }
    }
    
    func updateColor(){
        //베이비그레이-커스텀블랙
        let babyGTocustomB = traitCollection.userInterfaceStyle == .dark ? UIColor(named: "customblack") : UIColor(named: "babygray")
        contentView.backgroundColor = babyGTocustomB
    }
}

protocol PrivacyPolicySectionHeaderViewDelegate: AnyObject {
    func didTapHeader(in section: Int)
}

