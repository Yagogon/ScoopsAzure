//
//  AGTScoopReaderViewController.m
//  ScoopsAzure
//
//  Created by Yago de la Fuente on 2/5/15.
//  Copyright (c) 2015 cinnika. All rights reserved.
//

#import "AGTScoopReaderViewController.h"
#import "Scoop.h"
#import "AGTScoopsAzure.h"

@interface AGTScoopReaderViewController ()

@property (strong, nonatomic) Scoop *scoop;

@end

@implementation AGTScoopReaderViewController

#pragma mark - Init



-(id)initWithScoop: (Scoop *) scoop {
    
    if (self = [super initWithNibName:nil
                               bundle:nil]) {
        _scoop = scoop;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self syncModelAndView];
    
}

#pragma mark - Utils

-(void) syncModelAndView {
    
    self.titleLabel.text = self.scoop.title;
    self.bodyText.text = self.scoop.text;
    
    self.photo.image = [UIImage imageNamed:@"no_image.png"];
    
    [self updateImageWithName:self.scoop.blobName
                   completion:^(NSData *data) {
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           self.photo.image = [UIImage imageWithData:data];
                       });
                       
                   }];
}

-(void) updateImageWithName:(NSString *) blobName completion: (void (^)(NSData * data))completionBlock{
    
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

#pragma mark - Actions

- (IBAction)like:(id)sender {
    
    AGTScoopsAzure *azure = [[AGTScoopsAzure alloc] init];
    [azure likeScoop:self.scoop vote:@+1];
}

- (IBAction)noLike:(id)sender {
    AGTScoopsAzure *azure = [[AGTScoopsAzure alloc] init];
    [azure likeScoop:self.scoop vote:@-1];
}

@end
