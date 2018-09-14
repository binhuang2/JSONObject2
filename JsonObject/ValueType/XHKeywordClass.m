//
//  XHKeywordClass.m
//  JsonObject
//
//  Created by 黄斌 on 2018/9/10.
//  Copyright © 2018年 黄斌. All rights reserved.
//

#import "XHKeywordClass.h"

@implementation XHKeywordClass {
    NSDictionary *_keywordMap;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _keywordMap = @{
                        @"id":@"debugId",
                        @"description":@"debugDescription"
                        };
    }
    return self;
}

- (NSString *)makeNewkeyword:(NSString *)key {
    return key ? _keywordMap[key] : nil ;
}

@end
