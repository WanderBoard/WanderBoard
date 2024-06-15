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
    static var tripLogs: [PinLog] = []
    let pinLogManager = PinLogManager()
    
    var pageIndex: Int?
    var pageText: String?
    
    let filters = ["My Pin", "Tag Pin", "Wander Pin"]
    var currentFilterIndex = 0
    static var pinnedTripLogs: [PinLog] = [] // 핀 찍은 로그를 저장할 새로운 배열 추가
    static var taggedTripLogs: [PinLog] = [] // 태그 된 아이디들 불러오는
    
    lazy var plusButton: UIButton = {
        let button = UIButton(type: .system)
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 15, weight: .regular)
        let image = UIImage(systemName: "plus", withConfiguration: imageConfig)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.backgroundColor = .black
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        $0.dataSource = self
        $0.delegate = self
        $0.register(FilterCollectionViewCell.self, forCellWithReuseIdentifier: FilterCollectionViewCell.identifier)
        $0.register(MyTripsCollectionViewCell.self, forCellWithReuseIdentifier: MyTripsCollectionViewCell.identifier)
    }
    
    lazy var emptyView = UIView().then {
        $0.isHidden = true
    }
        
    private let emptyImg = UIImageView().then {
        $0.image = UIImage(named: "emptyImg")
        $0.tintColor = .black
        $0.contentMode = .scaleAspectFill
    }
        
    private let mainLabel = UILabel().then {
        $0.text = ""
        $0.font = .boldSystemFont(ofSize: 20)
        $0.textAlignment = .center
    }
        
    private let subLabel = UILabel().then {
        $0.text = ""
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
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        $0.setTitleColor(.black, for: .normal)
        $0.backgroundColor = .babygray
        $0.layer.cornerRadius = 26
        $0.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        
        setupConstraints()
        setGradient()
        setupNV()
        updateNavigationBarColor()
        
        currentFilterIndex = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        NotificationHelper.changePage(hidden: false, isEnabled: true)
        updateView()
        plusButton.isHidden = false

        Task {
            await loadData()
            await loadPinnedData() // 핀 찍은 데이터도 로드
            updateView()
        }
    }
    
    private func setupNV() {
        navigationItem.title = pageText
        
        if let navigationBarSuperview = navigationController?.navigationBar.superview {
            navigationBarSuperview.addSubview(plusButton)
            
            plusButton.snp.makeConstraints {
                $0.trailing.equalTo(navigationController!.navigationBar.snp.trailing).offset(-16)
                $0.bottom.equalTo(navigationController!.navigationBar.snp.bottom).offset(-10)
                $0.size.equalTo(CGSize(width: 30, height: 30))
            }
        }
    }

    private func setupConstraints() {
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        collectionView.addSubview(emptyView)
        
        emptyView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(120)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(300)
            $0.width.equalTo(300)
        }
        
        emptyView.addSubview(stackView)
        emptyView.addSubview(addButton)
        
        [emptyImg, mainLabel, subLabel].forEach {
            stackView.addArrangedSubview($0)
        }
        
        stackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-50)
        }
        
        addButton.snp.makeConstraints {
            $0.top.equalTo(stackView.snp.bottom).offset(40)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(240)
            $0.height.equalTo(50)
        }
        
        emptyImg.snp.makeConstraints {
            $0.height.equalTo(35)
            $0.width.equalTo(55)
        }
    }

    private func setGradient() {
        let maskedView = UIView(frame: CGRect(x: 0, y: 722, width: 393, height: 130))
        let gradientLayer = CAGradientLayer()
        
        maskedView.backgroundColor = view.backgroundColor
        gradientLayer.frame = maskedView.bounds
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.white.withAlphaComponent(0.98), UIColor.white.cgColor, UIColor.white.cgColor]
        gradientLayer.locations = [0, 0.05, 0.8, 1]
        maskedView.layer.mask = gradientLayer
        view.addSubview(maskedView)
    }
    
    func filterTripLogs() -> [PinLog] {
        switch currentFilterIndex {
        case 0:
            return MyTripsViewController.tripLogs
        case 1:
            return MyTripsViewController.taggedTripLogs
        case 2:
            return MyTripsViewController.pinnedTripLogs
        default:
            return []
        }
    }
    
    @objc func addButtonTapped() {
        print("buttonTapped")
        NotificationHelper.changePage(hidden: true, isEnabled: false)
        plusButton.isHidden = true
        let inputVC = DetailInputViewController()
        inputVC.delegate = self
        navigationController?.pushViewController(inputVC, animated: false)
    }
    
    @objc func filterButtonTapped(sender: UIButton) {
        currentFilterIndex = sender.tag
        updateFilterButtonColors()
        updateView()
    }
    
    func loadData() async {
        do {
            guard let userId = Auth.auth().currentUser?.uid else {
                print("No user ID found")
                return
            }
            // 사용자가 작성한 핀로그 가져오기
            let userPinLogs = try await pinLogManager.fetchPinLogsWithoutLocation(forUserId: userId)
            MyTripsViewController.tripLogs = userPinLogs
            
            // 태그된 핀로그 가져오기
            let taggedPinLogs = try await pinLogManager.fetchTaggedPinLogs(forUserId: userId)
            MyTripsViewController.taggedTripLogs = taggedPinLogs
            
            print("Fetched userPinLogs: \(userPinLogs)")
            print("Fetched taggedPinLogs: \(taggedPinLogs)")
            updateView()
        } catch {
            print("Failed to fetch pin logs: \(error.localizedDescription)")
        }
    }
    
    func loadPinnedData() async {
        do {
            guard let userId = Auth.auth().currentUser?.uid else {
                print("No user ID found")
                return
            }
            let pinnedLogs = try await pinLogManager.fetchPinnedPinLogs(forUserId: userId)
            MyTripsViewController.pinnedTripLogs = pinnedLogs
            print("Fetched pinned pinLogs: \(pinnedLogs)")
        } catch {
            print("Failed to fetch pinned pin logs: \(error.localizedDescription)")
        }
    }
    
    func addNewTripLog(_ log: PinLog) {
        MyTripsViewController.tripLogs.insert(log, at: 0)
        updateView()
    }
    
    private func updateView() {
        let filteredLogs = filterTripLogs()

        if filteredLogs.isEmpty {
            emptyView.isHidden = false
            collectionView.bringSubviewToFront(emptyView)
            
            // 현재 필터에 따라 텍스트 업데이트
            switch currentFilterIndex {
            case 0:
                mainLabel.text = "나만의 핀 기록을 추가해보세요"
                subLabel.text = "아직 핀 기록이 없습니다.\n WanderBoard에 소중한 순간들을 기록해보세요."
                addButton.isHidden = false
                plusButton.isHidden = true
            case 1:
                mainLabel.text = "함께한 추억을 공유해보세요"
                subLabel.text = "메이트를 추가하거나 추가된 여행 기록이 \n 이곳에 표시됩니다."
                addButton.isHidden = true
                plusButton.isHidden = false
            case 2:
                mainLabel.text = "다른 사람의 여행을 저장해보세요"
                subLabel.text = "Wander Pin 버튼을 눌러 저장한 핀이 \n 이곳에 표시됩니다."
                addButton.isHidden = true
                plusButton.isHidden = false
            default:
                mainLabel.text = "나의 핀 기록을 추가하세요"
                subLabel.text = "입력된 나의 핀 기록이 없습니다.\n WanderBoard에 당신의 기록을 남겨보세요."
                plusButton.isHidden = true
            }
        } else {
            emptyView.isHidden = true
            plusButton.isHidden = false
        }

        collectionView.reloadData()
    }
    
    private func updateFilterButtonColors() {
        for index in 0..<filters.count {
            let indexPath = IndexPath(item: index, section: 0)
            if let cell = collectionView.cellForItem(at: indexPath) as? FilterCollectionViewCell {
                if index == currentFilterIndex {
                    cell.filterButton.backgroundColor = .babygray
                    cell.filterButton.setTitleColor(.darkgray, for: .normal)
                } else {
                    cell.filterButton.backgroundColor = .clear
                    cell.filterButton.setTitleColor(.darkgray, for: .normal)
                }
            }
        }
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
            return filterTripLogs().count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterCollectionViewCell.identifier, for: indexPath) as! FilterCollectionViewCell
            cell.filterButton.setTitle(filters[indexPath.item], for: .normal)
            cell.filterButton.tag = indexPath.item
            cell.filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
            
            // 필터 버튼 색상 업데이트
            if indexPath.item == currentFilterIndex {
                cell.filterButton.backgroundColor = .babygray
                cell.filterButton.setTitleColor(.darkgray, for: .normal)
            } else {
                cell.filterButton.backgroundColor = .clear
                cell.filterButton.setTitleColor(.darkgray, for: .normal)
            }
            
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyTripsCollectionViewCell.identifier, for: indexPath) as? MyTripsCollectionViewCell else {
                fatalError("컬렉션 뷰 오류")
            }
            
            let tripLog = filterTripLogs()[indexPath.item]
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
        NotificationHelper.changePage(hidden: true, isEnabled: false)
        plusButton.isHidden = true
        let detailVC = DetailViewController()
        
        let filteredTripLogs = filterTripLogs()
        let selectedTripLog = filteredTripLogs[indexPath.item]
        
        detailVC.pinLog = selectedTripLog
        navigationController?.pushViewController(detailVC, animated: false)
    }
}

extension MyTripsViewController: DetailInputViewControllerDelegate {
    func didSavePinLog(_ pinLog: PinLog) {
        addNewTripLog(pinLog)
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

extension MyTripsViewController {
    func updateNavigationBarColor() {
        let navbarAppearance = UINavigationBarAppearance()
        navbarAppearance.configureWithOpaqueBackground()
        let navBarColor = traitCollection.userInterfaceStyle == .dark ? UIColor.black : UIColor.clear
        navbarAppearance.backgroundColor = navBarColor
        navigationController?.navigationBar.standardAppearance = navbarAppearance
    }
}
