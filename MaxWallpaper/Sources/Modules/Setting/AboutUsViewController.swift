//
//  AboutUsViewController.swift
//
//
//  Created by youngxkk on 2018/8/5.
//  Copyright © 2018 youngxkk. All rights reserved.
//

import UIKit

class AboutUsViewController: UIViewController {
    let aboutus:UILabel = UILabel()
    let setTitle:UILabel = UILabel()
    let closeBtn:UIButton = UIButton()
    let image:UIImage = UIImage(named: "max-logo")!
    let version:UILabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "setting_cell_about_us".localized
        view.backgroundColor = UIColor.black
        
        closeBtn.frame.size = CGSize(width: 39, height: 39)
        closeBtn.setBackgroundImage(UIImage(named: "navi_close"), for: .normal)
        closeBtn.adjustsImageWhenHighlighted = false
//        view.addSubview(closeBtn)
        
        setTitle.text = "About Us"
        setTitle.font = UIFont(name: "DINCond-Black", size: 24)
        setTitle.textColor = UIColor.white
        setTitle.textAlignment = .center
        setTitle.frame.size = CGSize(width: view.bounds.width, height: 64)
        setTitle.center.y = 10
//        view.addSubview(setTitle)
        
        let logo = UIImageView(image: image)
        logo.frame.size = CGSize(width: 100, height: 40)
        logo.center.x = view.bounds.width / 2
        logo.center.y = view.bounds.height / 2.8
        view.addSubview(logo)
        
        aboutus.text = "MAXC Studio is Very Cool"
        aboutus.font = UIFont(name: "DINCond-Black", size: 20)
        aboutus.textColor = UIColor.white
        aboutus.textAlignment = .center
        aboutus.frame.size = CGSize(width: view.bounds.width, height: 40)
        aboutus.center.y = view.bounds.height / 2.3
        view.addSubview(aboutus)
        
        
        version.text = "Version 1.0"
        version.font = UIFont(name: "DIN-Medium", size: 12)
        version.textColor = UIColor.gray
        version.textAlignment = .center
        version.frame.size = CGSize(width: view.bounds.width, height: 30)
        version.center.y = view.bounds.height * 0.9
        view.addSubview(version)
    }
}

