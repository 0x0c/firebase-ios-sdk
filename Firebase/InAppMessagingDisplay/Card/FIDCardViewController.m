//
//  FIDCardViewController.m
//  FirebaseInAppMessagingDisplay
//
//  Created by Chris Tibbs on 2/19/19.
//

#import "FIDCardViewController.h"
#import "FIRCore+InAppMessagingDisplay.h"

@interface FIDCardViewController ()

@property(nonatomic, readwrite) FIRInAppMessagingCardDisplay *cardDisplayMessage;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *primaryActionButton;
@property (weak, nonatomic) IBOutlet UIButton *secondaryActionButton;
@property (weak, nonatomic) IBOutlet UITextView *bodyTextView;

@end

@implementation FIDCardViewController

+ (FIDCardViewController *)
    instantiateViewControllerWithResourceBundle:(NSBundle *)resourceBundle
                                 displayMessage:(FIRInAppMessagingCardDisplay *)cardMessage
                                displayDelegate:(id<FIRInAppMessagingDisplayDelegate>)displayDelegate
                                    timeFetcher:(id<FIDTimeFetcher>)timeFetcher {
  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FIRInAppMessageDisplayStoryboard"
                                                       bundle:resourceBundle];
  
  if (!storyboard) {
    FIRLogError(kFIRLoggerInAppMessagingDisplay, @"I-FID300001",
                @"Storyboard '"
                "FIRInAppMessageDisplayStoryboard' not found in bundle %@",
                resourceBundle);
    return nil;
  }
  FIDCardViewController *cardVC = (FIDCardViewController *)[storyboard
      instantiateViewControllerWithIdentifier:@"card-view-vc"];
  cardVC.displayDelegate = displayDelegate;
  cardVC.cardDisplayMessage = cardMessage;
  cardVC.timeFetcher = timeFetcher;
  
  return cardVC;
}

- (IBAction)primaryActionButtonTapped:(id)sender {
  if (self.cardDisplayMessage.primaryActionURL) {
    [self followActionURL:self.cardDisplayMessage.primaryActionURL];
  } else {
    [self dismissView:FIRInAppMessagingDismissTypeUserTapClose];
  }
}

- (IBAction)secondaryActionButtonTapped:(id)sender {
  if (self.cardDisplayMessage.secondaryActionURL) {
    [self followActionURL:self.cardDisplayMessage.secondaryActionURL];
  } else {
    [self dismissView:FIRInAppMessagingDismissTypeUserTapClose];
  }
}


- (FIRInAppMessagingDisplayMessage *)inAppMessage {
  return self.cardDisplayMessage;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.bodyTextView.contentInset = UIEdgeInsetsZero;
  self.bodyTextView.textContainer.lineFragmentPadding = 0;
  
  // make the background half transparent
  [self.view setBackgroundColor:[UIColor.grayColor colorWithAlphaComponent:0.5]];
  
  self.titleLabel.text = self.cardDisplayMessage.title;
  self.titleLabel.textColor = self.cardDisplayMessage.textColor;
  
  self.bodyTextView.text = self.cardDisplayMessage.body;

  [self.primaryActionButton setTitle:self.cardDisplayMessage.primaryActionButton.buttonText
                            forState:UIControlStateNormal];
  [self.primaryActionButton setTitleColor:self.cardDisplayMessage.primaryActionButton.buttonTextColor
                                 forState:UIControlStateNormal];
  
  if (self.cardDisplayMessage.secondaryActionButton) {
    self.secondaryActionButton.hidden = NO;
    [self.secondaryActionButton setTitle:self.cardDisplayMessage.secondaryActionButton.buttonText
                                forState:UIControlStateNormal];
    [self.secondaryActionButton setTitleColor:self.cardDisplayMessage.secondaryActionButton.buttonTextColor
                                     forState:UIControlStateNormal];
  }
}

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];
  
  if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular ||
      self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact) {
    NSData *imageData = self.cardDisplayMessage.landscapeImageData ? self.cardDisplayMessage.landscapeImageData.imageRawData : self.cardDisplayMessage.portraitImageData.imageRawData;
    self.imageView.image = [UIImage imageWithData:imageData];
  } else {
    self.imageView.image = [UIImage imageWithData:self.cardDisplayMessage.portraitImageData.imageRawData];
  }
  
  CGFloat textViewWidth = self.bodyTextView.frame.size.width;
  CGFloat textHeight = [self determineTextAreaViewFitHeightForView:self.bodyTextView withWidth:textViewWidth];
  self.bodyTextView.contentSize = CGSizeMake(textViewWidth, textHeight);
  self.bodyTextView.scrollEnabled = textHeight > self.bodyTextView.frame.size.height;
  
  if (self.bodyTextView.scrollEnabled) {
    [self.bodyTextView setContentOffset:CGPointZero animated:YES];
  }
}

- (CGFloat)determineTextAreaViewFitHeightForView:(UIView *)textView
                                       withWidth:(CGFloat)displayWidth {
  CGSize displaySize = CGSizeMake(displayWidth, FLT_MAX);
  return [textView sizeThatFits:displaySize].height;
}

@end
