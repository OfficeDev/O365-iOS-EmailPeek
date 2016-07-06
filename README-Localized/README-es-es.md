#Email Peek: una aplicación de iOS creada mediante Office 365 #
[![Estado de la compilación](https://travis-ci.org/OfficeDev/O365-iOS-EmailPeek.svg)](https://travis-ci.org/OfficeDev/O365-iOS-EmailPeek)

Email Peek es una fantástica aplicación de correo electrónico creada con las API de Office 365 en la plataforma de iOS. Esta aplicación le permite echar un vistazo solo a las conversaciones de correo electrónico que realmente le interesan cuando está ausente, como cuando está de vacaciones. Email Peek también facilita el envío de respuestas rápidas a los mensajes sin escribir. Esta aplicación usa muchas de las características de la API de correo de Office 365 como lectura y escritura, el filtrado del lado del servidor y las categorías.

[![Office 365 iOS Email Peek](../readme-images/emailpeek_video.png)](https://youtu.be/WqEqxKD6Bfw "Haga clic para ver el ejemplo en funcionamiento")

**Tabla de contenido**

* [Configurar su entorno](#set-up-your-environment)
* [Usar CocoaPods para importar el SDK de O365 para iOS](#use-cocoapods-to-import-the-o365-ios-sdk)
* [Registrar su aplicación con Microsoft Azure](#register-your-app-with-microsoft-azure)
* [Obtener el identificador de cliente y el identificador URI de redireccionamiento en el proyecto](#get-the-client-id-and-redirect-uri-into-the-project)
* [Archivos de código importantes](#code-of-interest)
* [Preguntas y comentarios](#questions-and-comments)
* [Solución de problemas](#troubleshooting)
* [Recursos adicionales](#additional-resources)



## Configurar el entorno ##

Para ejecutar Email Peek, necesita lo siguiente:


* [Xcode](https://developer.apple.com/) de Apple.
* Una cuenta de Office 365. Puede obtener una cuenta de Office 365 registrándose en un [Sitio para desarrolladores de Office 365](http://msdn.microsoft.com/library/office/fp179924.aspx). Esto le permitirá tener acceso a las API que puede usar para crear aplicaciones destinadas a los datos de Office 365.
* Un inquilino de Microsoft Azure para registrar la aplicación. Azure Active Directory proporciona servicios de identidad que las aplicaciones usan para autenticación y autorización. Puede adquirir una suscripción de prueba aquí: [Microsoft Azure](https://account.windowsazure.com/SignUp).

**Importante**: También necesitará asegurarse de que su suscripción a Azure esté enlazada a su inquilino de Office 365. Para hacer esto, consulte la sección **Agregar un directorio nuevo** en la publicación del blog del equipo de Active Directory, [Crear y administrar varios directorios de Windows Azure Active Directory](http://blogs.technet.com/b/ad/archive/2013/11/08/creating-and-managing-multiple-windows-azure-active-directories.aspx). También puede leer [Configurar el acceso a Azure Active Directory para su Sitio para desarrolladores](http://msdn.microsoft.com/office/office365/howto/setup-development-environment#bk_CreateAzureSubscription) para obtener más información.


* Instalación de [CocoaPods](https://cocoapods.org/) como un administrador de dependencias. CocoaPods le permitirá insertar las dependencias de la biblioteca de autenticación de Azure Active Directory (ADAL) y Office 365 en el proyecto.

Una vez que tenga una cuenta de Office 365 y una cuenta de Azure AD que esté enlazada a su Sitio para desarrolladores de Office 365, necesitará realizar los siguientes pasos:

1. Registre la aplicación con Azure y configure los permisos apropiados de Exchange Online de Office 365.
2. Instale y use CocoaPods para obtener las dependencias de autenticación de ADAL y Office 365 en el proyecto.
3. Escriba los detalles de registro de la aplicación de Azure (ClientID y RedirectUri) en la aplicación de Email Peek.

## Use CocoaPods para importar el SDK de Office 365 para iOS
Nota: Si nunca ha usado **CocoaPods** como administrador de dependencias, tendrá que instalarlo para poder obtener las dependencias del SDK de Office 365 para iOS en su proyecto.

Escriba las siguientes dos líneas de código desde la aplicación **Terminal** en su equipo Mac.

sudo gem install cocoapods
pod setup

Si la instalación y la configuración se realizan correctamente, debería ver el mensaje **Configuración completada en Terminal**. Para obtener más información sobre CocoaPods y su uso, consulte [CocoaPods](https://cocoapods.org/).


**Obtener las dependencias del SDK de Office 365 para iOS en su proyecto**
La aplicación Email Peek ya contiene un podfile que recibirá los componentes de Office 365 y ADAL (pods) en el proyecto. Se encuentra en la raíz de ejemplo ("Podfile"). El ejemplo muestra el contenido del archivo.

target ‘O365-iOS-EmailPeek’ do
pod 'ADALiOS',   '~> 1.2.1'
pod 'Office365/Outlook', '= 0.9.1'
pod 'Office365/Discovery', '= 0.9.1'
fin


Simplemente necesitará dirigirse al directorio del proyecto en el **Terminal** (raíz de la carpeta del proyecto) y ejecutar el siguiente comando.


pod install

Nota: Debería recibir la confirmación de que estas dependencias se han agregado al proyecto y que, a partir de ahora, debe abrir el espacio de trabajo en lugar del proyecto en Xcode (**O365-iOS-EmailPeek.xcworkspace**).  Si hay un error de sintaxis en el Podfile, aparecerá un error al ejecutar el comando de instalación.

## Registrar la aplicación con Microsoft Azure
1.	Inicie sesión en el [Portal de administración de Azure](https://manage.windowsazure.com), con sus credenciales de Azure AD.
2.	Seleccione **Active Directory** en el menú de la izquierda y, a continuación, seleccione el directorio del Sitio para desarrolladores de Office 365.
3.	En el menú superior, seleccione **Aplicaciones**.
4.	Seleccione **Agregar** en el menú inferior.
5.	En la **página Qué desea hacer**, seleccione **Agregar una aplicación que mi organización está desarrollando**.
6.	En la página **Háblenos acerca de su aplicación**, especifique **O365-iOS-EmailPeek** para el nombre de la aplicación y seleccione **APLICACIÓN DE CLIENTE NATIVO** para el tipo.
7.	Seleccione el icono de flecha en la esquina inferior derecha de la página.
8.	En la página de información de la aplicación, especifique un identificador URI de redireccionamiento, para este ejemplo puede especificar http://localhost/emailpeek, y, a continuación, seleccionar la casilla de la esquina inferior derecha de la página. Recuerde este valor para la sección **Obtener el valor de ClientID y RedirectUri en el proyecto**.
9.	Una vez que la aplicación se ha agregado correctamente, se le dirigirá a la página Inicio rápido de la aplicación. Seleccione Configurar en el menú superior.
10.	En **permisos a otras aplicaciones**, agregue el siguiente permiso: **Agregar la aplicación Exchange Online de Office 365**, y seleccione los permisos **Leer y escribir correo de usuario** y **Enviar correo como un usuario**.
13.	Copie el valor especificado para **Identificador de cliente** en la página **Configurar**. Recuerde este valor para la sección **Obtener el valor de ClientID y RedirectUri en el proyecto**.
14.	Seleccione **Guardar** en el menú inferior.


## Obtener el identificador de cliente y el identificador URI de redireccionamiento en el proyecto

Por último, necesitará agregar el identificador de cliente y el identificador URI de redireccionamiento que registró en la sección anterior **Registrar su aplicación con Microsoft Azure**.

Examine el directorio del proyecto **O365-iOS-EmailPeek** y abra el espacio de trabajo (O365-EmailPeek-iOS.xcworkspace). En el archivo **AppDelegate.m**, verá que los valores de **ClientID** y **RedirectUri** pueden agregarse en la parte superior del archivo. Proporcione los valores necesarios en este archivo.

// Establecerá el identificador de cliente y el identificador URI de redireccionamiento de la aplicación. Obtiene
// estos valores al registrar su aplicación en Azure AD.
static NSString * const kClientId           = @"ENTER_REDIRECT_URI_HERE";
static NSString * const kRedirectURLString  = @"ENTER_CLIENT_ID_HERE";
static NSString * const kAuthorityURLString = @"https://login.microsoftonline.com/common";



## Archivos de código importantes


**Modelos**

Estas entidades de dominio son clases personalizadas que representan los datos de la aplicación. Todas estas clases son inmutables.  Contienen las entidades básicas proporcionadas por el SDK de Office 365.

**Ayudantes de Office365**

Los ayudantes son las clases que realmente se comunican con Office 365 mediante llamadas a la API. Esta arquitectura desacopla el resto de la aplicación desde el SDK de Office365.

**Filtros del lado del servidor de Office365**

Estas clases ayudan a realizar la llamada apropiada a la API con las cláusulas del filtro correcto del lado del servidor de Office 365 durante la recuperación de cambios.

**ConversationManager y SettingsManager**

Estas clases ayudan a administrar las conversaciones y la configuración de la aplicación.

**Controladores**

Estos son los controladores de las distintas vistas compatibles con Email Peek.

**Vistas**

Implementa una celda personalizada que se usa en dos lugares diferentes, en ConversationListViewController y ConversationViewController.


## Preguntas y comentarios

Nos encantaría recibir sus comentarios sobre el ejemplo de la aplicación Email Peek. Puede enviarnos sus comentarios en la sección [Problemas](https://github.com/OfficeDev/O365-EmailPeek-iOS) de este repositorio. <br>
<br>
Las preguntas generales acerca del desarrollo en Office 365 deberían publicarse en [Stack Overflow](http://stackoverflow.com/questions/tagged/Office365+API). Etiquete sus preguntas con [Office365] y [API].

## Solución de problemas
Con la actualización de Xcode 7.0, la característica Seguridad de transporte de la aplicación está habilitada para los simuladores y dispositivos que ejecutan iOS 9. Consulte [Nota técnica de seguridad de transporte de la aplicación](https://developer.apple.com/library/prerelease/ios/technotes/App-Transport-Security-Technote/).

Para este ejemplo hemos creado una excepción temporal para el siguiente dominio en el plist:

- outlook.office365.com

Si estas excepciones no se incluyen, todas las llamadas a la API de Office 365 producirán un error en esta aplicación cuando se implementen en un simulador de iOS 9 en Xcode.


## Recursos adicionales

* [Aplicación Connect de Office 365 para iOS](https://github.com/OfficeDev/O365-iOS-Connect)
* [Fragmentos de código de Office 365 para iOS](https://github.com/OfficeDev/O365-iOS-Snippets)
* [Ejemplo de perfil de Office 365 para iOS](https://github.com/OfficeDev/O365-iOS-Profile)
* [Documentación de las API de Office 365](http://msdn.microsoft.com/office/office365/howto/platform-development-overview)
* [Ejemplos de código y vídeos de la API de Office 365](https://msdn.microsoft.com/office/office365/howto/starter-projects-and-code-samples)
* [Centro de desarrollo de Office](http://dev.office.com/)
* [Artículo de Medium sobre Email Peek](https://medium.com/office-app-development/why-read-email-when-you-can-peek-2af947d352dc)

## Copyright

Copyright (c) 2015 Microsoft. Todos los derechos reservados.

