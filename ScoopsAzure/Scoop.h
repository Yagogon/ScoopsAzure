//
//  Scoop.h
//  Scoops
//
//  Created by Juan Antonio Martin Noguera on 17/04/15.
//  Copyright (c) 2015 Cloud On Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;

@interface Scoop : NSObject

- (id)initWithTitle:(NSString*)title
           andPhoto:(NSData *)img
              aText:(NSString*)text
           anUserId:(NSString *) anUserId
           anAuthor:(NSString *)author
              aCoor:(CLLocationCoordinate2D) coors
           blobName: (NSString *)blobName;

-(id)initWithDict: (NSDictionary *)dict;

@property (readonly) NSString *title;
@property (readonly) NSString *text;
@property (readonly) NSString *author;
@property (readonly) CLLocationCoordinate2D coors;
@property (nonatomic, strong) NSData *image;
@property (readonly) NSDate *dateCreated;
@property BOOL publicada;
@property BOOL aprobada;
@property float points;
@property float latitude;
@property float longitude;
@property (readonly) NSString *userId;
@property (readonly) NSString *blobName;
@property int likes;

@end
