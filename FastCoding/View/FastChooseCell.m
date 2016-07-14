//
//  FastChooseCell.m
//  FastCoding
//
//  Created by DevDu on 16/7/12.
//  Copyright © 2016年 DevDu. All rights reserved.
//

#import "FastChooseCell.h"

@implementation FastChooseCell

- (IBAction)getAction:(id)sender {
    self.lazyButton1.objectValue = @NO;
    self.setButton1.objectValue = @NO;
    self.model.isNeedSet = NO;
    self.model.isNeedLazyGet = NO;
    self.model.isNeedGet = !self.model.isNeedGet;
}

- (IBAction)setAction:(id)sender {
    self.lazyButton1.objectValue = @NO;
    self.getButton1.objectValue = @NO;
    self.model.isNeedGet = NO;
    self.model.isNeedLazyGet = NO;
    self.model.isNeedSet = ! self.model.isNeedSet;
}
- (IBAction)lazyAction:(id)sender {
    self.getButton1.objectValue = @NO;
    self.setButton1.objectValue = @NO;
    self.model.isNeedSet = NO;
    self.model.isNeedGet = NO;
    self.model.isNeedLazyGet = ! self.model.isNeedLazyGet;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    // Drawing code here.
}

@end
