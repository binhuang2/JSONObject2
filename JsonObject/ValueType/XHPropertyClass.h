//
//  XHPropertyClass.h
//  JsonObject
//
//  Created by 黄斌 on 2018/9/10.
//  Copyright © 2018年 黄斌. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XHPropertyClass : NSObject

- (NSString *)stringProperty:(NSString *)propertyName;
- (NSString *)integerProperty:(NSString *)propertyName;
- (NSString *)floatProperty:(NSString *)propertyName;
- (NSString *)boolProperty:(NSString *)propertyName;
- (NSString *)dictionaryPropertyWithName:(NSString *)propertyName type:(NSString *)propertyType;
- (NSString *)arrayPropertyWithName:(NSString *)propertyName class:(NSString *)className;
- (NSString *)idProperty:(NSString *)propertyName;

@end
