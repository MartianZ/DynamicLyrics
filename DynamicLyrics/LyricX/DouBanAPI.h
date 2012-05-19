//
//  DouBanAPI.h
//  LyricX
//
//  Created by Martian on 12-4-7.
//  Copyright (c) 2012年 Martian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DouBanAPI : NSObject {
}

@property(nonatomic, retain) NSMutableArray *SongArtwork;

-(void)SearchArtwork:(NSString* )q;

@end
