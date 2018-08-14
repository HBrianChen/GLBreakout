//
//  BCCharacter.m
//  GLBreakout
//
//  Created by BrianChen on 2018/8/13.
//  Copyright © 2018 BrianChen. All rights reserved.
//

#import "BCCharacter.h"

@implementation BCCharacter

- (instancetype)init {
    if (self = [super init]) {
        _textureID = 0;
        _size = CGSizeZero;
        _bearing = CGSizeZero;
        _advance = 0;
    }
    return self;
}

@end
