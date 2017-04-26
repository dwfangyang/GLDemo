//
//  GLBeautyPainter.m
//  openGLDemo
//
//  Created by 方阳 on 16/12/16.
//  Copyright © 2016年 dw_fangyang. All rights reserved.
//

#import "GLBeautyPainter.h"
#import "GLContext.h"
#import "shaderString.h"

NSString* const kBeautyVertextShaderString = SHADER(
 attribute vec4 position;
 attribute vec4 SourceColor;
 varying vec4 DestinationColor;
 attribute vec2 textureCoordinate;
 varying vec2 inputTextureCoordinate;
 void main(void) {
    DestinationColor = SourceColor;
    gl_Position = position;
    inputTextureCoordinate = textureCoordinate;
 }
);

NSString * const kMBeautyV2FragmentShaderString = SHADER
(
 precision highp float;
 varying vec4 DestinationColor;
 varying highp vec2 inputTextureCoordinate;
 uniform sampler2D inputImageTexture;
 uniform float uFrameWidth;
 uniform float uFrameHeight;
 uniform float uHueFactor;
 uniform float uSmoothFactor;
 uniform float uRouguangFactor;
 uniform float uMixFactor;
 uniform float uFactor;
 
 void main() {
     //gl_FragColor = texture2D(inputImageTexture, inputTextureCoordinate);
     //return;
     vec3 centralColor;
     mediump float sampleColor;
     
     vec2 blurCoordinates[20];
     
     float mul = 2.0;
     float mul_x = mul / uFrameWidth;
     float mul_y = mul / uFrameHeight;
     
     blurCoordinates[0] = inputTextureCoordinate + vec2(0.0 * mul_x, -10.0 * mul_y);
     blurCoordinates[1] = inputTextureCoordinate + vec2(5.0 * mul_x, -8.0 * mul_y);
     blurCoordinates[2] = inputTextureCoordinate + vec2(8.0 * mul_x, -5.0 * mul_y);
     blurCoordinates[3] = inputTextureCoordinate + vec2(10.0 * mul_x, 0.0 * mul_y);
     blurCoordinates[4] = inputTextureCoordinate + vec2(8.0 * mul_x, 5.0 * mul_y);
     blurCoordinates[5] = inputTextureCoordinate + vec2(5.0 * mul_x, 8.0 * mul_y);
     blurCoordinates[6] = inputTextureCoordinate + vec2(0.0 * mul_x, 10.0 * mul_y);
     blurCoordinates[7] = inputTextureCoordinate + vec2(-5.0 * mul_x, 8.0 * mul_y);
     blurCoordinates[8] = inputTextureCoordinate + vec2(-8.0 * mul_x, 5.0 * mul_y);
     blurCoordinates[9] = inputTextureCoordinate + vec2(-10.0 * mul_x, 0.0 * mul_y);
     blurCoordinates[10] = inputTextureCoordinate + vec2(-8.0 * mul_x ,-5.0 * mul_y);
     blurCoordinates[11] = inputTextureCoordinate + vec2(-5.0 * mul_x, -8.0 * mul_y);
     blurCoordinates[12] = inputTextureCoordinate + vec2(0.0 * mul_x, -6.0 * mul_y);
     blurCoordinates[13] = inputTextureCoordinate + vec2(-4.0 * mul_x, -4.0 * mul_y);
     blurCoordinates[14] = inputTextureCoordinate + vec2(-6.0 * mul_x, 0.0 * mul_y);
     blurCoordinates[15] = inputTextureCoordinate + vec2(-4.0 * mul_x, 4.0 * mul_y);
     blurCoordinates[16] = inputTextureCoordinate + vec2(0.0 * mul_x, 6.0 * mul_y);
     blurCoordinates[17] = inputTextureCoordinate + vec2(4.0 * mul_x, 4.0 * mul_y);
     blurCoordinates[18] = inputTextureCoordinate + vec2(6.0 * mul_x, 0.0 * mul_y);
     blurCoordinates[19] = inputTextureCoordinate + vec2(4.0 * mul_x, -4.0 * mul_y);
     
     sampleColor = texture2D(inputImageTexture, inputTextureCoordinate).g * 22.0;
     sampleColor += texture2D(inputImageTexture, blurCoordinates[0]).g;
     sampleColor += texture2D(inputImageTexture, blurCoordinates[1]).g;
     sampleColor += texture2D(inputImageTexture, blurCoordinates[2]).g;
     sampleColor += texture2D(inputImageTexture, blurCoordinates[3]).g;
     sampleColor += texture2D(inputImageTexture, blurCoordinates[4]).g;
     sampleColor += texture2D(inputImageTexture, blurCoordinates[5]).g;
     sampleColor += texture2D(inputImageTexture, blurCoordinates[6]).g;
     sampleColor += texture2D(inputImageTexture, blurCoordinates[7]).g;
     sampleColor += texture2D(inputImageTexture, blurCoordinates[8]).g;
     sampleColor += texture2D(inputImageTexture, blurCoordinates[9]).g;
     sampleColor += texture2D(inputImageTexture, blurCoordinates[10]).g;
     sampleColor += texture2D(inputImageTexture, blurCoordinates[11]).g;
     sampleColor += texture2D(inputImageTexture, blurCoordinates[12]).g * 2.0;
     sampleColor += texture2D(inputImageTexture, blurCoordinates[13]).g * 2.0;
     sampleColor += texture2D(inputImageTexture, blurCoordinates[14]).g * 2.0;
     sampleColor += texture2D(inputImageTexture, blurCoordinates[15]).g * 2.0;
     sampleColor += texture2D(inputImageTexture, blurCoordinates[16]).g * 2.0;
     sampleColor += texture2D(inputImageTexture, blurCoordinates[17]).g * 2.0;
     sampleColor += texture2D(inputImageTexture, blurCoordinates[18]).g * 2.0;
     sampleColor += texture2D(inputImageTexture, blurCoordinates[19]).g * 2.0;
     sampleColor = sampleColor / 50.0;
     
     centralColor = texture2D(inputImageTexture, inputTextureCoordinate).rgb;
     float dis = centralColor.g - sampleColor + 0.5;
     
     if(dis <= 0.5) {
         dis = dis * dis * 2.0;
     } else {
         dis = 1.0 - ((1.0 - dis)*(1.0 - dis) * 2.0);
     }
     
     if(dis <= 0.5) {
         dis = dis * dis * 2.0;
     } else {
         dis = 1.0 - ((1.0 - dis)*(1.0 - dis) * 2.0);
     }
     
     if(dis <= 0.5) {
         dis = dis * dis * 2.0;
     } else {
         dis = 1.0 - ((1.0 - dis)*(1.0 - dis) * 2.0);
     }
     
     if(dis <= 0.5) {
         dis = dis * dis * 2.0;
     } else {
         dis = 1.0 - ((1.0 - dis)*(1.0 - dis) * 2.0);
     }
     
     if(dis <= 0.5) {
         dis = dis * dis * 2.0;
     } else {
         dis = 1.0 - ((1.0 - dis)*(1.0 - dis) * 2.0);
     }
     
     float aa = 1.03;
     vec3 smoothColor = centralColor * 1.0;// aa - vec3(dis) * (aa-1.0);

     float hueFactor = uHueFactor;
     float smoothFactor = uSmoothFactor;
     float rouguangFactor = uRouguangFactor;
     float mixFactor = uMixFactor;
     
     float hue = dot(smoothColor, vec3(0.299, 0.587, 0.114));
     aa = 1.0 + pow(hue, hueFactor) * 0.1;
     smoothColor = centralColor* aa  - vec3(dis) * (aa - 1.0);
//     gl_FragColor = vec4(smoothColor,1.0);
     
     smoothColor.r = clamp(pow(smoothColor.r, smoothFactor), 0.0, 1.0);
     smoothColor.g = clamp(pow(smoothColor.g, smoothFactor), 0.0, 1.0);
     smoothColor.b = clamp(pow(smoothColor.b, smoothFactor), 0.0, 1.0);
     
     vec3 lvse = vec3(1.0) - (vec3(1.0) - smoothColor) * (vec3(1.0) - centralColor);
     vec3 bianliang = max(smoothColor, centralColor);
     vec3 rouguang = 2.0 * centralColor * smoothColor + centralColor * centralColor - 2.0 * centralColor * centralColor * smoothColor;
     
     gl_FragColor = vec4(mix(centralColor, lvse, pow(hue, hueFactor)), 1.0);
     gl_FragColor.rgb = mix(gl_FragColor.rgb, bianliang, pow(hue, hueFactor));
     gl_FragColor.rgb = mix(gl_FragColor.rgb, rouguang, rouguangFactor);
     mat3 saturateMatrix = mat3(1.0102, -0.0598, -0.061,
                                -0.0774, 1.0826, -0.0786,
                                -0.0228, -0.0228, 1.0772);
     
     vec3 satcolor = gl_FragColor.rgb * saturateMatrix;
     gl_FragColor.rgb = mix(gl_FragColor.rgb, satcolor, 1.0);
     
     //gl_FragColor.rgb = vec3(mul_x*10.0,mul_y*100.0,1.0);
 }
);
//NSString * const kMBeautyV2FragmentShaderString = SHADER
//(
// precision highp float;
// varying vec4 DestinationColor;
// varying highp vec2 inpuTextureCoordinate;
// uniform sampler2D inputImageTexture;
// uniform float uFrameWidth;
// uniform float uFrameHeight;
// uniform float uHueFactor;
// uniform float uSmoothFactor;
// uniform float uRouguangFactor;
// uniform float uMixFactor;
// uniform float uFactor;
// 
// void main() {
//     vec3 centralColor;
//     mediump float sampleColor;
//     
//     vec2 blurCoordinates[20];
//     
//     float mul = 2.0;
//     float mul_x = mul / uFrameWidth;
//     float mul_y = mul / uFrameHeight;
//     
//     blurCoordinates[0] = inpuTextureCoordinate + vec2(0.0 * mul_x, -10.0 * mul_y);
//     blurCoordinates[1] = inpuTextureCoordinate + vec2(5.0 * mul_x, -8.0 * mul_y);
//     blurCoordinates[2] = inpuTextureCoordinate + vec2(8.0 * mul_x, -5.0 * mul_y);
//     blurCoordinates[3] = inpuTextureCoordinate + vec2(10.0 * mul_x, 0.0 * mul_y);
//     blurCoordinates[4] = inpuTextureCoordinate + vec2(8.0 * mul_x, 5.0 * mul_y);
//     blurCoordinates[5] = inpuTextureCoordinate + vec2(5.0 * mul_x, 8.0 * mul_y);
//     blurCoordinates[6] = inpuTextureCoordinate + vec2(0.0 * mul_x, 10.0 * mul_y);
//     blurCoordinates[7] = inpuTextureCoordinate + vec2(-5.0 * mul_x, 8.0 * mul_y);
//     blurCoordinates[8] = inpuTextureCoordinate + vec2(-8.0 * mul_x, 5.0 * mul_y);
//     blurCoordinates[9] = inpuTextureCoordinate + vec2(-10.0 * mul_x, 0.0 * mul_y);
//     blurCoordinates[10] = inpuTextureCoordinate + vec2(-8.0 * mul_x ,-5.0 * mul_y);
//     blurCoordinates[11] = inpuTextureCoordinate + vec2(-5.0 * mul_x, -8.0 * mul_y);
//     blurCoordinates[12] = inpuTextureCoordinate + vec2(0.0 * mul_x, -6.0 * mul_y);
//     blurCoordinates[13] = inpuTextureCoordinate + vec2(-4.0 * mul_x, -4.0 * mul_y);
//     blurCoordinates[14] = inpuTextureCoordinate + vec2(-6.0 * mul_x, 0.0 * mul_y);
//     blurCoordinates[15] = inpuTextureCoordinate + vec2(-4.0 * mul_x, 4.0 * mul_y);
//     blurCoordinates[16] = inpuTextureCoordinate + vec2(0.0 * mul_x, 6.0 * mul_y);
//     blurCoordinates[17] = inpuTextureCoordinate + vec2(4.0 * mul_x, 4.0 * mul_y);
//     blurCoordinates[18] = inpuTextureCoordinate + vec2(6.0 * mul_x, 0.0 * mul_y);
//     blurCoordinates[19] = inpuTextureCoordinate + vec2(4.0 * mul_x, -4.0 * mul_y);
//     
//     sampleColor = texture2D(inputImageTexture, inpuTextureCoordinate).g * 22.0;
//     sampleColor += texture2D(inputImageTexture, blurCoordinates[0]).g;
//     sampleColor += texture2D(inputImageTexture, blurCoordinates[1]).g;
//     sampleColor += texture2D(inputImageTexture, blurCoordinates[2]).g;
//     sampleColor += texture2D(inputImageTexture, blurCoordinates[3]).g;
//     sampleColor += texture2D(inputImageTexture, blurCoordinates[4]).g;
//     sampleColor += texture2D(inputImageTexture, blurCoordinates[5]).g;
//     sampleColor += texture2D(inputImageTexture, blurCoordinates[6]).g;
//     sampleColor += texture2D(inputImageTexture, blurCoordinates[7]).g;
//     sampleColor += texture2D(inputImageTexture, blurCoordinates[8]).g;
//     sampleColor += texture2D(inputImageTexture, blurCoordinates[9]).g;
//     sampleColor += texture2D(inputImageTexture, blurCoordinates[10]).g;
//     sampleColor += texture2D(inputImageTexture, blurCoordinates[11]).g;
//     sampleColor += texture2D(inputImageTexture, blurCoordinates[12]).g * 2.0;
//     sampleColor += texture2D(inputImageTexture, blurCoordinates[13]).g * 2.0;
//     sampleColor += texture2D(inputImageTexture, blurCoordinates[14]).g * 2.0;
//     sampleColor += texture2D(inputImageTexture, blurCoordinates[15]).g * 2.0;
//     sampleColor += texture2D(inputImageTexture, blurCoordinates[16]).g * 2.0;
//     sampleColor += texture2D(inputImageTexture, blurCoordinates[17]).g * 2.0;
//     sampleColor += texture2D(inputImageTexture, blurCoordinates[18]).g * 2.0;
//     sampleColor += texture2D(inputImageTexture, blurCoordinates[19]).g * 2.0;
//     sampleColor = sampleColor / 50.0;
//     
//     centralColor = texture2D(inputImageTexture, inpuTextureCoordinate).rgb;
//     float dis = centralColor.g - sampleColor + 0.5;
//     
//     if(dis <= 0.5) {
//         dis = dis * dis * 2.0;
//     } else {
//         dis = 1.0 - ((1.0 - dis)*(1.0 - dis) * 2.0);
//     }
//     
//     if(dis <= 0.5) {
//         dis = dis * dis * 2.0;
//     } else {
//         dis = 1.0 - ((1.0 - dis)*(1.0 - dis) * 2.0);
//     }
//     
//     if(dis <= 0.5) {
//         dis = dis * dis * 2.0;
//     } else {
//         dis = 1.0 - ((1.0 - dis)*(1.0 - dis) * 2.0);
//     }
//     
//     if(dis <= 0.5) {
//         dis = dis * dis * 2.0;
//     } else {
//         dis = 1.0 - ((1.0 - dis)*(1.0 - dis) * 2.0);
//     }
//     
//     if(dis <= 0.5) {
//         dis = dis * dis * 2.0;
//     } else {
//         dis = 1.0 - ((1.0 - dis)*(1.0 - dis) * 2.0);
//     }
//     
//     float aa = 1.03;
//     vec3 smoothColor = centralColor *1.0;//* aa - vec3(dis) * (aa-1.0);
//     
//     float hueFactor = uHueFactor;
//     float smoothFactor = uSmoothFactor;
//     float rouguangFactor = uRouguangFactor;
//     float mixFactor = uMixFactor;
//     
//     float hue = dot(smoothColor, vec3(0.299, 0.587, 0.114));
//     aa = 1.0 + pow(hue, hueFactor) * 0.1;
//     smoothColor = centralColor * aa - vec3(dis) * (aa - 1.0);
//     
//      smoothColor.r = clamp(pow(smoothColor.r, smoothFactor), 0.0, 1.0);
//      smoothColor.g = clamp(pow(smoothColor.g, smoothFactor), 0.0, 1.0);
//      smoothColor.b = clamp(pow(smoothColor.b, smoothFactor), 0.0, 1.0);
//
//      vec3 lvse = vec3(1.0) - (vec3(1.0) - smoothColor) * (vec3(1.0) - centralColor);
//      vec3 bianliang = max(smoothColor, centralColor);
//      vec3 rouguang = 2.0 * centralColor * smoothColor + centralColor * centralColor - 2.0 * centralColor * centralColor * smoothColor;
//
//      gl_FragColor = vec4(mix(centralColor, lvse, pow(hue, hueFactor)), 1.0);
//      gl_FragColor.rgb = mix(gl_FragColor.rgb, bianliang, pow(hue, hueFactor));
//      gl_FragColor.rgb = mix(gl_FragColor.rgb, rouguang, rouguangFactor);
//      mat3 saturateMatrix = mat3(1.0102, -0.0598, -0.061,
//                                 -0.0774, 1.0826, -0.0786,
//                                 -0.0228, -0.0228, 1.0772);
//
//      vec3 satcolor = gl_FragColor.rgb * saturateMatrix;
//      gl_FragColor.rgb = mix(gl_FragColor.rgb, satcolor, 1.0);
//     
//     //gl_FragColor.rgb = vec3(mul_x*10.0,mul_y*100.0,1.0);
// }
// );
@interface GLBeautyPainter()

@end

@implementation GLBeautyPainter

- (instancetype)initWithVertexShader:(NSString *)vShader fragmentShader:(NSString *)fShader
{
    self = [super initWithVertexShader:vShader fragmentShader:fShader];
    if( self )
    {
        [[GLContext sharedGLContext] useGLContext];
        [_program use];
        GLuint width = [_program getUniformLocation:@"uFrameWidth"];
        GLuint height = [_program getUniformLocation:@"uFrameHeight"];
        GLuint hue = [_program getUniformLocation:@"uHueFactor"];
        GLuint smooth = [_program getUniformLocation:@"uSmoothFactor"];
        GLuint rouguang = [_program getUniformLocation:@"uRouguangFactor"];
        GLuint mix = [_program getUniformLocation:@"uMixFactor"];
        GLuint ufactor = [_program getUniformLocation:@"uFactor"];
        float factor = 0.9;
        glUniform1f(width, 360);
        glUniform1f(height, 640);
        glUniform1f(hue, 1.3f * (1.0f - factor) + 0.3f * factor);
        glUniform1f(smooth, 1.4f * (1.0f - factor) + 0.6 * factor);
        glUniform1f(rouguang, 0.15f + factor * 0.25f);
        glUniform1f(mix, 0.15f + factor * 0.2f);
        glUniform1f(ufactor, factor);
    }
    return self;
}
@end
