//
//  DetailTodoViewController.swift
//  TodoApp_CoreData
//
//  Created by Designer on 2023/06/28.
//

import UIKit
import CoreData

enum PriorityLevel: Int16 {
    case level1 = 1
    case level2 = 2
    case level3 = 3
}

extension PriorityLevel {
    var color: UIColor {
        switch self {
        case .level1: return UIColor(hex: "#36C0FD") ?? .black
        case .level2: return UIColor(hex: "#3636FD") ?? .black
        case .level3: return UIColor(hex: "#4E2EA5") ?? .black
        }
    }
    var title: String {
        switch self {
        case .level1:
            return "Low"
        case .level2:
            return "Normal"
        case .level3:
            return "High"
        }
    }
}

protocol DetailTodoViewControllerProtocol {
    func didFinishSave()
}

class DetailTodoViewController: UIViewController {
    
    var delegate: DetailTodoViewControllerProtocol?
    
    var todoItem: ToDoList?
    let appdelegate = (UIApplication.shared.delegate as! AppDelegate)
    var isPickerOpen = true
    let halfButtonHeight:CGFloat = 20
    var priorityLevel = PriorityLevel.level1
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var priorityLevel1: UIButton! {
        didSet{
            priorityLevel1.layer.cornerRadius = halfButtonHeight
            priorityLevel1.setTitle(PriorityLevel.level1.title, for: .normal)
        }
    }
    @IBOutlet weak var priorityLevel2: UIButton! {
        didSet{
            priorityLevel2.layer.cornerRadius = halfButtonHeight
            priorityLevel2.setTitle(PriorityLevel.level2.title, for: .normal)
        }
    }
    @IBOutlet weak var priorityLevel3: UIButton! {
        didSet{
            priorityLevel3.layer.cornerRadius = halfButtonHeight
            priorityLevel3.setTitle(PriorityLevel.level3.title, for: .normal)
        }
    }
    @IBOutlet weak var openCloseButton: UIButton!
    @IBOutlet weak var dataPickerHeight: NSLayoutConstraint!
    
    @IBAction func pickerOpenOrClose(_ sender: Any) {
        isPickerOpen.toggle()
        UIView.animate(withDuration: 0.5) {
            if self.isPickerOpen {
                // 열렸을때
                self.dataPickerHeight.priority = UILayoutPriority(240)
                self.openCloseButton.setTitle("Close", for: .normal)
                
            }else{
                // 닫혔을때
                self.dataPickerHeight.priority = UILayoutPriority(900)
                self.openCloseButton.setTitle("Open", for: .normal)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    func updateLevelDesign(level: PriorityLevel) {
        priorityLevel1.backgroundColor = .clear
        priorityLevel2.backgroundColor = .clear
        priorityLevel3.backgroundColor = .clear
        priorityLevel1.tintColor = .blue
        priorityLevel2.tintColor = .blue
        priorityLevel3.tintColor = .blue
        
        switch level {
        case .level1:
            priorityLevel1.backgroundColor = level.color
            priorityLevel1.tintColor = .white
        case .level2:
            priorityLevel2.backgroundColor = level.color
            priorityLevel2.tintColor = .white
        case .level3:
            priorityLevel3.backgroundColor = level.color
            priorityLevel3.tintColor = .white
        }
    }
    
    @IBAction func selectLevel(_ sender: UIButton) {
        if sender.currentTitle == PriorityLevel.level1.title  {
            // low일때 처리
            priorityLevel = .level1
        }else if sender.currentTitle == PriorityLevel.level2.title {
            // normal일때 처리
            priorityLevel = .level2
        }else if sender.currentTitle == PriorityLevel.level3.title {
            // high일때 처리
            priorityLevel = .level3
        }
        updateLevelDesign(level: priorityLevel)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        openCloseButton.setTitle("Close", for: .normal)
        if let todoItem = todoItem {
            saveButton.setTitle("Update", for: .normal)
            titleTextField.text = todoItem.title
            datePicker.date = todoItem.date ?? Date()
        let level = PriorityLevel(rawValue:todoItem.priorityLevel)
            priorityLevel = level ?? .level1
            updateLevelDesign(level: priorityLevel)
        }else {
            deleteButton.isHidden = true
        }
        
        self.hideKeyboardWhenTappedAround()
    }
    
    
    @IBAction func save(_ sender: Any) {
        
        if let todoItem = todoItem {
            // update
            CoreDataManager.shared.update(entity: todoItem) { entity in
                entity.title = titleTextField.text ?? ""
                entity.priorityLevel = priorityLevel.rawValue
                entity.date = datePicker.date
            }
            
//            appdelegate.saveContext()
            
            delegate?.didFinishSave()
            self.dismiss(animated: true)
            return
        }
        
        CoreDataManager.shared.create(entity: ToDoList.self) { entity in
            entity.title = titleTextField.text
            entity.priorityLevel = priorityLevel.rawValue
            entity.date = datePicker.date
            entity.id = UUID()
        }
        
        delegate?.didFinishSave()
        self.dismiss(animated: true)
    }
    
    
    @IBAction func deleteItem(_ sender: Any) {
        if let todoItem = todoItem {
            // delete
//            context.delete(todoItem)
//            CoreDataManager.shared.saveContext()
//            appdelegate.saveContext()
            // saveContext를 해야 로컬 DB에도 적용된다. 반드시 호출 필요
            CoreDataManager.shared.delete(entity: todoItem)
            delegate?.didFinishSave()
            self.dismiss(animated: true)
            
        }
        
    }
}

extension DetailTodoViewController {
    func hideKeyboardWhenTappedAround(){
        let tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
extension UIColor {
    convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                    b = CGFloat(hexNumber & 0x0000ff) / 255
                    a = 1
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
}
