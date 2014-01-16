//
//  UMDReader.h
//  
//
//  Created by yjh4866 on 13-3-4.
//  Copyright (c) 2013年 CocoaChina. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UMDReader : NSObject

@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, readonly) BOOL isCartoon;
@property (nonatomic, readonly) NSString *bookName;
@property (nonatomic, readonly) NSString *author;
@property (nonatomic, readonly) UIImage *titlePage;
@property (nonatomic, readonly) NSString *year;
@property (nonatomic, readonly) NSString *month;
@property (nonatomic, readonly) NSString *day;
@property (nonatomic, readonly) NSString *articleType;
@property (nonatomic, readonly) NSString *publishers;
@property (nonatomic, readonly) NSString *dealer;
@property (nonatomic, readonly) NSUInteger articleLength;
@property (nonatomic, readonly) NSUInteger chapterCount;
@property (nonatomic, readonly) NSArray *titles;
@property (nonatomic, readonly) NSArray *chapters;
@property (nonatomic, readonly) NSArray *cartoonsData;

@end
