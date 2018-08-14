//
//  BCGame.h
//  GLBreakout
//
//  Created by BrianChen on 2018/7/25.
//  Copyright © 2018 BrianChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@class BCGameLevel;

typedef NS_ENUM(NSUInteger, BCGameState) {
    BCGame_ACTIVE,
    BCGame_MENU,
    BCGame_WIN,
};

typedef NS_ENUM(NSUInteger, BCDirection) {
    BCDirectionUp,
    BCDirectionDown,
    BCDirectionLeft,
    BCDirectionRight,
};

typedef NS_ENUM(NSUInteger, BCKey) {
    BCKeyA,
    BCKeyD,
    BCKeyW,
    BCKeyS,
    BCKeyEnter,
    BCKeyEsc,
    BCKeySpace,
    BCKeyCount,
};

typedef struct {
    BOOL isCollision;
    BCDirection dir;
    GLKVector2 diffVector;
} BCCollision;

@interface BCGame : NSObject

@property (nonatomic, readwrite, assign) BCGameState state;
@property (nonatomic, readwrite, assign) BOOL *keys;
@property (nonatomic, readwrite, assign) BOOL *keysProcessed;
@property (nonatomic, readwrite, assign) NSUInteger width;
@property (nonatomic, readwrite, assign) NSUInteger height;
@property (nonatomic, readwrite, strong) NSArray<BCGameLevel *> *levels;
@property (nonatomic, readwrite, assign) NSUInteger level;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithWidth:(NSUInteger)width height:(NSUInteger)height;
- (void)setupGame;
- (void)processInput:(CGFloat)dt;
- (void)update:(CGFloat)dt;
- (void)render;

- (void)destroyGame;

@end
