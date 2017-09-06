//
//  AnnotationView.swift
//  DemoSwiftyCam
//
//  Created by Jordan Russell Weatherford on 6/17/17.
//  Copyright © 2017 Cappsule. All rights reserved.
//

import UIKit
import HDAugmentedReality




class arAnnotationView: ARAnnotationView {
    
    var titleLabel: UILabel?
    var distanceLabel: UILabel?
    var image: UIImage?
    var count: Int = 1
    var username: String?
    var likes: Int?
    var background: UIImage?
    var viewSize: CGRect?
    var imageFrame: CGRect?
    var album_title_rect: CGRect?
    var like_thumb_rect: CGRect?
    var like_count_rect: CGRect?
    var photo_key: String?
    var pages: NSArray?
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        loadUI()
    }
    
    
    func loadUI() {
//      add 'likes' thumb
        let likeThumbLabel = UIButton(frame: like_thumb_rect!)
        likeThumbLabel.setImage(#imageLiteral(resourceName: "like"), for: .normal)
        
        
//      add 'likes' count label
        let likeCountLabel = UILabel(frame: like_count_rect!)
        likeCountLabel.font = UIFont(name: "Georgia", size: 14)
        likeCountLabel.textColor = UIColor.blue
        likeCountLabel.text = "\(likes!)!"
        
//      add 'album_title' label
        let album_title = UILabel(frame: album_title_rect!)
        album_title.font = UIFont(name: "Georgia", size: 30)
        album_title.textColor = UIColor.black
        album_title.text = username
        
        
//      add create image view and add image
        let clipart = UIImageView()
        clipart.frame = viewSize!
        clipart.image = background
    
        
//      add user image to UIImageView
        let imageView = UIImageView(image: image!)
        imageView.frame = imageFrame!
        imageView.layer.borderWidth = 2
        imageView.isUserInteractionEnabled = true
        
        
        //      set frame size of view for tap gesture recognizer
        self.frame = imageFrame!
        
//        //      ad gesture
//        let gesture = UITapGestureRecognizer()
//        gesture.addTarget(self, action: #selector(photoTapped))
//        self.addGestureRecognizer(gesture)
        
        
        
        clipart.addSubview(album_title)
        clipart.addSubview(imageView)
        clipart.addSubview(likeThumbLabel)
        clipart.addSubview(likeCountLabel)
        clipart.bringSubview(toFront: imageView)

        
        self.addSubview(clipart)
        
    }
}








