//
//  BCCharacter.h
//  GLBreakout
//
//  Created by BrianChen on 2018/8/13.
//  Copyright © 2018 BrianChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BCCharacter : NSObject

@property (nonatomic, readwrite, assign) unsigned int textureID;
@property (nonatomic, readwrite, assign) CGSize size;
@property (nonatomic, readwrite, assign) CGSize bearing;
@property (nonatomic, readwrite, assign) unsigned int advance;

@end
