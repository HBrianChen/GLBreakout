//
//  BCPowerUp.m
//  GLBreakout
//
//  Created by BrianChen on 2018/8/11.
//  Copyright © 2018 BrianChen. All rights reserved.
//

#import "BCPowerUp.h"

@implementation BCPowerUp

- (instancetype)initWithType:(BCPowerUpType)type color:(GLKVector3)color duration:(float)duration position:(GLKVector2)position texture:(BCTexture2D *)texture {
    if (self = [super initWithPosition:position size:GLKVector2Make(60, 20) texture:texture color:color velocity:GLKVector2Make(0.0f, 150.0f)]) {
        _type = type;
        _duration = duration;
        _isActivated = NO;
    }
    return self;
}

@end
