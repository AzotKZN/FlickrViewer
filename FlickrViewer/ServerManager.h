//
//  ServerManager.h
//  FlickrViewer
//
//  Created by Азат on 27.01.15.
//  Copyright (c) 2015 Azat Minvaliev. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ServerResponse;
@interface ServerManager : NSObject

@property (strong, nonatomic, readonly) ServerResponse* currentUser;

+ (ServerManager*) sharedManager;

-(void) authorizeUser:(void(^)(ServerResponse* user)) completion;
-(void) getListForUser_id:(NSString*)user_id
                  per_page:(NSInteger) per_page
                  page:(NSInteger) page
                  format:(NSString*)format
                  nojsoncallback:(NSInteger) nojsoncallback
                  onSuccess:(void(^)(NSArray* photos)) success
                  onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

-(void) getPhotoForPhotoset_id:(NSString*)photoset_id
                        format:(NSString*)format
                nojsoncallback:(NSInteger) nojsoncallback
                onSuccess:(void(^)(NSArray* photos)) success
                onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

-(void) getTokenForFrob:(NSString*)Frob
                        format:(NSString*)format
                nojsoncallback:(NSInteger) nojsoncallback
                        api_sig:(NSString*)api_sig
                     onSuccess:(void(^)(NSArray* photos)) success
                     onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

-(void)uploadImage:img;


@end
