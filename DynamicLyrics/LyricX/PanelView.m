//
//  PanelView.m
//  LyricX
//
//  Created by Martian on 12-4-3.
//  Copyright (c) 2012年 Martian. All rights reserved.
//

#import "PanelView.h"
#import "Constants.h"


@implementation PanelView


- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(iTunesLyricsChanged:) name:@"LyricsChanged" object:nil];
        LyricsLine = [[NSMutableString alloc] initWithString:@"DynamicLyrics!"];

        rootLayer = [[CALayer layer] retain];

        [rootLayer setNeedsDisplayOnBoundsChange:YES];

        [self setLayer:rootLayer];
        [self setWantsLayer:YES];
        
        textLayer = [[CATextLayer layer] retain];
        rectangleLayer = [[CAGradientLayer layer] retain];
        
        [rootLayer addSublayer:rectangleLayer];
        [rootLayer addSublayer:textLayer];
        
                
    }
    return self;
}



static CGColorRef CGColorCreateFromNSColor (CGColorSpaceRef
                                            colorSpace, NSColor *color)
{
    NSColor *deviceColor = [color colorUsingColorSpaceName:
                            NSDeviceRGBColorSpace];
    
    
    CGFloat components[4];
    [deviceColor getRed: &components[0] green: &components[1] blue:
     &components[2] alpha: &components[3]];
    return CGColorCreate (colorSpace, components);
}


-(void)iTunesLyricsChanged:(NSNotification *)note
{
    @autoreleasepool {
    NSDictionary *d = [note userInfo];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    if ([[d objectForKey:@"Lyrics"] isEqualToString:@NC_Disabled_MenuBarLyrics]) {
        return;
    }
    

    if (![userDefaults boolForKey:@Pref_Enable_Desktop_Lyrics]) {
        rectangleLayer.frame = CGRectMake(0, 0, 0, 0);
        textLayer.frame=CGRectMake(0, 0, 0, 0);
        return;
    }
    
    
    
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
        fontName = [NSString stringWithString:@"Helvetica"];
    }
    NSColor *textColor = [NSColor whiteColor];
    NSData *theData=[userDefaults dataForKey:@Pref_Desktop_Text_Color];
    if (theData != nil) textColor =(NSColor *)[NSUnarchiver unarchiveObjectWithData:theData];
    
    
    CGFontRef font = CGFontCreateWithFontName((CFStringRef)fontName);
    
    CGColorRef cgfontColor = CGColorCreateFromNSColor (colorSpace, textColor);

    if (![[d objectForKey:@"Lyrics"] isEqualToString:@NC_Changed_DesktopLyrics]) {
        textLayer.string = [d objectForKey:@"Lyrics"];

    }

    textLayer.fontSize = fontSize;
    textLayer.frame=CGRectMake(x, y - h/2 + fontSize/2 , w, h);
    textLayer.alignmentMode = kCAAlignmentCenter;
    textLayer.font = font;
    textLayer.foregroundColor = cgfontColor;
    
    CGFontRelease(font);
    CGColorSpaceRelease (colorSpace);
    CGColorRelease (cgbackColor);
    CGColorRelease (cgfontColor);
    }
}




@end
