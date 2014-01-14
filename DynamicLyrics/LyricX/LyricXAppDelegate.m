//
//  LyricXAppDelegate.m
//  LyricX
//
//  Created by Martian on 12-4-3.
//  Copyright 2012 Martian. All rights reserved.
//

#import "LyricXAppDelegate.h"
#import "Constants.h"
#import <Carbon/Carbon.h>
@implementation AppDelegate

//保存快捷键事件回调的引用
static EventHandlerRef g_EventHandlerRef = NULL;
//保存快捷键注册的引用
static EventHotKeyRef a_HotKeyRef = NULL;
//快捷键注册使用的信息
static EventHotKeyID a_HotKeyID = {'keyA',1};

+ (void)initialize {
	if ( self == [AppDelegate class] ) {
        //set default preference values
        NSDictionary *defaultValues = @{@Pref_Desktop_Text_Color: [NSArchiver archivedDataWithRootObject:[NSColor yellowColor]],
                                        @Pref_Desktop_Background_Color: [NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedWhite:0 alpha:0.25]],
                                        @Pref_Enable_Desktop_Lyrics: @(YES),
                                        @Pref_Enable_MenuBar_Lyrics: @(NO),
                                        @Pref_hotkeyCodeWriteLyrics: [NSNumber numberWithInt:kVK_ANSI_W],
                                        @Pref_hotkeyModifiersWriteLyrics:[NSNumber numberWithInt:optionKey]
                                        };
        [[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
        [[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:defaultValues];
        [[NSUserDefaults standardUserDefaults] synchronize];  //And sync them

    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    //Initialize application
    //Start coding at 2012-04-03 10:51 =。=
    //By MartianZ
    Controller = [[MainController alloc] initWithMenu:AppMenu initWithDelayItem:currentDelay];

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults floatForKey:@Pref_Lyrics_W] <= 0)
    {
        [userDefaults setInteger:NSScreen.mainScreen.frame.size.width-300 forKey:@Pref_Lyrics_W];
    }
    
    
    if ([userDefaults integerForKey:@"DonationNewNew"] == 5 || [userDefaults integerForKey:@"DonationNewNew"] == 40) {
        [[NSAlert alertWithMessageText:NSLocalizedString(@"Donate us", nil) defaultButton:@"OKay" alternateButton:nil otherButton:nil informativeTextWithFormat:NSLocalizedString(@"Donate", nil)] runModal];
    }
    if ([userDefaults integerForKey:@"DonationNewNew"] <= 50) {
        [userDefaults setInteger:[userDefaults integerForKey:@"DonationNewNew"] + 1 forKey:@"DonationNewNew"];
    }
    [userDefaults synchronize];
    
    //EventTypeSpec eventSpecs[] = {{kEventClassKeyboard,kEventHotKeyPressed}};
    //InstallApplicationEventHandler(NewEventHandlerUPP(myHotKeyHandler),GetEventTypeCount(eventSpecs), eventSpecs, (void *)self, &g_EventHandlerRef);
        
    //注册快捷键:option+B
    //RegisterEventHotKey((UInt32)[userDefaults integerForKey:@Pref_hotkeyCodeWriteLyrics], (UInt32)[userDefaults integerForKey:@Pref_hotkeyModifiersWriteLyrics], a_HotKeyID, GetApplicationEventTarget(), 0, &a_HotKeyRef);

}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    /*
    //注销快捷键
    if (a_HotKeyRef)
    {
        UnregisterEventHotKey(a_HotKeyRef);
        a_HotKeyRef = NULL;
    }

    //注销快捷键的事件回调
    if (g_EventHandlerRef)
    {
        RemoveEventHandler(g_EventHandlerRef);
        g_EventHandlerRef = NULL;
    }*/
}



OSStatus myHotKeyHandler(EventHandlerCallRef inHandlerCallRef, EventRef inEvent, void *inUserData)
{
    //判定事件的类型是否与所注册的一致
    if (GetEventClass(inEvent) == kEventClassKeyboard && GetEventKind(inEvent) == kEventHotKeyPressed)
    {
        //获取快捷键信息，以判定是哪个快捷键被触发
        EventHotKeyID keyID;
        GetEventParameter(inEvent,
                          kEventParamDirectObject,
                          typeEventHotKeyID,
                          NULL,
                          sizeof(keyID),
                          NULL,
                          &keyID);
        if (keyID.id == a_HotKeyID.id) {
            NSLog(@"Key pressed!");
            AppDelegate * mySelf = (AppDelegate *) inUserData;
            
            @try {
                [mySelf WriteLyricsToiTunes:nil];
            }
            @catch (NSException *exception) {
                //
            }
            @finally {
                [[NSSound soundNamed:@"Ping"] play];

            }

            
            
        }
    }
    return noErr;
}

-(IBAction)OpenAlbumfillerWindow:(id)sender
{
    if (!AlbumfillerWindow)
        AlbumfillerWindow = [[Albumfiller alloc] init];
    else {
        [AlbumfillerWindow.window makeKeyAndOrderFront:self];
        [AlbumfillerWindow SearchArtwork];
    }
    
}

-(IBAction)OpenLyricsSearchWindow:(id)sender
{  
    //i think put the init code in app delegate may be a good idea
    SearchWindow = [[LyricsSearchWnd alloc] initWithArtist:Controller.iTunesCurrentTrack.artist initWithTitle:Controller.iTunesCurrentTrack.name];
}

-(IBAction)CopyCurrentLyrics:(id)sender
{
    [[NSPasteboard generalPasteboard] declareTypes:[NSArray arrayWithObject: NSStringPboardType] owner:nil];
    [[NSPasteboard generalPasteboard] setString:Controller.CurrentSongLyrics forType: NSStringPboardType];
}


-(IBAction)CopyTotalLRC:(id)sender
{
    [[NSPasteboard generalPasteboard] declareTypes:[NSArray arrayWithObject: NSStringPboardType] owner:nil];
    [[NSPasteboard generalPasteboard] setString:Controller.SongLyrics forType: NSStringPboardType];

}

-(IBAction)CopyTotalTextLyrics:(id)sender
{
    
    NSMutableString *s = [[NSMutableString alloc] init];
    [s setString:@""];
    for (int i = 0; i < [Controller.lyrics count]; i++) {
        [s setString:[s stringByAppendingString:[NSString stringWithFormat:@"%@\n",[[Controller.lyrics objectAtIndex:i] objectForKey:@"Content"]]]];
    }
    [[NSPasteboard generalPasteboard] declareTypes:[NSArray arrayWithObject: NSStringPboardType] owner:nil];
    [[NSPasteboard generalPasteboard] setString: s forType: NSStringPboardType];
    [s release];
    
}

-(IBAction)WriteLyricsToiTunes:(id)sender
{
    NSMutableString *s = [[NSMutableString alloc] init];
    [s setString:@""];
    for (int i = 0; i < [Controller.lyrics count]; i++) {
        [s setString:[s stringByAppendingString:[NSString stringWithFormat:@"%@\n",[[Controller.lyrics objectAtIndex:i] objectForKey:@"Content"]]]];
    }

    Controller.iTunesCurrentTrack.lyrics = s;
    [s release];

}

-(IBAction)WriteArtwork:(id)sender
{
    NSSavePanel *saveDlg = [[NSSavePanel savePanel] retain];
    
    [saveDlg setTitle:@"Save Artwork"];
    
    
     
    NSString* documentsFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Desktop"];
    NSString* fileName = [NSString stringWithFormat:@"%@ - %@.tiff",Controller.iTunesCurrentTrack.name,Controller.iTunesCurrentTrack.artist];
    
    [saveDlg setNameFieldStringValue:fileName];

    [saveDlg setDirectoryURL:[NSURL URLWithString:documentsFolder]];
    [saveDlg runModal];



    iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];


    NSImage *image = [[NSImage alloc] initWithData:[[[[iTunes currentTrack] artworks] objectAtIndex:0] rawData]];
    
    NSData *imageData = [image TIFFRepresentation];
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
    NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor];
    imageData = [imageRep representationUsingType:NSJPEGFileType properties:imageProps];
    [imageData writeToFile:[[saveDlg URL] path] atomically:NO];
    [saveDlg release];
    [image release];
}


-(IBAction)exportLRC:(id)sender
{
    NSSavePanel *saveDlg = [NSSavePanel savePanel];
    [saveDlg setTitle:@"Save Lyrics"];

    
    NSString* documentsFolder =  [NSString stringWithFormat:@"file://localhost%@",  [NSHomeDirectory() stringByAppendingPathComponent:@"Desktop"]];
    NSString* fileName = [NSString stringWithFormat:@"%@ - %@.lrc",Controller.iTunesCurrentTrack.name,Controller.iTunesCurrentTrack.artist];
    [saveDlg setNameFieldStringValue:fileName];
    [saveDlg setDirectoryURL:[NSURL URLWithString:documentsFolder]];
    [saveDlg runModal];
    [[NSFileManager defaultManager] createFileAtPath:[[saveDlg URL] path] contents:[Controller.SongLyrics dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];

}

-(IBAction)showPrefsWindow:(id)sender
{
    [[AppPrefsWindowController sharedPrefsWindowController] showWindow:nil];
	(void)sender;
}

- (IBAction)hideLyric:(id)sender {
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:[NSString stringWithFormat:@"%@%@", Controller.iTunesCurrentTrack.artist, Controller.iTunesCurrentTrack.name]];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:Controller.iTunesCurrentTrack.name, @"SongTitle", Controller.iTunesCurrentTrack.artist, @"SongArtist", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@NC_LyricsChanged object:self userInfo:dict];
    Controller.SongLyrics = @"";
    [Controller Anylize];
}

-(IBAction)importLyric:(id)sender
{
    NSOpenPanel *oPanel = [NSOpenPanel openPanel];
    [oPanel setCanChooseDirectories:NO];
	[oPanel setCanChooseFiles:YES];
	[oPanel setDirectoryURL:[NSURL URLWithString:[NSHomeDirectory() stringByAppendingPathComponent:@"Desktop"]]];
    [oPanel setAllowedFileTypes:[NSArray arrayWithObject:@"lrc"]];

    if ([oPanel runModal] == NSOKButton) {
        
        
        NSString *contents = [NSString stringWithContentsOfFile:[[[oPanel URLs] objectAtIndex:0] path] encoding:NSUTF8StringEncoding error:nil];
                
        [[NSUserDefaults standardUserDefaults] setValue:contents forKey:[NSString stringWithFormat:@"%@%@", Controller.iTunesCurrentTrack.artist, Controller.iTunesCurrentTrack.name]];
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:Controller.iTunesCurrentTrack.name, @"SongTitle", Controller.iTunesCurrentTrack.artist, @"SongArtist", nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@NC_LyricsChanged object:self userInfo:dict];
        Controller.SongLyrics = contents;
        [Controller Anylize];
    }
    

}

- (IBAction)DisabledMenuBarLyrics:(id)sender
{
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:@NC_LyricsChanged object:self userInfo:[NSDictionary dictionaryWithObject:@NC_Disabled_MenuBarLyrics forKey:@"Lyrics"]];
    
}

- (IBAction)DisabledDesktopLyrics:(id)sender
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:@NC_LyricsChanged object:self userInfo:[NSDictionary dictionaryWithObject:@NC_Changed_DesktopLyrics forKey:@"Lyrics"]];
}

- (IBAction)donate:(id)sender
{
    //NSURL *url = [NSURL URLWithString:@"http://donate.martianz.cn"];
    
    //[[NSWorkspace sharedWorkspace] openURL:url];
    
    [[AppPrefsWindowController sharedPrefsWindowController] showWindow:nil];

    [[[[AppPrefsWindowController sharedPrefsWindowController] window] toolbar] setSelectedItemIdentifier:@"Donate"];
    
    [[AppPrefsWindowController sharedPrefsWindowController] displayViewForIdentifier:@"Donate" animate:NO];
}

- (IBAction)adjustLyricsDelay:(id)sender
{
    NSString *str = [[(NSMenuItem *)sender title] stringByReplacingOccurrencesOfString:@"s" withString:@""];
    
    float i = 0 - [str floatValue]; //我发现我第一次脑残了，把延迟给弄成提前了……于是为了省事直接加个 0- 吧……
    if (Controller && Controller.iTunesCurrentTrack.name) {
        Controller->LyricsDelay += i;
        
        [currentDelay setTitle:[NSString stringWithFormat:@"%@ %.2fs",NSLocalizedString(@"CurrentDelay", nil),0 - Controller->LyricsDelay]];

        [[NSUserDefaults standardUserDefaults] setFloat:Controller->LyricsDelay forKey:[NSString stringWithFormat:@"Delay%@%@",Controller.iTunesCurrentTrack.artist,Controller.iTunesCurrentTrack.name]];
            }
}
- (IBAction)resetLyricsDelay:(id)sender
{
    if (Controller && Controller.iTunesCurrentTrack.name) {
        Controller->LyricsDelay = 0 ;
        
        [currentDelay setTitle:[NSString stringWithFormat:@"%@ %.2fs",NSLocalizedString(@"CurrentDelay", nil),0 - Controller->LyricsDelay]];
        [[NSUserDefaults standardUserDefaults] setFloat:0.0 forKey:[NSString stringWithFormat:@"Delay%@%@",Controller.iTunesCurrentTrack.artist,Controller.iTunesCurrentTrack.name]];
        
    }
}

@end
