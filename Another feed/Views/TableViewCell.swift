//
//  TableViewCell.swift
//  Another feed
//
//  Created by Дмитрий Вашлаев on 09.08.18.
//  Copyright © 2018 Дмитрий Вашлаев. All rights reserved.
//

import UIKit

enum cellLayoutSpacing: Int {
    case commonSpacing = 5
    case spacingToMargins = 15
}

class CustomCell: UITableViewCell {
    // MARK: - Public type properties
    static let imageViewSize: Int = 120
    var viewModel: CellViewModel? {
        didSet {
            setupCell()
        }
    }
    
    // MARK: - Public properties
    let newsTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    let newsDescription: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 4
        label.lineBreakMode = .byTruncatingTail
        label.font = UIFont.systemFont(ofSize: 14.0)
        return label
    }()
    
    let newsImage: UIImageView = {
        let image = UIImageView(frame: CGRect(x: 0, y: 0, width: imageViewSize, height: imageViewSize))
        
        image.backgroundColor = UIColor.blue
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        return image
    }()
    
    
    // MARK: - Initializers
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addUIElements()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    // MARK: - Public methods
    static func cellHeight() -> CGFloat {
        return CGFloat(CustomCell.imageViewSize + cellLayoutSpacing.commonSpacing.rawValue * 2)
    }
    
    
    // MARK: - Private methods
    private func addUIElements() {
        addSubview(newsImage)
        addSubview(newsTitle)
        addSubview(newsDescription)
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(cellLayoutSpacing.spacingToMargins.rawValue)-[v0(\(CustomCell.imageViewSize))]",
            options: NSLayoutFormatOptions(),
            metrics: nil,
            views: ["v0": newsImage]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-\(cellLayoutSpacing.commonSpacing.rawValue)-[v0(\(CustomCell.imageViewSize))]",
            options: NSLayoutFormatOptions(),
            metrics: nil,
            views: ["v0": newsImage]))
        
        let leftSpacing = CGFloat(cellLayoutSpacing.spacingToMargins.rawValue + cellLayoutSpacing.commonSpacing.rawValue + CustomCell.imageViewSize)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(leftSpacing)-[v0]-\(cellLayoutSpacing.spacingToMargins.rawValue)-|",
            options: NSLayoutFormatOptions(),
            metrics: nil,
            views: ["v0": newsTitle]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-\(cellLayoutSpacing.commonSpacing.rawValue)-[v0]",
            options: NSLayoutFormatOptions(),
            metrics: nil,
            views: ["v0": newsTitle]))
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(leftSpacing)-[v0]-\(cellLayoutSpacing.spacingToMargins.rawValue)-|",
            options: NSLayoutFormatOptions(),
            metrics: nil,
            views: ["v0": newsDescription]))
        newsDescription.topAnchor.constraint(equalTo: newsTitle.bottomAnchor, constant: CGFloat(cellLayoutSpacing.commonSpacing.rawValue)).isActive = true
    }
    
    private func setupCell() {
        newsTitle.text = viewModel?.title
        newsDescription.text = viewModel?.description
        newsImage.image = viewModel?.image
    }
}

