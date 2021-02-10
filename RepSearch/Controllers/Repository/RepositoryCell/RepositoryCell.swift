//
//  RepositoryCell.swift
//  RepSearch
//
//  Created by  Елена on 04.02.2021.
//

import UIKit

class RepositoryCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel     : UILabel!
    @IBOutlet weak var activityView  : UIActivityIndicatorView!
    
    var viewModel: RepositoryCellViewModelProtocol! {
        didSet {
            configure(with: viewModel.name)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        configure(with: .none)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        activityView.hidesWhenStopped = true
        
    }
    
}

//MARK:- Cell Configuration:
extension RepositoryCell {
    
    func configure(with text: String?) {
        if let text = text {
            nameLabel?.text = text
            nameLabel?.alpha = 1
            activityView.stopAnimating()
        } else {
            nameLabel?.text = nil
            nameLabel?.alpha = 0
            activityView.startAnimating()
        }
    }
}
