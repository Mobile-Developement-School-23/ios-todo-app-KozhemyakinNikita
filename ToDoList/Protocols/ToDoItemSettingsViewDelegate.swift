import UIKit

protocol ToDoItemSettingsViewDelegate: AnyObject {
    func importanceControlValueChanged(importance: Importance)
    func deadlineSwitcherValueChanged(deadline: Date?)
    func deleteItem()
}
