//
//  BCResourceManager.h
//  GLBreakout
//
//  Created by BrianChen on 2018/7/25.
//  Copyright © 2018 BrianChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BCShader;
@class BCTexture2D;

@interface BCResourceManager : NSObject

@property (nonatomic, readonly, strong) NSMutableDictionary<NSString *, BCShader *> *shaders;
@property (nonatomic, readonly, strong) NSMutableDictionary<NSString *, BCTexture2D *> *textures;

+ (instancetype)sharedResourceManager;

- (BCShader *)loadShaderWithVShaderFile:(NSString *)vShaderFile fShaderFile:(NSString *)fShaderFile shaderName:(NSString *)shaderName;

- (BCTexture2D *)loadTextureWithFile:(NSString *)file useAlpha:(BOOL)useAlpha textureName:(NSString *)textureName;

- (void)destroyResourceManager;

@end
