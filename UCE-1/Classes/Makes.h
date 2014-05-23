//
//  Makes.h
//  MakesModels
//
//  Created by Mac on 06/04/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Makes : NSManagedObject

@property (nonatomic, copy) NSString * makeID;
@property (nonatomic, copy) NSString * makeName;

@end
