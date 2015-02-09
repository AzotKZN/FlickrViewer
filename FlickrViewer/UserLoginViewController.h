//
//  UserLoginViewController.h
//  FlickrViewer
//
//  Created by Азат on 05.02.15.
//  Copyright (c) 2015 Azat Minvaliev. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AccessToken;
typedef void(^UserLoginCompletionBlock)(AccessToken* token);

@interface UserLoginViewController : UIViewController

-(id) initWithCompletionBlock:(UserLoginCompletionBlock) completionBlock;

@end
