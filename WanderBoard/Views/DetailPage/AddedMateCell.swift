//
//  AddedMateCell.swift
//  WanderBoard
//
//  Created by 김시종 on 6/14/24.
//

import UIKit

protocol AddedMateCellDelegate: AnyObject {
    func didTapRemoveButton(for user: UserSummary)
}


class AddedMateCell: UICollectionViewCell {
    static let identifier = "AddedMateCell"
    
    weak var delegate: AddedMateCellDelegate?
    private var user: UserSummary?
    
    let nameLabel = UILabel().then {
        $0.textColor = #colorLiteral(red: 0.8666666746, green: 0.8666666746, blue: 0.8666666746, alpha: 1)
        $0.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        $0.textAlignment = .center
    }
    
    lazy var removeButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "xmark"), for: .normal)
        $0.tintColor = #colorLiteral(red: 0.8666666746, green: 0.8666666746, blue: 0.8666666746, alpha: 1)
        $0.addTarget(self, action: #selector(didTapRemoveButton), for: .touchUpInside)
    }
    
    let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.spacing = 10
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        contentView.addSubview(stackView)
        
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(removeButton)
        
        contentView.layer.cornerRadius = 15
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = #colorLiteral(red: 0.8666666746, green: 0.8666666746, blue: 0.8666666746, alpha: 1)
        
        stackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        removeButton.snp.makeConstraints {
            $0.height.equalTo(15)
            $0.width.equalTo(15)
        }
    }
    
    func configure(with user: UserSummary) {
        self.user = user
        nameLabel.text = user.displayName
    }
    
    @objc func didTapRemoveButton() {
        guard let user = user else { return }
        delegate?.didTapRemoveButton(for: user)
    }
}
