//
//  ColorArrayController.m
//  HyperionRemote
//
//  Created by Tobias Tangemann on 17.06.18.
//  Copyright © 2018 Tobias Tangemann. All rights reserved.
//

#import "ColorArrayController.h"
#import "HyperionColor.h"

#import "GlobalDefinitions.h"

@implementation ColorArrayController

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSArray *selection = self.selectedObjects;
    
    if (selection.count == 1) {
        [(HyperionColor*)(selection.firstObject) sendColor:nil];
    }
}

- (void)addObject:(id)object {
    [super addObject:object];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_SAVE_SETTING object:self];
}

- (void)remove:(id)sender {
    [super remove:sender];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_SAVE_SETTING object:self];
}

@end
