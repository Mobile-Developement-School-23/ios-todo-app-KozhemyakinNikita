

import UIKit
 
//class ViewController: UIViewController {
// 
//    var todoItem: [String: ToDoItem] = [:]
//    func loadData() {
//        var fileCache = FileCache()
//        do {
//            try fileCache.loadFromFile(from: "TodoCache")
//            todoItem = fileCache.todoItems
//            fileCache.todoItems.forEach { (key: String, value: ToDoItem) in
//                print(value.text)
//            }
//        } catch {
//            print("error")
//        }
// 
// 
// 
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view.
//        loadData()
//    }
// 
// 
//}

class ViewController: UIViewController {
    let creationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("+", for: .normal)
        button.backgroundColor = .blue
        button.addTarget(nil, action: #selector(creationButtonDidTapped), for: .touchUpInside)
        button.layer.cornerRadius = 0.5 * 44
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let creationViewController = ToDoItemController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setConstraints()

        let fc = FileCache()
        try? fc.loadFromFile(from: "TodoCache")
        creationViewController.todoItem = fc.todoItems.first?.value
        print(fc.todoItems.first?.value)
        
    }
    
    func loadFromfile() {
        
    }
    
    
    func setupView() {
        view.backgroundColor = UIColor.Colors.backPrimary
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Мои дела"
        view.addSubview(creationButton)
    }

    
    @objc func creationButtonDidTapped() {
        let test = UINavigationController(rootViewController: creationViewController)
        creationViewController.checkTodoItem()
        present(test, animated: true)
    }
    
}

extension ViewController {
    func setConstraints() {
        NSLayoutConstraint.activate([
            creationButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            creationButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            creationButton.widthAnchor.constraint(equalToConstant: 44),
            creationButton.heightAnchor.constraint(equalToConstant: 44),
            
        ])
    }
}
