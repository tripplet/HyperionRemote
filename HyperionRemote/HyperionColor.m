//
//  HyperionColor.m
//  HyperionRemote
//
//  Created by Tobias Tangemann on 03.10.15.
//  Copyright © 2015 Tobias Tangemann. All rights reserved.
//

#import "HyperionColor.h"
#import "GlobalDefinitions.h"

@interface HyperionColor()
@property (readwrite) NSString *identifier;
@end

@implementation HyperionColor

@synthesize name = _name;
@synthesize color = _color;
@synthesize identifier;

- (id)init
{
    if (self = [super init])
    {
        self.name = @"NewColor";
        [self setColorNoSend: [NSColor blueColor]];
        self.identifier = [[NSUUID UUID] UUIDString];
    }
    
    return self;
}

- (void)setColor:(NSColor *)color
{
    [self setColorNoSend:color];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_SAVE_SETTING object:self];
    
    // Send the color to hyperion to make it easiert to choose the right color
    [self sendColor:nil];
}


- (NSColor*)color  { return _color; }
- (NSString *)name { return _name; }

- (void)setColorNoSend:(NSColor *)color { _color = [color copy]; }
- (void)setNameNoSave:(NSString *)name  { _name = [name copy];}

- (void)setName:(NSString *)name {
    [self setNameNoSave:name];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_SAVE_SETTING object:self];
}

- (NSString *)colorText
{
    return [HyperionColor getTextDescriptionFromColor:self.color];
}

- (IBAction)sendColor:(id)sender
{
    [HyperionColor sendColor: self.color];
}

+ (NSString *)getTextDescriptionFromColor:(NSColor*) color
{
    return [NSString stringWithFormat:@"[%d, %d, %d]",
            (int) (color.redComponent   * 255),
            (int) (color.greenComponent * 255),
            (int) (color.blueComponent  * 255)];
}

+ (void)sendColor: (NSColor*) color
{
    NSInteger timeout = [[NSUserDefaults standardUserDefaults] integerForKey:@"timeout"];
    
    NSString *command;
    if (timeout != 0) {
        command = [NSString stringWithFormat:@"{\"color\":%@,\"command\":\"color\",\"priority\":10,\"duration\":%ld}\n",
                                     [HyperionColor getTextDescriptionFromColor:color], timeout * 60 * 1000];
    }
    else {
        command = [NSString stringWithFormat:@"{\"color\":%@,\"command\":\"color\",\"priority\":10}\n",
                                    [HyperionColor getTextDescriptionFromColor:color]];
    }
    
    [HyperionColor sendCommand: command];
}

+ (void)sendCommand: (NSString *)command
{
    // Networking done in the background to avoid hanging ui
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [HyperionColor sendCommandData: command];
    });
}

+ (void)sendCommandData: (NSString*)command
{
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
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding { return YES; }

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.name       forKey:@"NAME"];
    [coder encodeObject:self.color      forKey:@"COLOR"];
    [coder encodeObject:self.identifier forKey:@"ID"];
}

- (id)initWithCoder:(NSCoder *)coder
{
    if (self = [super init])
    {
        [self setNameNoSave:  [coder decodeObjectOfClass:NSString.class forKey:@"NAME"]];
        self.identifier =     [coder decodeObjectOfClass:NSUUID.class forKey:@"ID"];
        [self setColorNoSend: [coder decodeObjectOfClass:NSColor.class forKey:@"COLOR"]];
    }
    return self;
}

@end
