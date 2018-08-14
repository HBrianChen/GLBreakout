//
//  BCPostProcessor.m
//  GLBreakout
//
//  Created by BrianChen on 2018/8/8.
//  Copyright © 2018 BrianChen. All rights reserved.
//

#import "BCPostProcessor.h"
#import "BCShader.h"
#import "BCTexture2D.h"

@interface BCPostProcessor () {
    BCShader *_shader;
    BCTexture2D *_texture;
    GLuint _MSFBO;
    GLuint _FBO;
    GLuint _RBO;
    GLuint _VAO;
    GLuint _VBO;
}

@end

@implementation BCPostProcessor

- (instancetype)initWithShader:(BCShader *)shader size:(CGSize)size {
    if (self = [super init]) {
        _shader = shader;
        _size = size;
        _enableConfuse = NO;
        _enableChaos = NO;
        _enableShake = NO;
        
        glGenFramebuffers(1, &_MSFBO);
        glGenFramebuffers(1, &_FBO);
        glGenRenderbuffers(1, &_RBO);
        
        glBindFramebuffer(GL_FRAMEBUFFER, _MSFBO);
        glBindRenderbuffer(GL_RENDERBUFFER, _RBO);
        glRenderbufferStorageMultisample(GL_RENDERBUFFER, 8, GL_RGB, size.width, size.height);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _RBO);
        if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
            NSLog(@"Post processor failed to initialize MSFBO.");
        }
        
        glBindFramebuffer(GL_FRAMEBUFFER, _FBO);
        _texture = [[BCTexture2D alloc] init];
        [_texture generateWithData:nil width:size.width height:size.height];
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _texture.texID, 0);
        if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
            NSLog(@"Post processor failed to initialize FBO.");
        }
        glBindFramebuffer(GL_FRAMEBUFFER, 0);
        
        [self setupRenderData];
        [_shader use];
        [_shader setInteger:@"scene" value:0];
        GLfloat offset = 1.0f / 300.0f;
        GLfloat offsets[9][2] = {
            {-offset, offset},
            {0.0f, offset},
            {offset, offset},
            {-offset, 0.0f},
            {0.0f, 0.0f},
            {offset, 0.0f},
            {-offset, -offset},
            {0.0f, -offset},
            {offset, -offset}
        };
        glUniform2fv(glGetUniformLocation(_shader.shaderID, "offsets"), 9, (GLfloat *)offsets);
        GLint edge_kernel[9] = {
            -1, -1, -1,
            -1,  8, -1,
            -1, -1, -1
        };
        glUniform1iv(glGetUniformLocation(_shader.shaderID, "edge_kernel"), 9, edge_kernel);
        GLfloat blur_kernel[9] = {
            1.0 / 16, 2.0 / 16, 1.0 / 16,
            2.0 / 16, 4.0 / 16, 2.0 / 16,
            1.0 / 16, 2.0 / 16, 1.0/ 16
        };
        glUniform1fv(glGetUniformLocation(_shader.shaderID, "blur_kernel"), 9, blur_kernel);
    }
    return self;
}

- (void)setupRenderData {
    GLfloat vertices[] = {
        -1.0f, -1.0f, 0.0f, 0.0f,
        1.0f, 1.0f, 1.0f, 1.0f,
        -1.0f, 1.0f, 0.0f, 1.0f,
        
        -1.0f, -1.0f, 0.0f, 0.0f,
        1.0f, -1.0f, 1.0f, 0.0f,
        1.0f, 1.0f, 1.0f, 1.0f
    };
    
    glGenVertexArrays(1, &_VAO);
    glGenBuffers(1, &_VBO);
    
    glBindBuffer(GL_ARRAY_BUFFER, _VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    glBindVertexArray(_VAO);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 4, GL_FLOAT, GL_FALSE, 4 * sizeof(GLfloat), (GLvoid *)0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
}

- (void)beginRender {
    glBindFramebuffer(GL_FRAMEBUFFER, _MSFBO);
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
}

- (void)endRender {
    glBindFramebuffer(GL_READ_FRAMEBUFFER, _MSFBO);
    glBindFramebuffer(GL_DRAW_FRAMEBUFFER, _FBO);
    glBlitFramebuffer(0, 0, _size.width, _size.height, 0, 0, _size.width, _size.height, GL_COLOR_BUFFER_BIT, GL_NEAREST);
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
}

- (void)render:(float)time {
    [_shader use];
    [_shader setFloat:@"time" value:time];
    [_shader setInteger:@"confuse" value:_enableConfuse];
    [_shader setInteger:@"chaos" value:_enableChaos];
    [_shader setInteger:@"shake" value:_enableShake];
    
    glActiveTexture(GL_TEXTURE0);
    [_texture bind];
    glBindVertexArray(_VAO);
    glDrawArrays(GL_TRIANGLES, 0, 6);
    glBindVertexArray(0);
}

- (void)destroyPostProcessor {
    glDeleteBuffers(1, &_VBO);
    glDeleteVertexArrays(1, &_VAO);
    glDeleteFramebuffers(1, &_MSFBO);
    glDeleteFramebuffers(1, &_FBO);
    glDeleteRenderbuffers(1, &_RBO);
}


@end
