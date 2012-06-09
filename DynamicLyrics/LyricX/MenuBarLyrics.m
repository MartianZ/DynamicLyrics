//
//  MenuBarLyrics.m
//  LyricX
//
//  Created by Martian on 12-4-3.
//  Copyright (c) 2012年 Martian. All rights reserved.
//

#import "MenuBarLyrics.h"
#import "Constants.h"
@implementation MenuBarLyrics

@synthesize CurrentSongLyrics;

-(id) initWithMenu:(NSMenu *)AppMenu;
{
    self = [super init];
    if (self) {
        _queue = [[NSOperationQueue alloc] init]; 
        [_queue setMaxConcurrentOperationCount:1];
        _statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
        //[_statusItem setTitle:@"LyricsX!"];
        [_statusItem setImage:[NSImage imageNamed:@"StatusIcon.png"]];
        [_statusItem setHighlightMode:YES];
        [_statusItem setMenu:AppMenu];
        nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(iTunesLyricsChanged:) name:@NC_LyricsChanged object:nil];
        
        NSLog(@"%@",@"MenuBarLyrics");

    }
    return self;
}

-(void) dealloc
{
    self.CurrentSongLyrics = nil;
    [nc removeObserver:self];
    [_statusItem release];
    [super dealloc];
}

-(void) showSmoothTitle:(NSString *)title
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    for (float alpha = 0.3; alpha < 1.01; alpha+=0.02)
    {
        NSColor *color = [NSColor colorWithCalibratedWhite:0 alpha:alpha];
        
        NSMutableDictionary *d = [NSMutableDictionary dictionary];
        [d setObject:color forKey:NSForegroundColorAttributeName];
        [d setObject:[NSFont fontWithName: @"Helvetica" size: 15] forKey:NSFontAttributeName];
        
        NSAttributedString *shadowTitle = [[NSAttributedString alloc] initWithString:title attributes:d];
        
        [_statusItem setAttributedTitle:shadowTitle];
        
        usleep(5000);
        [shadowTitle release];
    }
    [pool release];
}


-(void) hideSmoothTitle:(NSDictionary *)dict
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSNumber *sleepTime = [dict objectForKey:@"Time"];
    long sT = ([sleepTime longValue] - 800)*1000;
    if (sT < 0) return;
    usleep((unsigned int)sT);
    for (float alpha = 0.7; alpha > 0; alpha-=0.02)
    {
        NSColor *color = [NSColor colorWithCalibratedWhite:0 alpha:alpha];
        NSMutableDictionary *d = [NSMutableDictionary dictionary];
        [d setObject:color forKey:NSForegroundColorAttributeName];
        [d setObject:[NSFont fontWithName: @"Helvetica" size: 15] forKey:NSFontAttributeName];
        
        NSAttributedString *shadowTitle = [[NSAttributedString alloc] initWithString:[dict objectForKey:@"Title"] attributes:d];
        
        [_statusItem setAttributedTitle:shadowTitle];
        usleep(5000);
        [shadowTitle release];
    }
    [_statusItem setTitle:@""];
    [pool release];
}


-(void)iTunesLyricsChanged:(NSNotification *)note
{
    if ([[[note userInfo] objectForKey:@"Lyrics"] isEqualToString:@NC_Changed_DesktopLyrics]) {
        return;
    }
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];

    
    if (![ud boolForKey:@Pref_Enable_MenuBar_Lyrics]) {
        [_statusItem setAttributedTitle:nil];
        [_statusItem setImage:[NSImage imageNamed:@"StatusIcon.png"]];
        return;
    } else {
        [_statusItem setImage:nil];
    }
    

    if ([[[note userInfo] objectForKey:@"Lyrics"] isEqualToString:@NC_Disabled_MenuBarLyrics]) {
        if (![ud boolForKey:@Pref_Enable_MenuBar_Lyrics]) {
            [_statusItem setAttributedTitle:nil];
            [_statusItem setImage:[NSImage imageNamed:@"StatusIcon.png"]];
            
        } 
        return;
    }
    
    
    
    self.CurrentSongLyrics = [[note userInfo] objectForKey:@"Lyrics"];
    NSInvocationOperation *operation = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(showSmoothTitle:) object:self.CurrentSongLyrics];
    
    
    [_queue cancelAllOperations];
    [_queue addOperation:operation];
    [operation release];
    [pool release];
}


@end
