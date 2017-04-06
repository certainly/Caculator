//
//  ImageTableViewCell.swift
//  Smashtag
//
//  Created by certainly on 2017/4/5.
//  Copyright © 2017年 certainly. All rights reserved.
//

import UIKit

class ImageTableViewCell: UITableViewCell {

    @IBOutlet weak var tweetImage: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var imageUrl: URL? { didSet { updateUI() } }
    
    fileprivate func updateUI() {
        if let url = imageUrl {
            spinner?.startAnimating()
            
            DispatchQueue.global(qos: .userInitiated).async {
                let loadedImageData = try? Data(contentsOf: url)
                DispatchQueue.main.async {
                    if url == self.imageUrl {
                        if let imageData = loadedImageData {
                            self.tweetImage?.image = UIImage(data: imageData)
                        }
                        self.spinner?.stopAnimating()
                    }
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
