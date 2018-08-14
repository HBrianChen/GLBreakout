//
//  BCResourceManager.m
//  GLBreakout
//
//  Created by BrianChen on 2018/7/25.
//  Copyright © 2018 BrianChen. All rights reserved.
//

#import "BCResourceManager.h"
#import "BCShader.h"
#import "BCTexture2D.h"
#import <OpenGL/gl3.h>

@implementation BCResourceManager

+ (instancetype)sharedResourceManager {
    static BCResourceManager *resourceManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        resourceManager = [[BCResourceManager alloc] init];
    });
    return resourceManager;
}

- (instancetype)init {
    if (self = [super init]) {
        _shaders = [NSMutableDictionary dictionary];
        _textures = [NSMutableDictionary dictionary];
    }
    return self;
}

- (BCShader *)loadShaderWithVShaderFile:(NSString *)vShaderFile fShaderFile:(NSString *)fShaderFile shaderName:(NSString *)shaderName {
    _shaders[shaderName] = [[BCShader alloc] initWithVertexShader:vShaderFile fragmentShader:fShaderFile];
    return _shaders[shaderName];
}

- (BCTexture2D *)loadTextureWithFile:(NSString *)file useAlpha:(BOOL)useAlpha textureName:(NSString *)textureName {
    _textures[textureName] = [self loadTextureFromFile:file useAlpha:useAlpha];
    return _textures[textureName];
}

- (BCTexture2D *)loadTextureFromFile:(NSString *)file useAlpha:(BOOL)useAlpha {
    NSURL *url = [NSURL fileURLWithPath:file];
    CGImageSourceRef imageSourceRef = CGImageSourceCreateWithURL((__bridge CFURLRef)url, NULL);
    CGImageRef imageRef = CGImageSourceCreateImageAtIndex (imageSourceRef, 0, NULL);
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGRect rect = {{0, 0}, {width, height}};
    
    size_t bytesPerRow = width * 4;
    uint32_t bitmapInfo = kCGBitmapByteOrder32Host;
    if (useAlpha) {
        bitmapInfo |= kCGImageAlphaPremultipliedFirst;
    } else {
        bitmapInfo |= kCGImageAlphaNoneSkipFirst;
    }
    
    NSUInteger dataLen = bytesPerRow * height;
    void * data = calloc(dataLen, 1);
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmapContext = CGBitmapContextCreate (data,
                                                        width, height, 8,
                                                        bytesPerRow, space,
                                                        bitmapInfo);
    CGContextSetBlendMode(bitmapContext, kCGBlendModeCopy);
    CGContextDrawImage(bitmapContext, rect, imageRef);
    CGContextRelease(bitmapContext);
    
    BCTexture2D *texture = [[BCTexture2D alloc] init];
    texture.internalFormat = GL_RGBA;
    texture.imageFormat = GL_BGRA;
    [texture generateWithData:data width:width height:height];
    free(data);
    return texture;
}

- (void)destroyResourceManager {
    [_textures enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, BCTexture2D * _Nonnull obj, BOOL * _Nonnull stop) {
        [obj destroyTexture];
    }];
    [_shaders enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, BCShader * _Nonnull obj, BOOL * _Nonnull stop) {
        [obj destroyShader];
    }];
    [_textures removeAllObjects];
    [_shaders removeAllObjects];
}

@end
