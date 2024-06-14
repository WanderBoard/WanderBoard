//
//  BlockViewController.swift
//  WanderBoard
//
//  Created by 이시안 on 6/13/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class BlockViewController: BaseViewController, UISearchBarDelegate {
    
    let searchBar = UISearchBar().then {
        $0.backgroundImage = UIImage()
        $0.placeholder = "메이트를 검색해주세요"
    }
    let tableView = UITableView().then {
        $0.backgroundColor = .clear
        $0.register(BlockTableViewCell.self, forCellReuseIdentifier: BlockTableViewCell.identifier)
    }
    let noDataView = UIView().then {
        $0.isUserInteractionEnabled = false
    }
    let imageView = UIImageView().then {
        $0.image = UIImage(named: "emptyImg")
        $0.contentMode = .scaleAspectFill
        $0.isHidden = true
    }
    let noDataMainTitle = UILabel().then {
        $0.text = "검색결과가 없습니다"
        $0.textAlignment = .center
        $0.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        $0.textColor = .font
        $0.isHidden = true
    }
    let noDataSubTitle = UILabel().then {
        $0.text = "검색을 통해 차단한 메이트를 찾아보세요"
        $0.textAlignment = .center
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.textColor = .lightgray
        $0.isHidden = true
    }
    var blockedUsers: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        constraintLayout()
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = .clear
    }
    
    
    override func constraintLayout() {
        super.constraintLayout()
        [searchBar, tableView, noDataView].forEach(){
            view.addSubview($0)
        }
        [imageView, noDataMainTitle, noDataSubTitle].forEach(){
            noDataView.addSubview($0)
        }
        
        searchBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(30)
            $0.leading.trailing.bottom.equalTo(view)
        }
        
        noDataView.snp.makeConstraints {
            $0.edges.equalTo(view)
        }
        
        imageView.snp.makeConstraints {
            $0.centerX.equalTo(noDataView)
            $0.centerY.equalTo(noDataView).offset(-40)
            $0.width.height.equalTo(60)
        }
        
        noDataMainTitle.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(20)
            $0.leading.trailing.equalTo(noDataView).inset(20)
        }
        
        noDataSubTitle.snp.makeConstraints {
            $0.top.equalTo(noDataMainTitle.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(noDataView).inset(20)
        }
    }
}
    
    
    extension BlockViewController: UITableViewDelegate, UITableViewDataSource {
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 3
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            100
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: BlockTableViewCell.identifier, for: indexPath) as? BlockTableViewCell else {
                return UITableViewCell()
            }
            return cell
        }
    }

