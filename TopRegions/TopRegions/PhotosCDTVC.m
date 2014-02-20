//
//  FlickrPhotoTableViewController.m
//  flickr_places
//
//  Created by Scott Kensell on 1/30/14.
//  Copyright (c) 2014 Scott Kensell. All rights reserved.
//

#import "PhotosCDTVC.h"

#import "Photo.h"
#import "FlickrFetcher.h"
#import "ImageViewController.h"

static NSString *tableViewCellIdentifier = @"Photo Cell";
static NSString *backgroundSessionConfigurationID = @"Thumbnail Fetch Session Config";

@interface PhotosCDTVC ()

@end

@implementation PhotosCDTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupWithTitle:nil
 tableViewCellIdentifier:tableViewCellIdentifier
segueIdentifierToNextViewController:@"Show Photo"
classOfViewControllerAfterSegue:[ImageViewController class]];
}


#pragma mark - TableView data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:tableViewCellIdentifier];
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = photo.title;
    cell.detailTextLabel.text = photo.subtitle;
    if (photo.thumbnail) {
        cell.imageView.image = [[UIImage alloc] initWithData:photo.thumbnail];
    } else {
        [self fetchThumbnailForPhoto:photo];
    }
    return cell;
}

#pragma mark - Navigation

- (void)prepareNextViewController:(UIViewController *)vc
          afterSelectingIndexPath:(NSIndexPath *)indexPath
                  segueIdentifier:(NSString *)segueIdentifier {
    Photo *photoToShow = [self.fetchedResultsController objectAtIndexPath:indexPath];
    photoToShow.lastViewed = [NSDate date];
    if ([vc isKindOfClass:[ImageViewController class]]) {
        ImageViewController *ivc = (ImageViewController *)vc;
        ivc.imageURL = [NSURL URLWithString:photoToShow.imageURL];
        ivc.title = photoToShow.title;
    }
}

#pragma mark - Thumbnail fetch

- (void)fetchThumbnailForPhoto:(Photo *)photo {
    if (photo.thumbURL && photo.thumbURL.length) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:photo.thumbURL]];
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
                                                        completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                                            NSData *thumbData = [NSData dataWithContentsOfFile:[location path]];
                                                            photo.thumbnail = thumbData;
                                                        }];
        [task resume];
    }
}

@end
