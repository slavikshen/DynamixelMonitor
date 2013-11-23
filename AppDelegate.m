//
//    Controller.m      Controller for the defaults settings
//
//    Copyright (C) 2010  Christian Balkenius
//
//    This program is free software; you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation; either version 2 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program; if not, write to the Free Software
//    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
//
//    Created: April 1, 2010
//

#import "AppDelegate.h"
#import "JSWrapper.h"
#import "ControlPanelController.h"
#import "FileDocument.h"

#define defaultValue @"/dev/tty.usbserial-AD01UY2K"
#define myKey @"device"

@implementation AppDelegate {
    BOOL _appHasLaunched;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    _appHasLaunched = YES;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:[NSNumber numberWithBool:NO] forKey:@"NSNavLastUserSetHideExtensionButtonState"];
    
    NSString *string = [defaults stringForKey:myKey];
    if (string == nil) string = defaultValue;
    [self.myTextField setStringValue:string];

    [self _openLastDocument];
    
//    ControlPanelController* controlPanelController = [[ControlPanelController alloc] initWithWindowNibName:@"ControlPanelController"];
//    self.controlPanelController = controlPanelController;
//    
//    [controlPanelController.window makeKeyAndOrderFront:nil];
   
//    double delayInSeconds = 1.0;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        [controlPanelController.window makeKeyAndOrderFront:nil];
//    });
    
    
}


- (void)textFieldAction:(id)sender
{

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *string;

    string = [self.myTextField stringValue];

    if ([string isEqualToString:defaultValue]) {
        [defaults removeObjectForKey:myKey];
    } else {
        [defaults setObject:string forKey:myKey];
    }
    
    [self.myWindow orderOut: self];
}

//- (IBAction)openDocument:(id)sender {
//    NSLog(@"open document");
//}
//
//- (IBAction)newDocument:(id)sender {
// 
//    NSLog(@"new document");
//    
//}

-(void)applicationWillFinishLaunching:(NSNotification *)notification
{

    
}


//- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender
//{
//    // On startup, when asked to open an untitled file, open the last opened
//    // file instead
//    if (!_appHasLaunched) {
//        if( [self _openLastDocument] ) {
//            return NO;
//        }
//    }
//    return YES;
//}

- (void)_openLastDocument {
    // Get the recent documents
    NSDocumentController *controller =
    [NSDocumentController sharedDocumentController];
    NSArray *documents = [controller recentDocumentURLs];
    
    // If there is a recent document, try to open it.
    if ([documents count] > 0) {
        NSURL* url = [documents objectAtIndex:0];
        [controller openDocumentWithContentsOfURL:url display:YES completionHandler:^(NSDocument *document, BOOL documentWasAlreadyOpen, NSError *error) {
            if( nil == document ) {
                [[NSDocumentController sharedDocumentController] newDocument:nil];
            }
        }];
    }
}


@end
