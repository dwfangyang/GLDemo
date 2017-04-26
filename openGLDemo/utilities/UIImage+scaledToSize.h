//
//  UIImage+scaledToSize.h
//  YYMobile
//
//  Created by lixingpeng on 14/11/4.
//  Copyright (c) 2014年 YY.inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (scaledToSize)

/**
 *  根据传入尺寸对图片进行裁剪
 *
 *  @param rect  裁剪区域
 *
 *  @return 裁剪后图片
 */
- (UIImage*)subWithRect:(CGRect)rect;

/**
 *  把图片伸缩到特定尺寸
 *
 *  @param size 伸缩尺寸
 *
 *  @return 伸缩后的图片
 */
- (UIImage*)scaleToSize:(CGSize)size;


//等比缩放,scale缩放的比例
- (UIImage *)scaleImageWithScale:(float)scale;


@end
