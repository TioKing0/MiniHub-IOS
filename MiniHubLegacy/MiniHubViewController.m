#import "MiniHubViewController.h"

static NSString * const MiniHubURL = @"http://webminihub.local:8080";

@interface MiniHubViewController ()
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UILabel *statusLabel;
@end

@implementation MiniHubViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];

    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.allowsInlineMediaPlayback = YES;

    // This property exists on the iOS 9 SDK and is the legacy equivalent of
    // mediaTypesRequiringUserActionForPlayback introduced later.
    if ([configuration respondsToSelector:@selector(setMediaPlaybackRequiresUserAction:)]) {
        configuration.mediaPlaybackRequiresUserAction = NO;
    }

    if ([configuration respondsToSelector:@selector(setMediaPlaybackAllowsAirPlay:)]) {
        configuration.mediaPlaybackAllowsAirPlay = YES;
    }

    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.webView.navigationDelegate = self;
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

    [self loadMiniHub];
}

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadMiniHub) object:nil];
    self.webView.navigationDelegate = nil;
}

- (void)loadMiniHub {
    NSURL *url = [NSURL URLWithString:MiniHubURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                         timeoutInterval:8.0];
    [self.webView loadRequest:request];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    self.statusLabel.hidden = YES;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadMiniHub) object:nil];
}

- (void)handleNavigationError:(NSError *)error {
    if (error.code == NSURLErrorCancelled) {
        return;
    }

    self.statusLabel.hidden = NO;
    self.statusLabel.text = @"MiniHub\nProcurando servidor...";
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadMiniHub) object:nil];
    [self performSelector:@selector(loadMiniHub) withObject:nil afterDelay:3.0];
}

- (void)webView:(WKWebView *)webView
didFailProvisionalNavigation:(WKNavigation *)navigation
      withError:(NSError *)error {
    [self handleNavigationError:error];
}

- (void)webView:(WKWebView *)webView
didFailNavigation:(WKNavigation *)navigation
      withError:(NSError *)error {
    [self handleNavigationError:error];
}

- (BOOL)prefersStatusBarHidden { return YES; }
- (BOOL)shouldAutorotate { return YES; }
- (UIInterfaceOrientationMask)supportedInterfaceOrientations { return UIInterfaceOrientationMaskAll; }

@end
