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
-(bool)_toggleDesktopLyrics:(NSMenuItem*)item{
    CGKeyCode key=kVK_ANSI_X;NSString*kx=@"x";
    CGEventRef kd=CGEventCreateKeyboardEvent(nil,key,true);
    CGEventRef ku=CGEventCreateKeyboardEvent(nil,key,false);
    if(!kd||!ku){
        [_statusItem performSelectorOnMainThread:@selector(setEnabled:) withObject:true waitUntilDone:false];
        if(kd)CFRelease(kd);
        if(ku)CFRelease(ku);
        return false;
    }
    NSString*kv=[item keyEquivalent];
    NSUInteger km=[item keyEquivalentModifierMask];
    [item setKeyEquivalent:kx];
    [item setKeyEquivalentModifierMask:0];
    [NSThread sleepForTimeInterval:0.1];
    CGEventTapLocation loc=kCGHIDEventTap;
    CGEventPost(loc,kd);
    CGEventPost(loc,ku);
    [NSThread sleepForTimeInterval:0.1];
    [item setKeyEquivalent:kv];
    [item setKeyEquivalentModifierMask:km];
    CFRelease(kd);CFRelease(ku);
    [_statusItem performSelectorOnMainThread:@selector(setEnabled:) withObject:true waitUntilDone:false];
    return true;
}
-(void)toggleDesktopLyrics:(id)sender{
    NSEvent*event=[NSApp currentEvent];
    if([event type]!=NSRightMouseUp&&!([event modifierFlags]&NSControlKeyMask)){
        [_statusItem setEnabled:false];
        NSMenuItem*item=[self.AppMenu itemWithTag:100];
        [self performSelectorInBackground:@selector(_toggleDesktopLyrics:) withObject:item];
        [_statusItem popUpStatusItemMenu:self.AppMenu];
    }else [_statusItem popUpStatusItemMenu:self.AppMenu];
}
-(void) dealloc
{
    self.CurrentSongLyrics = nil;
    [nc removeObserver:self];
    [_statusItem release];
    [super dealloc];
}
-(bool)isStatusBarWideEnoughToDisplayLyrics{
    // TODO
    return true;
}
-(void) showSmoothTitle:(NSString *)title
{
    NSString*font=@"Bradley Hand";
//    font=@"Comic Sans MS";
    NSMutableDictionary *d = [NSMutableDictionary dictionary];
    [d setObject:[NSFont fontWithName: font size: 15] forKey:NSFontAttributeName];
    [d setObject:[NSNumber numberWithInt: 0] forKey:NSBaselineOffsetAttributeName];
    
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSString *style = [[NSUserDefaults standardUserDefaults] stringForKey:@"AppleInterfaceStyle"];
    CGFloat white = (style && [style isEqualToString:@"Dark"]) ? 1 : 0;
    {
        NSAttributedString *shadowTitle = [[NSAttributedString alloc] initWithString:title attributes:d];
        [_statusItem setAttributedTitle:shadowTitle];
        if(![self isStatusBarWideEnoughToDisplayLyrics])
            title=@"…";
    }
    
    
    for (float alpha = 0.3; alpha < 1.01; alpha+=0.02)
    {
        
        NSColor *color = [NSColor colorWithCalibratedWhite:white alpha:alpha];
        [d setObject:color forKey:NSForegroundColorAttributeName];
        
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
