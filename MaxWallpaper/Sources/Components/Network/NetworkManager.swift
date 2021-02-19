//
//  NetworkManager.swift
//  MaxWallpaper
//
//  Created by elijah on 2018/7/3.
//  Copyright © 2018年 elijah. All rights reserved.
//

import Foundation
import Alamofire
import CoreTelephony
import SDVersion

let NetworkStatusChangeNotification = "NetworkStatusChangeNotification"

typealias RequestProgress = (Int64?, Int64?) -> Void
typealias RequestCompletion = (_ error: Error?, Any?) -> Void

//创建请求类枚举
fileprivate enum RequestType: Int {
    case GET
    case POST
}

class NetworkManager {
    private var header: HTTPHeaders?
    private var baseURL: String
    private var reachabilityManager: NetworkReachabilityManager?
    private let sessionManager: SessionManager?
    
    
    static let shared = NetworkManager()
    //This prevents others from using the default '()' initializer for this class.
    init() {
        baseURL = "http://maxw.cc:8082"
        sessionManager = Alamofire.SessionManager.default
        configNetwork()
        header = getBaseParams();
    }
    
    // MARK: - CTTelephonyNetworkInfo
    func timeoutInterval() -> TimeInterval {
        var timeInterval: TimeInterval = 10
        let networkInfo: CTTelephonyNetworkInfo = CTTelephonyNetworkInfo()
        let currentRadioAccessTechnology: String? = networkInfo.currentRadioAccessTechnology
        if let key = currentRadioAccessTechnology {
            let configDict: [String: TimeInterval] = [CTRadioAccessTechnologyGPRS: 30,
                                                 CTRadioAccessTechnologyEdge: 20,
                                CTRadioAccessTechnologyWCDMA: 15,
                                CTRadioAccessTechnologyHSDPA: 10,
                                CTRadioAccessTechnologyHSUPA: 10,
                                CTRadioAccessTechnologyCDMA1x: 30,
                                CTRadioAccessTechnologyCDMAEVDORev0: 20,
                                CTRadioAccessTechnologyCDMAEVDORevA: 15,
                                CTRadioAccessTechnologyCDMAEVDORevB: 15,
                                CTRadioAccessTechnologyeHRPD: 10,
                                CTRadioAccessTechnologyLTE: 10];
            timeInterval = configDict[key]!;
        }
        return timeInterval
    }
    
    // MARK: - 发送网络请求
    func GET(_ url: String, parameters: Dictionary<String, Any>?, completion: ((_ error: Error?, _ rsp: Dictionary<String, Any>?) -> Void)?) -> Void {
        self.request(url, type: .GET, parameters: parameters, completion: completion)
    }
    func POST(_ url: String, parameters: Dictionary<String, Any>?, completion: ((_ error: Error?, _ rsp: Dictionary<String, Any>?) -> Void)?) -> Void {
        self.request(url, type: .POST, parameters: parameters, completion: completion)
    }
    
    fileprivate func request(_ url: String, type: RequestType, parameters: Dictionary<String, Any>?, completion: ((_ error: Error?, _ rsp: Dictionary<String, Any>?) -> Void)?) -> Void {
        let method: HTTPMethod
        let encoding: ParameterEncoding
        switch type {
        case .GET:
            method = .get
            encoding = URLEncoding.default
        case .POST:
            method = .post
            encoding = URLEncoding.httpBody
        }
        
        Alamofire.request(completeURL(url), method: method, parameters: buildParams(parameters), encoding: encoding, headers: header).validate().responseJSON { (response: DataResponse<Any>) in
            JKLog(response.request ?? "unkonw req", response.result)
            if let closure = completion {
                closure(response.error, response.result.value as? Dictionary<String, Any>)
            }
        }
    }
    
    private func completeURL(_ url: String) -> String {
        if url.isEmpty {
            return baseURL
        }
        if url.hasPrefix("http") || url.hasPrefix("https") {
            return url
        }
        
        return baseURL + url
    }
    
    private func getBaseParams() -> Dictionary<String, String> {
        return ["device": SDiOSVersion.deviceNameString()!,
                "os_version": UIDevice.current.systemName + UIDevice.current.systemVersion,
                "version": Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String,
                "locale": Locale.current.identifier,
        ]
    }
    
    private func buildParams(_ dic: Dictionary<String, Any>?) -> Dictionary<String, Any>? {
        
        return dic
    }
    
    // MARK: upload
    func upload(_ url: String, parameters: Dictionary<String, Any>?, completion: ((_ error: Error?, Any?) -> Void)?) -> Void {
//        Alamofire.upload(multipartFormData: <#T##(MultipartFormData) -> Void#>, usingThreshold: <#T##UInt64#>, to: <#T##URLConvertible#>, method: <#T##HTTPMethod#>, headers: <#T##HTTPHeaders?#>, encodingCompletion: <#T##((SessionManager.MultipartFormDataEncodingResult) -> Void)?##((SessionManager.MultipartFormDataEncodingResult) -> Void)?##(SessionManager.MultipartFormDataEncodingResult) -> Void#>)
    }
    
    // MARK: download
    func download(_ url: String, parameters: Dictionary<String, Any>?, completion: ((_ error: Error?, Any?) -> Void)?) -> Void {
//        Alamofire.download(<#T##url: URLConvertible##URLConvertible#>, method: <#T##HTTPMethod#>, parameters: <#T##Parameters?#>, encoding: <#T##ParameterEncoding#>, headers: <#T##HTTPHeaders?#>, to: <#T##DownloadRequest.DownloadFileDestination?##DownloadRequest.DownloadFileDestination?##(URL, HTTPURLResponse) -> (destinationURL: URL, options: DownloadRequest.DownloadOptions)#>)
    }

    // MARK: 配置网络
    private func configNetwork() -> Void {
        configNetworkReachability()
        
    }
    
    // MARK: - 网络可达性
    private func configNetworkReachability() -> Void {
        reachabilityManager = NetworkReachabilityManager()
        reachabilityManager!.listener = { status in
            if status == .reachable(.ethernetOrWiFi) { //WIFI
                
            } else if status == .reachable(.wwan) { // 蜂窝网络
                
            } else if status == .notReachable { // 无网络
                
            } else { // 其他
                
            }
            self.sessionManager!.session.configuration.timeoutIntervalForRequest = self.timeoutInterval()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NetworkStatusChangeNotification), object: status, userInfo: nil)
        }
        
        reachabilityManager!.startListening()
    }
    
    func isReachable() -> Bool {
        return reachabilityManager!.isReachable;
    }
}
