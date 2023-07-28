//
//  ViewController.swift
//  TodoApp_CoreData
//
//  Created by Designer on 2023/06/28.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView! {
        didSet{
            tableView.delegate = self
            tableView.dataSource = self
            
            tableView.register(UINib(nibName: "TodoCell", bundle: nil), forCellReuseIdentifier: "TodoCell")
        }
    }
    
    var todoList = [ToDoList]()
    
    func fetchData() {
        guard let hasList = CoreDataManager.shared.fetchData(entity: ToDoList.self) else {
            return
        }
        self.todoList = hasList
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.title = "To Do List"
        // self.title = "To Do List"
        self.addRightBarButtonItem()
        
        self.fetchData()
        self.tableView.reloadData()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    private func addRightBarButtonItem() {
        let item = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createDoto))
        item.tintColor = .blue
        navigationItem.rightBarButtonItem = item
    }
    
    @objc func createDoto() {
        let detailVC = DetailTodoViewController(nibName: "DetailTodoViewController", bundle: nil)
        detailVC.delegate = self
        self.present(detailVC, animated: true)
    }
    
}

extension ViewController: DetailTodoViewControllerProtocol {
    func didFinishSave() {
        self.fetchData()
        self.tableView.reloadData()
    }
    
    
}
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath) as! TodoCell
        cell.topTitle.text = todoList[indexPath.row].title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        
        if let todoDate = todoList[indexPath.row].date {
            cell.bottomDate.text = formatter.string(from: todoDate)
        }
        
        let savedLevel = todoList[indexPath.row].priorityLevel
        let level = PriorityLevel(rawValue: savedLevel)
        cell.priorityLevel.backgroundColor = level?.color
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 테이블을 눌렀을때 표시되는 상태
        let detailVC = DetailTodoViewController(nibName: "DetailTodoViewController", bundle: nil)
        detailVC.delegate = self
        
        detailVC.todoItem = todoList[indexPath.row]
        
        self.present(detailVC, animated: true)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
}

