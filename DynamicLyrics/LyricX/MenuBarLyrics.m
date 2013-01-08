//
//  MenuBarLyrics.m
//  LyricX
//
//  Created by Martian on 12-4-3.
//  Copyright (c) 2012年 Martian. All rights reserved.
//

#import "MenuBarLyrics.h"
#import "Constants.h"

@interface NSStatusBar (NSStatusBar_Private)
- (id)_statusItemWithLength:(float)l withPriority:(int)p;
- (id)_insertStatusItem:(NSStatusItem *)i withPriority:(int)p;
@end

@implementation MenuBarLyrics

@synthesize  CurrentSongLyrics;
-(id) initWithMenu:(NSMenu *)AppMenu;
{
    self = [super init];
    if (self) {
        _queue = [[NSOperationQueue alloc] init]; 
        [_queue setMaxConcurrentOperationCount:1];
        NSStatusBar *bar = [NSStatusBar systemStatusBar];
        _statusItem = [[bar _statusItemWithLength:0 withPriority:INT_MIN] retain];
        //[_statusItem setTitle:@"LyricsX!"];
        [bar removeStatusItem:_statusItem];
        [bar _insertStatusItem:_statusItem withPriority:INT_MIN];
        [_statusItem setLength:NSVariableStatusItemLength];
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
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *lyric = [[note userInfo] objectForKey:@"Lyrics"];
	// Change desktop lyrics status. Ignore action
	if ([lyric isEqualToString:@NC_Changed_DesktopLyrics]) {
		[pool release];
		return;
    }
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	BOOL forceUpdate = NO;
	if ([lyric isEqualToString:@NC_Disabled_MenuBarLyrics]) {
		if ([ud boolForKey:@Pref_Enable_MenuBar_Lyrics]) {
			[_queue cancelAllOperations];
			[_statusItem setAttributedTitle:nil];
			[_statusItem setImage:[NSImage imageNamed:@"StatusIcon.png"]];
			
			[pool release];
			return;
			
		}else{
			forceUpdate = YES;
		}
	}else{
		self.CurrentSongLyrics = lyric;
	}

	[_queue cancelAllOperations];
    if ([ud boolForKey:@Pref_Enable_MenuBar_Lyrics] || forceUpdate) {
		if ([self.CurrentSongLyrics isEqualToString:@""]) {
			[_statusItem setAttributedTitle:nil];
			[_statusItem setImage:[NSImage imageNamed:@"StatusIcon.png"]];
		}else{
			[_statusItem setImage:nil];
			NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(showSmoothTitle:) object:self.CurrentSongLyrics];
			[_queue addOperation:operation];
			[operation release];
		}
    } else {
		[_statusItem setAttributedTitle:nil];
		[_statusItem setImage:[NSImage imageNamed:@"StatusIcon.png"]];
    }
    
    [pool release];
}


@end
