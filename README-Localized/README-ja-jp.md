#Email Peek - Office 365 を使用して構築された iOS アプリ #
[![ビルドの状態](https://travis-ci.org/OfficeDev/O365-iOS-EmailPeek.svg)](https://travis-ci.org/OfficeDev/O365-iOS-EmailPeek)

Email Peek は、iOS プラットフォームで Office 365 API を使用して構築された優れたメール アプリです。このアプリを使用すると、休暇中などの不在時に、本当に重要なメールの会話のみをすばやく確認できます。Email Peek では、メッセージにすばやく返信するのも簡単で、入力する必要もありません。このアプリは、読み取り/書き込み、サーバー側のフィルタリング、カテゴリなど、Office 365 メール API の多くの機能を使用しています。

[![Office 365 iOS Email Peek](../readme-images/emailpeek_video.png)](https://youtu.be/WqEqxKD6Bfw "活用できるサンプルを確認するにはこちらをクリックしてください")

**目次**

* [環境をセットアップする](#set-up-your-environment)
* [CocoaPods を使用して O365 iOS SDK をインポートする](#use-cocoapods-to-import-the-o365-ios-sdk)
* [Microsoft Azure にアプリを登録する](#register-your-app-with-microsoft-azure)
* [プロジェクトにクライアント ID とリダイレクト URI を取り込む](#get-the-client-id-and-redirect-uri-into-the-project)
* [重要なコード ファイル](#code-of-interest)
* [質問とコメント](#questions-and-comments)
* [トラブルシューティング](#troubleshooting)
* [その他の技術情報](#additional-resources)



## 環境のセットアップ ##

Email Peek を実行するには、次のものが必要です。


*Apple の[Xcode](https://developer.apple.com/)。
*Office 365 アカウント。Office 365 アカウントは、[Office 365 開発者向けサイト](http://msdn.microsoft.com/library/office/fp179924.aspx)にサイン アップすると取得できます。これにより、Office 365 のデータを対象とするアプリの作成に使用できる API にアクセスできるようになります。
*アプリケーションを登録する Microsoft Azure テナント。Azure Active Directory は、アプリケーションが認証と承認に使用する ID サービスを提供します。こちらから試用版サブスクリプションを取得できます。[Microsoft Azure](https://account.windowsazure.com/SignUp)

**重要**:Azure サブスクリプションが Office 365 テナントにバインドされていることを確認する必要もあります。これを行うには、Active Directory チームのブログ投稿「[複数の Windows Azure Active Directory を作成して管理する](http://blogs.technet.com/b/ad/archive/2013/11/08/creating-and-managing-multiple-windows-azure-active-directories.aspx)」の「**新しいディレクトリを追加する**」セクションをご覧ください。また、詳細については、「[開発者向けサイトに Azure Active Directory へのアクセスをセットアップする](http://msdn.microsoft.com/office/office365/howto/setup-development-environment#bk_CreateAzureSubscription)」もご覧ください。


*依存関係マネージャーとしての [CocoaPods](https://cocoapods.org/) のインストール。CocoaPods を使用すると、Office 365 と Azure Active Directory 認証ライブラリ (ADAL) の依存関係をプロジェクトに導入することができます。

Office 365 アカウント、および Office 365 開発者サイトにバインドされた Azure AD アカウントを取得したら、次の手順を実行する必要があります。

1. Azure にアプリケーションを登録し、Office 365 Exchange Online の適切なアクセス許可を構成します。
2. CocoaPods をインストールし、これを使用して、プロジェクトに Office 365 と ADAL 認証の依存関係を取り込みます。
3. Azure アプリの登録固有の情報 (ClientID と RedirectUri) を、Email Peek アプリに入力します。

## CocoaPods を使用して O365 iOS SDK をインポートする
注:依存関係マネージャーとして **CocoaPods** を初めて使用する場合は、これをインストールしてからプロジェクトで Office 365 iOS SDK の依存関係を取り込む必要があります。

Mac の**ターミナル** アプリから、次の 2 行のコードを入力します。

sudo gem install cocoapods
pod setup

インストールとセットアップが成功すると、「**ターミナルのセットアップが完了しました**」というメッセージが表示されます。CocoaPods とその使用法の詳細については、「[CocoaPods](https://cocoapods.org/)」をご覧ください。


**プロジェクトに iOS 版 Office 365 SDK の依存関係を取り込む**
Email Peek アプリには、プロジェクトに Office 365 と ADAL コンポーネント (pods) を取り込む podfile が既に含まれています。podfile がある場所は、サンプルの root ("Podfile") です。次の例は、ファイルの内容を示しています。

target ‘O365-iOS-EmailPeek’ do
pod 'ADALiOS',   '~> 1.2.1'
pod 'Office365/Outlook', '= 0.9.1'
pod 'Office365/Discovery', '= 0.9.1'
end


**Terminal** (プロジェクト フォルダーのルート) にあるプロジェクトのディレクトリに移動して、次のコマンドを実行する必要があります。


pod install

注:「これらの依存関係がプロジェクトに追加されました。今すぐ Xcode (**O365-iOS-EmailPeek.xcworkspace**) でプロジェクトの代わりにワークスペースを開く必要があります」という確認のメッセージを受信する必要があります。Podfile で構文エラーが発生すると、インストール コマンドを実行する際にエラーが発生します。

## Microsoft Azure にアプリを登録する
1.	Azure AD 資格情報を使用して、[Azure 管理ポータル](https://manage.windowsazure.com)にサインインします。
2.	左側のメニューで **[Active Directory]** を選んでから、Office 365 開発者向けサイトのディレクトリを選びます。
3.	上部のメニューで、**[アプリケーション]** を選びます。
4.	下部のメニューから、**[追加]** を選びます。
5.	**[何を行いますか]** ページで、**[組織で開発中のアプリケーションを追加]** を選びます。
6.	**[アプリケーションについてお聞かせください]** ページで、アプリケーション名には「**O365-iOS-EmailPeek**」を指定し、種類は**[NATIVE CLIENT APPLICATION]** を選びます。
7.	ページの右下隅にある矢印アイコンを選びます。
8.	[アプリケーション情報] ページで、リダイレクト URI を指定します。この例では http://localhost/emailpeek を指定します。続いて、ページの右下隅にあるチェック ボックスを選びます。この値は、「**プロジェクトに ClientID と RedirectUri を取り込む**」セクションで使用するため覚えておいてください。
9.	アプリケーションが正常に追加されたら、アプリケーションの [クイック スタート] ページに移動します。上部のメニューにある [構成] を選びます。
10.	**[他のアプリケーションへのアクセス許可]** の下で、**[Office 365 Exchange Online アプリケーションを追加する]** アクセス許可を追加し、**[ユーザーのメールの読み取りと書き込み]** と **[ユーザーとしてメールを送信]** の各アクセス許可を選びます。
13.	**[構成]** ページで、**[クライアント ID]** に指定された値をコピーします。この値は、「**プロジェクトに ClientID と RedirectUri を取り込む**」セクションで使用するため覚えておいてください。
14.	下部のメニューで、**[保存]** を選びます。


## プロジェクトにクライアント ID とリダイレクト URI を取り込む

最後に、前のセクション「**Microsoft Azure にアプリを登録する**」で記録したクライアント ID とリダイレクト URI を追加する必要があります。

**O365-iOS-EmailPeek** プロジェクトのディレクトリを参照し、ワークスペース (O365-EmailPeek-iOS.xcworkspace) を開きます。**AppDelegate.m** ファイルで、**ClientID** と **RedirectUri** の各値がファイルの一番上に追加されていることが分かります。このファイルに必要な値を指定します。

// You will set your application's clientId and redirect URI.You get
// these when you register your application in Azure AD.
static NSString * const kClientId           = @"ENTER_REDIRECT_URI_HERE";
static NSString * const kRedirectURLString  = @"ENTER_CLIENT_ID_HERE";
static NSString * const kAuthorityURLString = @"https://login.microsoftonline.com/common";



## 重要なコード ファイル


**モデル**

これらのドメインのエンティティは、アプリケーションのデータを表すカスタム クラスです。これらのすべてのクラスは変更できません。これらは Office 365 SDK で提供される基本的なエンティティをラップします。

**Office365 ヘルパー**

ヘルパーは、API 呼び出しを行って Office 365 と実際に通信するクラスです。このアーキテクチャでは、Office365 SDK からアプリの残りの部分が切り離されます。

**Office365 サーバー側フィルター**

これらのクラスを使用すると、フェッチ中に正しい Office 365 サーバー側フィルターの句で適切な API 呼び出しを行うことができます。

**ConversationManager と SettingsManager**

これらのクラスでは、アプリの会話と設定を管理できます。

**コントローラー**

これらは、Email Peek でサポートされているさまざまなビューのコントローラーです。

**ビュー**

これにより、ConversationListViewController と ConversationViewController の 2 つの異なる場所で使用されるカスタム セルが実装されます。


## 質問とコメント

Email Peek アプリ サンプルについて、Microsoft にフィードバックをお寄せください。フィードバックはこのリポジトリの「[問題](https://github.com/OfficeDev/O365-EmailPeek-iOS)」セクションで送信できます。<br>
<br>
Office 365 開発全般の質問につきましては、[スタック オーバーフロー](http://stackoverflow.com/questions/tagged/Office365+API)に投稿してください。質問には、[Office365] と [API] のタグを付けてください。

## トラブルシューティング
Xcode 7.0 のアップデートにより、iOS 9 を実行するシミュレーターやデバイス用に App Transport Security を使用できるようになりました。「[App Transport Security のテクニカル ノート](https://developer.apple.com/library/prerelease/ios/technotes/App-Transport-Security-Technote/)」をご覧ください。

このサンプルでは、plist 内の次のドメインのために一時的な例外を作成しました:

- outlook.office365.com

これらの例外が含まれていないと、Xcode で iOS 9 シミュレーターにデプロイされたときに、このアプリで Office 365 API へのすべての呼び出しが失敗します。


## その他の技術情報

* [iOS 用 Office 365 Connect アプリ](https://github.com/OfficeDev/O365-iOS-Connect)
* [iOS 用 Office 365 コード スニペット](https://github.com/OfficeDev/O365-iOS-Snippets)
* [iOS 用 Office 365 プロファイル サンプル](https://github.com/OfficeDev/O365-iOS-Profile)
* [Office 365 API ドキュメント](http://msdn.microsoft.com/office/office365/howto/platform-development-overview)
* [Office 365 API のサンプル コードとビデオ](https://msdn.microsoft.com/office/office365/howto/starter-projects-and-code-samples)
* [Office デベロッパー センター](http://dev.office.com/)
* [Email Peek の Medium の記事](https://medium.com/office-app-development/why-read-email-when-you-can-peek-2af947d352dc)

## 著作権

Copyright (c) 2015 Microsoft.All rights reserved.

