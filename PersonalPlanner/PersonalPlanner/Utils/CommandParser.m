//
//  CommandParser.m
//  PersonalPlanner
//
//  Created by Keresztesi Tekla on 08.09.2025.
//

#import <Foundation/Foundation.h>
#import "CommandParser.h"

@implementation CommandParser: NSObject

+ (Command *)getCommand:(NSString *)text {
    NSString *lowercase = text.lowercaseString;
    if ([lowercase containsString:@"schedule"]) {
        return [[Command alloc] initWithText:text type:CommandTypeSchedule];
    } else if ([lowercase containsString:@"remind"]) {
        return [[Command alloc] initWithText:text type:CommandTypeReminder];
    } else if ([lowercase containsString:@"to do"] || [text containsString:@"list"]) {
        return [[Command alloc] initWithText:text type:CommandTypeToDo];
    } else if ([lowercase containsString:@"stop"]) {
        return [[Command alloc] initWithText:text type:CommandTypeStop];
    }

    return [[Command alloc] initWithText:text type:CommandTypeUnknown];
}

@end
