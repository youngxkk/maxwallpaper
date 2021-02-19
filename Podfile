source 'https://github.com/CocoaPods/Specs.git'

inhibit_all_warnings!  # 关闭所有警告
install! 'cocoapods', :deterministic_uuids => false
use_frameworks!   # 用framework替代静态库

def basic
#    pod 'YYCache'
#    pod 'HandyJSON' #pod 'YYModel'
    pod 'Alamofire' #    pod 'AFNetworking/NSURLSession', '~> 3.1.0'
    pod 'Kingfisher', '5.2.0'  # SDWebImage
    pod 'KingfisherWebP', '0.5.0'
#    pod 'CocoaAsyncSocket', '~> 7.6.2'
#    pod 'SwiftyDB', '~> 1.1.3'  # pod 'FMDB'
    pod 'SnapKit'
    pod 'SDVersion'
#    pod 'SSZipArchive'
    pod 'RSLoadingView'
    pod 'Chrysan'  # pod 'MBProgressHUD'
    pod 'MJRefresh'  # pod 'DGElasticPullToRefresh' # pod 'CRRefresh'
    pod 'CocoaLumberjack/Swift' # pod 'SwiftyBeaver'
    pod 'pop'
#    pod 'RocketData'
    pod 'Sharaku', :git => 'git@github.com:elijahdou/Sharaku.git'
    pod 'Firebase/Core'
    pod 'Fabric'
    pod 'Crashlytics'
end

def debug
    configs = ['Debug']
    pod 'Reveal-SDK', '17', :configurations => configs
    pod 'MLeaksFinder', :configurations => configs
    pod 'FBRetainCycleDetector', :git => 'https://github.com/facebook/FBRetainCycleDetector.git', :branch => 'master', :configurations => configs
    pod 'OOMDetector', :configurations => configs
end


target 'MaxWallpaper' do
    platform :ios, '10.0'
    basic
    debug
end


#在Debug模式下，设置Optimization level = None方便断点调试
post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        if config.name.include?('Debug')
            config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Onone'
            # Enable assertions for target
            config.build_settings['ENABLE_NS_ASSERTIONS'] = 'YES'
        else
            config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Osize'
        end
        config.build_settings['SWIFT_COMPILATION_MODE'] = 'wholemodule'
        config.build_settings['SWIFT_VERSION'] = '5.0'
    end
end

