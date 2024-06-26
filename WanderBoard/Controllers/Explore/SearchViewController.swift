//
//  SearchViewController.swift
//  WanderBoard
//
//  Created by Luz on 6/9/24.
//

import UIKit
import SnapKit
import Then
import FirebaseFirestore

@MainActor
class SearchViewController: UIViewController, UISearchBarDelegate {
    
    //이미지 캐싱
    private static let imageCache = NSCache<NSString, UIImage>()
    
    var searchKeyword: String?
    
    var allTripLogs: [PinLogSummary] = []
    var searchedLogs: [PinLogSummary] = []
    
    var blockedAuthors: [String] = []
    var hiddenPinLogs: [String] = []
        
    var lastDocumentSnapshot: DocumentSnapshot?
    var isLoading = false
    let pageSize = 30
        
    let pinLogManager = PinLogManager()
    
    lazy var searchBar = UISearchBar().then {
        $0.placeholder = "Search"
        $0.delegate = self
        $0.autocorrectionType = .no
        $0.spellCheckingType = .no
    }
    
    let collectionViewFlowLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .vertical
        $0.minimumLineSpacing = 16
        $0.sectionInset = .init(top: 13, left: 24, bottom: 0, right: 24)
        
        let screenWidth = UIScreen.main.bounds.width
        let inset: CGFloat = 30
        let spacing: CGFloat = 10
        let numberOfItemsPerRow: CGFloat = 2
        
        let itemWidth = (screenWidth - 2 * inset - (numberOfItemsPerRow - 1) * spacing) / numberOfItemsPerRow
        let itemHeight = itemWidth * 117 / 170
        
        $0.itemSize = CGSize(width: itemWidth, height: itemHeight)
    }
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout).then {
        $0.dataSource = self
        $0.delegate = self
        $0.register(RecentCollectionViewCell.self, forCellWithReuseIdentifier: RecentCollectionViewCell.identifier)
        $0.backgroundColor = .clear
        $0.keyboardDismissMode = .onDrag
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupConstraints()
        setGradient()
        setupSearchBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.largeTitleDisplayMode = .never
        
        Task {
            self.blockedAuthors = try await AuthenticationManager.shared.getBlockedAuthors()
            self.hiddenPinLogs = try await AuthenticationManager.shared.getHiddenPinLogs()
            await loadAllData()
        }
    }
    
    private func applyFilterAndReload() {
        DispatchQueue.main.async {
            var filteredLogs = self.allTripLogs.filter { !self.blockedAuthors.contains($0.authorId) && !self.hiddenPinLogs.contains($0.id ?? "") }

            if let keyword = self.searchKeyword, !keyword.isEmpty {
                let lowercasedSearchText = keyword.lowercased()
                filteredLogs = filteredLogs.filter {
                    $0.location.containsIgnoringCase(lowercasedSearchText) || $0.location.containsInitials(keyword)
                }.sorted {
                    let firstContainsInitials = $0.location.hasPrefixInitial(keyword)
                    let secondContainsInitials = $1.location.hasPrefixInitial(keyword)
                    
                    if firstContainsInitials && !secondContainsInitials {
                        return true
                    } else if !firstContainsInitials && secondContainsInitials {
                        return false
                    } else {
                        return $0.location.localizedCaseInsensitiveCompare($1.location) == .orderedAscending
                    }
                }
            }

            self.searchedLogs = filteredLogs
            self.collectionView.reloadData()
        }
    }
    
    private func filterBlockedAndHiddenLogs(from logs: [PinLogSummary]) -> [PinLogSummary] {
        return logs.filter { !blockedAuthors.contains($0.authorId) && !hiddenPinLogs.contains($0.id ?? "") }
    }
    
    func loadAllData() async {
        isLoading = true
        pinLogManager.fetchInitialData(pageSize: pageSize) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            switch result {
            case .success(let (logs, lastSnapshot)):
                self.allTripLogs = self.filterBlockedAndHiddenLogs(from: logs)
                self.allTripLogs.sort { $0.startDate > $1.startDate }
                self.searchedLogs = self.allTripLogs
                self.applyFilterAndReload()
                self.lastDocumentSnapshot = lastSnapshot
            case .failure(let error):
                print("Error getting documents: \(error)")
            }
        }
    }
        
    private func fetchMoreData() {
        guard !isLoading, let lastSnapshot = lastDocumentSnapshot else { return }
        
        isLoading = true
        pinLogManager.fetchMoreData(pageSize: pageSize, lastSnapshot: lastSnapshot) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            switch result {
            case .success(let (logs, lastSnapshot)):
                self.allTripLogs.append(contentsOf: self.filterBlockedAndHiddenLogs(from: logs))
                self.searchedLogs = self.allTripLogs
                self.applyFilterAndReload()
                self.lastDocumentSnapshot = lastSnapshot
            case .failure(let error):
                print("Error getting documents: \(error)")
            }
        }
    }

    private func setupSearchBar() {
        navigationItem.titleView = searchBar
    }
    
    private func setupConstraints() {
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func setGradient() {
        let maskedView = UIView()
        maskedView.backgroundColor = view.backgroundColor
        view.addSubview(maskedView)
        
        maskedView.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.white.withAlphaComponent(0.98).cgColor, UIColor.white.cgColor, UIColor.white.cgColor]
        gradientLayer.locations = [0, 0.05, 0.8, 1]
        
        maskedView.layer.mask = gradientLayer
        maskedView.isUserInteractionEnabled = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchKeyword = searchText
        lastDocumentSnapshot = nil
        Task {
            await loadAllData()
        }
    }
}

extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchedLogs.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecentCollectionViewCell.identifier, for: indexPath) as? RecentCollectionViewCell else { return UICollectionViewCell() }
        let log = searchedLogs[indexPath.item]
        Task { await cell.configure(with: log) }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        NotificationHelper.changePage(hidden: true, isEnabled: false)
        let detailVC = DetailViewController()
        let selectedItem = searchedLogs[indexPath.item]
        detailVC.pinLogId = selectedItem.id
        detailVC.delegate = self
        let navController = UINavigationController(rootViewController: detailVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            fetchMoreData()
        }
    }
}

extension String {
    func containsIgnoringCase(_ find: String) -> Bool {
        return self.range(of: find, options: .caseInsensitive, locale: .current) != nil
    }
    
    func initials() -> String {
        let initialConsonants: [Character] = ["ㄱ", "ㄲ", "ㄴ", "ㄷ", "ㄸ", "ㄹ", "ㅁ", "ㅂ", "ㅃ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅉ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"]
        
        return self.compactMap { char -> Character? in
            guard let scalar = char.unicodeScalars.first else { return char }
            let value = scalar.value

            if value >= 0xAC00 && value <= 0xD7A3 {
                let index = (value - 0xAC00) / 28 / 21
                return initialConsonants[Int(index)]
            } else {
                return char
            }
        }.reduce("") { $0 + String($1) }
    }
    
    func containsInitials(_ find: String) -> Bool {
        return self.initials().contains(find)
    }
    
    func hasPrefixInitial(_ prefix: String) -> Bool {
        return self.initials().hasPrefix(prefix)
    }
}

extension SearchViewController: DetailViewControllerDelegate {
    func didHidePinLog(_ hiddenPinLogId: String) {
        self.hiddenPinLogs.append(hiddenPinLogId)
        applyFilterAndReload()
    }
    
    func didUpdatePinButton(_ updatedPinLog: PinLog) {
        let updatedPinLogSummary = PinLogSummary(
            id: updatedPinLog.id,
            location: updatedPinLog.location,
            startDate: updatedPinLog.startDate,
            representativeMediaURL: updatedPinLog.media.first { $0.isRepresentative }?.url,
            authorId: updatedPinLog.authorId,
            createdAt: updatedPinLog.createdAt ?? Date(),
            isPublic: updatedPinLog.isPublic
        )
        
        if let index = searchedLogs.firstIndex(where: { $0.id == updatedPinLog.id }) {
            searchedLogs[index] = updatedPinLogSummary
            collectionView.reloadData()
        }
    }
    
    func didUpdatePinLog() {
        Task {
            self.blockedAuthors = try await AuthenticationManager.shared.getBlockedAuthors()
            self.hiddenPinLogs = try await AuthenticationManager.shared.getHiddenPinLogs()
            await loadAllData()
        }
    }
    
    func didBlockAuthor(_ authorId: String) {
        self.blockedAuthors.append(authorId)
        applyFilterAndReload()
    }
}
