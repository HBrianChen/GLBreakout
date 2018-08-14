//
//  BCTexture2D.h
//  GLBreakout
//
//  Created by BrianChen on 2018/7/25.
//  Copyright © 2018 BrianChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BCTexture2D : NSObject

@property (nonatomic, readwrite, assign) NSUInteger internalFormat;
@property (nonatomic, readwrite, assign) NSUInteger imageFormat;
@property (nonatomic, readwrite, assign) NSInteger wrapS;
@property (nonatomic, readwrite, assign) NSInteger wrapT;
@property (nonatomic, readwrite, assign) NSInteger filterMin;
@property (nonatomic, readwrite, assign) NSInteger filterMax;

- (void)generateWithData:(void *)data width:(NSUInteger)width height:(NSUInteger)height;

- (void)bind;

- (unsigned int)texID;
- (void)destroyTexture;

@end
