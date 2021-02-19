//
//  CrashHandler.h
//  putong
//
//  Created by elijah on 2019/1/28.
//  Copyright © 2019 P1. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CarashInfo : NSObject

@property (nonatomic, strong) NSException *exception;
// exception为nil时 以下属性才有意义
@property (nonatomic, assign) int signalNum; /* signal number */
@property (nonatomic, assign) int signalErrorNum; /* errno association */
@property (nonatomic, assign) int signalCode;  /* signal code */
@property (nonatomic, assign) int errorProcess;  /* sending process */
@property (nonatomic, assign) int ruid;  /* sender's ruid */
@property (nonatomic, assign) int signalStatus;  /* exit value */
@property (nonatomic, assign) void *si_addr;   /* faulting instruction */
@property (nonatomic, assign) int signalValue;  /* signal value */
@property (nonatomic, assign) long signalBand;

@end


@protocol CrashHandlerProtocol <NSObject>

@required
+ (void)handleCarsh:(CarashInfo *)crash;

@end

@interface CrashHandler : NSObject

@property (class, nonatomic, strong, readonly) Class<CrashHandlerProtocol> handler;

/**
 配置自定义部分的异常处理，一定要在crash手机工具初始化完成以后再调用本方法

 @param handler 自定义的异常处理的委托对象
 */
+ (void)configCrashHandler:(Class<CrashHandlerProtocol>)handler;

@end

NS_ASSUME_NONNULL_END
