#Email Peek – Eine mit Office 365 erstellte iOS-App #
[![Buildstatus](https://travis-ci.org/OfficeDev/O365-iOS-EmailPeek.svg)](https://travis-ci.org/OfficeDev/O365-iOS-EmailPeek)

Email Peek ist eine interessante E-Mail-App, die mithilfe der Office 365-APIs in der iOS-Plattform erstellt wurde. Mit dieser App können Sie unterwegs, z. B. im Urlaub, auf E-Mails einen Blick werfen, die Ihnen wirklich wichtig sind. Email Peek ermöglicht auch das Senden schneller Antwort-E-Mails ohne Tippen. Diese App verwendet viele Funktionen der Office 365-E-Mail-API, wie z. B. Lesen/Schreiben, serverseitige Filterung und Kategorien.

[![Office 365 iOS Email Peek](../readme-images/emailpeek_video.png)](https://youtu.be/WqEqxKD6Bfw "Klicken Sie, um das Beispiel in Aktion zu sehen.")

**Inhaltsverzeichnis**

* [Einrichten der Entwicklungsumgebung](#set-up-your-environment)
* [Verwenden von CocoaPods zum Importieren des O365 iOS-SDK](#use-cocoapods-to-import-the-o365-ios-sdk)
* [Registrieren der App bei Microsoft Azure](#register-your-app-with-microsoft-azure)
* [Abrufen der Client-ID und des Umleitungs-URI in das Projekt](#get-the-client-id-and-redirect-uri-into-the-project)
* [Wichtige Codedateien](#code-of-interest)
* [Fragen und Kommentare](#questions-and-comments)
* [Problembehandlung](#troubleshooting)
* [Zusätzliche Ressourcen](#additional-resources)



## Einrichten der Entwicklungsumgebung ##

Um Email Peek auszuführen, benötigen Sie Folgendes:


* [Xcode](https://developer.apple.com/xcode/downloads/) von Apple.
* Ein Office 365-Konto. Sie erhalten ein Office 365-Konto, indem Sie sich für eine [Office 365-Entwicklerwebsite registrieren](http://msdn.microsoft.com/library/office/fp179924.aspx). Dadurch erhalten Sie Zugriff auf die APIs, die Sie zum Erstellen von Apps mit Office 365-Daten verwenden können.
* Einen Microsoft Azure-Mandanten zum Registrieren Ihrer Anwendung. Von Azure Active Directory werden Identitätsdienste bereitgestellt, die durch Anwendungen für die Authentifizierung und Autorisierung verwendet werden. Ein Testabonnement können Sie hier erwerben: [Microsoft Azure](https://account.windowsazure.com/SignUp).

**Wichtig**: Sie müssen zudem sicherstellen, dass Ihr Azure-Abonnement an Ihren Office 365-Mandanten gebunden ist. Eine Anleitung finden Sie unter **Hinzufügen eines neuen Verzeichnisses** im Blogbeitrag des Active Directory-Teams [Creating and Managing Multiple Windows Azure Active Directories](http://blogs.technet.com/b/ad/archive/2013/11/08/creating-and-managing-multiple-windows-azure-active-directories.aspx) (Erstellen und Verwalten mehrerer Windows Azure Active Directories, in englischer Sprache). Weitere Informationen finden Sie auch unter [Set up Azure Active Directory access for your Developer Site](http://msdn.microsoft.com/office/office365/howto/setup-development-environment#bk_CreateAzureSubscription) (Einrichten des Zugriffs auf Active Directory für Ihre Entwicklerwebsite, in englischer Sprache).


* Installation von [CocoaPods](https://cocoapods.org/) als Abhängigkeits-Manager. CocoaPods ermöglicht es Ihnen, die Abhängigkeiten von Office 365 und der Azure Active Directory Authentifizierungsbibliothek (ADAL) in das Projekt zu übernehmen.

Wenn Sie über ein Office 365-Konto und ein Azure AD-Konto verfügen, das an Ihre Office 365-Entwicklerwebsite gebunden ist, führen Sie die folgenden Schritte aus:

1. Registrieren Sie die Anwendung bei Azure, und konfigurieren Sie die entsprechenden Berechtigungen für Office 365 Exchange Online.
2. Installieren und verwenden Sie CocoaPods, um die Office 365- und ADAL-Abhängigkeiten in Ihr Projekt zu übernehmen.
3. Geben Sie die App-Registrierungsdaten für Azure (Client-ID und Umleitungs-URI) in die App „Email Peek“ ein.

## Verwenden von CocoaPods zum Importieren des O365 iOS-SDK
Hinweis: Wenn Sie **CocoaPods** noch nie als Abhängigkeits-Manager verwendet haben, müssen Sie es installieren, bevor Sie die Office 365 iOS SDK-Abhängigkeiten in Ihr Projekt übernehmen.

Geben Sie die folgenden beiden Codezeilen aus der **Terminal**-App auf Ihrem Mac ein.

sudo gem install cocoapods
pod setup

Wenn Installation und Einrichtung erfolgreich waren, sollte Ihnen die Nachricht **Setup completed in Terminal** angezeigt werden. Weitere Informationen zu CocoaPods und seiner Verwendung finden Sie unter [CocoaPods](https://cocoapods.org/).


**Abrufen der Office 365 SDK für iOS-Abhängigkeiten in Ihr Projekt**
Die App „Email Peek“ enthält bereits eine POD-Datei, die die Office 365- und ADAL-Komponenten (pods) in das Projekt überträgt. Sie befindet sich im Beispiel-Stamm („Podfile“). Das folgende Beispiel zeigt den Inhalt der Datei.

target ‘O365-iOS-EmailPeek’ do
pod 'ADALiOS',   '~> 1.2.1'
pod 'Office365/Outlook', '= 0.9.1'
pod 'Office365/Discovery', '= 0.9.1'
end


Sie müssen einfach im **Terminal** (Stamm des Projektordners) zum Projektverzeichnis navigieren und den folgenden Befehl ausführen.


pod install

Hinweis: Sie sollten eine Bestätigung erhalten, dass diese Abhängigkeiten zu dem Projekt hinzugefügt wurden und Sie von nun an anstelle des Projekts den Arbeitsbereich in Xcode öffnen müssen (**O365-iOS-EmailPeek.xcworkspace**).  Enthält die Podfile einen Syntaxfehler, tritt beim Ausführen des Installationsbefehls ein Fehler auf.

## Registrieren der App bei Microsoft Azure
1.	Melden Sie sich mithilfe Ihrer Azure AD-Anmeldeinformationen beim [Azure-Verwaltungsportal](https://manage.windowsazure.com) an.
2.	Wählen Sie im linken Menü **Active Directory** aus, und wählen Sie dann das Verzeichnis für Ihre Office 365-Entwicklerwebsite aus.
3.	Wählen Sie im oberen Menü **Anwendungen** aus.
4.	Wählen Sie im unteren Menü **Hinzufügen** aus.
5.	Wählen Sie auf der Seite für die **Auswahl der Aktion** die Option **Eine von meinem Unternehmen entwickelte Anwendung hinzufügen** aus.
6.	Geben Sie auf der Seite **Erzählen Sie uns von Ihrer Anwendung** den Anwendungsnamen **O365-iOS-EmailPeek** an und wählen Sie **NATIVE CLIENT APPLICATION** als Anwendungstyp aus.
7.	Wählen Sie unten rechts auf der Seite das Pfeilsymbol aus.
8.	Geben Sie auf der Seite mit den Anwendungsinformationen einen Umleitungs-URI an, z. B. http://localhost/emailpeek, und wählen Sie dann das Kontrollkästchen auf der rechten unteren Ecke der Seite aus. Notieren Sie sich diesen Wert für den Abschnitt **Abrufen der Client-ID und des Umleitungs-URI in das Projekt**.
9.	Nachdem die Anwendung erfolgreich hinzugefügt wurde, gelangen Sie zur Seite „Schnellstart“ für die Anwendung. Klicken Sie dort im oberen Menü auf „Konfigurieren“ 
10.	Fügen Sie unter **Berechtigungen für andere Anwendungen** die folgende Berechtigung hinzu: **Hinzufügen der Office 365 Exchange Online-Anwendung**, und wählen Sie die Berechtigungen **Benutzer-E-Mails lesen und schreiben** und **E-Mail als Benutzer senden** aus.
13.	Kopieren Sie den auf der Seite **Konfigurieren** als **Client-ID** angegebenen Wert. Notieren Sie sich diesen Wert für den Abschnitt **Abrufen der Client-ID und des Umleitungs-URI in das Projekt**.
14.	Klicken Sie im Menü unten auf **Speichern**.


## Abrufen der Client-ID und des Umleitungs-URI in das Projekt

Schließlich müssen Sie die im Abschnitt **Anmelden der App bei Microsoft Azure** notierte Client-ID und den Umleitungs-URI hinzufügen.

Durchsuchen Sie das Projektverzeichnis **O365-iOS-EmailPeek** und öffnen Sie den Arbeitsbereich (O365-EmailPeek-iOS.xcworkspace). In der Datei **AppDelegate.m** sehen Sie, dass die Werte **ClientID** und **RedirectUri** am Anfang der Datei hinzugefügt werden können. Geben Sie die erforderlichen Werte an.

// You will set your application's clientId and redirect URI. You get
// these when you register your application in Azure AD.
static NSString * const kClientId           = @"ENTER_REDIRECT_URI_HERE";
static NSString * const kRedirectURLString  = @"ENTER_CLIENT_ID_HERE";
static NSString * const kAuthorityURLString = @"https://login.microsoftonline.com/common";



## Wichtige Code-Dateien


**Modelle**

Diese Domänenentitäten sind benutzerdefinierte Klassen, die die Daten der Anwendung darstellen. Alle diese Klassen sind unveränderlich.  Sie umschließen die durch das Office 365-SDK bereitgestellten grundlegenden Entitäten.

**Office365-Hilfsprogramme**

Die Hilfsprogramme sind die Klassen, die mit Office 365 durch API-Aufrufe kommunizieren. Durch diese Architektur wird der Rest der App vom Office365-SDK entkoppelt.

**Serverseitige Office365-Filter**

Diese Klassen sorgen mithilfe der richtigen serverseitigen Office 365-Filterklauseln dafür, dass während des Abrufens der richtige API-Aufruf ausgeführt wird.

**ConversationManager und SettingsManager**

Diese Klassen unterstützen die Verwaltung von Unterhaltungen und Einstellungen in der App.

**Controller**

Dies sind die Controller für die verschiedenen, von Email Peek unterstützten Ansichten.

**Ansichten**

Dadurch wird eine benutzerdefinierte Zelle implementiert, die an zwei verschiedenen Stellen verwendet wird – im ConversationListViewController und im ConversationViewController.


## Fragen und Kommentare

Wir freuen uns auf Ihr Feedback zu diesem Beispiel mit der App „Email Peek“. Sie können uns Ihr Feedback im Abschnitt [Probleme](https://github.com/OfficeDev/O365-EmailPeek-iOS) dieses Repositorys senden. <br>
<br>
Allgemeine Fragen zur Office 365-Entwicklung können Sie auf [Stack Overflow](http://stackoverflow.com/questions/tagged/Office365+API) stellen. Markieren Sie Ihre Fragen mit [Office365] und [API].

## Fehlerbehebung
Mit dem Xcode 7.0-Update ist App Transport Security für Simulatoren und Geräte mit iOS 9 aktiviert. Informationen hierzu finden Sie unter [App Transport Security Technote](https://developer.apple.com/library/prerelease/ios/technotes/App-Transport-Security-Technote/).

Für dieses Beispiel wurde eine vorübergehende Ausnahme für die folgende Domäne in der PLIST erstellt:

- outlook.office365.com

Wenn diese Ausnahmen nicht enthalten sind, treten bei allen Aufrufen der Office 365-API in dieser App Fehler auf, wenn sie für einen iOS 9-Simulator in Xcode bereitgestellt wird.


## Zusätzliche Ressourcen

* [Office 365 Connect-App für iOS](https://github.com/OfficeDev/O365-iOS-Connect)
* [Office 365-Codeausschnitte für iOS](https://github.com/OfficeDev/O365-iOS-Snippets)
* [Office 365-Profilbeispiel für iOS](https://github.com/OfficeDev/O365-iOS-Profile)
* [Office 365 APIs documentation](http://msdn.microsoft.com/office/office365/howto/platform-development-overview) (Dokumentation zu Office 365-APIs, in englischer Sprache)
* [Codebeispiele und Videos zu Office 365-APIs](https://msdn.microsoft.com/office/office365/howto/starter-projects-and-code-samples)
* [Office Dev Center](http://dev.office.com/)
* [Artikel zu Email Peek auf Medium](https://medium.com/office-app-development/why-read-email-when-you-can-peek-2af947d352dc) 

## Copyright

Copyright (c) 2015 Microsoft. Alle Rechte vorbehalten.
