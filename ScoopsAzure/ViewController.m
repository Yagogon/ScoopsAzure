//
//  ViewController.m
//  ScoopsAzure
//
//  Created by Yago de la Fuente on 28/4/15.
//  Copyright (c) 2015 cinnika. All rights reserved.
//

#import "ViewController.h"
#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import "Keys.h"
#import "AGTNewScoopViewController.h"
#import "AGTScoopsAzure.h"


@interface ViewController  (){
    
    MSClient * client;
    
    NSString *userFBId;
    NSString *tokenFB;
}

@end

@implementation ViewController

- (void)loginFB {
    //login
    
    AGTScoopsAzure *azure = [[AGTScoopsAzure alloc] init];
    
     AGTNewScoopViewController *sVC = [[AGTNewScoopViewController alloc] initWithScoop:nil];
    
    [azure loginAppInViewController:self destinationController:sVC withCompletion:^(NSArray *results) {
        
        NSLog(@"Resultados ---> %@", results);
        
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib
    
    [self loginFB];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
