//
//  AppDelegate.h
//  DBDataChangeToFile
//
//  Created by roc on 16/12/15.
//  Copyright © 2016年 roc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

//托管上下文
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

//托管模型
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
//托管协调者
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;


@end

