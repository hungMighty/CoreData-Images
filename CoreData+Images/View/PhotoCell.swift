//
//  PhotoCell.swift
//  CoreDataTutorial
//
//  Created by James Rochabrun on 3/1/17.
//  Copyright © 2017 James Rochabrun. All rights reserved.
//

import Foundation
import UIKit


class PhotoCell: UITableViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var dividerLineView: UIView!
    @IBOutlet weak var tagsLabel: UILabel!
    
    static let id = String(describing: PhotoCell.self)
    static let nibName = String(describing: PhotoCell.self)
    
    var photo: Photo? {
        didSet {
            guard let photo = photo else {
                return
            }
            self.authorLabel.text = photo.author
            self.tagsLabel.text = photo.tags
            
            if let url = photo.mediaURL {
                self.photoImageView
                    .loadImageUsingCacheWithURLString(url,
                                                      placeHolder: UIImage(named: "placeholder"))
            }
        }
    }
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        isUserInteractionEnabled = false
        authorLabel.font = UIFont.systemFont(ofSize: 16)
        tagsLabel.font = UIFont.systemFont(ofSize: 14)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
}


