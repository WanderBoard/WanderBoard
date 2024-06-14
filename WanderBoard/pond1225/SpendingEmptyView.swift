//
//  SpendingEmptyView.swift
//  WanderBoard
//
//  Created by t2023-m0049 on 6/13/24.
//

import UIKit
import SnapKit

class SpendingEmptyView: UIView {
    
    weak var delegate: EmptyViewDelegate?
    
    private let emptyImg = UIImageView().then {
        $0.image = UIImage(named: "emptyImg")
        $0.tintColor = .black
        $0.contentMode = .scaleAspectFill
    }
    
    private let mainLabel = UILabel().then {
        $0.text = "지출 내역을 추가하세요"
        $0.font = .boldSystemFont(ofSize: 20)
        $0.textAlignment = .center
    }
    
    private let subLabel = UILabel().then {
        $0.text = "입력된 지출 내역이 없습니다. \n 아래 버튼을 클릭하여 지출 내역을 기록해보세요"
        $0.font = .systemFont(ofSize: 16)
        $0.textColor = .darkgray
        $0.textAlignment = .center
        $0.numberOfLines = 2
    }
    
    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 10
        $0.alignment = .center
    }
    
    lazy var addButton = UIButton().then {
        $0.setTitle("지출 내역 추가하기", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        $0.setTitleColor(.black, for: .normal)
        $0.backgroundColor = .babygray
        $0.layer.cornerRadius = 26
        $0.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        
        setupConstraints()
    }
        
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupConstraints() {
        addSubview(stackView)
        addSubview(addButton)
        
        [emptyImg, mainLabel, subLabel].forEach {
            stackView.addArrangedSubview($0)
        }
        
        stackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(100)
        }
        
        addButton.snp.makeConstraints {
            $0.top.equalTo(stackView.snp.bottom).offset(40)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(240)
            $0.height.equalTo(50)
        }
        
        emptyImg.snp.makeConstraints {
            $0.height.equalTo(45)
            $0.width.equalTo(65)
        }
    }
    
    @objc private func addButtonTapped() {
        delegate?.didTapAddButton()
    }
}

protocol SpendingEmptyViewDelegate: AnyObject {
    func didTapAddButton()
}
