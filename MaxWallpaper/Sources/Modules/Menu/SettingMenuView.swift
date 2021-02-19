//
//  SettingMenuView.swift
//  MaxWallpaper
//
//  Created by elijah on 2018/7/7.
//  Copyright © 2018年 elijah. All rights reserved.
//

import Foundation
import UIKit

typealias DidSelectItemCallback = (_ idx: Int) -> Void

fileprivate let iconKey: String! = "iconKey"
fileprivate let titleKey: String! = "titleKey"
fileprivate let idxKey: String! = "idxKey"

class SettingMenuView: UIView {
    class var recommendSize: CGSize {
        get { return CGSize.init(width: 240, height: 192)
        }
    }
    
    fileprivate let items: Array<Dictionary<String, Any>>! = [
        [iconKey: "ic_menu_feedback", titleKey: "home_setting_menu_feedback".localized, idxKey: 0],
        [iconKey: "ic_menu_setting", titleKey: "home_setting_menu_setting".localized, idxKey: 1],
        [iconKey: "ic_menu_share", titleKey: "home_setting_menu_share_app".localized, idxKey: 2]]

    fileprivate lazy var tableView: UITableView = {
        let view = UITableView.init(frame: CGRect.zero, style: .plain)
        view.backgroundColor = UIColor.clear
        view.separatorStyle = .none
        view.delegate = self
        view.dataSource = self
        view.rowHeight = SettingMenuTableViewCell.recommendHeight
        view.sectionHeaderHeight = 18
        view.register(SettingMenuTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(SettingMenuTableViewCell.self))
        view.tableFooterView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 18))
        view.isScrollEnabled = false
        return view
    }()
    
    var selectCallback: DidSelectItemCallback?
    
    override init(frame:CGRect){
        super.init(frame: frame)
        self.configUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configUI() -> Void {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: self.tableView.bounds.height)
        self.backgroundColor = HexColor(hex: 0xFF0073, alpha: 0.9)
        self.addSubview(self.tableView)
        self.addSubview(blurEffectView)
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
    }
}

extension SettingMenuView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SettingMenuTableViewCell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(SettingMenuTableViewCell.self), for: indexPath) as! SettingMenuTableViewCell
        let data: Dictionary<String, Any>! = items[indexPath.section]
        cell.setData(icon: data[iconKey] as? String, title: data[titleKey] as? String)
//        cell.selectedBackgroundView = UIView()
//        cell.selectedBackgroundView?.backgroundColor = UIColor.black
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < items.count {
            if let closure = selectCallback {
                closure(indexPath.section)
            }
            self.removeFromSuperview()
        }
    }
}
