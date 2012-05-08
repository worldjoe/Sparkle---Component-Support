//
//  main.m
//  TurboTaxPatcher
//
//  Created by Joseph Elwell on 6/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

int main(int argc, char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; 
	
	int result = NSApplicationMain(argc,  (const char **) argv);
	
	NSLog(@"TurboTaxPatcher result %d", result);
	[pool drain];
	
	return result;
}
