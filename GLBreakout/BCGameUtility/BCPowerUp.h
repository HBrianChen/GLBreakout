//
//  BCPowerUp.h
//  GLBreakout
//
//  Created by BrianChen on 2018/8/11.
//  Copyright © 2018 BrianChen. All rights reserved.
//

#import "BCGameObject.h"

typedef NS_ENUM(NSUInteger, BCPowerUpType) {
    BCPowerUpSpeed,
    BCPowerUpSticky,
    BCPowerUpPassThrough,
    BCPowerUpPadSizeInc,
    BCPowerUpConfuse,
    BCPowerUpChaos,
};

@interface BCPowerUp : BCGameObject

@property (nonatomic, readwrite, assign) BCPowerUpType type;
@property (nonatomic, readwrite, assign) float duration;
@property (nonatomic, readwrite, assign) BOOL isActivated;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithType:(BCPowerUpType)type color:(GLKVector3)color duration:(float)duration position:(GLKVector2)position texture:(BCTexture2D *)texture;

@end
