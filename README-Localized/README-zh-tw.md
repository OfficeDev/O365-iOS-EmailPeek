#電子郵件預覽 - 使用 Office 365 # 建置的 iOS 應用程式
[![組建狀態](https://travis-ci.org/OfficeDev/O365-iOS-EmailPeek.svg)](https://travis-ci.org/OfficeDev/O365-iOS-EmailPeek)

電子郵件預覽是在 iOS 平台上，使用 Office 365 API 建置的一個很棒的郵件應用程式。這個應用程式可讓您預覽您不在時 (例如度假) 真正關心的電子郵件交談。電子郵件預覽也能讓您輕鬆且快速地回覆郵件，而不需輸入。這個應用程式使用 Office 365 郵件 API 的許多功能，例如讀取/寫入、伺服器端篩選及類別。

[![Office 365 iOS Email Peek](../readme-images/emailpeek_video.png)](https://youtu.be/WqEqxKD6Bfw "Click to see the sample in action")

**目錄**

* [設定您的環境](#set-up-your-environment)
* [使用 CocoaPods 以匯入 O365 iOS SDK](#use-cocoapods-to-import-the-o365-ios-sdk)
* [使用 Microsoft Azure 註冊您的應用程式](#register-your-app-with-microsoft-azure)
* [取得用戶端識別碼，並將 Uri 重新導向至專案](#get-the-client-id-and-redirect-uri-into-the-project)
* [重要程式碼檔案](#code-of-interest)
* [問題和意見](#questions-and-comments)
* [疑難排解](#troubleshooting")
* [其他資源](#additional-resources)



## 設定您的環境 ##

若要執行電子郵件預覽，您需要下列項目︰


* 來自 Apple 的 [Xcode](https://developer.apple.com/)。
* Office 365 帳戶。您可以註冊 [Office 365 開發人員網站 ](http://msdn.microsoft.com/library/office/fp179924.aspx)來取得 Office 365 帳戶。這會讓您存取 API，可用來建立目標為 Office 365 資料的應用程式。
* 用來註冊您的應用程式的 Microsoft Azure 租用戶。Azure Active Directory 會提供識別服務，以便應用程式用於驗證和授權。可以在這裡取得試用版訂閱︰[Microsoft Azure](https://account.windowsazure.com/SignUp)。

**重要**：您還需要確定您的 Azure 訂用帳戶已繫結至您的 Office 365 租用戶。若要這麼做，請參閱 Active Directory 小組的部落格文章[建立和管理多個 Windows Azure Active Directory](http://blogs.technet.com/b/ad/archive/2013/11/08/creating-and-managing-multiple-windows-azure-active-directories.aspx) 的**新增目錄**一節。您也可以閱讀[為您的開發人員網站設定 Azure Active Directory 存取](http://msdn.microsoft.com/office/office365/howto/setup-development-environment#bk_CreateAzureSubscription)的詳細資訊。


*以相依性管理員身分安裝 [CocoaPods](https://cocoapods.org/)。CocoaPods 可讓您將 Office 365 和 Azure Active Directory Authentication Library (ADAL) 相依性提取至專案中。

一旦您有 Office 365 帳戶和已繫結至您的 Office 365 開發人員網站的 Azure AD 帳戶，您必須執行下列步驟︰

1. 使用 Azure 註冊您的應用程式，並設定適當的 Office 365 Exchange Online 權限。
2. 安裝並使用 CocoaPods，將 Office 365 和 ADAL 驗證相依性置入您的專案中。
3. 在電子郵件預覽應用程式中輸入 Azure 應用程式註冊細節 (ClientID 和 RedirectUri)。

## 使用 CocoaPods 以匯入 O365 iOS SDK
附註：如果您從未以依存關係管理員身分使用 **CocoaPods**，您必須先安裝它，才能將 Office 365 iOS SDK 相依性置於您的專案。

在 Mac 上，從 **Terminal** 應用程式輸入接下來的兩行程式碼。

sudo gem install cocoapods
pod setup

如果安裝和設定都成功，您應該會看到**終端機安裝完成**訊息。如需有關 CocoaPods 和其用法的詳細資訊，請參閱 [CocoaPods](https://cocoapods.org/)。


**在您的專案中取得 Office 365 SDK for iOS 相依性**
電子郵件預覽應用程式已經包含可將 Office 365 和 ADAL 元件 (pods) 放入專案的 podfile。它位於範例根目錄 ("Podfile") 中。此範例會顯示檔案的內容。

target ‘O365-iOS-EmailPeek’ do
pod 'ADALiOS',   '~> 1.2.1'
pod 'Office365/Outlook', '= 0.9.1'
pod 'Office365/Discovery', '= 0.9.1'
end


您只需要瀏覽到 **Terminal** (專案資料夾的根目錄) 中的專案目錄，然後執行下列命令。


pod install

附註：您應該會收到這些相依性已加入至專案的確認，且從現在起，您必須在 Xcode 上開啟工作區而非專案 (**O365-iOS-EmailPeek.xcworkspace**)。如果在 Podfile 中有語法錯誤，就會在執行安裝命令時發生錯誤。

## 向 Microsoft Azure 註冊您的應用程式
1.	使用 Azure AD 認證登入 [Azure 管理入口網站](https://manage.windowsazure.com)。
2.	選取左邊功能表上的 [Active Directory]****，然後選取您的 Office 365 開發人員網站的目錄。
3.	在上方功能表中，選取 [應用程式]****。
4.	從下方功能表選取 [新增]****。
5.	在 [您想要做什麼]**** 頁面上，選取 [新增我的組織正在開發的應用程式]****。
6.	在 [告訴我們您的應用程式]**** 頁面上，為應用程式名稱指定 **O365-iOS-EmailPeek**，並為類型選取 [原生用戶端應用程式]****。
7.	選取頁面右下角的箭號圖示。
8.	在 [應用程式的資訊] 頁面上，指定重新導向 URI，在這個範例中，您可以指定 http://localhost/emailpeek，然後選取頁面右下角的核取方塊。為**將 ClientID 和 RedirectUri 置於專案**一節記憶此值。
9.	一旦成功新增應用程式，您就會進入應用程式的 [快速入門] 頁面。選取頂端功能表中的 [設定]。
10.	在 [其他應用程式的權限]**** 下新增下列權限︰[新增 Office 365 Exchange Online 應用程式]****，再依序選取 [讀取和寫入使用者郵件]**** 和 [以使用者身分傳送郵件]**** 權限。
13.	在 [設定]**** 頁面上複製為 [用戶端識別碼]**** 指定的值。為**將 ClientID 和 RedirectUri 置於專案**一節記憶此值。
14.	選取底部功能表中的 [儲存]****。


## 取得用戶端識別碼，並將 Uri 重新導向至專案

最後，您需要新增上一節**向 Microsoft Azure 註冊您的應用程式**所記錄的用戶端識別碼 和重新導向的 Uri。

瀏覽 **O365-iOS-EmailPeek** 專案目錄並開啟工作區 (O365-EmailPeek-iOS.xcworkspace)。在 **AppDelegate.m** 檔案中，您會看到檔案頂端新增 **ClientID** 和 **RedirectUri** 值。在此檔案中提供必要的值。

// 您會設定應用程式的 clientId 和重新導向 URI。您會在
// Azure AD 中登錄應用程式時取得。
static NSString * const kClientId           = @"ENTER_REDIRECT_URI_HERE";
static NSString * const kRedirectURLString  = @"ENTER_CLIENT_ID_HERE";
static NSString * const kAuthorityURLString = @"https://login.microsoftonline.com/common";



# # 重要的程式碼檔案


**模型**

這些網域實體是代表應用程式資料的自訂類別。所有這些類別都是不變的。他們會包裝 Office 365 SDK 所提供的基本實體。

**Office365 協助程式**

協助程式是藉由 API 呼叫，與 Office 365 實際通訊的類別。這種架構會從 Office365 SDK 中解構其餘應用程式。

**Office365 伺服器端篩選**

這些類別可在擷取期間，以正確的 Office 365 伺服器端篩選子句來協助進行適當的 API 呼叫。

**ConversationManager 和 SettingsManager**

這些類別可幫助管理應用程式中的對話和設定。

** 控制器 **

這些是適用於電子郵件預覽支援的不同檢視的控制器。

**檢視**

這會實作兩個不同位置 (ConversationListViewController 和 ConversationViewController) 中使用的自訂儲存格。


## 問題與意見

我們樂於在電子郵件預覽應用程式範例中取得您的意見反應。您可以在此儲存機制的[問題](https://github.com/OfficeDev/O365-EmailPeek-iOS)區段中，將意見反應傳給我們。<br>
<br>
Office 365 的一般開發問題必須張貼至[堆疊溢位](http://stackoverflow.com/questions/tagged/Office365+API)。請確定使用 [Office365] 和 [API] 標記您的問題。

## 疑難排解
利用 Xcode 7.0 更新，會針對執行  iOS 9 的模擬器和裝置啟用應用程式傳輸安全性。請參閱 [應用程式傳輸安全性技術說明](https://developer.apple.com/library/prerelease/ios/technotes/App-Transport-Security-Technote/)。

在這個範例中，我們已經為 plist 中的下列網域建立暫存例外狀況：

- outlook.office365.com

如果不包含這些例外狀況，在 Xcode 中部署到 iOS 9 模擬器時，所有 Office 365 API 的呼叫都會在此應用程式中進行。


## 其他資源

* [iOS 的 Office 365 Connect 應用程式](https://github.com/OfficeDev/O365-iOS-Connect)
* [iOS 的 Office 365 程式碼片段](https://github.com/OfficeDev/O365-iOS-Snippets)
* [iOS 的 Office 365 設定檔範例](https://github.com/OfficeDev/O365-iOS-Profile)
* [Office 365 API 文件](http://msdn.microsoft.com/office/office365/howto/platform-development-overview)
* [Office 365 API 程式碼範例和視訊](https://msdn.microsoft.com/office/office365/howto/starter-projects-and-code-samples)
* [Office 開發中心](http://dev.office.com/)
* [電子郵件預覽上的媒體文件](https://medium.com/office-app-development/why-read-email-when-you-can-peek-2af947d352dc)

## 著作權

Copyright (c) 2015 Microsoft.著作權所有，並保留一切權利。
