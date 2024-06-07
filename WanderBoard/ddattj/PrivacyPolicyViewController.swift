//
//  PrivacyPolicyViewController.swift
//  WanderBoard
//
//  Created by 이시안 on 5/29/24.
//

import UIKit


class PrivacyPolicyViewController: BaseViewController {
    var completionHandler: (() -> Void)?    // 진영 추가
    
    // 진영 추가
    private let agreeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("동의함", for: .normal)
        button.layer.cornerRadius = 10
        return button
    }()
    
    let scrollView = UIScrollView()
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then {
        $0.scrollDirection = .vertical //UICollectionViewFlowLayout에 대한 then
        $0.minimumLineSpacing = 24
        $0.itemSize = CGSize(width: 361, height: 332)
    }).then {
        $0.backgroundColor = .clear //collectionView에 대한 then
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureUI()
        constraintLayout()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(PrivacyPolicyCollectionViewCell.self, forCellWithReuseIdentifier: "PrivacyPolicyCollectionViewCell")
        
        // 진영 추카
        agreeButton.addTarget(self, action: #selector(agreeButtonTapped), for: .touchUpInside)

        
    }
    override func configureUI() {
    }
    
    override func constraintLayout() {
        super.constraintLayout()
        view.addSubview(scrollView)
        scrollView.addSubview(collectionView)
        scrollView.addSubview(logo)
        view.addSubview(agreeButton)
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(view).offset(112)
            $0.horizontalEdges.equalTo(view).inset(16)
            $0.bottom.equalTo(view)
        }
        
        collectionView.snp.makeConstraints {
            $0.edges.equalTo(scrollView)
            $0.width.equalTo(scrollView)
            $0.height.equalTo(1150)
        }
        
        logo.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.equalTo(143)
            $0.height.equalTo(18.24)
            $0.bottom.equalToSuperview().inset(55)
        }
        
        // 진영 추가
        agreeButton.snp.makeConstraints {
            $0.left.equalToSuperview().inset(30)
            $0.right.equalToSuperview().inset(30)
            $0.height.equalTo(50)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(48)
        }
    }
    
    // 진영 추가
    @objc private func agreeButtonTapped() {
        completionHandler?()
        dismiss(animated: true, completion: nil)
    }
}

extension PrivacyPolicyViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PrivacyPolicyCollectionViewCell", for: indexPath) as! PrivacyPolicyCollectionViewCell
            return cell
    }
}

//class StickyHeaderViewController: UIViewController {
//
//    let scrollView = UIScrollView()
//    let stackView = UIStackView()
//    
//    let headerView = UIView()
//    let contentView = UIView()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .white
//
//        // scrollView 설정
//        view.addSubview(scrollView)
//        scrollView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
//
//        // stackView 설정
//        scrollView.addSubview(stackView)
//        stackView.axis = .vertical
//        stackView.spacing = 0
//        stackView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//            make.width.equalToSuperview()
//        }
//
//        // headerView 설정
//        headerView.backgroundColor = .red
//        stackView.addArrangedSubview(headerView)
//        headerView.snp.makeConstraints { make in
//            make.height.equalTo(200)
//        }
//
//        // contentView 설정
//        contentView.backgroundColor = .blue
//        stackView.addArrangedSubview(contentView)
//        contentView.snp.makeConstraints { make in
//            make.height.equalTo(1000)
//        }
//    }
//}
