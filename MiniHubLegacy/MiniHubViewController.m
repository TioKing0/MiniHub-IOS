#import "MiniHubViewController.h"

static NSString * const MiniHubURL = @"http://webminihub.local";

@interface MiniHubViewController ()
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UILabel *statusLabel;
@end

@implementation MiniHubViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];

    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.webView.delegate = self;
    self.webView.scalesPageToFit = NO;
    self.webView.mediaPlaybackRequiresUserAction = YES;
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

- (void)loadMiniHub {
    NSURL *url = [NSURL URLWithString:MiniHubURL];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url
                                              cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                          timeoutInterval:8.0]];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.statusLabel.hidden = YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    self.statusLabel.hidden = NO;
    self.statusLabel.text = @"MiniHub\nProcurando servidor...";
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadMiniHub) object:nil];
    [self performSelector:@selector(loadMiniHub) withObject:nil afterDelay:3.0];
}

- (BOOL)prefersStatusBarHidden { return YES; }
- (BOOL)shouldAutorotate { return YES; }
- (UIInterfaceOrientationMask)supportedInterfaceOrientations { return UIInterfaceOrientationMaskAll; }

@end
