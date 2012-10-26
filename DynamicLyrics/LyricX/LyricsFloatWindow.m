//
//  FloatPanel.m
//  LyricX
//
//  Created by Martian on 12-4-3.
//  Copyright (c) 2012年 Martian. All rights reserved.
//

#import "LyricsFloatWindow.h"
#import "Constants.h"
@implementation LyricsFloatWindow

- (id)initWithContentRect:(NSRect)contentRect
{
    self = [super initWithContentRect:contentRect styleMask:(NSBorderlessWindowMask | NSNonactivatingPanelMask) backing:NSBackingStoreBuffered defer:YES];
    if (self) {
        //self.backgroundColor = [NSColor colorWithCalibratedWhite:0 alpha:0.3];
        self.backgroundColor = NSColor.clearColor;
        self.level = NSFloatingWindowLevel; //CGShieldingWindowLevel();
        self.opaque = NO;
        self.hasShadow = NO;
        self.hidesOnDeactivate = NO;
        self.IgnoresMouseEvents = YES;
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@Pref_Attach_LyricsWindow_To_All_Spaces]) {
            [self setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces];
        }
        lyricsView = [[LyricsView alloc] initWithFrame:NSScreen.mainScreen.frame];
        [self.contentView addSubview:lyricsView];
        //[self center];
                 
    }
    return self;
}




@end
