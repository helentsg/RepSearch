//
//  RepositoryViewController.swift
//  RepSearch
//
//  Created by  Елена on 04.02.2021.
//

import UIKit

class RepositoryViewController: UIViewController {
    
    @IBOutlet weak var repositoryNameLabel : UILabel!
    @IBOutlet weak var repositoryDescriptionLabel : UILabel!
    @IBOutlet weak var ownerNameLabel : UILabel!
    @IBOutlet weak var ownerEmailLabel : UILabel!
    @IBOutlet weak var button : RoundedButton!
    
    var viewModel: RepositoryViewModelProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
    }
    
}

//MARK:- Setup View
extension RepositoryViewController {
    
    func setupView() {
        
        repositoryNameLabel.text = viewModel.repositoryName
        repositoryDescriptionLabel.text = viewModel.repositoryDescription
        ownerNameLabel.text = viewModel.ownerName
        ownerEmailLabel.text = viewModel.ownerEmail
        button.configure(for: viewModel.isSelected)
        
    }
    
}

//MARK:- Actions:
extension RepositoryViewController {
    
    @IBAction func buttonPressed() {
        
        viewModel.isSelected.toggle()
        button.configure(for: viewModel.isSelected)
        viewModel.isSelected ? viewModel.save() : viewModel.removeFromSelected()
        
    }
    
}
