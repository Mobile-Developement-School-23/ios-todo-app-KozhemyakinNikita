//
//  ToDoListView.swift
//  ToDoList
//
//  Created by Nik Kozhemyakin on 28.06.2023.
//

import UIKit

extension ToDoListViewController: ToDoListViewControllerDelegate {
    
    func setupHeader() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.layoutMargins = UIEdgeInsets(top: 0, left: 34, bottom: 0, right: 0)
        title = "Мои дела"
    }
    
    func setupUI() {
        view.backgroundColor = UIColor.Colors.backPrimary
        view.addSubview(tableView)
        view.addSubview(creationButton)
    }
    
    func setupTableViewCells() {
        tableView.backgroundColor = UIColor.Colors.backPrimary
        tableView.register(ToDoListHeaderCell.self, forHeaderFooterViewReuseIdentifier: ToDoListHeaderCell.reuseIdentifier)
        tableView.register(ToDoListViewCell.self, forCellReuseIdentifier: ToDoListViewCell.reuseIdentifier)
//        tableView.rowHeight = 56
        tableView.layer.cornerRadius = 16
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    func setupCreationButton() {
        creationButton.setImage(UIImage(named: "radioButtonPlus"), for: .normal)
        creationButton.addTarget(nil, action: #selector(creationButtonDidTapped), for: .touchUpInside)
        creationButton.layer.cornerRadius = 1
        creationButton.layer.shadowColor = UIColor.blue.cgColor
        creationButton.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        creationButton.layer.shadowRadius = 5.0
        creationButton.layer.shadowOpacity = 0.3
    }
    
    func setupConstraints() {
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        creationButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            creationButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            creationButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            creationButton.widthAnchor.constraint(equalToConstant: 44),
            creationButton.heightAnchor.constraint(equalToConstant: 44),
            
        ])
    }
}
