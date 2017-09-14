//
//  GLYUVPainter.m
//  openGLDemo
//
//  Created by 方阳 on 17/4/3.
//  Copyright © 2017年 dw_fangyang. All rights reserved.
//

#import "GLYUVPainter.h"
#import "shaderString.h"

@interface GLYUVPainter()

@property (nonatomic,assign) YUVType type;

@end

@implementation GLYUVPainter

#pragma mark utility methods
+ (const NSString*)yuvToRGBFragmentString:(YUVType)type;
{
    switch ( type ) {
        case YUVTypeBT601videoRange:
        case YUVTypeBT709videoRange:
            return glYUVVideoRangeToRGBFragmentShaderString;
        case YUVTypeBT601fullRange:
            return glYUVFullRangeToRGBFragmentShaderString;
        default:
            return glYUVFullRangeToRGBFragmentShaderString;
    }
}

+ (const GLfloat*)yuvToRGBMatrix:(YUVType)type;
{
    switch ( type ) {
        case YUVTypeBT601videoRange:
            return yuvToRGBBT601videoRangeConversionMatrix;
        case YUVTypeBT601fullRange:
            return yuvToRGBBT601fullRangeConversionMatrix;
        case YUVTypeBT709videoRange:
            return yuvToRGBBT709videoRangeConversionMatrix;
            
        default:
            return yuvToRGBBT601fullRangeConversionMatrix;
    }
}

- (instancetype)initWithVertexShader:(const NSString *)vShader fragmentShader:(const NSString *)fShader
{
    return [self initWithVertexShader:vShader fragmentShader:fShader type:YUVTypeUnknown];
}

- (instancetype)initWithVertexShader:(const NSString *)vShader fragmentShader:(const NSString *)fShader type:(YUVType)type
{
    self = [super init];
    if( self )
    {
        _type = type;
        _program = [[GLProgram alloc] initWithVertexString:defVertexShader fragmentString:fShader];
        __unused BOOL ret = [_program link];
        
        NSAssert(ret, @"glyuvpainter program link fail");
        GLuint texturelocation = [_program getAttributeLocation:@"textureCoordinate"];
        glEnableVertexAttribArray(texturelocation);
        
        GLuint positionlocation = [_program getAttributeLocation:@"position"];
        glEnableVertexAttribArray(positionlocation);
    }
    return self;
}

- (instancetype)initWithType:(YUVType)type;
{
    return [self initWithVertexShader:defVertexShader fragmentShader:[GLYUVPainter yuvToRGBFragmentString:type] type:type];
}

#pragma mark api
+ (instancetype)painterWithYUVType:(YUVType)type
{
    return [[GLYUVPainter alloc] initWithType:type];
}

- (void)paint
{
    [_program use];
    
    glClear(GL_COLOR_BUFFER_BIT);
    glActiveTexture(GL_TEXTURE4);
    glBindTexture(GL_TEXTURE_2D, _luminanceTexture);
    glUniform1i([_program getUniformLocation:@"luminanceTexture"], 4);
    glActiveTexture(GL_TEXTURE5);
    glBindTexture(GL_TEXTURE_2D, _chromananceTexture);
    glUniform1i([_program getUniformLocation:@"chrominanceTexture"], 5);
    
    glUniformMatrix3fv([_program getUniformLocation:@"yuvToRGBConversion"], 1, GL_FALSE, [GLYUVPainter yuvToRGBMatrix:_type]);
    
    GLfloat position[] = {-1.0,-1.0,0,1.0,-1.0,0,-1.0,1.0,0,1.0,1.0,0};
    glVertexAttribPointer([_program getAttributeLocation:@"position"], 3, GL_FLOAT, 0, 0, position);
    GLfloat coord1[] = {0,0,1,0,0,1,1,1};
    glVertexAttribPointer([_program getAttributeLocation:@"textureCoordinate"], 2, GL_FLOAT, GL_FALSE, 0, coord1);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

@end
