import Foundation
import UIKit

protocol ToDoListDelegate: AnyObject {
    func didUpdateToDoItem(_ item: ToDoItem)
}

class ToDoItemController: UIViewController {
    weak var delegate: ToDoItemSettingsViewDelegate?
    weak var delegateToDoList: ToDoListDelegate?
    let fileCache = FileCache()
    var todoItem: ToDoItem?
    let scrollView = UIScrollView()
    var isNew: Bool = false
    weak var listViewController: ToDoListViewController?
    lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.backgroundColor = UIColor.Colors.backPrimary
        stack.spacing = 16.0
        return stack
    }()
    lazy var textView: UITextView = {
        let txtView = UITextView()
        txtView.isScrollEnabled = false
        txtView.textColor = UIColor.Colors.labelTertiary
        txtView.text = "Что надо сделать?"
        txtView.font = .body
        txtView.textContainerInset = UIEdgeInsets(top: 17, left: 16, bottom: 12, right: 16)
        txtView.layer.cornerRadius = 16
        txtView.backgroundColor = UIColor.Colors.backSecondary
        txtView.delegate = self
        return txtView
    }()
    lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Удалить", for: .normal)
        button.tintColor = UIColor.Colors.colorRed
        button.titleLabel?.font = UIFont.body
        button.backgroundColor = UIColor.Colors.backSecondary
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.isEnabled = false
        button.addTarget(
            self,
            action: #selector(deleteItem),
            for: .touchUpInside
        )
        return button
    }()
    private var currentText = String()
    private var currentImportance = Importance.common
    private var currentDeadline: Date? = nil
    let settingsView = ToDoItemSettingsView()
    var cancelButton: UIBarButtonItem?
    var saveButton: UIBarButtonItem?
    var listViewCell = ToDoListViewCell()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        view.backgroundColor = UIColor.Colors.backPrimary
        setupNavigationBar()
        checkTodoItem()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        settingsView.delegate = self

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        scrollView.keyboardDismissMode = .interactive
    }
    // MARK: - Actions
    @objc func saveItem() {
        var importance: Importance = .common
        switch settingsView.importanceControl.selectedSegmentIndex {
        case 0: importance = .unimpurtant
        case 2: importance = .important
        default: importance = .common
        }
        let deviceID = UIDevice.current.identifierForVendor?.uuidString ?? ""

        if todoItem != nil {
            let newItem = ToDoItem(
                id: todoItem?.id ?? "",
                text: textView.text,
                deadline: settingsView.deadlineSwitcher.isOn ? settingsView.deadlineDatePicker.date : nil,
                importance: importance,
                isDone: false,
                created: Date(),
                changed: Date(),
                lastUpdatedBy: deviceID
            )
            todoItem = newItem
            listModel.saveTask(item: newItem)
        } else {
            let newItem = ToDoItem(
                text: textView.text,
                deadline: settingsView.deadlineSwitcher.isOn ? settingsView.deadlineDatePicker.date : nil,
                importance: importance,
                isDone: false,
                created: Date(),
                changed: Date(),
                lastUpdatedBy: deviceID
            )
//            todoItem = newItem
//            listModel.saveTask(item: newItem)
            addTodoItem(newItem)
            listViewController?.reloadData()
        }
        dismiss(animated: true)
    }
    @objc private func cancel() {
        dismiss(animated: true)
    }
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let keyboardSize = (
            notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]as? NSValue
        )?.cgRectValue else {
            return
        }
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        var visibleRect = self.view.frame
        visibleRect.size.height -= keyboardSize.height
        if let activeField = findActiveField(in: scrollView) {
            if !visibleRect.contains(activeField.frame.origin) {
                scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }
    @objc func keyboardWillHide(_ notification: Notification) {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    private func findActiveField(in view: UIView) -> UIView? {
        for subview in view.subviews {
            if let textField = subview as? UITextField, textField.isFirstResponder {
                return textField
            }
            if let textView = subview as? UITextView, textView.isFirstResponder {
                return textView
            }
            if let found = findActiveField(in: subview) {
                return found
            }
        }
        return nil
    }
    
    private func addTodoItem(_ item: ToDoItem) {
        Task {
            do {
                try await listModel.addNewItem(item)
            } catch {
                print("Error added item", error)
            }
        }
    }
    
    // MARK: - Setup
    func setupNavigationBar() {
        let titleFont = UIFont.headline
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: titleFont
        ]
        navigationController?.navigationBar.titleTextAttributes = attributes
        title = "Дело"
        let cancelButton = UIBarButtonItem(
            title: "Отменить",
            style: .plain,
            target: self,
            action: #selector(cancel)
        )
        saveButton = UIBarButtonItem(
            title: "Сохранить",
            style: .done,
            target: self,
            action: #selector(saveItem)
        )
        navigationItem.leftBarButtonItem = cancelButton // добавить цвет
        navigationItem.rightBarButtonItem = saveButton
        navigationItem.leftBarButtonItem?.tintColor = .blue
        navigationItem.rightBarButtonItem?.tintColor = UIColor.Colors.colorBlue
    }
    func checkTodoItem() {
        guard let todoItem else {
            return
        }
        textView.text = todoItem.text
        textView.textColor = UIColor.Colors.labelPrimary
        if todoItem.importance == .unimpurtant {
            settingsView.importanceControl.selectedSegmentIndex = 0
        } else if todoItem.importance == .common {
            settingsView.importanceControl.selectedSegmentIndex = 1
        } else {
            settingsView.importanceControl.selectedSegmentIndex = 2
        }
        if let deadline = todoItem.deadline {
            let formattedDate = settingsView.dateFormatter.string(from: deadline)
            settingsView.deadlineDate.setTitle(formattedDate, for: .normal)
            settingsView.deadlineDatePicker.date = deadline
            settingsView.deadlineSwitcher.isOn = true
            settingsView.deadlineDate.isHidden = false
        }
        saveButton?.tintColor = .blue
        deleteButton.isEnabled = true
    }
    func setupConstraints() {
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        stackView.addArrangedSubview(textView)
        stackView.addArrangedSubview(settingsView.verticalSubStack)
        stackView.addArrangedSubview(deleteButton)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor)
        ])
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: stackView.topAnchor),
            textView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 120)
        ])
        deleteButton.heightAnchor.constraint(equalToConstant: 56).isActive = true

    }
    func resetButtons() {
        saveButton?.isEnabled = false
        textView.text = "Что надо сделать?"
        textView.textColor = UIColor.Colors.labelTertiary
        settingsView.importanceControl.selectedSegmentIndex = 1
                settingsView.deadlineDatePicker.date = Date()
        settingsView.setupDatePicker()
        settingsView.deadlineSwitcher.isOn = false
        deleteButton.isEnabled = false
        settingsView.deadlineDatePicker.isHidden = true
    }
}

// MARK: - Extentions
extension ToDoItemController: ToDoItemSettingsViewDelegate {
    func importanceControlValueChanged(importance: Importance) {
        currentImportance = importance
    }
    func deadlineSwitcherValueChanged(deadline: Date?) {
        currentDeadline = deadline
    }
    @objc func deleteItem() {
        guard let item = todoItem else { return }
//        let fc = FileCache()
//        try? fc.loadFromFile(from: "TodoCache")
        listModel.deleteTask(id: item.id)
        resetButtons()
        settingsView.deadlineDate.isHidden = true
        dismiss(animated: true)
    }
}

extension ToDoItemController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.Colors.labelTertiary{
            textView.text = nil
            textView.textColor = UIColor.Colors.labelPrimary
            saveButton?.isEnabled = true
            saveButton?.tintColor = UIColor.Colors.colorBlue
        }
        
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Что надо сделать?"
            textView.textColor = UIColor.Colors.labelTertiary
            saveButton?.isEnabled = false
            saveButton?.tintColor = .blue
        }
        textView.resignFirstResponder()
    }
}

extension ToDoItemController: ToDoListViewCellDelegate {
    func didUpdateToDoItem(_ item: ToDoItem, index: Int) {
//        listModel.toDoItems[item.id] = item // заменить элемент
        listModel.listViewController?.tableView.reloadData()// обновление таблицы
//        listModel.saveTask(item: item)
        addTodoItem(item)
    }
}
