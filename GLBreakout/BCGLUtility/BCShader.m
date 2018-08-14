//
//  BCShader.m
//  GLBreakout
//
//  Created by BrianChen on 2018/7/13.
//  Copyright © 2018 BrianChen. All rights reserved.
//

#import "BCShader.h"
#import <OpenGL/gl3.h>

@interface BCShader () {
    GLuint _program;
}

@end

@implementation BCShader

- (instancetype)initWithVertexShader:(NSString *)vertexShaderPath fragmentShader:(NSString *)fragmentShaderPath {
    NSError *error = nil;
    NSString *vertexShaderSource = [NSString stringWithContentsOfFile:vertexShaderPath encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"read vertex BCShader file error.\n%@", error.localizedDescription);
        return nil;
    }
    
    NSString *fragmentShaderSource = [NSString stringWithContentsOfFile:fragmentShaderPath encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"read fragment BCShader file error.\n%@", error.localizedDescription);
        return nil;
    }
    
    const GLchar *vShaderSource = vertexShaderSource.UTF8String;
    const GLchar *fShaderSource = fragmentShaderSource.UTF8String;
    
    GLuint vertexShader;
    vertexShader = glCreateShader(GL_VERTEX_SHADER);
    glShaderSource(vertexShader, 1, &vShaderSource, NULL);
    glCompileShader(vertexShader);
    
    GLint status;
    GLchar infoLog[512];
    glGetShaderiv(vertexShader, GL_COMPILE_STATUS, &status);
    if (!status) {
        glGetShaderInfoLog(vertexShader, 512, NULL, infoLog);
        NSLog(@"vertex BCShader compile log:\n%s", infoLog);
    }
    
    GLuint fragmentShader;
    fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(fragmentShader, 1, &fShaderSource, NULL);
    glCompileShader(fragmentShader);
    
    glGetShaderiv(fragmentShader, GL_COMPILE_STATUS, &status);
    if (!status) {
        glGetShaderInfoLog(fragmentShader, 512, NULL, infoLog);
        NSLog(@"fragment BCShader compile log:\n%s", infoLog);
    }
    
    if (self = [super init]) {
        _program = glCreateProgram();
        glAttachShader(_program, vertexShader);
        glAttachShader(_program, fragmentShader);
        glLinkProgram(_program);
        
        glGetProgramiv(_program, GL_LINK_STATUS, &status);
        if (!status) {
            glGetProgramInfoLog(_program, 512, NULL, infoLog);
            NSLog(@"program link log:\n%s", infoLog);
        }
        
        glDeleteShader(vertexShader);
        glDeleteShader(fragmentShader);
    }
    return self;
}

- (void)use {
    glUseProgram(_program);
}

- (void)setFloat:(NSString *)name value:(CGFloat)value {
    glUniform1f(glGetUniformLocation(_program, name.UTF8String), value);
}

- (void)setInteger:(NSString *)name value:(NSInteger)value {
    glUniform1i(glGetUniformLocation(_program, name.UTF8String), (GLint)value);
}

- (void)setVector2f:(NSString *)name vec2f:(GLKVector2)vec2f {
    glUniform2f(glGetUniformLocation(_program, name.UTF8String), vec2f.x, vec2f.y);
}

- (void)setVector3f:(NSString *)name vec3f:(GLKVector3)vec3f {
    glUniform3f(glGetUniformLocation(_program, name.UTF8String), vec3f.x, vec3f.y, vec3f.z);
}

- (void)setVector4f:(NSString *)name vec4f:(GLKVector4)vec4f {
    glUniform4f(glGetUniformLocation(_program, name.UTF8String), vec4f.x, vec4f.y, vec4f.z, vec4f.w);
}

- (void)setMatrix4:(NSString *)name matrix4:(GLKMatrix4)matrix4 {
    glUniformMatrix4fv(glGetUniformLocation(_program, name.UTF8String), 1, GL_FALSE, matrix4.m);
}

- (unsigned int)shaderID {
    return _program;
}

- (void)destroyShader {
    glDeleteProgram(_program);
}

@end
