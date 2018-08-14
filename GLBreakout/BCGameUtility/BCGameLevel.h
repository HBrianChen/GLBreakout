//
//  BCGameLevel.h
//  GLBreakout
//
//  Created by BrianChen on 2018/8/3.
//  Copyright © 2018 BrianChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BCGameObject;
@class BCSpriteRenderer;

@interface BCGameLevel : NSObject

@property (nonatomic, readonly, strong) NSArray<BCGameObject *> *bricks;

- (void)loadFromFile:(NSString *)file levelWidth:(NSUInteger)levelWidth levelHeight:(NSUInteger)levelHeight;

- (void)draw:(BCSpriteRenderer *)renderer;

- (BOOL)isCompleted;

@end
