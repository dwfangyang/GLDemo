//
//  AlbumVideoPickerController.h
//  openGLDemo
//
//  Created by 方阳 on 17/5/2.
//  Copyright © 2017年 dw_fangyang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^videoPickedCallback)(NSURL*);

@interface AlbumVideoPickerController : UIImagePickerController

@property (nonatomic,strong) videoPickedCallback videoPickedBlock;

@end
