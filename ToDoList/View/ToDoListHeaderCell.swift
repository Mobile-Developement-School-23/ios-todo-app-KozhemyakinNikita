

import UIKit

class ToDoListHeaderCell: UITableViewHeaderFooterView {
    static let reuseIdentifier = "ToDoHeaderCell"
    var valueDidChange: (() -> Void)?
    let showButton = UIButton()
    var textViewLabel = UILabel()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        setupTextLabel()
        setupShowButton()
        setupConstraints()
    }
    
    func setupTextLabel() {
        textViewLabel.textColor = UIColor.Colors.labelTertiary
        textViewLabel.text = "Выполнено - \(listModel.fileCache.todoItems.filter( {$0.value.isDone} ).count)"
    }
    
    func setupShowButton() {
        showButton.addTarget(self, action: #selector(pressedButtonHeader), for: .touchUpInside)
        showButton.setTitle("Скрыть", for: .selected)
        showButton.setTitle("Показать", for: .normal)
        showButton.setTitleColor(.systemBlue, for: .normal)
    }
    
    func setupConstraints() {
        contentView.backgroundColor = UIColor.Colors.backPrimary
        contentView.addSubview(textViewLabel)
        contentView.addSubview(showButton)
        
        textViewLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textViewLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            textViewLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            textViewLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        ])
        
        showButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            showButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            showButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            showButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    @objc func pressedButtonHeader(_ button: UIButton) {
        if button.isSelected {
            listModel.changeIsHiddenStatus(to: IsHiddenItem.hideCompletedItems)
            showButton.isSelected = false
            self.valueDidChange?()
        } else {
            listModel.changeIsHiddenStatus(to: IsHiddenItem.showAllItems)
            showButton.isSelected = true
            self.valueDidChange?()
        }
    }
}
