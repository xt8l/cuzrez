#import <substrate.h>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <IOKit/IOKit.h>
#import <mach/mach.h>

// ============================================================
// Native Objective-C functions for resolution management
// ============================================================

// Device and version detection
static BOOL is_iPhone6sSeries(void) {
    NSString *model = [NSProcessInfo processInfo].globallyStringForKey:@"MESAccessibilityDisplayIdentifier"];
    if (!model) {
        model = @"unknown";
    }
    return [model isEqualToString:@"iPhone9,1"] || [model isEqualToString:@"iPhone9,3"] || // iPhone 6s
           [model isEqualToString:@"iPhone9,2"] || [model isEqualToString:@"iPhone9,4"] || // iPhone 6s Plus
           [model isEqualToString:@"iPhone8,1"] || // iPhone SE (1st gen)
           [model isEqualToString:@"iPhone8,2"] || // iPhone 7
           [model isEqualToString:@"iPhone8,3"] || // iPhone 7 Plus
           [model isEqualToString:@"iPhone8,4"];  // iPhone 7 (China)
}

// Get current iOS version
static float get_iOS_version(void) {
    NSString *version = [[UIDevice currentDevice] systemVersion];
    return [version floatValue];
}

// Native bounds
static CGRect get_native_bounds(void) {
    return UIScreen.main.nativeBounds;
}

// Resolution settings plist paths
static NSString *const kResolutionPlistPath = @"/var/tmp/com.apple.iokit.IOMobileGraphicsFamily.plist";
static NSString *const kMobileResolutionPlistPath = @"/private/var/mobile/Library/Preferences/com.apple.iokit.IOMobileGraphicsFamily.plist";

// Apply resolution using the IOMobileGraphicsFamily plist mechanism
static void apply_resolution(CGFloat width, CGFloat height) {
    NSFileManager *fm = [NSFileManager defaultManager];
    
    // Create the plist dictionary with canvas dimensions
    NSDictionary *plistDict = @{
        @"canvas_width": @(roundf(width)),
        @"canvas_height": @(roundf(height))
    };
    
    // Write to /var/tmp/ - this is a temp location that gets read by SpringBoard
    BOOL success = [plistDict writeToFile:kResolutionPlistPath atomically:YES];
    if (!success) {
        NSLog(@"StretchRes: Failed to write resolution plist to /var/tmp/");
        return;
    }
    
    // Copy to mobile preferences directory - this is where SpringBoard/Backboardd reads it
    NSError *copyError = nil;
    BOOL copied = [fm copyItemAtPath:kResolutionPlistPath toPath:kMobileResolutionPlistPath error:&copyError];
    if (!copied) {
        NSLog(@"StretchRes: Failed to copy resolution plist to mobile preferences: %@", copyError);
        return;
    }
    
    // Send notification to SpringBoard to reload display configuration
    CFNotificationCenterPostNotification(
        CFNotificationCenterGetDarwinNotifyCenter(),
        CFSTR("com.stretchres.reload.display"),
        nil,
        nil,
        YES
    );
    
    NSLog(@"StretchRes: Applied resolution %.0f x %.0f", width, height);
}

// Reset to original resolution
static void reset_resolution(void) {
    NSFileManager *fm = [NSFileManager defaultManager];
    
    // Remove the tmp file
    [fm removeItemAtPath:kResolutionPlistPath error:nil];
    
    // Remove the mobile preferences file
    [fm removeItemAtPath:kMobileResolutionPlistPath error:nil];
    
    // Post notification to reload native resolution
    CFNotificationCenterPostNotification(
        CFNotificationCenterGetDarwinNotifyCenter(),
        CFSTR("com.stretchres.reload.display"),
        nil,
        nil,
        YES
    );
    
    NSLog(@"StretchRes: Resolution reset to original");
}

// Save user preference using NSUserDefaults
static void save_preference(NSString *key, id value) {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:value forKey:key];
    [synchronize];
}

// Load user preference using NSUserDefaults
static id load_preference(NSString *key) {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults valueForKey:key];
}

// Get current resolution display text
static NSString *current_resolution_text(void) {
    CGBounds bounds = UIScreen.main.nativeBounds;
    return [NSString stringWithFormat:@"%dx%d", (int)bounds.size.width, (int)bounds.size.height];
}

// Get original native resolution display text
static NSString *original_resolution_text(void) {
    return current_resolution_text();
}

// Portrait resolution configuration for supported devices
static CGFloat portrait_width_for_device(NSString *deviceModel) {
    if ([deviceModel isEqualToString:@"iPhone6,1"] || [deviceModel isEqualToString:@"iPhone6,2"] || // iPhone 6s
        [deviceModel isEqualToString:@"iPhone7,2"] || // iPhone 7 Plus
        [deviceModel isEqualToString:@"iPhone8,1"] || // iPhone SE (1st gen)
        [deviceModel isEqualToString:@"iPhone8,2"] || // iPhone 7
        [deviceModel isEqualToString:@"iPhone8,3"] || // iPhone 7 Plus
        [deviceModel isEqualToString:@"iPhone8,4"]) { // iPhone 7 (China)
        return 1334.0f;
    }
    return 1136.0f; // iPhone SE (1st gen) default / fallback
}

static CGFloat portrait_height_for_device(NSString *deviceModel) {
    if ([deviceModel isEqualToString:@"iPhone6,1"] || [deviceModel isEqualToString:@"iPhone6,2"]) {
        return 750.0f; // iPhone 6s
    }
    if ([deviceModel isEqualToString:@"iPhone9,2"] || [deviceModel isEqualToString:@"iPhone9,4"]) {
        return 1080.0f; // iPhone 6s Plus
    }
    if ([deviceModel isEqualToString:@"iPhone8,1"] || [deviceModel isEqualToString:@"iPhone8,2"] || 
        [deviceModel isEqualToString:@"iPhone8,3"] || [deviceModel isEqualToString:@"iPhone8,4"]) {
        return 640.0f; // iPhone SE (1st gen) / iPhone 7
    }
    return 750.0f; // Default
}

// Landscape resolution configuration
static CGFloat landscape_width_for_device(NSString *deviceModel) {
    return portrait_height_for_device(deviceModel);
}

static CGFloat landscape_height_for_device(NSString *deviceModel) {
    return portrait_width_for_device(deviceModel);
}

// Apply preset resolution
static void apply_preset(NSString *preset_name) {
    NSString *deviceModel = [NSProcessInfo processInfo].globallyStringForKey:@"MESAccessibilityDisplayIdentifier"];
    if (!deviceModel) {
        deviceModel = @"unknown";
    }
    
    CGFloat width, height;
    
    if ([preset_name isEqualToString:@"native"]) {
        width = UIScreen.main.nativeBounds.size.width;
        height = UIScreen.main.nativeBounds.size.height;
    } else if ([preset_name isEqualToString:@"16:9"]) {
        float aspect = 16.0f / 9.0f;
        float current_aspect = UIScreen.main.nativeBounds.size.width / UIScreen.main.nativeBounds.size.height;
        if (current_aspect > aspect) {
            height = UIScreen.main.nativeBounds.size.width / aspect;
            width = UIScreen.main.nativeBounds.size.width;
        } else {
            width = UIScreen.main.nativeBounds.size.height * aspect;
            height = UIScreen.main.nativeBounds.size.height;
        }
    } else if ([preset_name isEqualToString:@"custom"]) {
        width = [[load_preference:@"custom_width"] floatValue];
        height = [[load_preference:@"custom_height"] floatValue];
        if (width <= 0 || height <= 0) {
            width = UIScreen.main.nativeBounds.size.width;
            height = UIScreen.main.nativeBounds.size.height;
        }
    } else if ([preset_name isEqualToString:@"portrait"]) {
        width = portrait_width_for_device(deviceModel);
        height = portrait_height_for_device(deviceModel);
    } else if ([preset_name isEqualToString:@"landscape"]) {
        width = landscape_width_for_device(deviceModel);
        height = landscape_height_for_device(deviceModel);
    } else {
        width = UIScreen.main.nativeBounds.size.width;
        height = UIScreen.main.native.bounds.size.height;
    }
    
    apply_resolution(width, height);
}

// Apply custom resolution from inputs, with validation
static void apply_custom_resolution(CGFloat width, CGFloat height) {
    // Validate: resolution must be positive
    if (width <= 0 || height <= 0) {
        NSLog(@"StretchRes: Invalid resolution values - must be positive");
        return;
    }
    
    // Validate: reasonable aspect ratio range for iOS 15 devices
    float ratio = width / height;
    if (ratio < 0.3 || ratio > 3.5) {
        NSLog(@"StretchRes: Aspect ratio %.2f out of valid range [0.3, 3.5]", ratio);
        return;
    }
    
    // Validate: both dimensions should be reasonable for iPhone screens
    if (width < 480 || width > 4000 || height < 480 || height > 4000) {
        NSLog(@"StretchRes: Dimension out of reasonable range [480-4000]");
        return;
    }
    
    apply_resolution(width, height);
}

// Handle respring - restore saved configuration
static void handle_respring(void) {
    NSString *preset = [load_preference:@@"last_preset"] ?:[@"native"];
    apply_preset(preset);
}

// ============================================================
// Preference Bundle Action Implementation Class
// ============================================================

// The class that implements the preference bundle actions
@interface StretchResController : NSObject

// Actions matching the plist specifier Actions strings
- (void)apply_resolution:(id)sender;
- (void)reset_resolution:(id)sender;
- (void)preset_selection:(id)sender;
- (void)enable_tweak:(id)sender;
- (void)auto_apply:(id)sender;
- (void)reset_preferences:(id)sender;

@end

@implementation StretchResController

// Apply resolution from preference bundle
- (void)apply_resolution:(id)sender {
    CGFloat width = [[[NSUserDefaults standardUserDefaults] valueForKey:@"custom_width"] floatValue];
    CGFloat height = [[[NSUserDefaults standardUserDefaults] valueForKey:@"custom_height"] floatValue];
    apply_custom_resolution(width, height);
}

// Reset original resolution from preference bundle
- (void)reset_resolution:(id)sender {
    reset_resolution();
}

// Preset selection from preference bundle
- (void)preset_selection:(id)sender {
    // Get the selected preset from user defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *preset = [defaults stringForKey:@"last_preset"];
    if (!preset) preset = @"native";
    apply_preset(preset);
}

// Enable/Disable tweak from preference bundle
- (void)enable_tweak:(id)sender {
    BOOL enabled = [self isEqual:[sender on]]; // Simplified toggle logic
    save_preference(@@"tweak_enabled", @(enabled));
    if (!enabled) {
        reset_resolution();
    }
}

// Auto apply after respring from preference bundle
- (void)auto_apply:(id)sender {
    BOOL enabled = [self isEqual:[sender on]]; // Simplified toggle logic
    save_preference(@@"auto_apply_after_respring", @(enabled));
}

// Reset preferences from preference bundle
- (void)reset_preferences:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removePersistentDomainForIdentifier:@"StretchRes"];
    [defaults synchronize];
    reset_resolution();
}

@end

// ============================================================
// Logos initialization
// ============================================================

%ctor {
    // Detect iOS version and device model
    float ios_ver = get_iOS_version();
    NSLog(@"StretchRes: Loading on iOS %g", ios_ver);
    
    // Device detection log
    if (is_iPhone6sSeries()) {
        NSLog(@"StretchRes: Detected iPhone 6s/7 series device");
    }
    
    %log(@"StretchRes tweak loaded successfully");
    
    // Apply saved configuration on load
    handle_respring();
}

// Hook to display current resolution in status bar area
%hook UIApplication

// Override status bar style
-(void)setStatusBarStyle:(UIStatusBarStyle)style animated:(BOOL)animated {
    %orig;
}

// Override status bar hidden
-(void)setStatusBarHidden:(BOOL)hidden animated:(BOOL)animated {
    %orig;
}

// Status bar is NOT hidden - we show resolution info
-(BOOL)isStatusBarHidden {
    %orig;
    return NO;
}

%end

// ============================================================
// Preferences group - hook into the preference bundle
// ============================================================

%group StretchResPreferences

// Hook into the StretchRes preference bundle controller
%hook StretchResController

// Apply resolution from UI
- (void)apply_resolution:(id)sender {
    %orig;
}

// Reset resolution from UI
- (void)reset_resolution:(id)sender {
    %orig;
}

// Handle preset selection
- (void)preset_selection:(id)sender {
    // Get selected preset title
    NSString *title = [self title]; // Get the selected radio button title
    // Save the selected preset
    save_preference(@@"last_preset", title);
    apply_preset(title);
}

// Handle enable/disable toggle
- (void)enable_tweak:(id)sender {
    BOOL enabled = [self isEqual:[sender on]];
    save_preference(@@"tweak_enabled", @(enabled));
    if (!enabled) {
        [self reset_resolution:@""];
    }
}

// Handle auto-apply toggle
- (void)auto_apply:(id)sender {
    BOOL enabled = [self isEqual:[sender on]];
    save_preference(@@"auto_apply_after_respring", @(enabled));
}

// Handle reset preferences
- (void)reset_preferences:(id)sender {
    %orig;
}

%end