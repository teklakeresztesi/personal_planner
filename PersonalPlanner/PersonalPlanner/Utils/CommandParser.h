//
//  CommandParser.h
//  PersonalPlanner
//
//  Created by Keresztesi Tekla on 08.09.2025.
//

#import "Command.h"

@interface CommandParser : NSObject

+ (Command*)getCommand:(NSString *)text;

@end
