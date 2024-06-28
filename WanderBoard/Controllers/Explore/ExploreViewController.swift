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
    
    var recentLogs: [PinLogSummary] = []
    var hotLogs: [PinLogSummary] = []
    var blockedAuthors: [String] = []
    var hiddenPinLogs: [String] = []
    
    let pinLogManager = PinLogManager()
    var recentCellHeight: CGFloat = 0
    var lastSnapshot: DocumentSnapshot?
    var isLoading = false

    var progressViewController: ProgressViewController?
    
    lazy var searchButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
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
        navigationItem.largeTitleDisplayMode = .always
        
        NotificationHelper.changePage(hidden: false, isEnabled: true)
        searchButton.isHidden = false
    }
    
    private func showProgressView() {
        let progressVC = ProgressViewController()
        addChild(progressVC)
        view.addSubview(progressVC.view)
        progressVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        progressVC.didMove(toParent: self)
        progressViewController = progressVC
    }

    private func hideProgressView() {
        if let progressVC = progressViewController {
            progressVC.willMove(toParent: nil)
            progressVC.view.removeFromSuperview()
            progressVC.removeFromParent()
            progressViewController = nil
        }
    }

    private func loadData() {
        showProgressView()
        
        Task {
            do {
//            try await Task.sleep(nanoseconds: 3_000_000_000) // 프로그레스뷰 테스트용 강제지연 3초
                self.blockedAuthors = try await AuthenticationManager.shared.getBlockedAuthors()
                self.hiddenPinLogs = try await AuthenticationManager.shared.getHiddenPinLogs()
                
                await loadHotData()
                loadRecentData()
            } catch {
                print("Failed to fetch user data: \(error.localizedDescription)")
            }
            hideProgressView()
        }
    }
    
    private func setupNV() {
        navigationItem.title = pageText
        
        if let navigationBarSuperview = navigationController?.navigationBar.superview {
            navigationBarSuperview.addSubview(searchButton)
            searchButton.snp.makeConstraints {
                $0.trailing.equalTo(navigationController!.navigationBar.snp.trailing).offset(-16)
                $0.bottom.equalTo(navigationController!.navigationBar.snp.bottom).offset(-5)
                $0.size.equalTo(CGSize(width: 44, height: 44))
            }
        }
    }
    
    private func setupConstraints() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
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
    
    private func filterBlockedAndHiddenLogs(from logs: [PinLogSummary]) -> [PinLogSummary] {
        return logs.filter { !blockedAuthors.contains($0.authorId) && !hiddenPinLogs.contains($0.id ?? "") }
    }
    
    func loadRecentData() {
        pinLogManager.fetchInitialData(pageSize: 30) { result in
            switch result {
            case .success(let (logs, snapshot)):
                self.recentLogs = self.filterBlockedAndHiddenLogs(from: logs)
                self.recentLogs.sort { $0.createdAt > $1.createdAt }
                self.calculateRecentCellHeight()
                self.lastSnapshot = snapshot
                DispatchQueue.main.async {
                    let indexPath = IndexPath(row: 1, section: 0)
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            case .failure(let error):
                print("Failed to fetch initial data: \(error.localizedDescription)")
            }
        }
    }

    func loadHotData() async {
        do {
            let logs = try await pinLogManager.fetchHotPinLogs()
            await MainActor.run {
                self.hotLogs = self.filterBlockedAndHiddenLogs(from: logs)
                let indexPath = IndexPath(row: 0, section: 0)
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        } catch {
            print("Failed to fetch pin logs: \(error.localizedDescription)")
        }
    }
    
    private func calculateRecentCellHeight() {
        guard let recentCell = tableView.dequeueReusableCell(withIdentifier: RecentTableViewCell.identifier) as? RecentTableViewCell else { return }
        recentCell.configure(with: recentLogs)
        recentCellHeight = recentCell.calculateCollectionViewHeight()
    }
    
    @objc func searchButtonTapped(_ sender: UIButton) {
        NotificationHelper.changePage(hidden: true, isEnabled: false)
        searchButton.isHidden = true
        let searchVC = SearchViewController()
        navigationController?.pushViewController(searchVC, animated: true)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            
    }
}

extension ExploreViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: HotTableViewCell.identifier, for: indexPath) as? HotTableViewCell else { return UITableViewCell() }
            cell.configure(with: hotLogs)
            cell.delegate = self
            cell.selectionStyle = .none
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: RecentTableViewCell.identifier, for: indexPath) as? RecentTableViewCell else { return UITableViewCell() }
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
            return recentCellHeight > 0 ? recentCellHeight : 500 // 최소 높이를 지정하거나 동적으로 계산된 높이를 반환
        default:
            return 0
        }
    }
}

extension ExploreViewController: HotTableViewCellDelegate {
    func refreshHotData() {
        Task {
            await loadHotData()
            if let hotCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? HotTableViewCell {
                hotCell.endRefreshing()
            }
        }
    }
    
    func hotTableViewCell(_ cell: HotTableViewCell, didSelectItemAt indexPath: IndexPath) {
        let detailVC = DetailViewController()
        let hotPinLogSummary = cell.hotPinLogs[indexPath.item]
        
        detailVC.pinLogId = hotPinLogSummary.id
        detailVC.delegate = self
        let navController = UINavigationController(rootViewController: detailVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
}

extension ExploreViewController: RecentTableViewCellDelegate {
    func recentTableViewCell(_ cell: RecentTableViewCell, didSelectItemAt indexPath: IndexPath) {
        let selectedPinLogSummary = cell.recentLogs[indexPath.item]
        
        let detailVC = DetailViewController()
        detailVC.pinLogId = selectedPinLogSummary.id
        detailVC.delegate = self
        let navController = UINavigationController(rootViewController: detailVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
    func loadMoreRecentLogs() {
        guard let lastSnapshot = lastSnapshot, !isLoading else {
            return
        }
        
        isLoading = true
        
        pinLogManager.fetchMoreData(pageSize: 30, lastSnapshot: lastSnapshot) { result in
            self.isLoading = false
            switch result {
            case .success(let (newLogs, newSnapshot)):
                let filteredNewLogs = self.filterBlockedAndHiddenLogs(from: newLogs)
                self.recentLogs.append(contentsOf: filteredNewLogs)
                self.recentLogs.sort { $0.createdAt > $1.createdAt }
                self.calculateRecentCellHeight()
                self.lastSnapshot = newSnapshot
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    if let cell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? RecentTableViewCell {
                        cell.updateItemCount(self.recentLogs.count)
                    }
                }
            case .failure(let error):
                print("Failed to fetch more data: \(error.localizedDescription)")
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
        let updatedPinLogSummary = PinLogSummary(
            id: updatedPinLog.id,
            location: updatedPinLog.location,
            startDate: updatedPinLog.startDate,
            representativeMediaURL: updatedPinLog.media.first { $0.isRepresentative }?.url,
            authorId: updatedPinLog.authorId,
            createdAt: updatedPinLog.createdAt ?? Date()
        )
        
        if let index = recentLogs.firstIndex(where: { $0.id == updatedPinLog.id }) {
            recentLogs[index] = updatedPinLogSummary
            tableView.reloadData()
        }
        
        if let hotIndex = hotLogs.firstIndex(where: { $0.id == updatedPinLog.id }) {
            hotLogs[hotIndex] = updatedPinLogSummary
            tableView.reloadData()
        }
    }
    
    func didUpdatePinLog() {
        Task {
            self.blockedAuthors = try await AuthenticationManager.shared.getBlockedAuthors()
            self.hiddenPinLogs = try await AuthenticationManager.shared.getHiddenPinLogs()
            await loadHotData()
            loadRecentData()
        }
    }
    
    func didBlockAuthor(_ authorId: String) {
        self.blockedAuthors.append(authorId)
        self.recentLogs = self.recentLogs.filter { !self.blockedAuthors.contains($0.authorId) }
        self.hotLogs = self.hotLogs.filter { !self.blockedAuthors.contains($0.authorId) }
        self.tableView.reloadData()
    }
}

extension ExploreViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height

        if offsetY > contentHeight - height && !isLoading {
            loadMoreRecentLogs()
        }
        
    }
}
