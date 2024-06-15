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
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        collectionView.addSubview(emptyView)
        
        emptyView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(300)
            $0.centerX.equalToSuperview()
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
            $0.height.equalTo(45)
            $0.width.equalTo(65)
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
        guard let userId = Auth.auth().currentUser?.uid else { return [] }
        
        switch currentFilterIndex {
        case 0:
            return MyTripsViewController.tripLogs.filter { $0.authorId == userId }
        case 1:
            return [] // 다른 필터 로직 추가
        case 2:
            return MyTripsViewController.pinnedTripLogs
        default:
            return []
        }
    }
    
    @objc func addButtonTapped() {
        NotificationHelper.changePage(hidden: true, isEnabled: false)
        plusButton.isHidden = true
        let inputVC = DetailInputViewController()
        inputVC.delegate = self
        navigationController?.pushViewController(inputVC, animated: false)
    }
    
    @objc func filterButtonTapped(sender: UIButton) {
        currentFilterIndex = sender.tag
        Task {
            if currentFilterIndex == 2 { // Wander Pin 필터가 선택되었을 때
                await loadPinnedData()
            }
            updateView()
            printFilteredLogs() // 필터링된 로그를 콘솔에 출력
        }
    }
    
    func loadData() async {
        do {
            guard let userId = Auth.auth().currentUser?.uid else {
                print("No user ID found")
                return
            }
            // 위치 정보를 포함하지 않는 핀 로그 데이터를 가져옵니다.
            let pinLogs = try await pinLogManager.fetchPinLogsWithoutLocation(forUserId: userId)
            MyTripsViewController.tripLogs = pinLogs
            print("Fetched pinLogs: \(pinLogs)")
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
    
    func printFilteredLogs() {
        let filteredLogs = filterTripLogs()
        for log in filteredLogs {
            print("Title: \(log.title), Author: \(log.authorId), Pinned By: \(log.pinnedBy ?? [])")
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
        } else {
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
            return filterTripLogs().count
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
