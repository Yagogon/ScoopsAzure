//
//  AGTScoopsAzure.h
//  ScoopsAzure
//
//  Created by Yago de la Fuente on 28/4/15.
//  Copyright (c) 2015 cinnika. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
@class Scoop;

typedef void (^profileCompletion)(NSDictionary* profInfo);
typedef void (^completeBlock)(NSArray* results);
typedef void (^completeOnError)(NSError *error);
typedef void (^completionWithURL)(NSURL *theUrl, NSError *error);

@interface AGTScoopsAzure : NSObject

-(void)saveScoopInAzure: (Scoop *) scoop errorBlock: (void (^)(NSError * error))errorBlock
        completionBlock:(void (^)(NSDictionary * result))completionBlock;

- (void)loginAppInViewController:(UIViewController *)controller
           destinationController: (UIViewController *) toController
                  withCompletion:(completeBlock)bloque;

-(void)populateModelFromAzure:  (void (^)(NSArray * array))completionBlock;

-(void) scoopWithTitle:(NSString *) title completion: (void (^)(NSArray * array))completionBlock;

-(void)saveBlobWithName: (NSString *) blobName data: (NSData *) data;

-(void)populateReaderModelFromAzure:  (void (^)(NSArray * array))completionBlock;

-(void) publishScoop: (Scoop *) scoop;

-(void) userInfo:(void (^)(id result))completionBlock;

-(void) blobURLWithBlobName: (NSString *) blobName completion: (void (^)(NSURL * url))completionBlock;

-(void) blobReadURLWithBlobName: (NSString *) blobName completion: (void (^)(NSURL * url))completionBlock;

-(void) likeScoop: (Scoop *) scoop vote: (NSNumber *) vote;

@end
