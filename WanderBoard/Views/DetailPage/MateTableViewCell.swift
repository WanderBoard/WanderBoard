//
//  MateTableViewCell.swift
//  WanderBoard
//
//  Created by 김시종 on 6/13/24.
//

import UIKit

protocol MateTableViewCellDelegate: AnyObject {
    func didTapAddButton(for user: UserSummary)
}

class MateTableViewCell: UITableViewCell {
    
    static let identifier = "MateTableViewCell"
    
    weak var delegate: MateTableViewCellDelegate?
    private var user: UserSummary?
    
    
    let profileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 35
        $0.clipsToBounds = true
    }
    
    let nicknameLabel = UILabel().then {
        $0.textColor = .font
        $0.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        $0.numberOfLines = 2
    }
    
    lazy var addButton = UIButton(type: .system).then {
        $0.setTitle("추가", for: .normal)
        $0.setTitleColor(.darkgray, for: .normal)
        $0.backgroundColor = .babygray
        $0.layer.cornerRadius = 22
        $0.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        updateColor()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(nicknameLabel)
        contentView.addSubview(addButton)
        
        profileImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(32)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(70)
        }
        
        nicknameLabel.snp.makeConstraints {
            $0.leading.equalTo(profileImageView.snp.trailing).offset(16)
            $0.trailing.equalTo(addButton.snp.leading)
            $0.centerY.equalToSuperview()
            
        }
        
        addButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-32)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(110)
            $0.height.equalTo(44)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateColor()
            
        }
    }
    
    func updateColor(){
        
        //베이비그레이-라이트블랙
        let babyGTolightB = traitCollection.userInterfaceStyle == .dark ? UIColor(named: "lightblack") : UIColor(named: "babygray")
        addButton.backgroundColor = babyGTolightB
    }
    
    
    func configure(with user: UserSummary) {
        self.user = user
        nicknameLabel.text = user.displayName
        if let photoURL = user.photoURL, let url = URL(string: photoURL) {
            profileImageView.kf.setImage(with: url)
        } else {
            profileImageView.image = UIImage(systemName: "person.crop.circle.fill")
        }
        
        updateAddButton()
    }
    
    func updateAddButton() {
        guard let user = user else { return }
        let buttonTitle = user.isMate ? "제거" : "추가"
        addButton.setTitle(buttonTitle, for: .normal)
        let babyGTolightB = traitCollection.userInterfaceStyle == .dark ? UIColor(named: "lightblack") : UIColor(named: "babygray")
        addButton.backgroundColor = user.isMate ? .font : babyGTolightB
        addButton.setTitleColor(user.isMate ? UIColor(named: "textColor") : .darkgray, for: .normal)
    }
    
    @objc private func didTapAddButton() {
        guard var user = user else { return }
        user.isMate.toggle()
        updateAddButton()
        delegate?.didTapAddButton(for: user)
    }
}
