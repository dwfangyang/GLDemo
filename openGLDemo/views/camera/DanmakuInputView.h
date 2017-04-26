//
//  DanmakuInputView.h
//  openGLDemo
//
//  Created by 方阳 on 17/3/21.
//  Copyright © 2017年 dw_fangyang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^danmakuGenerated)(NSString*);
@interface DanmakuInputView : UIView

@property (nonatomic,strong) danmakuGenerated danmakuBlock;

@end
