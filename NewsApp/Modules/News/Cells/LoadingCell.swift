//
//  LoadingCell.swift
//  NewsApp
//
//  Created by Viacheslav Tolstopiatenko on 3/26/20.
//  Copyright © 2020 Vicheslav Tolstopiatnko. All rights reserved.
//

import UIKit

class LoadingCell: UITableViewCell {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
