//
//  CommandType.m
//  PersonalPlanner
//
//  Created by Keresztesi Tekla on 08.09.2025.
//

#import <Foundation/Foundation.h>
#import "CommandType.h"

/// Description
NSString *NSStringFromCommandType(CommandType type) {
    switch (type) {
        case CommandTypeSchedule: return @"Schedule";
        case CommandTypeReminder: return @"Reminder";
        case CommandTypeToDo: return @"ToDo";
        case CommandTypeUnknown:
        default: return @"Unknown";
    }
}
