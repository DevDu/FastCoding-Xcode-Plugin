//
//  FastCoding.m
//  FastCoding
//
//  Created by DevDu on 16/7/12.
//  Copyright © 2016年 DevDu. All rights reserved.
//

#import "FastCoding.h"
#import "FastCodingDataManager.h"

static FastCoding *sharedPlugin;

@implementation FastCoding

#pragma mark - Initialization

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    NSArray *allowedLoaders = [plugin objectForInfoDictionaryKey:@"me.delisa.XcodePluginBase.AllowedLoaders"];
    if ([allowedLoaders containsObject:[[NSBundle mainBundle] bundleIdentifier]]) {
        sharedPlugin = [[self alloc] initWithBundle:plugin];
    }
}

+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)bundle
{
    if (self = [super init]) {
        // reference to plugin's bundle, for resource access
        _bundle = bundle;
        // NSApp may be nil if the plugin is loaded from the xcodebuild command line tool
        if (NSApp && !NSApp.mainMenu)
        {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(applicationDidFinishLaunching:)
                                                         name:NSApplicationDidFinishLaunchingNotification
                                                       object:nil];
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(notificationLog:)
                                                         name:NSTextViewDidChangeSelectionNotification
                                                       object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(notificationLog:)
                                                         name:@"IDEEditorDocumentDidChangeNotification"
                                                       object:nil];
        } else {
            [self initializeAndLog];
        }
    }
    return self;
}
- (void)notificationLog:(NSNotification *)notify
{
    if ([notify.name isEqualToString:NSTextViewDidChangeSelectionNotification]) {
        if ([notify.object isKindOfClass:[NSTextView class]]) {
            NSTextView *textView = (NSTextView *)notify.object;
            self.currentTextView = textView;
        }
    }else if ([notify.name isEqualToString:@"IDEEditorDocumentDidChangeNotification"]){
        NSObject *array = notify.userInfo[@"IDEEditorDocumentChangeLocationsKey"];
        NSURL *url = [[array valueForKey:@"documentURL"] firstObject];
        if (![url isKindOfClass:[NSNull class]])
        {
            NSString *path = [url absoluteString];
            self.currentFilePath = path;
        }
    }
}
-(void)applicationDidFinishLaunching:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSApplicationDidFinishLaunchingNotification
                                                  object:nil];
    [self initializeAndLog];
}

- (void)initializeAndLog
{
    NSString *name = [self.bundle objectForInfoDictionaryKey:@"CFBundleName"];
    NSString *version = [self.bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *status = [self initialize] ? @"loaded successfully" : @"failed to load";
    NSLog(@"🔌 Plugin %@ %@ %@", name, version, status);
}

#pragma mark - Implementation

- (BOOL)initialize
{
    NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Product"];
    if (menuItem) {
        [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
        
        NSMenuItem *actionMenuItem1 = [[NSMenuItem alloc] initWithTitle:@"Generate All Setters" action:@selector(doMenuAction) keyEquivalent:@""];
        [actionMenuItem1 setTarget:self];
        [[menuItem submenu] addItem:actionMenuItem1];
        
        NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"Generate All Getters" action:@selector(addGetAction) keyEquivalent:@""];
        [actionMenuItem setTarget:self];
        [[menuItem submenu] addItem:actionMenuItem];
        
        NSMenuItem *actionMenuItem2 = [[NSMenuItem alloc] initWithTitle:@"Generate Getters and Setters" action:@selector(chooseSetGet) keyEquivalent:@"="];
        [actionMenuItem2 setTarget:self];
        [menuItem setKeyEquivalentModifierMask: NSShiftKeyMask | NSCommandKeyMask];

        [[menuItem submenu] addItem:actionMenuItem2];
        return YES;
    } else {
        return NO;
    }
}
- (void) chooseSetGet
{
     self.chooseWindow = [[ChooseWindowController alloc] initWithWindowNibName:@"ChooseWindowController"];
    [self.chooseWindow showWindow:self.chooseWindow];
}
- (void)addGetAction
{
    NSString * content = [[FastCodingDataManager sharedDataManager] inMfileGetHfileContentWithUrl:self.currentFilePath];
    NSString *  setMethodsStr = [[FastCodingDataManager sharedDataManager] getFilePropertysWithContent:content isSetMethod:NO];
    [self.currentTextView insertText:setMethodsStr replacementRange:self.currentTextView.rangeForUserCompletion];
    
}
// Sample Action, for menu item:
- (void)doMenuAction
{
    NSString * content = [[FastCodingDataManager sharedDataManager] inMfileGetHfileContentWithUrl:self.currentFilePath];
    NSString * setMethodsStr = [[FastCodingDataManager sharedDataManager] getFilePropertysWithContent:content isSetMethod:YES];
    [self.currentTextView insertText:setMethodsStr replacementRange:self.currentTextView.rangeForUserCompletion];
}

@end
