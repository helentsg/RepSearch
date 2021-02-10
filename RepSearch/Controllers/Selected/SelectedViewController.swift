//
//  SelectedViewController.swift
//  RepSearch
//
//  Created by  Елена on 04.02.2021.
//

import UIKit

class SelectedViewController: UIViewController {
    
    @IBOutlet weak var tableView     : UITableView!
    @IBOutlet weak var emptyLabel    : UILabel!
    
    var viewModel: SelectedViewModelProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateSelected()
    }
    
}

//MARK:- Setup Table View:
extension SelectedViewController {
    
    func setupTableView() {
        
        emptyLabel.text = "У вас сейчас нет избранных репозиториев. Вернитесь на экран \"Поиск\", нажмите на строку и на экране \"Репозиторий\" добавьте в избранное. Ждём вас снова!"
        emptyLabel.isHidden = !viewModel.isEmpty
        
        tableView.isHidden = viewModel.isEmpty
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 0
        tableView.rowHeight = 55
        
        /// Hide Empty rows:
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.tableFooterView?.isHidden = true
        
    }
    
}

// MARK: - Table view data source
extension SelectedViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.currentCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SelectedCell
        cell.viewModel = viewModel.cellViewModel(at: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            viewModel.remove(at: indexPath)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
    }
    
}

// MARK: - UITableViewDelegate
extension SelectedViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        let repositoryVeiwModel = viewModel.viewModelForSelectedRow(at: indexPath)
        performSegue(withIdentifier: "fromSelectedToRepository", sender: repositoryVeiwModel)
        
    }
    
}

// MARK: - Actions:
extension SelectedViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "fromSelectedToRepository",
           let repositoryViewController = segue.destination as? RepositoryViewController {
            
            repositoryViewController.viewModel = sender as? RepositoryViewModelProtocol
            
        }
        
    }
    
    private func updateSelected() {
        
        viewModel.updateSelected()
        tableView.reloadData()
        
    }
    
}
