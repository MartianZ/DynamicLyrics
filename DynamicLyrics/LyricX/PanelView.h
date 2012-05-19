//
//  PanelView.h
//  LyricX
//
//  Created by Martian on 12-4-3.
//  Copyright (c) 2012年 Martian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PanelView : NSView {
    @private
    NSMutableString *LyricsLine;
    NSNotificationCenter *nc;
}

@end
