//
//  EditLyricsWindowController.m
//  LyricX
//
//  Created by Zeray Rice on 2014/02/12.
//  Copyright (c) 2014年 Martian. All rights reserved.
//

#import "EditLyricsWindowController.h"
#import "Constants.h"

@interface EditLyricsWindowController ()

@property (assign) IBOutlet NSTextView *textarea;
@property (assign) IBOutlet NSButton *saveButton;

@end

@implementation EditLyricsWindowController

@synthesize SongLyrics;
@synthesize SongArtist;
@synthesize SongName;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (id)initWithLyrics:(NSString *)Lyrics artist:(NSString *)artist name:(NSString *)name
{
    if ((self = [super initWithWindowNibName:@"EditLyricsWindow"])) {
        self.SongLyrics = Lyrics;
        self.SongArtist = artist;
        self.SongName   = name;
        
        self.window.level = NSFloatingWindowLevel;
        [self.window makeKeyAndOrderFront:self];
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    if (self.SongLyrics != nil) {
        [self.textarea insertText:self.SongLyrics];
    }
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction) buttonClicked:(id)sender
{
    NSString *newLyrics = [[self.textarea textStorage] string];
    
    [[NSUserDefaults standardUserDefaults] setValue:newLyrics forKey:[NSString stringWithFormat:@"%@%@", self.SongArtist, self.SongName]];

    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:self.SongName, @"SongTitle", self.SongArtist, @"SongArtist", nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserLyricsChanged" object:self userInfo:dict];
    
    [self.window close];
}

@end
