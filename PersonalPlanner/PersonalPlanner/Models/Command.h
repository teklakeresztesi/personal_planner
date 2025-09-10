//
//  Command.h
//  PersonalPlanner
//
//  Created by Keresztesi Tekla on 04.09.2025.
//

#import <Foundation/Foundation.h>
#import "CommandType.h"

@interface Command : NSObject

@property (nonatomic, strong) NSString *text;
@property (nonatomic, assign) CommandType type;

- (id)initWithText:(NSString *)text type:(CommandType)type;

@end
