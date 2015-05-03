//
//  ViewController.h
//  ScoopsAzure
//
//  Created by Yago de la Fuente on 28/4/15.
//  Copyright (c) 2015 cinnika. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^profileCompletion)(NSDictionary* profInfo);
typedef void (^completeBlock)(NSArray* results);
typedef void (^completeOnError)(NSError *error);
typedef void (^completionWithURL)(NSURL *theUrl, NSError *error);

@interface ViewController : UIViewController


@end

