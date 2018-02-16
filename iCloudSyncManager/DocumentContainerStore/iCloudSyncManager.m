/*
The MIT License (MIT)

Copyright (c) 2018 INTUZ

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
#import "iCloudSyncManager.h"

@implementation iCloudSyncManager 

+ (iCloudSyncManager *)sharedInstance {
    static dispatch_once_t once;
    static iCloudSyncManager *sharedInstance;
    dispatch_once(&once, ^ {
        sharedInstance = [[iCloudSyncManager alloc] init];
    });
    return sharedInstance;
}

-(id)copyWithZone:(NSZone *)zone {    
    return self;
}
-(void)setupiCloud {
    // Setup iCloud
    [[iCloud sharedCloud] setDelegate:self]; // Set this if you plan to use the delegate
    [[iCloud sharedCloud] setVerboseLogging:YES];
    
    [[iCloud sharedCloud] setupiCloudDocumentSyncWithUbiquityContainer:nil]; // You must call this setup method before performing any document operations
}

-(void)readDocumentFromiCloud {
    NSLog(@"readDocumentFromiCloud");
    [self retriveiCloudDocumentWithFileName:kStandardUserDefaultLocalFile];
}

-(void)addObserverForSaveDocumentToiCloud {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(savePrefrenceFileOniCloudDirectory:) name:kUserDefaultsDidUpdatedNotification object:[NSUbiquitousKeyValueStore defaultStore]];
}

-(void)removeObserverForSaveDocumentToiCloud {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kUserDefaultsDidUpdatedNotification object:[NSUbiquitousKeyValueStore defaultStore]];
}

- (void)savePrefrencesOnLocalDirectory {
    NSString *strFilePath = [FMDBManager getDoumentDirectoryPath:kStandardUserDefaultLocalFile];
    NSDictionary *dictUserDefault = [NSStandardUserDefaults dictionaryRepresentation];
    [dictUserDefault writeToFile:strFilePath atomically:YES];
}

- (void)savePrefrenceFileOniCloudDirectory:(NSNotification*)notification {
    
    NSArray *arrFiles = [[iCloud sharedCloud] listCloudFiles];
    if (arrFiles.count) {
        [arrFiles enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSURL *fileURL = obj;
            NSString *strFilePath = [fileURL.absoluteString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [[iCloud sharedCloud] deleteDocumentWithName:strFilePath.lastPathComponent completion:^(NSError *error) {
                if (!error) {
                    if ((arrFiles.count-1) == idx) { // save new document after last file deleted from icloud.
                        [self saveAndCloseDocument];
                    }
                }else {
                    NSLog(@"Error while deleting file %@",error.localizedDescription);
                }
            }];
        }];
    }else {
            [self saveAndCloseDocument];
    }
}

-(void)saveAndCloseDocument {
    [self savePrefrencesOnLocalDirectory];
    NSData *fileData = [NSData dataWithContentsOfFile:[FMDBManager getDoumentDirectoryPath:kStandardUserDefaultLocalFile]];
    [[iCloud sharedCloud] saveAndCloseDocumentWithName:kStandardUserDefaultLocalFile withContent:fileData completion:^(UIDocument *cloudDocument, NSData *documentData, NSError *error) {
        if (!error) {
            NSLog(@"iCloud Document saved sucessfully.");
            [[iCloud sharedCloud] updateFiles];
        } else {
            NSLog(@"iCloud Document save error: %@", error);
        }
    }];
}
#pragma mark - iCloud Methods
- (void)iCloudDidFinishInitializingWitUbiquityToken:(id)cloudToken withUbiquityContainer:(NSURL *)ubiquityContainer {
    NSLog(@"Ubiquity container initialized. You may proceed to perform document operations.");
}

- (void)iCloudAvailabilityDidChangeToState:(BOOL)cloudIsAvailable withUbiquityToken:(id)ubiquityToken withUbiquityContainer:(NSURL *)ubiquityContainer {
    if (!cloudIsAvailable) {
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"iCloud Unavailable"
                                      message:@"iCloud is no longer available. Make sure that you are signed into a valid iCloud account."
                                      preferredStyle:UIAlertControllerStyleAlert];
        UIWindow *window=[UIApplication sharedApplication].keyWindow;
        [[window rootViewController] presentViewController:alert animated:YES completion:nil];
    }
}

- (void)iCloudFilesDidChange:(NSMutableArray *)files withNewFileNames:(NSMutableArray *)fileNames {
    // Get the query results
    NSLog(@"Files: %@", fileNames);
    [self retriveiCloudDocumentWithFileName:kStandardUserDefaultLocalFile];
}

-(void)retriveiCloudDocumentWithFileName:(NSString*)fileName {
    
    [[iCloud sharedCloud] retrieveCloudDocumentWithName:fileName completion:^(UIDocument *cloudDocument, NSData *documentData, NSError *error) {
        if (!error) {
            if (cloudDocument.documentState != UIDocumentStateClosed) {
                if ([documentData length]) {
                    [documentData writeToFile:[FMDBManager getDoumentDirectoryPath:kStandardUserDefaultiCloudFile] atomically:YES];
                    [self updateUserDefaultValues];
                }
            }
        } else {
            NSLog(@"Error retrieveing document: %@", error);
        }
    }];
}

-(void)updateUserDefaultValues {
    NSDictionary *dictUserDefaluts = [[NSDictionary alloc]initWithContentsOfFile:[FMDBManager getDoumentDirectoryPath:kStandardUserDefaultiCloudFile]];
    for (NSString *key in dictUserDefaluts)
    {
        if (![key isEqualToString:kEnableiCloudKey]) {
            [NSStandardUserDefaults setObject: [dictUserDefaluts objectForKey: key]
                                       forKey: key];
        }
    }
    [NSStandardUserDefaults synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kReceiveUpdatesFromiCloudNotification object:nil];
}

@end
