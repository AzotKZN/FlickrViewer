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

@interface ViewController ()

@property (strong, nonatomic) NSMutableArray* albumArray;
@property (strong, nonatomic) NSMutableArray* photosArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.photosArray = [NSMutableArray array];
   // [self getAlbumFromServer];
    
    [self getPhotoFromServer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - API

-(void) getAlbumFromServer {
    [[ServerManager sharedManager]
     getListForUser_id:@"126076261@N03"
     per_page:3
     page:1
     format:@"json"
     nojsoncallback:1
     onSuccess:^(NSArray *albums) {
         
         [self.albumArray addObjectsFromArray:albums];
     }
     onFailure:^(NSError *error, NSInteger statusCode) {
        NSLog(@"error = %@, code = %d", [error localizedDescription], statusCode);
     }];
}

-(void) getPhotoFromServer {
    [[ServerManager sharedManager]
     getPhotoForPhotoset_id:@"72157650265404535"
     format:@"json"
     nojsoncallback:1
     onSuccess:^(NSArray *photos) {
         
         [self.photosArray addObjectsFromArray:photos];
         [self.tableView reloadData];
     }
     onFailure:^(NSError *error, NSInteger statusCode) {
         NSLog(@"error = %@, code = %d", [error localizedDescription], statusCode);
     }];
}


#pragma mark - UITableViewDataSource

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
