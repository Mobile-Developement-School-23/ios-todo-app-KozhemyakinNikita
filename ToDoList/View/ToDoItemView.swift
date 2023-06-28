

import Foundation
import UIKit


class ToDoItemSettingsView: UIView {
    weak var delegate: ToDoItemSettingsViewDelegate?
    let importanceLabel = UILabel()
    let importanceControl = UISegmentedControl(items:
                                                [UIImage(named: "arrowLine") as Any,
                                                 "нет",
                                                 UIImage(named: "quarks") as Any]
    )
    let deadlineDatePicker = UIDatePicker()
    let deadlineLabel = UILabel()
    let additionalView = UIView()
    let deadLineAdditionalView = UIView()
    let firstSpacer = UIView()
    let deadlineSwitcher = UISwitch()
    
    var isDatePickerVisible = false
    
    let secondSpacer = UIView()
    
    lazy var verticalSubStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.backgroundColor = UIColor.Colors.backSecondary
        stack.layer.cornerRadius = 16
        return stack
    }()
    
    private lazy var importanceHStack: UIStackView = {
        let importanceStack = UIStackView()
        importanceStack.axis = .horizontal
        importanceStack.backgroundColor = UIColor.Colors.backSecondary
        
        importanceStack.addArrangedSubview(importanceLabel)
        importanceStack.addArrangedSubview(importanceControl)
        
        importanceLabel.text = "Важность"
        importanceControl.selectedSegmentIndex = 1
        importanceControl.addTarget(self, action: #selector(importanceControlValueChanged), for: .valueChanged)
        return importanceStack
    }()
    
    private lazy var deadlineHStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.backgroundColor = UIColor.Colors.backSecondary
        deadlineLabel.text = "Сделать до"
        deadlineDatePicker.isHidden = true
        return stack
    }()
    private lazy var deadlineStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        return stack
    }()
    
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }()
    
    lazy var deadlineDate: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(UIColor.Colors.colorBlue, for: .normal) 
        button.titleLabel?.font = UIFont.footnote
        button.contentHorizontalAlignment = .left
        button.isHidden = true
        button.addTarget(self, action: #selector(deadlineDateButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
        setupFirstSpacer()
        setupSecondSpacer()
        setupDatePicker()
        setupSwitcher()
    }
    
    func setupConstraints() {
        addSubview(verticalSubStack)
        verticalSubStack.addArrangedSubview(additionalView)
        
        additionalView.addSubview(importanceHStack)
        additionalView.addSubview(firstSpacer)
        
        verticalSubStack.addArrangedSubview(deadLineAdditionalView)
        
        deadLineAdditionalView.addSubview(deadlineHStack)
        deadlineHStack.addArrangedSubview(deadlineStack)
        
        [deadlineLabel,
         deadlineDate
        ].forEach {
            deadlineStack.addArrangedSubview($0)
        }
        
        deadlineHStack.addArrangedSubview(deadlineSwitcher)
        
        deadLineAdditionalView.addSubview(secondSpacer)
        
        verticalSubStack.addArrangedSubview(deadlineDatePicker)
        
        verticalSubStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            verticalSubStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            verticalSubStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            verticalSubStack.widthAnchor.constraint(equalTo: widthAnchor),
        ])
        
        additionalView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            additionalView.heightAnchor.constraint(equalToConstant: 56.25)
        ])
        
        importanceHStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            importanceHStack.leadingAnchor.constraint(equalTo: additionalView.leadingAnchor, constant: 16),
            importanceHStack.trailingAnchor.constraint(equalTo: additionalView.trailingAnchor, constant: -16),
            importanceHStack.topAnchor.constraint(equalTo: additionalView.topAnchor, constant: 10),
            importanceHStack.bottomAnchor.constraint(equalTo: additionalView.bottomAnchor, constant: -10)
        ])
        
        firstSpacer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            firstSpacer.leadingAnchor.constraint(equalTo: additionalView.leadingAnchor, constant: 16),
            firstSpacer.trailingAnchor.constraint(equalTo: additionalView.trailingAnchor, constant: -16),
            firstSpacer.heightAnchor.constraint(equalToConstant: 0.5),
            firstSpacer.bottomAnchor.constraint(equalTo: additionalView.bottomAnchor)
        ])
        
        deadLineAdditionalView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            deadLineAdditionalView.heightAnchor.constraint(equalToConstant: 56.25)
        ])
        
        deadlineHStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            deadlineHStack.leadingAnchor.constraint(equalTo: deadLineAdditionalView.leadingAnchor, constant: 16),
            deadlineHStack.trailingAnchor.constraint(equalTo: deadLineAdditionalView.trailingAnchor, constant: -16),
            deadlineHStack.topAnchor.constraint(equalTo: deadLineAdditionalView.topAnchor, constant: 10),
            deadlineHStack.bottomAnchor.constraint(equalTo: deadLineAdditionalView.bottomAnchor, constant: -10)
        ])
        
        secondSpacer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            secondSpacer.leadingAnchor.constraint(equalTo: deadLineAdditionalView.leadingAnchor, constant: 16),
            secondSpacer.trailingAnchor.constraint(equalTo: deadLineAdditionalView.trailingAnchor, constant: -16),
            secondSpacer.heightAnchor.constraint(equalToConstant: 0.5),
            secondSpacer.bottomAnchor.constraint(equalTo: deadLineAdditionalView.bottomAnchor)
        ])
        
    }
    
    //MARK: - Setup
    
    func setupFirstSpacer() {
        firstSpacer.backgroundColor = UIColor.Colors.supportSeparator
    }
    
    func setupSecondSpacer() {
        secondSpacer.backgroundColor = UIColor.Colors.supportSeparator
        secondSpacer.isHidden = true
    }
    
    func setupDatePicker() {
        deadlineDatePicker.addTarget(self, action: #selector(deadlineDatePickerValueChanged), for: .valueChanged)
        
        let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: Date())
        deadlineDatePicker.date = nextDay ?? Date()
        
        deadlineDatePicker.datePickerMode = .date
        deadlineDatePicker.calendar.firstWeekday = 2
        let calendar = Calendar.current
        deadlineDatePicker.minimumDate = calendar.startOfDay(for: Date())
    }
    
    func setupSwitcher() {
        deadlineSwitcher.addTarget(self, action: #selector(deadlineSwitcherValueChanged), for: .valueChanged)
    }
    
    
    
    //MARK: - Actions
    
    @objc func importanceControlValueChanged() {
        let selectedSegmentIndex = importanceControl.selectedSegmentIndex
        var importance: Importance = .common
        
        switch selectedSegmentIndex {
        case 0:
            importance = Importance.unimpurtant
        case 2:
            importance = Importance.important
        default:
            importance = Importance.common
        }
        delegate?.importanceControlValueChanged(importance: importance)
    }
    
    @objc func deadlineSwitcherValueChanged() {
        if deadlineSwitcher.isOn {
            deadlineDate.isHidden = false
            let selectedDate = deadlineDatePicker.date
            let formattedDate = dateFormatter.string(from: selectedDate)
            deadlineDate.setTitle(formattedDate, for: .normal)
        } else {
            deadlineDate.isHidden = true
            UIView.animate(withDuration: 0.3) {
                self.deadlineDatePicker.alpha = 0.0
            } completion: { _ in
                self.deadlineDatePicker.isHidden = true
                self.secondSpacer.isHidden = true
            }
            isDatePickerVisible = false
            secondSpacer.isHidden = true
            
        }
    }
    
    @objc func deadlineDateButtonTapped() {
        deadlineDatePicker.preferredDatePickerStyle = .inline
        if isDatePickerVisible {
            UIView.animate(withDuration: 0.3) {
                self.deadlineDatePicker.alpha = 0.0
            } completion: { _ in
                self.deadlineDatePicker.isHidden = true
                self.secondSpacer.isHidden = true
            }
            isDatePickerVisible = false
        } else {
            deadlineDatePicker.alpha = 0.0
            deadlineDatePicker.isHidden = false
            UIView.animate(withDuration: 1.0) {
                self.secondSpacer.isHidden = false
                self.deadlineDatePicker.alpha = 1.0
            }
            isDatePickerVisible = true
        }
    }
    
    @objc func deadlineDatePickerValueChanged() {
        let selectedDate = deadlineDatePicker.date
        let formattedDate = dateFormatter.string(from: selectedDate)
        deadlineDate.setTitle(formattedDate, for: .normal)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}





