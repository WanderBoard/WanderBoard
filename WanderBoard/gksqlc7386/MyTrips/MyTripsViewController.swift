//
//  MyTripsViewController.swift
//  Wanderboard
//
//  Created by Luz on 5/28/24.
//

import UIKit
import Then
import SnapKit
import SwiftUI
import FirebaseAuth
import Kingfisher


class MyTripsViewController: UIViewController, PageIndexed, UICollectionViewDelegateFlowLayout {

    static var tripLogs: [PinLog] = [] //시안: 마이페이지의 tripLogs개수 업데이트를 위해 static 변수 사용
    let pinLogManager = PinLogManager()
    
    var pageIndex: Int?
    var pageText: String?
    
    let filters = ["My Logs", "Our Logs", "Pin Logs"]

    lazy var plusButton = UIButton(type: .system).then {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 15, weight: .regular)
        let image = UIImage(systemName: "plus", withConfiguration: imageConfig)
        $0.setImage(image, for: .normal)
        $0.tintColor = .white
        $0.backgroundColor = .black
        $0.layer.cornerRadius = 15
        $0.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }

    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        $0.dataSource = self
        $0.delegate = self
        $0.register(FilterCollectionViewCell.self, forCellWithReuseIdentifier: FilterCollectionViewCell.identifier)
        $0.register(MyTripsCollectionViewCell.self, forCellWithReuseIdentifier: MyTripsCollectionViewCell.identifier)
    }
    
    lazy var emptyView = EmptyView().then {
        $0.delegate = self
        $0.isHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        
        setupConstraints()
        setGradient()
        setupNV()
        
        Task {
            await loadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.post(name: .setPageControlButtonVisibility, object: nil, userInfo: ["hidden": false])
        NotificationCenter.default.post(name: .setScrollEnabled, object: nil, userInfo: ["isEnabled": true])
        updateView()

        Task {
            await loadData()
        }
    }
    
    private func setupNV() {
        navigationItem.title = pageText
        navigationItem.largeTitleDisplayMode = .always
        
        // 네비게이션 바 위에 플러스 버튼 추가
        if let navigationBarSuperview = navigationController?.navigationBar.superview {
            let customView = UIView()
            customView.backgroundColor = .clear
            customView.addSubview(plusButton)
            
            navigationBarSuperview.addSubview(customView)
            
            // customView의 크기와 위치 설정
            customView.snp.makeConstraints {
                $0.trailing.equalTo(navigationController!.navigationBar.snp.trailing).offset(-30)
                $0.bottom.equalTo(navigationController!.navigationBar.snp.bottom).offset(-10)
                $0.size.equalTo(CGSize(width: 30, height: 30))
            }
            
            plusButton.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
    }

    private func setupConstraints() {
        view.addSubview(collectionView)
        view.addSubview(emptyView)

        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        emptyView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func setGradient() {
        if let sublayers = view.layer.sublayers {
            for sublayer in sublayers {
                if (sublayer is CAGradientLayer) {
                    sublayer.removeFromSuperlayer()
                }
            }
        }
        
        let gradientColors = [UIColor.white.withAlphaComponent(1).cgColor] + Array(repeating: UIColor.white.withAlphaComponent(0).cgColor, count: 8)
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds

        gradientLayer.colors = gradientColors
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)

        view.layer.addSublayer(gradientLayer)
    }
    
    @objc func addButtonTapped() {
        NotificationCenter.default.post(name: .setPageControlButtonVisibility, object: nil, userInfo: ["hidden": true])
        NotificationCenter.default.post(name: .setScrollEnabled, object: nil, userInfo: ["isEnabled": false])
        plusButton.isHidden = true
        let inputVC = DetailInputViewController()
        inputVC.delegate = self
        navigationController?.pushViewController(inputVC, animated: true)
    }
    
    @objc func filterButtonTapped(sender: UIButton) {
        let filterIndex = sender.tag
        let filterTitle = filters[filterIndex]
        print("Filter button tapped: \(filterTitle)")
    }
    
    func loadData() async {
        do {
            guard let userId = Auth.auth().currentUser?.uid else { return }
            MyTripsViewController.tripLogs = try await pinLogManager.fetchPinLogs(forUserId: userId)
            updateView()
        } catch {
            print("Failed to fetch pin logs: \(error.localizedDescription)")
        }
    }
    
    func addNewTripLog(_ log: PinLog) {
        MyTripsViewController.tripLogs.insert(log, at: 0)
        updateView()
    }
    
    private func updateView() {
        if MyTripsViewController.tripLogs.isEmpty {
            collectionView.isHidden = true
            plusButton.isHidden = true
            emptyView.isHidden = false
        } else {
            collectionView.isHidden = false
            plusButton.isHidden = false
            emptyView.isHidden = true
        }
        collectionView.reloadData()
    }
}

extension MyTripsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return filters.count
        } else {
            return MyTripsViewController.tripLogs.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterCollectionViewCell.identifier, for: indexPath) as! FilterCollectionViewCell
            cell.filterButton.setTitle(filters[indexPath.item], for: .normal)
            cell.filterButton.tag = indexPath.item
            cell.filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyTripsCollectionViewCell.identifier, for: indexPath) as? MyTripsCollectionViewCell else {
                fatalError("컬렉션 뷰 오류")
            }
            
            let tripLog = MyTripsViewController.tripLogs[indexPath.item]
            cell.configure(with: tripLog)
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        if indexPath.section == 0 {
            let itemWidth = screenWidth / 4 - 16
            let itemHeight = itemWidth * 1/3
            return CGSize(width: itemWidth, height: itemHeight)
        } else {
            let itemWidth = screenWidth - 32
            let itemHeight = itemWidth * 9/16
            return CGSize(width: itemWidth, height: itemHeight)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if section == 0 {
            return 8
        } else {
            return 16
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if section == 0 {
            return 8
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0 {
            return UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        } else {
            return UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        NotificationCenter.default.post(name: .setPageControlButtonVisibility, object: nil, userInfo: ["hidden": true])
        NotificationCenter.default.post(name: .setScrollEnabled, object: nil, userInfo: ["isEnabled": false])
        plusButton.isHidden = true
        let detailVC = DetailViewController()
        let selectedTripLog = MyTripsViewController.tripLogs[indexPath.item]
        detailVC.pinLog = selectedTripLog
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension MyTripsViewController: DetailInputViewControllerDelegate {
    func didSavePinLog(_ pinLog: PinLog) {
        addNewTripLog(pinLog)
    }
}

extension MyTripsViewController: EmptyViewDelegate {
    func didTapAddButton() {
        NotificationCenter.default.post(name: .setPageControlButtonVisibility, object: nil, userInfo: ["hidden": true])
        NotificationCenter.default.post(name: .setScrollEnabled, object: nil, userInfo: ["isEnabled": false])
        let inputVC = DetailInputViewController()
        inputVC.delegate = self
        navigationController?.pushViewController(inputVC, animated: true)
    }
}

extension MyTripsViewController {
    var parentPageViewController: PageViewController? {
        var parentResponder: UIResponder? = self
        while let parent = parentResponder?.next {
            if let pageVC = parent as? PageViewController {
                return pageVC
            }
            parentResponder = parent
        }
        return nil
    }
}
