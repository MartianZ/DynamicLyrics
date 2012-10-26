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
	//[self addView:generalPreferenceView label:@"General"];
	[self addView:advancedPreferenceView label:@"Lyrics"];
	//[self addView:donatePreferenceView label:@"Donate"];
    [self addView:notificationPreferenceView label:@"Notification"];
    [self addView:donatePreferenceView label:@"Donate"];

    
	[self setCrossFade:[[NSUserDefaults standardUserDefaults] boolForKey:@"fade"]];
	[self setShiftSlowsAnimation:[[NSUserDefaults standardUserDefaults] boolForKey:@"shiftSlowsAnimation"]];
    
    [[NSColorPanel sharedColorPanel] setShowsAlpha:YES];
    [NSColor setIgnoresAlpha:NO];

}

- (IBAction)DesktopLyricsChanged:(id)sender
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
    return  NSFontPanelSizeModeMask | NSFontPanelCollectionModeMask | NSFontPanelShadowEffectModeMask;
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

/*
 需要更换一种能够SandBox的优雅方式……
- (LSSharedFileListRef)loginItemsFileListRef {
    LSSharedFileListRef loginItemsRef =
    LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    return (LSSharedFileListRef)(loginItemsRef);
}

- (NSArray *)loginItemsArrayForFileListRef:(LSSharedFileListRef)fileListRef {
    UInt32 seedValue;
    CFArrayRef filelistArrayRef = LSSharedFileListCopySnapshot(fileListRef,
                                                               &seedValue);
    return (NSArray *)filelistArrayRef;
}

- (void)addPathToLoginItems:(NSString*)path hide:(BOOL)hide {
    if (!path) return;
    // make sure it isn't already there
    // now append it
    [self removeItemWithNameFromLoginItems:@"DynamicLyricsHelper"];
    NSURL *url = [NSURL fileURLWithPath:path];
    if (url) {
        LSSharedFileListRef loginItemsRef = [self loginItemsFileListRef];
        if (loginItemsRef) {
            NSDictionary *setProperties =
            [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:hide]
                                        forKey:(id)kLSSharedFileListLoginItemHidden];
            LSSharedFileListItemRef itemRef =
            LSSharedFileListInsertItemURL(loginItemsRef,
                                          kLSSharedFileListItemLast, NULL, NULL,
                                          (CFURLRef)url,
                                          (CFDictionaryRef)setProperties, NULL);
            if (itemRef) CFRelease(itemRef);
        }
    }

}

- (void)removeItemWithNameFromLoginItems:(NSString *)name {
    if ([name length] == 0) return;
    LSSharedFileListRef loginItemsRef = [self loginItemsFileListRef];
    if (loginItemsRef) {
        NSArray *fileList = [self loginItemsArrayForFileListRef:loginItemsRef];
        for (id item in fileList) {
            LSSharedFileListItemRef itemRef = (LSSharedFileListItemRef)item;
            CFStringRef itemNameRef = LSSharedFileListItemCopyDisplayName(itemRef);
            if (itemNameRef) {
                NSString *itemName =
                [(NSString *)itemNameRef stringByDeletingPathExtension];
                if ([itemName isEqual:name]) {
                    LSSharedFileListItemRemove(loginItemsRef, itemRef);
                }
                CFRelease(itemNameRef);
            }
        }
    }
}
*/
- (IBAction)LaunchAndQuitWithiTunes:(id)sender
{
    /*NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/sh"];
    [task setArguments:[NSArray arrayWithObjects:@"-c", @"killall DynamicLyricsHelper", nil]];
    [task launch];
    [task waitUntilExit];
    [task release];*/
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults boolForKey:@Pref_Launch_Quit_With_iTunes]) {

        //NSString *path = [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath],@"DynamicLyricsHelper.app"];

        //[[NSWorkspace sharedWorkspace] launchApplication:path];
        
        //添加开机启动
        //[self addPathToLoginItems:path hide:0];
        
        /* 
         
         按照苹果蹩脚的文档，下面的代码确实可以在沙盒中运行。不过出来的Helper甚至无法kill掉进程（kill掉立刻被系统重新运行了，囧），而且在系统设置中的Login Items也不再显示。代码是比我之前的代码简洁了好几倍（报一个警告是怎么回事？！），但是对于用户来说体验差了好多，只能再通过DnamicLyrics来关闭Helper。
         估计是苹果的工程师傲娇偷懒这么设定的。嗯，一定是这样！
         
         无聊的Apple弄沙盒……
         
         */
        
        NSString *ref = @"la.4321.DynamicLyricsHelper";
        if (!SMLoginItemSetEnabled((CFStringRef)ref, YES)) {
            NSLog(@"SMLoginItemSetEnabled failed.");
        }
        
    } else {
        
        //[self removeItemWithNameFromLoginItems:@"DynamicLyricsHelper"];
        NSString *ref = @"la.4321.DynamicLyricsHelper";
        if (!SMLoginItemSetEnabled((CFStringRef)ref, false)) {
            NSLog(@"SMLoginItemSetEnabled failed.");
        }
    }
}

@end
