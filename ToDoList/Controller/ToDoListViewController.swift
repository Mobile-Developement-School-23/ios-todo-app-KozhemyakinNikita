//
//  ToDoListViewController.swift
//  ToDoList
//
//  Created by Nik Kozhemyakin on 28.06.2023.
//

import Foundation
import UIKit

var listModel: ToDoListModel = ToDoListModel()

class ToDoListViewController: UIViewController {
    weak var delegate: ToDoItemSettingsViewDelegate?
    let tableViewHeader = ToDoListHeaderCell()
    let fc = FileCache()
    let creationButton = UIButton()

    private let creationViewController = ToDoItemController()

    let tableView = UITableView(frame: .zero, style: .insetGrouped)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupHeader()
        setupUI()
        setupTableViewCells()
        setupCreationButton()
        setupConstraints()

        listModel.listViewController = self

//        listModel.fetchData()
//        listModel.fetchTodoItems()
        
        listModel.updateToDoList()
    }

    @objc func creationButtonDidTapped() {
        listModel.openSetupToDo(with: nil)
    }

}

extension ToDoListViewController {
    func setConstraints() {
        NSLayoutConstraint.activate([
            creationButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            creationButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            creationButton.widthAnchor.constraint(equalToConstant: 44),
            creationButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    func reloadData() {
        tableView.reloadData()
    }
}

extension ToDoListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listModel.toDoItems.count

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let todoItems = Array(listModel.toDoItems.values).sorted(by: { $0.created < $1.created })
        var todoItems = listModel.toDoItems
        todoItems.sort(by: { $0.created < $1.created })
//        listModel.toDoItems.sort(by: { $0.created < $1.created })
        let todoItem = todoItems[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath) as? ToDoListViewCell {
            cell.accessoryType = .disclosureIndicator
            let viewModel = ToDoListCellModel(todoItem: todoItem, index: indexPath.row)
            cell.setupCellsView(with: viewModel)
            cell.selectionStyle = .none

            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        tableViewHeader.textViewLabel.text = "Выполнено - \(listModel.fileCache.todoItems.filter({ $0.value.isDone }).count)"
        tableViewHeader.valueDidChange = {listModel.updateToDoList()}
        return tableViewHeader
    }

    func tableView(
        _ tableView: UITableView,
        leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
//        let todoItems = Array(listModel.toDoItems.values).sorted(by: { $0.created < $1.created })
        var todoItems = listModel.toDoItems
        todoItems.sort(by: { $0.created < $1.created })
        let toggle = UIContextualAction(style: .normal, title: "") { (action, view, completionHandler) in
            let item  = todoItems[indexPath.row]
            completionHandler(true)
        }
        if todoItems[indexPath.row].isDone {
            toggle.image = UIImage(systemName: "circle")
            toggle.backgroundColor = UIColor.Colors.backPrimary
        } else {
            toggle.image = UIImage(systemName: "checkmark.circle.fill")
            toggle.backgroundColor = UIColor.Colors.colorGreen
        }
        return UISwipeActionsConfiguration(actions: [toggle])
    }

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let trash = UIContextualAction(style: .destructive, title: "") { (action, view, completionHandler) in
//            let todoItems = Array(listModel.toDoItems.values).sorted(by: { $0.created < $1.created })
            var todoItems = listModel.toDoItems
            todoItems.sort(by: { $0.created < $1.created })
            let item  = todoItems[indexPath.row]
            listModel.deleteTask(id: item.id)
            completionHandler(true)
        }
        trash.backgroundColor = UIColor.Colors.colorRed
        trash.image = UIImage(systemName: "trash.fill")

        return UISwipeActionsConfiguration(actions: [trash])
    }

}

extension ToDoListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let todoItems = Array(listModel.toDoItems.values).sorted(by: { $0.created < $1.created })
        var todoItems = listModel.toDoItems
        todoItems.sort(by: { $0.created < $1.created })
        let selectedTodoItem = todoItems[indexPath.row]
        showToDoItemController(with: selectedTodoItem)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func showToDoItemController(with item: ToDoItem) {
        let todoItemController = ToDoItemController()
        todoItemController.delegateToDoList = self
        todoItemController.todoItem = item

        let navigationController = UINavigationController(rootViewController: todoItemController)
        present(navigationController, animated: true, completion: nil)
    }
}

extension ToDoListViewController: ToDoListDelegate {
    func didUpdateToDoItem(_ item: ToDoItem) {

        print("Updated")
//        var todoItems = Array(listModel.toDoItems.values).sorted(by: { $0.created < $1.created })
        var todoItems = listModel.toDoItems
        todoItems.sort(by: { $0.created < $1.created })
        if let index = todoItems.firstIndex(where: { $0.id == item.id }) {
            todoItems[index] = item
            print("Updated2")
            try? fc.loadFromFile(from: "TodoCache")
            listModel.fetchData()
            DispatchQueue.main.async {
                self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                print("Update3")
            }
            self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
        }
    }
}
