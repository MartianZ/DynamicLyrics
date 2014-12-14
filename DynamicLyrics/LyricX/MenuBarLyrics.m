//
//  MenuBarLyrics.m
//  LyricX
//
//  Created by Martian on 12-4-3.
//  Copyright (c) 2012年 Martian. All rights reserved.
//

#import "MenuBarLyrics.h"
#import "LyricXAppDelegate.h"
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
        _statusItem = [[bar _statusItemWithLength:0 withPriority:0] retain];
        //[_statusItem setTitle:@"LyricsX!"];
        [bar removeStatusItem:_statusItem];
        [bar _insertStatusItem:_statusItem withPriority:0];
        [_statusItem setLength:NSVariableStatusItemLength];
        NSImage *image = [NSImage imageNamed:@"StatusIcon"];
        [image setTemplate:YES];
        [_statusItem setImage:image];
        [_statusItem setHighlightMode:YES];
        self.AppMenu=AppMenu;
        [_statusItem setTarget:self];
        [_statusItem setAction:@selector(toggleDesktopLyrics:)];
        [_statusItem sendActionOn:NSLeftMouseUpMask|NSRightMouseUpMask];
        nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(iTunesLyricsChanged:) name:@NC_LyricsChanged object:nil];
        [nc addObserver:self selector:@selector(iTunesPaused:) name:@"iTunesPaused" object:nil];
        
        NSLog(@"%@",@"MenuBarLyrics");

    }
    return self;
}
-(void)toggleDesktopLyrics:(id)sender{
    NSEvent*event=[NSApp currentEvent];
    if([event type]!=NSRightMouseUp&&!([event modifierFlags]&NSControlKeyMask)){
        NSUserDefaults*df=[NSUserDefaults standardUserDefaults];
        bool edl=[[df valueForKey:@Pref_Enable_Desktop_Lyrics]boolValue];
        [df setBool:!edl forKey:@Pref_Enable_Desktop_Lyrics];
        // FIXME refreshing problems, response is delayed
        // this is main thread, no need for performSelectorOnMainThread
        [(AppDelegate*)[NSApp delegate]DisabledDesktopLyrics:self];
        [self showSmoothTitle:@"PleaseWait…"];
        // fuck [NSEvent keyEventWithType:<#(NSEventType)#> location:<#(NSPoint)#> modifierFlags:<#(NSEventModifierFlags)#> timestamp:<#(NSTimeInterval)#> windowNumber:<#(NSInteger)#> context:<#(NSGraphicsContext *)#> characters:<#(NSString *)#> charactersIgnoringModifiers:<#(NSString *)#> isARepeat:<#(BOOL)#> keyCode:<#(unsigned short)#>]
        // are apple's engineers all have shit in there brain!?
    }else [_statusItem popUpStatusItemMenu:self.AppMenu];
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
    NSString *style = [[NSUserDefaults standardUserDefaults] stringForKey:@"AppleInterfaceStyle"];
    CGFloat white = (style && [style isEqualToString:@"Dark"]) ? 1 : 0;
    
    for (float alpha = 0.3; alpha < 1.01; alpha+=0.02)
    {
        
        NSColor *color = [NSColor colorWithCalibratedWhite:white alpha:alpha];
        NSMutableDictionary *d = [NSMutableDictionary dictionary];
        [d setObject:color forKey:NSForegroundColorAttributeName];
        [d setObject:[NSFont fontWithName: @"Lucida Grande" size: 15] forKey:NSFontAttributeName];
        
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
    
    NSString *style = [[NSUserDefaults standardUserDefaults] stringForKey:@"AppleInterfaceStyle"];
    CGFloat white = (style && [style isEqualToString:@"Dark"]) ? 1 : 0;

    for (float alpha = 0.7; alpha > 0; alpha-=0.02)
    {
        NSColor *color = [NSColor colorWithCalibratedWhite:white alpha:alpha];
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
-(void)iTunesPaused:(NSNotification*)notification{
    bool pausing=[[[notification userInfo]valueForKey:@"isPausing"]boolValue];
    NSLog(@"%s",pausing?"Paused":"Playing");
    [_statusItem setAttributedTitle:nil];
    [_statusItem setImage:[NSImage imageNamed:@"StatusIcon"]];
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
			[_statusItem setImage:[NSImage imageNamed:@"StatusIcon"]];
			
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
//        NSString*trimmed=[self.CurrentSongLyrics stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString*trimmed=self.CurrentSongLyrics;
		if ([trimmed isEqualToString:@""]){
			[_statusItem setAttributedTitle:nil];
			[_statusItem setImage:[NSImage imageNamed:@"StatusIcon"]];
		}else{
			[_statusItem setImage:nil];
			NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(showSmoothTitle:) object:self.CurrentSongLyrics];
			[_queue addOperation:operation];
			[operation release];
		}
    } else {
		[_statusItem setAttributedTitle:nil];
		[_statusItem setImage:[NSImage imageNamed:@"StatusIcon"]];
    }
    
    [pool release];
}


@end
