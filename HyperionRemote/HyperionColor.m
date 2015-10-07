//
//  HyperionColor.m
//  HyperionRemote
//
//  Created by Tobias Tangemann on 03.10.15.
//  Copyright © 2015 Tobias Tangemann. All rights reserved.
//

#import "HyperionColor.h"

@implementation HyperionColor

@synthesize name;
@synthesize color = _color;
;

- (id) init
{
    if (self = [super init])
    {
        self.name = @"NewColor";
        [self setColorNoSend: [NSColor blueColor]];
    }
    return self;
}

- (void) setColor:(NSColor *)color
{
    _color = [color copy];
    
    // Send the color to hyperion to make it easiert to choose the right color
    [self sendColor:nil];
}

- (NSColor*) color
{
    return _color;
}

- (void) setColorNoSend:(NSColor *)color
{
    _color = [color copy];
}

- (NSString *)colorText
{
    return [NSString stringWithFormat:@"[%d, %d, %d]",
              (int) (self.color.redComponent   * 255),
              (int) (self.color.greenComponent * 255),
              (int) (self.color.blueComponent  * 255)];
}

- (IBAction) sendColor:(id)sender
{
    [HyperionColor sendCommand:[NSString stringWithFormat:@"{\"color\":%@,\"command\":\"color\",\"priority\":10}\n", self.colorText]];
}

+ (void) sendCommand: (NSString *)command {
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"quimby.", 19444, &readStream, &writeStream);
    
    NSInputStream *inputStream = (__bridge_transfer NSInputStream *)readStream;
    NSOutputStream *outputStream = (__bridge_transfer NSOutputStream *)writeStream;
    
    [inputStream open];
    [outputStream open];
    
    const char *rawstring = [command UTF8String];
    [outputStream write:(uint8_t*)rawstring maxLength: strlen(rawstring)];
    [outputStream close];
    [inputStream close];
}


#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.name  forKey:@"NAME"];
    [coder encodeObject:self.color forKey:@"COLOR"];
}

- (id)initWithCoder:(NSCoder *)coder
{
    if (self = [super init])
    {
        self.name  = [coder decodeObjectForKey:@"NAME"];
        [self setColorNoSend: [coder decodeObjectForKey:@"COLOR"]];
    }
    return self;
}

@end