//
//  NewCollectionCell.swift
//  NewsApp
//
//  Created by Viacheslav Tolstopiatenko on 3/23/20.
//  Copyright © 2020 Vicheslav Tolstopiatnko. All rights reserved.
//

import UIKit

class NewCollectionCell: UICollectionViewCell {


    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var organization: UILabel!
    @IBOutlet weak var title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
