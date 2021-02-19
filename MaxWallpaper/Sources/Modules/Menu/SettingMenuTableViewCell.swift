//
//  SettingMenuTableViewCell.swift
//  MaxWallpaper
//
//  Created by elijah on 2018/7/7.
//  Copyright © 2018年 elijah. All rights reserved.
//

import Foundation
import UIKit

class SettingMenuTableViewCell: UITableViewCell {
    class var recommendHeight: CGFloat {
        get { return 40 }
    }
    
    private lazy var iconView: UIImageView = {
        let view: UIImageView = UIImageView()
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label: UILabel = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont(name: "DINCond-Black", size: 17)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier:String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setData(icon: String?, title: String?) -> Void {
        if let name = icon {
            iconView.image = UIImage(named: name)
        } else {
            iconView.image = nil
        }
        titleLabel.text = title
    }
    
    private func configUI() -> Void {
        backgroundColor = UIColor.clear
        selectionStyle = .none;
        contentView.addSubview(iconView)
        contentView.addSubview(titleLabel)
        iconView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(25)
            make.size.equalTo(CGSize.init(width: 18, height: 18))
        }
        self.titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(iconView.snp.right).offset(10)
        }
    }
}
