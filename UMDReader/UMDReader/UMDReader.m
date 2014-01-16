//
//  UMDReader.m
//  
//
//  Created by yjh4866 on 13-3-4.
//  Copyright (c) 2013年 CocoaChina. All rights reserved.
//

#import "UMDReader.h"
#import "zlib.h"

@interface UMDReader () {
    
    NSMutableArray *_marrChapterTitle;
    NSMutableArray *_marrChapter;
    NSMutableArray *_marrCartoonData;
    
    NSMutableArray *_marrChapterLen;
    NSMutableData *_mdataArticle;
    NSString *_bookName;
}

@end

@implementation UMDReader

@synthesize bookName = _bookName;
@synthesize titles = _marrChapterTitle;
@synthesize chapters = _marrChapter;
@synthesize cartoonsData = _marrCartoonData;

- (id)init
{
    self = [super init];
    if (self) {
        _marrChapterLen = [[NSMutableArray alloc] init];
        _marrChapterTitle = [[NSMutableArray alloc] init];
        _marrChapter = [[NSMutableArray alloc] init];
        _marrCartoonData = [[NSMutableArray alloc] init];
        _mdataArticle = [[NSMutableData alloc] init];
        //
        [self addObserver:self forKeyPath:@"self.filePath" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"self.filePath" context:nil];
    //
    [_filePath release];
    [_bookName release];
    [_author release];
    [_titlePage release];
    [_year release];
    [_month release];
    [_day release];
    [_articleType release];
    [_publishers release];
    [_dealer release];
    //
    [_marrChapterLen release];
    [_marrChapterTitle release];
    [_marrChapter release];
    [_marrCartoonData release];
    [_mdataArticle release];
    
    [super dealloc];
}


#pragma mark - NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"self.filePath"]) {
        NSString *fileExtension = [[self.filePath pathExtension] lowercaseString];
        if (![fileExtension isEqualToString:@"umd"]) {
            return;
        }
        //
        [_marrChapterTitle removeAllObjects];
        [_marrChapterLen removeAllObjects];
        [_marrChapter removeAllObjects];
        [_marrCartoonData removeAllObjects];
        //
        NSData *fileData = [[NSData alloc] initWithContentsOfFile:self.filePath];
        if (fileData.length > 0) {
            [_mdataArticle setData:nil];
            [self parseFileData:fileData];
        }
        [fileData release];
    }
}


#pragma mark - ()

- (void)parseFileData:(NSData *)fileData
{
    //看文件头是否符合要求
    UInt32 fileTypeCode;
    NSRange rangeTypeCode = NSMakeRange(0, 4);
    [fileData getBytes:&fileTypeCode range:rangeTypeCode];
    if (0xde9a9b89 != fileTypeCode) {
        return;
    }
    //
    UInt8 blockType;
    UInt16 dataType;
    BOOL chapterTitleFinished = NO;
    NSRange rangeBlockType = NSMakeRange(4, 1);
    while (rangeBlockType.location < fileData.length) {
        [fileData getBytes:&blockType range:rangeBlockType];
        if (0x23 == blockType) {
            //
            NSRange rangeDataType = NSMakeRange(rangeBlockType.location+1, 2);
            [fileData getBytes:&dataType range:rangeDataType];
            switch (dataType) {
                case 0x0001:
                {
                    UInt8 bookType;
                    NSRange rangeData = NSMakeRange(rangeDataType.location+2+2, 1);
                    [fileData getBytes:&bookType range:rangeData];
                    _isCartoon = bookType==2;
                    //
                    rangeBlockType.location = rangeData.location+1+2;
                }
                    break;
                case 0x0002:
                {
                    //查看数据长度
                    UInt8 dataLength;
                    NSRange rangeDataLength = NSMakeRange(rangeDataType.location+2+1, 1);
                    [fileData getBytes:&dataLength range:rangeDataLength];
                    //取数据
                    NSRange rangeData = NSMakeRange(rangeDataLength.location+1, dataLength-5);
                    NSData *blockData = [fileData subdataWithRange:rangeData];
                    //UNICODE编码
                    UInt16 bom = 0xfeff;
                    NSMutableData *mdataBlock = [NSMutableData dataWithBytes:&bom length:2];
                    [mdataBlock appendData:blockData];
                    //书名
                    [_bookName release];
                    _bookName = [[NSString alloc] initWithData:mdataBlock
                                                      encoding:NSUnicodeStringEncoding];
                    //
                    rangeBlockType.location += dataLength;
                }
                    break;
                case 0x0003:
                {
                    //查看数据长度
                    UInt8 dataLength;
                    NSRange rangeDataLength = NSMakeRange(rangeDataType.location+2+1, 1);
                    [fileData getBytes:&dataLength range:rangeDataLength];
                    //取数据
                    NSRange rangeData = NSMakeRange(rangeDataLength.location+1, dataLength-5);
                    NSData *blockData = [fileData subdataWithRange:rangeData];
                    //UNICODE编码
                    UInt16 bom = 0xfeff;
                    NSMutableData *mdataBlock = [NSMutableData dataWithBytes:&bom length:2];
                    [mdataBlock appendData:blockData];
                    //作者
                    [_author release];
                    _author = [[NSString alloc] initWithData:mdataBlock
                                                    encoding:NSUnicodeStringEncoding];
                    //
                    rangeBlockType.location += dataLength;
                }
                    break;
                case 0x0004:
                {
                    //查看数据长度
                    UInt8 dataLength;
                    NSRange rangeDataLength = NSMakeRange(rangeDataType.location+2+1, 1);
                    [fileData getBytes:&dataLength range:rangeDataLength];
                    //取数据
                    NSRange rangeData = NSMakeRange(rangeDataLength.location+1, dataLength-5);
                    NSData *blockData = [fileData subdataWithRange:rangeData];
                    //UNICODE编码
                    UInt16 bom = 0xfeff;
                    NSMutableData *mdataBlock = [NSMutableData dataWithBytes:&bom length:2];
                    [mdataBlock appendData:blockData];
                    //年
                    [_year release];
                    _year = [[NSString alloc] initWithData:mdataBlock
                                                  encoding:NSUnicodeStringEncoding];
                    //
                    rangeBlockType.location += dataLength;
                }
                    break;
                case 0x0005:
                {
                    //查看数据长度
                    UInt8 dataLength;
                    NSRange rangeDataLength = NSMakeRange(rangeDataType.location+2+1, 1);
                    [fileData getBytes:&dataLength range:rangeDataLength];
                    //取数据
                    NSRange rangeData = NSMakeRange(rangeDataLength.location+1, dataLength-5);
                    NSData *blockData = [fileData subdataWithRange:rangeData];
                    //UNICODE编码
                    UInt16 bom = 0xfeff;
                    NSMutableData *mdataBlock = [NSMutableData dataWithBytes:&bom length:2];
                    [mdataBlock appendData:blockData];
                    //月
                    [_month release];
                    _month = [[NSString alloc] initWithData:mdataBlock
                                                   encoding:NSUnicodeStringEncoding];
                    //
                    rangeBlockType.location += dataLength;
                }
                    break;
                case 0x0006:
                {
                    //查看数据长度
                    UInt8 dataLength;
                    NSRange rangeDataLength = NSMakeRange(rangeDataType.location+2+1, 1);
                    [fileData getBytes:&dataLength range:rangeDataLength];
                    //取数据
                    NSRange rangeData = NSMakeRange(rangeDataLength.location+1, dataLength-5);
                    NSData *blockData = [fileData subdataWithRange:rangeData];
                    //UNICODE编码
                    UInt16 bom = 0xfeff;
                    NSMutableData *mdataBlock = [NSMutableData dataWithBytes:&bom length:2];
                    [mdataBlock appendData:blockData];
                    //日
                    [_day release];
                    _day = [[NSString alloc] initWithData:mdataBlock
                                                 encoding:NSUnicodeStringEncoding];
                    //
                    rangeBlockType.location += dataLength;
                }
                    break;
                case 0x0007:
                {
                    //查看数据长度
                    UInt8 dataLength;
                    NSRange rangeDataLength = NSMakeRange(rangeDataType.location+2+1, 1);
                    [fileData getBytes:&dataLength range:rangeDataLength];
                    //取数据
                    NSRange rangeData = NSMakeRange(rangeDataLength.location+1, dataLength-5);
                    NSData *blockData = [fileData subdataWithRange:rangeData];
                    //UNICODE编码
                    UInt16 bom = 0xfeff;
                    NSMutableData *mdataBlock = [NSMutableData dataWithBytes:&bom length:2];
                    [mdataBlock appendData:blockData];
                    //图书类型
                    [_articleType release];
                    _articleType = [[NSString alloc] initWithData:mdataBlock
                                                         encoding:NSUnicodeStringEncoding];
                    //
                    rangeBlockType.location += dataLength;
                }
                    break;
                case 0x0008:
                {
                    //查看数据长度
                    UInt8 dataLength;
                    NSRange rangeDataLength = NSMakeRange(rangeDataType.location+2+1, 1);
                    [fileData getBytes:&dataLength range:rangeDataLength];
                    //取数据
                    NSRange rangeData = NSMakeRange(rangeDataLength.location+1, dataLength-5);
                    NSData *blockData = [fileData subdataWithRange:rangeData];
                    //UNICODE编码
                    UInt16 bom = 0xfeff;
                    NSMutableData *mdataBlock = [NSMutableData dataWithBytes:&bom length:2];
                    [mdataBlock appendData:blockData];
                    //出版商
                    [_publishers release];
                    _publishers = [[NSString alloc] initWithData:mdataBlock
                                                        encoding:NSUnicodeStringEncoding];
                    //
                    rangeBlockType.location += dataLength;
                }
                    break;
                case 0x0009:
                {
                    //查看数据长度
                    UInt8 dataLength;
                    NSRange rangeDataLength = NSMakeRange(rangeDataType.location+2+1, 1);
                    [fileData getBytes:&dataLength range:rangeDataLength];
                    //取数据
                    NSRange rangeData = NSMakeRange(rangeDataLength.location+1, dataLength-5);
                    NSData *blockData = [fileData subdataWithRange:rangeData];
                    //UNICODE编码
                    UInt16 bom = 0xfeff;
                    NSMutableData *mdataBlock = [NSMutableData dataWithBytes:&bom length:2];
                    [mdataBlock appendData:blockData];
                    //零售商
                    [_dealer release];
                    _dealer = [[NSString alloc] initWithData:mdataBlock
                                                    encoding:NSUnicodeStringEncoding];
                    //
                    rangeBlockType.location += dataLength;
                }
                    break;
                case 0x000b:
                {
                    //查看数据长度，其实是固定的，四个字节
                    UInt8 dataLength;
                    NSRange rangeDataLength = NSMakeRange(rangeDataType.location+2+1, 1);
                    [fileData getBytes:&dataLength range:rangeDataLength];
                    //文章长度
                    NSRange rangeData = NSMakeRange(rangeDataLength.location+1, dataLength-5);
                    [fileData getBytes:&_articleLength range:rangeData];
                    //
                    rangeBlockType.location += dataLength;
                }
                    break;
                case 0x0081:
                {
                    //正文写入完毕，裁剪出各章节
                    NSUInteger startPos = 0;
                    [_marrChapterLen addObject:[NSNumber numberWithInt:_mdataArticle.length]];
                    for (int i = 1; i < _marrChapterLen.count; i++) {
                        NSUInteger endPos = [[_marrChapterLen objectAtIndex:i] intValue];
                        NSRange rangeChapter = NSMakeRange(startPos, endPos-startPos);
                        NSData *chapterData = [_mdataArticle subdataWithRange:rangeChapter];
                        //UNICODE编码
                        UInt16 bom = 0xfeff;
                        NSMutableData *mdataChapter = [NSMutableData dataWithBytes:&bom length:2];
                        [mdataChapter appendData:chapterData];
                        NSString *chapter = [[NSString alloc] initWithData:mdataChapter encoding:NSUnicodeStringEncoding];
                        //去掉首尾的换行符
                        NSCharacterSet *spaceSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
                        NSString *chapterText = [chapter stringByTrimmingCharactersInSet:spaceSet];
                        //将章节标题加到章节内容最前面
                        //（在这里处理最简单，如果需要将标题与内容区别显示，则需注掉以下代码，在UI处理中区别显示）
                        {
                            NSString *chapterTitle = [_marrChapterTitle objectAtIndex:i-1];
                            chapterTitle = [chapterTitle stringByAppendingString:@"\r\n\r\n"];
                            chapterText = [chapterTitle stringByAppendingString:chapterText];
                        }
                        [_marrChapter addObject:chapterText];
                        [chapter release];
                        startPos = endPos;
                    }
                    [_mdataArticle setData:nil];
                    
                    //查看数据长度
                    UInt8 dataLength;
                    NSRange rangeDataLength = NSMakeRange(rangeDataType.location+2+1, 1);
                    [fileData getBytes:&dataLength range:rangeDataLength];
                    //
                    rangeBlockType.location += dataLength;
                }
                    break;
                case 0x000a:
                case 0x000c:
                case 0x000e:
                case 0x0082:
                case 0x0083:
                case 0x0084:
                case 0x0087:
                case 0x00f1:
                default:
                {
                    //查看数据长度
                    UInt8 dataLength;
                    NSRange rangeDataLength = NSMakeRange(rangeDataType.location+2+1, 1);
                    [fileData getBytes:&dataLength range:rangeDataLength];
                    //
                    rangeBlockType.location += dataLength;
                }
                    break;
            }
        }
        else if (0x24 == blockType) {
            //
            switch (dataType) {
                case 0x000a:
                case 0x0084:
                case 0x00f1:
                {
                    UInt32 dataLength;
                    NSRange rangeData = NSMakeRange(rangeBlockType.location+1+4, 4);
                    [fileData getBytes:&dataLength range:rangeData];
                    //
                    if (chapterTitleFinished) {
                        //
                        rangeData = NSMakeRange(rangeData.location+4, dataLength-9);
                        NSData *compressData = [fileData subdataWithRange:rangeData];
                        NSData *articleData = [self uncompress:compressData];
                        [_mdataArticle appendData:articleData];
                    }
                    else {
                        //读取各章节标题
                        UInt8 titleLen = 0;//章节标题长度
                        rangeData.location += 4;
                        for (UInt32 i = 0; i < _chapterCount; i++) {
                            rangeData.location += titleLen;
                            rangeData.length = 1;
                            [fileData getBytes:&titleLen range:rangeData];
                            //取数据
                            rangeData.location += 1;
                            rangeData.length = titleLen;
                            NSData *titleData = [fileData subdataWithRange:rangeData];
                            //UNICODE编码
                            UInt16 bom = 0xfeff;
                            NSMutableData *mdataTitle = [NSMutableData dataWithBytes:&bom length:2];
                            [mdataTitle appendData:titleData];
                            NSString *title = [[NSString alloc] initWithData:mdataTitle encoding:NSUnicodeStringEncoding];
                            [_marrChapterTitle addObject:title];
                            [title release];
                        }
                        chapterTitleFinished = YES;
                    }
                    //
                    rangeBlockType.location += dataLength;
                }
                    break;
                case 0x000e:
                {
                    UInt32 dataLength;
                    NSRange rangeData = NSMakeRange(rangeBlockType.location+1+4, 4);
                    [fileData getBytes:&dataLength range:rangeData];
                    //
                    rangeData = NSMakeRange(rangeData.location+4, dataLength-9);
                    NSData *picData = [fileData subdataWithRange:rangeData];
                    [_marrCartoonData addObject:picData];
                    //
                    rangeBlockType.location += dataLength;
                }
                    break;
                case 0x0082:
                {
                    UInt32 dataLength;
                    NSRange rangeData = NSMakeRange(rangeBlockType.location+1+4, 4);
                    [fileData getBytes:&dataLength range:rangeData];
                    //封面图片数据
                    rangeData = NSMakeRange(rangeData.location+4, dataLength-9);
                    NSData *data = [fileData subdataWithRange:rangeData];
                    //封面图片
                    [_titlePage release];
                    _titlePage = [[UIImage alloc] initWithData:data];
                    //
                    rangeBlockType.location += dataLength;
                }
                    break;
                case 0x0083:
                {
                    UInt32 dataLength;
                    NSRange rangeData = NSMakeRange(rangeBlockType.location+1+4, 4);
                    [fileData getBytes:&dataLength range:rangeData];
                    //章节数
                    _chapterCount = (dataLength-9)/4;
                    //各章节长度
                    UInt32 chapterLen;
                    for (UInt32 i = 0; i < _chapterCount; i++) {
                        rangeData.location += 4;
                        [fileData getBytes:&chapterLen range:rangeData];
                        [_marrChapterLen addObject:[NSNumber numberWithInt:chapterLen]];
                    }
                    //
                    rangeBlockType.location += dataLength;
                }
                    break;
                case 0x0081:
                case 0x0087:
                default:
                {
                    UInt32 dataLength;
                    NSRange rangeData = NSMakeRange(rangeBlockType.location+1+4, 4);
                    [fileData getBytes:&dataLength range:rangeData];
                    //
                    rangeBlockType.location += dataLength;
                }
                    break;
            }
        }
        else {
            NSLog(@"UMD图书数据错误");
            break;
        }
    }
#ifdef DEBUG
    NSLog(@"文件%@ 解析完成", [self.filePath lastPathComponent]);
#endif
}

- (NSData *)uncompress:(NSData *)zlibData
{
    if ([zlibData length] == 0) return zlibData;
    
    unsigned full_length = [zlibData length];
    unsigned half_length = [zlibData length] / 2;
    
    NSMutableData *decompressed = [NSMutableData dataWithLength: full_length + half_length];
    BOOL done = NO;
    int status;
    
    z_stream strm;
    strm.next_in = (Bytef *)[zlibData bytes];
    strm.avail_in = [zlibData length];
    strm.total_out = 0;
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    
    if (inflateInit (&strm) != Z_OK) return nil;
    
    while (!done)
    {
        // Make sure we have enough room and reset the lengths.
        if (strm.total_out >= [decompressed length])
            [decompressed increaseLengthBy: half_length];
        strm.next_out = [decompressed mutableBytes] + strm.total_out;
        strm.avail_out = [decompressed length] - strm.total_out;
        
        // Inflate another chunk.
        status = inflate (&strm, Z_SYNC_FLUSH);
        if (status == Z_STREAM_END) done = YES;
        else if (status != Z_OK) break;
    }
    if (inflateEnd (&strm) != Z_OK) return nil;
    
    // Set real length.
    if (done)
    {
        [decompressed setLength: strm.total_out];
        return [NSData dataWithData: decompressed];
    }
    else return nil;
}

@end
