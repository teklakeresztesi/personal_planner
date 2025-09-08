//
//  SpeechManager.h
//  PersonalPlanner
//
//  Created by Keresztesi Tekla on 04.09.2025.
//

#import "SpeechManagerDelegate.h"
#import <Speech/Speech.h>

@protocol PermissionHandlingProtocol <NSObject>

+ (void)requestRecordPermissionWithCompletionHandler:(void (^)(BOOL granted))response;
+ (void)requestAuthorization:(void(^)(SFSpeechRecognizerAuthorizationStatus status))handler;

@end

@interface SpeechManager: NSObject

@property (nonatomic, weak) id<SpeechManagerDelegate> delegate;
@property (nonatomic, assign) BOOL isListening;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

+ (instancetype)sharedInstance;

- (BOOL)isAllApproved;
- (BOOL)isAnyDenied;
- (void)requestPermissions;
- (BOOL)startListening;
- (void)stopListening;

@end
