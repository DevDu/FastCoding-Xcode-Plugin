//
//  FastCoding.h
//  FastCoding
//
//  Created by DevDu on 16/7/12.
//  Copyright © 2016年 DevDu. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "ChooseWindowController.h"
#import "PropertyModel.h"
@interface FastCoding : NSObject

+ (instancetype)sharedPlugin;


@property (nonatomic, copy) NSString *currentFilePath;
@property (nonatomic) NSTextView *currentTextView;
@property (nonatomic,strong) NSString * currentFileContent;
@property (nonatomic,strong, readonly) NSBundle* bundle;
@property (nonatomic,strong) ChooseWindowController * chooseWindow;


@end