//
//  ViewController.m
//  FlickrViewer
//
//  Created by Азат on 26.01.15.
//  Copyright (c) 2015 Azat Minvaliev. All rights reserved.
//

#import "ViewController.h"
#import "ServerManager.h"
#import "ServerResponse.h"
#import "UIImageView+AFNetworking.h"
#import "Frob.h"
#import <CommonCrypto/CommonDigest.h>

@interface ViewController ()

@property (strong, nonatomic) NSMutableArray* albumArray;
@property (strong, nonatomic) NSMutableArray* photosArray;
@property (strong, nonatomic) NSString* token;
@property (assign, nonatomic) BOOL firstTimeAppear;
@property (strong, nonatomic) Frob* frob;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.photosArray = [NSMutableArray array];
    [self getAlbumFromServer];
    
    [self getPhotoFromServer];
    self.firstTimeAppear = YES;
    [[ServerManager sharedManager] authorizeUser:^(ServerResponse *user) {
        NSLog(@"BoOoOm!");
    }];
   
    UIRefreshControl* refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refreshWall) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;

    UIBarButtonItem* plus =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                  target:self
                                                  action:@selector(choosePhoto:)];
    
    self.navigationItem.rightBarButtonItem = plus;

}

-(IBAction) choosePhoto:(id) sender {
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    
// if((UIButton *) sender == choosePhotoBtn) { //Если будет выбор откуда грузить
        picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
// } else {
//     picker.sourceType = UIImagePickerControllerSourceTypeCamera;
//  }
    
    [self presentModalViewController:picker animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
   [picker dismissModalViewControllerAnimated:YES];
    ServerManager* sm = [[ServerManager alloc] init];
    
    UIImage* img = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    [sm uploadImage:img];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if (self.firstTimeAppear) {
        self.firstTimeAppear = NO;
        
        [[ServerManager sharedManager] authorizeUser:^(ServerResponse *user) {
            
            NSLog(@"AUTHORIZED!");
           // NSLog(@"%@ %@", user.firstName, user.lastName);
        }];
        
    }
    
}

NSString * md5( NSString *str ) {
    const char *cStr = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), result );
    
    return [[NSString stringWithFormat: @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X", result[0], result[1],   result[2], result[3], result[4], result[5], result[6], result[7], result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]] lowercaseString];
}

#pragma mark - API

-(void) getAlbumFromServer {
    [[ServerManager sharedManager]
     getListForUser_id:@"130931950@N04"
     per_page:3
     page:1
     format:@"json"
     nojsoncallback:1
     onSuccess:^(NSArray *albums) {
         
         [self.albumArray addObjectsFromArray:albums];
     }
     onFailure:^(NSError *error, NSInteger statusCode) {
        NSLog(@"error = %@, code = %d", [error localizedDescription], (long)statusCode);
     }];
}

-(void) getPhotoFromServer {
    [[ServerManager sharedManager]
     getPhotoForPhotoset_id:@"72157650776215095"
     format:@"json"
     nojsoncallback:1
     onSuccess:^(NSArray* photos) {
         
         [self.photosArray addObjectsFromArray:photos];
         [self.tableView reloadData];
     }
     onFailure:^(NSError *error, NSInteger statusCode) {
         NSLog(@"error = %@, code = %d", [error localizedDescription], (long)statusCode);
     }];
}

-(void) getTokenFromServer:(NSString*)Frob11 {
    NSString* hash = [@"d2cac5f203e27181api_keyffd2e06854c5dea003eb9270d5b86b13formatjsonfrob" stringByAppendingString: Frob11];
    hash = [hash stringByAppendingString: @"methodflickr.auth.getTokennojsoncallback1permsdelete"];
    NSString *api_sig = md5(hash);
    
    
    [[ServerManager sharedManager]
     getTokenForFrob:Frob11
     format:@"json"
     nojsoncallback:1
     api_sig:api_sig
     onSuccess:nil
     onFailure:^(NSError *error, NSInteger statusCode) {
         NSLog(@"error = %@, code = %ld", [error localizedDescription], (long)statusCode);
     }];
}

#pragma mark - UITableViewDataSource

- (void) refreshWall {
    
    [[ServerManager sharedManager]
     getPhotoForPhotoset_id:@"72157650776215095"
     format:@"json"
     nojsoncallback:1
     onSuccess:^(NSArray* photos) {
         
         [self.photosArray removeAllObjects];
         
         [self.photosArray addObjectsFromArray:photos];
         
         [self.tableView reloadData];
         
         [self.refreshControl endRefreshing];
     }
     onFailure:^(NSError *error, NSInteger statusCode) {
         NSLog(@"error = %@, code = %ld", [error localizedDescription], statusCode);
         
         [self.refreshControl endRefreshing];
     }];
    
}




- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.photosArray count] + 1;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* identifier = @"Cell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    if (indexPath.row == [self.photosArray count]) {
        
//        cell.imageView.image = nil;

        
    } else {
        
        ServerResponse* photo = [self.photosArray objectAtIndex:indexPath.row];
        
        NSURLRequest* request = [NSURLRequest requestWithURL:photo.imageURL];
        
        __weak UITableViewCell* weakCell = cell;
 
        cell.imageView.image = nil;
        
        [cell.imageView
         setImageWithURLRequest:request
         placeholderImage:nil
         success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
             weakCell.imageView.image = image;
             [weakCell layoutSubviews];
         }
         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
             
         }];
        
    }
    
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == [self.photosArray count]) {
        [self getPhotoFromServer];
    }
    
}


@end
