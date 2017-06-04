//
//  ScreenToast.m
//  openGLDemo
//
//  Created by 方阳 on 2017/5/10.
//  Copyright © 2017年 dw_fangyang. All rights reserved.
//

#import "ScreenToast.h"
#import <UIKit/UIKit.h>

@interface ScreenToast()

@property (nonatomic,strong) CATextLayer* currentLayer;
@property (nonatomic,strong) NSMutableArray* toastContainer;
@property (atomic,assign) BOOL isShowing;

@end

@implementation ScreenToast

+(instancetype)sharedInstance
{
    static ScreenToast* toastmanager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        toastmanager = [ScreenToast new];
    });
    return toastmanager;
}

- (instancetype)init
{
    if( (self = [super init]) )
    {
        _toastContainer = [NSMutableArray new];
    }
    return self;
}

- (void)showToast:(NSString *)toastText;
{
    @synchronized (self.toastContainer) {
        [self.toastContainer addObject:toastText];
    }
    
    __weak __typeof(self) wself = self;
    if( [NSThread isMainThread] )
    {
        [self doShowing];
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [wself doShowing];
        });
    }
}

#pragma mark utility method
- (void)doShowing;/*main thread only*/
{
    //NSLog(@"doshowing:%@",@([[NSDate date] timeIntervalSince1970]));
    BOOL needToShow = NO;
    NSString* toast = nil;
    @synchronized (self.toastContainer)
    {
        if( self.isShowing || !self.toastContainer.count )
        {
            needToShow = NO;
        }
        else
        {
            needToShow = YES;
            toast = [self.toastContainer firstObject];
            [self.toastContainer removeObjectAtIndex:0];
        }
    }
    if( !needToShow )
    {
        return;
    }
    self.isShowing = YES;
    if( self.currentLayer )
    {
        //NSLog(@"remove:%@",@([[NSDate date] timeIntervalSince1970]));
        [self.currentLayer removeFromSuperlayer];
    }
    self.currentLayer = [[CATextLayer alloc] init];
    CGRect frame = [UIScreen mainScreen].bounds;
    
    CGRect rect = [toast boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]} context:nil];
    self.currentLayer.frame = CGRectMake(frame.size.width/2-rect.size.width/2, frame.size.height/2-10, rect.size.width, 20);
    self.currentLayer.fontSize = 16;
    self.currentLayer.backgroundColor = [[UIColor blackColor] CGColor];
    self.currentLayer.cornerRadius = 2;
    self.currentLayer.contentsScale = [UIScreen mainScreen].scale;
    self.currentLayer.string = toast;
    self.currentLayer.alignmentMode = kCAAlignmentCenter;
    [[UIApplication sharedApplication].keyWindow.layer addSublayer:self.currentLayer];
    __weak CATextLayer* weakLayer = self.currentLayer;
    [CATransaction begin];
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"position.x"];
    animation.fromValue = @(frame.size.width+rect.size.width/2);
    animation.toValue = @(frame.size.width/2);
    [CATransaction setCompletionBlock:^{
        self.isShowing = NO;
        [self doShowing];
    }];
    [weakLayer addAnimation:animation forKey:@"abc"];
    [CATransaction commit];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [weakLayer removeFromSuperlayer];
    });
    
}
@end
