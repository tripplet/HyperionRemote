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

- (IBAction)clearColor:(NSMenuItem *)sender;
- (IBAction)showSettings:(id)sender;
- (IBAction)clickedColorWell:(NSColorWell *)sender;

@end