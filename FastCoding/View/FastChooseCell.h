//
//  FastChooseCell.h
//  FastCoding
//
//  Created by DevDu on 16/7/12.
//  Copyright © 2016年 DevDu. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PropertyModel.h"

@interface FastChooseCell : NSTableCellView

@property (strong) IBOutlet NSTextField *propertyName1;
@property (strong) IBOutlet NSButton *getButton1;
@property (strong) IBOutlet NSButton *setButton1;
@property (strong) IBOutlet NSButton *lazyButton1;

@property (nonatomic,strong) PropertyModel * model;
@end
