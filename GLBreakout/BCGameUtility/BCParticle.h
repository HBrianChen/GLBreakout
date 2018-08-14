//
//  BCParticle.h
//  GLBreakout
//
//  Created by BrianChen on 2018/8/4.
//  Copyright © 2018 BrianChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface BCParticle : NSObject

@property (nonatomic, readwrite, assign) GLKVector2 position;
@property (nonatomic, readwrite, assign) GLKVector2 velocity;
@property (nonatomic, readwrite, assign) GLKVector4 color;
@property (nonatomic, readwrite, assign) float life;

@end
