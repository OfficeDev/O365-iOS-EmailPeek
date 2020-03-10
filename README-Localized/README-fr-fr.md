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
#Email Peek - Une application iOS créée à l’aide d’Office 365 #
[![État de la Build](https://travis-ci.org/OfficeDev/O365-iOS-EmailPeek.svg)](https://travis-ci.org/OfficeDev/O365-iOS-EmailPeek)

Email Peek est une application de messagerie originale créée à l’aide des API Office 365 sur la plateforme iOS. Cette application vous permet de voir uniquement les conversations électroniques qui vous intéressent vraiment lorsque vous êtes absent(e), par exemple lorsque vous partez en vacances. Email Peek facilite également l’envoi de réponses rapides à des messages sans avoir à saisir de texte. Cette application utilise la plupart des fonctionnalités de l’API de messagerie Office 365, telles que les fonctionnalités de lecture/écriture, de filtrage côté serveur et de catégories.

[![Email Peek Office 365 pour iOS](/readme-images/emailpeek_video.png)![Cliquez ici pour voir l’exemple en action](/readme-images/emailpeek_video.png)

**Table des matières**

* [Configuration de votre environnement](#set-up-your-environment)
* [Utiliser CocoaPods pour importer le kit de développement de Office 365 iOS](#use-cocoapods-to-import-the-o365-ios-sdk)
* [Inscription de votre application auprès de Microsoft Azure](#register-your-app-with-microsoft-azure)
* [Obtenir l’ID client et rediriger URI dans le projet](#get-the-client-id-and-redirect-uri-into-the-project)
* [Fichiers de code importants](#code-of-interest)
* [Questions et commentaires](#questions-and-comments)
* [Résolution des problèmes](#troubleshooting)
* [Ressources supplémentaires](#additional-resources)



## Configuration de votre environnement ##

Pour exécuter Email Peek, vous devez disposer des éléments suivants :


* [Xcode](https://developer.apple.com/) d’Apple.
* Un compte Office 365. Vous pouvez obtenir un compte Office 365 en vous inscrivant à un [site de développeurs Office 365](http://msdn.microsoft.com/library/office/fp179924.aspx). Cela vous permettra d’accéder aux API que vous pouvez utiliser pour créer des applications destinées aux données Office 365.
* Un client Microsoft Azure pour enregistrer votre application. Azure Active Directory fournit des services d’identité que les applications utilisent à des fins d’authentification et d’autorisation. Un abonnement d’évaluation peut être demandé ici : [Microsoft Azure](https://account.windowsazure.com/SignUp).

**Important** : Vous devrez également vous assurer que votre abonnement Azure est lié à votre client Office 365. Pour cela, consultez la section sur l’**Ajout d’un nouveau répertoire** dans le billet du blog de l’équipe d’Active Directory relatif à la [Création et la gestion de plusieurs fenêtres dans les répertoires Azure Active Directory](http://blogs.technet.com/b/ad/archive/2013/11/08/creating-and-managing-multiple-windows-azure-active-directories.aspx). Vous pouvez également lire l’article relatif à la [configuration de l’accès Azure Active Directory pour votre site de développeur](http://msdn.microsoft.com/office/office365/howto/setup-development-environment#bk_CreateAzureSubscription) pour plus d’informations.


* Installation de [CocoaPods](https://cocoapods.org/) comme gestionnaire de dépendances. CocoaPods vous permet de transférer les dépendances Office 365 et ADAL (Bibliothèque d’authentification Azure Active Directory) dans le projet.

Une fois que vous avez un compte Office 365 et un compte Azure AD lié à votre site de développeur Office 365, procédez comme suit :

1. Inscrivez votre application auprès d’Azure et configurez les autorisations Office 365 Exchange Online appropriées.
2. Installez et utilisez CocoaPods pour transférer les dépendances d’authentification ADAL et Office 365 dans votre projet.
3. Saisissez les détails propres à l’inscription d’application Azure (ID client et URI de redirection) dans l’application Email Peek.

## Utiliser CocoaPods pour importer le kit de développement de Office 365 iOS
Remarque : Si vous n’avez jamais utilisé **CocoaPods**en tant que gestionnaire des dépendances, vous devez l’installer avant de transférer les dépendances de kit de développement logiciel Office 365 iOS dans votre projet.

Saisissez les deux lignes de code de l’application **Terminal**sur votre Mac.

sudo gem install cocoapods
pod setup

Lorsque l’installation et la configuration sont terminées, vous devez voir le message **Configuration terminée dans Terminal**. Pour plus d’informations sur CocoaPods et son utilisation, voir [CocoaPods](https://cocoapods.org/).


**Obtenir le kit de développement logiciel (SDK) Office 365 pour iOS dans votre projet** L’application Email Peek contient déjà un podfile qui recevra les composants Office 365 et ADAL (pods) dans votre projet.
Il se trouve à la racine de l’échantillon (« Podfile »). L’exemple illustre le contenu du fichier.

target ‘O365-iOS-EmailPeek’ do
pod 'ADALiOS', '~> 1.2.1'
pod 'Office365/Outlook', '= 0.9.1'
pod 'Office365/Discovery', '= 0.9.1'
end


Vous devez simplement accéder au répertoire du projet dans **Terminal** (racine du dossier du projet) et exécuter la commande suivante.


pod install

Remarque : Vous recevrez une confirmation de l’ajout de ces dépendances au projet vous indiquant qu’à partir de ce moment-là vous devez ouvrir l’espace de travail au lieu du projet dans Xcode (**O365-iOS-EmailPeek.xcworkspace**). S’il existe une erreur de syntaxe dans le podfile, vous rencontrerez une erreur lors de l’exécution de la commande d’installation.

## Inscription de votre application auprès de Microsoft Azure
1.	Connectez-vous au [Portail de gestion Azure](https://manage.windowsazure.com) à l’aide de vos informations d’identification Azure AD.
2.	Sélectionnez **Active Directory** dans le menu de gauche, puis sélectionnez le répertoire sur votre site de développeur Office 365.
3.	Dans le menu supérieur, sélectionnez **Applications**.
4.	Sélectionnez **Ajouter** dans le menu inférieur.
5.	Sur la page **Que souhaitez-vous faire ?**, sélectionnez **Ajouter une application développée par mon entreprise**.
6.	Dans la page **Parlez-nous de votre application**, indiquez **O365-iOS-EmailPeek** pour le nom de l’application et sélectionnez **APPLICATION CLIENT NATIVE** pour le type.
7.	Cliquez sur l’icône de flèche en bas à droite de la page.
8.	Sur la page d’informations relatives à l’application, indiquez un URI de redirection. Pour cet exemple, vous pouvez spécifier http://localhost/emailpeek et activer la case à cocher dans le coin inférieur droit de la page. Souvenez-vous de cette valeur pour la section **Obtenir l’ID client et l’URI de redirection dans le projet**.
9.	Une fois l’application ajoutée, vous serez redirigé vers la page Démarrage rapide de l’application. Sélectionnez Configurer dans le menu supérieur.
10.	Sous **autorisations aux autres applications**, ajoutez l’autorisation suivante : **Ajouter l'application Exchange Online Office 365**, puis sélectionnez les autorisations**Lire et écrire les courriers d’utilisateur**, puis **Envoyer des messages en tant qu’utilisateur**.
13.	Copiez la valeur **ClientID** sur la page **Configurer**. Souvenez-vous de cette valeur pour la section **Transfert de l’ID client et de l’URI de redirection dans le projet**.
14.	Sélectionnez **Enregistrer** dans le menu inférieur.


## Obtenir l’ID client et rediriger URI dans le projet

Enfin, vous devez ajouter l’ID client et l’URI de redirection enregistrés dans la section précédente **Inscription de votre application auprès de Microsoft Azure**.

Parcourez le répertoire du projet **O365-iOS-EmailPeek** et ouvrez l’espace de travail (Office 365-EmailPeek-iOS.xcworkspace). Dans le fichier**AppDelegate.m**, vous constatez que les valeurs **ClientID** et **RedirectUri** peuvent être ajoutées en haut du fichier. Indiquez les valeurs nécessaires dans ce fichier.

// Vous définissez l’ID client et l’URI de redirection de votre application. Vous les recevez
//lorsque vous enregistrez votre application dans Azure AD.
static NSString * const kClientId = @"ENTER\_REDIRECT\_URI\_HERE";
static NSString * const kRedirectURLString = @"ENTER\_CLIENT\_ID\_HERE";
static NSString * const kAuthorityURLString = @"https://login.microsoftonline.com/common";



## Fichiers de code importants


**Modèles**

Ces entités de domaine sont des classes personnalisées qui représentent les données de l’application. Toutes ces classes sont immuables. Elles renvoient les entités de base fournies par le kit de développement logiciel Office 365.

**Assistants Office 365**

Les applications auxiliaires sont les classes qui communiquent réellement avec Office 365 en émettant des appels d’API. Cette architecture sépare le reste de l’application du kit de développement logiciel Office 365.

**Filtres côté serveur Office 365**

Ces classes permettent de réaliser l’appel d’API approprié avec les clauses de filtre côté serveur Office 365 correctes lors de l’extraction.

**ConversationManager et SettingsManager**

Ces classes permettent de gérer les conversations et les paramètres dans l’application.

**Contrôleurs**

Il s’agit des contrôleurs des différents affichages pris en charge par Email Peek.

**Affichages**

Cela implémente une cellule personnalisée qui est utilisée à deux endroits différents, dans ConversationListViewController et dans ConversationViewController.


## Questions et commentaires

Nous aimerions connaître vos commentaires sur l’exemple de l’application Email Peek. Vous pouvez nous envoyer vos commentaires via la section [Problèmes](https://github.com/OfficeDev/O365-EmailPeek-iOS) de ce référentiel. <br>
<br>
Si vous avez des questions sur le développement d’Office 365, envoyez-les sur [Stack Overflow](http://stackoverflow.com/questions/tagged/Office365+API). Merci de poser vos questions en incluant les tags \[API] et \[Office365].

## Résolution des problèmes
Avec la mise à jour de Xcode 7.0, la sécurité de transport d’application est activée pour les simulateurs et les appareils exécutant iOS 9. Consultez la [note technique relative à la sécurité de transport d’application](https://developer.apple.com/library/prerelease/ios/technotes/App-Transport-Security-Technote/).

Pour cet exemple, nous avons créé une exception temporaire pour le domaine suivant dans l’élément plist :

- outlook.office365.com

Si ces exceptions ne sont pas prises en compte, tous les appels de l’API Office 365 échoueront dans cette application lors du déploiement sur un simulateur iOS 9 dans Xcode.


## Ressources supplémentaires

* [Application Connect Office 365 pour iOS](https://github.com/OfficeDev/O365-iOS-Connect)
* [Extraits de code Office 365 pour iOS](https://github.com/OfficeDev/O365-iOS-Snippets)
* [Exemple de profil Office 365 pour iOS](https://github.com/OfficeDev/O365-iOS-Profile)
* [Documentation sur les API Office 365](http://msdn.microsoft.com/office/office365/howto/platform-development-overview)
* [Vidéos et exemples de code d’API Office 365](https://msdn.microsoft.com/office/office365/howto/starter-projects-and-code-samples)
* [Centre des développeurs Office](http://dev.office.com/)
* [Article sur Email Peek](https://medium.com/office-app-development/why-read-email-when-you-can-peek-2af947d352dc)

## Copyright

Copyright (c) 2015 Microsoft. Tous droits réservés.


Ce projet a adopté le [code de conduite Open Source de Microsoft](https://opensource.microsoft.com/codeofconduct/). Pour en savoir plus, reportez-vous à la [FAQ relative au code de conduite](https://opensource.microsoft.com/codeofconduct/faq/) ou contactez [opencode@microsoft.com](mailto:opencode@microsoft.com) pour toute question ou tout commentaire.
