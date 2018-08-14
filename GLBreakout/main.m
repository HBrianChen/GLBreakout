//
//  main.m
//  GLBreakout
//
//  Created by BrianChen on 2018/7/25.
//  Copyright © 2018 BrianChen. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"


int main(int argc, const char * argv[]) {
    AppDelegate  *appDelegate = [[AppDelegate alloc] init];
    [NSApplication sharedApplication].delegate = appDelegate;
    return NSApplicationMain(argc, argv);
}
