//
//  BlockViewController.swift
//  WanderBoard
//
//  Created by 김시종 on 6/16/24.
//

import UIKit
import FirebaseFirestore

class BlockViewController: UIViewController {
    var blockedUsers: [BlockedUserSummary] = []
    var filteredUsers: [BlockedUserSummary] = []
    
    let searchBar = UISearchBar().then {
        $0.backgroundImage = UIImage()
        $0.placeholder = "차단된 유저를 검색해주세요"
    }

    let tableView = UITableView().then {
        $0.backgroundColor = .white
        $0.register(BlockedUserTableViewCell.self, forCellReuseIdentifier: BlockedUserTableViewCell.identifier)
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
        $0.text = "차단된 유저가 없습니다"
        $0.textAlignment = .center
        $0.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        $0.textColor = .black
        $0.isHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstraints()
        setupTableView()
        setupSearchBar()
        fetchBlockedUsers()

        updateNoDataView(isEmpty: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.navigationBar.tintColor = .black
        navigationItem.largeTitleDisplayMode = .never
    }

    func setupUI() {
        view.addSubview(searchBar)
        view.addSubview(tableView)
        view.addSubview(noDataView)

        noDataView.addSubview(imageView)
        noDataView.addSubview(noDataMainTitle)

        view.backgroundColor = .white
    }

    func setupConstraints() {
        searchBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom)
            $0.leading.trailing.bottom.equalTo(view)
        }

        noDataView.snp.makeConstraints {
            $0.edges.equalTo(view)
        }

        imageView.snp.makeConstraints {
            $0.centerX.equalTo(noDataView)
            $0.centerY.equalTo(noDataView).offset(-40)
            $0.height.equalTo(35)
            $0.width.equalTo(55)
        }

        noDataMainTitle.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(20)
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

    func fetchBlockedUsers() {
        Task {
            do {
                let users = try await AuthenticationManager.shared.getBlockedUsersSummaries()
                self.blockedUsers = users
                self.filteredUsers = users
                self.updateNoDataView(isEmpty: users.isEmpty)
                self.tableView.reloadData()
            } catch {
                print("Failed to fetch blocked users: \(error)")
            }
        }
    }

    func searchBlockedUsers(with query: String) {
        let filteredByName = blockedUsers.filter { $0.displayName.lowercased().contains(query.lowercased()) }
        let filteredByEmail = blockedUsers.filter { $0.email.lowercased().contains(query.lowercased()) }
        filteredUsers = Array(Set(filteredByName + filteredByEmail))
        updateNoDataView(isEmpty: filteredUsers.isEmpty)
        tableView.reloadData()
    }

    func updateNoDataView(isEmpty: Bool) {
        noDataMainTitle.isHidden = !isEmpty
        imageView.isHidden = !isEmpty
    }
}

extension BlockViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         guard let cell = tableView.dequeueReusableCell(withIdentifier: BlockedUserTableViewCell.identifier, for: indexPath) as? BlockedUserTableViewCell else {
            return UITableViewCell()
        }

        let user = filteredUsers[indexPath.row]
        cell.configure(with: user)
        cell.delegate = self
        cell.selectionStyle = .none
        return cell
    }
}

extension BlockViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText.isEmpty) {
            filteredUsers = blockedUsers
            updateNoDataView(isEmpty: filteredUsers.isEmpty)
        } else {
            searchBlockedUsers(with: searchText)
        }
        tableView.reloadData()
    }
}

extension BlockViewController: BlockedUserTableViewCellDelegate {
    func didTapUnblockButton(for user: BlockedUserSummary) {
        Task {
            do {
                try await AuthenticationManager.shared.unblockAuthor(authorId: user.uid)
                blockedUsers.removeAll { $0.uid == user.uid }
                filteredUsers.removeAll { $0.uid == user.uid }
                tableView.reloadData()
                updateNoDataView(isEmpty: blockedUsers.isEmpty)
            } catch {
                print("Failed to unblock user: \(error)")
            }
        }
    }
}
