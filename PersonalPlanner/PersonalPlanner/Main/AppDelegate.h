//
//  AppDelegate.h
//  PersonalPlanner
//
//  Created by Keresztesi Tekla on 03.09.2025.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

