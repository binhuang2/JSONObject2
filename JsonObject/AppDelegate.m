//
//  AppDelegate.m
//  JsonObject
//
//  Created by 黄斌 on 2018/6/1.
//  Copyright © 2018年 黄斌. All rights reserved.
//

#import "AppDelegate.h"
#import "RootVC.h"

@interface AppDelegate () <NSWindowDelegate>

@property (strong) RootVC *rootVC;

@property (weak) IBOutlet NSWindow *window;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

    [_window setDelegate:self];

    self.rootVC = [[RootVC alloc] initWithNibName:@"RootVC" bundle:nil];

    [self.window.contentView addSubview:self.rootVC.view];

    self.rootVC.view.frame = self.window.contentView.bounds;
}

-(BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag{

    [_window makeKeyAndOrderFront:nil];

    return YES;
}

-(void)windowWillClose:(NSNotification *)notification{
    exit(-1);
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
