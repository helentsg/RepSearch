//
//  SearchViewController.swift
//  RepSearch
//
//  Created by  Елена on 04.02.2021.
//

import UIKit
import RealmSwift

class SearchViewController: UIViewController {
    
    @IBOutlet weak var selectedButton    : UIBarButtonItem!
    @IBOutlet weak var searchBar         : UISearchBar!
    @IBOutlet weak var activityIndicator : UIActivityIndicatorView!
    @IBOutlet weak var tableView         : UITableView!
    private var tapGesture : UITapGestureRecognizer!
    
    var viewModel: SearchViewModelProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
}

//MARK:- Setup View
extension SearchViewController {
    
    func setupView() {
        
        setupSubviews()
        setupTableView()
        
    }
    
    func setupSubviews() {
        
        viewModel = SearchViewModel(delegate: self)
        activityIndicator.hidesWhenStopped = true
        searchBar.delegate = self
        searchBar.setShowsCancelButton(false, animated: false)
        
    }
    
    func setupTableView() {
        
        tableView.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.prefetchDataSource = self
        
        tableView.estimatedRowHeight = 0
        tableView.rowHeight = 55
        
        /// Hide Empty rows:
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.tableFooterView?.isHidden = true
        
        /// Pull-To-Refresh:
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
    }
    
}



//MARK:- UITableViewDataSource
extension SearchViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.totalCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RepositoryCell
        if viewModel.isLoadingCell(for: indexPath) {
            cell.viewModel = viewModel.emptyCellViewModel()
        } else {
            cell.viewModel = viewModel.cellViewModel(at: indexPath)
        }
        return cell
    }
    
}

// MARK: - UITableViewDelegate
extension SearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        searchBar.resignFirstResponder()
        let repositoryVeiwModel = viewModel.viewModelForSelectedRow(at: indexPath)
        performSegue(withIdentifier: "fromSearchToRepository", sender: repositoryVeiwModel)
        
    }
    
}

//MARK:- Search Implementation:

extension SearchViewController : UISearchBarDelegate , AlertDisplayer {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.reload(_:)), object: searchBar)
        //Delay the search in case user is still typing characters
        perform(#selector(self.reload(_:)), with: searchBar, afterDelay: 0.75)
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if searchBar.text == viewModel.lastQuery {
            searchBar.resignFirstResponder()
        } else {
            reload(searchBar)
            searchBar.resignFirstResponder()
        }
        
    }
    
    @objc func reload(_ searchBar: UISearchBar) {
        
        //Checking for empty and whitespace strings ("   ")
        guard let text = searchBar.text, text.trimmingCharacters(in: .whitespaces) != "" else {
            return
        }
        viewModel.lastQuery = text
        activityIndicator.startAnimating()
        tableView.isHidden = true
        searchBar.setShowsCancelButton(false, animated: true)
        viewModel.fetchRepositories(with: text)
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        activityIndicator.stopAnimating()
        searchBar.resignFirstResponder()
        
    }
    
}

// MARK: - Pull-To-Refresh Implementation:
extension SearchViewController {
    
    @objc func pullToRefresh(_ sender: UIRefreshControl) {
        
        sender.endRefreshing()
        //Checking for empty and whitespace strings ("   ")
        guard let text = searchBar.text, text.trimmingCharacters(in: .whitespaces) != "" else {
            print("nothing to search")
            return
        }
        
        viewModel.fetchNewRepositories(with: text) {[weak self] result in
            
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(let indexPaths):
                self.tableView.insertRows(at: indexPaths, with: .automatic)
            case .failure(let error):
                let title = "Ошибка"
                let action = UIAlertAction(title: "OK", style: .default)
                self.displayAlert(with: title , message: error.description, actions: [action])
            }
        }
    }
}

// MARK: - Infinite Scrolling (Pagination) Implementation:
extension SearchViewController : UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        
        //Checking for empty and whitespace strings ("   ")
        guard let text = searchBar.text, text.trimmingCharacters(in: .whitespaces) != "" else {
            print("nothing to search")
            return
        }

        if indexPaths.contains(where: viewModel.isLoadingCell) {
            viewModel.fetchRepositories(with: text)
        }
        
    }
    
    func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath]) -> [IndexPath] {
        let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows ?? []
        let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
        return Array(indexPathsIntersection)
    }
    
}

extension SearchViewController : SearchViewModelDelegate {
    
    func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?) {
        
        activityIndicator.stopAnimating()
        searchBar.setShowsCancelButton(true, animated: true)
        tableView.isHidden = false
        guard let newIndexPathsToReload = newIndexPathsToReload else {
            tableView.reloadData()
            return
        }
        
        let indexPathsToReload = visibleIndexPathsToReload(intersecting: newIndexPathsToReload)
        tableView.reloadRows(at: indexPathsToReload, with: .automatic)
    }
    
    func onFetchFailed(with error: DataResponseError) {
        searchBar.resignFirstResponder()
        activityIndicator.stopAnimating()
        let title = "Ошибка"
        let action = UIAlertAction(title: "OK", style: .default)
        self.displayAlert(with: title , message: error.description, actions: [action])
    }
    
}


// MARK: - Actions:
extension SearchViewController {
    

    @IBAction func selectedButtonTapped() {
        activityIndicator.stopAnimating()
        searchBar.resignFirstResponder()
        let sender = viewModel.selectedViewModel()
        performSegue(withIdentifier: "fromSearchToSelected", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "fromSearchToRepository",
           let repositoryViewController = segue.destination as? RepositoryViewController {
            
            repositoryViewController.viewModel = sender as? RepositoryViewModelProtocol
            
        } else if segue.identifier == "fromSearchToSelected",
                  let selectedViewController = segue.destination as? SelectedViewController {
            
            selectedViewController.viewModel = sender as? SelectedViewModelProtocol
            
        }
        
    }
    
}
