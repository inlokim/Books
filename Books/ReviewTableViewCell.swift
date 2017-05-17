//
//  ReviewTableViewCell.swift
//  Books
//
//  Created by 김인로 on 2017. 5. 12..
//  Copyright © 2017년 김인로. All rights reserved.
//

import UIKit

class ReviewTableViewCell: UITableViewCell {
    
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var writerLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
