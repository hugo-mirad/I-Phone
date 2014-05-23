//
//  CarRecord.h
//  XMLTable2
//
//  Created by Mac on 14/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


@interface CarRecord:NSObject

@property(copy,nonatomic) NSString *imagePath,*make,*model,*sellerType,*sellerName,*phone,*address1,*address2,*exteriorColor,*numberOfDoors,*fueltype,*transmission,*driveTrain,*vin,*pic0,*picLoc0,*zipCode,*pageCount,*totalRecords,*email,*city,*state,*description,*interiorColor,*ConditionDescription,*sellerEmail;
@property(assign,nonatomic) NSInteger carid,year,mileage,price;


@property(strong,nonatomic) UIImage *thumbnailUIImage;
@property(assign,nonatomic) NSInteger presentInMyList;
@property(assign,nonatomic) BOOL presentInPreference;

@property(assign,nonatomic) BOOL hasImage,failedToDownload;


-(id)initWithDictionary:(NSDictionary *)tempDict;

@end
