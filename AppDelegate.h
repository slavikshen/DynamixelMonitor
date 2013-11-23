//
//    Controller.h      Controller for the defaults settings
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


#import <Cocoa/Cocoa.h>

@class ControlPanelController;

@interface AppDelegate : NSObject<NSApplicationDelegate> {
}

@property (assign) IBOutlet NSTextField *myTextField;
@property (assign) IBOutlet NSWindow *myWindow;

@property (nonatomic,strong) ControlPanelController* controlPanelController;

- (IBAction)textFieldAction:(id)sender;
- (void)applicationDidFinishLaunching:(NSNotification *)notification;

//- (IBAction)openDocument:(id)sender;
//- (IBAction)newDocument:(id)sender;

@end
