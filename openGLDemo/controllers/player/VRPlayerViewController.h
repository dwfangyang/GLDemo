//
//  VRPlayerViewController.h
//  openGLDemo
//
//  Created by 方阳 on 17/4/8.
//  Copyright © 2017年 dw_fangyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VRPlayerViewController : UIViewController

@property (nonatomic,strong) NSURL* videoUrl;

@property (nonatomic,strong) dispatch_block_t completion;

@end
