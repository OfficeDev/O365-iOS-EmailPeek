#Email Peek - An iOS app built using Office 365#
[![Build Status](https://travis-ci.org/OfficeDev/O365-iOS-EmailPeek.svg)](https://travis-ci.org/OfficeDev/O365-iOS-EmailPeek)

Email Peek is a cool mail app built using the Office 365 APIs on the iOS platform. This app allows you to peek at just the email conversations you truly care about when you are away, such as when you are on vacation. Email Peek also makes it easy for you to send quick replies to messages without typing. This app uses many of the features of the Office 365 Mail API such as read/write, server-side filtering, and categories.

[![Office 365 iOS Email Peek](/readme-images/emailpeek_video.png)](https://youtu.be/WqEqxKD6Bfw "Click to see the sample in action")

**Table of contents**

* [Set up your environment](#set-up-your-environment)
* [Use CocoaPods to import the O365 iOS SDK](#use-cocoapods-to-import-the-o365-ios-sdk)
* [Register your app with Microsoft Azure](#register-your-app-with-microsoft-azure)
* [Get the Client ID and Redirect Uri into the project](#get-the-client-id-and-redirect-uri-into-the-project)
* [Important code files](#code-of-interest)
* [Questions and comments](#questions-and-comments)
* [Troubleshooting](#troubleshooting)
* [Additional resources](#additional-resources)



## Set up your environment ##

To run Email Peek, you need the following:


* [Xcode](https://developer.apple.com/) from Apple.
* An Office 365 account. You can get an Office 365 account by signing up for an [Office 365 Developer site](http://msdn.microsoft.com/library/office/fp179924.aspx). This will give you access to the APIs that you can use to create apps that target Office 365 data.
* A Microsoft Azure tenant to register your application. Azure Active Directory provides identity services that applications use for authentication and authorization. A trial subscription can be acquired here: [Microsoft Azure](https://account.windowsazure.com/SignUp).

**Important**: You will also need to ensure your Azure subscription is bound to your Office 365 tenant. To do this see the **Adding a new directory** section in the Active Directory team's blog post, [Creating and Managing Multiple Windows Azure Active Directories](http://blogs.technet.com/b/ad/archive/2013/11/08/creating-and-managing-multiple-windows-azure-active-directories.aspx). You can also read [Set up Azure Active Directory access for your Developer Site](http://msdn.microsoft.com/office/office365/howto/setup-development-environment#bk_CreateAzureSubscription) for more information.


* Installation of [CocoaPods](https://cocoapods.org/) as a dependency manager. CocoaPods will allow you to pull the Office 365 and Azure Active Directory Authentication Library (ADAL) dependencies into the project.

Once you have an Office 365 account and an Azure AD account that is bound to your Office 365 Developer site, you'll need to perform the following steps:

1. Register your application with Azure, and configure the appropriate Office 365 Exchange Online permissions.
2. Install and use CocoaPods to get the Office 365 and ADAL authentication dependencies into your project.
3. Enter the Azure app registration specifics (ClientID and RedirectUri) into the Email Peel app.

## Use CocoaPods to import the O365 iOS SDK
Note: If you've never used **CocoaPods** before as a dependency manager you'll have to install it prior to getting your Office 365 iOS SDK dependencies into your project.

Enter the next two lines of code from the **Terminal** app on your Mac.

sudo gem install cocoapods
pod setup

If the install and setup are successful, you should see the message **Setup completed in Terminal**. For more information on CocoaPods, and its usage, see [CocoaPods](https://cocoapods.org/).


**Get the Office 365 SDK for iOS dependencies in your project**
The Email Peek app already contains a podfile that will get the Office 365 and ADAL components (pods) into your project. It's located in the sample root ("Podfile"). The example shows the contents of the file.

target ‘O365-iOS-EmailPeek’ do
pod 'ADALiOS',   '~> 1.2.1'
pod 'Office365/Outlook', '= 0.9.1'
pod 'Office365/Discovery', '= 0.9.1'
end


You'll simply need to navigate to the project directory in the **Terminal** (root of the project folder) and run the following command.


pod install

Note: You should receive confirmation that these dependencies have been added to the project and that you must open the workspace instead of the project from now on in Xcode (**O365-iOS-EmailPeek.xcworkspace**).  If there is a syntax error in the Podfile, you will encounter an error when you run the install command.

## Register your app with Microsoft Azure
1.	Sign in to the [Azure Management Portal](https://manage.windowsazure.com), using your Azure AD credentials.
2.	Select **Active Directory** on the left menu, then select the directory for your Office 365 developer site.
3.	On the top menu, select **Applications**.
4.	Select **Add** from the bottom menu.
5.	On the **What do you want to do page**, select **Add an application my organization is developing**.
6.	On the **Tell us about your application** page, specify **O365-iOS-EmailPeek** for the application name and select **NATIVE CLIENT APPLICATION** for type.
7.	Select the arrow icon on the lower-right corner of the page.
8.	On the Application information page, specify a Redirect URI, for this example, you can specify http://localhost/emailpeek, and then select the check box in the lower-right hand corner of the page. Remember this value for the section **Get the ClientID and RedirectUri into the project**.
9.	Once the application has been successfully added, you will be taken to the Quick Start page for the application. Select Configure in the top menu.
10.	Under **permissions to other applications**, add the following permission: **Add the Office 365 Exchange Online application**, and select **Read and write user mail**, and **Send mail as a user** permissions.
13.	Copy the value specified for **Client ID** on the **Configure** page. Remember this value for the section **Getting the ClientID and RedirectUri into the project**.
14.	Select **Save** in the bottom menu.


## Get the Client ID and Redirect Uri into the project

Finally you'll need to add the Client ID and Redirect Uri you recorded from the previous section **Register your app with Microsoft Azure**.

Browse the **O365-iOS-EmailPeek** project directory and open up the workspace (O365-EmailPeek-iOS.xcworkspace). In the **AppDelegate.m** file you'll see that the **ClientID** and **RedirectUri** values can be added to the top of the file. Supply the necessary values in this file.

// You will set your application's clientId and redirect URI. You get
// these when you register your application in Azure AD.
static NSString * const kClientId           = @"ENTER_REDIRECT_URI_HERE";
static NSString * const kRedirectURLString  = @"ENTER_CLIENT_ID_HERE";
static NSString * const kAuthorityURLString = @"https://login.microsoftonline.com/common";



## Important code files


**Models**

These domain entities are custom classes that represent the data of the application. All of these classes are immutable.  They wrap the basic entities provided by the Office 365 SDK.

**Office365 Helpers**

The helpers are the classes that actually communicate with Office 365 by making API calls. This architecture decouples the rest of the app from the Office365 SDK.

**Office365 Server Side Filters**

These classes help make the appropriate API call with the correct Office 365 server-side filter clauses during fetch.

**ConversationManager and SettingsManager**

These classes help manage conversations and settings in the app.

**Controllers**

These are the controllers for the different views supported by Email Peek.

**Views**

This implements a custom cell which is used in two different places, in the ConversationListViewController and ConversationViewController.


## Questions and comments

We'd love to get your feedback on the Email Peek app sample. You can send your feedback to us in the [Issues](https://github.com/OfficeDev/O365-EmailPeek-iOS) section of this repository. <br>
<br>
Questions about Office 365 development in general should be posted to [Stack Overflow](http://stackoverflow.com/questions/tagged/Office365+API). Please tag your questions are tagged with [Office365] and [API].

## Troubleshooting
With the Xcode 7.0 update, App Transport Security is enabled for simulators and devices running iOS 9. See [App Transport Security Technote](https://developer.apple.com/library/prerelease/ios/technotes/App-Transport-Security-Technote/).

For this sample we have created a temporary exception for the following domain in the plist:

- outlook.office365.com

If these exceptions are not included, all calls into the Office 365 API will fail in this app when deployed to an iOS 9 simulator in Xcode.


## Additional resources

* [Office 365 Connect app for iOS](https://github.com/OfficeDev/O365-iOS-Connect)
* [Office 365 Code Snippets for iOS](https://github.com/OfficeDev/O365-iOS-Snippets)
* [Office 365 Profile Sample for iOS](https://github.com/OfficeDev/O365-iOS-Profile)
* [Office 365 APIs documentation](http://msdn.microsoft.com/office/office365/howto/platform-development-overview)
* [Office 365 API code samples and videos](https://msdn.microsoft.com/office/office365/howto/starter-projects-and-code-samples)
* [Office Dev Center](http://dev.office.com/)
* [Medium article on Email Peek](https://medium.com/office-app-development/why-read-email-when-you-can-peek-2af947d352dc)

## Copyright

Copyright (c) 2015 Microsoft. All rights reserved.
