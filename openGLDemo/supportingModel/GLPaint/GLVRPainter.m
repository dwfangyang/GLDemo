//
//  GLVRPainter.m
//  openGLDemo
//
//  Created by 方阳 on 17/4/8.
//  Copyright © 2017年 dw_fangyang. All rights reserved.
//

#import "GLVRPainter.h"
#import <GLKit/GLKit.h>
#define PI 3.141592653

@interface GLVRPainter()
{
    GLfloat* vertices;
    GLushort* indices;
    GLfloat* textureCoors;
    GLushort numIndices;
    GLushort numVertices;
}

@property (nonatomic,assign) GLuint vertexIndicesBufferID;
@property (nonatomic,assign) GLuint vertexBufferID;
@property (nonatomic,assign) GLuint vertexTexCoordID;

@end

@implementation GLVRPainter

- (instancetype)initWithVertexShader:(const NSString *)vShader fragmentShader:(const NSString *)fShader
{
    self = [super initWithVertexShader:vShader fragmentShader:fShader];
    if( self )
    {
        [_program use];
        [self updateMatrix];
        [self config];
    }
    return self;
}

- (void)paint
{
    glBindBuffer(GL_ARRAY_BUFFER, _vertexTexCoordID);
    glVertexAttribPointer(textureCoordIn, 2, GL_FLOAT, GL_FALSE, 0, NULL);// [self inputTextureCoordinatesForInputRotation:self.inputRotation]);
    [_program use];
    
    glClearColor(1.0, 0, 0, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, self.inputTexture);
    glUniform1i(textureSampleUniform, 0);
    /*glGenBuffers(1, &_vertexIndicesBufferID);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, self.vertexIndicesBufferID);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, 3*sizeof(GLushort) , indices, GL_STATIC_DRAW);*/
    
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferID);
    //GLfloat position[] = {0.2,0.3,0.5,0.4,0.1,0.4,-0.2,0.3,0.3};// {-1.0,-1.0,-1.0,1.0,-1.0,-1.0,-1.0,1.0,-1.0,1.0,1.0,-1.0};
    glVertexAttribPointer(positionSlot, 3, GL_FLOAT, GL_FALSE, 0, NULL);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    //Indices
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, self.vertexIndicesBufferID);
    //[self updateMatrix];
    
    //glDrawArrays(GL_TRIANGLE_STRIP, 0, 3);
    glDrawElements(GL_TRIANGLES, numIndices, GL_UNSIGNED_SHORT, 0);
}

#pragma mark utility methods
- (void)config
{
    GLushort latitudeSlice = 70, longitudeSlice = 124;
    numVertices = (latitudeSlice-1)*(longitudeSlice+1) + 2;
    numIndices = latitudeSlice*longitudeSlice*6;
    if( !vertices )
    {
        vertices =(GLfloat*)malloc(numVertices*3*sizeof(GLfloat));
    }
    if( !indices )
    {
        indices =(GLushort*)malloc(numIndices*sizeof(GLushort));
    }
    if( !textureCoors )
    {
        textureCoors = (GLfloat*)malloc(numVertices*2*sizeof(GLfloat));
    }
    
    vertices[0] = 0;vertices[1] = 0;vertices[2] = 1;vertices[3] = 0;vertices[4] = 0;vertices[5] = -1;
    textureCoors[0] = 0;textureCoors[1] = 1; textureCoors[2] = 0;textureCoors[3] = 0;
    float latiAngleStep = PI/latitudeSlice, longiAngleStep = 2*PI/longitudeSlice;
    for( int i = 1; i< latitudeSlice; ++i )
    {
        for( int j = 0; j < longitudeSlice+1; ++j )
        {
            float longiAngle = j*longiAngleStep,latiangle = i*latiAngleStep;
            if( j == longitudeSlice )
            {
                longiAngle = 0;
            }
            GLfloat *vertex = &vertices[(2+j+(i-1)*(longitudeSlice+1))*3];
            vertex[0] = sinf(latiangle)*cosf(longiAngle);
            vertex[1] = cosf(latiangle);
            vertex[2] = sinf(latiangle)*sinf(longiAngle);
            
            GLfloat* tco = &textureCoors[(2+j+(i-1)*(longitudeSlice+1))*2];
            tco[0] = j*1.0/longitudeSlice;
            if( longitudeSlice == j )
            {
                tco[0] = 0;
            }
            tco[1] = 1- i*1.0/latitudeSlice;
        }
    }
    
    for( int k = 0; k < latitudeSlice ; ++k )
    {
        for( int m = 0;  m < longitudeSlice; ++m )
        {
            GLushort* index = &indices[(k*(longitudeSlice+1)+m)*6];
            if( k == 0 )
            {
                index[0] = m+2;
                index[1] = m +3;
                index[2] = 0;
                index[3] = index[1];
                index[4] = index[2];
                index[5] = 0;
            }
            else if( k == latitudeSlice-1 )
            {
                
                index[0] = 0;
                index[1] = 0;
                index[2] = m + (longitudeSlice+1)*(k-1) + 2;
                index[3] = index[1];
                index[4] = index[2];
                index[5] = m+1 + (longitudeSlice+1)*(k-1) +2;
            }
            else
            {
                index[0] = m+(longitudeSlice+1)*k+2;
                index[1] = (m+1) + (longitudeSlice+1)*k+2;
                index[2] = m + (longitudeSlice+1)*(k-1)+2;
                index[3] = index[1];
                index[4] = index[2];
                index[5] = m+1 + (longitudeSlice+1)*(k-1)+2;
            }
        }
    }
    
    glGenBuffers(1, &_vertexTexCoordID);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexTexCoordID);
    glBufferData(GL_ARRAY_BUFFER, numVertices*2*sizeof(GLfloat), textureCoors, GL_STATIC_DRAW);
    
    glGenBuffers(1, &_vertexIndicesBufferID);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, self.vertexIndicesBufferID);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, numIndices*sizeof(GLushort), indices, GL_STATIC_DRAW);
    
    glGenBuffers(1, &_vertexBufferID);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferID);
    glBufferData(GL_ARRAY_BUFFER, numVertices * 3*sizeof(GLfloat), vertices, GL_STATIC_DRAW);
}

- (void)updateMatrix;
{
    static float offset = 80;
    GLKMatrix4 projectionmatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90), 16.0/9, 0.1, 2);
    GLKMatrix4 modelviewmatrix = GLKMatrix4RotateY(GLKMatrix4Identity, PI*offset/100);
    GLKMatrix4 mvp = GLKMatrix4Multiply(projectionmatrix, modelviewmatrix);
    GLuint mvpMatrixLocation = [_program getUniformLocation:@"mvpMatrix"];
    glUniformMatrix4fv(mvpMatrixLocation, 1, GL_FALSE, mvp.m);
    offset += 1;
}

- (void)genVertices;
{
    
    /*glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*3, NULL);
    
    // Texture Coordinates
    glGenBuffers(1, &_vertexTexCoordID);
    glBindBuffer(GL_ARRAY_BUFFER, self.vertexTexCoordID);
    glBufferData(GL_ARRAY_BUFFER, numVertices*2*sizeof(GLfloat), vTextCoord, GL_DYNAMIC_DRAW);
    
    glEnableVertexAttribArray(self.vertexTexCoordAttributeIndex);
    glVertexAttribPointer(self.vertexTexCoordAttributeIndex, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*2, NULL);*/
}
@end
