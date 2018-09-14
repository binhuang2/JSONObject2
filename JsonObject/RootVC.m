//
//  RootVC.m
//  JsonObject
//
//  Created by 黄斌 on 2018/6/1.
//  Copyright © 2018年 黄斌. All rights reserved.
//

#import "RootVC.h"
#import "XHModelClass.h"
#import "XHModelParser.h"

@interface RootVC ()

@property (strong) IBOutlet NSPopUpButton *popUpButton;

@property (strong) IBOutlet NSButton *buildButton;
//json输入框
@property (strong) IBOutlet NSTextView *textView;
//父类名
@property (strong) IBOutlet NSTextField *superTF;
//model类名前缀
@property (strong) IBOutlet NSTextField *prefixTF;
//model类名
@property (strong) IBOutlet NSTextField *fileNameTF;

/**
 选择解析json使用的框架，默认使用yymodel
 */
@property (assign, nonatomic) YWFrameworkType frameworkType;

@end

@implementation RootVC

- (void)viewDidLoad {
    [super viewDidLoad];


    //禁止引号替换
    self.textView.automaticQuoteSubstitutionEnabled = NO;

    self.frameworkType = YYmodelFramework;
}

///选择模型转化框架
- (IBAction)selectFramework:(NSPopUpButton *)sender {
    self.frameworkType = sender.indexOfSelectedItem == 0 ? 0 : sender.indexOfSelectedItem - 1;
}

//解析json，生成文件
- (IBAction)buildJsonObject:(NSButton *)sender
{
    NSString *jsonString = _textView.string;
    NSString *prefix = _prefixTF.stringValue;
    NSString *suffix = _fileNameTF.stringValue;
    NSString *superName = _superTF.stringValue;

    if (!jsonString.length || !prefix.length || !suffix.length || !superName.length) {
        return;
    }
    NSError *error;
    id object = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    if (error) {
        [self alert:@"json 格式有误"];
        return;
    }

    //生成 XHModelParser 解析需要的结构
    XHModelClass *rootModel = [[XHModelClass alloc] initWithObject:object prefix:prefix suffix:suffix superName:superName];
    //转换成class文件内容
    XHModelParser *parser = [[XHModelParser alloc] initWithModelClass:rootModel type:self.frameworkType];

    if (parser.fileHContentList.count && parser.fileMContentList.count) {
        [self openFinderWithParser:parser];
    } else {
        [self alert:@"文件生成失败,请检查json"];
    }
}

//选择文件保存路径
- (void)openFinderWithParser:(XHModelParser *)parser {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:NO];  //是否能选择文件file
    [panel setCanChooseDirectories:YES];  //是否能打开文件夹
    [panel setAllowsMultipleSelection:NO];  //是否允许多选file
    NSInteger finded = [panel runModal];   //获取panel的响应
    if (finded == NSModalResponseOK) {
        [self createModelFile:[[panel URLs] firstObject] :parser];
    }
}
//生成文件方法
- (void)createModelFile:(NSURL *)saveUrl :(XHModelParser *)parser
{
    for (NSDictionary *dict in parser.fileHContentList) {
        [dict.allValues.firstObject writeToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@.h",saveUrl.absoluteString,dict.allKeys.firstObject]] atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    }

    for (NSDictionary *dict in parser.fileMContentList) {
        [dict.allValues.firstObject writeToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@.m",saveUrl.absoluteString,dict.allKeys.firstObject]] atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    }
}


- (void)alert:(NSString *)title {
    NSAlert *alert = [NSAlert new];
    [alert addButtonWithTitle:@"确定"];
    [alert setMessageText:title];
    [alert setAlertStyle:NSAlertStyleWarning];
    [alert beginSheetModalForWindow:[self.view window] completionHandler:nil];
}


@end
