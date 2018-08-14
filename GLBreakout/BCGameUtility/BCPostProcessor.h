//
//  BCPostProcessor.h
//  GLBreakout
//
//  Created by BrianChen on 2018/8/8.
//  Copyright © 2018 BrianChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BCShader;

@interface BCPostProcessor : NSObject

@property (nonatomic, readwrite, assign) CGSize size;
@property (nonatomic, readwrite, assign) BOOL enableConfuse;
@property (nonatomic, readwrite, assign) BOOL enableChaos;
@property (nonatomic, readwrite, assign) BOOL enableShake;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithShader:(BCShader *)shader size:(CGSize)size;

- (void)beginRender;
- (void)endRender;

- (void)render:(float)time;
- (void)destroyPostProcessor;

@end
