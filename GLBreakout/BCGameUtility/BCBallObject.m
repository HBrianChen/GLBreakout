//
//  BCBallObject.m
//  GLBreakout
//
//  Created by BrianChen on 2018/8/3.
//  Copyright © 2018 BrianChen. All rights reserved.
//

#import "BCBallObject.h"

@implementation BCBallObject

- (instancetype)initWithPosition:(GLKVector2)pos texture:(BCTexture2D *)texture radius:(float)radius velocity:(GLKVector2)velocity {
    if (self = [super initWithPosition:pos size:GLKVector2Make(radius * 2, radius * 2) texture:texture]) {
        self.velocity = velocity;
        _radius = radius;
        _isStuck = YES;
        _sticky = NO;
        _passThrough = NO;
    }
    return self;
}

- (void)moveWithDT:(float)dt windowWidth:(NSUInteger)width {
    if (!_isStuck) {
        self.position = GLKVector2Add(self.position, GLKVector2MultiplyScalar(self.velocity, dt));
        if (self.position.x <= 0.0f) {
            self.velocity = GLKVector2Make(-self.velocity.x, self.velocity.y);
            self.position = GLKVector2Make(0.0f, self.position.y);
        } else if (self.position.x + self.size.x >= width) {
            self.velocity = GLKVector2Make(-self.velocity.x, self.velocity.y);
            self.position = GLKVector2Make(width - self.size.x, self.position.y);
        }
        if (self.position.y <= 0.0f) {
            self.velocity = GLKVector2Make(self.velocity.x, -self.velocity.y);
            self.position = GLKVector2Make(self.position.x, 0.0f);
        }
    }
}

- (void)resetWithPosition:(GLKVector2)pos velocity:(GLKVector2)velocity {
    self.position = pos;
    self.velocity = velocity;
    _isStuck = YES;
    _sticky = NO;
    _passThrough = NO;
}

@end
