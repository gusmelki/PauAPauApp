//
//  DetalhesContatoTableViewCell.swift
//  PauAPau
//
//  Created by Gustavo Melki Leal on 13/04/15.
//  Copyright (c) 2015 Melki. All rights reserved.
//

import UIKit


class DetalhesContatoTableViewCell: UITableViewCell {

 
    @IBOutlet weak var imagem: UIImageView!
    @IBOutlet weak var titulo: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
