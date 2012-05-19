//
//  AlbumModel.m
//  LyricX
//
//  Created by Martian on 12-4-4.
//  Copyright (c) 2012年 Martian. All rights reserved.
//

#import "AlbumModel.h"

@implementation AlbumModel

@synthesize artwork;
@synthesize url;


-(void) dealloc {
    self.url = nil;
    self.artwork = nil;
    [super dealloc];
}

@end
