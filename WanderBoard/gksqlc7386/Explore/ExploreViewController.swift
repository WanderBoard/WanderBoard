//
//  ExploreViewController.swift
//  WanderBoard
//
//  Created by Luz on 5/31/24.
//

import UIKit
import SnapKit
import Then
import FirebaseFirestore

class ExploreViewController: UIViewController, PageIndexed {
    
    var pageIndex: Int?
    var pageText: String?
    
    var recentLogs: [PinLog] = []
    var hotLogs: [PinLog] = []
    var blockedAuthors: [String] = []
    
    let pinLogManager = PinLogManager()
    var recentCellHeight: CGFloat = 0
    
    var lastSnapshot: DocumentSnapshot?
    
    lazy var searchButton = UIButton(type: .system).then {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 15, weight: .regular)
        let image = UIImage(systemName: "magnifyingglass", withConfiguration: imageConfig)
        $0.setImage(image, for: .normal)
        $0.tintColor = .font
        $0.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
    }
    
    lazy var tableView = UITableView().then {
        $0.dataSource = self
        $0.delegate = self
        $0.separatorStyle = .none
        $0.register(HotTableViewCell.self, forCellReuseIdentifier: HotTableViewCell.identifier)
        $0.register(RecentTableViewCell.self, forCellReuseIdentifier: RecentTableViewCell.identifier)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupConstraints()
        setGradient()
        setupNV()
        
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic
        
        NotificationHelper.changePage(hidden: false, isEnabled: true)
        searchButton.isHidden = false
        
        if recentLogs.isEmpty {
            loadData()
        }
        
        reloadRecentCell()
    }

    private func loadData() {
        Task {
            self.blockedAuthors = try await AuthenticationManager.shared.getBlockedAuthors()
            await loadRecentData()
            await loadHotData()
        }
    }
    
    private func reloadRecentCell() {
        let indexPath = IndexPath(row: 1, section: 0) // 두 번째 셀의 인덱스
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    private func setupNV() {
        navigationItem.title = pageText
        
        if let navigationBarSuperview = navigationController?.navigationBar.superview {
            navigationBarSuperview.addSubview(searchButton)
            
            searchButton.snp.makeConstraints {
                $0.trailing.equalTo(navigationController!.navigationBar.snp.trailing).offset(-16)
                $0.bottom.equalTo(navigationController!.navigationBar.snp.bottom).offset(-10)
                $0.size.equalTo(CGSize(width: 30, height: 30))
            }
        }
        
//        if let navigationBarSuperview = navigationController?.navigationBar.superview {
//            let customView = UIView()
//            customView.backgroundColor = .clear
//            customView.addSubview(searchButton)
//            
//            navigationBarSuperview.addSubview(customView)
//            
//            customView.snp.makeConstraints {
//                $0.trailing.equalTo(navigationController!.navigationBar.snp.trailing).offset(-30)
//                $0.bottom.equalTo(navigationController!.navigationBar.snp.bottom).offset(-10)
//                $0.size.equalTo(CGSize(width: 30, height: 30))
//            }
//            
//            searchButton.snp.makeConstraints {
//                $0.edges.equalToSuperview()
//            }
//        }
    }
    
    private func setupConstraints() {
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func filterBlockedAuthors(from logs: [PinLog]) -> [PinLog] {
        return logs.filter { !blockedAuthors.contains($0.authorId) }
    }
    
    func loadRecentData() async {
        do {
            let logs = try await pinLogManager.fetchPublicPinLogs()
            await MainActor.run {
                self.recentLogs = filterBlockedAuthors(from: logs)
                self.recentLogs.sort { ($0.createdAt ?? Date.distantPast) > ($1.createdAt ?? Date.distantPast) }
                self.calculateRecentCellHeight()
                self.tableView.reloadData()
            }
        } catch {
            print("Failed to fetch pin logs: \(error.localizedDescription)")
        }
    }
    
//    // 무한스크롤 시도 중
//    func loadRecentData() {
//        pinLogManager.fetchInitialData(pageSize: 30) { result in
//            switch result {
//            case .success(let (logs, snapshot)):
//                DispatchQueue.main.async {
//                    self.recentLogs = self.filterBlockedAuthors(from: logs)
//                    self.calculateRecentCellHeight()
//                    self.lastSnapshot = snapshot
//                    self.reloadRecentCell()
//                }
//            case .failure(let error):
//                print("Failed to fetch pin logs: \(error.localizedDescription)")
//            }
//        }
//    }
    
    func loadHotData() async {
        do {
            let logs = try await pinLogManager.fetchHotPinLogs()
            await MainActor.run {
                //self.recentLogs = logs
                self.hotLogs = filterBlockedAuthors(from: logs)
                self.tableView.reloadData()
            }
        } catch {
            print("Failed to fetch pin logs: \(error.localizedDescription)")
        }
    }
    
    private func setGradient() {
        let maskedView = UIView(frame: CGRect(x: 0, y: 722, width: 393, height: 130))
        let gradientLayer = CAGradientLayer()
        
        maskedView.backgroundColor = view.backgroundColor
        gradientLayer.frame = maskedView.bounds
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.white.withAlphaComponent(0.98), UIColor.white.cgColor, UIColor.white.cgColor]
        gradientLayer.locations = [0, 0.05, 0.5, 1]
        maskedView.layer.mask = gradientLayer
        view.addSubview(maskedView)
    }
    
    private func calculateRecentCellHeight() {
        guard let recentCell = tableView.dequeueReusableCell(withIdentifier: RecentTableViewCell.identifier) as? RecentTableViewCell else { return }
        recentCell.configure(with: recentLogs)
        recentCellHeight = recentCell.calculateCollectionViewHeight()
        print("Calculated recentCellHeight: \(recentCellHeight)")
    }
    
    @objc func searchButtonTapped(_ sender: UIButton) {
        NotificationHelper.changePage(hidden: true, isEnabled: false)
        searchButton.isHidden = true
        let searchVC = SearchViewController()
        navigationController?.pushViewController(searchVC, animated: true)
    }
}

extension ExploreViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: HotTableViewCell.identifier, for: indexPath) as? HotTableViewCell else { return .init() }
            cell.configure(with: hotLogs)
            cell.delegate = self
            cell.selectionStyle = .none
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: RecentTableViewCell.identifier, for: indexPath) as? RecentTableViewCell else { return .init() }
            cell.delegate = self
            cell.configure(with: recentLogs)
            cell.updateItemCount(recentLogs.count)
            cell.selectionStyle = .none
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 450
        case 1:
            print("Returning recentCellHeight: \(recentCellHeight) for row 1")
            return recentCellHeight
        default:
            return 0
        }
    }
}

extension ExploreViewController: HotTableViewCellDelegate {
    func hotTableViewCell(_ cell: HotTableViewCell, didSelectItemAt indexPath: IndexPath) {
        NotificationHelper.changePage(hidden: true, isEnabled: false)
        searchButton.isHidden = true
        let detailVC = DetailViewController()
        let hotPinLog = cell.hotPinLogs[indexPath.item]
        detailVC.pinLog = hotPinLog
        detailVC.delegate = self
        navigationController?.pushViewController(detailVC, animated: false)
    }
}

extension ExploreViewController: RecentTableViewCellDelegate {
    func recentTableViewCell(_ cell: RecentTableViewCell, didSelectItemAt indexPath: IndexPath) {
        NotificationHelper.changePage(hidden: true, isEnabled: false)
        searchButton.isHidden = true
        let detailVC = DetailViewController()
        let selectedPinLog = cell.recentLogs[indexPath.item]
        detailVC.pinLog = selectedPinLog
        detailVC.delegate = self
        navigationController?.pushViewController(detailVC, animated: false)
    }
    
    func loadMoreRecentLogs() {
        guard let lastSnapshot = lastSnapshot else {
            print("Last snapshot is nil")
            return
        }
        
        pinLogManager.fetchMoreData(pageSize: 30, lastSnapshot: lastSnapshot) { result in
            switch result {
            case .success(let (newLogs, newSnapshot)):
                let filteredNewLogs = self.filterBlockedAuthors(from: newLogs)
                self.recentLogs.append(contentsOf: filteredNewLogs)
                self.recentLogs.sort { ($0.createdAt ?? Date.distantPast) > ($1.createdAt ?? Date.distantPast) }
                self.calculateRecentCellHeight()
                self.lastSnapshot = newSnapshot
                self.tableView.reloadData()
            case .failure(let error):
                print("Failed to fetch more pin logs: \(error.localizedDescription)")
            }
        }
    }
}

extension ExploreViewController: DetailViewControllerDelegate {
    func didHidePinLog(_ hiddenPinLogId: String) {
        self.recentLogs = self.recentLogs.filter { $0.id != hiddenPinLogId }
        self.hotLogs = self.hotLogs.filter { $0.id != hiddenPinLogId }
        
        self.tableView.reloadData()
    }
    
    func didUpdatePinButton(_ updatedPinLog: PinLog) {
        print("Received updated pin log via delegate")
        if let index = recentLogs.firstIndex(where: { $0.id == updatedPinLog.id }) {
            recentLogs[index] = updatedPinLog
            tableView.reloadData()
        }
        
        if let hotIndex = hotLogs.firstIndex(where: { $0.id == updatedPinLog.id }) {
            hotLogs[hotIndex] = updatedPinLog
            tableView.reloadData()
        }
    }
    
    func didUpdatePinLog() {
        Task {
            self.blockedAuthors = try await AuthenticationManager.shared.getBlockedAuthors()
            await loadRecentData()
            await loadHotData()
        }
    }
    
    func didBlockAuthor(_ authorId: String) {
        self.blockedAuthors.append(authorId)
        
        // 차단된 작성자의 로그를 숨기기 위해 필터링
        self.recentLogs = self.recentLogs.filter { !self.blockedAuthors.contains($0.authorId) }
        self.hotLogs = self.hotLogs.filter { !self.blockedAuthors.contains($0.authorId) }
        
        self.tableView.reloadData()
    }
}
