//
//  RoundedButton.swift
//  RepSearch
//
//  Created by  Елена on 05.02.2021.
//

import Foundation
import UIKit

final class RoundedButton: UIButton {
    
    // MARK: - Init
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
}

// MARK: - Configure:
extension RoundedButton {
    
    func configure(for isSelected: Bool) {
        alpha = isSelected ? 0.8 : 1
        backgroundColor = isSelected ? #colorLiteral(red: 0.9567686915, green: 0.9569287896, blue: 0.9610529542, alpha: 1) : UIColor(named: "myBlue")
        let titleColor = isSelected ? #colorLiteral(red: 0.7411026955, green: 0.7412287593, blue: 0.7539924979, alpha: 1) : #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        setTitleColor(titleColor, for: .normal)
        let title = isSelected ? "Убрать из избранных" : "Добавить в избранные"
        setTitle(title, for: .normal)
    }
    
}

// MARK: - View Setup
private extension RoundedButton {
    
    func setupView() {
        
        layer.cornerRadius = 30
        layer.shadowColor = UIColor.systemGray3.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 16)
        layer.shadowOpacity = 1
        layer.shadowRadius = 10
        layer.masksToBounds = false
        
    }
}

