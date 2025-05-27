//
//  UserView.swift
//  VIPER-Boilerplate
//
//  Created by Wilson Munoz on 23/05/25.
//

import UIKit

/// Responsable for the User Interface
/// Can be a ViewController / object or a struct for SwiftUI
/// For this example we tie our AnyUserView to an AnyObject
/// Should have a reference to the `Presenter`
/// Uses a Protocol

protocol AnyUserView: AnyObject {
    var presenter:AnyUserPresenter? { get set }
    func update(with users:[AnyUserEntity])
    func weGotErrorFetchingUsers(with error:Error)
}

class UserViewController:UIViewController, AnyUserView {
    
    private var users = [AnyUserEntity]()
    private let tableView = {
        let table      = UITableView(frame: .zero)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.isHidden = true
        return table
    }()
    var presenter: (any AnyUserPresenter)?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemTeal
        tableView.dataSource      = self
        tableView.delegate        = self
        self.view.addSubview(tableView)
        self.presenter?.interactor?.getUsers()

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableView.frame = self.view.bounds
    }
    
    func update(with users:[AnyUserEntity]) {
        self.users = users
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }

    }
    
    func weGotErrorFetchingUsers(with error: Error) {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(
                title: "Error",
                message: "Failed to load users. Please try again.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }
    }
}

extension UserViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "cell",
            for: indexPath
        )
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        return cell
    }
    
}
