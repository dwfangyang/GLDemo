//
//  VrPlayerAudioDataController.m
//  openGLDemo
//
//  Created by 方阳 on 17/4/30.
//  Copyright © 2017年 dw_fangyang. All rights reserved.
//

#import "VrPlayerAudioDataController.h"
#import <AudioToolbox/AudioToolbox.h>

static CMSampleBufferRef firstBuffer = nil;

static const int kNumberBuffers = 3;

static void HandleOutputBuffer (void                 *aqData,                 // 1
                                AudioQueueRef        inAQ,                    // 2
                                AudioQueueBufferRef  inBuffer                 // 3
)
{
    VrPlayerAudioDataController* controller = (__bridge VrPlayerAudioDataController*)aqData;
    CMSampleBufferRef buffer = nil;
    if( firstBuffer )
    {
        buffer = firstBuffer;
        firstBuffer = nil;
    }
    else if( controller.delegate )
    {
        buffer = [controller.delegate getNextAudioSampleBuffer];
    }
    if( !buffer )
    {
        AudioQueueStop(inAQ, true);
        AudioQueueDispose (  inAQ,true );
        return;
    }
    CMBlockBufferRef block = CMSampleBufferGetDataBuffer(buffer);
    size_t lengthAtOffset,totalLength;
    char* dataPointer;
    CMBlockBufferGetDataPointer(block, 0, &lengthAtOffset, &totalLength, &dataPointer);
    memcpy(inBuffer->mAudioData, dataPointer, totalLength);
    inBuffer->mAudioDataByteSize = (UInt32)totalLength;
    AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, nil);
    
    if( buffer )
    {
        CFRelease(buffer);
    }
}

@interface VrPlayerAudioDataController(){
    AudioQueueRef                audioQueue;
    const AudioStreamBasicDescription* audioStreamDesc;
    AudioQueueBufferRef          audioQueueBuffers[kNumberBuffers];
    uint32_t                     bufferSize;
    uint32_t                     numberOfPackets;
}

@end

@implementation VrPlayerAudioDataController

- (instancetype)initWithDelegate:(__weak id<VRPlayerAudioDelegate>)delegate;
{
    if( self = [super init] )
    {
        _delegate = delegate;
        firstBuffer = [self.delegate getNextAudioSampleBuffer];
        CMAudioFormatDescriptionRef audioDesc = CMSampleBufferGetFormatDescription(firstBuffer);
        audioStreamDesc = CMAudioFormatDescriptionGetStreamBasicDescription(audioDesc);
        OSStatus stat = AudioQueueNewOutput(audioStreamDesc,HandleOutputBuffer,(__bridge void*)self,NULL,kCFRunLoopCommonModes,0,&audioQueue);
        /*CMSampleTimingInfo timingInfo;
        CMSampleBufferGetSampleTimingInfo(firstBuffer, 0, &timingInfo);*/
        //AudioQueueSetParameter(audioQueue, kAudioQueueParam_Volume, 1.0);
        CMItemCount sampleCount = CMSampleBufferGetNumSamples(firstBuffer);
        if( stat == noErr )
        {
            CMTime duration = CMSampleBufferGetOutputDuration(firstBuffer);
            bufferSize = audioStreamDesc->mBytesPerPacket*audioStreamDesc->mSampleRate*(duration.value*1.0/duration.timescale);
            numberOfPackets = (uint32_t)sampleCount;
            for( int i = 0; i< kNumberBuffers; ++i )
            {
                AudioQueueAllocateBuffer(audioQueue, bufferSize, &audioQueueBuffers[i]);
                HandleOutputBuffer((__bridge void*)self, audioQueue, audioQueueBuffers[i]);
            }
            AudioQueueStart(audioQueue, NULL);
        }
        
    }
    return self;
}
@end
