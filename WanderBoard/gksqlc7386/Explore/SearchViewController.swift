//
//  SearchViewController.swift
//  WanderBoard
//
//  Created by Luz on 6/9/24.
//

import UIKit
import SnapKit
import Then

class SearchViewController: UIViewController, UISearchBarDelegate {
    
    var allTripLogs: [PinLog] = []
    var searchedLogs: [PinLog] = []
    
    var blockedAuthors: [String] = []
    
    let pinLogManager = PinLogManager()
    
    lazy var searchBar = UISearchBar().then {
        $0.placeholder = "Search"
        $0.delegate = self
        $0.autocorrectionType = .no
        $0.spellCheckingType = .no
    }
    
    let collectionViewFlowLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .vertical
        $0.minimumLineSpacing = 10
        $0.sectionInset = .init(top: 20, left: 30, bottom: 0, right: 30)
        
        let screenWidth = UIScreen.main.bounds.width
        let inset: CGFloat = 30
        let spacing: CGFloat = 10
        let numberOfItemsPerRow: CGFloat = 2
        
        let itemWidth = (screenWidth - 2 * inset - (numberOfItemsPerRow - 1) * spacing) / numberOfItemsPerRow
        let itemHeight = itemWidth * 110 / 160
        
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
        setupSearchBar()
        
        Task {
            self.blockedAuthors = try await AuthenticationManager.shared.getBlockedAuthors()
            await loadAllData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    private func filterBlockedAuthors(from logs: [PinLog]) -> [PinLog] {
        return logs.filter { !blockedAuthors.contains($0.authorId) }
    }
    
    func loadAllData() async {
        do {
            let logs = try await pinLogManager.fetchPublicPinLogs()
            await MainActor.run {
                //self?.allTripLogs = logs
                self.allTripLogs = filterBlockedAuthors(from: logs)
                //self?.searchedLogs = logs
                self.searchedLogs = filterBlockedAuthors(from: logs)
                self.collectionView.reloadData()
            }
        } catch {
            print("Failed to fetch pin logs: \(error.localizedDescription)")
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
 
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        Task {
            let lowercasedSearchText = searchText.lowercased()
            var filteredLogs: [PinLog]
            
            if searchText.isEmpty {
                filteredLogs = allTripLogs
            } else {
                filteredLogs = allTripLogs.filter {
                    $0.location.containsIgnoringCase(lowercasedSearchText) || $0.location.containsInitials(searchText)
                }.sorted {
                    let firstContainsInitials = $0.location.hasPrefixInitial(searchText)
                    let secondContainsInitials = $1.location.hasPrefixInitial(searchText)
                    
                    if firstContainsInitials && !secondContainsInitials {
                        return true
                    } else if !firstContainsInitials && secondContainsInitials {
                        return false
                    } else {
                        return $0.location.localizedCaseInsensitiveCompare($1.location) == .orderedAscending
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.searchedLogs = filteredLogs
                self.collectionView.reloadData()
            }
        }
    }
}

extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchedLogs.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecentCollectionViewCell.identifier, for: indexPath) as? RecentCollectionViewCell else { return UICollectionViewCell() }
        cell.configure(with: searchedLogs[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        NotificationHelper.changePage(hidden: true, isEnabled: false)
        let detailVC = DetailViewController()
        let selectedItem = searchedLogs[indexPath.item]
        detailVC.pinLog = selectedItem
        detailVC.delegate = self
        navigationController?.pushViewController(detailVC, animated: true)
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
            
            // 한글 음절 범위 내에서만 처리
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
    func didUpdatePinButton(_ updatedPinLog: PinLog) {
        print("Received updated pin log via delegate")
        if let index = searchedLogs.firstIndex(where: { $0.id == updatedPinLog.id }) {
            searchedLogs[index] = updatedPinLog
            collectionView.reloadData()
        }
    }
    
    func didUpdatePinLog() {
        Task {
            self.blockedAuthors = try await AuthenticationManager.shared.getBlockedAuthors()
            await loadAllData()
        }
    }
    
    func didBlockAuthor(_ authorId: String) {
        self.blockedAuthors.append(authorId)
        
        // 차단된 작성자의 로그를 숨기기 위해 필터링
//        self.allTripLogs.filter { !self.blockedAuthors.contains($0.authorId) }
        self.searchedLogs = self.searchedLogs.filter { !self.blockedAuthors.contains($0.authorId) }
        
        self.collectionView.reloadData()
    }
}
