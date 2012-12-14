//
//  PanelView.h
//  LyricX
//
//  Created by Martian on 12-4-3.
//  Copyright (c) 2012年 Martian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quartz/Quartz.h>

@interface LyricsView : NSView  {
    NSNotificationCenter *nc;
    NSDistributedNotificationCenter *dnc;
    CALayer *rootLayer;
    CATextLayer *textLayer;
    CAGradientLayer *rectangleLayer;
    CAGradientLayer *messageRectangleLayer;
    CATextLayer *messageTextLayer;
    CALayer *messageAlbumLayer;
}


@end
