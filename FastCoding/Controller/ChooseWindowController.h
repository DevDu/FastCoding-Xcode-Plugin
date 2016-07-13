//
//  ChooseWindowController.h
//  PlugunTest
//
//  Created by DevDu on 16/7/8.
//  Copyright © 2016年 joybar. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ChooseWindowController : NSWindowController
<NSTableViewDelegate,NSTableViewDataSource>

@property (strong) IBOutlet NSTableView *tableView;

@end
