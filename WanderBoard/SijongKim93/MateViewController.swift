//
//  MateViewController.swift
//  WanderBoard
//
//  Created by 김시종 on 6/13/24.
//

import UIKit
import FirebaseFirestore

class MateViewController: UIViewController {
    
    weak var delegate: MateViewControllerDelegate?
    
    var users: [UserSummary] = []
    var filteredUsers: [UserSummary] = []
    
    var addedMates: [UserSummary] = [] {
        didSet {
            updateAddedMatesCollectionViewVisibility()
        }
    }
    
    
    let searchBar = UISearchBar().then {
        $0.backgroundImage = UIImage()
        $0.placeholder = "메이트를 검색해주세요"
    }
    
    let addedMatesView = UIView()
    
    let addedMatesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 5, left: 32, bottom: 5, right: 32)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.register(AddedMateCell.self, forCellWithReuseIdentifier: AddedMateCell.identifier)
        return collectionView
    }()
    
    let tableView = UITableView().then {
        $0.backgroundColor = .white
        $0.register(MateTableViewCell.self, forCellReuseIdentifier: MateTableViewCell.identifier)
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
        $0.textColor = .black
        $0.isHidden = true
    }
    
    let noDataSubTitle = UILabel().then {
        $0.text = "검색을 통해 메이트를 추가해주세요"
        $0.textAlignment = .center
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.textColor = .lightgray
        $0.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstraints()
        setupTableView()
        setupSearchBar()
        setupAddedMatesCollectionView()
        setupNavigationBar()
        fetchUsers()
        
        updateNoDataView(isEmpty: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.tintColor = .black
    }
    
    func setupUI() {
        view.addSubview(searchBar)
        view.addSubview(addedMatesView)
        addedMatesView.addSubview(addedMatesCollectionView)
        view.addSubview(tableView)
        view.addSubview(noDataView)
        
        noDataView.addSubview(imageView)
        noDataView.addSubview(noDataMainTitle)
        noDataView.addSubview(noDataSubTitle)
        
        view.backgroundColor = .white
    }

    func setupConstraints() {
        searchBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        addedMatesView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(addedMates.isEmpty ? 0 : 40)
        }
        
        addedMatesCollectionView.snp.makeConstraints {
            $0.edges.equalTo(addedMatesView)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(addedMatesView.snp.bottom)
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
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func setupSearchBar() {
        searchBar.delegate = self
    }
    
    func setupNavigationBar() {
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
        navigationItem.rightBarButtonItem = doneButton
    }
    
    @objc func doneButtonTapped() {
        delegate?.didSelectMates(addedMates)
        navigationController?.popViewController(animated: true)
    }
    
    func setupAddedMatesCollectionView() {
        addedMatesCollectionView.delegate = self
        addedMatesCollectionView.dataSource = self
    }
    
    func updateAddedMatesCollectionViewVisibility() {
        addedMatesView.isHidden = addedMates.isEmpty
        addedMatesView.snp.updateConstraints {
            $0.height.equalTo(addedMates.isEmpty ? 0 : 40)
        }
        tableView.snp.updateConstraints {
            $0.top.equalTo(addedMatesView.snp.bottom)
        }
    }
    
    func fetchUsers() {
        MateManager.shared.fetchUserSummaries { [weak self] result in
            switch result {
            case .success(let userSummaries):
                self?.users = userSummaries
                self?.filteredUsers = []
                self?.updateNoDataView(isEmpty: true)
                self?.tableView.reloadData()
            case .failure(let error):
                print("Error fetching users: \(error)")
            }
        }
    }

    func searchFriends(with query: String) {
        let filteredByName = users.filter { $0.displayName.lowercased().contains(query.lowercased()) }
        let filteredByEmail = users.filter { $0.email.lowercased().contains(query.lowercased()) }
        filteredUsers = Array(Set(filteredByName + filteredByEmail))
        updateNoDataView(isEmpty: filteredUsers.isEmpty)
        tableView.reloadData()
    }
    
    func updateNoDataView(isEmpty: Bool) {
        noDataMainTitle.isHidden = !isEmpty
        noDataSubTitle.isHidden = !isEmpty
        imageView.isHidden = !isEmpty
    }
}

extension MateViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MateTableViewCell.identifier, for: indexPath) as? MateTableViewCell else {
            return UITableViewCell()
        }
        
        let user = filteredUsers[indexPath.row]
        cell.configure(with: user)
        cell.delegate = self
        return cell
    }
}


extension MateViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredUsers = []
            updateNoDataView(isEmpty: true)
        } else {
            searchFriends(with: searchText)
        }
        tableView.reloadData()
    }
}

extension MateViewController: MateTableViewCellDelegate {
    func didTapAddButton(for user: UserSummary) {
        if let index = filteredUsers.firstIndex(where: { $0.uid == user.uid }) {
            filteredUsers[index].isMate.toggle()
            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            
            if filteredUsers[index].isMate {
                addedMates.append(filteredUsers[index])
            } else {
                addedMates.removeAll { $0.uid == filteredUsers[index].uid }
            }
            addedMatesCollectionView.reloadData()
        }
    }
}

extension MateViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return addedMates.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddedMateCell.identifier, for: indexPath) as? AddedMateCell else {
            return UICollectionViewCell()
        }
        
        let mate = addedMates[indexPath.row]
        cell.configure(with: mate)
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == addedMatesCollectionView {
            let user = addedMates[indexPath.row]
            let labelWidth = user.displayName.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .semibold)]).width
            let buttonWidth: CGFloat = 50
            let padding: CGFloat = 20
            let totalWidth = labelWidth + buttonWidth + padding
            return CGSize(width: totalWidth, height: 30)
        }
        return CGSize(width: 120, height: 30)
    }
}

extension MateViewController: AddedMateCellDelegate {
    func didTapRemoveButton(for user: UserSummary) {
        if let index = addedMates.firstIndex(where: { $0.uid == user.uid }) {
            addedMates.remove(at: index)
            if let filteredIndex = filteredUsers.firstIndex(where: { $0.uid == user.uid }) {
                filteredUsers[filteredIndex].isMate = false
                tableView.reloadRows(at: [IndexPath(row: filteredIndex, section: 0)], with: .automatic)
            }
            addedMatesCollectionView.reloadData()
        }
    }
}

protocol MateViewControllerDelegate: AnyObject {
    func didSelectMates(_ mates: [UserSummary])
}
