//
//  BCTexture2D.m
//  GLBreakout
//
//  Created by BrianChen on 2018/7/25.
//  Copyright © 2018 BrianChen. All rights reserved.
//

#import "BCTexture2D.h"
#import <OpenGL/gl3.h>

@interface BCTexture2D () {
    GLsizei _width;
    GLsizei _height;
    GLuint _texID;
}

@end

@implementation BCTexture2D

- (instancetype)init {
    if (self = [super init]) {
        _width = 0;
        _height = 0;
        _internalFormat = GL_RGB;
        _imageFormat = GL_RGB;
        _wrapS = GL_REPEAT;
        _wrapT = GL_REPEAT;
        _filterMax = GL_LINEAR;
        _filterMin = GL_LINEAR;
        glGenTextures(1, &_texID);
    }
    return self;
}

- (void)generateWithData:(void *)data width:(NSUInteger)width height:(NSUInteger)height {
    _width = (GLsizei)width;
    _height = (GLsizei)height;
    glBindTexture(GL_TEXTURE_2D, _texID);
    glTexImage2D(GL_TEXTURE_2D, 0, (GLenum)_internalFormat, _width, _height, 0, (GLenum)_imageFormat, GL_UNSIGNED_BYTE, data);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, (GLint)_wrapS);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, (GLint)_wrapT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, (GLint)_filterMin);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, (GLint)_filterMax);
    glBindTexture(GL_TEXTURE_2D, 0);
}

- (void)bind {
    glBindTexture(GL_TEXTURE_2D, _texID);
}

- (unsigned int)texID {
    return _texID;
}

- (void)destroyTexture {
    glDeleteTextures(1, &_texID);
}

@end
