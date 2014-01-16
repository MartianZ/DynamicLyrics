//
//  FloatPanel.h
//  LyricX
//
//  Created by Martian on 12-4-3.
//  Copyright (c) 2012年 Martian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "LyricsView.h"
#import "CGSPrivate.h"


@interface LyricsFloatWindow : NSPanel {
    LyricsView *lyricsView;
    NSNotificationCenter *nc;


}

-(id)initWithContentRect:(NSRect)contentRect;

@end
