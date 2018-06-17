//
//  AppDelegate.m
//  HyperionRemote
//
//  Created by Tobias Tangemann on 14.08.15.
//  Copyright (c) 2015 Tobias Tangemann. All rights reserved.
//

#import "AppDelegate.h"
#import "HyperionColor.h"
#import "GlobalDefinitions.h"

@interface AppDelegate ()
@end

@implementation AppDelegate

@synthesize statusMenu;
@synthesize colorMenu;
@synthesize colorArrayController;
@synthesize colorTableView;
@synthesize colors;

NSStatusItem *statusItem = nil;

- (id) init
{
    self = [super init];
    if (!self) return nil;
    
    // Add this instance of TestClass as an observer of the TestNotification.
    // We tell the notification center to inform us of "TestNotification"
    // notifications using the receiveTestNotification: selector. By
    // specifying object:nil, we tell the notification center that we are not
    // interested in who posted the notification. If you provided an actual
    // object rather than nil, the notification center will only notify you
    // when the notification was posted by that particular object.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(saveSettingsNotification:)
                                                 name:NOTIFY_SAVE_SETTING
                                               object:nil];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.colors = [NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:COLORS_KEY]];
    
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    statusItem.image = [NSImage imageNamed:@"hyperion_icon"];
    statusItem.menu = statusMenu;
    statusItem.toolTip = @"HyperionRemote";
    statusItem.highlightMode = YES;
    
    [self updateMenuItems];
}

- (IBAction)addColor:(id)sender {
    // Try to end any editing that is taking place in the table view
    NSWindow *w = [colorTableView window];
    BOOL endEdit = [w makeFirstResponder:w];
    if(!endEdit) {
        return;
    }
    
    // Create a new object and add it to the arrayController
    HyperionColor *new = [colorArrayController newObject];
    [colorArrayController addObject:new];
    
    // Get the index of the new object
    NSArray *array = [colorArrayController arrangedObjects];
    
    // Comparison based on identifier
    NSUInteger row = [array indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [((HyperionColor*)obj).identifier isEqualTo:new.identifier];
    }];
    
    // Begin editing of the cell containing the new color
    colorArrayController.selectionIndex = row;
    [colorTableView editColumn:0 row:row withEvent:nil select:YES];
}

- (void) updateMenuItems
{
    [colorMenu removeAllItems];
    
    for (HyperionColor *color in self.colorArrayController.arrangedObjects) {
        NSMenuItem *newColorEntry = [colorMenu addItemWithTitle:color.name action:@selector(sendColor:) keyEquivalent:@""];
        [newColorEntry setTarget:color];
    }
}

- (void) saveSettingsNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:NOTIFY_SAVE_SETTING])
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:self.colorArrayController.arrangedObjects] forKey:COLORS_KEY];
        [defaults synchronize];
        
        [self updateMenuItems];
    }
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
