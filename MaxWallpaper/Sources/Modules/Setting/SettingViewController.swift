//
//  SettingViewController.swift
//  test
//
//  Created by youngxkk on 2018/8/5.
//  Copyright © 2018 youngxkk. All rights reserved.
//
import Foundation
import UIKit

class SettingViewController: UIViewController {
    // tableView 的数据，设置的各项功能
    var dataList = [["setting_cell_feedback".localized,"setting_cell_soundSwitch".localized,"setting_cell_rate_us".localized],["setting_cell_invite_riends".localized,"setting_cell_privacy_policy".localized,"setting_cell_about_us".localized]]
    var hideImage = UIImage(named: "hidebutton")
    
    override func loadView() {
        let tableView = UITableView(frame: UIScreen.main.bounds, style: .grouped)
        tableView.dataSource = self
        tableView.delegate = self
        view = tableView

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        navigationItem.title = "home_setting_menu_setting".localized
        navigationController?.navigationBar.isHidden = false
        
        //导航栏右上角设置一个去妹子图界面的button(暂时注掉，以后在用)
        let hideButton = UIBarButtonItem(image: hideImage, style: .plain, target: self, action: #selector(gobeautyVC))
        self.navigationItem.rightBarButtonItem = hideButton
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //跳转到妹子图页面
    @objc func gobeautyVC() {
        let vc = ArtImageViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //跳转到关于页面
    @objc func goaboutus() {
        let goAboutUs = AboutUsViewController()
        self.navigationController?.pushViewController(goAboutUs, animated: true)
    }
    @objc func cacheAll() {
            ImageTool.clearAllCache()
            HUDTool.show(msg: "Clear Done")
    }
    
    //弹出反馈邮件界面
    @objc func feedback() {
        let sendMailHelper = SendMailHelper()
        let viewController = sendMailHelper.basicConfigAndShowMail(recipients: ["maxwallpaperapp@gmail.com"], subject: "home_feedback_mail_subject".localized, messageBody: "")
        if let vc = viewController {
            sendMailHelper.setCcRecipients([""])
            self.present(vc, animated: true, completion: {})
        }
    }
    
    //弹出系统的分享功能，分享到第三方
    @objc func inviteFriends() {
        func share() -> Void {
            let title: String = "home_share_app_title".localized
            let img = UIImage(named: "icon-60@3x.png")
            let imageView = UIImageView(image: img)
            let url: NSURL = NSURL(string: "https://itunes.apple.com/cn/app/id1420435738")! // 已替换成自己的appid
            let items: Array = [title, imageView, url] as [Any]
            let vc = UIActivityViewController(activityItems: items, applicationActivities: nil)
            vc.completionWithItemsHandler = { (activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, activityError: Error?) in
                log.info("share app"+(completed ? "success" : "failed"))
                vc.dismiss(animated: true, completion: {})
            }
            self.present(vc, animated: true) {}
        }
        share()
    }

    //弹出评价的弹窗
    @objc func rateUs() {
        APPStoreReview.showReview()
    }
    //去到收藏界面
    @objc func goFavoriteViewController() {
        let fvc = FavoriteViewController()
        self.navigationController?.pushViewController(fvc, animated: true)
    }
    
    
    //声音开关的方法
    @objc func soundSwitch (_ sender: UISwitch) {
        UserSettingConfig.setSoundEffect(sender.isOn)
    }
    
    //去隐私条款界面
    @objc func goPrivacyViewController() {
        let pvc = PrivacyViewController()
        self.navigationController?.pushViewController(pvc, animated: true)
    }
    //清理缓存,这个功能不会加，留着大神加
    @objc func clearCache(){
        ImageTool.clearAllCache()
    }
}

//TableView 相关
extension SettingViewController: UITableViewDataSource, UITableViewDelegate {
        
    //返回每一个 section 有多少行
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < dataList.count {
            return dataList[section].count
        } else {
            return 0
        }
    }
    

    //返回cell 显示的内容
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cellIdentifier")
        }
        tableView.separatorStyle = .none //去掉cell之间的分割线
        let arr = dataList[indexPath.section]
        cell?.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        cell?.textLabel?.text = arr[indexPath.row]
        cell?.textLabel?.textColor = .white
        cell?.backgroundColor = .black
        cell?.textLabel?.font = UIFont(name: "DINCond-Black", size: 18)
        cell?.textLabel?.textAlignment = NSTextAlignment.left
        cell?.selectedBackgroundView = UIView()
        cell?.selectedBackgroundView?.backgroundColor = HexColor(hex: 0xFF0073, alpha: 1.0)
        
        
        //设置一个声音的 UISwitch 开关'
        if indexPath.section == 0 , indexPath.row == 1 {
            let swicthObj = UISwitch(frame: CGRect(x: 1, y: 1, width: 20, height: 20))
            swicthObj.onTintColor = HexColor(hex: 0xFF0073, alpha: 1.0)
            swicthObj.isOn = UserSettingConfig.soundEffectStatus()
            swicthObj.addTarget(self, action: #selector(soundSwitch(_ :)), for: .valueChanged)
            cell?.accessoryView = swicthObj
        }

        return  cell!
    }
    
    //头部高度
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    //该方法是用来设置 TableView 有多少组 Cell
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataList.count
    }
    
    //设置每一行 cell 的高度
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }

    //文本和分割线的左右上下间距
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.separatorInset = UIEdgeInsets.init(top: 0, left: 20, bottom: 0, right: 20) //控制线的左右间距
        cell.layoutMargins = UIEdgeInsets.init(top: 0, left: 30, bottom: 0, right: 0) //控制文本的左右间距
    }


    //选中 cell 后的操作
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) //取消选中的效果动画开
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                print("打开邮件系统")
                SoundEffect.playSound(name: "tap")
                feedback()
            }else if indexPath.row == 1 {
                print("声音开关")
//                SoundEffect.playSound(name: "tap")
//                goFavoriteViewController()
                
            }else if indexPath.row == 2 {
                print("弹窗评价弹窗")
                SoundEffect.playSound(name: "tap")
                rateUs()
//                UserDefaultCache.clear(self)
            }
        } else if indexPath.section == 1{
            if indexPath.row == 0 {
                print("打开系统的第三方分享")
                SoundEffect.playSound(name: "Tab1")
                inviteFriends()
            }else if indexPath.row == 1 {
                SoundEffect.playSound(name: "Tab1")
                print("去隐私条款界面")
                goPrivacyViewController()
            }else if indexPath.row == 2 {
                print("去关于页面")
                SoundEffect.playSound(name: "Tab1")
                goaboutus()
            }
        }
    }
}
