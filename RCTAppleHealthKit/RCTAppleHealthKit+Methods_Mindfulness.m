//
//  RCTAppleHealthKit+Methods_Mindfulness.m
//  RCTAppleHealthKit
//
//


#import "RCTAppleHealthKit+Methods_Mindfulness.h"
#import "RCTAppleHealthKit+Queries.h"
#import "RCTAppleHealthKit+Utils.h"

@implementation RCTAppleHealthKit (Methods_Sleep)

- (void)canWriteMindfulSession:(RCTResponseSenderBlock)callback {
    self.healthStore = [[HKHealthStore alloc] init];
    
    if ([HKHealthStore isHealthDataAvailable]) {
        HKObjectType *type = [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierMindfulSession];
        
        HKAuthorizationStatus canWriteStatus = [self.healthStore authorizationStatusForType:(type)];
        
        BOOL canWrite = canWriteStatus == HKAuthorizationStatusSharingAuthorized;
        
        callback(@[[NSNull null], @(canWrite)]);
    } else {
        callback(@[[NSNull null], @false]);
    }
}


- (void)mindfulness_saveMindfulSession:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback
{
    double value = [RCTAppleHealthKit doubleFromOptions:input key:@"value" withDefault:(double)0];
    NSDate *startDate = [RCTAppleHealthKit dateFromOptions:input key:@"startDate" withDefault:nil];
    NSDate *endDate = [RCTAppleHealthKit dateFromOptions:input key:@"endDate" withDefault:[NSDate date]];

    if(startDate == nil || endDate == nil){
        callback(@[RCTMakeError(@"startDate and endDate are required in options", nil, nil)]);
        return;
    }

    HKCategoryType *type = [HKCategoryType categoryTypeForIdentifier: HKCategoryTypeIdentifierMindfulSession];
    HKCategorySample *sample = [HKCategorySample categorySampleWithType:type value:value startDate:startDate endDate:endDate];


    [self.healthStore saveObject:sample withCompletion:^(BOOL success, NSError *error) {
        if (!success) {
            NSLog(@"An error occured saving the mindful session sample %@. The error was: %@.", sample, error);
            callback(@[RCTMakeError(@"An error occured saving the mindful session sample", error, nil)]);
            return;
        }
        callback(@[[NSNull null], @(value)]);
    }];
}


- (void)mindfulness_deleteAllMindfulSessions:(RCTResponseSenderBlock)callback
{
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierEndDate ascending:false];
    HKSampleType *mindfulType = [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierMindfulSession];
    
    // Get all samples from 1970 until now
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:0];
    NSDate *endDate = [NSDate date];
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionNone];
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:mindfulType predicate:predicate limit:0 sortDescriptors:@[sortDescriptor] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
        if (results.count == 0) {
            RCTLog(@"No objects found");
            callback(@[[NSNull null], @0]);
            return;
        }
        [self.healthStore deleteObjects:results withCompletion:^(BOOL success, NSError * _Nullable error) {
            RCTLog(@"Deleted %d, error %@", results.count, error);
            callback(@[[NSNull null], @(results.count)]);
        }];
    }];
    
    [self.healthStore executeQuery:query];
}


@end
