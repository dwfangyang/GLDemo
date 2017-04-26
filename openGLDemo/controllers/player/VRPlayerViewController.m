//
//  VRPlayerViewController.m
//  openGLDemo
//
//  Created by 方阳 on 17/4/8.
//  Copyright © 2017年 dw_fangyang. All rights reserved.
//

#import "VRPlayerViewController.h"
#import "GLImage.h"
#import "GLVRPainter.h"
#import "GLVideoReader.h"

@interface VRPlayerViewController ()

@property (nonatomic,strong) GLStillImage* vrimg;
@property (nonatomic,strong) GLSimplestImageView* imgview;
@property (nonatomic,strong) GLVRPainter* painter;
@property (nonatomic,strong) GLFramebuffer* framebuffer;
@property (nonatomic,strong) GLVideoReader* videoReader;
@property (nonatomic,strong) NSTimer* timerPlayer;

@end

@implementation VRPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor greenColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews
{
    self.imgview.frame = self.view.bounds;
}

- (void)timeout:(NSTimer*)timer
{
    dispatch_async_on_glcontextqueue(^{
        CMSampleBufferRef buf = [self.videoReader getNextVideoSampleBuffer];
        if( buf )
        {
            CVPixelBufferRef pixbuf = CMSampleBufferGetImageBuffer(buf);
            
            GLTexture* texture = [GLTexture glTextureWithPixelBuffer:pixbuf isYUV:NO];
            if( texture.texture )
            {
                //NSLog(@"ts:%@",@([[NSDate date] timeIntervalSince1970]));
                [_framebuffer useFramebuffer];
                _painter.inputTexture = texture.texture;
                [_painter paint];
                [self.imgview setFrameBuffer:_framebuffer];
                [self.imgview display];
            }
            CFRelease(buf);
        }
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSURL* url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"demo" ofType:@"m4v"]];
    _videoReader = [[GLVideoReader alloc] initWithAsset:url];
    [_videoReader startReading:^{
        
        dispatch_async_on_glcontextqueue(^{
            self.imgview = [[GLSimplestImageView alloc] initWithFrame:self.view.frame];
            _painter = [[GLVRPainter alloc] initWithVertexShader:vrVertexShader fragmentShader:defFragmentShader];
            _framebuffer = [[GLFramebuffer alloc] initWithSize:CGSizeMake(1334, 750)];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.view addSubview:self.imgview];
            });
        });
        dispatch_async(dispatch_get_main_queue(), ^{
            float fps = self.videoReader.curFps;
            NSTimeInterval ti = ((fps>1.0/120)?1.0/fps:0.033);
            _timerPlayer = [NSTimer scheduledTimerWithTimeInterval:ti target:self selector:@selector(timeout:) userInfo:nil repeats:YES];
        });
    }];
}

@end
