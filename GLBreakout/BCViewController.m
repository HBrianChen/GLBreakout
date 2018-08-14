//
//  BCViewController.m
//  GLBreakout
//
//  Created by BrianChen on 2018/7/25.
//  Copyright © 2018 BrianChen. All rights reserved.
//

#import "BCViewController.h"
#import "BCGLView.h"

@interface BCViewController () {
    NSRect _frameRect;
}

@end

@implementation BCViewController

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithNibName:nil bundle:nil]) {
        _frameRect = frameRect;
        BCGLView *glView = [[BCGLView alloc] initWithFrame:_frameRect];
        self.view = glView;
    }
    return self;
}

- (void)loadView {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
