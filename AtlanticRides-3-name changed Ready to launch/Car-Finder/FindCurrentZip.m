//
//  FindCurrentZip.m
//  GPS1
//
//  Created by Mac on 15/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FindCurrentZip.h"
#import "Reachability.h"

@interface FindCurrentZip()


@property(strong,nonatomic) CLLocationManager *locationMgr;
@property(assign,nonatomic) NSInteger noUpdates;
@property(strong,nonatomic) Reachability *hostReachable;

@end


@implementation FindCurrentZip
@synthesize delegate=_delegate,locationMgr=_locationMgr,noUpdates=_noUpdates,hostReachable=_hostReachable;


-(void)findCurrentZip:(CLLocation *)loc
{
    CLLocation *userLocation = [[CLLocation alloc] initWithLatitude:loc.coordinate.latitude
                                                          longitude:loc.coordinate.longitude];
    __block NSString *zipcode=nil;
    
    
    CLGeocoder *myGeocoder = [[CLGeocoder alloc] init];
    
    __weak FindCurrentZip *weakSelf=self;
    
    [myGeocoder 
     reverseGeocodeLocation:userLocation
     completionHandler: (id)^(NSArray *placemarks, NSError *error) {
         if (error == nil && [placemarks count] > 0)
         {
             //             NSLog(@"Placemarks: %@",placemarks);
             CLPlacemark *placemark = [placemarks objectAtIndex:0]; 
             //             NSLog(@"Country = %@", placemark.country);
             //NSLog(@"Postal Code = %@", placemark.postalCode);
             zipcode = placemark.postalCode;
             //             NSLog(@"Locality = %@", placemark.locality);
             //             NSLog(@"Country%@",[placemarks lastObject]);
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(didSendZip:)])
                 {
                     [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                     [weakSelf.delegate didSendZip:zipcode];
                 }
             });
             
         }
         else if (error == nil && [placemarks count] == 0)
         {
             //NSLog(@"No results were returned.");
             dispatch_async(dispatch_get_main_queue(), ^{
                 if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(didSendZip:)])
                 {
                     [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                     
                     [weakSelf.delegate didSendZip:nil];
                 }
             });
         }
         else if (error != nil)
         {
             NSLog(@"error is %@ in %@:%@",[error localizedDescription],NSStringFromClass([self class]),NSStringFromSelector(_cmd));
             dispatch_async(dispatch_get_main_queue(), ^{
                 if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(didSendZip:)])
                 {
                     [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                     [weakSelf.delegate didSendZip:nil];
                 }
             });
         }
     }];
    
    userLocation=nil;
    myGeocoder=nil;
    
}

-(void)FindingZipCode
{
    
    // check if a pathway to your host exists
    self.hostReachable = [Reachability reachabilityWithHostName: @"www.unitedcarexchange.com"];
    [self.hostReachable startNotifier];
    
    // now patiently wait for the notification
    
    
    NSString *locationMgrClassStr=@"CLLocationManager";
    Class locationMgrClass=NSClassFromString(locationMgrClassStr);
    
    if(locationMgrClass!=nil)
    {
        if([CLLocationManager locationServicesEnabled])
        {
            self.locationMgr = [[CLLocationManager alloc] init];
            
            self.locationMgr.delegate = self;
            
            self.locationMgr.distanceFilter = kCLDistanceFilterNone;
            self.locationMgr.desiredAccuracy = kCLLocationAccuracyBest;
            
            self.noUpdates=0;
            
            
            [self.locationMgr startUpdatingLocation];
        }
        else
        {
            //        NSLog(@"location services are disabled on your device");
            
            UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled" message:@"You currently have all location services for this device disabled. If you proceed, you will be asked to confirm whether location services should be reenabled." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [servicesDisabledAlert show];
            servicesDisabledAlert=nil;
            
        }
    }
    else
    {
        __weak FindCurrentZip *weakSelf=self;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(didSendZip:)])
                [weakSelf.delegate didSendZip:nil];
        });
    }
    
}


-(void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *) newLocation fromLocation:(CLLocation*) oldLocation
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    });
    
    self.noUpdates++;
    if (self.noUpdates >= 1)
        [self.locationMgr stopUpdatingLocation];
    
    //    NSLog(@"The coordinates are latitude=%f longitude=%f",newLocation.coordinate.latitude,newLocation.coordinate.longitude);
    self.hostReachable=[Reachability reachabilityForInternetConnection];
    
    NetworkStatus networkStatus=[self.hostReachable currentReachabilityStatus];
    if (networkStatus==NotReachable) {
        
        
        //display alert
        __weak FindCurrentZip *weakSelf=self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(didSendZip:)])
                [weakSelf.delegate didSendZip:nil];
        });
        
    }
    else
    {
        [self findCurrentZip:newLocation];
    }
    
}

- (void)locationManager: (CLLocationManager *)manager didFailWithError: (NSError *)error
{
    //raise a notifcation and give an option for the CustomTable to display an alert view so that user can manually enter zip code.
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"ErrorFindingLocationNotif" object:self];
    });
}

-(void)dealloc
{
    [_hostReachable stopNotifier];
    
    _delegate=nil;
    _locationMgr.delegate=nil;
    _locationMgr=nil;
    
    _hostReachable=nil;
}

@end
