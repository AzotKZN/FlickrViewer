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
#import <CommonCrypto/CommonDigest.h>

@interface ServerManager ()

@property (strong, nonatomic) AFHTTPRequestOperationManager* requestOperationManager;
@property (strong, nonatomic) AccessToken* accessToken;
@property (strong,nonatomic) AccessToken* auth_token;
@property (nonatomic) Boolean isUploading;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end

NSString* token = nil;

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
    self.isUploading = NO;
    if (self) {
        NSURL* url = [NSURL URLWithString:@"https://api.flickr.com/services/"];
        
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
     GET:@"rest/?method=flickr.photosets.getList"
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
     GET:@"rest/?method=flickr.photosets.getPhotos"
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
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:@"ffd2e06854c5dea003eb9270d5b86b13", @"api_key",
                            (Frob), @"frob",
                            (format), @"format",
                            @(nojsoncallback), @"nojsoncallback",
                           @"delete", @"perms",
                            (api_sig), @"api_sig", nil];
    [self.requestOperationManager
     GET:@"rest/?method=flickr.auth.getToken" parameters:params
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         token = [[[responseObject objectForKey:@"auth"] objectForKey:@"token"] objectForKey:@"_content"];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         
         if (failure){
             failure(error, operation.response.statusCode);
         }

     }];
}

NSString * md6( NSString *str ) {
    const char *cStr = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), result );
    
    return [[NSString stringWithFormat: @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X", result[0], result[1],   result[2], result[3], result[4], result[5], result[6], result[7], result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]] lowercaseString];
}

-(void)uploadImage:(UIImage*)img
{
    if(self.isUploading == NO){
            NSString *desc = @"descriptionText";
            NSString *tag = @"tagText";
        
        
            NSString *uploadSig = md6([NSString stringWithFormat:@"d2cac5f203e27181api_keyffd2e06854c5dea003eb9270d5b86b13auth_token%@description%@tags%@",  token, desc, tag]);
        
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setURL:[NSURL URLWithString:@"https://up.flickr.com/services/upload/"]];
            [request setHTTPMethod:@"POST"];
            
            NSString *boundary = @"---------------------------7d44e178b0434";
            
            [request addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField: @"Content-Type"];
            
            NSMutableData *body = [NSMutableData data];
            [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"Content-Disposition: form-data; name=\"api_key\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"%@\r\n", @"ffd2e06854c5dea003eb9270d5b86b13"] dataUsingEncoding:NSUTF8StringEncoding]];
            
            
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"Content-Disposition: form-data; name=\"auth_token\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"%@\r\n", token] dataUsingEncoding:NSUTF8StringEncoding]];
            
            
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"Content-Disposition: form-data; name=\"api_sig\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"%@\r\n", uploadSig] dataUsingEncoding:NSUTF8StringEncoding]];
            
            
            
            //Description
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"description\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"%@",desc] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            
            
            //Tag
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"tags\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"%@",tag] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            
            //Image
            UIImage *image = img;
            NSData *imageData = UIImageJPEGRepresentation(image, 0.9);
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"photo\"; filename=\"%@\"\r\n", @"titleText"] dataUsingEncoding:NSUTF8StringEncoding]];
            
            [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            
            [body appendData:imageData];
            
            
            [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [request setHTTPBody:body];
        
            [self.spinner startAnimating];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            self.isUploading = YES;
            NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            [theConnection start];
        NSLog(@"%@", theConnection); }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Загрузка уже идет!"
                                                        message:@"Одно изображение уже загружается, пожалуйста, не спешите."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)theData
{
    
    //Надо будет добавить обработку ошибок
    
    
    NSLog(@"send %@",[[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding]);
    [self.spinner stopAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.isUploading = NO;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Загрузка завершена!"
                                                    message:@"Ваше изображение уже на Flikr!"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
}


@end
