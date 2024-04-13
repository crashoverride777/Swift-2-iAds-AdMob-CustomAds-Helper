[![Swift 5.8](https://img.shields.io/badge/swift-5.8-ED523F.svg?style=flat)](https://swift.org/download/)
[![Platform](https://img.shields.io/cocoapods/p/SwiftyAds.svg?style=flat)]()
[![SPM supported](https://img.shields.io/badge/SPM-supported-DE5C43.svg?style=flat)](https://swift.org/package-manager)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/SwiftyAds.svg)](https://img.shields.io/cocoapods/v/SwiftyAds.svg)

# SwiftyAds

A Swift library to display banner, interstitial, rewarded and native ads from Google AdMob and supported mediation partners.

- [Requirements](#requirements)
- [Create Accounts](#create-accounts)
- [Mediation](#mediation)
- [Installation](#installation)
- [Pre-Usage](#pre-usage)
- [Usage](#usage)
- [App Store release information](#app-store-release-information)
- [Demos](#demos)
- [License](#license)

## Requirements

- iOS 14.0+

## Create Accounts

### AdMob

Sign up for an [AdMob account](https://admob.google.com/home/get-started/) and create your required AdUnitIDs for the types of ads you would like to display. 

### Funding Choices (Optional)

SwiftyAds uses Google`s [User Messaging Platform](https://developers.google.com/admob/ump/ios/quick-start) (UMP) SDK to handle user consent if required. This SDK can handle both GDPR (EEA) requests and also the iOS 14 [ATT](https://developers.google.com/admob/ios/ios14) alert. 

This step can be skipped if you would like to disable user consent requests, see `Add SwiftyAds.plist` part of [pre-usage section](#pre-usage) below. Otherwise please read the Funding Choices [documentation](https://support.google.com/fundingchoices/answer/9180084) to ensure they are setup up correctly for your requirements.

NOTE: Apple may be rejecting apps that use the UMP SDK to display the iOS 14 ATT alert. As a workaround you may have to tweak the wording of the [explainer message](https://github.com/Gimu/admob_consent/issues/6#issuecomment-772349196) or you can [manually](https://github.com/crashoverride777/swifty-ads/issues/50) display the ATT alert before configuring SwiftyAds. 

## Installation

### Swift Package Manager

The Swift Package Manager is a tool for automating the distribution of Swift code and is integrated into the swift compiler.

To add a swift package to your project simple open your project in xCode and click File > Swift Packages > Add Package Dependency.
Than enter `https://github.com/crashoverride777/swifty-ads.git` as the repository URL and finish the installation wizard.

Alternatively if you have another swift package that requires `SwiftyAds` as a dependency it is as easy as adding it to the dependencies value of your Package.swift.
```swift
dependencies: [
.package(url: "https://github.com/crashoverride777/swifty-ads.git", from: "16.0.0")
]
```

### Cocoa Pods

[CocoaPods](https://developers.google.com/admob/ios/quick-start#streamlined_using_cocoapods) is a dependency manager for Cocoa projects. 
Simply install the pod by adding the following line to your pod file

```swift
pod 'SwiftyAds'
```

### Manually 

Alternatively you can copy the `Sources` folder and its containing files into your project and install the required dependencies.

- [AdMob](https://developers.google.com/admob/ios/quick-start#manual_download)
- [UMP](https://developers.google.com/admob/ump/ios/quick-start#manual_download)

## Pre-Usage

### Update Info.plist

- [AdMob](https://developers.google.com/admob/ios/quick-start#update_your_infoplist)
- [UMP](https://developers.google.com/admob/ump/ios/quick-start#update_your_infoplist)

### Add SwiftyAds.plist

Download the [template](../SwiftyAds.plist) plist and add it to your projects main bundle. Enter your required ad unit ids.

- bannerAdUnitId (String)
- interstitialAdUnitId (String)
- rewardedAdUnitId (String)
- rewardedInterstitialAdUnitId (String)
- nativeAdUnitId (String)

### Add SwiftyAdsConsent.plist (Optional)

By default SwiftyAds does not carry out any consent validation (COPPA or GDPR). 
To enable consent validation using the User Messaging Platform (UMP) SDK, download the [template](../SwiftyAdsConsent.plist) plist and add it to your projects bundle. Enter your required values.

- isTaggedForChildDirectedTreatment (Boolean) ([COPPA](https://developers.google.com/admob/ios/targeting#child-directed_setting))
- isTaggedForUnderAgeOfConsent (Boolean) ([GDPR](https://developers.google.com/admob/ios/targeting#users_under_the_age_of_consent))

### Link AppTrackingTransparency framework

[Link](https://developers.google.com/admob/ump/ios/quick-start#update_your_infoplist) the AppTrackingTransparency framework in `Framework, Libraries and Embedded Content` under the general tab, otherwise iOS 14 ATT alerts will not display.

## Usage

### Add import (CocoaPods or SwiftPackageManager)

- Add the import statement to your swift file(s) if you installed via CocoaPods or SwiftPackageManager

```swift
import SwiftyAds
```

### Create GADRequest builder

Create a `SwiftyAdsRequestBuilder` class, implementing the `SwiftyAdsRequestBuilderType` protocol, that SwiftyAds will use to load ads. Some mediation networks such as Vungle may required specific GADRequest extras.
Please check the AdMob mediation [documentation](https://developers.google.com/admob/ios/mediation).

```swift
import SwiftyAds
import GoogleMobileAds

final class SwiftyAdsRequestBuilder: SwiftyAdsRequestBuilderType {
    func build() -> GADRequest {
        GADRequest()
    }
}
```

### Create Mediation Configurator (Optional)

Create a `SwiftyAdsMediationConfigurator` class, implementing the `SwiftyAdsMediationConfiguratorType` protocol, to manage updating mediation networks for COPPA/GDPR consent status changes.
Please check the AdMob mediation [documentation](https://developers.google.com/admob/ios/mediation).

#### App Lovin Example
```swift
import SwiftyAds
import AppLovinAdapter

final class SwiftyAdsMediationConfigurator {}

extension SwiftyAdsMediationConfigurator: SwiftyAdsMediationConfiguratorType {

    func updateCOPPA(isTaggedForChildDirectedTreatment: Bool)
        // App Lovin mediation network example
        ALPrivacySettings.setIsAgeRestrictedUser(isTaggedForChildDirectedTreatment)
    }

    func updateGDPR(for consentStatus: SwiftyAdsConsentStatus, isTaggedForUnderAgeOfConsent: Bool) {
        // App Lovin mediation network example
        ALPrivacySettings.setHasUserConsent(consentStatus == .obtained)
        if !ALPrivacySettings.isAgeRestrictedUser() { // skip if already age restricted e.g. enableCOPPA called
            ALPrivacySettings.setIsAgeRestrictedUser(isTaggedForUnderAgeOfConsent)
        }
    }
}
```

### Configure 

Create a configure method and call it as soon as your app launches e.g. AppDelegate `didFinishLaunchingWithOptions`. This will also trigger the initial consent flow if consent has not been disabled. Ads can only be displayed after the `completion` handler was called.

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    if let rootViewController = window?.rootViewController {
        configureSwiftyAds(from: rootViewController)
    }
    return true
}

private func configureSwiftyAds(from viewController: UIViewController) {
    #if DEBUG
    let environment: SwiftyAdsEnvironment = .development(testDeviceIdentifiers: [], consentConfiguration: .resetOnLaunch(geography: .EEA))
    #else
    let environment: SwiftyAdsEnvironment = .production
    #endif
    SwiftyAds.shared.configure(
        from: viewController,
        for: environment,
        requestBuilder: SwiftyAdsRequestBuilder(),
        mediationConfigurator: SwiftyAdsMediationConfigurator(), // set to nil if no mediation is required
        bundlePlist: .main, // looks for SwiftyAds.plist/SwiftyAdsConsent.plist
        completion: { result in 
            switch result {
            case .success:
                // Ads should be ready for displaying
            case .failure(let error):
                print(error)
            }
        }
    )
}
```

### Showing ads outside a UIViewController

SwiftyAds requires reference to a `UIViewController` to present ads. If you are not using SwiftyAds inside a `UIViewController` you can do the following to get reference the rootViewController.

AppDelegate
```swift
if let viewController = window?.rootViewController {
    SwiftyAds.shared.show(...)
}
```

SKScene
```swift
if let viewController = view?.window?.rootViewController {
    SwiftyAds.shared.show(...)
}
```

### Banner Ads

Create a property in your `UIViewController` for the banner to be displayed

```swift
class SomeViewController: UIViewController {

    private var bannerAd: SwiftyAdsBannerType?
}
```

Prepare the banner in `viewDidLoad`

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    
    bannerAd = SwiftyAds.shared.makeBannerAd(
        in: self,
        adUnitIdType: .plist, // set to `.custom("AdUnitId")` to add a different AdUnitId for this particular banner ad
        position: .bottom(isUsingSafeArea: true) // banner is pinned to bottom and follows the safe area layout guide
        animation: .slide(duration: 1.5),
        onOpen: {
            print("SwiftyAds banner ad did receive ad and was opened")
        },
        onClose: {
            print("SwiftyAds banner ad did close")
        },
        onError: { error in
            print("SwiftyAds banner ad error \(error)")
        },
        onWillPresentScreen: {
            print("SwiftyAds banner ad was tapped and is about to present screen")
        },
        onWillDismissScreen: {
            print("SwiftyAds banner ad presented screen is about to be dismissed")
        },
        onDidDismissScreen: {
            print("SwiftyAds banner did dismiss presented screen")
        }
    )
}
```

and show it in `viewDidAppear`. This is to ensure that the view has been layed out correctly and has a valid safe area.

```swift
override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    bannerAd?.show(isLandscape: view.frame.width > view.frame.height)
}
```

To handle orientation changes, simply call the show method again in `viewWillTransition`

```swift
override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    
    coordinator.animate(alongsideTransition: { [weak self] _ in
        self?.bannerAd?.show(isLandscape: size.width > size.height)
    })
}
```

You can hide the banner by calling the `hide` method. 

```swift
bannerAd?.hide() 
```

You can remove the banner from its superview by calling the `remove` method and afterwards nil out the reference.

```swift
bannerAd?.remove() 
bannerAd = nil
```

### Interstitial Ads

```swift
SwiftyAds.shared.showInterstitialAd(
    from: self,
    afterInterval: 2, // every 2nd time method is called ad will be displayed. Set to nil to always display.
    onOpen: {
        print("SwiftyAds interstitial ad did open")
    },
    onClose: {
        print("SwiftyAds interstitial ad did close")
    },
    onError: { error in
        print("SwiftyAds interstitial ad error \(error)")
    }
)
```

### Rewarded Ads

Rewarded ads may be non-skippable and should only be presented when pressing a dedicated button.

```swift
SwiftyAds.shared.showRewardedAd(
    from: self,
    onOpen: {
        print("SwiftyAds rewarded ad did open")
    },
    onClose: {
        print("SwiftyAds rewarded ad did close")
    }, 
    onError: { error in
        print("SwiftyAds rewarded ad error \(error)")
    },
    onNotReady: { [weak self] in
        guard let self = self else { return }
        print("SwiftyAds rewarded ad was not ready")
        
        // If the user presses the rewarded video button and watches a video it might take a few seconds for the next video to reload.
        // Use this callback to display an alert incase the video was not ready. 
        let alertController = UIAlertController(
            title: "Sorry",
            message: "No video available to watch at the moment.",
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "Ok", style: .cancel))
        DispatchQueue.main.async {
            self.present(alertController, animated: true)
        }
    },
    onReward: { [weak self] rewardAmount in
        print("SwiftyAds rewarded ad did reward user with \(rewardAmount)")
        // Provide the user with the reward e.g coins, diamonds etc
    }
)
```

NOTE: AdMob provided a new rewarded video API which lets you preload multiple rewarded videos with different AdUnitIds. While SwiftyAds uses this new API it currently only supports loading 1 rewarded ad at a time.

### Rewarded Interstitial Ads

Rewarded interstitial ads can be presented naturally in your apps flow, similar to interstitial ads, and do not require a dedicated button like regular rewarded ads.
Before displaying a rewarded interstitial ad, you must present the user with an [intro screen](https://support.google.com/admob/answer/9884467) that provides clear reward messaging and an option to skip the ad before it starts.

```swift
SwiftyAds.shared.showRewardedInterstitialAd(
    from: self,
    afterInterval: 2, // every 2nd time method is called ad will be displayed. Set to nil to always display.
    onOpen: {
        print("SwiftyAds rewarded interstitial ad did open")
    },
    onClose: {
        print("SwiftyAds rewarded interstitial ad did close")
    }, 
    onError: { error in
        print("SwiftyAds rewarded interstitial ad error \(error)")
    },
    onReward: { [weak self] rewardAmount in
        print("SwiftyAds rewarded interstitial ad did reward user with \(rewardAmount)")
        // Provide the user with the reward e.g coins, diamonds etc
    }
)
```

### Native Ads

To present a native ad simply call the load method. Once a native ad has been received you can update your custom ad view with the native ad content.

You can set the amount of ads to load (`GADMultipleAdsAdLoaderOptions`) via the `loaderOptions` parameter. Set to `.single` to use the default options.

As per Googles documentation, requests for multiple native ads don't currently work for AdMob ad unit IDs that have been configured for mediation. Publishers using mediation should avoid using the GADMultipleAdsAdLoaderOptions class when making requests. In that case you can also set the `loaderOptions` parameter to `.single`.


```swift
SwiftyAds.shared.loadNativeAd(
    from: self,
    adUnitIdType: .plist, // set to `.custom("AdUnitId")` to add a different AdUnitId for this particular native ad
    loaderOptions: .single, // set to `.multiple(2)` to load multiple ads for example 2
    onFinishLoading: {
        // Native ad has finished loading and new ads can now be loaded
    },
    onError: { error in
        // Native ad could not load ad due to error
    },
    onReceive: { nativeAd in
        // show native ad (see demo app or google documentation)
    }
)
```

NOTE: While prefetching ads is a great technique, it's important that you don't keep old native ads around forever without displaying them. Any native ad objects that have been held without display for longer than an hour should be discarded and replaced with new ads from a new request.

### Errors

Use can use the `SwiftyAdsError` enum to handle SwiftyAds specific errors.

```swift
if let swiftyAdsError = error as? SwiftyAdsError {
    switch swiftyAdsError { 
    case .interstitialAdNotLoaded:
        // Ad was not loaded
    default:
        break
    }
}
```

### Consent

```swift
Check current consent status
SwiftyAds.shared.consentStatus
```

Observe consent status changes
```swift
SwiftyAds.shared.observeConsentStatus { status in 
    print("New consent status set \(status")
}
```

Ask for consent again. 
It is required that the user has the option to change their GDPR consent settings, usually via a button in settings. 
```swift
func consentButtonPressed() {
    SwiftyAds.shared.askForConsent(from: self) { result in
        switch result {
        case .success(let status):
            print("Did change consent status")
        case .failure(let error):
            print("Consent status change error \(error)")
        }
    }
}
```

The consent button can be hidden if consent is not required or user is tagged for under age of consent.
```swift
// If consent is not required e.g. outside EEA than we do not need to show consent button.
// If inside EEA we need to display the consentButton unless user is tagged for under age of consent
if SwiftyAds.shared.consentStatus == .notRequired {
    consentButton.isHidden = true
} else {
    consentButton.isHidden = SwiftyAds.shared.isTaggedForUnderAgeOfConsent
}
```

### Booleans

```swift
// Check if interstitial ad is ready, for example to show an alternative ad
SwiftyAds.shared.isInterstitialAdReady

// Check if rewarded ad is ready, for example to show/hide button
SwiftyAds.shared.isRewardedAdReady

// Check if rewarded interstitial ad is ready, for example to show an alternative ad
SwiftyAds.shared.isRewardedInterstitialAdReady

// Check if child directed treatment is tagged on/off. Nil if not indicated how to be treated. (COPPA)
SwiftyAds.shared.isTaggedForChildDirectedTreatment

// Check if under age of consent is tagged on/off (GDPR)
SwiftyAds.shared.isTaggedForUnderAgeOfConsent

// Check if ads have been disabled
SwiftyAds.shared.isDisabled
```

### Disable/Enable Ads (In App Purchases)

Call the `disable(_ isDisabled: Bool)` method and banner, interstitial and rewarded interstitial ads will no longer display. 
This will not stop regular rewarded ads from displaying as they should have a dedicated button. This way you can remove banner, interstitial and rewarded interstitial ads but still have rewarded ads. 

```swift
SwiftyAds.shared.setDisabled(true)
```

For permanent storage you will need to create your own boolean logic and save it in something like `NSUserDefaults`, or preferably `Keychain`. 
Than at app launch, before you call `SwiftyAds.shared.configure(...)`, check your saved boolean and disable the ads if required.

```swift
if UserDefaults.standard.bool(forKey: "RemovedAdsKey") == true {
    SwiftyAds.shared.setDisabled(true)
}
```

## App Store release information

Make sure to prepare for Apple's App Store data disclosure [requirements](https://developers.google.com/admob/ios/data-disclosure)

## Demos

https://github.com/crashoverride777/swifty-ads-demo

## License

SwiftyAds is released under the MIT license. [See LICENSE](https://github.com/crashoverride777/swifty-ads/blob/master/LICENSE) for details.
