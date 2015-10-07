//
//  AppDelegate.m
//  HyperionRemote
//
//  Created by Tobias Tangemann on 14.08.15.
//  Copyright (c) 2015 Tobias Tangemann. All rights reserved.
//

#import "AppDelegate.h"
#import "HyperionColor.h"

#define COLORS_KEY @"colors"

@interface AppDelegate ()
@end

@implementation AppDelegate

@synthesize statusMenu;
@synthesize colorMenu;

NSStatusItem *statusItem = nil;
NSArray *colors;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    statusItem.image = [NSImage imageNamed:@"hyperion_icon"];
    statusItem.menu = statusMenu;
    statusItem.toolTip = @"HyperionRemote";
    statusItem.highlightMode = YES;
    
    [[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:COLORS_KEY options:NSKeyValueObservingOptionNew context:nil];
    [self updateMenuItems];
}

- (void) updateMenuItems
{
    [colorMenu removeAllItems];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    colors = [NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:COLORS_KEY]];
    
    for (HyperionColor *color in colors) {
        NSMenuItem *newColorEntry = [colorMenu addItemWithTitle:color.name action:@selector(sendColor:) keyEquivalent:@""];
        [newColorEntry setTarget:color];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self updateMenuItems];
}

- (void)dealloc
{
    [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:COLORS_KEY context:NULL];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (IBAction)clearColor:(NSMenuItem *)sender {
    [HyperionColor sendCommand:@"{\"command\":\"clear\",\"priority\":10}\n"];
}

- (IBAction)showSettings:(id)sender {
    [NSApp activateIgnoringOtherApps:YES];
    [self.window makeKeyAndOrderFront:nil];
}

@end
