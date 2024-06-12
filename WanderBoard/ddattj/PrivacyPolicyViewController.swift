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
        let button = UIButton(type: .system).then(){
            $0.setTitle("동의함", for: .normal)
            $0.setTitleColor(UIColor(named: "textColor"), for: .normal)
            $0.backgroundColor = .font
            $0.layer.cornerRadius = 10
        }
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
    //그라데이션 레이어와 마스크 해줄 레이어 만들기 -> 회색부분을 배경으로 입혀 점진적으로 투명해지는 느낌을 주기 위해 마스크를 씌움
    let maskedView = UIView(frame: CGRect(x: 0, y: 58, width: 393, height: 100))
    let maskedView2 = UIView(frame: CGRect(x: 0, y: 652, width: 393, height: 200))
    let gradientLayer = CAGradientLayer()
    let gradientLayer2 = CAGradientLayer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        constraintLayout()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(PrivacyPolicyCollectionViewCell.self, forCellWithReuseIdentifier: "PrivacyPolicyCollectionViewCell")
        
        // 진영 추카
        agreeButton.addTarget(self, action: #selector(agreeButtonTapped), for: .touchUpInside)
        
        //마스크 및 그라데이션 설정
        maskedView.backgroundColor = view.backgroundColor //마스킹 컬러는 백그라운드 컬러로
        gradientLayer.frame = maskedView.bounds
        gradientLayer.colors = [UIColor.white.cgColor, UIColor.white.cgColor, UIColor.white.withAlphaComponent(0.2), UIColor.clear.cgColor]
        gradientLayer.locations = [0, 0.3, 0.7, 1]
        maskedView.layer.mask = gradientLayer
        view.addSubview(maskedView)
        
        maskedView2.backgroundColor = view.backgroundColor
        gradientLayer2.frame = maskedView2.bounds
        gradientLayer2.colors = [UIColor.clear.cgColor, UIColor.white.withAlphaComponent(0.9), UIColor.white.cgColor, UIColor.white.cgColor]
        gradientLayer2.locations = [0, 0.1, 0.5, 1]
        maskedView2.layer.mask = gradientLayer2
        view.addSubview(maskedView2)
        
        view.addSubview(agreeButton)// 진영 추가
        agreeButton.snp.makeConstraints { //최상단에 위치하게 하기 위해 코드를 여기로 이동 - 시안
            $0.left.equalTo(view).inset(32)
            $0.right.equalTo(view).inset(32)
            $0.height.equalTo(50)
            $0.bottom.equalTo(view).inset(60)
        }

    }
    
    override func constraintLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(collectionView)
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(view).offset(112)
            $0.horizontalEdges.equalTo(view).inset(16)
            $0.bottom.equalTo(view)
        }
        
        collectionView.snp.makeConstraints {
            $0.edges.equalTo(scrollView)
            $0.width.equalTo(scrollView)
            $0.height.equalTo(1170)
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
