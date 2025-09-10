//
//  SpeechManagerDelegate.h
//  PersonalPlanner
//
//  Created by Keresztesi Tekla on 07.09.2025.
//

#import <Foundation/Foundation.h>

@protocol SpeechManagerDelegate <NSObject>

@optional
- (void)speechManager:(id)sender handleText:(NSString *)text;
- (void)speechManager:(id)sender handleFinalText:(NSString *)text;
- (void)permissionsUpdated:(id)sender;

@end
