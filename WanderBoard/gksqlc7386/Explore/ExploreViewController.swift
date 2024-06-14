//
//  ExploreViewController.swift
//  WanderBoard
//
//  Created by Luz on 5/31/24.
//

import UIKit
import SnapKit
import Then

class ExploreViewController: UIViewController, PageIndexed {
    
    var pageIndex: Int?
    var pageText: String?
    
    var recentLogs: [PinLog] = []
    var hotLogs: [PinLog] = []
    var blockedAuthors: [String] = []
    
    let pinLogManager = PinLogManager()
    
    var recentCellHeight: CGFloat = 0
    
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
        updateNavigationBarColor()
        
        loadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
        navigationItem.largeTitleDisplayMode = .always
        
        if let navigationBarSuperview = navigationController?.navigationBar.superview {
            let customView = UIView()
            customView.backgroundColor = .clear
            customView.addSubview(searchButton)
            
            navigationBarSuperview.addSubview(customView)
            
            customView.snp.makeConstraints {
                $0.trailing.equalTo(navigationController!.navigationBar.snp.trailing).offset(-30)
                $0.bottom.equalTo(navigationController!.navigationBar.snp.bottom).offset(-10)
                $0.size.equalTo(CGSize(width: 30, height: 30))
            }
            
            searchButton.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
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
                //self.recentLogs = logs
                self.recentLogs = filterBlockedAuthors(from: logs)
                self.recentLogs.sort { $0.startDate > $1.startDate }
                self.calculateRecentCellHeight()
                self.tableView.reloadData()
            }
        } catch {
            print("Failed to fetch pin logs: \(error.localizedDescription)")
        }
    }
    
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
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension ExploreViewController: DetailViewControllerDelegate {
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

extension ExploreViewController {
    func updateNavigationBarColor() {
        let navbarAppearance = UINavigationBarAppearance()
        navbarAppearance.configureWithOpaqueBackground()
        let navBarColor = traitCollection.userInterfaceStyle == .dark ? UIColor.black : UIColor.clear
        navbarAppearance.backgroundColor = navBarColor
        navigationController?.navigationBar.standardAppearance = navbarAppearance
    }
}
