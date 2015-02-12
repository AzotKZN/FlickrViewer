//
//  ViewController.h
//  FlickrViewer
//
//  Created by Азат on 26.01.15.
//  Copyright (c) 2015 Azat Minvaliev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UITableViewController
-(void) getTokenFromServer:(NSString*) Frob11;
-(void) getPhotoFromServer;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
@end

