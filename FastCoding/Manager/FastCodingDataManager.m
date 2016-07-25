//
//  FastCodingDataManager.m
//  FastCoding
//
//  Created by DevDu on 16/7/12.
//  Copyright © 2016年 DevDu. All rights reserved.
//

#import "FastCodingDataManager.h"
@interface FastCodingDataManager ()

@end

@implementation FastCodingDataManager

+ (instancetype) sharedDataManager
{
    static FastCodingDataManager * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[FastCodingDataManager alloc] init];
    });
    
    return manager;
}


- (NSString *) inMfileGetHfileContentWithUrl:(NSString *) url
{
    NSError * error = nil;
    BOOL ismfile = [url hasSuffix:@".m"];
    NSString * hfilePath = @"";
    if (ismfile)
    {
        hfilePath = [[url substringToIndex:url.length - 1] stringByAppendingString:@"h"];
        NSString * pathContent = [NSString stringWithContentsOfURL:[NSURL URLWithString:hfilePath] encoding:NSUTF8StringEncoding error:&error];
        if (error==nil) return pathContent;
    }
    return @"";
}

- (NSString *) getInterfaceWithUrl:(NSString *) url
{
    NSError * error = nil;
    NSString * pathContent = [NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSUTF8StringEncoding error:&error];
    NSString * regularStr = @"@interface([\\s\\S]*?)@end";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regularStr options:0 error:nil];
    NSArray *matches = [regex matchesInString:pathContent options:0 range:NSMakeRange(0, pathContent.length)];
    
    for (int i = 0; i < matches.count; i++) {
        
        NSRange firstHalfRange = [matches[i] range];
        if (firstHalfRange.length > 0) {
            NSString *resultString1 = [pathContent substringWithRange:firstHalfRange];
            return resultString1;
        }
    }
    return @"";
}


- (void) getFilePropertysWithContent:(NSString *) content isFromfile:(NSString *) file
{
    NSString * propertyStr = content;
    NSString * regularStr = @"@property([\\s\\S]*?);";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regularStr options:0 error:nil];
    NSArray *matches = [regex matchesInString:propertyStr options:0 range:NSMakeRange(0, propertyStr.length)];
    
    for (int i = 0; i < matches.count; i++) {
        
        NSRange firstHalfRange = [matches[i] range];
        if (firstHalfRange.length > 0) {
            NSString *resultString1 = [propertyStr substringWithRange:firstHalfRange];
            NSRange range = [resultString1 rangeOfString:@"IBOutlet"];
//            if(range.location !=NSNotFound)
//            {
//                resultString1 = [resultString1 stringByReplacingOccurrencesOfString:@"IBOutlet" withString:@""];
//            }
            //如果是xib 或者 storyboard 不添加到数组
            if(range.location !=NSNotFound) continue;
            
            NSArray * keyword  =  [self getPropertysKeywordWithProperty:resultString1.mutableCopy];
            NSArray * dateType =  [self getPropertyTypeAndNameWithProperty:resultString1];
            
            if (!keyword.count || !dateType.count)  continue;
            PropertyModel * proMoel = [[PropertyModel alloc] init];
            proMoel.atomicType    = [keyword firstObject];
            proMoel.memorykeyWord = [keyword lastObject];
            proMoel.dataType      = [dateType firstObject];
            proMoel.name          = [dateType lastObject];
            NSArray * weakArray = [self weakArray];
            if (([weakArray containsObject:[keyword lastObject]]) ||
                ([weakArray containsObject:[keyword firstObject]]) ||
                [proMoel.dataType isEqualToString:@"id"])
            {
                proMoel.propertyStr = [NSString stringWithFormat:@"%@ %@",proMoel.dataType,proMoel.name];
            }
            else
            {
                proMoel.propertyStr = [NSString stringWithFormat:@"%@ * %@",proMoel.dataType,proMoel.name];
            }
            proMoel.isNeedGet = NO;
            proMoel.isNeedSet = NO;
            proMoel.isNeedLazyGet = NO;
            proMoel.fileFrom = file;

            [self.propertyArray addObject:proMoel];
        }
    }
}

- (NSString *) getFilePropertysWithContent:(NSString *) content isSetMethod:(BOOL) isSetMethod
{
    
    NSString * propertyStr = content;
    NSString * regularStr = @"@property([\\s\\S]*?);";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regularStr options:0 error:nil];
    NSArray *matches = [regex matchesInString:propertyStr options:0 range:NSMakeRange(0, propertyStr.length)];
    
    NSString * contentStr = @"";
    for (int i = 0; i < matches.count; i++) {
        NSRange firstHalfRange = [matches[i] range];
        if (firstHalfRange.length > 0) {
            NSString *resultString1 = [propertyStr substringWithRange:firstHalfRange];
            PropertyModel * proMoel = [[PropertyModel alloc] init];
            NSArray * keyword  = [self getPropertysKeywordWithProperty:resultString1.mutableCopy];
            NSArray * dateType = [self getPropertyTypeAndNameWithProperty:resultString1];
            
            if (!keyword.count || !dateType.count)  continue;

            if ([[keyword lastObject] isEqualToString:@"readonly"])
            {
                proMoel.isOnlyRead = YES;
            }
            proMoel.atomicType = [keyword firstObject];
            proMoel.memorykeyWord = [keyword lastObject];
            proMoel.dataType = [dateType firstObject];
            proMoel.name     = [dateType lastObject];
            if (isSetMethod && proMoel.isOnlyRead == NO)
            {
                NSString * strSet = [self productSetMethodWithPropertyModel:proMoel];
                contentStr = [contentStr  stringByAppendingString:strSet];
            }
            else if(isSetMethod == NO)
            {
                NSString * strSet = [self productGetMethodWithPropertyModel:proMoel];
                contentStr = [contentStr  stringByAppendingString:strSet];
            }
        }
    }
    return contentStr;
    
}

- (NSArray *) getPropertysKeywordWithProperty:(NSString *)propertyStr
{
    //MRC 下需要截取关键字
    NSString * propertyStr1 = propertyStr;
    NSString * regularStr = @"\\(.*\\)";
    NSRegularExpression *regex1 = [NSRegularExpression regularExpressionWithPattern:regularStr options:0 error:nil];
    NSArray *matches1 = [regex1 matchesInString:propertyStr1 options:0 range:NSMakeRange(0, propertyStr1.length)];
    
    for (int i = 0; i < matches1.count; i++)
    {
        NSRange firstHalfRange = [matches1[i] range];
        if (firstHalfRange.length > 0)
        {
            NSString *resultString1 = [[propertyStr1 substringWithRange:firstHalfRange] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            resultString1 = [resultString1 stringByReplacingOccurrencesOfString:@" " withString:@""];
            //去头
            NSString * deleteHead = [resultString1 substringFromIndex:1];
            //去尾
            NSString * deleteEnd  = [deleteHead substringToIndex:deleteHead.length - 1];
            return  [deleteEnd componentsSeparatedByString:@","];
        }
    }
    return nil;
}


- (NSMutableArray *) getPropertyTypeAndNameWithProperty:(NSString *) propertyStr;
{
    //取出类型 和 对象名称
    NSString * propertyStr1 = propertyStr;
    NSString * regularStr = @"\\).*\\;";
    NSRegularExpression *regex1 = [NSRegularExpression regularExpressionWithPattern:regularStr options:0 error:nil];
    NSArray *matches1 = [regex1 matchesInString:propertyStr1 options:0 range:NSMakeRange(0, propertyStr1.length)];
    NSMutableArray * gjsArr = @[].mutableCopy;
    for (int i = 0 ; i < matches1.count; i++) {
        NSRange firstHalfRange =   [matches1[i] range];
        if (firstHalfRange.length > 0)
        {
            //去除两端空格
            NSString *resultString1 = [[propertyStr1 substringWithRange:firstHalfRange] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            //去头
            NSString * deleteHead = [resultString1 substringFromIndex:1];
            //去尾
            NSString * deleteEnd  = [deleteHead substringToIndex:deleteHead.length - 1];
            if([propertyStr1 rangeOfString:@"*"].location !=NSNotFound)
            {
                //去除中间空格
                deleteEnd = [deleteEnd stringByReplacingOccurrencesOfString:@" " withString:@""];
                gjsArr =  [deleteEnd componentsSeparatedByString:@"*"].mutableCopy;
            }
            else
            {
                gjsArr =  [deleteEnd componentsSeparatedByString:@" "].mutableCopy;
                [gjsArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj isEqualToString:@""]) {
                        [gjsArr removeObject:obj];
                    }
                }];
            }
            return gjsArr;
        }
    }
    return gjsArr;
    
}
/**
 *  弱引用数组
 */
- (NSArray *) weakArray
{
  return @[@"assign",
           @"weak"];
}
//set
- (NSString *) productSetMethodWithPropertyModel:(PropertyModel *) model
{
    NSArray * weakArray = [self weakArray];
    
    NSArray * typeArray = @[@"id"];
    
    NSArray * specArray = @[@"CGRect",
                            @"CGPoint",
                            @"CGSize"];
    
    NSString * capitalName =  [[[model.name substringToIndex:1] uppercaseString] stringByAppendingString:[model.name substringFromIndex:1]];
    
    NSString * setMethodStr = [NSString stringWithFormat:@"\n- (void)set%@:(%@ *) %@ {\n    if (_%@ != %@) {\n        _%@ = %@;\n    }\n}",
                               capitalName,
                               model.dataType,
                               model.name,
                               model.name,
                               model.name,
                               model.name,
                               model.name];
    if ([specArray containsObject:model.dataType])
    {
        
        NSString * name = [model.dataType substringFromIndex:2];
        //CGSizeEqualToSize
        NSString * methodName = [NSString stringWithFormat:@"%@EqualTo%@",model.dataType,name];
        setMethodStr = [NSString stringWithFormat:@"\n- (void)set%@:(%@ ) %@ {\n    if (!%@(_%@,%@)) {\n        _%@ = %@;\n    }\n}",
                        capitalName,
                        model.dataType,
                        model.name,
                        methodName,
                        model.name,
                        model.name,
                        model.name,
                        model.name];
        
        return setMethodStr;
        
    }
    else
        if ([weakArray containsObject:model.memorykeyWord]
            || [weakArray containsObject:model.atomicType]
            || [typeArray containsObject:model.dataType])
        {
            setMethodStr = [NSString stringWithFormat:@"\n- (void)set%@:(%@) %@ {\n    if (_%@ != %@) {\n        _%@ = %@;\n    }\n}",
                            capitalName,
                            model.dataType,
                            model.name,
                            model.name,
                            model.name,
                            model.name,
                            model.name];
        }
    
    return setMethodStr;
}
//get
- (NSString *) productGetMethodWithPropertyModel:(PropertyModel *) model
{
    NSArray * weakArray = [self weakArray];
    NSArray * typeArray = @[@"id"];
    NSString *  setMethodStr = @"";
    if ([weakArray containsObject:model.memorykeyWord]
        || [weakArray containsObject:model.atomicType]
        || [typeArray containsObject:model.dataType]) {
        setMethodStr = [NSString stringWithFormat:@"\n- (%@)%@ {\n   return _%@;\n}",
                        model.dataType,
                        model.name,
                        model.name];
    }
    else
    {
        setMethodStr = [NSString stringWithFormat:@"\n- (%@ *)%@ {\n   return _%@;\n}",
                        model.dataType,
                        model.name,
                        model.name];
    }
    return setMethodStr;
}

//get lazy
- (NSString *) productGetLazyMethodWithPropertyModel:(PropertyModel *) model
{
    NSArray * weakArray = [self weakArray];
    NSArray * typeArray = @[@"id"];
    NSString *  setMethodStr = @"";
    if (![weakArray containsObject:model.memorykeyWord] || ![typeArray containsObject:model.dataType]) {
        setMethodStr = [NSString stringWithFormat:@"\n- (%@ *)%@ {\n	if (_%@ == nil) {\n        _%@ = [[%@ alloc] init];\n	}\n	return _%@;\n}",
                        model.dataType,
                        model.name,
                        model.name,
                        model.name,
                        model.dataType,
                        model.name];
    }
    return setMethodStr;
}

@end
