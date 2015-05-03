//
//  AGTReaderScoopsTableViewController.m
//  ScoopsAzure
//
//  Created by Yago de la Fuente on 2/5/15.
//  Copyright (c) 2015 cinnika. All rights reserved.
//

#import "AGTReaderScoopsTableViewController.h"
#import "AGTScoopsAzure.h"
#import "Scoop.h"
#import "AGTScoopReaderViewController.h"

@interface AGTReaderScoopsTableViewController ()

@property (strong, nonatomic) NSMutableArray *model;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;

@end

@implementation AGTReaderScoopsTableViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    AGTScoopsAzure *azure = [[AGTScoopsAzure alloc] init];
    
    [azure loginAppInViewController:self destinationController:self withCompletion:^(NSArray *results) {
        
        NSLog(@"Resultados ---> %@", results);
        
        self.model = [[NSMutableArray alloc] init];
        [self addActivityIndicator];
        
        [azure populateReaderModelFromAzure:^(NSArray *array) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.model = [array mutableCopy];
                [self.spinner stopAnimating];
                [self.tableView reloadData];
            });
            
        }];

        
    }];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.model.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"ScoopCell";
    
    // Crear la celda
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:cellIdentifier];
    }
    
    
    Scoop *scoop = [self.model objectAtIndex:indexPath.row];
    // Configure the cell...
    cell.textLabel.text = scoop.title;
    cell.imageView.image = [UIImage imageNamed:@"no_image.png"];
    
    if (scoop.image) {
        cell.imageView.image = [UIImage imageWithData:scoop.image];
    } else {
        
        [self updateCellImage:cell
                    imageName:scoop.blobName
                   completion:^(NSData *data) {
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           UIImage *image = [UIImage imageWithData:data];
                           scoop.image = data;
                           cell.imageView.image = image;
                           
                       });
                   }];
        
        
    }
    
    [self likes:cell scoop:scoop];

    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
    Scoop *scoop = [self.model objectAtIndex:indexPath.row];
    
    AGTScoopsAzure *azure = [[AGTScoopsAzure alloc] init];
    
    [azure scoopWithTitle:scoop.title completion:^(NSArray *array) {
        
        Scoop *scoop = [[Scoop alloc] initWithDict:[array objectAtIndex:0]];
        
        AGTScoopReaderViewController *sVC = [[AGTScoopReaderViewController alloc]
                                          initWithScoop:scoop];
        
        [self.navigationController pushViewController:sVC
                                             animated:YES];
    }];
}

#pragma mark - Utils

- (void)addActivityIndicator {
    UIView *view = self.view;
    self.spinner = [[UIActivityIndicatorView alloc]
                    initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    CGRect frame = self.spinner.frame;
    frame.origin.x = view.frame.size.width / 2 - frame.size.width / 2;
    frame.origin.y = view.frame.size.height / 2 - frame.size.height / 2;
    self.spinner.frame = frame;
    [view addSubview:self.spinner];
    [self.view bringSubviewToFront:self.spinner];
    [self.spinner startAnimating];
}

-(void) updateCellImage: (UITableViewCell *) cell imageName: (NSString *) blobName completion: (void (^)(NSData * data))completionBlock{
    
    if (blobName) {
        
        AGTScoopsAzure *azure = [[AGTScoopsAzure alloc] init];
        
        [azure blobReadURLWithBlobName:blobName completion:^(NSURL *url) {
            
            NSURLSessionConfiguration *conf = [NSURLSessionConfiguration defaultSessionConfiguration];
            NSURLSession *downloadSession = [NSURLSession sessionWithConfiguration:conf];
            
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            
            NSURLSessionDataTask *task = [downloadSession dataTaskWithRequest:request
                                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                                
                                                                completionBlock(data);
                                                            }];
            [task resume];
            
            
        }];
    }
    
}

- (void)likes:(UITableViewCell *)cell scoop:(Scoop *)scoop {
    if (scoop.likes > 0) {
        cell.accessoryView  = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"like.jpeg"]];
    } else {
        cell.accessoryView  = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no_like.jpg"]];
        
    }
    [cell.accessoryView setFrame:CGRectMake(0, 0, 30, 30)];
}



@end
