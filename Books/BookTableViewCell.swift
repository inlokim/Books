//
//  BookTableViewCell.swift
//  SpeakingBooks
//
//  Created by 김인로 on 2017. 3. 20..
//  Copyright © 2017년 김인로. All rights reserved.
//

import UIKit

class BookTableViewCell: UITableViewCell {
    
    //MARK: Properties
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var bookCover: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
