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
    self.setButton1.objectValue = @NO;
    self.model.isNeedSet = NO;
    self.model.isNeedGet = !self.model.isNeedGet;
}

- (IBAction)setAction:(id)sender {
    self.getButton1.objectValue = @NO;
    self.model.isNeedGet = NO;
    self.model.isNeedSet = ! self.model.isNeedSet;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    // Drawing code here.
}

@end
