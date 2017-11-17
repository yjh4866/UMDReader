//
//  ViewController.m
//  UMDReader
//
//  Created by yangjh on 14-1-16.
//  Copyright (c) 2014年 yangjh. All rights reserved.
//

#import "ViewController.h"
#import "UMDReader.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    UMDReader *reader = [[UMDReader alloc] init];
    reader.filePath = [[NSBundle mainBundle] pathForResource:@"201101101441122136" ofType:@"umd"];
    NSLog(@"书名：%@", reader.bookName);
    NSLog(@"章节标题：");
    for (NSString *title in reader.titles) {
        NSLog(@"%@", title);
    }
    NSLog(@"------------------");
    reader.filePath = [[NSBundle mainBundle] pathForResource:@"201101110809472321" ofType:@"umd"];
    NSLog(@"书名：%@", reader.bookName);
    NSLog(@"章节标题：");
    for (NSString *title in reader.titles) {
        NSLog(@"%@", title);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
