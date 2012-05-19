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
    }
    return self;
}

-(void)iTunesLyricsChanged:(NSNotification *)note
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSDictionary *d = [note userInfo];
    
    if ([[d objectForKey:@"Lyrics"] isEqualToString:@NC_Disabled_MenuBarLyrics]) {
        [pool release]; return;
    }
    
    if ([[d objectForKey:@"Lyrics"] isEqualToString:@NC_Changed_DesktopLyrics]) {
        [self setNeedsDisplay:YES];
        [pool release]; return;
    }
   
    [LyricsLine setString: [d objectForKey:@"Lyrics"]];
    [self setNeedsDisplay:YES];
    [pool release];
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    if (![userDefaults boolForKey:@Pref_Enable_Desktop_Lyrics]) {
         return;
    }
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    //First: 绘制圆角矩形
    CGFloat x = [userDefaults floatForKey:@Pref_Lyrics_X];
    x = x <= 0 ? 150 : x;
    CGFloat y = [userDefaults floatForKey:@Pref_Lyrics_Y];
    y = y <=0 ? 100 : y;
    CGFloat w = [userDefaults floatForKey:@Pref_Lyrics_W];
    w = w <=0 ? self.bounds.size.width - (x*2) : w;
    CGFloat h = [userDefaults floatForKey:@Pref_Lyrics_H];
    h = h <=0 ? 100 : h;
    
    
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(x, y, w, h) xRadius:15 yRadius:15];
    
    NSColor *backColor = [NSColor whiteColor];
    NSData *theDataA=[userDefaults dataForKey:@Pref_Desktop_Background_Color];
    if (theDataA != nil) backColor =(NSColor *)[NSUnarchiver unarchiveObjectWithData:theDataA];

    
    [backColor set];
    [path fill];
    
    //Second: 设置文字样式
    NSMutableDictionary *attr=[[NSMutableDictionary alloc] init];
    
    
    NSString *fontName = [userDefaults stringForKey:@Pref_Lyrics_FontName];
    if (!fontName) {
        fontName = [NSString stringWithString:@"Helvetica"];
    }
    float fontSize = [userDefaults floatForKey:@Pref_Lyrics_FontSize];
    if (fontSize <= 0) {
        fontSize = 28;
    }
    
    
    NSColor *textColor = [NSColor whiteColor];
    NSData *theData=[userDefaults dataForKey:@Pref_Desktop_Text_Color];
    if (theData != nil) textColor =(NSColor *)[NSUnarchiver unarchiveObjectWithData:theData];
    
    [attr setObject:textColor forKey:NSForegroundColorAttributeName];

    
    [attr setObject:[NSFont fontWithName:fontName size:fontSize] forKey:NSFontAttributeName];
    
    
    
    NSMutableParagraphStyle *par=[[NSMutableParagraphStyle alloc] init];
    [par setAlignment:NSCenterTextAlignment];
    [par setLineBreakMode:NSLineBreakByClipping];
    [par setLineHeightMultiple:30];
    [attr setObject:par forKey:NSParagraphStyleAttributeName];
    
    //Third: 绘制文字
    NSMutableAttributedString *str=[[NSMutableAttributedString alloc] initWithString:LyricsLine attributes:attr];    
    [str drawInRect:NSMakeRect(x, y -h/2 + fontSize/2, w, h)];
    [str release];
    [attr release];
    [par release];
    [pool release];
    
}


@end
