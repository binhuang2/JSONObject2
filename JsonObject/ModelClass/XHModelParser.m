//
//  XHModelParser.m
//  JsonObject
//
//  Created by 黄斌 on 2018/9/13.
//  Copyright © 2018年 黄斌. All rights reserved.
//

#import "XHModelParser.h"
#import "XHModelClass.h"

@implementation XHModelParser {
    YWFrameworkType _frameworkType;
}

- (NSMutableArray *)fileHContentList {
    if (!_fileHContentList) {
        _fileHContentList = [NSMutableArray array];
    }
    return _fileHContentList;
}

- (NSMutableArray *)fileMContentList {
    if (!_fileMContentList) {
        _fileMContentList = [NSMutableArray array];
    }
    return _fileMContentList;
}

- (instancetype)initWithModelClass:(XHModelClass *)model type:(YWFrameworkType)type {
    if (self = [super init]) {
        _frameworkType = type;
        [self parser:model];
    }
    return self;
}

- (void)parser:(XHModelClass *)model {

    NSString *className = [NSString stringWithFormat:@"%@%@",model.classPrefix,model.classSuffix];

    NSString *hContent = [self buildFileTypeHContent:model];
    if (hContent) {
        NSString *mContent = [self buildFileTypeMContent:model];

        NSDictionary *dictH = @{
                                className:hContent
                               };
        NSDictionary *dictM = @{
                                className:mContent
                                };
        [self.fileHContentList addObject:dictH];
        [self.fileMContentList addObject:dictM];
    }

    for (XHModelClass * _Nonnull obj in model.modelClassList) {
        [self parser:obj];
    }
}

- (NSString *)buildFileTypeMContent:(XHModelClass *)model {
    if (model.propertyList.count == 0) {
        //没有属性的类，不能叫做类
        return nil;
    }
    NSString *className = [NSString stringWithFormat:@"%@%@",model.classPrefix,model.classSuffix];
    NSString *import = [NSString stringWithFormat:@"#import \"%@.h\"",className];
    NSString *implementation = [NSString stringWithFormat:@"@implementation %@",className];
    NSString *modelCustomPropertyMapper = nil;
    if (model.propertyMap.count) {
        NSMutableArray *propertyMap = @[].mutableCopy;
        for (NSString *key in model.propertyMap) {
            [propertyMap addObject:[NSString stringWithFormat:@" @\"%@\":@\"%@\"",key,model.propertyMap[key]]];
        }
        modelCustomPropertyMapper = [self propertyChange:[propertyMap componentsJoinedByString:@","] frameworkType:_frameworkType];
    }

    NSString *propertyGenericClass = nil;
    if (model.modelClassList.count) {
        NSMutableArray *classMap = @[].mutableCopy;
        for (NSString *key in model.classNameList) {
            [classMap addObject:[NSString stringWithFormat:@" @\"%@\":@\"%@\"",key,model.classNameList[key]]];
        }
        propertyGenericClass = [self classPropertyChange:[classMap componentsJoinedByString:@","] frameworkType:_frameworkType];
    }

    NSString *content = [NSString stringWithFormat:@"\n%@\n\n%@",import,implementation];

    if (modelCustomPropertyMapper) {
        content = [NSString stringWithFormat:@"%@\n\n%@",content,modelCustomPropertyMapper];
    }

    if (propertyGenericClass) {
        content = [NSString stringWithFormat:@"%@\n%@",content,propertyGenericClass];
    }

    content = [NSString stringWithFormat:@"%@\n\n@end",content];

    return content;
}

///根据XHModelClass生成.h文件
- (NSString *)buildFileTypeHContent:(XHModelClass *)model {
    if (model.propertyList.count == 0) {
        //没有属性的类，不能叫做类
        return nil;
    }
    NSString *className = [NSString stringWithFormat:@"%@%@",model.classPrefix,model.classSuffix];
    NSString *import = [model.superName isEqualToString:@"NSObject"] ? @"#import <Foundation/Foundation.h>" : [NSString stringWithFormat:@"#import \"%@.h\"",model.superName];
    NSString *interface = [NSString stringWithFormat:@"@interface %@ : %@",className,model.superName];
    NSString *propertyList = [model.propertyList componentsJoinedByString:@"\n"];

    NSString *incloud_class = @"";
    //导入当前拥有的class
    //可以在这里将@class修改成#import.
    if (model.modelClassList.count) {
        for (XHModelClass *object in model.modelClassList) {
            incloud_class = [NSString stringWithFormat:@"%@%@%@,",incloud_class,object.classPrefix,object.classSuffix];
        }
        incloud_class = [NSString stringWithFormat:@"@class %@;",[incloud_class substringToIndex:incloud_class.length - 1]];
    }
    NSString *content = nil;
    if (incloud_class.length) {
        content = [NSString stringWithFormat:@"\n%@\n\n%@\n\n%@\n\n%@\n@end",import,incloud_class,interface,propertyList];
    } else {
        content = [NSString stringWithFormat:@"\n%@\n\n%@\n\n%@\n@end",import,interface,propertyList];
    }
    return content;
}

#pragma mark - yymode mj

- (NSString *)propertyChange:(NSString *)dict frameworkType:(YWFrameworkType)type
{
    switch (type) {
        case YYmodelFramework:
        {
            return [self yy_modelCustomPropertyMapper:dict];
            break;
        }
        case MJExtensionFramework:
        {
            return [self mj_replacedKeyFromPropertyName:dict];
            break;
        }
    }
    return nil;
}

- (NSString *)classPropertyChange:(NSString *)dict frameworkType:(YWFrameworkType)type
{
    switch (type) {
        case YYmodelFramework:
        {
            return [self yy_modelContainerPropertyGenericClass:dict];
            break;
        }
        case MJExtensionFramework:
        {
            return [self mj_objectClassInArray:dict];
            break;
        }
    }
    return nil;
}

//YYModel属性名称替换方法
- (NSString *)yy_modelCustomPropertyMapper:(NSString *)dict {
    NSString *funcHeader = @"\n+ (NSDictionary *)modelCustomPropertyMapper {";
    NSString *funcContent = [NSString stringWithFormat:@"    return @{\n        %@\n    };",dict];
    NSString *funcFooter = @"}";
    return [NSString stringWithFormat:@"%@\n%@\n%@",funcHeader,funcContent,funcFooter];
}

//YYModel字段对应的类名称
- (NSString *)yy_modelContainerPropertyGenericClass:(NSString *)dict {
    NSString *funcHeader =  @"\n+ (NSDictionary *)modelContainerPropertyGenericClass {";
    NSString *funcContent = [NSString stringWithFormat:@"    return @{\n        %@\n    };",dict];
    NSString *funcFooter = @"}";
    return [NSString stringWithFormat:@"%@\n%@\n%@",funcHeader,funcContent,funcFooter];
}

//MJ属性名称替换方法
- (NSString *)mj_replacedKeyFromPropertyName:(NSString *)dict
{
    NSString *funcHeader = @"\n+ (NSDictionary *)mj_replacedKeyFromPropertyName {";
    NSString *funcContent = [NSString stringWithFormat:@"    return @{\n        %@\n    };",dict];
    NSString *funcFooter = @"}";
    return [NSString stringWithFormat:@"%@\n%@\n%@",funcHeader,funcContent,funcFooter];
}

//MJ字段对应的类名称
- (NSString *)mj_objectClassInArray:(NSString *)dict {
    NSString *funcHeader =  @"\n+ (NSDictionary *)mj_objectClassInArray {";
    NSString *funcContent = [NSString stringWithFormat:@"    return @{\n        %@\n    };",dict];
    NSString *funcFooter = @"}";
    return [NSString stringWithFormat:@"%@\n%@\n%@",funcHeader,funcContent,funcFooter];
}


@end
