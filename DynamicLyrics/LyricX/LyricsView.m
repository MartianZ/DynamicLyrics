//
//  PanelView.m
//  LyricX
//
//  Created by Martian on 12-4-3.
//  Copyright (c) 2012年 Martian. All rights reserved.
//

#import "LyricsView.h"
#import "Constants.h"
#import "iTunes.h"

@interface LyricsView ()

@property(copy, nonatomic)NSString *currentLyrics;

@end

@implementation LyricsView

@synthesize currentLyrics=_currentLyrics;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(iTunesLyricsChanged:) name:@"LyricsChanged" object:nil];

        
        rootLayer = [[CALayer layer] retain];

        [rootLayer setNeedsDisplayOnBoundsChange:YES];

        [self setLayer:rootLayer];
        [self setWantsLayer:YES];
        
        textLayer = [[CATextLayer layer] retain];
        rectangleLayer = [[CAGradientLayer layer] retain];
        messageRectangleLayer = [[CAGradientLayer layer] retain];
        messageAlbumLayer = [[CALayer layer] retain];
        messageTextLayer = [[CATextLayer layer] retain];
        [rootLayer addSublayer:rectangleLayer];
        [rootLayer addSublayer:textLayer];
        [rootLayer addSublayer:messageRectangleLayer];

        [messageRectangleLayer addSublayer:messageAlbumLayer];
        [messageRectangleLayer addSublayer:messageTextLayer];
        
        dnc = [NSDistributedNotificationCenter defaultCenter];
        [dnc addObserver:self selector:@selector(iTunesPlayerInfo:) name:@"com.apple.iTunes.playerInfo" object:nil];

                
    }
    return self;
}



static CGColorRef CGColorCreateFromNSColor (CGColorSpaceRef colorSpace, NSColor *color)
{
    NSColor *deviceColor = [color colorUsingColorSpaceName:NSDeviceRGBColorSpace];
    
    CGFloat components[4];
    [deviceColor getRed: &components[0] green: &components[1] blue:
     &components[2] alpha: &components[3]];
    return CGColorCreate (colorSpace, components);
}


-(void)iTunesLyricsChanged:(NSNotification *)note
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *lyrics = [[note userInfo] objectForKey:@"Lyrics"];
    if ([lyrics isEqualToString:@NC_Disabled_MenuBarLyrics]) {
        [pool release];
		return;
    }
    
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	BOOL forceUpdate = NO;
    if ([lyrics isEqualToString:@NC_Changed_DesktopLyrics]) {
        if ([userDefaults boolForKey:@Pref_Enable_Desktop_Lyrics]) {
			// Disable desktop lyrics
			rectangleLayer.frame = CGRectMake(0, 0, 0, 0);
			textLayer.frame=CGRectMake(0, 0, 0, 0);
			[pool release];
			return;
			
		}else{
			// Enable desktop lyrics
			forceUpdate = YES;
		}
    }else{
		self.currentLyrics = lyrics;
	}
    
	if ([userDefaults boolForKey:@Pref_Enable_Desktop_Lyrics] || forceUpdate) {
		rootLayer.opacity = 1;
		
		//First: 绘制圆角矩形
		CGFloat x = [userDefaults floatForKey:@Pref_Lyrics_X];
		x = x <= 0 ? 150 : x;
		CGFloat y = [userDefaults floatForKey:@Pref_Lyrics_Y];
		y = y <=0 ? 100 : y;
		CGFloat w = [userDefaults floatForKey:@Pref_Lyrics_W];
		w = w <=0 ? self.bounds.size.width - (x*2) : w;
		CGFloat h = [userDefaults floatForKey:@Pref_Lyrics_H];
		h = h <=0 ? 100 : h;
		
		NSColor *backColor = [NSColor whiteColor];
		NSData *theDataA=[userDefaults dataForKey:@Pref_Desktop_Background_Color];
		if (theDataA != nil) backColor =(NSColor *)[NSUnarchiver unarchiveObjectWithData:theDataA];
		
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB ();
		CGColorRef cgbackColor = CGColorCreateFromNSColor (colorSpace, backColor);
		
		
		rectangleLayer.colors = [NSArray arrayWithObjects:(id)cgbackColor,(id)cgbackColor, nil];
		rectangleLayer.cornerRadius = 15;
		rectangleLayer.frame=CGRectMake(x, y, w, h);
		
		//Second：文字
		
		float fontSize = [userDefaults floatForKey:@Pref_Lyrics_FontSize];
		if (fontSize <= 0) {
			fontSize = 28;
		}
		NSString *fontName = [userDefaults stringForKey:@Pref_Lyrics_FontName];
		if (!fontName) {
			fontName = @"Helvetica";
		}
		NSColor *textColor = [NSColor whiteColor];
		NSData *theData=[userDefaults dataForKey:@Pref_Desktop_Text_Color];
		if (theData != nil) textColor =(NSColor *)[NSUnarchiver unarchiveObjectWithData:theData];
		
		
		CGFontRef font = CGFontCreateWithFontName((CFStringRef)fontName);
		
		CGColorRef cgfontColor = CGColorCreateFromNSColor (colorSpace, textColor);
		
		textLayer.string = self.currentLyrics;
		textLayer.fontSize = fontSize;
		textLayer.frame=CGRectMake(x, y - h/2 + fontSize/2, w, h);
		textLayer.alignmentMode = kCAAlignmentCenter;
		textLayer.font = font;
		textLayer.foregroundColor = cgfontColor;
		
		CGFontRelease(font);
		CGColorSpaceRelease (colorSpace);
		CGColorRelease (cgbackColor);
		CGColorRelease (cgfontColor);
	}else{
		rectangleLayer.frame = CGRectMake(0, 0, 0, 0);
		textLayer.frame=CGRectMake(0, 0, 0, 0);
	}
	
    [pool release];
}


- (void) iTunesPlayerInfo:(NSNotification *)note
{
    @autoreleasepool {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        if ([[[note userInfo] objectForKey:@"Player State"] isEqualToString:@"Stopped"] || [[[note userInfo] objectForKey:@"Player State"] isEqualToString:@"Paused"]) {
            
            if (![userDefaults boolForKey:@Pref_Lyrcis_Show_When_Paused]) {
                rootLayer.opacity = 0;
            }
            return;
        }
        
        
        if ((note != nil) && (![[[note userInfo] objectForKey:@"Player State"] isEqualToString:@"Playing"])) {
            return;
        }
        
        
        if (![userDefaults boolForKey:@Pref_Enable_Notification]) {
            return;
        }
        
        iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];

           
        //绘制圆角矩形
        messageRectangleLayer.opacity = 1;
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB ();
        CGColorRef cgbackColor = CGColorCreateFromNSColor (colorSpace, [NSColor colorWithCalibratedWhite:0 alpha:0.3]);
        messageRectangleLayer.colors = [NSArray arrayWithObjects:(id)cgbackColor,(id)cgbackColor, nil];
        messageRectangleLayer.cornerRadius = 15;
        messageRectangleLayer.frame=CGRectMake(self.bounds.size.width / 2 - 100, 250, 200, 200);
        CGColorSpaceRelease (colorSpace);
        CGColorRelease (cgbackColor);
        
        //绘制歌曲标题
        
        messageTextLayer.fontSize = 13;
        messageTextLayer.foregroundColor = CGColorGetConstantColor(kCGColorWhite);
        messageTextLayer.frame = CGRectMake(0, 5, 200, 20);
        messageTextLayer.alignmentMode = kCAAlignmentCenter;
        messageTextLayer.string = [[note userInfo] objectForKey:@"Name"];
        
        //绘制专辑封面
        SBElementArray* theArtworks = [[iTunes currentTrack] artworks];
        messageAlbumLayer.frame = CGRectMake((200 - 150) / 2, 30, 150, 150);
        if ([theArtworks count] > 0) {
            iTunesArtwork *thisArtwork = [theArtworks objectAtIndex:0];
            NSImage *image = [[NSImage alloc] initWithData:[thisArtwork rawData]];
            messageAlbumLayer.contents = (id)image;
            [image release];
        } else{
            NSImage *image = [NSImage imageNamed:@"music-default.gif"];
            messageAlbumLayer.contents = (id)image;
        }
        
        //隐藏
        [NSThread detachNewThreadSelector:@selector(hideMessageThread) toTarget:self withObject:nil];
 
    }
}

- (void) hideMessage {
    messageRectangleLayer.opacity = 0;
}

- (void) hideMessageThread {
    
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    long i = [userDefaults integerForKey:@Pref_Notification_Time];
    if (i<=0) i = 3;
    sleep((int)i);
    
    [self performSelectorOnMainThread:@selector(hideMessage) withObject:nil waitUntilDone:NO];

}

@end
