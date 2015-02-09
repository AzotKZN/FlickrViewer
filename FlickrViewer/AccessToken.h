//
//  AccessToken.h
//  FlickrViewer
//
//  Created by Азат on 04.02.15.
//  Copyright (c) 2015 Azat Minvaliev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccessToken : NSObject

@property (strong, nonatomic) NSString* token;
@property (strong, nonatomic) NSDate* expirationDate;
@property (strong, nonatomic) NSString* frob;

@end
