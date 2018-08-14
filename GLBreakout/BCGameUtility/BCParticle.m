//
//  BCParticle.m
//  GLBreakout
//
//  Created by BrianChen on 2018/8/4.
//  Copyright © 2018 BrianChen. All rights reserved.
//

#import "BCParticle.h"

@implementation BCParticle

- (instancetype)init {
    if (self = [super init]) {
        _position = GLKVector2Make(0, 0);
        _velocity = GLKVector2Make(0, 0);
        _color = GLKVector4Make(1.0, 1.0, 1.0, 1.0);
        _life = 0;
    }
    return self;
}

@end
