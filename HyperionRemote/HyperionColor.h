//
//  HyperionColor.h
//  HyperionRemote
//
//  Created by Tobias Tangemann on 03.10.15.
//  Copyright © 2015 Tobias Tangemann. All rights reserved.
//

@import AppKit;
#import <Foundation/Foundation.h>

@interface HyperionColor : NSObject <NSCoding>

@property (strong) NSString *name;
@property (strong) NSColor *color;

@property (readonly) NSString *colorText;

+ (void) sendCommand: (NSString *)command;

- (IBAction) sendColor: (id) sender;
- (void) setColorNoSend: (NSColor*) color;

@end
