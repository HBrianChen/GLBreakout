//
//  BCShader.h
//  GLBreakout
//
//  Created by BrianChen on 2018/7/13.
//  Copyright © 2018 BrianChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface BCShader : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithVertexShader:(NSString *)vertexShaderPath fragmentShader:(NSString *)fragmentShaderPath;
- (void)use;
- (void)setFloat:(NSString *)name value:(CGFloat)value;
- (void)setInteger:(NSString *)name value:(NSInteger)value;
- (void)setVector2f:(NSString *)name vec2f:(GLKVector2)vec2f;
- (void)setVector3f:(NSString *)name vec3f:(GLKVector3)vec3f;
- (void)setVector4f:(NSString *)name vec4f:(GLKVector4)vec4f;
- (void)setMatrix4:(NSString *)name matrix4:(GLKMatrix4)matrix4;

- (unsigned int)shaderID;
- (void)destroyShader;
@end
