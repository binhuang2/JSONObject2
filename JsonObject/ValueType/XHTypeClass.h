//
//  XHTypeClass.h
//  JsonObject
//
//  Created by 黄斌 on 2018/9/10.
//  Copyright © 2018年 黄斌. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, XHValueType) {
    XHDictionary,
    XHArray,
    XHString,
    XHFloat,
    XHInteger,
    XHBool,
    
    XHNull,
    XHUnknown
};

@interface XHTypeClass : NSObject

- (XHValueType)valueTypeOfObject:(id)object;

@end
