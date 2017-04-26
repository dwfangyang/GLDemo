//
//  GLYUVPainter.h
//  openGLDemo
//
//  Created by 方阳 on 17/4/3.
//  Copyright © 2017年 dw_fangyang. All rights reserved.
//

#import "GLPainter.h"

typedef NS_ENUM(NSUInteger,YUVType)
{
    YUVTypeUnknown,
    YUVTypeBT709videoRange,
    YUVTypeBT601fullRange,
    YUVTypeBT601videoRange,
};

@interface GLYUVPainter : GLPainter

@property (nonatomic,readonly) YUVType type;
@property (nonatomic,assign) GLuint luminanceTexture;
@property (nonatomic,assign) GLuint chromananceTexture;

+ (instancetype)painterWithYUVType:(YUVType)type;

@end
