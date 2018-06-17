//
//  AppDelegate.h
//  HyperionRemote
//
//  Created by Tobias Tangemann on 14.08.15.
//  Copyright (c) 2015 Tobias Tangemann. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (weak) IBOutlet NSMenu *colorMenu;
@property (weak) IBOutlet NSMenu *statusMenu;
@property (strong) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSArrayController *colorArrayController;
@property (weak) IBOutlet NSTableView *colorTableView;
@property (strong) NSArray *colors;

- (IBAction)clearColor:(NSMenuItem *)sender;
- (IBAction)showSettings:(id)sender;
- (IBAction)addColor:(id)sender;

@end
