//
//  CameraDataController.m
//  openGLDemo
//
//  Created by 方阳 on 17/3/9.
//  Copyright © 2017年 dw_fangyang. All rights reserved.
//

#import "CameraDataController.h"
#import "ImageProcessingDataController.h"
#import "GLImage.h"
#import "GLBeautyPainter.h"
#import "VideoEncoder.h"
#import "VideoDecoder.h"
#import "GLBlendPainter.h"
#import "AudioCapturer.h"
#import "GLVideoAssetWriter.h"
#import <Photos/Photos.h>
#import "offScreenContext.h"
#import "GLYUVPainter.h"
#import "ScreenToast.h"

@interface CameraDataController()

@property (nonatomic,strong) videoCapturer* videoCapturer;
@property (nonatomic,strong) GLTexture* texture;
@property (nonatomic,strong) GLSimplestImageView* simpleView;
@property (nonatomic,strong) GLFramebuffer* buffer;
@property (nonatomic,strong) GLFramebuffer* yuvbuffer;
@property (nonatomic,strong) GLBeautyPainter* beautyPainter;
@property (nonatomic,strong) VideoEncoder* encoder;
@property (nonatomic,strong) VideoDecoder* decoder;
@property (nonatomic,assign) BOOL isCaptureYUV;
@property (nonatomic,strong) GLTexture* decodeTexture;
@property (nonatomic,strong) GLFramebuffer* decodeyuvbuffer;
@property (nonatomic,strong) GLBlendPainter* blendPainter;
@property (nonatomic,strong) GLStillImage* watermark;
@property (nonatomic,strong) GLYUVPainter* yuvPainter;

@property (nonatomic,strong) GLStillImage* danmakuImage;
@property (nonatomic,strong) GLStillImage* danmakuImage1;
@property (nonatomic,strong) GLStillImage* danmakuImage2;
@property (nonatomic,assign) CGFloat beginx;

@property (nonatomic,strong) GLFramebuffer* preRenderBuffer;
@property (nonatomic,strong) GLPainter* preRenderPainter;

//audio
@property (nonatomic,strong) AudioCapturer* audioCapturer;

//assetwriter
@property (nonatomic,strong) GLVideoAssetWriter* assetWriter;

@property (nonatomic,strong) ImageProcessingDataController* imageProcessor;

@end

#define landscapeSize CGSizeMake(960, 540)
#define portraitSize CGSizeMake(540, 960)
@implementation CameraDataController

- (instancetype)init
{
    self = [super init];
    if( self )
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}

#pragma mark notifications
- (void)applicationWillResignActive:(NSNotification*)notification
{
    
}

- (void)applicationBecomeActive:(NSNotification*)notification
{
    
}

- (void)applicationDidEnterBackground:(NSNotification*)notification;
{
}

- (void)applicationWillEnterForeground:(NSNotification*)notification;
{
}

#pragma mark api
- (void)startCaptureWith:(GLSimplestImageView *)imgView
{
    if( !self.videoCapturer )
    {
        self.videoCapturer = [videoCapturer capturer];
        self.videoCapturer.delegate = self;
    }
    
    if( [self.videoCapturer isCapturing] )
    {
        NSLog(@"start capture while capturing");
        return;
    }
    self.isCaptureYUV = NO;
    self.simpleView = imgView;
    [self.videoCapturer startCaptureWithYUV:self.isCaptureYUV];
    
    __typeof(self) __weak wself = self;
    dispatch_async_on_glcontextqueue(^{
        wself.imageProcessor = [ImageProcessingDataController new];
        [wself.imageProcessor setFilterMode:FilterModeNormal];
        
        BOOL isPortrait = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
        wself.buffer = [[GLFramebuffer alloc] initWithSize:isPortrait?portraitSize:landscapeSize];
        [wself.buffer useFramebuffer];
        wself.yuvbuffer = [[GLFramebuffer alloc] initWithSize:isPortrait?portraitSize:landscapeSize];
        wself.simpleView.backgroundColor = [UIColor clearColor];
        wself.beautyPainter = [[GLBeautyPainter alloc] initWithVertexShader:kBeautyVertextShaderString fragmentShader:kMBeautyV2FragmentShaderString];
        wself.beautyPainter.bIsForPresent = NO;
        
        wself.blendPainter = [[GLBlendPainter alloc] initWithVertexShader:defVertexShader fragmentShader:glBlendShaderFragmentString];
        wself.yuvPainter = [GLYUVPainter painterWithYUVType:YUVTypeBT709videoRange];
        wself.decodeyuvbuffer = [[GLFramebuffer alloc] initWithSize:CGSizeMake(360, 640)];
        
        wself.preRenderBuffer = [[GLFramebuffer alloc] initWithSize:isPortrait?portraitSize:landscapeSize];
        wself.preRenderPainter = [[GLPainter alloc] initWithVertexShader:defVertexShader fragmentShader:defFragmentShader];
    });
    
}

- (void)stopCapture
{
    [self.videoCapturer stopCapture];
}

- (void)switchCamera
{
    [self.videoCapturer switchCamera];
}

- (void)rotateToOrientation:(AVCaptureVideoOrientation)orientation;
{
    [self.videoCapturer rotateToOrientation:orientation];
    dispatch_async_on_glcontextqueue(^{
        if( orientation == AVCaptureVideoOrientationPortrait )
        {
            self.buffer = [[GLFramebuffer alloc] initWithSize:portraitSize];
            self.yuvbuffer = [[GLFramebuffer alloc] initWithSize:portraitSize];
            self.preRenderBuffer = [[GLFramebuffer alloc] initWithSize:portraitSize];
        }
        else
        {
            self.buffer = [[GLFramebuffer alloc] initWithSize:landscapeSize];
            self.yuvbuffer = [[GLFramebuffer alloc] initWithSize:landscapeSize];
            self.preRenderBuffer = [[GLFramebuffer alloc] initWithSize:landscapeSize];
        }
    });
}

- (void)startEncodeVideoAndAudio
{
    if( !self.audioCapturer )
    {
        self.audioCapturer = [AudioCapturer new];
        self.audioCapturer.delegate = self;
        self.audioCapturer.captureQueue = self.videoCapturer.captureOutputQueue;
        
        [self.audioCapturer startCapture];
        self.encoder = [VideoEncoder new];
        self.encoder.delegate = self;
    }
    else
    {
        [self.audioCapturer startCapture];
    }
    NSURL* url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:[NSString stringWithFormat:@"record_%@.mov",@([Utility curTimeStamp])]];
    _assetWriter = [[GLVideoAssetWriter alloc] initWithURL:url withAudio:YES videoSize:(self.videoCapturer.orientation == AVCaptureVideoOrientationPortrait?portraitSize:landscapeSize)];
    
    CGSize size = portraitSize;
    if( [UIApplication sharedApplication].statusBarOrientation != UIInterfaceOrientationPortrait )
    {
        size = landscapeSize;
    }
    [self.encoder beginEncodeWithVideoSize:size];
}

- (void)stopEncodeVideoAndAudio
{
    [self.encoder endEncode];
    [self.audioCapturer stopCapture];
    if( self.videoCapturer.captureOutputQueue )
    {
        dispatch_async(self.videoCapturer.captureOutputQueue, ^{
            [self.assetWriter stopRecording:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    dispatch_block_t fetchblock = ^{
                        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                            PHAssetChangeRequest* request = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:self.assetWriter.urlAsset];
                            request.favorite = NO;
                        } completionHandler:^(BOOL success, NSError * _Nullable error) {
                            NSError* err = nil;
                            [[NSFileManager defaultManager] removeItemAtPath:self.assetWriter.urlAsset.path error:&err];
                            NSLog(@"issucceeded:%d,error:%@,removeerr:%@",success,error,err);
                        }];
                    };
                    PHAuthorizationStatus stat = [PHPhotoLibrary authorizationStatus] ;
                    
                    if ( stat == PHAuthorizationStatusNotDetermined ) {
                        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                            if ( status == PHAuthorizationStatusAuthorized ) {
                                BLOCK_INVOKE(fetchblock);
                            }
                        }];
                    }
                    else if( stat == PHAuthorizationStatusAuthorized )
                    {
                        BLOCK_INVOKE(fetchblock);
                    }
                    else
                    {
                        [[ScreenToast sharedInstance] showToast:@"无法保存视频，请到设置中打开相册权限"];
                    }
                });
            }];
        });
    }
}

- (void)addDanmaku:(NSString *)danmaku
{
    CTFrameRef frame = [[CtFrameParser sharedParser] getCTFrameOfString:[[NSAttributedString alloc] initWithString:danmaku attributes:@{NSForegroundColorAttributeName:[UIColor redColor],NSFontAttributeName:[UIFont systemFontOfSize:25]}] inRect:CGRectMake(0, 0, 320, NSUIntegerMax)];
    __weak __typeof(self) wself = self;
    [[offScreenContext sharedContext] getImageForCTFrame:frame withCompletion:^(UIImage * img) {
        dispatch_async_on_glcontextqueue(^{
            if( img )
            {
                wself.danmakuImage = [[GLStillImage alloc] initWithImage:img];
                wself.beginx = 1;
            }
            else
            {
                wself.danmakuImage = nil;
            }
        });
    }];
}

#pragma mark videocapturerdelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if( [UIApplication sharedApplication].applicationState == UIApplicationStateBackground && sampleBuffer )
    {
        return;
    }
    if( [captureOutput isKindOfClass:[AVCaptureAudioDataOutput class]] )
    {
        [self.assetWriter enqueueSampleBuffer:sampleBuffer];
        return;
    }
    
    CFRetain(sampleBuffer);
    dispatch_async_on_glcontextqueue(^{
        if( self.isCaptureYUV )
        {
            _texture = [GLTexture glTextureWithPixelBuffer:CMSampleBufferGetImageBuffer(sampleBuffer) isYUV:YES];
            [_yuvbuffer useFramebuffer];
            CVPixelBufferRef pb = CMSampleBufferGetImageBuffer(sampleBuffer);
            CFDictionaryRef dic;
            dic = CVBufferGetAttachments(pb,kCMAttachmentMode_ShouldPropagate);
            _yuvPainter.luminanceTexture = _texture.lumitexture;
            _yuvPainter.chromananceTexture = _texture.chrometexture;
            [_yuvPainter paint];
            _beautyPainter.inputTexture = _yuvbuffer.texture;
        }
        else
        {
            _texture = [GLTexture glTextureWithPixelBuffer:CMSampleBufferGetImageBuffer(sampleBuffer) isYUV:NO];
            _beautyPainter.inputTexture = _texture.texture;
        }
        
        [_buffer useFramebuffer];
        _beautyPainter.inputRotation = (self.videoCapturer.isFrontCamera? GLInputRotationFlipHorizontal:GLInputRotationNone);
        
        [_beautyPainter paint];
        
//        GLFramebuffer* fbuf = [_imageProcessor process:_buffer];
        
        [_preRenderBuffer useFramebuffer];
        _preRenderPainter.inputTexture = _buffer.texture;
        _preRenderPainter.inputRotation = (self.videoCapturer.isFrontCamera? GLInputRotationFlipHorizontal:GLInputRotationNone);
        [_preRenderPainter paint];
        
        if( self.danmakuImage.texture )
        {
            _blendPainter.blendArea = CGRectMake(self.beginx, 0.5, self.danmakuImage.size.width/1.5/_preRenderBuffer.size.width, self.danmakuImage.size.height/1.5/_preRenderBuffer.size.height);
            if( self.beginx + _blendPainter.blendArea.size.width < 0 )
            {
                self.danmakuImage = nil;
            }
            else
            {
                self.beginx -= 5/_preRenderBuffer.size.width;
            }
        }
        
        if( self.danmakuImage.texture )
        {
            [_preRenderBuffer useFramebuffer];
            glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
            glEnable(GL_BLEND);
            _blendPainter.inputTexture = self.danmakuImage.texture;
            [_blendPainter paint];
            glDisable(GL_BLEND);
        }
        
        if( self.danmakuImage )
        {
            [_buffer useFramebuffer];
            glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
            glEnable(GL_BLEND);
            _blendPainter.inputTexture = self.danmakuImage.texture;
            [_blendPainter paint];
            glDisable(GL_BLEND);
        }
        
        if( [UIApplication sharedApplication].applicationState != UIApplicationStateBackground )
        {
            CMSampleBufferRef buffer;
            CMSampleTimingInfo info;
            info.presentationTimeStamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
            info.duration = CMTimeMake(1, [Utility fps]);
            info.decodeTimeStamp = kCMTimeInvalid;
            CMVideoFormatDescriptionRef formatref;
            CMVideoFormatDescriptionCreateForImageBuffer(kCFAllocatorDefault, _buffer.pixelBuffer, &formatref);
            __unused OSStatus ret = CMSampleBufferCreateForImageBuffer(kCFAllocatorDefault, _buffer.pixelBuffer , YES, nil, nil, formatref, &info, &buffer);
            
            [_assetWriter enqueueSampleBuffer:buffer];
            //[_encoder encodeBuffer:buffer];
            CFRelease(buffer);
        }
        
        [_simpleView setFrameBuffer:_preRenderBuffer];
        [_simpleView display];
        _texture = nil;
        CFRelease(sampleBuffer);
    });
}

- (void)encoderOutput:(CMSampleBufferRef)buffer
{
    //[_assetWriter enqueueSampleBuffer:buffer];
}

- (void)encoderSps:(const uint8_t *)sps spsCount:(size_t)spscount pps:(const uint8_t *)pps ppsCount:(size_t)ppscount
{
    [_decoder encoderSps:sps spsCount:spscount pps:pps ppsCount:ppscount];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    CFTypeRef ret = CMGetAttachment(sampleBuffer, kCMSampleBufferAttachmentKey_DroppedFrameReason, kCMAttachmentMode_ShouldNotPropagate);
    NSLog(@"drop sampleframe because of:%@",ret);
    //    Boolean isvalid = CMSampleBufferIsValid(sampleBuffer);
    //    CFArrayRef arr = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, YES);
    //    CMBlockBufferRef ref = CMSampleBufferGetDataBuffer(sampleBuffer);
    //    CMVideoFormatDescriptionRef format = CMSampleBufferGetFormatDescription(sampleBuffer);
    //    arr = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, NO);
}

@end
