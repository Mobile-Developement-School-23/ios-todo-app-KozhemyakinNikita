//
//  ToDoListViewCell.swift
//  ToDoList
//
//  Created by Nik Kozhemyakin on 29.06.2023.
//

import UIKit

protocol ToDoListViewCellDelegate: AnyObject {
    func didUpdateToDoItem(_ item: ToDoItem, index: Int)
}

class ToDoListViewCell: UITableViewCell {
    static let reuseIdentifier = "TodoCell"
    weak var delegateCell: ToDoListViewCellDelegate?
    var viewModel: ToDoListCellModel?
    var todoItem: ToDoItem?
    let isDoneButton = UIButton()
    var textField = UILabel()
    var textViewStack = UIStackView()
    let calendar = UIImageView(image: UIImage(named: "calendar"))
    var deadlineView = UILabel()
    var deadlineStack = UIStackView()
    var statusStack = UIStackView()
    var importanceView = UIImageView()
    
    var isChecked = false {
        didSet {
            updateIcon()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Setup
    
    func setupCellsView(with todoItem: ToDoListCellModel) {
        self.viewModel = todoItem   //change
        let todoItem = todoItem.todoItem
        
        textField.text = todoItem.text
        textField.textColor = UIColor.Colors.labelPrimary
        textField.strikeThrough(todoItem.isDone)
        
        if todoItem.isDone == true {
            isDoneButton.setImage(UIImage(named: "radioButtonOn"), for: UIControl.State.normal)
            textField.textColor = UIColor.Colors.labelTertiary
            importanceView.isHidden = true
        } else if todoItem.importance == .important{
            isDoneButton.setImage(UIImage(named: "radioButtonHighPriority"), for: UIControl.State.normal)
            importanceView.image = UIImage(named: "quarks")
            importanceView.isHidden = false
        } else if todoItem.importance == .unimpurtant {
            isDoneButton.setImage(UIImage(named: "radioButtonOff"), for: UIControl.State.normal)
            importanceView.image = UIImage(named: "arrowLine")
            importanceView.isHidden = false
        } else {
            isDoneButton.setImage(UIImage(named: "radioButtonOff"), for: UIControl.State.normal)
            importanceView.isHidden = true
        }
        
        if let deadline = todoItem.deadline{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM"
            deadlineView.text = dateFormatter.string(from: deadline)
            deadlineStack.isHidden = false
        } else {
            deadlineStack.isHidden = true
        }
    }
    
    func setupView() {
        setupStatusOfItem()
        setupConstraints()
        setupTextField()
        setupDeadlineStack()
        setupTextViewStack()
        
    }
    
    func setupStatusOfItem() {
        isDoneButton.addTarget(self, action: #selector(iconButtonTapped(_:)), for: .touchUpInside)
        isDoneButton.layer.cornerRadius = 666
        
        statusStack.axis = .horizontal
        statusStack.spacing = 12
        statusStack.alignment = .center
    }
    
    func setupTextField() {
        textField.numberOfLines = 3
        textField.font = UIFont.body
        textField.textColor = UIColor.Colors.labelPrimary
    }
    
    func setupDeadlineStack() {
        deadlineView.font = UIFont.footnote
        deadlineView.textColor = UIColor.Colors.labelTertiary
        deadlineStack.axis = .horizontal
        deadlineStack.spacing = 2
        deadlineStack.alignment = .center
    }
    
    func setupTextViewStack() {
        textViewStack.axis = .vertical
        textViewStack.distribution = .fill
        textViewStack.alignment = .leading
    }
    
    private func updateIcon() {
        let imageName = isChecked ? "radioButtonOn" : "radioButtonOff"
        let image = UIImage(named: imageName)
        isDoneButton.setImage(image, for: .normal)
        viewModel?.toggleIsDone()
        guard let item = viewModel?.todoItem else {return}
        guard let index = viewModel?.index else {return}
        delegateCell?.didUpdateToDoItem(item, index: index)
    }
    @objc private func iconButtonTapped(_ sender: UIButton) {
        isChecked.toggle()
        
    }
    
    func setupConstraints() {
        contentView.addSubview(statusStack)
        statusStack.addArrangedSubview(isDoneButton)
        statusStack.addArrangedSubview(importanceView)
        contentView.addSubview(textViewStack)
        textViewStack.addArrangedSubview(textField)
        textViewStack.addArrangedSubview(deadlineStack)
        deadlineStack.addArrangedSubview(calendar)
        deadlineStack.addArrangedSubview(deadlineView)
        //        contentView.addSubview(textField)
        
        statusStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            statusStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            statusStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        isDoneButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            isDoneButton.widthAnchor.constraint(equalToConstant: 24),
            isDoneButton.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        importanceView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            importanceView.leadingAnchor.constraint(equalTo: isDoneButton.trailingAnchor, constant: 12),
            importanceView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        textViewStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textViewStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            textViewStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            textViewStack.leadingAnchor.constraint(equalTo: statusStack.trailingAnchor, constant: 16),
            textViewStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
        
        calendar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            calendar.heightAnchor.constraint(equalToConstant: 16),
            calendar.widthAnchor.constraint(equalToConstant: 16),
        ])
        
    }
}

extension UILabel {
    func strikeThrough(_ isStrikeThrough: Bool = true) {
        guard let text = self.text else {
            return
        }
        
        if isStrikeThrough {
            let attributeString =  NSMutableAttributedString(string: text)
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0,attributeString.length))
            self.attributedText = attributeString
        } else {
            let attributeString =  NSMutableAttributedString(string: text)
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle,
                                         value: [""],
                                         range: NSMakeRange(0,attributeString.length))
            self.attributedText = attributeString
        }
    }
}

