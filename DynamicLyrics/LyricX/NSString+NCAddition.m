//
//  NSString+NCAddition.m
//  ChineseConverter Example
//
//  Created by nickcheng on 13-2-28.
//  Copyright (c) 2013年 NC. All rights reserved.
//

#import "NSString+NCAddition.h"
#import "NCChineseConverter.h"

@implementation NSString (NCAddition)

- (NSString *)chineseStringTW {
  return [[NCChineseConverter sharedInstance] convert:self withDict:NCChineseConverterDictTypezh2TW];
}

- (NSString *)chineseStringHK {
  return [[NCChineseConverter sharedInstance] convert:self withDict:NCChineseConverterDictTypezh2HK];
}

- (NSString *)chineseStringSG {
  return [[NCChineseConverter sharedInstance] convert:self withDict:NCChineseConverterDictTypezh2SG];
}

- (NSString *)chineseStringCN {
  return [[NCChineseConverter sharedInstance] convert:self withDict:NCChineseConverterDictTypezh2CN];
}


@end
