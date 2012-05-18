//
//  AlbumModel.h
//  LyricX
//
//  Created by Martian on 12-4-4.
//  Copyright (c) 2012年 Martian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlbumModel : NSObject {
    NSString *url;
    NSImage *artwork;
}

@property (nonatomic,retain) NSString *url;
@property (nonatomic,retain) NSImage *artwork;

@end
