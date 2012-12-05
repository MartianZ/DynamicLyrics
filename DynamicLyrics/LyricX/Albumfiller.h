//
//  Albumfiller.h
//  LyricX
//
//  Created by Martian on 12-4-4.
//  Copyright (c) 2012年 Martian. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AlbumModel.h"
#import "DouBanAPI.h"
#import "iTunes.h"
@interface Albumfiller : NSWindowController {
    IBOutlet NSArrayController *IB_Array_Controller;
    DouBanAPI *DouBan;
    NSDistributedNotificationCenter *dnc;
    NSOperationQueue *operationQueue;

    IBOutlet NSImageCell *currentArtwork;
    IBOutlet NSCollectionView *collectionView;
}

-(void)SearchArtwork;

-(IBAction)ChangeAlbum:(id)sender;
 

@end
