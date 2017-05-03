//
//  NCChineseConverter.h
//  NCChineseConverter Example
//
//  Created by nickcheng on 13-2-28.
//  Copyright (c) 2013年 NC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
  NCChineseConverterDictTypezh2TW = 0,
  NCChineseConverterDictTypezh2HK,
  NCChineseConverterDictTypezh2SG,
  NCChineseConverterDictTypezh2CN,
} NCChineseConverterDictType;

@interface NCChineseConverter : NSObject

+ (NCChineseConverter *)sharedInstance;
- (NSString *)convert:(NSString *)oriString withDict:(NCChineseConverterDictType)dictType;

@end
