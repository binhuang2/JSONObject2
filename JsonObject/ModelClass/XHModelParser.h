//
//  XHModelParser.h
//  JsonObject
//
//  Created by 黄斌 on 2018/9/13.
//  Copyright © 2018年 黄斌. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 model解析框架
 可以在这里扩展新的框架
 将转换方法放在 .m文件
 */
typedef NS_ENUM(NSUInteger, YWFrameworkType) {
    YYmodelFramework = 0,   //默认是0
    MJExtensionFramework = 1
} ;

@class XHModelClass;

@interface XHModelParser : NSObject

@property (strong, nonatomic) NSMutableArray <NSDictionary <NSString *, NSString *>*>*fileHContentList;

@property (strong, nonatomic) NSMutableArray <NSDictionary <NSString *, NSString *>*>*fileMContentList;

- (instancetype)initWithModelClass:(XHModelClass *)model type:(YWFrameworkType)type;

@end
