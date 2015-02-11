//
//  UserLoginViewController.m
//  FlickrViewer
//
//  Created by Азат on 05.02.15.
//  Copyright (c) 2015 Azat Minvaliev. All rights reserved.
//

#import "UserLoginViewController.h"
#import "Frob.h"
#import "CommonCrypto/CommonDigest.h"
#import "ViewController.h"
@interface UserLoginViewController ()

@property (copy, nonatomic) UserLoginCompletionBlock completionBlock;
@property (weak, nonatomic) UIWebView* webView;

@end

@implementation UserLoginViewController

-(id) initWithCompletionBlock:(UserLoginCompletionBlock) completionBlock
{
    self = [super init];
    if (self) {
        self.completionBlock = completionBlock;
    }
    return self;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGRect r = self.view.bounds;
    r.origin = CGPointZero;
    
    UIWebView* webView = [[UIWebView alloc] initWithFrame:r];
    
    webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [self.view addSubview:webView];
    
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                          target:self
                                                                          action:@selector(actionCancel:)];
    [self.navigationItem setRightBarButtonItem:item animated:NO];
    
    self.navigationItem.title = @"Login";
    
    NSString* urlString =
    @"http://www.flickr.com/services/auth/?"
    "api_key=ffd2e06854c5dea003eb9270d5b86b13&"
    "perms=delete&"
     "api_sig=1a293fa750b61947eb4c4b53f317ea26"
    ;
    NSURL* url = [NSURL URLWithString:urlString];
    
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    
    webView.delegate = self;
    
    [webView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Actions

- (void) actionCancel:(UIBarButtonItem*) item {
    
    if (self.completionBlock) {
        self.completionBlock(nil);
    }
    
    [self dismissViewControllerAnimated:YES
                             completion:nil];
    
}

#pragma mark - Web-view

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {

    if ([[[request URL] path] isEqualToString:@"/azat.flickr.app"]) {
        Frob* frobFlickr = [[Frob alloc] init];
        
        NSString* query = [[request URL] description];
        
        NSArray* array = [query componentsSeparatedByString:@"?"];
        
        if ([array count] > 1) {
            query = [array lastObject];
        }
        
        NSArray* pairs = [query componentsSeparatedByString:@"&"];
        
        for (NSString* pair in pairs) {
            
            NSArray* values = [pair componentsSeparatedByString:@"="];
            
            if ([values count] == 2) {
                
                NSString* key = [values firstObject];
                
                if ([key isEqualToString:@"frob"]) {
                    
                    frobFlickr.frob = [values lastObject];
                 
                    NSLog(@"FROB= %@", frobFlickr.frob);
                    
                }
            }
        }
        
        
        
        self.webView.delegate = nil;
        if (self.completionBlock) {
            self.completionBlock(frobFlickr);
            ViewController* vc = [[ViewController alloc] init];
            [vc getTokenFromServer:frobFlickr.frob];
        }
        
        
        
        [self dismissViewControllerAnimated:YES
                                 completion:nil];
        
        
        return NO;
    }
    
    
    
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
