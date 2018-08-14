//
//  BCBallObject.h
//  GLBreakout
//
//  Created by BrianChen on 2018/8/3.
//  Copyright © 2018 BrianChen. All rights reserved.
//

#import "BCGameObject.h"

@interface BCBallObject : BCGameObject

@property (nonatomic, readwrite, assign) BOOL isStuck;
@property (nonatomic, readwrite, assign) float radius;
@property (nonatomic, readwrite, assign) BOOL sticky;
@property (nonatomic, readwrite, assign) BOOL passThrough;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithPosition:(GLKVector2)pos texture:(BCTexture2D *)texture radius:(float)radius velocity:(GLKVector2)velocity;

- (void)moveWithDT:(float)dt windowWidth:(NSUInteger)width;

- (void)resetWithPosition:(GLKVector2)pos velocity:(GLKVector2)velocity;

@end
