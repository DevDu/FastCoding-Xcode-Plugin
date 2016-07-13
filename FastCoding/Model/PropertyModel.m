//
//  PropertyModel.m
//  TestChaJian
//
//  Created by DevDu on 16/7/8.
//  Copyright © 2016年 joybar. All rights reserved.
//

#import "PropertyModel.h"

@implementation PropertyModel


- (void)setAtomicType:(NSString *) atomicType {
    if (_atomicType != atomicType) {
        _atomicType = atomicType;
    }
}
- (void)setMemorykeyWord:(NSString *) memorykeyWord {
    if (_memorykeyWord != memorykeyWord) {
        _memorykeyWord = memorykeyWord;
    }
}
- (void)setDataType:(NSString *) dataType {
    if (_dataType != dataType) {
        _dataType = dataType;
    }
}
- (void)setName:(NSString *) name {
    if (_name != name) {
        _name = name;
    }
}
- (void)setIsOnlyRead:(BOOL ) isOnlyRead {
    if (_isOnlyRead != isOnlyRead) {
        _isOnlyRead = isOnlyRead;
    }
}
- (void)setPropertyStr:(NSString *) propertyStr {
    if (_propertyStr != propertyStr) {
        _propertyStr = propertyStr;
    }
}
- (void)setIsNeedSet:(BOOL ) isNeedSet {
    if (_isNeedSet != isNeedSet) {
        _isNeedSet = isNeedSet;
    }
}
- (void)setIsNeedGet:(BOOL ) isNeedGet {
    if (_isNeedGet != isNeedGet) {
        _isNeedGet = isNeedGet;
    }
}
- (void)setIsAleadyProduct:(BOOL ) isAleadyProduct {
    if (_isAleadyProduct != isAleadyProduct) {
        _isAleadyProduct = isAleadyProduct;
    }
}

@end
