//
//  ProjectWindowController.m
//  DynamixelMonitor
//
//  Created by Slavik on 11/16/13.
//  Copyright (c) 2013 LUCS. All rights reserved.
//

#import "ProjectWindowController.h"
#import "ProjectDocument.h"
#import "ProjectItem.h"
#import "FileDocument.h"

#import "CodeViewController.h"
#import "MotionEditorController.h"

#import "Dynamixel.h"
#import "VDKQueue.h"

#define kIconImageSize 16.0f
#define kMinOutlineViewSplit	200.0f

NSString* const ProjectWindowControllerProperty_Document = @"document";
NSString* const ProjectWindowControllerProperty_Running = @"running";

@interface ProjectWindowController ()<VDKQueueDelegate>

@property (nonatomic,assign) ProjectDocument* projDocument;
@property(nonatomic,strong) VDKQueue* projectDirMonitor;

@property(nonatomic,strong) NSCache* docViewControllers;

@end

@implementation ProjectWindowController

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    
    NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
    if ([key isEqualToString:@"document"]) {
        // notify document change when the current editor controller change
        keyPaths = [keyPaths setByAddingObject:@"currentEditorController"];
    }
    return keyPaths;
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        NSImage* folderImage = [[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(kGenericFolderIcon)];
		[folderImage setSize:NSMakeSize(kIconImageSize, kIconImageSize)];
        self.folderIcon = folderImage;
        
        NSImage* projectImage = [NSImage imageNamed:@"robot_Template"];
        self.projectIcon = projectImage;
        
        NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
               selector:@selector(handleDocumentNeedWindowNotification:)
                   name:DocumentNeedWindowNotification
                 object:nil];
        
        [self addObserver:self
             constantKeys:@[ProjectWindowControllerProperty_Document,
                            ProjectWindowControllerProperty_Running]];
        
        Dynamixel* d = [Dynamixel sharedInstance];
        [d addObserver:self constantKeys:@[kDynamixelProperty_Connected]];

    }
    return self;
}

- (void)dealloc {

    Dynamixel* d = [Dynamixel sharedInstance];
    [d removeObserver:self constantKeys:@[kDynamixelProperty_Connected]];
    
    self.projDocument = nil;
    [self removeObserver:self constantKeys:@[ProjectWindowControllerProperty_Document,
                                             ProjectWindowControllerProperty_Running]];
    
    
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    VDKQueue* monitor = [[VDKQueue alloc] init];
    monitor.delegate = self;
    self.projectDirMonitor = monitor;
    
    NSCache* viewControllerCache = [[NSCache alloc] init];
    self.docViewControllers = viewControllerCache;
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    ProjectDocument* pdoc = self.projDocument;
    if( pdoc ) {
        self.projDocument.outlineView = self.outlineView;
        if( nil == pdoc.projectItem ) {
            // request to create a existing project
            [pdoc performSelector:@selector(saveDocumentAs:) withObject:nil afterDelay:0.1f];
        } else {
            [self _updateDocumentWindowInfo];
        }
        
    }
    
    [self _addDocument:pdoc.projectItem];
    
    [self _updateDebugStatus];
    [self _updateConnectionStatus];
    
    [self _collapseDebugView];
    
    self.editorSplitView.delegate = self;
    
}


-(void)handleDocumentNeedWindowNotification:(NSNotification *)notification {
    
//    NSDocument* doc = notification.object;

    
}

- (void)setCurrentEditorController:(DocumentViewController *)currentEditorController {
    
    if( _currentEditorController ) {
        NSView* view = _currentEditorController.view;
        [view removeFromSuperviewWithoutNeedingDisplay];
    }
    
    _currentEditorController = currentEditorController;
    
    if( _currentEditorController ) {
        NSView* view = _currentEditorController.view;
        NSView* contentView = self.contentView;
        view.frame = contentView.bounds;
        view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        [self.contentView addSubview:view];
    }
}

- (void)_showViewForDocument:(NSDocument*)doc {
    
    // there is a document for the item
    if( self.currentEditorController.document == doc ) {
        // do nothing
        return;
    }
    
    DocumentViewController* docViewController = nil;
    
    NSString* path = doc.fileURL.path;
    NSCache* cache = self.docViewControllers;
    
    docViewController = [cache objectForKey:path];
    if( nil == docViewController ) {
        //TODO: add more document type check here
        
        NSString* type = doc.fileType;
        if( [type isEqualToString:@"Motion"] ) {
            docViewController = [[MotionEditorController alloc] init];
        } else {
            docViewController = [[CodeViewController alloc] init];
        }        
        
        
        docViewController.document = doc;
        [self.docViewControllers setObject:docViewController forKey:path];
        [doc addWindowController:self];
    }

    self.currentEditorController = docViewController;
    
}

- (void)_switchToSelectedDocumentIfPossible {
    
    NSOutlineView* outline = self.outlineView;
    NSInteger row = outline.selectedRow;
    ProjectItem* item = [outline itemAtRow:row];
    NSDocument* itemDoc = item.document;

    ProjectWindowController* s = self;
    if( nil == itemDoc ) {
        // create document for the item
        NSString* fullPath = item.fullPath;
        NSURL* url = [NSURL URLWithString:_F(@"file://%@",fullPath)];
        [[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:url display:NO completionHandler:^(NSDocument *doc, BOOL documentWasAlreadyOpen, NSError *error) {
            if( doc ) {
                [doc addWindowController:s];
                item.document = doc;
                [self _showViewForDocument:doc];
            }
        }];
        
    } else {
        [self _showViewForDocument:itemDoc];
    }
    

}

-(void)setProjDocument:(ProjectDocument *)projDocument {
 
    if( _projDocument ) {
        _projDocument.outlineView = nil;
        [_projDocument removeObserver:self
                         constantKeys:@[
                                        ProjectDocumentProperty_FileURL
                                        ]];
        NSString* path = _projDocument.fileURL.path;
        NSString* prjPath = [path stringByDeletingLastPathComponent];
        
        VDKQueue* monitor = self.projectDirMonitor;
        [monitor removePath:prjPath];
    }
    
    _projDocument = projDocument;
    
    if( _projDocument ) {
     
        NSOutlineView* outlineView = self.outlineView;
        _projDocument.outlineView = outlineView;
        
        [_projDocument addObserver:self
                       constantKeys:@[
                                      ProjectDocumentProperty_FileURL
                                      ]];

        NSURL* url = _projDocument.fileURL;
        NSString* path = url.path;
        NSString* prjPath = [path stringByDeletingLastPathComponent];
        VDKQueue* monitor = self.projectDirMonitor;
        [monitor addPath:prjPath notifyingAbout:VDKQueueNotifyAboutRename|VDKQueueNotifyAboutLinkCountChanged];
        
        if( [self isWindowLoaded] ) {
            
            NSWindow* win = self.window;
            if( path ) {
                NSString* filename = [path lastPathComponent];
                [win setFrameAutosaveName:_F(@"dm_%@",filename)];
                win.title = filename;
            }
                
            [self _updateDocumentWindowInfo];
        }
    }
    
}

-(void)setDocument:(NSDocument *)document
{
    // NSLog(@"Will not set document to: %@",document);
    if( [document isKindOfClass:[ProjectDocument class]] ) {
        ProjectDocument* pdoc = (ProjectDocument*)document;
        self.projDocument = pdoc;
        [pdoc addWindowController:self];
    }
    
}

-(NSDocument*)document
{
    NSDocument* doc = self.currentEditorController.document;
    if( nil == doc ) {
        doc = self.projDocument;
    }
    return doc;
}

- (IBAction)saveDocument:(id)sender {
 
    NSDocument* doc = self.document;
    NSDocument* projDoc = self.projDocument;
    
    [doc saveDocument:sender];
    
    if( doc != projDoc && [projDoc isDocumentEdited] ) {
        [projDoc saveDocument:sender];
    }
    
}

- (IBAction)showInFinder:(id)sender {
 
    NSOutlineView* outline = self.outlineView;
    NSInteger row = outline.clickedRow;
    
    ProjectItem* item = [outline itemAtRow:row];
    NSString* path = item.fullPath;
    
    NSArray *fileURLs = @[[NSURL URLWithString:_F(@"file://%@",path)]];
    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:fileURLs];
    
}

- (IBAction)deleteDocument:(id)sender {
    
    NSOutlineView* outline = self.outlineView;
    NSInteger row = outline.clickedRow;
    
    ProjectItem* item = [outline itemAtRow:row];
    NSString* path = item.fullPath;

    NSFileManager* fm = [NSFileManager defaultManager];
    NSError* err = nil;
    [fm removeItemAtPath:path error:&err];
    
}


// Each document needs to be detached from the window controller before the window closes.
// In addition, any references to those documents from any child view controllers will also
// need to be cleared in order to ensure a proper cleanup.
// The windowWillClose: method does just that. One caveat found during debugging was that the
// window controller’s self pointer may become invalidated at any time within the method as
// soon as nothing else refers to it (using ARC). Since we’re disconnecting references to
// documents, there have been cases where the window controller got deallocated mid-way of
// cleanup. To prevent that, I’ve added a strong pointer to self and use that pointer exclusively
// in the windowWillClose: method.
-(void) windowWillClose:(NSNotification *)notification
{
    NSWindow * window = self.window;
    if (notification.object != window) {
        return;
    }
    
    self.projectDirMonitor.delegate = nil;
    self.projectDirMonitor = nil;
    
    // let's keep a reference to ourself and not have us thrown away while we clear out references.
    [self _closeDocument:self.projDocument.projectItem];
    
}

- (void)_closeDocument:(ProjectItem*)item {

    for( ProjectItem* child in item.children ) {
        [self _closeDocument:child];
    }
    
    NSDocument* doc = item.document;
    [doc removeWindowController:self];
    
}

- (void)_addDocument:(ProjectItem*)item {

    for( ProjectItem* child in item.children ) {
        [self _addDocument:child];
    }
    
    NSDocument* doc = item.document;
    [doc addWindowController:self];

}

- (void)_updateDocumentWindowInfo {
 
    NSWindow* win = self.window;
    ProjectDocument* pdoc = self.document;
    NSURL* url = pdoc.fileURL;
    if( url ) {
        NSString* path = url.path;
        NSString* filename = [path lastPathComponent];
//        [win setFrameAutosaveName:_F(@"dm_%@",filename)];
        win.title = filename;
    } else {
//        [win setFrameAutosaveName:nil];
//        win.title = @"Untitiled";
    }
    
}

- (void)_updateDebugStatus {
 
    BOOL isRunning = self.running;
    
    if( isRunning ) {
     
        [self.runToolbarItem setEnabled:NO];
        [self.stopToolbarItem setEnabled:YES];
        
        if( [self _isDebugViewCollapsed] ) {
            [self _uncollapseDebugView];
        }
        
    } else {

        [self.runToolbarItem setEnabled:YES];
        [self.stopToolbarItem setEnabled:NO];

    }
    
}

- (void)_updateConnectionStatus {
 
    Dynamixel* d = [Dynamixel sharedInstance];
    BOOL connected = d.connected;
    
    NSString* title = @"Connect";
    if( connected ) {
        title = @"Disconnect";
    }
    
    self.connectToolbarItem.label = title;
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if ( (__bridge void*)ProjectDocumentProperty_FileURL == context ||
         (__bridge void*)ProjectWindowControllerProperty_Document == context
    ) {
        [self _updateDocumentWindowInfo];
    } else if( (__bridge void*)ProjectWindowControllerProperty_Running == context ) {
        [self _updateDebugStatus];
    } else if( (__bridge void*)kDynamixelProperty_Connected == context ) {
        [self _updateConnectionStatus];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
}

#pragma mark - split view

- (void)_collapseDebugView {
    
    NSSplitView* splitView = self.editorSplitView;
    NSView *bottom = [[splitView subviews] objectAtIndex:1];
    NSView *top  = [[splitView subviews] objectAtIndex:0];
    [bottom setHidden:YES];
    [top setFrameSize:splitView.bounds.size];
    [splitView display];

}

- (void)_uncollapseDebugView {

    NSSplitView* splitView = self.editorSplitView;
    NSView *bottom = [[splitView subviews] objectAtIndex:1];
    NSView *top  = [[splitView subviews] objectAtIndex:0];
    [bottom setHidden:NO];
    CGFloat dividerThickness = [splitView dividerThickness];
    // get the different frames
    NSRect topFrame = [top frame];
    NSRect bottomFrame = [bottom frame];
    // Adjust left frame size
    
    CGFloat height = splitView.bounds.size.height;
    
    topFrame.size.height = (height-bottomFrame.size.height-dividerThickness);
    topFrame.origin.y = height - topFrame.size.height;
    bottomFrame.origin.y = 0;

    [top setFrameSize:topFrame.size];
    [bottom setFrame:bottomFrame];
    [splitView display];
    
}

- (BOOL)_isDebugViewCollapsed {
 
    NSSplitView* splitView = self.editorSplitView;
    NSView *bottom = [[splitView subviews] objectAtIndex:1];
    
    BOOL isCollapsed = [splitView isSubviewCollapsed:bottom];
    
    return isCollapsed;
    
}

// -------------------------------------------------------------------------------
//	splitView:constrainMinCoordinate:
//
//	What you really have to do to set the minimum size of both subviews to kMinOutlineViewSplit points.
// -------------------------------------------------------------------------------
- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedCoordinate ofSubviewAt:(NSInteger)index
{
    if( ![splitView isVertical] ) {
        return proposedCoordinate;
    } else {
        return proposedCoordinate + kMinOutlineViewSplit;
    }
}

// -------------------------------------------------------------------------------
//	splitView:constrainMaxCoordinate:
// -------------------------------------------------------------------------------
- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedCoordinate ofSubviewAt:(NSInteger)index
{
    if( [splitView isVertical] ) {
        return floorf(proposedCoordinate*0.3f);
    } else {
        return proposedCoordinate - kMinOutlineViewSplit;
    }
}

// -------------------------------------------------------------------------------
//	splitView:resizeSubviewsWithOldSize:
//
//	Keep the left split pane from resizing as the user moves the divider line.
// -------------------------------------------------------------------------------
- (void)splitView:(NSSplitView *)splitView resizeSubviewsWithOldSize:(NSSize)oldSize
{
    
    if( ![splitView isVertical] ) {
        
        // top bottom split view
        
        NSRect newFrame = [splitView bounds]; // get the new size of the whole splitView
        NSView *top = [[splitView subviews] objectAtIndex:0];
        NSView *bottom = [[splitView subviews] objectAtIndex:1];
        
        if( [splitView isSubviewCollapsed:bottom] ) {
            [top setFrame:newFrame];
        } else {
            NSRect topFrame = [top frame];
            NSRect bottomFrame = [bottom frame];
            
            CGFloat dividerThickness = [splitView dividerThickness];
            topFrame.size.height = newFrame.size.height-bottomFrame.size.height-dividerThickness;
            topFrame.origin.y = newFrame.size.height-topFrame.size.height;
            
            [top setFrame:topFrame];
            [bottom setFrame:bottomFrame];
        }
        
        
    } else {
        
        // left right split view
        
        NSRect newFrame = [splitView bounds]; // get the new size of the whole splitView
        NSView *left = [[splitView subviews] objectAtIndex:0];
        NSRect leftFrame = [left frame];
        NSView *right = [[splitView subviews] objectAtIndex:1];
        NSRect rightFrame = [right frame];
        
        CGFloat dividerThickness = [splitView dividerThickness];
        
        leftFrame.size.height = newFrame.size.height;
        
        rightFrame.size.width = newFrame.size.width - leftFrame.size.width - dividerThickness;
        rightFrame.size.height = newFrame.size.height;
        rightFrame.origin.x = leftFrame.size.width + dividerThickness;
        
        [left setFrame:leftFrame];
        [right setFrame:rightFrame];
    }
}

- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview {
    
    if( ![splitView isVertical] && [subview isKindOfClass:[NSScrollView class]] ) {
        return YES;
    }
    
    return NO;
    
}

- (BOOL)splitView:(NSSplitView *)splitView
shouldCollapseSubview:(NSView *)subview
forDoubleClickOnDividerAtIndex:(NSInteger)dividerIndex {
    
    if( ![splitView isVertical] && [subview isKindOfClass:[NSScrollView class]] ) {
        return YES;
    }
    
    return NO;
}



#pragma mark - outline

/* View Based OutlineView: See the delegate method -tableView:viewForTableColumn:row: in NSTableView.
 */
- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    static NSString* CELL_ID = @"ProjectCell";
    NSTableCellView* view = [outlineView makeViewWithIdentifier:CELL_ID owner:self];
    ProjectItem* pItem = item;
    if( view ) {
        NSImage* icon = nil;
        if( pItem.parent ) {
            if( [pItem isDir] ) {
                icon = self.folderIcon;
            } else {
                NSString* fullPath = pItem.fullPath;
                icon = [[NSWorkspace sharedWorkspace] iconForFileType:NSHFSTypeOfFile(fullPath)];
            }
        } else {
            icon = self.projectIcon;
        }
        NSString* displayName = [pItem displayName];
        view.textField.stringValue = displayName;
        view.imageView.image = icon;
        view.menu = self.outlineItemMenu;
    }
    
    return view;
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
 
    [self _switchToSelectedDocumentIfPossible];
    
}

#pragma mark - project directory monitor

-(void) VDKQueue:(VDKQueue *)queue receivedNotification:(NSString*)noteName forPath:(NSString*)fpath {
    
}

#pragma mark - Actions

- (JSWrapper*)jsWrapper {
 
    if( nil == _jsWrapper ) {
        // init
        JSWrapper* wrapper = [[JSWrapper alloc] initWithProject:self.projDocument];
        wrapper.dynamixel = [Dynamixel sharedInstance];
        wrapper.logView = self.logView;
        _jsWrapper = wrapper;
    }
    
    return _jsWrapper;
    
}

- (IBAction)run:(id)sender {
    
    // locate the main.js
    // start from the main.js
    self.logView.string = @"Booting...\n";
    
    JSWrapper* wrapper = self.jsWrapper;
    [wrapper evalFile:@"main.js"];
    
}

- (IBAction)stop:(id)sender {
    
    self.running = NO;
    [self.jsWrapper stopScript];
}

@end
