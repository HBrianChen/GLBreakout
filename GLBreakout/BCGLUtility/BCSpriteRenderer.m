//
//  BCSpriteRenderer.m
//  GLBreakout
//
//  Created by BrianChen on 2018/8/2.
//  Copyright © 2018 BrianChen. All rights reserved.
//

#import "BCSpriteRenderer.h"
#import "BCShader.h"
#import "BCTexture2D.h"

@interface BCSpriteRenderer () {
    BCShader *_shader;
    GLuint _quadVAO;
    GLuint _quadVBO;
}

- (void)setupRenderData;

@end

@implementation BCSpriteRenderer

- (instancetype)initWithShader:(BCShader *)shader {
    if (self = [super init]) {
        _shader = shader;
        [self setupRenderData];
    }
    return self;
}

- (void)setupRenderData {
    GLfloat vertices[] = {
        0.0f, 1.0f, 0.0f, 1.0f,
        1.0f, 0.0f, 1.0f, 0.0f,
        0.0f, 0.0f, 0.0f, 0.0f,
        
        0.0f, 1.0f, 0.0f, 1.0f,
        1.0f, 1.0f, 1.0f, 1.0f,
        1.0f, 0.0f, 1.0f, 0.0f
    };
    
    glGenVertexArrays(1, &_quadVAO);
    glGenBuffers(1, &_quadVBO);
    
    glBindBuffer(GL_ARRAY_BUFFER, _quadVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    glBindVertexArray(_quadVAO);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 4, GL_FLOAT, GL_FALSE, 4 * sizeof(GLfloat), (GLvoid *)0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
}

- (void)drawSpriteWithTexture:(BCTexture2D *)texture position:(GLKVector2)position {
    GLKVector3 color = GLKVector3Make(1.0f, 1.0f, 1.0f);
    [self drawSpriteWithTexture:texture position:position size:GLKVector2Make(10, 10) rotate:0.0f color:color];
}

- (void)drawSpriteWithTexture:(BCTexture2D *)texture position:(GLKVector2)position size:(GLKVector2)size rotate:(GLfloat)rotate color:(GLKVector3)color {
    [_shader use];
    GLKMatrix4 model = GLKMatrix4Identity;
    model = GLKMatrix4Translate(model, position.x, position.y, 0.0f);
    
    model = GLKMatrix4Translate(model, 0.5f * size.x, 0.5f * size.y, 0.0f);
    model = GLKMatrix4Rotate(model, rotate, 0.0f, 0.0f, 1.0f);
    model = GLKMatrix4Translate(model, -0.5f * size.x, -0.5f * size.y, 0.0f);
    
    model = GLKMatrix4Scale(model, size.x, size.y, 1.0f);
    
    [_shader setMatrix4:@"model" matrix4:model];
    [_shader setVector3f:@"spriteColor" vec3f:color];
    
    glActiveTexture(GL_TEXTURE0);
    [texture bind];
    
    glBindVertexArray(_quadVAO);
    glDrawArrays(GL_TRIANGLES, 0, 6);
    glBindVertexArray(0);
}

- (void)destroyRenderer {
    glDeleteBuffers(1, &_quadVBO);
    glDeleteVertexArrays(1, &_quadVAO);
}

@end
