//
//  PhotoEditingViewController.m
//  handy
//
//  Created by 方阳 on 17/3/4.
//  Copyright © 2017年 dw_fangyang. All rights reserved.
//

#import "PhotoEditingViewController.h"
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>
#import <CoreText/CoreText.h>
#import "GLImage.h"
#import "GLStillImage.h"
#import "CtFrameParser.h"

@interface PhotoEditingViewController () <PHContentEditingController,UITextFieldDelegate,UIScrollViewDelegate>
@property (strong) PHContentEditingInput *input;

@property (nonatomic,strong) UIScrollView* scrollview;
@property (strong,nonatomic) UIImageView* contentView;
@property (strong,nonatomic) UITextField* editlbl;
@property (nonatomic,strong) UIImage* origImg;
@end

@implementation PhotoEditingViewController

#pragma mark UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    __weak __typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSTimeInterval ts = [[NSDate date] timeIntervalSince1970];
        UIImage* img = wself.origImg;
        size_t scale = img.scale;
        size_t width = scale*img.size.width, height = scale*img.size.height;
        CGColorSpaceRef spaceref = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 4*width, spaceref, kCGImageAlphaPremultipliedLast);
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), img.CGImage);
        NSAttributedString* str = [[NSAttributedString alloc] initWithString:wself.editlbl.text attributes:@{NSForegroundColorAttributeName:[UIColor redColor],NSFontAttributeName:[UIFont systemFontOfSize:14*width/CGRectGetWidth([UIScreen mainScreen].bounds)]}];
        CTFrameRef frame = [[CtFrameParser sharedParser] getCTFrameOfString:str inRect:CGRectMake(0, 0, 200, 50)];
        CTFrameDraw(frame, context);
        CGImageRef imgref = CGBitmapContextCreateImage(context);
        CGColorSpaceRelease(spaceref);
        CGContextRelease(context);
        CFRelease(frame);
        dispatch_async(dispatch_get_main_queue(), ^{
            wself.contentView.image = [UIImage imageWithCGImage:imgref];
            CGImageRelease(imgref);
            NSLog(@"time:%@",@([[NSDate date] timeIntervalSince1970]-ts));
        });
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _scrollview = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_scrollview];
    _contentView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [_scrollview addSubview:_contentView];
    CGRect rect = [UIScreen mainScreen].bounds;
    _editlbl = [[UITextField alloc] initWithFrame:CGRectMake(rect.size.width/2-50, rect.size.height/2-25, 100, 50)];
    _editlbl.text = @"ek";
    [self.view addSubview:_editlbl];
    _editlbl.delegate = self;
    _scrollview.delegate = self;
}

#pragma mark scrollviewdelegate
- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _contentView;
}

- (void)scrollViewDidZoom:(UIScrollView*)scrollView
{
//    _contentView.layer.position = _scrollview.layer.position;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PHContentEditingController

- (BOOL)canHandleAdjustmentData:(PHAdjustmentData *)adjustmentData {
    // Inspect the adjustmentData to determine whether your extension can work with past edits.
    // (Typically, you use its formatIdentifier and formatVersion properties to do this.)
    return NO;
}

- (void)startContentEditingWithInput:(PHContentEditingInput *)contentEditingInput placeholderImage:(UIImage *)placeholderImage {
    // Present content for editing, and keep the contentEditingInput for use when closing the edit session.
    // If you returned YES from canHandleAdjustmentData:, contentEditingInput has the original image and adjustment data.
    // If you returned NO, the contentEditingInput has past edits "baked in".
    self.input = contentEditingInput;
    _contentView.image = placeholderImage;
    CGFloat scale = placeholderImage.scale;
    CGSize imgsize = placeholderImage.size;
    CGRect screen = [UIScreen mainScreen].bounds;
    CGFloat width = CGRectGetWidth(screen),height = CGRectGetHeight(screen);
    CGSize contentSize = CGSizeMake(width, height);
    CGRect frame = screen;
    if( imgsize.width*scale < width )
    {
        contentSize.width = imgsize.width*scale;
        contentSize.height = imgsize.height*scale;
    }
    else
    {
        contentSize.width = width;
        contentSize.height = imgsize.height*width/imgsize.width;
    }
    frame.origin.x = (width-contentSize.width)/2.0;
    frame.origin.y = (height-contentSize.height)/2.0;
    frame.size = contentSize;
    _contentView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
    CGFloat minScale = 1.0,maxScale = 1.0;
    if( imgsize.width*scale > width )
    {
        maxScale = imgsize.width*scale/width;
    }
    _scrollview.zoomScale = 1.0;
    _scrollview.minimumZoomScale = minScale;
    _scrollview.maximumZoomScale = maxScale;
    _origImg = placeholderImage;
//    _scrollview.contentSize = contentSize;
}

- (void)finishContentEditingWithCompletionHandler:(void (^)(PHContentEditingOutput *))completionHandler {
    // Update UI to reflect that editing has finished and output is being rendered.

    // Render and provide output on a background queue.
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        // Create editing output from the editing input.
        PHContentEditingOutput *output = [[PHContentEditingOutput alloc] initWithContentEditingInput:self.input];
        
        // Provide new adjustments and render output to given location.
        // output.adjustmentData = <#new adjustment data#>;
        // NSData *renderedJPEGData = <#output JPEG#>;
        // [renderedJPEGData writeToURL:output.renderedContentURL atomically:YES];
        
        // Call completion handler to commit edit to Photos.
        completionHandler(output);
        
        // Clean up temporary files, etc.
    });
}

- (BOOL)shouldShowCancelConfirmation {
    // Returns whether a confirmation to discard changes should be shown to the user on cancel.
    // (Typically, you should return YES if there are any unsaved changes.)
    return NO;
}

- (void)cancelContentEditing {
    // Clean up temporary files, etc.
    // May be called after finishContentEditingWithCompletionHandler: while you prepare output.
}

@end
