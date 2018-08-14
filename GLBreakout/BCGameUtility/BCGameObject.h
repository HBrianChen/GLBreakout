//
//  BCGameObject.h
//  GLBreakout
//
//  Created by BrianChen on 2018/8/3.
//  Copyright © 2018 BrianChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import <OpenGL/gl3.h>

@class BCTexture2D;
@class BCSpriteRenderer;

@interface BCGameObject : NSObject

@property (nonatomic, assign) GLKVector2 position;
@property (nonatomic, assign) GLKVector2 size;
@property (nonatomic, assign) GLKVector2 velocity;

@property (nonatomic, assign) GLKVector3 color;
@property (nonatomic, assign) GLfloat rotation;
@property (nonatomic, assign) GLboolean isSolid;
@property (nonatomic, assign) GLboolean destroyed;

@property (nonatomic, strong) BCTexture2D *sprite;

- (instancetype)initWithPosition:(GLKVector2)pos size:(GLKVector2)size texture:(BCTexture2D *)texture;
- (instancetype)initWithPosition:(GLKVector2)pos size:(GLKVector2)size texture:(BCTexture2D *)texture color:(GLKVector3)color velocity:(GLKVector2)velocity;

- (void)draw:(BCSpriteRenderer *)renderer;

@end
