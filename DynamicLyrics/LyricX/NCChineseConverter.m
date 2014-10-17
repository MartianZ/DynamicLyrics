//
//  NCChineseConverter.m
//  NCChineseConverter Example
//
//  Created by nickcheng on 13-2-28.
//  Copyright (c) 2013年 NC. All rights reserved.
//

#import "NCChineseConverter.h"

@implementation NCChineseConverter {
  NSDictionary *_dict;
  NSDictionary *_dictFiles;
}

#pragma mark -
#pragma mark Init

+ (NCChineseConverter *)sharedInstance {
  static NCChineseConverter *sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[NCChineseConverter alloc] init];
    //
  });
  return sharedInstance;
}

- (id)init {
  //
	if((self = [super init]) == nil) return nil;
  
  // Custom initialization
  [self initDicts];
  
  return self;
}

#pragma mark -
#pragma mark Public Methods

- (NSString *)convert:(NSString *)oriString withDict:(NCChineseConverterDictType)dictType {
  NSString *dictTypeKey;
  switch (dictType) {
    case NCChineseConverterDictTypezh2TW:
      dictTypeKey = @"zh2TW";
      break;
    case NCChineseConverterDictTypezh2HK:
      dictTypeKey = @"zh2HK";
      break;
    case NCChineseConverterDictTypezh2SG:
      dictTypeKey = @"zh2SG";
      break;
    case NCChineseConverterDictTypezh2CN:
      dictTypeKey = @"zh2CN";
      break;
    default:
      dictTypeKey = @"zh2TW";
      break;
  }
  
  //
  NSString *result = @"";
  NSDictionary *useDict = _dict[dictTypeKey];
  int i = 0;
  while (i < oriString.length) {
    int max = oriString.length - i;
    int j;
    for (j = max; j > 0; j--) {
      NSRange range = NSMakeRange(i, j);
      NSString *subStr = [oriString substringWithRange:range];
      if (useDict[subStr]) {
        result = [result stringByAppendingString:useDict[subStr]];
        break;
      }
    }
    if (j == 0) {
      result = [result stringByAppendingString:[oriString substringWithRange:NSMakeRange(i, 1)]];
      i++;
    } else {
      i += j;
    }
  }
  
  return result;
}

#pragma mark -
#pragma mark Private Methods

- (void)initDicts {
  //
  _dictFiles = [[NSDictionary alloc] initWithObjectsAndKeys:
                [[NSMutableArray alloc] init], @"zh2TW",
                [[NSMutableArray alloc] init], @"zh2HK",
                [[NSMutableArray alloc] init], @"zh2SG",
                [[NSMutableArray alloc] init], @"zh2CN",
                nil];
  _dict = [[NSDictionary alloc] initWithObjectsAndKeys:
           [[NSMutableDictionary alloc] init], @"zh2TW",
           [[NSMutableDictionary alloc] init], @"zh2HK",
           [[NSMutableDictionary alloc] init], @"zh2SG",
           [[NSMutableDictionary alloc] init], @"zh2CN",
           nil];
  
  //
  NSBundle *mainBundle = [NSBundle mainBundle];
  NSArray *arrFiles = [mainBundle pathsForResourcesOfType:@".txt" inDirectory:@""];
  for (NSString *path in arrFiles) {
    NSString *fullFilename = path.lastPathComponent;
    NSString *mainFilename = [fullFilename substringToIndex:[fullFilename rangeOfString:@"."].location];
    
    if ([_dictFiles.allKeys containsObject:mainFilename]) {
      [_dictFiles[mainFilename] addObject:path];
    }
  }
  
  //
  for (NSString *dictType in _dictFiles.allKeys) {
    NSMutableArray *arrFiles = _dictFiles[dictType];
    if (arrFiles.count <= 0)
      continue;
    
    //
    for (NSString *filePath in arrFiles) {
      if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) continue; // File is not exist.
      
      NSError *err;
      NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&err];
      if (!content) continue; // Can't get the content of the file.
      
      NSArray *arrLines = [content componentsSeparatedByString:@"\n"];
      for (NSString *line in arrLines) {
        NSArray *arrWords = [line componentsSeparatedByString:@"\t"];
        if (arrWords.count == 2)
          [_dict[dictType] setObject:arrWords[1] forKey:arrWords[0]];
      }
    }
  }
}

@end
