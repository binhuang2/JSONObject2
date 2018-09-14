//
//  XHModelClass.h
//  JsonObject
//
//  Created by 黄斌 on 2018/9/10.
//  Copyright © 2018年 黄斌. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface XHModelClass : NSObject

//类名前缀
@property (strong, nonatomic) NSString *classPrefix;

//类名后缀
@property (strong, nonatomic) NSString *classSuffix;

///父类名称 默认是NSObject
@property (strong, nonatomic) NSString *superName;

///属性列表
@property (strong, nonatomic) NSMutableArray <NSString *>*propertyList;

///替换的关键字列表：比如id,description。结构与yymode/mj里面需要返回的dict对应
@property (strong, nonatomic) NSMutableDictionary <NSString *,NSString *>*propertyMap;

///数组包含的内容对应的class。结构与yymode/mj里面需要返回的dict对应
@property (strong, nonatomic) NSMutableDictionary <NSString *,NSString *>*classNameList;

///当前json对象内部包含的其他json对象
@property (strong, nonatomic) NSMutableArray <XHModelClass *>*modelClassList;

/**
 自定义初始化
 @param object 当前类的json对象
 @param classPrefix 类名前缀
 @param classSuffix 类名后缀
 @param superName 父类名称
 @return 生成类文件的Model
 */
- (instancetype)initWithObject:(id)object prefix:(NSString *)classPrefix suffix:(NSString *)classSuffix superName:(NSString *)superName;

@end
