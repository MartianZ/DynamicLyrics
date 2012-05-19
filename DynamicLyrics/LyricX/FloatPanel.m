//
//  FloatPanel.m
//  LyricX
//
//  Created by Martian on 12-4-3.
//  Copyright (c) 2012年 Martian. All rights reserved.
//

#import "FloatPanel.h"

@implementation FloatPanel

- (id)initWithContentRect:(NSRect)contentRect
{
    self = [super initWithContentRect:contentRect styleMask:(NSBorderlessWindowMask | NSNonactivatingPanelMask) backing:NSBackingStoreBuffered defer:YES];
    if (self) {
        //self.backgroundColor = [NSColor colorWithCalibratedWhite:0 alpha:0.3];
        self.backgroundColor = NSColor.clearColor;
        self.level = NSDockWindowLevel; //CGShieldingWindowLevel();
        self.opaque = NO;
        self.hasShadow = NO;
        self.hidesOnDeactivate = NO;
        self.IgnoresMouseEvents = YES;
        //[self center];
        
    }
    return self;
}

@end
