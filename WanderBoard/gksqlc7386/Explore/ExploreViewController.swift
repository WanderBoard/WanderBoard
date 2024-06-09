//
//  ExploreViewController.swift
//  WanderBoard
//
//  Created by Luz on 5/31/24.
//

import UIKit
import SnapKit
import Then

class ExploreViewController: UIViewController, PageIndexed, UISearchBarDelegate {

    var pageIndex: Int?
    var pageText: String?
    
    lazy var searchButton = UIButton(type: .system).then {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 15, weight: .regular)
        let image = UIImage(systemName: "magnifyingglass", withConfiguration: imageConfig)
        $0.setImage(image, for: .normal)
        $0.tintColor = .black
        $0.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
    }
    
    lazy var searchBar = UISearchBar().then {
        $0.placeholder = "Search"
        $0.delegate = self
        $0.isHidden = true
        $0.backgroundImage = UIImage()
        $0.barTintColor = .white
        $0.backgroundColor = .white
    }
    
    lazy var tableView = UITableView().then {
        $0.dataSource = self
        $0.delegate = self
        $0.separatorStyle = .none
        $0.register(HotTableViewCell.self, forCellReuseIdentifier: HotTableViewCell.identifier)
        $0.register(RecentTableViewCell.self, forCellReuseIdentifier: RecentTableViewCell.identifier)
    }

    var recentCellHeight: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupConstraints()
        setGradient()
        setupNV()
        calculateRecentCellHeight()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.post(name: .setPageControlButtonVisibility, object: nil, userInfo: ["hidden": false])
    }
    
    private func setupNV() {
        navigationItem.title = pageText
        navigationItem.largeTitleDisplayMode = .automatic
        
        // 네비게이션 바 위에 search 버튼 추가
        if let navigationBarSuperview = navigationController?.navigationBar.superview {
            let customView = UIView()
            customView.backgroundColor = .clear
            customView.addSubview(searchButton)
            customView.addSubview(searchBar)
            
            navigationBarSuperview.addSubview(customView)
            
            customView.snp.makeConstraints {
                $0.trailing.equalTo(navigationController!.navigationBar.snp.trailing).offset(-30)
                $0.bottom.equalTo(navigationController!.navigationBar.snp.bottom).offset(-10)
                $0.size.equalTo(CGSize(width: 30, height: 30))
            }
            
            searchButton.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
            
            searchBar.snp.makeConstraints {
                $0.leading.equalTo(navigationController!.navigationBar.snp.leading).offset(10)
                $0.trailing.equalTo(navigationController!.navigationBar.snp.trailing).offset(-10)
                $0.bottom.equalTo(navigationController!.navigationBar.snp.bottom).offset(-10)
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
    
    private func calculateRecentCellHeight() {
        // 높이를 계산하기 위해 더미 데이터 사용
        let recentCell = RecentTableViewCell(style: .default, reuseIdentifier: RecentTableViewCell.identifier)
        recentCell.updateItemCount(20) // 아이템 수 업데이트
        recentCellHeight = recentCell.calculateCollectionViewHeight()
    }
    
    @objc func searchButtonTapped(_ sender: UIButton) {
        print("searchButton tapped")
        searchBar.isHidden = !searchBar.isHidden
        searchButton.isHidden = true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("Search text: \(searchText)")
        // 검색 결과 업데이트 로직 구현
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder() // 검색 버튼 클릭 시 키보드 숨기기
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
            cell.selectionStyle = .none
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: RecentTableViewCell.identifier, for: indexPath) as? RecentTableViewCell else { return .init() }
            cell.updateItemCount(20) // 아이템 수 업데이트
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
            return recentCellHeight
        default:
            return 0
        }
    }
}
