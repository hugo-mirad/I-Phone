//
//  Makes.h
//  Car-Finder
//
//  Created by Venkata Chinni on 10/21/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Makes : NSManagedObject

@property (nonatomic, retain) NSString * makeID;
@property (nonatomic, retain) NSString * makeName;
@property (nonatomic, retain) NSNumber * carsCount;

@end
