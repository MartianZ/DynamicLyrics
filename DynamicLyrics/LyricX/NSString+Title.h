//
//  NSString+Title.h
//  LyricX
//
//  Created by Frank on 26/05/2017.
//  Copyright © 2017 Martian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Title)

- (NSString *)getRidOfUnusedIndexNumber;

- (NSString *)getRidOfUnusedIndexNumberSeparatedByString:(NSString *)separator;

@end
