//
//  SelectedCell.swift
//  RepSearch
//
//  Created by  Елена on 07.02.2021.
//

import UIKit

class SelectedCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel     : UILabel!
    
    var viewModel: SelectedCellViewModelProtocol! {
        didSet {
            configure(with: viewModel.name)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        configure(with: .none)
    }
    
}

//MARK:- Cell Configuration:
extension SelectedCell {
    
    func configure(with text: String?) {
        if let text = text {
            nameLabel?.text = text
            nameLabel?.alpha = 1
        } else {
            nameLabel?.text = nil
            nameLabel?.alpha = 0
        }
    }
}

