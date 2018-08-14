//
//  BCGameAudioPlayer.h
//  GLBreakout
//
//  Created by BrianChen on 2018/8/11.
//  Copyright © 2018 BrianChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BCGameAudioPlayer : NSObject

+ (instancetype)sharedAudioPlayer;
- (void)playAudio:(NSString *)audioFile isLoop:(BOOL)isLoop;
- (void)stop;

@end
