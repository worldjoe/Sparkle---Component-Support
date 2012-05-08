//
//  TurboTaxPatcherAppDelegate.m
//  TurboTaxPatcher
//
//  Created by Joseph Elwell on 6/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TurboTaxPatcherAppDelegate.h"
//#import "Sparkle/SUupdater.h"
#import "Sparkle/SUupdaterDiffPatcher.h"

@implementation TurboTaxPatcherAppDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
	NSString *filePath = [[NSBundle mainBundle] pathForResource:@"patch" ofType:@"delta"];
	// if the patch type is not a delta/leapfrog
	// then it's a fallback/prime patch and it's extension is different
	Boolean fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
	if (!fileExists)
	{
		filePath = [[NSBundle mainBundle] pathForResource:@"patch" ofType:@"tar.gz"];
	}
	NSProcessInfo *proc = [NSProcessInfo processInfo];
	NSArray *args = [proc arguments];
	
	if([args count] > 2){
		NSString* appPath = [args objectAtIndex: 2];
		//NSString* appPath = @"/Users/jelwell/Desktop/junk/TurboTax2011.app/";
		NSLog(@"Info: Trying to patch %@ with patch file %@", appPath, filePath);
		NSBundle* appBundle = [NSBundle bundleWithPath:appPath];
		SUUpdater* updater = [SUUpdater updaterForBundle: appBundle];
		[updater setDelegate: self];
		if(updater != nil){
			[updater applyUpdate: nil patchFile:filePath];
		}
	}
	else {
		NSLog(@"Error: %@ did was not passed a destination path", [proc processName]);
	}


}

@end
