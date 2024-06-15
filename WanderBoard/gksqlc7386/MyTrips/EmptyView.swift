//
//  EmptyView.swift
//  WanderBoard
//
//  Created by Luz on 6/7/24.
//

import UIKit
import SnapKit

class EmptyView: UIView {
    
    weak var delegate: EmptyViewDelegate?
    
    private var emptyImg = UIImageView().then {
        $0.image = UIImage(named: "emptyImg")?.withTintColor(.customblack)
        $0.contentMode = .scaleAspectFill
    }
    
    private let mainLabel = UILabel().then {
        $0.text = "여행 기록을 추가하세요"
        $0.font = .boldSystemFont(ofSize: 20)
        $0.textAlignment = .center
    }
    
    private let subLabel = UILabel().then {
        $0.text = "입력된 글이 없습니다. \n 상단에 버튼을 클릭하여 여행을 기록해보세요"
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
        $0.setTitle("여행 추가하기", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        $0.setTitleColor(.black, for: .normal)
        $0.backgroundColor = .babygray
        $0.layer.cornerRadius = 23
        $0.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        
        setupConstraints()
        updateColor()
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
            $0.top.equalToSuperview().offset(320)
        }
        
        addButton.snp.makeConstraints {
            $0.top.equalTo(stackView.snp.bottom).offset(40)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(234)
            $0.height.equalTo(46)
        }
        
        emptyImg.snp.makeConstraints {
            $0.height.equalTo(44)
            $0.width.equalTo(66)
        }
    }
    
    @objc private func addButtonTapped() {
        delegate?.didTapAddButton()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateColor()
        }
    }
    
    func updateColor(){
        let imageColor = traitCollection.userInterfaceStyle == .dark ? UIColor.babygray : UIColor.customblack
        emptyImg.image = UIImage(named: "emptyImg")?.withTintColor(imageColor)
    }
}
    
    protocol EmptyViewDelegate: AnyObject {
        func didTapAddButton()
    }
    
