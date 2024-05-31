//
//  ViewController.swift
//  Wanderboard
//
//  Created by Luz on 5/28/24.
//

import UIKit
import Then
import SnapKit

class MainViewController: UIViewController {
    
    //그라이데이션 컬러
    let colors: [CGColor] = [
        UIColor.white.cgColor,
        UIColor.clear.cgColor
    ]
    
    //메뉴 버튼 설정
    private struct Const {
        static let ImageRightMargin: CGFloat = 18
        static let ImageBottomMarginForLargeState: CGFloat = 10
    }

    let menuButton = UIButton().then {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .light)
        let image = UIImage(systemName: "ellipsis.circle", withConfiguration: imageConfig)
        $0.setImage(image, for: .normal)
        $0.tintColor = .black
    }
    
    let layout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .vertical
        $0.minimumLineSpacing = 24
        $0.itemSize = .init(width: 356, height: 198)
        $0.sectionInset = .init(top: 20, left: 0, bottom: 0, right: 0)
        
        let screenWidth = UIScreen.main.bounds.width
        let itemWidth = screenWidth - 40
        let itemHeight = itemWidth * 198 / 356
        $0.itemSize = .init(width: itemWidth, height: itemHeight)
    }
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout).then {
        $0.dataSource = self
        $0.delegate = self
        $0.register(MyTripsCollectionViewCell.self, forCellWithReuseIdentifier: MyTripsCollectionViewCell.identifier)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupConstraints()
        configureUI()
        setupNvBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setGradient()
    }
    
    func setupConstraints() {
        
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func configureUI() {
        view.backgroundColor = .white
    }
    
    func setupNvBar() {
        //title
        title = "My trips"
        navigationController?.navigationBar.largeTitleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 34, weight: .regular)
        ]
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .medium)
        ]
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        //menuButton
        guard let navigationBar = self.navigationController?.navigationBar else { return }
        navigationBar.addSubview(menuButton)
        menuButton.menu = createMenu()
        menuButton.showsMenuAsPrimaryAction = true
        
        menuButton.snp.makeConstraints {
            $0.right.equalTo(navigationBar.snp.right).offset(-Const.ImageRightMargin)
            $0.bottom.equalTo(navigationBar.snp.bottom).offset(-Const.ImageBottomMarginForLargeState)
        }
    }
    
    func createMenu() -> UIMenu {
        let newAction = UIAction(title: "New PinLog", image: UIImage(systemName: "plus")) { [weak self] _ in
            let practiceVC = PracticeViewController()
            self?.navigationController?.pushViewController(practiceVC, animated: true)
        }
        
        let myAction = UIAction(title: "My Setting", image: UIImage(systemName: "person.crop.circle")) { [weak self] _ in
            let practiceVC = PracticeViewController()
            self?.navigationController?.pushViewController(practiceVC, animated: true)
        }
        
        let menu = UIMenu(title: "", children: [newAction, myAction])
        return menu
    }
    
    func setGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        
        view.layer.addSublayer(gradientLayer)
    }
}

extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
        
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyTripsCollectionViewCell.identifier, for: indexPath) as! MyTripsCollectionViewCell
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 셀이 선택되었을 때 이동
        let detailVC = DetailViewController()
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
