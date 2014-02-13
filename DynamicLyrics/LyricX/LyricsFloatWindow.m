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
        [self setContentView:lyricsView];
        [self setSharingType:NSWindowSharingNone];
        
        nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(hideLyricsWindow:) name:@NC_Hide_DesktopLyrics object:nil];
        [nc addObserver:self selector:@selector(showLyricsWindow:) name:@NC_Show_DesktopLyrics object:nil];

    }
    return self;
}

-(void)hideLyricsWindow:(NSNotification *)note
{
    NSLog(@"HIDE");
    [self orderOut:self];
}

-(void)showLyricsWindow:(NSNotification *)note
{
    NSLog(@"SHOW");
    [self orderBack:self];
}

@end
