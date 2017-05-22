# SwiftyAd

A Swift helper to integrate Ads from AdMob so you can easily show Banner Ads, Interstitial Ads and RewardVideoAds anywhere in your project.

This helper follows all the best practices in regards to ads, like creating shared banners and correctly preloading interstitial and rewarded videos so they are always ready to show.

# Rewarded Videos

Admob reward videos will only work when using a 3rd party mediation network such as Chartboost or Vungle. 
Read the AdMob mediation guidlines 

https://support.google.com/admob/bin/answer.py?answer=2413211

https://developers.google.com/admob/ios/mediation

https://developers.google.com/admob/ios/mediation-networks

and rewarded video guidlines 

https://developers.google.com/admob/ios/rewarded-video

Than read your 3rd party ad network(s) of choice mediation guidlines to set up reward videos correctly. This will unclude installing their SDK and mediation adapters. 

NOTE: AdMob reward videos will either show a black full screen ad when using the test AdUnitID or not show one at all.

# "DEBUG" custom flag

AdMob uses 2 types of AdUnit IDs, 1 for testing and 1 for release. This helper will automatically change the AdUnitID from test to release mode and vice versa. 

You should not show real ads when you are testing your app. In the past Google has been quite strict and has closed down AdMob/AdSense accounts because ads were clicked on apps that were not live. Keep this in mind when you for example test your app via TestFlight because your app will be in release mode when you send a TestFlight build which means it will show real ads.

With the latest xCode it is no longer necessary to setup the DEBUG flag manually.

# Pre-setup

- Step 1: Sign up for a Google AdMob account and create your real adUnitIDs for your app, one for each type of ad you will use (Banner, Interstitial, Reward Ads).

https://support.google.com/admob/answer/3052638?hl=en-GB&ref_topic=3052726

- Step 2: Install AdMob SDK

// Cocoa Pods
https://developers.google.com/admob/ios/quick-start#streamlined_using_cocoapods

// Manually
https://developers.google.com/admob/ios/quick-start#manually_using_the_sdk_download

I would recommend using Cocoa Pods especially if you will add more SDKs down the line from other ad networks. Its a bit more complicated but once you understand and do it once or twice its a breeze. 

They have an app now which should makes managing pods alot easier.
https://cocoapods.org/app

- Step 3: Copy the following file into your project.

```swift
SwiftyAd.swift
```

Tip:

If you have multiple apps and do not want to copy the file into each project I would create a folder on your Mac, called something like SharedFiles. Than drag the SwiftyAds.swift file into this folder. Than drag the SwiftyAds.swift file from this folder into your project, making sure that "copy if needed" is not selected. This way its easier to update the files and to share them between projects. Just make sure you do not move or rename this shared folder otherwise you will have to relink the file again.

# How to use

- Setup up the helper with your AdUnitIDs as soon as your app launches e.g AppDelegate or 1st ViewController.

```swift
SwiftyAd.shared.setup(
      withBannerID:    "Enter your real id or leave empty if unused", 
      interstitialID:  "Enter your real id or leave empty if unused", 
      rewardedVideoID: "Enter your real id or leave empty if unused"
)
```

- To show an Ad call these methods anywhere you like in your project

UIViewController
```swift
SwiftyAd.shared.showBanner(from: self) 
SwiftyAd.shared.showBanner(from: self, at: .top) // Shows banner at the top
SwiftyAd.shared.showInterstitial(from: self)
SwiftyAd.shared.showInterstitial(from: self, withInterval: 4) // Shows an ad every 4th time method is called
SwiftyAd.shared.showRewardedVideo(from: self) // Should be called when pressing dedicated button
```
SKScene
(Do not call this in didMoveToView as .window property is still nil at that point. Use a delay or call it later)
```swift
if let viewController = view?.window?.rootViewController {
     SwiftyAd.shared.showBanner(from: viewController) 
     SwiftyAd.shared.showBanner(from: viewController, at: .top) // Shows banner at the top
     SwiftyAd.shared.showInterstitial(from: viewController)
     SwiftyAd.shared.showInterstitial(from: viewController, withInterval: 4) // Shows an ad every 4th time method is called  
     SwiftyAd.shared.showRewardedVideo(from: viewController) // Should be called when pressing dedicated button
}
```

Note:

You should only show rewarded videos with a dedicated button and you should only show that button when a video is loaded (see below). If the user presses the reward video button and watches a video it might take a few seconds for the next video to reload afterwards. Incase the user immediately tries to watch another video this helper will show an alert informing the user that no video is available at the moment. 

Tip:

From my personal experience and from a user perspective you should not spam full screen interstitial ads all the time. This will also increase your revenue because user retention rate is higher so you should not be greedy. Therefore you should

1) Not show an interstitial ad everytime a button is pressed 
2) Not show an interstitial ad everytime you die in a game
3) Use the "withInterval" property in the show method and set it to a minimum of 5/6 depending on the frequence the method is called. There might be special cirumstances where you could set it lower e.g in a game where it takes a while to die but usually 5/6 mimimum is what I think is best. You could also randomise the interval e.g random number between 5-8.

- To check if ads are ready

```swift
if SwiftyAd.shared.isRewardedVideoReady {
    // add/show reward video button
}

if SwiftyAd.shared.isInterstitialReady {
    // maybe show custom ad or something similar
}

// When these return false the helper will try to preload an ad again.
```

- To remove Banner Ads, for example during gameplay 
```swift
SwiftyAd.shared.removeBanner() 
```

- To remove all Ads, mainly for in app purchases simply call 
```swift
SwiftyAd.shared.isRemoved = true 
```

NOTE: Remove Ads bool 

If set to true all the methods to show banner and interstitial ads will not fire anymore and therefore require no further editing. 

This will not stop rewarded videos from showing as they should have a dedicated button. Some reward videos are not skipabble and therefore should never be shown automatically. This way you can remove banner and interstitial ads but still have a rewarded videos button. 

For permanent storage you will need to create your own "removedAdsProduct" property and save it in something like UserDefaults, or preferably iOS Keychain. Than at app launch check if your saved property is set to true and than updated the helper poperty.

- Implement the delegate methods.

Set the delegate in the relevant SKScenes ```DidMoveToView``` method or in your ViewControllers ```ViewDidLoad``` method
to receive delegate callbacks.
```swift
SwiftyAd.shared.delegate = self 
```

Than create an extension conforming to the AdsDelegate protocol.
```swift
extension GameScene: SwiftyAdDelegate {
    func swiftyAdDidOpen(_ swiftyAd: SwiftyAd) {
        // pause your game/app if needed
    }
    func swiftyAdDidClose(_ swiftyAd: SwiftyAd) { 
       // resume your game/app if needed
    }
    func swifyAd(_ swiftyAd: SwiftyAd, didRewardUserWithAmount rewardAmount: Int) {
        self.coins += rewardAmount
       // Reward amount is a DecimelNumber I converted to an Int for convenience. 
     
       // You can ignore this and hardcore the value if you would like but than you cannot change the value dynamically without having to update your app.
       
       // You can also ingore the rewardAmount and do something else, for example unlocking a level or bonus item.
       
       // leave empty if unused
    }
}
```

Note:

This helper will pass a default value to the below method

```swift
func swiftyAd(_ swiftyAd: SwiftyAd, didRewardUserWithAmount rewardAmount: Int) {
```

incase there is a problem fetching the value from the ad network or you set it to 0 or lower by accident. The default value is 1. Incase you need to change this e.g to 20, you can change this in the setup method.

```swift
SwiftyAd.shared.setup(
      withBannerID:        ..., 
      interstitialID:  ..., 
      rewardedVideoID: ...,
      rewardAmountBackup: 20
)
```

# Supporting both landscape and portrait orientation

- If your app supports both portrait and landscape orientation go to your ViewControllers and add the following method.

```swift
override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) in
          
            SwiftyAd.shared.updateOrientation()
            
            }, completion: { (UIViewControllerTransitionCoordinatorContext) -> Void in
                print("Device rotation completed")
        })
    }
```

# When you submit your app to Apple

When you submit your app to Apple on iTunes connect do not forget to select YES for "Does your app use an advertising identifier", otherwise it will get rejected. If you use reward videos you should also select the 3rd point.

# Final Info

The sample project is the basic Apple spritekit template. It now shows a banner Ad on launch and an interstitial ad randomly when touching the screen. After a certain amount of clicks all ads will be removed to simulate what a removeAds button would do. 

Please feel free to let me know about any bugs or improvements. 

Enjoy

# Release Notes

- v8.0

Project has been renamed to SwiftyAd

Updated show methods

Updated delegate methods

Project cleanup

Please check the documentation again
