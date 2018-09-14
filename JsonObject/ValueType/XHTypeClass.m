//
//  XHValueTypeClass.m
//  JsonObject
//
//  Created by 黄斌 on 2018/9/10.
//  Copyright © 2018年 黄斌. All rights reserved.
//

#import "XHTypeClass.h"

@implementation XHTypeClass

- (XHValueType)valueTypeOfObject:(id)object {
    if ([object isKindOfClass:[NSDictionary class]])
    {
        return XHDictionary;
    }
    else if ([object isKindOfClass:[NSArray class]])
    {
        return XHArray;
    }
    else if ([object isKindOfClass:[NSString class]])
    {
        return XHString;
    }
    else if ([object isKindOfClass:[NSNull class]])
    {
        return XHNull;
    }
    else if ([object isKindOfClass:[NSNumber class]])
    {
        if (!strcmp([object objCType], @encode(float))|| !strcmp([object objCType], @encode(double)))
        {
            return XHFloat;
        }
        else if (!strcmp([object objCType], @encode(int)) || !strcmp([object objCType], @encode(long)) || !strcmp([object objCType], @encode(short)))
        {
            return XHInteger;
        }
        else if (!strcmp([object objCType], @encode(BOOL)) || !strcmp([object objCType], @encode(bool)))
        {
            return XHBool;
        }
    }
    return XHUnknown;
}

@end
