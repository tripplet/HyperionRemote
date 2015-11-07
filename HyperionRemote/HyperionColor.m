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

- (NSString *) colorText          { return [HyperionColor getTextDescriptionFromColor:self.color]; }
- (IBAction) sendColor:(id)sender { [HyperionColor sendColor: self.color]; }

+ (NSString *) getTextDescriptionFromColor:(NSColor*) color
{
    return [NSString stringWithFormat:@"[%d, %d, %d]",
            (int) (color.redComponent   * 255),
            (int) (color.greenComponent * 255),
            (int) (color.blueComponent  * 255)];
}

+ (void) sendColor: (NSColor*) color
{
    NSInteger timeout = [[NSUserDefaults standardUserDefaults] integerForKey:@"timeout"];
    
    if (timeout != 0) {
        [HyperionColor sendCommand: [NSString stringWithFormat:@"{\"color\":%@,\"command\":\"color\",\"priority\":10,\"duration\":%ld}\n",
                                                              [HyperionColor getTextDescriptionFromColor:color], timeout * 60 * 1000]];
    }
    else {
        [HyperionColor sendCommand:[NSString stringWithFormat:@"{\"color\":%@,\"command\":\"color\",\"priority\":10}\n",
                                                              [HyperionColor getTextDescriptionFromColor:color]]];
    }
}

+ (void) sendCommand: (NSString *)command {
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    
    NSString *server = [[NSUserDefaults standardUserDefaults] stringForKey:@"serverAddress"];
    
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)server, 19444, &readStream, &writeStream);
    
    NSInputStream *inputStream = (__bridge_transfer NSInputStream *)readStream;
    NSOutputStream *outputStream = (__bridge_transfer NSOutputStream *)writeStream;
    
    [inputStream open];
    [outputStream open];
    
    const char *rawstring = [command UTF8String];
    [outputStream write:(uint8_t*)rawstring maxLength: strlen(rawstring)];
    [outputStream close];
    
    NSMutableData *collectedData = [NSMutableData data];
    uint8_t buffer[1024];
    long len;
    while ([inputStream hasBytesAvailable]) {
        len = [inputStream read:buffer maxLength:sizeof(buffer)];
        [collectedData appendBytes: (const void *)buffer length:len];
    }
    
    [inputStream close];
    
    id object = [NSJSONSerialization JSONObjectWithData:collectedData options:0 error:nil];
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