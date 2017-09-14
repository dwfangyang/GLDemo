//
//  ImageProcessingDataController.h
//  openGLDemo
//
//  Created by 方阳 on 2017/6/4.
//  Copyright © 2017年 dw_fangyang. All rights reserved.
//

#import "dataController.h"
#import "GLImage.h"

typedef NS_ENUM(NSUInteger,FilterMode) {
    FilterModeBlackWhite,
    FilterModeNormal,
};

@interface ImageProcessingDataController : dataController

- (void)setFilterMode:(FilterMode)mode;

- (GLFramebuffer*)process:(GLFramebuffer*)fb;

@end
