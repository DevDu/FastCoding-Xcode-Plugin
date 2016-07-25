//
//  FastCodingDataManager.h
//  FastCoding
//
//  Created by DevDu on 16/7/12.
//  Copyright © 2016年 DevDu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PropertyModel.h"

@interface FastCodingDataManager : NSObject


@property (nonatomic,strong) NSMutableArray * propertyArray;


- (NSArray *) weakArray;
+ (instancetype) sharedDataManager;

- (NSString *) inMfileGetHfileContentWithUrl:(NSString *) url;


- (NSString *) getInterfaceWithUrl:(NSString *) url;
- (void) getFilePropertysWithContent:(NSString *) content isFromfile:(NSString *) file;
//all 
- (NSString *) getFilePropertysWithContent:(NSString *) content isSetMethod:(BOOL) isSetMethod;

- (NSArray *) getPropertysKeywordWithProperty:(NSString *)propertyStr;
- (NSMutableArray *) getPropertyTypeAndNameWithProperty:(NSString *) propertyStr;


- (NSString *) productSetMethodWithPropertyModel:(PropertyModel *) model;
- (NSString *) productGetMethodWithPropertyModel:(PropertyModel *) model;
- (NSString *) productGetLazyMethodWithPropertyModel:(PropertyModel *) model;
@end
