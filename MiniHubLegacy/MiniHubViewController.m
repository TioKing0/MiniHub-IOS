#import "MiniHubViewController.h"

static NSString * const MiniHubURL = @"http://webminihub.local:8080";

@interface MiniHubViewController ()
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, assign) BOOL audioWasPlayingBeforeBackground;
@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTask;
@end

@implementation MiniHubViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.backgroundTask = UIBackgroundTaskInvalid;

    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.webView.delegate = self;
    self.webView.scalesPageToFit = NO;

    // Dedicated media client: avoid WebKit getting stuck waiting for a second
    // user gesture after the MiniHub player has already been activated.
    self.webView.mediaPlaybackRequiresUserAction = NO;
    self.webView.allowsInlineMediaPlayback = YES;
    self.webView.mediaPlaybackAllowsAirPlay = YES;

    // Old UIWebView is noticeably more responsive on the A5 with touch delay off.
    self.webView.scrollView.delaysContentTouches = NO;
    self.webView.scrollView.bounces = NO;

    [self.view addSubview:self.webView];

    self.statusLabel = [[UILabel alloc] initWithFrame:self.view.bounds];
    self.statusLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.statusLabel.backgroundColor = [UIColor blackColor];
    self.statusLabel.textColor = [UIColor whiteColor];
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.numberOfLines = 0;
    self.statusLabel.text = @"MiniHub\nProcurando servidor...";
    [self.view addSubview:self.statusLabel];

    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(applicationWillResignActive:)
               name:UIApplicationWillResignActiveNotification object:nil];
    [nc addObserver:self selector:@selector(applicationDidEnterBackground:)
               name:UIApplicationDidEnterBackgroundNotification object:nil];
    [nc addObserver:self selector:@selector(applicationWillEnterForeground:)
               name:UIApplicationWillEnterForegroundNotification object:nil];

    [self loadMiniHub];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadMiniHub) object:nil];
}

- (void)loadMiniHub {
    NSURL *url = [NSURL URLWithString:MiniHubURL];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url
                                              cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                          timeoutInterval:8.0]];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.statusLabel.hidden = YES;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadMiniHub) object:nil];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    // UIWebView reports NSURLErrorCancelled (-999) during harmless internal
    // navigations. Reloading the whole MiniHub for that can look like a frozen
    // Player tab, so never treat it as a lost host.
    if (error.code == NSURLErrorCancelled) {
        return;
    }

    self.statusLabel.hidden = NO;
    self.statusLabel.text = @"MiniHub\nProcurando servidor...";
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadMiniHub) object:nil];
    [self performSelector:@selector(loadMiniHub) withObject:nil afterDelay:3.0];
}

- (void)applicationWillResignActive:(NSNotification *)notification {
    NSString *state = [self.webView stringByEvaluatingJavaScriptFromString:
        @"(function(){var a=document.getElementsByTagName('audio')[0];"
         "return (a && !a.paused && !a.ended) ? '1' : '0';})()"];
    self.audioWasPlayingBeforeBackground = [state isEqualToString:@"1"];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    if (!self.audioWasPlayingBeforeBackground) {
        return;
    }

    UIApplication *app = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier task = [app beginBackgroundTaskWithExpirationHandler:^{
        if (task != UIBackgroundTaskInvalid) {
            [app endBackgroundTask:task];
            task = UIBackgroundTaskInvalid;
        }
    }];
    self.backgroundTask = task;

    // Some iOS 9 UIWebView builds pause HTML5 audio immediately after the app
    // goes to background even with the correct audio session. Resume only when
    // it was definitely playing before the transition.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(350 * NSEC_PER_MSEC)),
                   dispatch_get_main_queue(), ^{
        if (self.audioWasPlayingBeforeBackground) {
            [self.webView stringByEvaluatingJavaScriptFromString:
                @"(function(){var a=document.getElementsByTagName('audio')[0];"
                 "if(a && a.paused && !a.ended){try{a.play();}catch(e){}}})();"];
        }

        if (task != UIBackgroundTaskInvalid) {
            [app endBackgroundTask:task];
            task = UIBackgroundTaskInvalid;
        }
        self.backgroundTask = UIBackgroundTaskInvalid;
    });
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    self.audioWasPlayingBeforeBackground = NO;
}

- (BOOL)prefersStatusBarHidden { return YES; }
- (BOOL)shouldAutorotate { return YES; }
- (UIInterfaceOrientationMask)supportedInterfaceOrientations { return UIInterfaceOrientationMaskAll; }

@end
