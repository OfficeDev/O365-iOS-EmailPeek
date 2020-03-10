---
page_type: sample
products:
- office-outlook
- office-365
languages:
- objc
extensions:
  contentType: samples
  createdDate: 2/26/2015 2:49:40 PM
  scenarios:
  - Mobile
---
#Email Peek - 使用 Office 365 构建的 iOS 应用程序#
[![生成状态](https://travis-ci.org/OfficeDev/O365-iOS-EmailPeek.svg)](https://travis-ci.org/OfficeDev/O365-iOS-EmailPeek)

Email Peek 是使用 iOS 平台上的 Office 365 API 生成的一款非常棒的邮件应用。此应用允许您在离开办公室时（例如，在度假时）仅查看您真正关心的电子邮件对话。借助 Email Peek，您可以轻松地发送邮件的快速回复，而无需键入任何内容。此应用使用 Office 365 邮件 API 的许多功能，如读/写、服务器端筛选和类别等。

[![Office 365 iOS Email Peek](/readme-images/emailpeek_video.png)![单击查看活动示例](/readme-images/emailpeek_video.png)

**目录**

* [设置环境](#set-up-your-environment)
* [使用 CocoaPods 导入 O365 iOS SDK](#use-cocoapods-to-import-the-o365-ios-sdk)
* [使用 Microsoft Azure 注册应用](#register-your-app-with-microsoft-azure)
* [将客户端 ID 和重定向 URI 导入项目](#get-the-client-id-and-redirect-uri-into-the-project)
* [重要代码文件](#code-of-interest)
* [问题和意见](#questions-and-comments)
* [疑难解答](#troubleshooting)
* [其他资源](#additional-resources)



## 设置环境 ##

若要运行 Email Peek，您需要具备以下条件：


* Apple 的 [Xcode](https://developer.apple.com/)。
* Office 365 帐户。可注册 [Office 365 开发人员网站](http://msdn.microsoft.com/library/office/fp179924.aspx)获取 Office 365 帐户。这将使您能够访问可用于面向 Office 365 数据创建应用的 API。
* 用于注册你的应用程序的 Microsoft Azure 租户。Azure Active Directory 为应用程序提供了用于进行身份验证和授权的标识服务。您还可在此处获得试用订阅：[Microsoft Azure](https://account.windowsazure.com/SignUp)。

**重要说明**：还需要确保你的 Azure 订阅已绑定到 Office 365 租户。要执行这一操作，请参阅 Active Directory 团队的博客文章“[创建和管理多个 Windows Azure Active Directory](http://blogs.technet.com/b/ad/archive/2013/11/08/creating-and-managing-multiple-windows-azure-active-directories.aspx)”中的“**添加新目录**”部分。有关详细信息，还可参阅“[为开发人员网站设置 Azure Active Directory 访问](http://msdn.microsoft.com/office/office365/howto/setup-development-environment#bk_CreateAzureSubscription)”。


* 安装 [CocoaPods](https://cocoapods.org/) 成为依存关系管理器。CocoaPods 允许您将 Office 365 和 Azure Active Directory Authentication Library (ADAL) 依赖项导入项目。

在拥有 Office 365 帐户以及绑定到 Office 365 开发人员网站的 Azure AD 帐户，您将需要执行以下步骤：

1. 在 Azure 中注册您的应用程序，并配置相应的 Office 365 Exchange Online 权限。
2. 安装并使用 CocoaPods 将 Office 365 和 ADAL 身份验证依赖项导入项目。
3. 将 Azure 应用注册详细信息（ClientID 和 RedirectUri）输入到 Email Peel 应用。

## 使用 CocoaPods 导入 O365 iOS SDK
注意：如果您以前从未将 **CocoaPods** 用作依赖管理器，则需要先安装 CocoaPods 以将您的 Office 365 iOS SDK 依赖项导入项目。

在 Mac 上的“**终端**”应用中输入以下两行代码。

sudo gem install cocoapods
pod setup

如果安装和设置成功，您应该看到消息：**已完成终端中的设置**。有关 CocoaPods 的更多信息和使用方法，参见 [CocoaPods](https://cocoapods.org/)。


**在项目中获取适用于 iOS 的 Office 365 SDK 依赖项**Email Peek 应用已经包含了可将 Office 365 和 ADAL 组件 (pod) 导入到项目中的 podfile。
它位于示例根（“Podfile”）中。该示例显示文件的内容。

target ‘O365-iOS-EmailPeek’ do
pod 'ADALiOS', '~> 1.2.1'
pod 'Office365/Outlook', '= 0.9.1'
pod 'Office365/Discovery', '= 0.9.1'
end


您只需导航到“**终端**”的项目目录（项目文件夹的根）中，并运行以下命令。


pod install

注意：您应该在发生以下情况时收到确认：依赖项添加到项目以及必须从现在起在 Xcode (**O365-iOS-EmailPeek.xcworkspace**) 中而不是从项目打开工作区。如果 Podfile 中存在语法错误，则您会在运行安装命令时遇到错误。

## 使用 Microsoft Azure 注册应用
1.	使用你的 Azure AD 凭据登录到[Azure 管理门户](https://manage.windowsazure.com)。
2.	选择左侧菜单中的 **Active Directory**，然后选择 Office 365 开发人员网站的目录。
3.	在顶部菜单中，选择“**应用程序**”。
4.	选择底部菜单中的“**添加**”。
5.	在“**希望执行何种操作**”页面上选择“**添加我的组织正在开发的应用程序**”。
6.	在“**告诉我们你的应用程序**”页上，为该应用程序名称指定 **O365-iOS-EmailPeek**，并选择“**本机客户端应用程序**”类型。
7.	选择页面右下角的箭头图标。
8.	在应用程序信息页中，指定重定向 URI，对于本例，您可以指定 http://localhost/emailpeek，然后选中页面右下角的复选框。记住此值，以便在“**将 ClientID 和 RedirectUri 导入项目**”部分使用。
9.	成功添加应用程序后，您将被带到应用程序的“快速启动”页面。在顶部菜单中选择“配置”。
10.	在“**针对其他应用程序的权限**”下，添加下列权限：“**添加 Office 365 Exchange Online 应用程序**”，然后选择“**阅读和撰写用户邮件**”，和“**以用户身份发送邮件**”权限。
13.	在**配置**页面上复制指定给**客户端 ID** 的值。记住此值，以便在“**将 ClientID 和 RedirectUri 导入项目**”部分使用。
14.	选择底部菜单中的“**保存**”。


## 将客户端 ID 和重定向 URI 导入项目

最后，您将需要添加您在上一节**在 Microsoft Azure 中注册应用**中记录的客户端 ID 和重定向 URI。

浏览 **O365-iOS-EmailPeek** 项目目录并打开工作区 （O365-EmailPeek-iOS.xcworkspace）。在 **AppDelegate.m** 文件中，您会发现，**ClientID** 和 **RedirectUri** 值可以添加到文件的顶部。在此文件中提供必需的值。

// 您将设置应用程序的 clientId 和重定向 URI。你会在
// 注册应用至 Azure AD 中时获得这些。
static NSString * const kClientId = @"ENTER_REDIRECT_URI_HERE";
static NSString * const kRedirectURLString = @"ENTER_CLIENT_ID_HERE";
static NSString * const kAuthorityURLString = @"https://login.microsoftonline.com/common";



## 重要代码文件


**模型**

这些域实体是自定义类，用于表示该应用程序的数据。所有这些类都是不可变的。他们包装由 Office 365 SDK 提供的基本实体。

**Office 365 帮助程序**

帮助程序是通过调用 API 真正与 Office 365 进行通信的类。这种体系结构将应用的其余部分从 Office365 SDK 中分离出来。

**Office365 服务器端筛选**

在提取过程中，这些类可帮助使用正确的 Office 365 服务器端筛选子句进行适当的 API 调用。

**ConversationManager 和 SettingsManager**

这些类可帮助管理应用中的对话和设置。

**控制器**

这些都是控制器，用于查看 Email Peek 支持的不同视图。

**视图**

这可以实现可在两个不同地方（ConversationListViewController 和 ConversationViewController）使用的自定义单元格。


## 问题和意见

我们乐于倾听您有关 Email Peek 应用示例的反馈。可以在此存储库中的[“问题”](https://github.com/OfficeDev/O365-EmailPeek-iOS)部分向我们发送反馈。<br>
<br>
与 Office 365 开发相关的问题一般应发布到 [Stack Overflow](http://stackoverflow.com/questions/tagged/Office365+API)。请标记有 [Office365] 和 [API] 标签的问题。

## 疑难解答
通过 Xcode 7.0 更新，运行 iOS 9 的模拟器和设备会启用应用传输安全性。请参阅[应用传输安全技术说明](https://developer.apple.com/library/prerelease/ios/technotes/App-Transport-Security-Technote/)。

在本示例中，我们已经为 plist 中的以下域创建了一个临时异常：

- outlook.office365.com

如果不包括这些异常情况，则在部署到 Xcode 中的 iOS 9 模拟器时，此应用中所有调用 Office 365 API 的操作都将失败。


## 其他资源

* [适用于 iOS 的 Office 365 Connect 应用](https://github.com/OfficeDev/O365-iOS-Connect)
* [适用于 iOS 的 Office 365 代码段](https://github.com/OfficeDev/O365-iOS-Snippets)
* [适用于 iOS 的 Office 365 配置文件示例](https://github.com/OfficeDev/O365-iOS-Profile)
* [Office 365 API 文档](http://msdn.microsoft.com/office/office365/howto/platform-development-overview)
* [Office 365 API 代码示例和视频](https://msdn.microsoft.com/office/office365/howto/starter-projects-and-code-samples)
* [Office 开发人员中心](http://dev.office.com/)
* [Email Peek 媒体文章](https://medium.com/office-app-development/why-read-email-when-you-can-peek-2af947d352dc)

## 版权信息

版权所有 (c) 2015 Microsoft。保留所有权利。


此项目已采用 [Microsoft 开放源代码行为准则](https://opensource.microsoft.com/codeofconduct/)。有关详细信息，请参阅[行为准则 FAQ](https://opensource.microsoft.com/codeofconduct/faq/)。如有其他任何问题或意见，也可联系 [opencode@microsoft.com](mailto:opencode@microsoft.com)。
