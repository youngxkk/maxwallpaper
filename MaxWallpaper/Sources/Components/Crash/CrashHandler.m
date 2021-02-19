//
//  CrashHandler.c
//  putong
//
//  Created by elijah on 2019/1/28.
//  Copyright © 2019 P1. All rights reserved.
//

#import "CrashHandler.h"
#import <signal.h>
#include <execinfo.h>

void jkd_delegateHandleCrash(CarashInfo *crash)
{
    [CrashHandler.handler handleCarsh:crash];
}

// signal部分
typedef void (*jkd_signalHandler)(int signal, siginfo_t *info, void *context);

static jkd_signalHandler jkd_previousSignalHandler_ABRT = NULL;
static jkd_signalHandler jkd_previousSignalHandler_HUP = NULL;
static jkd_signalHandler jkd_previousSignalHandler_INT = NULL;
static jkd_signalHandler jkd_previousSignalHandler_QUIT = NULL;
static jkd_signalHandler jkd_previousSignalHandler_ILL = NULL;
static jkd_signalHandler jkd_previousSignalHandler_SEGV = NULL;
static jkd_signalHandler jkd_previousSignalHandler_FPE = NULL;
static jkd_signalHandler jkd_previousSignalHandler_BUS = NULL;
static jkd_signalHandler jkd_previousSignalHandler_PIPE = NULL;

void jkd_custom_signalHandler(int signal, siginfo_t *info, void *context)
{
    NSMutableString *crashInfo = [[NSMutableString alloc] init];
    [crashInfo appendString:[NSString stringWithFormat:@"Signal:%d\n", signal]];
    [crashInfo appendString:@"Stack:\n"];
    void *callstack[128];
    int i, frames = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack, frames);
    for (i = 0; i <frames; ++i) {
        [crashInfo appendFormat:@"%s\n", strs[i]];
    }
    
    CarashInfo *crash = [[CarashInfo alloc] init];
    crash.signalNum = info->si_signo;
    crash.signalErrorNum = info->si_errno;
    crash.signalCode = info->si_code;
    crash.errorProcess = info->si_pid;
    crash.ruid = info->si_uid;
    crash.signalStatus = info->si_status;
    crash.si_addr = info->si_addr;
    crash.signalValue = info->si_value.sival_int;
    crash.signalBand = info->si_band;
    jkd_delegateHandleCrash(crash);
    
    // 处理前者注册的 handler
    jkd_signalHandler jkd_previousSignalHandler = NULL;
    switch (signal) {
        case SIGHUP:
            jkd_previousSignalHandler = jkd_previousSignalHandler_HUP;
            break;
        case SIGQUIT:
            jkd_previousSignalHandler = jkd_previousSignalHandler_QUIT;
            break;
        case SIGABRT:
            jkd_previousSignalHandler = jkd_previousSignalHandler_ABRT;
            break;
        case SIGILL:
            jkd_previousSignalHandler = jkd_previousSignalHandler_ILL;
            break;
        case SIGSEGV:
            jkd_previousSignalHandler = jkd_previousSignalHandler_SEGV;
            break;
        case SIGFPE:
            jkd_previousSignalHandler = jkd_previousSignalHandler_FPE;
            break;
        case SIGBUS:
            jkd_previousSignalHandler = jkd_previousSignalHandler_BUS;
            break;
        case SIGPIPE:
            jkd_previousSignalHandler = jkd_previousSignalHandler_PIPE;
            break;
        default:
            break;
    }
    if (jkd_previousSignalHandler != NULL) {
        jkd_previousSignalHandler(signal, info, context);
    }
}

void jkd_registerHandler(int signal, jkd_signalHandler previousHandler)
{
    struct sigaction old_action;
    sigaction(signal, NULL, &old_action);
    if (old_action.sa_flags & SA_SIGINFO) {
        previousHandler = old_action.sa_sigaction;
    }
    
    struct sigaction action;
    action.sa_sigaction = jkd_custom_signalHandler;
    action.sa_flags = SA_NODEFER | SA_SIGINFO;
    sigemptyset(&action.sa_mask);
    sigaction(signal, &action, 0);
}

void jkd_installSignalHandler(void)
{
    jkd_registerHandler(SIGHUP, jkd_previousSignalHandler_HUP);
    jkd_registerHandler(SIGINT, jkd_previousSignalHandler_INT);
    jkd_registerHandler(SIGQUIT, jkd_previousSignalHandler_QUIT);
    jkd_registerHandler(SIGABRT, jkd_previousSignalHandler_ABRT);
    jkd_registerHandler(SIGILL, jkd_previousSignalHandler_ILL);
    jkd_registerHandler(SIGSEGV, jkd_previousSignalHandler_SEGV);
    jkd_registerHandler(SIGFPE, jkd_previousSignalHandler_FPE);
    jkd_registerHandler(SIGBUS, jkd_previousSignalHandler_BUS);
    jkd_registerHandler(SIGPIPE, jkd_previousSignalHandler_PIPE);
    
//    signal(SIGHUP, jkd_signalHandler);
//    signal(SIGINT, jkd_signalHandler);
//    signal(SIGQUIT, jkd_signalHandler);
//    signal(SIGABRT, jkd_signalHandler);
//    signal(SIGILL, jkd_signalHandler);
//    signal(SIGSEGV, jkd_signalHandler);
//    signal(SIGFPE, jkd_signalHandler);
//    signal(SIGBUS, jkd_signalHandler);
//    signal(SIGPIPE, jkd_signalHandler);
}


// exception部分
static NSUncaughtExceptionHandler *jkd_ori_UncaughtExceptionHandler = NULL;
void jkd_NSSetUncaughtExceptionHandler(NSUncaughtExceptionHandler *handler)
{
    jkd_ori_UncaughtExceptionHandler = NSGetUncaughtExceptionHandler();
    NSSetUncaughtExceptionHandler(handler);
}

void jkd_uncaughtExceptionHandler(NSException *exception)
{
    CarashInfo *crash = [[CarashInfo alloc] init];
    crash.exception = exception;
    jkd_delegateHandleCrash(crash);
    
    if (jkd_ori_UncaughtExceptionHandler != NULL) {
        jkd_ori_UncaughtExceptionHandler(exception);
    }
}


@implementation CarashInfo

@end

@interface CrashHandler()

@property (class, nonatomic, strong, readwrite) Class<CrashHandlerProtocol> handler;

@end

@implementation CrashHandler

@dynamic handler;

+ (void)configCrashHandler:(Class<CrashHandlerProtocol>)handler
{
    NSAssert([handler respondsToSelector:@selector(handleCarsh:)], @"must implement CrashHandlerProtocol");
    [self setHandler:handler];
    
    jkd_installSignalHandler();
    jkd_NSSetUncaughtExceptionHandler(&jkd_uncaughtExceptionHandler);
}


static Class<CrashHandlerProtocol> delegateHandler = nil;
+ (void)setHandler:(Class<CrashHandlerProtocol>)handler
{
    delegateHandler = handler;
}

+ (Class<CrashHandlerProtocol>)handler
{
    return delegateHandler;
}

@end
