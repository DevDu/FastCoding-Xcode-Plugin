//
//  ChooseWindowController.m
//  PlugunTest
//
//  Created by DevDu on 16/7/8.
//  Copyright © 2016年 joybar. All rights reserved.
//

#import "ChooseWindowController.h"
#import "FastChooseCell.h"
#import "FastCodingDataManager.h"
#import "FastCoding.h"
#import "PropertyModel.h"
@interface ChooseWindowController ()

@property (nonatomic,strong) NSArray * dataArray;

@end

@implementation ChooseWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    FastCodingDataManager * shareManager = [FastCodingDataManager sharedDataManager];
    NSString * content = [shareManager inMfileGetHfileContentWithUrl:[FastCoding sharedPlugin].currentFilePath];
    [shareManager getFilePropertysWithContent:content];
    self.dataArray = shareManager.propertyArray;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleNone];
    
    NSBundle * currentBundle = [NSBundle bundleWithIdentifier:@"DevDu.FastCoding"];
    [self.tableView registerNib:[[NSNib alloc] initWithNibNamed:@"FastChooseCell"
                                                         bundle:currentBundle] forIdentifier:@"FastChooseCell"];
}
- (IBAction)productAction:(id)sender {
    NSString * contentStr = @"";
    for (int i = 0; i < self.dataArray.count; i++)
    {
        PropertyModel * model = self.dataArray[i];
        //如果还没有生成的
        if (!model.isAleadyProduct)
        {
            if ((model.isNeedSet == NO) && (model.isNeedGet == NO))
            {
                continue;
            }
            if (model.isNeedSet)
            {
                NSString * strSet =   [[FastCodingDataManager sharedDataManager] productSetMethodWithPropertyModel:model];
                model.isAleadyProduct = YES;
                contentStr = [contentStr  stringByAppendingString:strSet];
            }
            else  if (model.isNeedGet)
            {
                NSString * strSet =   [[FastCodingDataManager sharedDataManager] productGetMethodWithPropertyModel:model];
                model.isAleadyProduct = YES;
                contentStr = [contentStr  stringByAppendingString:strSet];
            }
        }
    }
    
    NSTextView * currentTextView = [FastCoding sharedPlugin].currentTextView;
    [currentTextView insertText:contentStr replacementRange:currentTextView.rangeForUserCompletion];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.dataArray.count;
}
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row
{
    FastChooseCell * cell = [tableView makeViewWithIdentifier:@"FastChooseCell" owner:nil];
    cell.setButton1.tag = row*10;
    cell.getButton1.tag = row;
    PropertyModel * model = self.dataArray[row];
    cell.model = model;
    cell.propertyName1.stringValue = model.propertyStr;
    cell.getButton1.objectValue = @(model.isNeedGet);
    cell.setButton1.objectValue = @(model.isNeedSet);
    return cell;
}
- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return 35;
}

@end
