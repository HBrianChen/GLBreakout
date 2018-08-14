//
//  BCGameLevel.m
//  GLBreakout
//
//  Created by BrianChen on 2018/8/3.
//  Copyright © 2018 BrianChen. All rights reserved.
//

#import "BCGameLevel.h"
#import "BCGameObject.h"
#import "BCSpriteRenderer.h"
#import "BCResourceManager.h"

@interface BCGameLevel () {
    NSMutableArray<BCGameObject *> *_bricks;
    BCResourceManager *_manager;
}

@end

@implementation BCGameLevel

- (instancetype)init {
    if (self = [super init]) {
        _bricks = [NSMutableArray array];
        _manager = [BCResourceManager sharedResourceManager];
    }
    return self;
}

- (void)loadFromFile:(NSString *)file levelWidth:(NSUInteger)levelWidth levelHeight:(NSUInteger)levelHeight {
    [_bricks removeAllObjects];
    NSError *error = nil;
    NSString *fileStr = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"Read level file failed! error: %@", error.localizedDescription);
        return;
    }
    
    NSString *lastChar = [fileStr substringFromIndex:fileStr.length-1];
    if ([lastChar isEqualToString:@"\n"]) {
        fileStr = [fileStr substringToIndex:fileStr.length-1];
    }
    
    NSArray<NSString *> *lines = [fileStr componentsSeparatedByString:@"\n"];
    NSMutableArray<NSMutableArray *> *datas = [NSMutableArray array];
    for (NSString *line in lines) {
        NSArray<NSString *> *numbers = [line componentsSeparatedByString:@" "];
        NSMutableArray<NSNumber *> *data = [NSMutableArray array];
        for (NSString *number in numbers) {
            NSInteger num = number.integerValue;
            [data addObject:@(num)];
        }
        [datas addObject:data];
    }
    
    NSUInteger rows = datas.count;
    NSUInteger cols = datas[0].count;
    NSLog(@"load game level file: %@", file.lastPathComponent);
    NSLog(@"rows: %lu cols: %lu", rows, cols);
    
    float unitWidth = levelWidth / (float)cols;
    float unitHeight = levelHeight / (float)rows;
    
    NSUInteger row = 0;
    for (NSMutableArray *data in datas) {
        NSUInteger col = 0;
        for (NSNumber *number in data) {
            GLKVector2 pos = GLKVector2Make(unitWidth * col, unitHeight * row);
            GLKVector2 size = GLKVector2Make(unitWidth, unitHeight);
            NSInteger tileData = number.integerValue;
            if (tileData == 1) {
                BCGameObject *obj = [[BCGameObject alloc] initWithPosition:pos size:size texture:_manager.textures[@"block_solid"]];
                obj.color = GLKVector3Make(0.8f, 0.8f, 0.7f);
                obj.isSolid = GL_TRUE;
                [_bricks addObject:obj];
            } else if (tileData > 1) {
                GLKVector3 color = GLKVector3Make(1.0f, 1.0f, 1.0f);
                if (number.integerValue == 2) {
                    color = GLKVector3Make(0.2f, 0.6f, 1.0f);
                } else if (tileData == 3) {
                    color = GLKVector3Make(0.0f, 0.7f, 0.0f);
                } else if (tileData == 4) {
                    color = GLKVector3Make(0.8f, 0.8f, 0.4f);
                } else if (tileData == 5) {
                    color = GLKVector3Make(1.0f, 0.5f, 0.0f);
                }
                BCGameObject *obj = [[BCGameObject alloc] initWithPosition:pos size:size texture:_manager.textures[@"block"]];
                obj.color = color;
                [_bricks addObject:obj];
            }
            col++;
        }
        row++;
    }
    NSLog(@"bricks count: %lu", _bricks.count);
}

- (void)draw:(BCSpriteRenderer *)renderer {
    for (BCGameObject *brick in _bricks) {
        if (!brick.destroyed) {
            [brick draw:renderer];
        }
    }
}

- (BOOL)isCompleted {
    for (BCGameObject *brick in _bricks) {
        if (!brick.isSolid && !brick.destroyed) {
            return NO;
        }
    }
    return YES;
}

@end
