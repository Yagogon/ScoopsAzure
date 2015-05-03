//
//  AGTScoopsWriterTableViewController.m
//  ScoopsAzure
//
//  Created by Yago de la Fuente on 28/4/15.
//  Copyright (c) 2015 cinnika. All rights reserved.
//

#import "AGTScoopsWriterTableViewController.h"
#import "AGTScoopsAzure.h"
#import "Scoop.h"
#import "Constants.h"
#import "AGTNewScoopViewController.h"

@interface AGTScoopsWriterTableViewController ()

@property (strong, nonatomic) NSMutableArray *model;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;

@end

@implementation AGTScoopsWriterTableViewController

-(id)initWithStyle:(UITableViewStyle)style {
    
    if (self = [super initWithStyle:style]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateTable:)
                                                     name:SCOOP_ADDED_NOTIFICATION
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(refreshTable:)
                                                     name:SCOOP_WAS_PUBLISHED
                                                   object:nil];
    }
    
    return self;
}

-(void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.model = [[NSMutableArray alloc] init];
    
    AGTScoopsAzure *azure = [[AGTScoopsAzure alloc] init];
    
    
    [self addActivityIndicator];
    
    
    [azure populateModelFromAzure:^(NSArray *array) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.model = [array mutableCopy];
            [self.tableView reloadData];
            [self.spinner stopAnimating];
        });
    }];
    
    [azure userInfo:^(id result) {
        NSDictionary *info = result;
        NSLog(@"User info : %@", result);
        NSURL *url = [NSURL URLWithString:info[@"picture"][@"data"][@"url"]];
        [self profileImageWithURL:url completionBlock:^(NSData *data) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:data]];
                imageView.layer.cornerRadius = imageView.frame.size.width / 2;
                imageView.clipsToBounds = YES;
                self.navigationItem.titleView = imageView;
            });
        }];
    }];
    
    
    
    UIBarButtonItem *barButtom = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                               target:self
                                                                               action:@selector(createScoop:)];
    self.navigationItem.rightBarButtonItem = barButtom;
    
    
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
     
   
        [self state:cell scoop:scoop];
    }
  
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Scoop *scoop = [self.model objectAtIndex:indexPath.row];
    
    AGTScoopsAzure *azure = [[AGTScoopsAzure alloc] init];
    
    [azure scoopWithTitle:scoop.title completion:^(NSArray *array) {
        
        Scoop *scoop = [[Scoop alloc] initWithDict:[array objectAtIndex:0]];
        
        AGTNewScoopViewController *sVC = [[AGTNewScoopViewController alloc]
                                          initWithScoop:scoop];
        
        [self.navigationController pushViewController:sVC
                                             animated:YES];
    }];
    
    
}

#pragma mark - Actions

-(IBAction)createScoop :(id)sender {
    
    AGTNewScoopViewController *newScoopVC = [[AGTNewScoopViewController alloc] initWithScoop:nil];
    
    [self.navigationController pushViewController:newScoopVC animated:YES];
    
}

#pragma mark - Notification

-(void) updateTable: (NSNotification *) notification {
    
    NSDictionary *dict = [notification.userInfo objectForKey:SCOOP_KEY];
    
    [self.model addObject:[[Scoop alloc]initWithDict:dict]];
    
    [self.tableView reloadData];
    
}

-(void) refreshTable: (NSNotification *) notification {
    
    [self.tableView reloadData];
}

#pragma mark - Utils

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

-(void) profileImageWithURL: (NSURL *)url completionBlock: (void (^)(NSData * data))completionBlock {
    
    NSURLSessionConfiguration *conf = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *downloadSession = [NSURLSession sessionWithConfiguration:conf];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionDataTask *task = [downloadSession dataTaskWithRequest:request
                                                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                        
                                                        completionBlock(data);
                                                    }];
    [task resume];
    
    
}

- (void)state:(UITableViewCell *)cell scoop:(Scoop *)scoop {
    if (scoop.aprobada) {
        cell.accessoryView  = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"aprobada.png"]];
    } else {
        cell.accessoryView  = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no_enviada.png"]];
        
    }
    [cell.accessoryView setFrame:CGRectMake(0, 0, 30, 30)];
}

@end
