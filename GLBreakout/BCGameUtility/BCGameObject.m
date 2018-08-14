//
//  BCGameObject.m
//  GLBreakout
//
//  Created by BrianChen on 2018/8/3.
//  Copyright © 2018 BrianChen. All rights reserved.
//

#import "BCGameObject.h"
#import "BCTexture2D.h"
#import "BCSpriteRenderer.h"

@implementation BCGameObject

- (instancetype)init {
    return [self initWithPosition:GLKVector2Make(0.0f, 0.0f) size:GLKVector2Make(1, 1) texture:nil];
}

- (instancetype)initWithPosition:(GLKVector2)pos size:(GLKVector2)size texture:(BCTexture2D *)texture {
    return [self initWithPosition:pos size:size texture:texture color:GLKVector3Make(1.0f, 1.0f, 1.0f) velocity:GLKVector2Make(0.0, 0.0)];
}

- (instancetype)initWithPosition:(GLKVector2)pos size:(GLKVector2)size texture:(BCTexture2D *)texture color:(GLKVector3)color velocity:(GLKVector2)velocity {
    if (self = [super init]) {
        _position = pos;
        _size = size;
        _sprite = texture;
        _color = color;
        _velocity = velocity;
        _rotation = 0.0f;
        _isSolid = NO;
        _destroyed = NO;
    }
    return self;
}

- (void)draw:(BCSpriteRenderer *)renderer {
    [renderer drawSpriteWithTexture:_sprite position:_position size:_size rotate:_rotation color:_color];
}

@end
