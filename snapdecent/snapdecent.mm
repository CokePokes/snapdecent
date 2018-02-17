//
//  snapdecent.mm
//  snapdecent
//
//  Created by CokePokes on 2/16/18.
//  Copyright (c) 2018 ___ORGANIZATIONNAME___. All rights reserved.
//

// CaptainHook by Ryan Petrich
// see https://github.com/rpetrich/CaptainHook/

#if TARGET_OS_SIMULATOR
#error Do not support the simulator, please use the real iPhone Device.
#endif

#import <Foundation/Foundation.h>
#import "CaptainHook/CaptainHook.h"

@interface FBBundleInfo : NSObject
@property (nonatomic,copy) NSString * displayName;
@property (nonatomic,copy) NSString * bundleIdentifier;
@end
@interface FBApplicationInfo : FBBundleInfo
@property (nonatomic,retain,readonly) NSDictionary * environmentVariables;
@property (nonatomic,retain,readonly) NSURL * dataContainerURL;
-(NSDictionary*)environmentVariables;
-(NSURL *)dataContainerURL;
@end
@interface SBApplication : NSObject
-(id)bundleContainerPath;
-(id)initWithApplicationInfo:(id)arg1 ;
-(id)dataContainerPath;
@end
@interface SBApplicationController : NSObject
+(id)_sharedInstanceCreateIfNecessary:(BOOL)arg1 ;
+(id)sharedInstance;
+(id)sharedInstanceIfExists;
-(id)applicationWithBundleIdentifier:(id)arg1 ;
-(id)applicationWithDisplayIdentifier:(id)arg1;
@end

CHDeclareClass(FBApplicationInfo);
CHOptimizedMethod0(self, NSDictionary*, FBApplicationInfo, environmentVariables) //probably could find a better method to hook. eh, everything i need is right here rather than using the ever changing SBApplication API.
{
    NSDictionary *originalEnv = CHSuper0(FBApplicationInfo, environmentVariables);
    if ([self.displayName isEqualToString:@"Snapchat"] || [self.bundleIdentifier isEqualToString:@"com.toyopagroup.picaboo"]){
        NSString *path = [NSString stringWithFormat:@"%@/Documents/zero-dep.plist", [self dataContainerURL].path];
        NSFileManager *fm = [NSFileManager defaultManager];
        NSError *error = nil;
        // Get the current permissions
        NSDictionary *currentPerms = [fm attributesOfFileSystemForPath:path error:&error];
        if (currentPerms) {
            // Update the permissions with the new permission
            NSMutableDictionary *attributes = [currentPerms mutableCopy];
            //if (attributes[NSFilePosixPermissions]){ needs a better check. Oh whale.
            attributes[NSFilePosixPermissions] = @(0000);
            if (![fm setAttributes:attributes ofItemAtPath:path error:&error]) {
                NSLog(@"Unable to make %@ strict: %@", path, error);
            }
            //}
        } else {
            NSLog(@"Unable to read permissions for %@: %@", path, error);
        }
    }
    return originalEnv;
}

CHConstructor
{
    @autoreleasepool
    {
        CHLoadLateClass(FBApplicationInfo);
        CHHook0(FBApplicationInfo, environmentVariables);
    }
}
