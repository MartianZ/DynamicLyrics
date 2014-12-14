//
//  MenuBarLyrics.h
//  LyricX
//
//  Created by Martian on 12-4-3.
//  Copyright (c) 2012年 Martian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MenuBarLyrics : NSObject {
    @private
    NSNotificationCenter *nc;
    NSStatusItem *_statusItem;
    NSOperationQueue *_queue;
}

@property(nonatomic, retain) NSString *CurrentSongLyrics;
@property(retain)NSMenu*AppMenu;

-(id) initWithMenu:(NSMenu *)AppMenu;


@end
