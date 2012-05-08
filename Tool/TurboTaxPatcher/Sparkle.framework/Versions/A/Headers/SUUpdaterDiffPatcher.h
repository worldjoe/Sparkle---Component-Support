//
//  SUUpdaterDiffPatcher.h
//  Sparkle
//
//  Created by Joseph Elwell on 6/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SUUpdater.h"

@interface SUUpdaterDiffPatcher : SUUpdater {

}

// Call this to jump right into the process of applying a patch
- (IBAction)applyUpdate:sender patchFile:(NSString *) patchFile;


@end
