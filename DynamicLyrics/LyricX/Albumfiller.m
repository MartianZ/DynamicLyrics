//
//  Albumfiller.m
//  LyricX
//
//  Created by Martian on 12-4-4.
//  Copyright (c) 2012年 Martian. All rights reserved.
//

#import "Albumfiller.h"

@interface Albumfiller ()

@property (strong, nonatomic) NSString *searchedAlbum;
@end

@implementation Albumfiller


- (id)init
{
    self = [super initWithWindowNibName:@"Albumfiller"];
    if (self) {    
        
        
        DouBan = [[DouBanAPI alloc]init];

        [self.window makeKeyAndOrderFront:self];
        [self.window center];
        [self.window setLevel:NSFloatingWindowLevel];
        dnc = [NSDistributedNotificationCenter defaultCenter];

        [dnc addObserver:self selector:@selector(iTunesPlayerInfo) name:@"com.apple.iTunes.playerInfo" object:nil];
        
        
        operationQueue = [[NSOperationQueue alloc] init];
        [operationQueue setMaxConcurrentOperationCount:5];
        self.searchedAlbum = nil;
        [self SearchArtwork];
        
        
    }
    return self;
}

-(void)dealloc
{
    [dnc removeObserver:self];
    [super dealloc];
}


-(void)DownloadImage:(NSDictionary *)d
{
    NSString *s = [NSString stringWithString:[d objectForKey:@"url"]];
    NSLog(@"%@",s);
    AlbumModel *am = [d objectForKey:@"am"];
    NSImage *image = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:s]];
    
    if (am)
        am.artwork = image;
    
    [image release];
}


-(void)SearchArtwork
{
    iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];

    if (![self.window isVisible]) return;
    if ([[iTunes currentTrack] album] == nil)
    {
        return;
    }
	NSString *searchAlbum = [NSString stringWithFormat:@"%@ %@", [[iTunes currentTrack] albumArtist],[[iTunes currentTrack] album]];
	if ([searchAlbum isEqualToString:self.searchedAlbum]) {
		NSLog(@"Same album. Ignore action.");
		return;
	}
	NSLog(@"Search album: %@", self.searchedAlbum);
    [DouBan SearchArtwork:[[iTunes currentTrack] album]];
    
    SBElementArray* theArtworks = [[iTunes currentTrack] artworks];
    unsigned long totalArtworkCount = [theArtworks count];
    if (totalArtworkCount > 0) {
        iTunesArtwork *thisArtwork = [theArtworks objectAtIndex:0];
        
        NSImage *image = [[NSImage alloc] initWithData:[thisArtwork rawData]];
        [currentArtwork setImage:image];
        [image release];

    }
    else {
        [currentArtwork setImage:[NSImage imageNamed:@"music-default.gif"]];
    }
    
    [IB_Array_Controller removeObjects:[IB_Array_Controller arrangedObjects]];

    for (NSString* str in DouBan.SongArtwork) {
        if ([str hasSuffix:@"music-default.gif"]) continue;
        
        AlbumModel *singelArtWork = [[AlbumModel alloc] init];
        singelArtWork.url = str;
        [IB_Array_Controller addObject:singelArtWork];

        
        NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:str,@"url",singelArtWork,@"am", nil];
        
        NSInvocationOperation *operation = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(DownloadImage:) object:d];
        [operationQueue addOperation:operation];
        [operation release];
        
        [singelArtWork release];

        
    }
	self.searchedAlbum = searchAlbum;
}

- (void) iTunesPlayerInfo
{
    [self SearchArtwork];
}

-(IBAction)ChangeAlbum:(id)sender
{
    if ([sender isKindOfClass:[NSButton class]])
    {
        NSLog(@"%@",sender);
        NSImage *im = [(NSButton *)sender image];
        iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
        iTunesArtwork *artwork = [[[iTunes currentTrack] artworks] objectAtIndex:0];
        artwork.rawData = [im TIFFRepresentation];
        artwork.data = im;
        [currentArtwork setImage:im];
        
        
        
    }
    
    
    
}

@end
