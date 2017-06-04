//
//  AlbumVideoPickerController.m
//  openGLDemo
//
//  Created by 方阳 on 17/5/2.
//  Copyright © 2017年 dw_fangyang. All rights reserved.
//

#import "AlbumVideoPickerController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface AlbumVideoPickerController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@end

@implementation AlbumVideoPickerController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.delegate = self;
    self.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    self.mediaTypes = @[(NSString*)kUTTypeMovie];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo NS_DEPRECATED_IOS(2_0, 3_0);
{
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info;
{
    [info enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if( [key isEqualToString:UIImagePickerControllerMediaURL] )
        {
            [self dismissViewControllerAnimated:YES completion:^{
                if( _videoPickedBlock )
                {
                    _videoPickedBlock(obj);
                }
            }];
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;
{
    [self dismissViewControllerAnimated:YES completion:^{
        if( _videoPickedBlock )
        {
            _videoPickedBlock(nil);
        }
    }];
}
@end
