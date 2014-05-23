//
//  DownloadModelsOperation.h
//  XMLTable2
//
//  Created by Mac on 14/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//  moved private ivars to .m

#import <Foundation/Foundation.h>

extern NSString *kDownloadModelsNotif;
extern NSString *kModelsDictNotifKey;

@interface DownloadModelsOperation : NSOperation


-(id)init;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property(strong,nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end