//
//  BCParticleGenerator.h
//  GLBreakout
//
//  Created by BrianChen on 2018/8/4.
//  Copyright © 2018 BrianChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BCParticle.h"

@class BCShader;
@class BCTexture2D;
@class BCGameObject;

@interface BCParticleGenerator : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithShader:(BCShader *)shader texture:(BCTexture2D *)texture amount:(NSUInteger)amount;

- (void)updateWithDT:(float)dt object:(BCGameObject *)object newParticles:(NSUInteger)newParticles offset:(GLKVector2)offset;

- (void)draw;
- (void)destroyParticleGenerator;

@end
