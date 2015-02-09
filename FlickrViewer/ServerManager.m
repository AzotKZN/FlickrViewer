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
#import "UserLoginViewController.h"
#import "AccessToken.h"
#import "Frob.h"

@interface ServerManager ()

@property (strong, nonatomic) AFHTTPRequestOperationManager* requestOperationManager;
@property (strong, nonatomic) AccessToken* accessToken;
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

-(void) authorizeUser:(void (^)(ServerResponse* user)) completion {
    UserLoginViewController* vc = [[UserLoginViewController alloc] initWithCompletionBlock:^(AccessToken *token) {
        self.accessToken = token;
        
        if (completion) {
            completion(nil);        }
    }];
    
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    UIViewController* mainVC = [[[[UIApplication sharedApplication] windows] firstObject] rootViewController];
    
    [mainVC presentViewController:nav animated:YES completion:nil];
}

-(void) getListForUser_id:(NSString*)user_id
                    per_page:(NSInteger) per_page
                        page:(NSInteger) page
                      format:(NSString*)format
                    nojsoncallback:(NSInteger) nojsoncallback
                   onSuccess:(void(^)(NSArray* albums)) success
                   onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {

    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"ffd2e06854c5dea003eb9270d5b86b13", @"api_key",
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
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:@"ffd2e06854c5dea003eb9270d5b86b13", @"api_key",
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

-(void) getTokenForFrob:(NSString*)Frob
                 format:(NSString*)format
         nojsoncallback:(NSInteger) nojsoncallback
                    api_sig:(NSString*)api_sig
              onSuccess:(void(^)(NSArray* photos)) success
              onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure{
//https://api.flickr.com/services/rest/?method=flickr.auth.getToken&api_key=9a0554259914a86fb9e7eb014e4e5d52&frob=72157650137623777-b09eae52121bf8ad-130818926&format=json&nojsoncallback=1&perms=write&api_sig=8fd09b55f670ec9a4ba07c076e520ae8
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:@"ffd2e06854c5dea003eb9270d5b86b13", @"api_key",
                            (Frob), @"frob",
                            (format), @"format",
                            @(nojsoncallback), @"nojsoncallback",
                           @"delete", @"perms",
                            (api_sig), @"api_sig", nil];
   
    [self.requestOperationManager
     GET:@"?method=flickr.auth.getToken" parameters:params
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         NSLog(@"----%@----", operation.request.URL);
         NSString* token = [[responseObject objectForKey:@"auth"] objectForKey:@"token"];
         NSLog(@"%@", responseObject);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         
         if (failure){
             failure(error, operation.response.statusCode);
         }

     }];
}
@end
