//
//  ServerResponse.h
//  FlickrViewer
//
//  Created by Азат on 28.01.15.
//  Copyright (c) 2015 Azat Minvaliev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServerResponse : NSObject

@property (strong, nonatomic) NSURL* imageURL;

- (id) initWithServerResponse:(NSDictionary*) responseObject;


@end
