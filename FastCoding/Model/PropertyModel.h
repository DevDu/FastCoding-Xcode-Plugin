//
//  PropertyModel.h
//  TestChaJian
//
//  Created by DevDu on 16/7/8.
//  Copyright © 2016年 joybar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PropertyModel : NSObject
/**
 *  原子性
 */
@property (nonatomic,strong) NSString * atomicType;
/**
 *  内存关键字
 */
@property (nonatomic,strong) NSString * memorykeyWord;
/**
 *  数据类型
 */
@property (nonatomic,strong) NSString * dataType;
/**
 *  属性名称
 */
@property (nonatomic,strong) NSString * name;

/**
 *  从哪个文件过来的
 */
@property (nonatomic,strong) NSString * fileFrom;

/**
 *  是否是只读
 */
@property (nonatomic,assign) BOOL isOnlyRead;


//展示所用的属性

/**
 *  展示的属性
 */
@property (nonatomic,strong) NSString * propertyStr;

/**
 *  是否需要set方法
 */
@property (nonatomic,assign) BOOL  isNeedSet;

/**
 *  是否需要get方法
 */
@property (nonatomic,assign) BOOL  isNeedGet;

/**
 *  是否需要懒加载get方法
 */
@property (nonatomic,assign) BOOL  isNeedLazyGet;

/**
 *  是否已经生成
 */
@property (nonatomic,assign) BOOL isAleadyProduct;


@end
