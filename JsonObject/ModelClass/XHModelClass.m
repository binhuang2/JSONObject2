//
//  XHModelClass.m
//  JsonObject
//
//  Created by 黄斌 on 2018/9/10.
//  Copyright © 2018年 黄斌. All rights reserved.
//

#import "XHModelClass.h"
#import "XHTypeClass.h"
#import "XHKeywordClass.h"
#import "XHPropertyClass.h"

@implementation XHModelClass {
    XHTypeClass *_typeClass;
    XHKeywordClass *_keywordClass;
    XHPropertyClass *_propertyClass;
}



- (instancetype)initWithObject:(id)object
                        prefix:(NSString *)classPrefix
                        suffix:(NSString *)classSuffix
                     superName:(NSString *)superName
{
    self = [super init];
    if (self) {
        //工具类
        _typeClass = [XHTypeClass new];
        _keywordClass = [XHKeywordClass new];
        _propertyClass = [XHPropertyClass new];

        //当前属性
        self.classPrefix = classPrefix;
        self.classSuffix = classSuffix;
        self.superName = superName;

        [self buildClass:object];
    }
    return self;
}

- (void)buildClass:(id)object
{
    XHValueType objectType = [_typeClass valueTypeOfObject:object];
    if (objectType == XHDictionary)
    {
        [self dictionaryOperation:object];
    }
    else if (objectType == XHArray)
    {
        [self arrayOperation:object classSuffix:nil];
    }
}

- (void)dictionaryOperation:(NSDictionary *)dict
{
    for (NSString *key in dict)
    {
        id object = dict[key];
        XHValueType valueType = [_typeClass valueTypeOfObject:object];
        //如果value是[]或者{}格式，
        //说明是一个数组属性或者对象类型，可能需要新增一个类

        if (valueType == XHArray)
        {
            [self arrayOperation:object classSuffix:key];
        }
        else
        {
            [self addPropertyWithObject:key type:valueType];
            if (valueType == XHDictionary)
            {
                [self addToModelClassListWithObject:object suffix:key];
            }
        }
    }
}

- (void)arrayOperation:(NSArray *)array classSuffix:(NSString *)suffix
{
    if (array.count && [array.firstObject isKindOfClass:[NSDictionary class]])
    {
        //每个dictionary里面的key可能不一样。统一添加完，再去处理
        NSMutableDictionary *tmpDict = @{}.mutableCopy;
        [array enumerateObjectsUsingBlock:^(NSDictionary *arrObj, NSUInteger arrIdx, BOOL * _Nonnull arrStop) {
            if (arrObj.count && [arrObj isKindOfClass:[NSDictionary class]])
            {
                [arrObj enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull arrObjKey, id  _Nonnull arrObjObj, BOOL * _Nonnull arrObjStop)
                {
                    if (![tmpDict objectForKey:arrObjKey])
                    {
                        tmpDict[arrObjKey] = arrObjObj;
                    }
                }];
            }
        }];

        if (suffix)
        {
            //数组添加属性，创建新类
            [self addPropertyWithObject:suffix type:XHArray];
            [self addToModelClassListWithObject:tmpDict suffix:[self isReplaceKeyword:suffix]];
        }
        else
        {
            [self dictionaryOperation:tmpDict.copy];
        }
    }
    else
    {
        if (suffix)
        {
            //需要一个新的数组属性，但是不需要新的类文件
            NSString *newName = [self isReplaceKeyword:suffix];
            NSString *propertyString = [_propertyClass arrayPropertyWithName:newName class:nil];
            [self.propertyList addObject:propertyString];
        }
    }
}


/**
 当前json字段下面需要创建新的modelClass

 @param object 数据
 @param suffix 类名（不带前缀）
 */
- (void)addToModelClassListWithObject:(id)object suffix:(NSString *)suffix {
    if ([suffix containsString:@"_"]) {
        suffix = [self deleteUnderline:suffix];
    }
    XHModelClass *nextModelClass = [[XHModelClass alloc] initWithObject:object prefix:self.classPrefix suffix:suffix.capitalizedString superName:self.superName];
    [self.modelClassList addObject:nextModelClass];
}

/**
 添加成员属性到当前类

 @param name 属性名称（不带前缀）
 @param type 属性类型
 */
- (void)addPropertyWithObject:(NSString *)name type:(XHValueType)type
{
    NSString *propertyString = nil;
    NSString *newName = [self isReplaceKeyword:name];
    switch (type) {
        case XHString:
        {
            propertyString = [_propertyClass stringProperty:newName];
            break;
        }
        case XHFloat:
        {
            propertyString = [_propertyClass floatProperty:newName];
            break;
        }
        case XHInteger:
        {
            propertyString = [_propertyClass integerProperty:newName];
            break;
        }
        case XHBool:
        {
            propertyString = [_propertyClass boolProperty:newName];
            break;
        }
        case XHDictionary:
        {
            NSString *newClassName = [NSString stringWithFormat:@"%@%@",self.classPrefix, newName.capitalizedString];
            propertyString = [_propertyClass dictionaryPropertyWithName:newName type:newClassName];
            break;
        }
        case XHArray:
        {
            NSString *newSuffix = newName.capitalizedString;
            NSString *newClassName = [NSString stringWithFormat:@"%@%@",self.classPrefix, newSuffix];
            //需要记住数组与对应的子类名称
            self.classNameList[newName] = newClassName;
            propertyString = [_propertyClass arrayPropertyWithName:newName class:newClassName];
            break;
        }
        default:
            //未知类型用id
            propertyString = [_propertyClass idProperty:newName];
            break;
    }
    if (propertyString)
        [self.propertyList addObject:propertyString];
}


/**
 替换系统关键字，并且记录

 @param keyword 关键字
 @return 替换后的关键字
 */
- (NSString *)isReplaceKeyword:(NSString *)keyword {
    NSString *newName = [_keywordClass makeNewkeyword:keyword];
    //若参数带有下划线，将下划线去掉
    BOOL isUnderline = [keyword containsString:@"_"];
    if (newName || isUnderline) {
        if (isUnderline) {
            newName = [self deleteUnderline:keyword];
        }
        self.propertyMap[newName] = keyword;
    } else {
        newName = keyword;
    }
    return newName;
}

- (NSString *)deleteUnderline:(NSString *)field {
    NSArray <NSString *>*keyList = [field componentsSeparatedByString:@"_"];
    NSMutableArray *newKeyList = [NSMutableArray array];
    [keyList enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx > 0) {
            [newKeyList addObject:obj.capitalizedString];
        } else {
            [newKeyList addObject:obj];
        }
    }];
    return [newKeyList componentsJoinedByString:@""];
}

#pragma mark - 懒加载

- (NSMutableArray *)propertyList {
    if (!_propertyList) {
        _propertyList = [NSMutableArray array];
    }
    return _propertyList;
}

- (NSMutableArray *)modelClassList {
    if (!_modelClassList) {
        _modelClassList = [NSMutableArray array];
    }
    return _modelClassList;
}

- (NSMutableDictionary *)propertyMap {
    if (!_propertyMap) {
        _propertyMap = [NSMutableDictionary dictionary];
    }
    return _propertyMap;
}

- (NSMutableDictionary *)classNameList {
    if (!_classNameList) {
        _classNameList = [NSMutableDictionary dictionary];
    }
    return _classNameList;
}


@end
