

import Foundation
import UIKit


class ToDoItemController: UIViewController {
    let fileCache = FileCache()
    var todoItem: ToDoItem?
    
    private var currentText = String()
    private var currentImportance = Importance.common
    private var currentDeadline: Date? = nil
    let settingsView = ToDoItemSettingsView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        view.backgroundColor = UIColor.Colors.backPrimary
        setupNavigationBar()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        settingsView.delegate = self
        
        if let item = todoItem {
            settingsView.textView.text = item.text
            currentDeadline = item.deadline
            currentImportance = item.importance
        }
    }
    
    //MARK: - Actions
    @objc func saveItem() {
        guard let text = settingsView.textView.text else { return }
        
        switch settingsView.importanceControl.selectedSegmentIndex {
        case 0:
            currentImportance = .unimpurtant
        case 1:
            currentImportance = .common
        case 2:
            currentImportance = .important
        default:
            currentImportance = .common
        }
        
        let isDone = false
        
        if settingsView.deadlineSwitcher.isOn {
            currentDeadline = settingsView.deadlineDatePicker.date
        } else {
            currentDeadline = nil
        }
        
        let item: ToDoItem
        if let existingItem = todoItem {
            item = ToDoItem(
                id: existingItem.id,
                text: text,
                deadline: currentDeadline,
                importance: currentImportance,
                isDone: isDone,
                created: existingItem.created,
                changed: Date()
            )
        } else {
            item = ToDoItem(
                text: text,
                deadline: currentDeadline,
                importance: currentImportance,
                isDone: isDone,
                created: Date(),
                changed: nil
            )
        }
        
        fileCache.addItem(item)
        
        do {
            try fileCache.saveToFile(to: "TodoCache")
        } catch {
            print("Ошибка при сохранении файла: \(error)")
        }
    }
    @objc private func cancel() {
        dismiss(animated: true)
    }
    
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    //MARK: - Setup
    
    func setupNavigationBar() {
        let titleFont = UIFont.headline
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: titleFont
        ]
        navigationController?.navigationBar.titleTextAttributes = attributes
        title = "Дело"
        let leftButton = UIBarButtonItem(
            title: "Отменить",
            style: .plain,
            target: self,
            action: #selector(cancel)
        )
        
        let rightButton = UIBarButtonItem(
            title: "Сохранить",
            style: .done,
            target: self,
            action: #selector(saveItem)
        )
        navigationItem.leftBarButtonItem = leftButton //добавить цвет
        navigationItem.rightBarButtonItem = rightButton
        navigationItem.leftBarButtonItem?.tintColor = UIColor.Colors.colorBlue
        navigationItem.rightBarButtonItem?.tintColor = UIColor.Colors.colorBlue
    }
    
    func setupConstraints() {
        view.addSubview(settingsView)
        settingsView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            settingsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            settingsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            settingsView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            settingsView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
}

//MARK: - Extentions
extension ToDoItemController: ToDoItemSettingsViewDelegate {
    func importanceControlValueChanged(importance: Importance) {
        currentImportance = importance
    }
    
    func deadlineSwitcherValueChanged(deadline: Date?) {
        currentDeadline = deadline
    }
    
    func deleteItem() {
        guard let item = todoItem else { return }
        do {
            try fileCache.loadFromFile(from: "TodoCache")
            let deletedItem = fileCache.deleteItem(item.id)
            if deletedItem != nil {
                try fileCache.saveToFile(to: "TodoCache")
            } else {
                print("Ошибка: Элемент не найден")
            }
        } catch {
            print("Ошибка при удалении элемента: \(error)")
        }
    }

    
}

