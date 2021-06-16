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
#Email Peek — приложение для iOS, созданное с помощью Office 365 #
[![Состояние сборки](https://travis-ci.org/OfficeDev/O365-iOS-EmailPeek.svg)](https://travis-ci.org/OfficeDev/O365-iOS-EmailPeek)

Email Peek — это полезное почтовое приложение, созданное с помощью API Office 365 на платформе iOS. Это приложение позволяет просматривать только действительно важные беседы, когда вас нет на месте, например во время отпуска. Кроме того, с Email Peek вы без труда сможете отправлять короткие ответы на сообщения, не печатая. В этом приложении используются многие функции API почты Office 365, такие как чтение и запись, фильтрация на стороне сервера и категории.

[![Office 365 iOS Email Peek](/readme-images/emailpeek_video.png)![Щелкните, чтобы посмотреть на примере, как это работает](/readme-images/emailpeek_video.png)

**Содержание**

* [Настройка среды](#set-up-your-environment)
* [Импорт пакета SDK Office 365 для iOS с помощью диспетчера зависимостей CocoaPods](#use-cocoapods-to-import-the-o365-ios-sdk)
* [Регистрация приложения в Microsoft Azure](#register-your-app-with-microsoft-azure)
* [Добавление идентификатора клиента и URI перенаправления в проект](#get-the-client-id-and-redirect-uri-into-the-project)
* [Важные файлы кода](#code-of-interest)
* [Вопросы и комментарии](#questions-and-comments)
* [Устранение неполадок](#troubleshooting)
* [Дополнительные ресурсы](#additional-resources)



## Настройка среды ##

Чтобы запустить Email Peek, необходимо следующее:


* [Xcode](https://developer.apple.com/) от Apple.
* Учетная запись Office 365. Для получения учетной записи Office 365 можно зарегистрироваться на [сайте разработчиков Office 365](http://msdn.microsoft.com/library/office/fp179924.aspx). Так вы получите доступ к интерфейсам API, с помощью которых можно создавать приложения, ориентированные на данные в Office 365.
* Клиент Microsoft Azure для регистрации приложения. В Azure Active Directory доступны службы идентификации, которые приложения используют для проверки подлинности и авторизации. Здесь можно получить пробную подписку: [Microsoft Azure](https://account.windowsazure.com/SignUp).

**Важно!** Убедитесь, что ваша подписка на Azure привязана к клиенту Office 365. Для этого просмотрите раздел **Добавление нового каталога** записи в блоге команды Active Directory, в которой рассматривается [создание нескольких каталогов Windows Azure Active Directory и управление ими](http://blogs.technet.com/b/ad/archive/2013/11/08/creating-and-managing-multiple-windows-azure-active-directories.aspx). Для получения дополнительных сведений можно ознакомиться со статьей [Настройка доступа к сайту разработчика с помощью Azure Active Directory](http://msdn.microsoft.com/office/office365/howto/setup-development-environment#bk_CreateAzureSubscription).


* Установка [CocoaPods](https://cocoapods.org/) в качестве диспетчера зависимостей. Диспетчер зависимостей CocoaPods позволяет добавить в проект зависимости Office 365 и Библиотеки проверки подлинности Active Directory (ADAL).

После того как вы создали учетную запись Office 365 и связали учетную запись Azure AD с Сайтом разработчика Office 365, выполните следующие действия.

1. Зарегистрируйте приложение в Azure и настройте необходимые разрешения Office 365 Exchange Online.
2. Установите диспетчер зависимостей CocoaPods и добавьте в проект зависимости Office 365 и проверки подлинности ADAL.
3. Введите сведения о регистрации приложения в Azure (ClientID и RedirectUri) в приложение Email Peel.

## Импортируйте пакет SDK Office 365 для iOS с помощью диспетчера зависимостей CocoaPods
Примечание. Если до этого вы никогда не пользовались диспетчером зависимостей **CocoaPods**, его необходимо установить перед добавлением зависимостей пакета SDK Office 365 для iOS в проект.

Введите две приведенные ниже строки кода из приложения **Терминал** на Mac.

sudo gem install cocoa
pods pod setup

После успешной установки и настройки должно появиться сообщение **Setup completed in Terminal**. Дополнительные сведения о диспетчере зависимостей CocoaPods и его использовании см. на сайте [CocoaPods](https://cocoapods.org/).


**Получите зависимости пакета Office 365 SDK для iOS в вашем проекте** Приложение Email Peek уже содержит компонент podfile, который добавит компоненты Office 365 и ADAL (pod) в проект. Он расположен в корневой папке приложения ("Podfile").
В примере показано содержимое файла.

target ‘O365-iOS-EmailPeek’ do
pod 'ADALiOS', '~> 1.2.1'
pod 'Office365/Outlook', '= 0.9.1'
pod 'Office365/Discovery', '= 0.9.1'
end


Необходимо просто перейти в каталог проекта в программе **Терминал** (корневую папку проекта) и выполнить следующую команду.


pod install

Примечание. Вы должны получить подтверждение, что эти зависимости добавлены в проект и теперь необходимо открывать рабочую область, а не проект в Xcode (**O365-iOS-EmailPeek.xcworkspace**). Если в компоненте Podfile есть синтаксическая ошибка, при выполнении команды install происходит ошибка.

## Регистрация приложения в Microsoft Azure
1.	Войдите на [портал управления Azure](https://manage.windowsazure.com), используя учетные данные Azure AD.
2.	Выберите **Active Directory** в левом меню, а затем выберите каталог для сайта разработчика Office 365.
3.	В верхнем меню выберите пункт **Приложения**.
4.	Выберите команду **Добавить** в нижнем меню.
5.	На странице **Что вы хотите сделать?** выберите **Добавить приложение, разрабатываемое моей организацией**.
6.	На странице **Расскажите о своем приложении** укажите имя приложения **Get the Office 365 SDK for iOS dependencies in your project** и выберите тип **СОБСТВЕННОЕ КЛИЕНТСКОЕ ПРИЛОЖЕНИЕ**.
7.	Щелкните значок стрелки в правом нижнем углу страницы.
8.	На странице сведений о приложении укажите URI перенаправления (для этого приложения вы можете указать http://localhost/emailpeek), а затем установите флажок в правом нижнем углу страницы. Запомните это значение для раздела **Добавление идентификатора клиента и URI перенаправления в проект**.
9.	После добавления приложения откроется страница "Быстрый запуск". Выберите пункт "Настройка" в верхнем меню.
10.	В разделе **разрешения для других приложений** добавьте указанное ниже разрешение. **Добавить приложение Office 365 Exchange Online**, а затем выберите разрешения **Чтение и запись почты пользователя** и **Отправка почты от имени пользователя**.
13.	Скопируйте значение, указанное для **идентификатора клиента** на странице **Настройка**. Запомните это значение для раздела **Добавление идентификатора клиента и URI перенаправления в проект**.
14.	В нижнем меню выберите пункт **Сохранить**.


## Добавление идентификатора клиента и URI перенаправления в проект

Наконец, необходимо добавить идентификатор клиента и URI перенаправления, записанные в предыдущем разделе **Регистрация приложения в Microsoft Azure**.

Перейдите в каталог проекта **O365-iOS-EmailPeek** и откройте рабочую область (O365-EmailPeek-iOS.xcworkspace). В файле **AppDelegate.m** вы увидите, что значения **ClientID** и **RedirectUri** можно добавить в начало файла. Укажите необходимые значения в этом файле.

// Вы добавите идентификатор клиента и URI перенаправления. Вы получите
// их при регистрации приложения в Azure AD.
static NSString * const kClientId = @"ENTER_REDIRECT_URI_HERE";
static NSString * const kRedirectURLString = @"ENTER_CLIENT_ID_HERE";
static NSString * const kAuthorityURLString = @"https://login.microsoftonline.com/common";



## Важные файлы кода


**Модели**

Эти объекты — специальные классы, которые представляют данные приложения. Все эти классы являются неизменными. Они создают оболочку для основных объектов, предусмотренных пакетом SDK Office 365.

**Вспомогательные приложения Office365**

Вспомогательные приложения — это классы, которые взаимодействуют с Office 365, осуществляя вызовы API. Эта архитектура отделяет остальную часть приложения от пакета SDK Office 365.

**Серверные фильтры Office 365**

Эти классы помогают осуществить необходимый вызов API с правильными предложениями фильтров Office 365 на стороне сервера во время доступа.

**ConversationManager и SettingsManager**

Эти классы помогают управлять беседами и параметрами в приложении.

**Controllers**

Это контроллеры различных представлений, которые поддерживаются в Email Peek.

**Views**

Добавляет специальную ячейку, используемую в контроллерах ConversationListViewController и ConversationViewController.


## Вопросы и комментарии

Мы будем рады получить ваш отзыв о приложении Email Peek. Своими мыслями можете поделиться на вкладке [Проблемы](https://github.com/OfficeDev/O365-EmailPeek-iOS) этого репозитория. <br>
<br>
Общие вопросы о разработке решений для Office 365 следует публиковать на сайте [Stack Overflow](http://stackoverflow.com/questions/tagged/Office365+API). Помечайте свои вопросы тегами \[Office365] и \[API].

## Устранение неполадок
Для симуляторов и устройств под управлением iOS 9 с обновлением Xcode 7.0 поддерживается технология App Transport Security. См. [технический комментарий к App Transport Security](https://developer.apple.com/library/prerelease/ios/technotes/App-Transport-Security-Technote/).

Для этого примера создано временное исключение для следующего домена в plist:

- outlook.office365.com

Если эти исключения не включены, при развертывании на симуляторе с iOS 9 в Xcode вызов API Office 365 в этом приложении будет невозможен.


## Дополнительные ресурсы

* [Приложение Office 365 Connect для iOS](https://github.com/OfficeDev/O365-iOS-Connect)
* [Фрагменты кода Office 365 для iOS](https://github.com/OfficeDev/O365-iOS-Snippets)
* [Пример профиля Office 365 для iOS](https://github.com/OfficeDev/O365-iOS-Profile)
* [Документация по API-интерфейсам Office 365](http://msdn.microsoft.com/office/office365/howto/platform-development-overview)
* [API Office 365: примеры кода и видео](https://msdn.microsoft.com/office/office365/howto/starter-projects-and-code-samples)
* [Центр разработчиков Office](http://dev.office.com/)
* [Статья об Email Peek на сайте Medium](https://medium.com/office-app-development/why-read-email-when-you-can-peek-2af947d352dc)

## Авторские права

(c) Корпорация Майкрософт (Microsoft Corporation), 2015. Все права защищены.


Этот проект соответствует [Правилам поведения разработчиков открытого кода Майкрософт](https://opensource.microsoft.com/codeofconduct/). Дополнительные сведения см. в разделе [часто задаваемых вопросов о правилах поведения](https://opensource.microsoft.com/codeofconduct/faq/). Если у вас возникли вопросы или замечания, напишите нам по адресу [opencode@microsoft.com](mailto:opencode@microsoft.com).
