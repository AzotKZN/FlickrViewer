//
//  ServerResponse.m
//  FlickrViewer
//
//  Created by Азат on 28.01.15.
//  Copyright (c) 2015 Azat Minvaliev. All rights reserved.
//

#import "ServerResponse.h"

@implementation ServerResponse : NSObject

- (id) initWithServerResponse:(NSDictionary*) responseObject
{
    self = [super init];
    if (self) {
        
        NSString* farm = [responseObject objectForKey:@"farm"];
        NSString* server = [responseObject objectForKey:@"server"];
        NSString* identificator = [responseObject objectForKey:@"id"];
        NSString* secret = [responseObject objectForKey:@"secret"];
        
        NSString* urlString = [NSString stringWithFormat:@"https://farm%@.staticflickr.com/%@/%@_%@.jpg", farm, server, identificator, secret];
        
        if (urlString) {
            self.imageURL = [NSURL URLWithString:urlString];
        }
    }
    return self;
}

@end