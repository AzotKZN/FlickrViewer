//
//  ServerManager.m
//  FlickrViewer
//
//  Created by Азат on 27.01.15.
//  Copyright (c) 2015 Azat Minvaliev. All rights reserved.
//
#import "ServerManager.h"
#import "AFNetworking.h"
#import "ServerResponse.h"

@interface ServerManager ()

@property (strong, nonatomic) AFHTTPRequestOperationManager* requestOperationManager;
@end


@implementation ServerManager

+ (ServerManager*) sharedManager;
{
    static ServerManager* manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ServerManager alloc] init];
    });
    
    return manager;
}

-(id)init
{
    self = [super init];
    if (self) {
        NSURL* url = [NSURL URLWithString:@"https://api.flickr.com/services/rest/"];
        
        self.requestOperationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    }
    return self;
}


-(void) getListForUser_id:(NSString*)user_id
                    per_page:(NSInteger) per_page
                        page:(NSInteger) page
                      format:(NSString*)format
                    nojsoncallback:(NSInteger) nojsoncallback
                   onSuccess:(void(^)(NSArray* albums)) success
                   onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {

    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"cde884f6c016e37c0e4429e9cb9e6c20", @"api_key",
                            user_id, @"user_id",
                            @(per_page), @"per_page",
                            @(page), @"page",
                            (format), @"format",
                    @(nojsoncallback), @"nojsoncallback", nil];
    
    [self.requestOperationManager
     GET:@"?method=flickr.photosets.getList"
     parameters:params
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
         
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

-(void) getPhotoForPhotoset_id:(NSString*)photoset_id
                        format:(NSString*)format
                nojsoncallback:(NSInteger) nojsoncallback
                     onSuccess:(void(^)(NSArray* photos)) success
                     onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure{
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:@"cde884f6c016e37c0e4429e9cb9e6c20", @"api_key",
                            (photoset_id), @"photoset_id",
                            (format), @"format",
                            @(nojsoncallback), @"nojsoncallback", nil];
    
    [self.requestOperationManager
     GET:@"?method=flickr.photosets.getPhotos"
     parameters:params
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         NSLog(@"JSON: %@", responseObject);
         //[[results objectForKey:@"photos"] objectForKey:@"photo"]
         NSArray* photosArray = [[responseObject objectForKey:@"photoset"] objectForKey:@"photo"];
         
         NSMutableArray* objectsArray = [NSMutableArray array];
         
         for (NSDictionary* dict in photosArray) {
             ServerResponse* photo = [[ServerResponse alloc] initWithServerResponse:dict];
             [objectsArray addObject:photo];
         }
         
         if (success) {
             success(objectsArray);
         }

         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         
         if (failure){
             failure(error, operation.response.statusCode);
         }
         
     }];
    
    
    
    
    
    
    
    
    
    
    
    
}

@end
