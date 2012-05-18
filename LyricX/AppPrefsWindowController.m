//
//  AppPrefsWindowController.m
//  LyricX
//
//  Created by Martian on 12-5-1.
//  Copyright (c) 2012年 Martian. All rights reserved.
//

#import "AppPrefsWindowController.h"

@implementation AppPrefsWindowController

- (void)setupToolbar
{
	[self addView:generalPreferenceView label:@"General"];
	[self addView:advancedPreferenceView label:@"Advanced"];
	[self addView:donatePreferenceView label:@"Donate"];
	[self setCrossFade:[[NSUserDefaults standardUserDefaults] boolForKey:@"fade"]];
	[self setShiftSlowsAnimation:[[NSUserDefaults standardUserDefaults] boolForKey:@"shiftSlowsAnimation"]];
    
    [[NSColorPanel sharedColorPanel] setShowsAlpha:YES];
    [NSColor setIgnoresAlpha:NO];

}

- (IBAction)EnableMenuBarLyrics:(id)sender
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:@NC_LyricsChanged object:self userInfo:[NSDictionary dictionaryWithObject:@NC_Disabled_MenuBarLyrics forKey:@"Lyrics"]];
    
}

- (IBAction)DesktopLyricsChanged:(id)sender;
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:@NC_LyricsChanged object:self userInfo:[NSDictionary dictionaryWithObject:@NC_Changed_DesktopLyrics forKey:@"Lyrics"]];
    
}

- (void)changeFont:(id)sender
{
    NSLog(@"CHANGE FONT!");
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSFont *oldFont = [NSFont systemFontOfSize:13];
    NSFont *newFont = [sender convertFont:oldFont];
    [userDefaults setObject:[newFont fontName] forKey:@Pref_Lyrics_FontName];
    [userDefaults setFloat:[newFont pointSize] forKey:@Pref_Lyrics_FontSize];
    
    [userDefaults setObject:[NSString stringWithFormat:@"%@, %.1f",[newFont displayName],[userDefaults floatForKey:@Pref_Lyrics_FontSize]] forKey:@Pref_Lyrics_DisplayFont];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:@NC_LyricsChanged object:self userInfo:[NSDictionary dictionaryWithObject:@NC_Changed_DesktopLyrics forKey:@"Lyrics"]];
    
}


-(void)changeColor:(id)sender
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:@NC_LyricsChanged object:self userInfo:[NSDictionary dictionaryWithObject:@NC_Changed_DesktopLyrics forKey:@"Lyrics"]];
}

- (NSUInteger)validModesForFontPanel:(NSFontPanel *)fontPanel 
{
    return  NSFontPanelSizeModeMask | NSFontPanelCollectionModeMask;
}

-(IBAction)openFontPanel:(id)sender
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    [fontManager setTarget:self];
    NSFontPanel *fp = [NSFontPanel sharedFontPanel];
    [fontManager setSelectedFont:[NSFont fontWithName:[userDefaults stringForKey:@Pref_Lyrics_FontName] size:[userDefaults floatForKey:@Pref_Lyrics_FontSize]] isMultiple:NO];
    [fp makeKeyAndOrderFront:self];
    [fp setDelegate:self];
}

- (IBAction)DonatePaypal:(id)sender
{
    NSURL *url = [NSURL URLWithString:@"https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=fzyadmin%40gmail%2ecom&item_name=Support%20future%20development%20of%204321.La%20app&no_shipping=1&no_note=1&tax=0&currency_code=USD&lc=US&bn=PP%2dDonationsBF&charset=UTF%2d8"];
    [[NSWorkspace sharedWorkspace] openURL:url];
}
- (IBAction)DonateAlipay:(id)sender
{
    NSURL *url = [NSURL URLWithString:@"https://me.alipay.com/martian"];
    [[NSWorkspace sharedWorkspace] openURL:url];
}
- (IBAction)DonateAmazon:(id)sender
{
    NSURL *url = [NSURL URLWithString:@"http://www.amazon.cn/registry/wishlist/1JUEM4PZIL82C"];
    [[NSWorkspace sharedWorkspace] openURL:url];
}

@end
