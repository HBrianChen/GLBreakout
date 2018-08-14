//
//  BCSpriteRenderer.h
//  GLBreakout
//
//  Created by BrianChen on 2018/8/2.
//  Copyright © 2018 BrianChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@class BCShader;
@class BCTexture2D;

@interface BCSpriteRenderer : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithShader:(BCShader *)shader;

- (void)drawSpriteWithTexture:(BCTexture2D *)texture position:(GLKVector2)position;
- (void)drawSpriteWithTexture:(BCTexture2D *)texture position:(GLKVector2)position size:(GLKVector2)size rotate:(GLfloat)rotate color:(GLKVector3)color;

- (void)destroyRenderer;
@end
