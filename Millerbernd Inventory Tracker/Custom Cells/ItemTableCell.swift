//
//  ItemTableCell.swift
//  Millerbernd Inventory Tracker
//
//  Created by Kyle Jones on 5/26/19.
//  Copyright © 2019 Kyle Jones. All rights reserved.
//

import UIKit

class ItemTableCell: UITableViewCell {
    
    var categoryImageView = UIImageView()
    var skuCategoryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12.0)
        label.textColor = .lightGray
        return label
    }()
    var manufacturerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15.0)
        label.textColor = .darkGray
        return label
    }()
    var detailsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20.0)
        return label
    }()
    var quantityLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 12.0)
        label.textColor = .gray
        label.textAlignment = .right
        return label
    }()
    
    var item: Item? {
        didSet {
            inputItemData()
        }
    }
    
    let whiteBackground = UIView()
    let detailStackView = UIStackView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    override func layoutSubviews() {
        setupContentView()
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            whiteBackground.backgroundColor = .lightBlue
        } else {
            whiteBackground.backgroundColor = .white
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if selected {
            whiteBackground.backgroundColor = .lightBlue
            skuCategoryLabel.textColor = .gray
        } else {
            whiteBackground.backgroundColor = .white
            skuCategoryLabel.textColor = .lightGray
        }
    }
    
    func setupContentView() {
        backgroundColor = .white
        addSubview(whiteBackground)
        whiteBackground.backgroundColor = .white
        whiteBackground.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 5.0, paddingLeft: 5.0, paddingBottom: 5.0, paddingRight: 5.0, width: 0.0, height: 0.0, enableInsets: true)
        whiteBackground.layer.cornerRadius = 10.0
        whiteBackground.layer.shadowColor = UIColor.lightGray.cgColor
        whiteBackground.layer.shadowOpacity = 0.5
        whiteBackground.layer.shadowRadius = 5
        whiteBackground.layer.shadowOffset = CGSize(width: 0.5, height: 1.0)
        whiteBackground.layer.shadowPath = UIBezierPath(roundedRect: whiteBackground.bounds, cornerRadius: 10.0).cgPath
        detailStackView.addArrangedSubview(skuCategoryLabel)
        detailStackView.addArrangedSubview(manufacturerLabel)
        detailStackView.addArrangedSubview(detailsLabel)
        detailStackView.alignment = .leading
        detailStackView.distribution = .fillProportionally
        detailStackView.axis = .vertical
        whiteBackground.addSubview(categoryImageView)
        whiteBackground.addSubview(detailStackView)
        whiteBackground.addSubview(quantityLabel)
        categoryImageView.layer.masksToBounds = true
        categoryImageView.layer.cornerRadius = 10.0
        categoryImageView.contentMode = .scaleAspectFill
        categoryImageView.anchor(top: nil, left: whiteBackground.leftAnchor, bottom: nil, right: nil, paddingTop: 0.0, paddingLeft: 10.0, paddingBottom: 0.0, paddingRight: 0.0, width: 55, height: 55, enableInsets: false)
        categoryImageView.centerYAnchor.constraint(equalTo: whiteBackground.centerYAnchor).isActive = true
        detailStackView.anchor(top: whiteBackground.topAnchor, left: categoryImageView.rightAnchor, bottom: whiteBackground.bottomAnchor, right: quantityLabel.leftAnchor, paddingTop: 7.0, paddingLeft: 10.0, paddingBottom: 7.0, paddingRight: 0.0, width: 0.0, height: 0.0, enableInsets: true)
        quantityLabel.anchor(top: whiteBackground.topAnchor, left: nil, bottom: whiteBackground.bottomAnchor, right: whiteBackground.rightAnchor, paddingTop: 10.0, paddingLeft: 10.0, paddingBottom: 10.0, paddingRight: 10.0, width: 0.0, height: 0, enableInsets: true)
        
    }
    
    func inputItemData() {
        guard let item = item else {return}
        skuCategoryLabel.text = "\(item.SKU) · \(item.category.name)"
        manufacturerLabel.text = item.manufacturer
        detailsLabel.text = item.details
        let quantityString = NSMutableAttributedString(string: "Qty:\n")
        let attributes = [ NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24.0), NSAttributedString.Key.foregroundColor: item.isBelowMinimumStock ? UIColor.red : UIColor.black]
        let quantity = NSMutableAttributedString(string: String(item.totalQuantity), attributes: attributes)
        quantityString.append(quantity)
        quantityLabel.attributedText = quantityString
        if let image = CategoryController.shared.imageForCategory(id: item.category.id) {
            categoryImageView.image = image
        } else {
            let character = String(item.category.name.prefix(1))
            categoryImageView.image = UIImage(color: .gray, text: character)
        }
    }
    
}
