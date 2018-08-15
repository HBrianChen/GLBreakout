//
//  BCGLView.m
//  GLBreakout
//
//  Created by BrianChen on 2018/7/25.
//  Copyright © 2018 BrianChen. All rights reserved.
//

#import "BCGLView.h"
#import <OpenGL/gl3.h>
#import "BCGame.h"

@interface BCGLView () {
    BCGame *_game;
    CGFloat _deltaTime;
    CGFloat _lastFrame;
    BOOL _keys[BCKeyCount];
    BOOL _keysProcessed[BCKeyCount];
    CVDisplayLinkRef _displayLink; //display link for managing rendering thread
}

@end

@implementation BCGLView

- (instancetype)init {
    return [self initWithFrame:NSZeroRect];
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    NSOpenGLPixelFormatAttribute attrs[] =
    {
        NSOpenGLPFADoubleBuffer,
        NSOpenGLPFADepthSize, 24,
        // Must specify the 3.2 Core Profile to use OpenGL 3.2
        NSOpenGLPFAOpenGLProfile,
        NSOpenGLProfileVersion3_2Core,
        0
    };
    NSOpenGLPixelFormat *format = [[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];
    _game = [[BCGame alloc] initWithWidth:800 height:600];
    _game.keys = _keys;
    _game.keysProcessed = _keysProcessed;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillClose) name:NSWindowWillCloseNotification object:nil];
    return [self initWithFrame:frameRect pixelFormat:format];
}

- (void)prepareOpenGL {
    [super prepareOpenGL];
    
    NSLog(@"OpenGL version: %s", glGetString(GL_VERSION));
    

    glEnable(GL_CULL_FACE);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    [_game setupGame];
    _deltaTime = 0.0f;
    _lastFrame = CFAbsoluteTimeGetCurrent();
    
    // Synchronize buffer swaps with vertical refresh rate
    GLint swapInt = 1;
    [[self openGLContext] setValues:&swapInt forParameter:NSOpenGLCPSwapInterval];
    
    // Create a display link capable of being used with all active displays
    CVDisplayLinkCreateWithActiveCGDisplays(&_displayLink);
    
    // Set the renderer output callback function
    CVDisplayLinkSetOutputCallback(_displayLink, &DisplayLinkCallback, (__bridge void * _Nullable)(self));
    
    // Set the display link for the current renderer
    CGLContextObj cglContext = [[self openGLContext] CGLContextObj];
    CGLPixelFormatObj cglPixelFormat = [[self pixelFormat] CGLPixelFormatObj];
    CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(_displayLink, cglContext, cglPixelFormat);
    
    // Activate the display link
    CVDisplayLinkStart(_displayLink);
}

#pragma mark -- OpenGL Draw

// This is the renderer output callback function
static CVReturn DisplayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp* now, const CVTimeStamp* outputTime, CVOptionFlags flagsIn, CVOptionFlags* flagsOut, void* displayLinkContext)
{
    CVReturn result = [(__bridge BCGLView *)displayLinkContext getFrameForTime:outputTime];
    return result;
}

- (CVReturn)getFrameForTime:(const CVTimeStamp*)outputTime
{
    // There is no autorelease pool when this method is called
    // because it will be called from a background thread.
    // It's important to create one or app can leak objects.
    @autoreleasepool {
        [self glDraw];
    }
    return kCVReturnSuccess;
}

- (void)glDraw {
    [[self openGLContext] makeCurrentContext];
    
    CGFloat currentFrame = CFAbsoluteTimeGetCurrent();
    _deltaTime = currentFrame - _lastFrame;
    _lastFrame = currentFrame;
    
    //NSLog(@"fps: %f", 1 / _deltaTime);
    
    [_game processInput:_deltaTime];
    [_game update:_deltaTime];
    
    // Drawing code here.
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    [_game render];
    
    CGLFlushDrawable([[self openGLContext] CGLContextObj]);
}

#pragma mark -- Keyboard

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (void)keyUp:(NSEvent *)event {
    //NSLog(@"key up.");
    if ([event.characters isEqualToString:@"a"] || event.keyCode == 123) {
        _keys[BCKeyA] = NO;
        _keysProcessed[BCKeyA] = NO;
    }
    if ([event.characters isEqualToString:@"d"] || event.keyCode == 124) {
        _keys[BCKeyD] = NO;
        _keysProcessed[BCKeyD] = NO;
    }
    if ([event.characters isEqualToString:@"w"] || event.keyCode == 126) {
        _keys[BCKeyW] = NO;
        _keysProcessed[BCKeyW] = NO;
    }
    if ([event.characters isEqualToString:@"s"] || event.keyCode == 125) {
        _keys[BCKeyS] = NO;
        _keysProcessed[BCKeyS] = NO;
    }
    if ([event.characters isEqualToString:@" "]) {
        _keys[BCKeySpace] = NO;
        _keysProcessed[BCKeySpace] = NO;
    }
    if ([event.characters isEqualToString:@"\r"]) {
        _keys[BCKeyEnter] = NO;
        _keysProcessed[BCKeyEnter] = NO;
    }
    [super keyUp:event];
}

- (void)keyDown:(NSEvent *)event {
    //NSLog(@"key down");
    if ([event.characters isEqualToString:@"a"] || event.keyCode == 123) {
        _keys[BCKeyA] = YES;
    }
    if ([event.characters isEqualToString:@"d"] || event.keyCode == 124) {
        _keys[BCKeyD] = YES;
    }
    if ([event.characters isEqualToString:@"w"] || event.keyCode == 126) {
        _keys[BCKeyW] = YES;
    }
    if ([event.characters isEqualToString:@"s"] || event.keyCode == 125) {
        _keys[BCKeyS] = YES;
    }
    if ([event.characters isEqualToString:@" "]) {
        _keys[BCKeySpace] = YES;
    }
    if ([event.characters isEqualToString:@"\r"]) {
        _keys[BCKeyEnter] = YES;
    }
    [super keyDown:event];
}

- (void)cancelOperation:(id)sender {
    if (_game.state == BCGame_WIN) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NSWindowWillCloseNotification object:nil];
    }
}

- (void)windowWillClose {
    CVDisplayLinkStop(_displayLink);
    CVDisplayLinkRelease(_displayLink);
    
    [self.openGLContext makeCurrentContext];
    [_game destroyGame];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"window will close.");
}

@end
