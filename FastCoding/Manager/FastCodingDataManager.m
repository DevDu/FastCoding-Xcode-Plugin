//
//  FastCodingDataManager.m
//  FastCoding
//
//  Created by DevDu on 16/7/12.
//  Copyright © 2016年 DevDu. All rights reserved.
//

#import "FastCodingDataManager.h"

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


- (void) getFilePropertysWithContent:(NSString *) content
{
    NSString * shuxing = content;
    NSString * zhengze = @"@property([\\s\\S]*?);";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:zhengze options:0 error:nil];
    NSArray *matches = [regex matchesInString:shuxing options:0 range:NSMakeRange(0, shuxing.length)];
    
    self.propertyArray = [NSMutableArray array];
    for (int i = 0; i < matches.count; i++) {
        
        NSRange firstHalfRange = [matches[i] range];
        if (firstHalfRange.length > 0) {
            NSString *resultString1 = [shuxing substringWithRange:firstHalfRange];
            NSRange range = [resultString1 rangeOfString:@"IBOutlet"];
            if(range.location !=NSNotFound)
            {
                resultString1 = [resultString1 stringByReplacingOccurrencesOfString:@"IBOutlet" withString:@""];
            }
            
            NSArray * keyword=   [self getPropertysKeywordWithProperty:resultString1.mutableCopy];
            NSArray * dateType =  [self getPropertyTypeAndNameWithProperty:resultString1];
            PropertyModel * proMoel = [[PropertyModel alloc] init];
            proMoel.atomicType = [keyword firstObject];
            proMoel.memorykeyWord = [keyword lastObject];
            proMoel.dataType = [dateType firstObject];
            proMoel.name     = [dateType lastObject];
            
            NSArray * weakArray = @[@"assign",
                                    @"weak"];
            if (([weakArray containsObject:[keyword lastObject]]) || [proMoel.dataType isEqualToString:@"id"])
            {
                proMoel.propertyStr = [NSString stringWithFormat:@"%@ %@",proMoel.dataType,proMoel.name];
            }
            else
            {
                proMoel.propertyStr = [NSString stringWithFormat:@"%@ * %@",proMoel.dataType,proMoel.name];
            }
            proMoel.isNeedGet = NO;
            proMoel.isNeedSet = NO;
            [self.propertyArray addObject:proMoel];
            
        }
    }
}

- (NSString *) getFilePropertysWithContent:(NSString *) content isSetMethod:(BOOL) isSetMethod
{
    
    NSString * shuxing = content;
    NSString * zhengze = @"@property([\\s\\S]*?);";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:zhengze options:0 error:nil];
    NSArray *matches = [regex matchesInString:shuxing options:0 range:NSMakeRange(0, shuxing.length)];
    
    NSString * contentStr = @"";
    for (int i = 0; i < matches.count; i++) {
        NSRange firstHalfRange = [matches[i] range];
        if (firstHalfRange.length > 0) {
            NSString *resultString1 = [shuxing substringWithRange:firstHalfRange];
            PropertyModel * proMoel = [[PropertyModel alloc] init];
            NSArray * keyword  = [self getPropertysKeywordWithProperty:resultString1.mutableCopy];
            NSArray * dateType = [self getPropertyTypeAndNameWithProperty:resultString1];            
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
    NSString * shuxing1 = propertyStr;
    NSString * zhengze1 = @"\\(.*\\)";
    NSRegularExpression *regex1 = [NSRegularExpression regularExpressionWithPattern:zhengze1 options:0 error:nil];
    NSArray *matches1 = [regex1 matchesInString:shuxing1 options:0 range:NSMakeRange(0, shuxing1.length)];
    
    for (int i = 0; i < matches1.count; i++)
    {
        NSRange firstHalfRange = [matches1[i] range];
        if (firstHalfRange.length > 0)
        {
            NSString *resultString1 = [[shuxing1 substringWithRange:firstHalfRange] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
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
    NSString * shuxing1 = propertyStr;
    NSString * zhengze1 = @"\\).*\\;";
    NSRegularExpression *regex1 = [NSRegularExpression regularExpressionWithPattern:zhengze1 options:0 error:nil];
    NSArray *matches1 = [regex1 matchesInString:shuxing1 options:0 range:NSMakeRange(0, shuxing1.length)];
    NSMutableArray * gjsArr = @[].mutableCopy;
    for (int i = 0 ; i < matches1.count; i++) {
        NSRange firstHalfRange =   [matches1[i] range];
        if (firstHalfRange.length > 0)
        {
            //去除两端空格
            NSString *resultString1 = [[shuxing1 substringWithRange:firstHalfRange] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            //去头
            NSString * deleteHead = [resultString1 substringFromIndex:1];
            //去尾
            NSString * deleteEnd  = [deleteHead substringToIndex:deleteHead.length - 1];
            if([shuxing1 rangeOfString:@"*"].location !=NSNotFound)
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
//set
- (NSString *) productSetMethodWithPropertyModel:(PropertyModel *) model
{
    NSArray * weakArray = @[@"assign",
                            @"weak"];
    
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
        if ([weakArray containsObject:model.memorykeyWord] || [typeArray containsObject:model.dataType])
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
    NSArray * weakArray = @[@"assign",
                            @"weak"];
    NSArray * typeArray = @[@"id"];
    NSString *  setMethodStr = @"";
    if ([weakArray containsObject:model.memorykeyWord] || [typeArray containsObject:model.dataType]) {
        setMethodStr = [NSString stringWithFormat:@"\n- (%@)%@\n{\n   return _%@;\n}",model.dataType,model.name,model.name];
    }
    else
    {
        setMethodStr = [NSString stringWithFormat:@"\n- (%@ *)%@\n{\n   return _%@;\n}",model.dataType,model.name,model.name];
    }
    return setMethodStr;
}

@end
