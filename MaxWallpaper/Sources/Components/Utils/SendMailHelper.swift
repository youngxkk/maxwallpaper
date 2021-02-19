//
//  SendMailHelper.swift
//  MaxWallpaper
//
//  Created by 大鲨鱼 on 2018/7/12.
//  Copyright © 2018年 大鲨鱼. All rights reserved.
//

import UIKit
import MessageUI

fileprivate typealias RetainClosure = () ->Void

class SendMailHelper: NSObject {
    
    fileprivate var retainClosure: RetainClosure?
    fileprivate var mailComposeVC: MFMailComposeViewController?
    
    func basicConfigAndShowMail(recipients: Array<String>?, subject: String, messageBody: String!, messageBodyIsHtml: Bool = false) -> UIViewController? {
        let canSendMail: Bool = MFMailComposeViewController.canSendMail()
        if canSendMail {
            mailComposeVC = MFMailComposeViewController()
            mailComposeVC?.mailComposeDelegate = self
            //设置邮件地址、主题及正文
            mailComposeVC?.setToRecipients(recipients)
            mailComposeVC?.setSubject(subject)
            mailComposeVC?.setMessageBody(messageBody, isHTML: messageBodyIsHtml)
            // trick: 用retain cyle的方式持有住自己，当外面将helper当做局部变量使用时 释放掉不能正常走代理方法
            retainClosure = { () in
                log.info("begin to send mail: \(self.description)")
            }
            retainClosure?()
            return mailComposeVC
        } else {
            showSendMailErrorAlert()
            return nil;
        }
    }
    
    //提示框，提示用户设置邮箱
    func showSendMailErrorAlert() {
        AuthorizationCheck.showAlert(title: "未开启邮件功能", msg: "设备邮件功能尚未开启，请在设置中更改", goSetting: false)
    }
    
    func setCcRecipients(_ ccRecipients: [String]?) -> Void {
        mailComposeVC?.setCcRecipients(ccRecipients)
    }
    
    func setBccRecipients(_ bccRecipients: [String]?) -> Void {
        mailComposeVC?.setBccRecipients(bccRecipients)
    }
    
    func addAttachmentData(_ attachment: Data, mimeType: String, filename: String) -> Void {
        mailComposeVC?.addAttachmentData(attachment, mimeType: mimeType, fileName: filename)
    }
}

extension SendMailHelper: MFMailComposeViewControllerDelegate {
    //MARK:- Mail Delegate
    //用户退出邮件窗口时被调用
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result.rawValue{
        case MFMailComposeResult.sent.rawValue:
            log.info("邮件已发送")
            break
        case MFMailComposeResult.cancelled.rawValue:
            log.info("邮件已取消")
            break
        case MFMailComposeResult.saved.rawValue:
            log.info("邮件已保存")
            break
        case MFMailComposeResult.failed.rawValue:
            log.info("邮件发送失败")
            break
        default:
            log.info("邮件没有发送")
            break
        }
        controller.dismiss(animated: true, completion: { () in
            self.retainClosure = nil;
        })
    }
}

