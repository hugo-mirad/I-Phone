//
//  CarRecord.m
//  XMLTable2
//
//  Created by Mac on 14/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CarRecord.h"

@implementation CarRecord
@synthesize imagePath=_imagePath,make=_make,model=_model,price=_price,sellerType=_sellerType,sellerName=_sellerName,sellerID=_sellerID,phone=_phone,address1=_address1,address2=_address2,exteriorColor=_exteriorColor,numberOfDoors=_numberOfDoors,fueltype=_fueltype,transmission=_transmission,driveTrain=_driveTrain,vin=_vin,pic0=_pic0,picLoc0=_picLoc0,carid=_carid,year=_year,mileage=_mileage,zipCode=_zipCode,pageCount=_pageCount,totalRecords=_totalRecords,email=_email,city=_city,state=_state,extraDescription=_extraDescription,interiorColor=_interiorColor,ConditionDescription=_ConditionDescription,sellerEmail=_sellerEmail;

@synthesize thumbnailUIImage=_thumbnailUIImage,presentInMyList=_presentInMyList,presentInPreference=_presentInPreference;

@synthesize hasImage=_hasImage,failedToDownload=_failedToDownload;

@synthesize uid=_uid,makeID=_makeID,modelID=_modelID,stateID=_stateID,bodytype=_bodytype, bodytypeID=_bodytypeID;

@synthesize title=_title,engineCylinders=_engineCylinders;

@synthesize fuelTypeId=_fuelTypeId,adStatus=_adStatus;

@synthesize packageID=_packageID;//,paymentID=_paymentID,postingID=_postingID;

-(id)init
{
    return [self initWithDictionary:nil];
}
-(id)initWithDictionary:(NSDictionary *)tempDict
{
    self=[super init];
    if (self) {
        _make=[tempDict objectForKey:@"_make"];
        _model=[tempDict objectForKey:@"_model"];
        
        
        _sellerType=[tempDict objectForKey:@"_sellerType"];
        _sellerName=[tempDict objectForKey:@"_sellerName"];
        _phone=[tempDict objectForKey:@"_phone"];
        _address1=[tempDict objectForKey:@"_address1"];
        _address2=[tempDict objectForKey:@"_address2"];
        _exteriorColor=[tempDict objectForKey:@"_exteriorColor"];
        _numberOfDoors=[tempDict objectForKey:@"_numberOfDoors"];
        _fueltype=[tempDict objectForKey:@"_Fueltype"];
        _transmission=[tempDict objectForKey:@"_Transmission"];
        _driveTrain=[tempDict objectForKey:@"_DriveTrain"];
        _vin=[tempDict objectForKey:@"_VIN"];
        _pic0=[tempDict objectForKey:@"_PIC0"];
        _picLoc0=[tempDict objectForKey:@"_PICLOC0"];
        _zipCode=[tempDict objectForKey:@"_zipcode"];
        _pageCount=[tempDict objectForKey:@"_PageCount"];
        _totalRecords=[tempDict objectForKey:@"_TotalRecords"];
        _email=[tempDict objectForKey:@"_email"];
        _city=[tempDict objectForKey:@"_city"];
        _state=[tempDict objectForKey:@"_state"];
        _extraDescription=[tempDict objectForKey:@"_description"];
        _interiorColor=[tempDict objectForKey:@"_interiorColor"];
        _ConditionDescription=[tempDict objectForKey:@"_ConditionDescription"];
        _sellerEmail=[tempDict objectForKey:@"_email"];
        
        _title = [tempDict objectForKey:@"_Title"];
        _engineCylinders = [tempDict objectForKey:@"_numberOfCylinder"];
        
        //uid,makeID,modelID,stateID,bodytypeID
        _uid=[NSString stringWithFormat:@"%d",[[tempDict objectForKey:@"uid"]integerValue]];
        _makeID=[NSString stringWithFormat:@"%d",[[tempDict objectForKey:@"_makeID"]integerValue]];
        _modelID=[NSString stringWithFormat:@"%d",[[tempDict objectForKey:@"_makeModelID"]integerValue]];
        
        //this condition is not required with real credentials
        if ([tempDict objectForKey:@"_stateID"]==nil || [[tempDict objectForKey:@"_stateID"] isKindOfClass:[NSNull class]]) {
            _stateID=@"0";
        }
        else
        {
            _stateID=[NSString stringWithFormat:@"%d",[[tempDict objectForKey:@"_stateID"]integerValue]];
        }
        _bodytype=[tempDict objectForKey:@"_bodytype"];
        _bodytypeID=[NSString stringWithFormat:@"%d",[[tempDict objectForKey:@"_bodytypeID"]integerValue]];
        
        _fuelTypeId=[NSString stringWithFormat:@"%d",[[tempDict objectForKey:@"_FueltypeId"]integerValue]];
        
        _sellerID=[NSString stringWithFormat:@"%d",[[tempDict objectForKey:@"_sellerID"]integerValue]];
        _adStatus=[tempDict objectForKey:@"_AdStatus"];
        
        
        _packageID=[NSString stringWithFormat:@"%d",[[tempDict objectForKey:@"_packageID"]integerValue]];
        /*
         _paymentID=[NSString stringWithFormat:@"%d",[[tempDict objectForKey:@"_paymentID"]integerValue]];
         
         _postingID=[NSString stringWithFormat:@"%d",[[tempDict objectForKey:@"_postingID"]integerValue]];
         */
        /*
         NSInteger carid,year,mileage,price;
         
         */
        _carid=[[tempDict objectForKey:@"_carid"]integerValue];
        _year=[[tempDict objectForKey:@"_yearOfMake"]integerValue];
        _mileage=[[tempDict objectForKey:@"_mileage"]integerValue];
        _price=[[tempDict objectForKey:@"_price"]integerValue];  //price is numeric in json. So convert to string. Otherwise we have to convert to string when displaying in cell.
        //we have to do currency formatiing on price. So we are not converting here. We will convert to string in cellforrow after currency formatting
        
        
        _thumbnailUIImage=nil;
        _imagePath=nil;
        _presentInMyList=0;
        _presentInPreference=NO;
        
        
        ///
        NSString *completeimagename1=nil;
        //condition to check whether PICLOC0 is empty or not
        if (![[tempDict objectForKey:@"_PICLOC0"] isEqualToString:@"Emp"]) {
            completeimagename1=[[NSString alloc]initWithFormat:@"http://www.unitedcarexchange.com/%@/%@",[tempDict objectForKey:@"_PICLOC0"],[tempDict objectForKey:@"_PIC0"]];
            
            
        }
        
        else if ([[tempDict objectForKey:@"_PICLOC0"] isEqualToString:@"Emp"])
        {
            completeimagename1=[NSString stringWithFormat:@"http://www.unitedcarexchange.com/%@",[tempDict objectForKey:@"_PIC0"]];
            
        }
        completeimagename1 =[completeimagename1 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        _imagePath=completeimagename1;
    }
    return self;
}

-(BOOL)hasImage
{
    return _thumbnailUIImage!=nil;
}

-(BOOL)failedToDownload
{
    return _failedToDownload;
}


-(void)dealloc
{
    
    _imagePath=nil;
    _make=nil;
    _model=nil;
    _sellerType=nil;
    _sellerName=nil;
    _phone=nil;
    _address1=nil;
    _address2=nil;
    _exteriorColor=nil;
    _numberOfDoors=nil;
    _fueltype=nil;
    _transmission=nil;
    _driveTrain=nil;
    _vin=nil;
    _pic0=nil;
    _picLoc0=nil;
    _zipCode=nil;
    _pageCount=nil;
    _totalRecords=nil;
    _email=nil;
    _thumbnailUIImage=nil;
    _extraDescription=nil;
    _interiorColor=nil;
    _ConditionDescription=nil;
    _sellerEmail=nil;
    _packageID=nil;
}

@end
