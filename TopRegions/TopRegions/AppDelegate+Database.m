//
//  AppDelegate+Database.m
//  TopRegions
//
//  Created by Scott Kensell on 2/14/14.
//  Copyright (c) 2014 Scott Kensell. All rights reserved.
//

#import "AppDelegatePrivate.h"

static NSString *databaseName = @"database";

@implementation AppDelegate (Database)

- (void)openManagedDocument {
    UIManagedDocument *document = [[UIManagedDocument alloc] initWithFileURL:[self urlForManagedDocument]];
    NSString *url = [document.fileURL path];
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    if ([defaultManager fileExistsAtPath:url]) {
        [document openWithCompletionHandler:^(BOOL success) {
            if (success) [self documentIsReady:document];
            else ERROR(@"Failed to open managed document (possible scheme change) at %@", url);
        }];
    } else {
        [document saveToURL:document.fileURL
           forSaveOperation:UIDocumentSaveForCreating
          completionHandler:^(BOOL success) {
              if (success) [self documentIsReady:document];
              else ERROR(@"Failed to create managed document (possible scheme change) at %@", url);
          }];
    }
}

- (void)documentIsReady:(UIManagedDocument *)document {
    if (document.documentState == UIDocumentStateNormal) {
        self.databaseContext = document.managedObjectContext;
    } else {
        ERROR(@"Document did not open properly. Instead of UIDocumentStateNormal, it's in state %d", document.documentState);
    }
}

- (NSURL *)urlForManagedDocument {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsDirectory = [[fileManager URLsForDirectory:NSDocumentDirectory
                                                     inDomains:NSUserDomainMask] firstObject];
    return [documentsDirectory URLByAppendingPathComponent:databaseName];
}



@end
