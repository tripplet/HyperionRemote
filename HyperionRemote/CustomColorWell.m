//
//  CustomColorWell.m
//  HyperionRemote
//
//  Created by Tobias Tangemann on 07.11.15.
//  Copyright © 2015 Tobias Tangemann. All rights reserved.
//

#import "CustomColorWell.h"
#import "HyperionColor.h"

@implementation CustomColorWell

- (void)activate:(BOOL)exclusive {
    [super activate:exclusive];
    [HyperionColor sendColor:self.color];
}

@end
