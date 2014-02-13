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
@property(copy, nonatomic)NSString *lastLyrics;
@property(copy, nonatomic)NSString *nextLyrics;

@end

@implementation LyricsView

@synthesize currentLyrics=_currentLyrics;
@synthesize nextLyrics=_nextLyrics;
@synthesize lastLyrics=_lastLyrics;

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
        secondTextLayer = [[CATextLayer layer] retain];
        rectangleLayer = [[CAGradientLayer layer] retain];
        messageRectangleLayer = [[CAGradientLayer layer] retain];
        messageAlbumLayer = [[CALayer layer] retain];
        messageTextLayer = [[CATextLayer layer] retain];
        [rootLayer addSublayer:rectangleLayer];
        [rootLayer addSublayer:textLayer];
        [rootLayer addSublayer:secondTextLayer];
        [rootLayer addSublayer:messageRectangleLayer];

        [messageRectangleLayer addSublayer:messageAlbumLayer];
        [messageRectangleLayer addSublayer:messageTextLayer];
        
        dnc = [NSDistributedNotificationCenter defaultCenter];
        [dnc addObserver:self selector:@selector(iTunesPlayerInfo:) name:@"com.apple.iTunes.playerInfo" object:nil];
        
        textLayer.contentsScale = [[NSScreen mainScreen] backingScaleFactor];
        secondTextLayer.contentsScale = [[NSScreen mainScreen] backingScaleFactor];

        hideTimer = NULL;
        switchTimer = NULL;
        switchFlag = YES;
        
        textLayer.string = @"";
        secondTextLayer.string = @"";
    }
    return self;
}

- (void) viewDidChangeBackingProperties {
    self.layer.contentsScale = [[self window] backingScaleFactor];

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
			secondTextLayer.frame = CGRectMake(0, 0, 0, 0);
			[pool release];
			return;
			
		}else{
			// Enable desktop lyrics
			forceUpdate = YES;
		}
    }else{
		self.currentLyrics = lyrics;
        if ([[[note userInfo] allKeys] containsObject:@"NextLyrics"]) {
            self.nextLyrics = [[note userInfo] objectForKey:@"NextLyrics"];
        } else {
            self.nextLyrics = @"";
        }
        if (!self.currentLyrics || [self.currentLyrics length] == 0) {
            self.nextLyrics = @""; //不剧透歌词
        }
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
		
        textLayer.fontSize = fontSize;
        textLayer.alignmentMode = kCAAlignmentCenter;
        textLayer.font = font;
        if ([userDefaults boolForKey:@Pref_Shadow_Style_Text]) {
            textLayer.shadowOpacity = 1.0;
            textLayer.shadowRadius = 2;
            textLayer.shadowOffset = CGSizeMake (0,  0);
        } else {
            textLayer.shadowOpacity = 0;
            
        }
        textLayer.foregroundColor = cgfontColor;
        
        
        secondTextLayer.fontSize = fontSize;
        secondTextLayer.alignmentMode = kCAAlignmentCenter;
        secondTextLayer.font = font;
        if ([userDefaults boolForKey:@Pref_Shadow_Style_Text]) {
            secondTextLayer.shadowOpacity = 1.0;
            secondTextLayer.shadowRadius = 2;
            secondTextLayer.shadowOffset = CGSizeMake (0,  0);
        } else {
            secondTextLayer.shadowOpacity = 0;
        }
        secondTextLayer.foregroundColor = cgfontColor;
        
        if (![userDefaults boolForKey:@Pref_Lyrics_Show_Next_Line] || [self.nextLyrics length] == 0) {
            //单行歌词
            textLayer.string = self.currentLyrics;
            textLayer.frame=CGRectMake(x, y - h/2 + fontSize / 2, w, h); //fontSize / 2 * number of line
            secondTextLayer.string = @"";
        } else {
            ///secondTextLayer start
            
            
            if (switchFlag) {
                if ([secondTextLayer.string isEqualToString:self.currentLyrics]) {
                    secondTextLayer.frame=CGRectMake(x, y - h/2 + fontSize, w, h);
                    
                    [textLayer removeAllAnimations];
                    textLayer.hidden = YES;
                    [textLayer removeAllAnimations];
                    textLayer.string = @"";
                    [textLayer removeAllAnimations];
                    textLayer.frame=CGRectMake(x, y - h/2  - 5, w, h);
                    [textLayer removeAllAnimations];

                    textLayer.hidden = NO;
                    textLayer.string = self.nextLyrics;

                    switchFlag = NO;

                } else {
                    //RESET!
                    switchFlag = YES;
                    textLayer.frame=CGRectMake(x, y - h/2 + fontSize, w, h);
                    secondTextLayer.frame=CGRectMake(x, y - h/2  - 5, w, h);
                    textLayer.string = self.currentLyrics;
                    secondTextLayer.string = self.nextLyrics;
                }
            } else {
                if ([textLayer.string isEqualToString:self.currentLyrics]) {
                    
                    textLayer.frame=CGRectMake(x, y - h/2 + fontSize, w, h);
                    
                    [secondTextLayer removeAllAnimations];
                    secondTextLayer.hidden = YES;
                    [secondTextLayer removeAllAnimations];
                    secondTextLayer.string = @"";
                    [secondTextLayer removeAllAnimations];
                    secondTextLayer.frame=CGRectMake(x, y - h/2  - 5, w, h);
                    [secondTextLayer removeAllAnimations];
                    
                    secondTextLayer.hidden = NO;
                    secondTextLayer.string = self.nextLyrics;


                } else {
                    //RESET!
                    textLayer.frame=CGRectMake(x, y - h/2 + fontSize, w, h);
                    secondTextLayer.frame=CGRectMake(x, y - h/2  - 5, w, h);
                    textLayer.string = self.currentLyrics;
                    secondTextLayer.string = self.nextLyrics;
                }
                switchFlag = YES;

            }

        
            ///secondTextLayer end
        }
		

        
        
		
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
        [self hideMessageThread];
//        [NSThread detachNewThreadSelector:@selector(hideMessageThread) toTarget:self withObject:nil];
 
    }
}

- (void) hideMessage:(NSTimer *)timer {
    messageRectangleLayer.opacity = 0;
    hideTimer = NULL;
}

- (void) hideMessageThread {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    long time = [userDefaults integerForKey:@Pref_Notification_Time];
    if (time <= 0)
        time = 3;
    
    if (hideTimer != NULL)
        [hideTimer invalidate];
    
    hideTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)time
                                                 target:self
                                               selector:@selector(hideMessage:)
                                               userInfo:NULL
                                                repeats:FALSE];
}

@end
