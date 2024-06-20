//
//  BlockTableViewCell.swift
//  WanderBoard
//
//  Created by 김시종 on 6/16/24.
//

import UIKit

protocol BlockedUserTableViewCellDelegate: AnyObject {
    func didTapUnblockButton(for user: BlockedUserSummary)
}

class BlockedUserTableViewCell: UITableViewCell {
    static let identifier = "BlockedUserTableViewCell"
    
    weak var delegate: BlockedUserTableViewCellDelegate?
    private var user: BlockedUserSummary?

    let profileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 35
        $0.clipsToBounds = true
    }
    
    let nicknameLabel = UILabel().then {
        $0.textColor = .black
        $0.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        $0.numberOfLines = 2
    }
    
    lazy var unblockButton = UIButton(type: .system).then {
        $0.setTitle("차단 해제", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.backgroundColor = .lightGray
        $0.layer.cornerRadius = 22
        $0.addTarget(self, action: #selector(didTapUnblockButton), for: .touchUpInside)
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
        contentView.addSubview(unblockButton)
        
        profileImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(32)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(70)
        }
        
        nicknameLabel.snp.makeConstraints {
            $0.leading.equalTo(profileImageView.snp.trailing).offset(16)
            $0.trailing.equalTo(unblockButton.snp.leading)
            $0.centerY.equalToSuperview()
        }
        
        unblockButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-32)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(110)
            $0.height.equalTo(44)
        }
    }
    
    func configure(with user: BlockedUserSummary) {
        self.user = user
        nicknameLabel.text = user.displayName
        if let photoURL = user.photoURL, let url = URL(string: photoURL) {
            profileImageView.kf.setImage(with: url)
        } else {
            profileImageView.image = UIImage(named: "profileImage")
        }
    }
    
    @objc private func didTapUnblockButton() {
        guard let user = user else { return }
        delegate?.didTapUnblockButton(for: user)
    }
}
