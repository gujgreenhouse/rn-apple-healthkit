//
//  RCTAppleHealthKit+Methods_Mindfulness.h
//  RCTAppleHealthKit
//
//

#import "RCTAppleHealthKit.h"

@interface RCTAppleHealthKit (Methods_Mindfulness)

- (void)mindfulness_canWriteMindfulSession:callback:(RCTResponseSenderBlock)callback;

- (void)mindfulness_saveMindfulSession:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback;

- (void)mindfulness_deleteAllMindfulSessions:(RCTResponseSenderBlock)callback;

@end
