/*
The MIT License (MIT)

Copyright (c) 2018 INTUZ

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
//  iCloudKeyValueManager.m

#import "iCloudKeyValueManager.h"

@implementation iCloudKeyValueManager

-(id)init {
    self = [super init];
    if (self != nil) {
        // code here
    }
    return self;
}

-(void)setupiCloudEnableKey {
    if (![NSStandardUserDefaults boolForKey:kEnableiCloudKey]) { // if key does not exist in userdefault.
        [NSStandardUserDefaults setBool:NO forKey:kEnableiCloudKey];
    }else {
        if ([NSStandardUserDefaults boolForKey:kEnableiCloudKey]==YES) {
            [self addObserverForiCloud];
            [[NSUbiquitousKeyValueStore defaultStore] synchronize];
        }
    }
}

- (void)addObserverForiCloud {
    id token = [[NSFileManager defaultManager] ubiquityIdentityToken];
    if (token) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveUpdatesFromiCloud:) name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification object:[NSUbiquitousKeyValueStore defaultStore]];
        [[NSUbiquitousKeyValueStore defaultStore] synchronize];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushUpdatesToiCloud:) name:kUserDefaultsDidUpdatedNotification object:[NSUbiquitousKeyValueStore defaultStore]];
    }else {
        [ToastView show:@"iCloud is not configured."];
    }
}

- (void)removeObserverForiCloud {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification object:[NSUbiquitousKeyValueStore defaultStore]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kUserDefaultsDidUpdatedNotification object:[NSUbiquitousKeyValueStore defaultStore]];
}

-(void)pushUpdatesToiCloud:(NSNotification *)notification {

    for (NSString *key in NSStandardUserDefaults)
    {
        if (![key isEqualToString:kEnableiCloudKey]) {
            [[NSUbiquitousKeyValueStore defaultStore] setObject: [NSStandardUserDefaults objectForKey: key] forKey: key];
        }
    }
    [[NSUbiquitousKeyValueStore defaultStore] synchronize];
}

-(void)receiveUpdatesFromiCloud:(NSNotification *)notification {
    
    [self printReason:[[notification userInfo] objectForKey:NSUbiquitousKeyValueStoreChangeReasonKey]];
    
    //for (NSString *key in [[notification userInfo] objectForKey:NSUbiquitousKeyValueStoreChangedKeysKey])
    for (NSString *key in [[NSUbiquitousKeyValueStore defaultStore] dictionaryRepresentation]) {
        if (![key isEqualToString:kEnableiCloudKey]) {
            [NSStandardUserDefaults setObject: [[NSUbiquitousKeyValueStore defaultStore] objectForKey: key]
                                       forKey: key];
        }
    }
    [NSStandardUserDefaults synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kReceiveUpdatesFromiCloudNotification object:nil];
}

-(void)printReason:(NSNumber*)reason {
    if (reason) {
        NSInteger reasonValue = [reason integerValue];
        NSLog(@"keyValueStoreChanged with reason %ld", (long)reasonValue);
        if (reasonValue == NSUbiquitousKeyValueStoreInitialSyncChange) {
            NSLog(@"Initial sync");
        }else if (reasonValue == NSUbiquitousKeyValueStoreServerChange) {
            NSLog(@"Server change sync");
        }else {
            NSLog(@"Another reason");
        }
    }
}

@end
