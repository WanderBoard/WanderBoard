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
    
    lazy var searchButton = UIButton(type: .system).then {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 15, weight: .regular)
        let image = UIImage(systemName: "magnifyingglass", withConfiguration: imageConfig)
        $0.setImage(image, for: .normal)
        $0.tintColor = .black
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
        setupNV()
    }
    
    private func setupNV() {
        navigationItem.title = pageText
        navigationItem.largeTitleDisplayMode = .always
        
        // 네비게이션 바 위에 search 버튼 추가
        if let navigationBarSuperview = navigationController?.navigationBar.superview {
            let customView = UIView()
            customView.backgroundColor = .clear
            customView.addSubview(searchButton)
            
            navigationBarSuperview.addSubview(customView)
            
            // customView의 크기와 위치 설정
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
    
    @objc func searchButtonTapped(_ sender: UIButton) {
        print("searchButton tapped")
    }
}

extension ExploreViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: HotTableViewCell.identifier, for: indexPath) as? HotTableViewCell else {
                return UITableViewCell()
            }
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: RecentTableViewCell.identifier, for: indexPath) as? RecentTableViewCell else {
                return UITableViewCell()
            }
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 480
        case 1:
            return 500
        default:
            return 0
        }
    }
}
