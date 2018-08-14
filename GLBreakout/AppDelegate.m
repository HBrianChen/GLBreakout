//
//  AppDelegate.m
//  GLBreakout
//
//  Created by BrianChen on 2018/7/25.
//  Copyright © 2018 BrianChen. All rights reserved.
//

#import "AppDelegate.h"
#import "BCViewController.h"

static CGFloat WindowX = 200.f;
static CGFloat WindowY = 200.f;
static CGFloat WindowW = 800.f;
static CGFloat WindowH = 600.f;

@interface AppDelegate () {
    NSWindow *_mainWindow;
    BCViewController *_viewController;
}

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillClose) name:NSWindowWillCloseNotification object:nil];
    
    NSRect windowRect = NSMakeRect(WindowX, WindowY, WindowW, WindowH);
    NSRect viewRect = NSMakeRect(0, 0, WindowW, WindowH);
    
    _mainWindow = [[NSWindow alloc] initWithContentRect:windowRect styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable
                                                backing:NSBackingStoreBuffered defer:NO];
    [_mainWindow setTitle:@"Breakout"];
    _mainWindow.collectionBehavior |= NSWindowCollectionBehaviorFullScreenNone;
    
    _viewController = [[BCViewController alloc] initWithFrame:viewRect];
    [_mainWindow.contentView addSubview:_viewController.view];
    
    _mainWindow.contentView.autoresizesSubviews = YES;
    _viewController.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    
    [_mainWindow makeKeyAndOrderFront:nil];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)windowWillClose {
    [NSApplication.sharedApplication terminate:nil];
}

@end
