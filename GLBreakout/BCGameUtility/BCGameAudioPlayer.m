//
//  BCGameAudioPlayer.m
//  GLBreakout
//
//  Created by BrianChen on 2018/8/11.
//  Copyright © 2018 BrianChen. All rights reserved.
//

#import "BCGameAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>

@implementation BCGameAudioPlayer {
    NSMutableDictionary<NSString *, AVAudioPlayer *> *_players;
}

- (instancetype)init {
    if (self = [super init]) {
        _players = [NSMutableDictionary dictionary];
    }
    return self;
}

+ (instancetype)sharedAudioPlayer {
    static BCGameAudioPlayer *sharedPlayer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedPlayer = [[BCGameAudioPlayer alloc] init];
    });
    return sharedPlayer;
}

- (void)playAudio:(NSString *)audioFile isLoop:(BOOL)isLoop {
    AVAudioPlayer *player = _players[audioFile];
    if (!player) {
        NSURL *fileURL = [NSURL URLWithString:audioFile];
        NSError *error = nil;
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&error];
        if (error) {
            NSLog(@"Open audio player error. %@", error.localizedDescription);
            return;
        }
        _players[audioFile] = player;
    }
    if (isLoop) {
        player.numberOfLoops = -1;
    }
    [player play];
}

- (void)stop {
    [_players enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, AVAudioPlayer * _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj.isPlaying) {
            [obj stop];
        }
    }];
}

@end
