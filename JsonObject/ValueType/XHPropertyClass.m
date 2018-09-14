//
//  XHPropertyClass.m
//  JsonObject
//
//  Created by 黄斌 on 2018/9/10.
//  Copyright © 2018年 黄斌. All rights reserved.
//


#import "XHPropertyClass.h"


@implementation XHPropertyClass
{
    NSString *_strongPrefix;
    NSString *_assignPrefix;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _strongPrefix = @"@property (strong, nonatomic) ";
        _assignPrefix = @"@property (assign, nonatomic) ";
    }
    return self;
}

- (NSString *)idProperty:(NSString *)propertyName
{
    NSString *suffix = [NSString stringWithFormat:@"id %@", propertyName];
    return [NSString stringWithFormat:@"%@%@;\n",_strongPrefix, suffix];
}

- (NSString *)arrayPropertyWithName:(NSString *)propertyName class:(NSString *)className {
    NSString *suffix;
    if (className) {
        suffix = [NSString stringWithFormat:@"NSArray <%@ *> *%@",className, propertyName];
    } else {
        suffix = [NSString stringWithFormat:@"NSArray *%@", propertyName];
    }
    return [NSString stringWithFormat:@"%@%@;\n",_strongPrefix, suffix];
}

- (NSString *)dictionaryPropertyWithName:(NSString *)propertyName type:(NSString *)propertyType {
    NSString *suffix = [NSString stringWithFormat:@"%@ *%@", propertyType, propertyName];
    return [NSString stringWithFormat:@"%@%@;\n",_strongPrefix, suffix];
}

- (NSString *)stringProperty:(NSString *)propertyName
{
    NSString *suffix = [NSString stringWithFormat:@"NSString *%@", propertyName];
    return [NSString stringWithFormat:@"%@%@;\n",_strongPrefix, suffix];
}

- (NSString *)integerProperty:(NSString *)propertyName
{
    NSString *suffix = [NSString stringWithFormat:@"NSInteger %@", propertyName];
    return [NSString stringWithFormat:@"%@%@;\n",_assignPrefix, suffix];
}

- (NSString *)floatProperty:(NSString *)propertyName
{
    NSString *suffix = [NSString stringWithFormat:@"CGFloat %@", propertyName];
    return [NSString stringWithFormat:@"%@%@;\n",_assignPrefix, suffix];
}

- (NSString *)boolProperty:(NSString *)propertyName
{
    NSString *suffix = [NSString stringWithFormat:@"BOOL %@", propertyName];
    return [NSString stringWithFormat:@"%@%@;\n",_assignPrefix, suffix];
}


@end
