//
//  BCTextRenderer.h
//  GLBreakout
//
//  Created by BrianChen on 2018/8/13.
//  Copyright © 2018 BrianChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@class BCCharacter;
@class BCShader;

@interface BCTextRenderer : NSObject

@property (nonatomic, readwrite, strong) NSMutableDictionary<NSString *, BCCharacter *> *characters;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithShader:(BCShader *)shader;

- (void)loadFont:(NSString *)fontFile fontSize:(NSUInteger)fontSize;
- (void)renderText:(NSString *)text x:(float)x y:(float)y scale:(float)scale;
- (void)renderText:(NSString *)text x:(float)x y:(float)y scale:(float)scale color:(GLKVector3)color;

- (void)destroyTextRenderer;

@end
