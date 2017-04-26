//
//  runloopTest.h
//  openGLDemo
//
//  Created by 方阳 on 17/3/8.
//  Copyright © 2017年 dw_fangyang. All rights reserved.
//

#ifndef runloopTest_h
#define runloopTest_h

/*
 - (void)networkThreadEntryPoint:(id)object
 {
 NSLog(@"networkThreadEntryPoint");
 [[NSThread currentThread] setName:@"networkThread"];
 NSRunLoop* runloop = [NSRunLoop currentRunLoop];
 
 
 _timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timeout:) userInfo:nil repeats:NO];
 [runloop addTimer:_timer forMode:NSDefaultRunLoopMode];
 
 [runloop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
 [runloop run];
 }
 
 //    CFOptionFlags activities = kCFRunLoopEntry|kCFRunLoopBeforeSources|kCFRunLoopBeforeWaiting|kCFRunLoopExit|kCFRunLoopAfterWaiting|kCFRunLoopBeforeTimers;
 //    CFRunLoopObserverContext context = {0,(__bridge void *)(self),nil,nil,nil};
 //    CFRunLoopObserverRef observer = CFRunLoopObserverCreate(NULL, activities, YES, INT_MAX, callbacker, &context);
 //    CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, kCFRunLoopDefaultMode);
 //    CFRelease(observer);
 //    _timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timeout:) userInfo:nil repeats:YES];
 //    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
 ////    CFRunLoopAddTimer(CFRunLoopGetCurrent(), (__bridge CFRunLoopTimerRef)_timer, kCFRunLoopCommonModes);
 //    _thread = [[NSThread alloc] initWithTarget:self selector:@selector(networkThreadEntryPoint:) object:nil];
 //    [_thread start];
 
 static void callbacker(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info);
 
 static void callbacker(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info)
 {
 switch (activity) {
 case kCFRunLoopBeforeWaiting:
 NSLog(@"before waiting\n");
 break;
 case kCFRunLoopAfterWaiting:
 NSLog(@"after waiting\n");
 break;
 case kCFRunLoopEntry:
 NSLog(@"entry\n");
 break;
 case kCFRunLoopBeforeTimers:
 NSLog(@"timestamp:%@",@([[NSDate new] timeIntervalSince1970]));
 NSLog(@"beforetimers\n");
 break;
 case kCFRunLoopBeforeSources:
 NSLog(@"timestamp:%@",@([[NSDate new] timeIntervalSince1970]));
 NSLog(@"beforesources\n");
 break;
 case kCFRunLoopExit:
 NSLog(@"timestamp:%@",@([[NSDate new] timeIntervalSince1970]));
 NSLog(@"exit\n");
 break;
 
 default:
 break;
 }
 }
 */


#endif /* runloopTest_h */
