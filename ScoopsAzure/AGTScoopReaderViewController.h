//
//  AGTScoopReaderViewController.h
//  ScoopsAzure
//
//  Created by Yago de la Fuente on 2/5/15.
//  Copyright (c) 2015 cinnika. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Scoop;

@interface AGTScoopReaderViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *bodyText;
@property (weak, nonatomic) IBOutlet UIImageView *photo;

- (IBAction)like:(id)sender;
- (IBAction)noLike:(id)sender;

-(id)initWithScoop: (Scoop *) scoop;

@end
