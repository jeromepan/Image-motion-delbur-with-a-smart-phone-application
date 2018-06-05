//
//  TableViewCell.swift
//  SeniorProject
//
//  Created by Sigh on 3/20/18.
//  Copyright © 2018 Sigh. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    @IBOutlet weak var picture: UIImageView!
    //@IBOutlet var filter: String!

    override func awakeFromNib() {
        super.awakeFromNib()
        picture.contentMode = .scaleAspectFit
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
