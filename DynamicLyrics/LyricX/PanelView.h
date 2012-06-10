//
//  PanelView.h
//  LyricX
//
//  Created by Martian on 12-4-3.
//  Copyright (c) 2012年 Martian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quartz/Quartz.h>

@interface PanelView : NSView {
    NSMutableString *LyricsLine;
    NSNotificationCenter *nc;
    CALayer *rootLayer;
    CATextLayer *textLayer;
    CAGradientLayer *rectangleLayer;
}


@end
