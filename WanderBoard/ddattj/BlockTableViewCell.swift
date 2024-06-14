//
//  BlockTableViewCell.swift
//  WanderBoard
//
//  Created by 이시안 on 6/14/24.
//

import UIKit

protocol BlockTableViewCellDelegate: AnyObject {
    func didTapAddButton(for user: UserSummary)
}


class BlockTableViewCell: UITableViewCell {

    static let identifier = "BlockTableViewCell"
    
    private var user: UserSummary?
    weak var delegate: BlockTableViewCellDelegate?
    
    
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
        $0.setTitle("차단", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.backgroundColor = .lightgray
        $0.layer.cornerRadius = 22
        $0.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        
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
    
    
    func configure(with user: UserSummary) {
        self.user = user
        nicknameLabel.text = user.displayName
        if let photoURL = user.photoURL, let url = URL(string: photoURL) {
            profileImageView.kf.setImage(with: url)
        } else {
            profileImageView.image = UIImage(named: "defaultProfileImage")
        }
        
        updateAddButton()
    }
    
    func updateAddButton() {
        guard var user = user else { return }
        let buttonTitle = user.isBlocked ? "해제" : "차단"
        addButton.setTitle(buttonTitle, for: .normal)
        addButton.backgroundColor = user.isBlocked ? .black : .lightgray
        addButton.setTitleColor(user.isBlocked ? .white : .black, for: .normal)
    }
    
    @objc private func didTapAddButton() {
        guard var user = user else { return }
        user.isMate.toggle()
        updateAddButton()
        delegate?.didTapAddButton(for: user)
    }
}
