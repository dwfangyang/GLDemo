//
//  AlbumDataController.h
//  openGLDemo
//
//  Created by 方阳 on 17/3/13.
//  Copyright © 2017年 dw_fangyang. All rights reserved.
//

#import "dataController.h"

@interface AlbumDataController : dataController

- (void)fetchAlbumDataWithCompletionHandler:(void (^)(BOOL))completionHandler;

@end
