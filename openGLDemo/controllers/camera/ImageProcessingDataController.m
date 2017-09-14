//
//  ImageProcessingDataController.m
//  openGLDemo
//
//  Created by 方阳 on 2017/6/4.
//  Copyright © 2017年 dw_fangyang. All rights reserved.
//

#import "ImageProcessingDataController.h"

@interface ImageProcessingDataController()

@property (nonatomic,strong) GLPainter* painter;
@property (nonatomic,strong) GLFramebuffer* framebuffer;

@end

@implementation ImageProcessingDataController

- (void)setFilterMode:(FilterMode)mode
{
    switch ( mode ) {
        case FilterModeBlackWhite:
            _painter = [[GLPainter alloc] initWithVertexShader:defVertexShader fragmentShader:glBlackWhiteFilter];
            break;
        case FilterModeNormal:
            _painter = [[GLPainter alloc] initWithVertexShader:defVertexShader fragmentShader:defFragmentShader];
            break;
            
        default:
            _painter = [[GLPainter alloc] initWithVertexShader:defVertexShader fragmentShader:defFragmentShader];
            break;
    }
}

- (GLFramebuffer*)process:(GLFramebuffer *)fb
{
    if( !CGSizeEqualToSize(_framebuffer.size, fb.size))
    {
        _framebuffer = [[GLFramebuffer alloc] initWithSize:fb.size];
    }
    [_framebuffer useFramebuffer];
    _painter.inputTexture = fb.texture;
    [_painter paint];
    return _framebuffer;
}

@end
