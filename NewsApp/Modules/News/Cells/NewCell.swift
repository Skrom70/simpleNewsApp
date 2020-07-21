//
//  TableViewCell.swift
//  NewsApp
//
//  Created by Viacheslav Tolstopiatenko on 3/23/20.
//  Copyright © 2020 Vicheslav Tolstopiatnko. All rights reserved.
//

import UIKit

class NewCell: UITableViewCell {

    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var organization: UILabel!
    @IBOutlet weak var des: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
