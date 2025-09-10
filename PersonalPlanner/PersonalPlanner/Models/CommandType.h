//
//  CommandType.h
//  PersonalPlanner
//
//  Created by Keresztesi Tekla on 08.09.2025.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CommandType) {
    CommandTypeSchedule,
    CommandTypeReminder,
    CommandTypeToDo,
    CommandTypeStop,
    CommandTypeUnknown
};

FOUNDATION_EXPORT NSString *NSStringFromCommandType(CommandType type);
