//
//  test.swift
//  DemoSwiftyCam
//
//  Created by Jordan Russell Weatherford on 6/23/17.
//  Copyright © 2017 Cappsule. All rights reserved.
//

import UIKit

class test: UIView {
    var image: UIImage?

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var pagesLabel: UILabel!
    @IBOutlet weak var photoView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInitialization()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInitialization()

    }
    
    
    func commonInitialization() {
        let view = Bundle.main.loadNibNamed("test", owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
    }
}
