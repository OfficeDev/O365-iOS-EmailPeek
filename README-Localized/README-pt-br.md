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
#Email Peek – um aplicativo do iOS criado usando o Office 365 #
[![Construir status](https://travis-ci.org/OfficeDev/O365-iOS-EmailPeek.svg)](https://travis-ci.org/OfficeDev/O365-iOS-EmailPeek)

O Email Peek é um aplicativo de e-mail interessante, criado através das APIs do Office 365 na plataforma iOS. Esse aplicativo permite ver apenas as conversas de email realmente importantes quando você está ausente, como quando estiver de férias. O Email Peek também facilita o envio de respostas rápidas às mensagens sem a necessidade de digitar. Esse aplicativo utiliza muitos dos recursos da API do Office 365 Mail, como leitura/gravação, filtragem do lado do servidor e categorias.

[![Office 365 iOS Email eek](/readme-images/emailpeek_video.png)![Clique no exemplo para vê-lo em ação](/readme-images/emailpeek_video.png)

**Sumário**

* [Configurar seu ambiente](#set-up-your-environment)
* [Usar o CocoaPods para importar SDK do O365 iOS](#use-cocoapods-to-import-the-o365-ios-sdk)
* [Registrar seu aplicativo com o Microsoft Azure](#register-your-app-with-microsoft-azure)
* [Obter a ID do Cliente e a URI de redirecionamento no projeto](#get-the-client-id-and-redirect-uri-into-the-project)
* [Arquivos de código importantes](#code-of-interest)
* [Perguntas e comentários](#questions-and-comments)
* [Solução de problemas](#troubleshooting)
* [Recursos adicionais](#additional-resources)



## Configurar seu ambiente ##

Para executar o Email Peek, você precisará do seguinte:


* [Xcode](https://developer.apple.com/) da Apple.
* Uma conta do Office 365. Você pode obter uma conta do Office 365 inscrevendo-se em um [site do Desenvolvedor do Office 365](http://msdn.microsoft.com/library/office/fp179924.aspx). Isso dará acesso às APIs que você pode usar para criar aplicativos que visam dados do Office 365.
* Um locatário do Microsoft Azure para registrar o seu aplicativo. O Azure Active Directory fornece serviços de identidade que os aplicativos usam para autenticação e autorização. Você pode adquirir uma assinatura de avaliação aqui: [Microsoft Azure](https://account.windowsazure.com/SignUp).

**Importante**: Você também deve garantir que a assinatura do Azure esteja vinculada ao seu locatário do Office 365. Para isso, consulte a seção **Adicionar um novo diretório**, na postagem de blog da equipe do Active Directory [Criar e gerenciar vários Azure Active Directories](http://blogs.technet.com/b/ad/archive/2013/11/08/creating-and-managing-multiple-windows-azure-active-directories.aspx). Para obter mais informações, leia [Configurar o acesso ao Azure Active Directory do seu site do Desenvolvedor](http://msdn.microsoft.com/office/office365/howto/setup-development-environment#bk_CreateAzureSubscription).


* Instalar o [CocoaPods](https://cocoapods.org/) como um gerenciador de dependências. O CocoaPods permitirá que você receba as dependências do Office 365 e da Biblioteca de Autenticação do Active Directory do Azure (ADAL) para o projeto.

Depois que você tiver uma conta do Office 365 e uma conta do Azure AD associada ao seu site do Desenvolvedor do Office 365, será preciso executar as seguintes etapas:

1. Registrar seu aplicativo no Azure e configurar as permissões apropriadas do Office 365 Exchange Online.
2. Instalar e usar o CocoaPods para obter dependências de autenticação do Office 365 e da ADAL no seu projeto.
3. Inserir as especificações de registro do aplicativo do Azure (ClientID e RedirectUri) no aplicativo Email Peet.

## Usar o CocoaPods para importar SDK do O365 iOS
Observação: Se você nunca tiver usado o **CocoaPods** como gerente de dependência anteriormente, terá que instalá-lo antes de obter dependências do Office 365 iOS SDK no seu projeto.

Insira as próximas duas linhas de código a partir do aplicativo do **Terminal** no seu Mac.

sudo gem instalar cocoapods
pod configuração

Se a instalação e a configuração forem bem-sucedidas, você deverá visualizar a mensagem **Configuração concluída no Terminal**. Para obter mais informações do CocoaPods e seu uso, consulte [CocoaPods](https://cocoapods.org/).


**Obtenha as dependências do Office 365 SDK para iOS no seu projeto** O aplicativo Email Peek já contém um podfile que incluirá os componentes do Office 365 e ADAL (pods) no seu projeto.
Ele está localizado na fonte do exemplo ("Podfile"). O exemplo exibe o conteúdo do arquivo.

target ‘O365-iOS-EmailPeek’ do
pod 'ADALiOS', '~> 1.2.1'
pod 'Office365/Outlook', '= 0.9.1'
pod 'Office365/Discovery', '= 0.9.1'
end


Você só precisará navegar até o diretório do projeto no **Terminal** (fonte da pasta do projeto) e executar o comando a seguir.


instalação do nó

Observação: Você receberá a confirmação de que essas dependências foram adicionadas ao projeto e que, de agora em diante, deverá abrir o espaço de trabalho em vez do projeto no Xcode (**O365-iOS-EmailPeek.xcworkspace**). Se houver um erro de sintaxe no Podfile, você encontrará um erro ao executar o comando de instalação.

## Registrar seu aplicativo com o Microsoft Azure
1.	Entre no [Portal de Gerenciamento do Azure](https://manage.windowsazure.com) utilizando suas credenciais do Azure AD.
2.	Clique em **Diretório ativo** no menu à esquerda e escolha o diretório do seu site do Desenvolvedor do Office 365.
3.	No menu superior, clique em **Aplicativos**.
4.	Clique em **Adicionar** no menu inferior.
5.	Na página **O que você deseja fazer?**, clique em **Adicionar um aplicativo que minha organização esteja desenvolvendo**.
6.	Na página **Conte-nos sobre seu aplicativo**, especifique O365-iOS-EmailPeek** como nome do aplicativo e escolha **APLICATIVO DO CLIENTE NATIVO** para o tipo.
7.	Escolha o ícone de seta no canto inferior direito da página.
8.	Na página de informações do Aplicativo, especifique uma URI de Redirecionamento. Para esse exemplo, você pode especificar http://localhost/emailpeek e, em seguida, marcar a caixa de seleção no canto inferior direito da página. Lembre-se desse valor para a seção **Obter ClientID e RedirectUri no projeto**.
9.	Após adicionar o aplicativo com êxito, você será direcionado para a página Início rápido do aplicativo. Clique em Configurar no menu superior.
10.	Em **permissões para outros aplicativos**, adicione a seguinte permissão: **Adicionar o aplicativo do Office Exchange Online 365** e selecionar **Ler e gravar e-mail do usuário** e **Enviar e-mail como permissões** de um usuário.
13.	Copiar o valor especificado da **ID do cliente** na página **Configurar**. Lembre-se desse valor para a seção **Obter ClientID e RedirectUri no projeto**.
14.	Clique em **Salvar no menu inferior.


## Obter a ID do Cliente e a URI de redirecionamento no projeto

Por fim, você precisará adicionar a ID de Cliente e a URI de Redirecionamento gravados na seção anterior **Registrar seu aplicativo no Microsoft Azure**.

Navegue pelo diretório do projeto **O365-iOS-EmailPeek** e abra o espaço de trabalho (O365-EmailPeek-iOS.xcworkspace). No arquivo **AppDelegate.m** você verá que os valores **ClientID** e **RedirectUri** pode ser adicionados na parte superior do arquivo. Forneça os valores necessários neste arquivo.

// Você definirá a ID do Cliente e a URI de Redirecionamento do aplicativo. Você obtém
//esses quando registra seu aplicativo no Azure AD.
static NSString * const kClientId = @"ENTER\_REDIRECT\_URI\_HERE";
static NSString * const kRedirectURLString = @"ENTER\_CLIENT\_ID\_HERE";
static NSString * const kAuthorityURLString = @"https://login.microsoftonline.com/common";



## Arquivos de código importantes


**Modelos**

Essas entidades de domínio são classes personalizadas que representam os dados do aplicativo. Todas essas classes são imutáveis. Elas encapsulam as entidades básicas fornecidas pelo SDK do Office 365.

**Auxiliares do Office 365**

Os auxiliares são as classes que realmente se comunicam com o Office 365 ao chamarem as APIs. Essa arquitetura desvincula o restante do aplicativo do SDK do Office 365.

**Filtros no Servidor do Office365**

Essas classes ajudam a chamarem a API apropriada com as cláusulas corretas do filtro do servidor do Office 365 durante a busca.

**Conversamanager e SettingsManager**

Essas classes ajudam a gerenciar as conversas e as configurações no aplicativo.

**Controladores**

Esses são os controladores dos diversos modos de visualizações compatíveis com o Email Peek.

**Visualizações**

Isso implementa uma célula personalizada que é usada em dois lugares diferentes, no ConversationListViewController e no ConversationViewController.


## Perguntas e comentários

Adoraríamos receber seus comentários sobre o exemplo do aplicativo Email Peek. Você pode enviar seus comentários na seção [Problemas](https://github.com/OfficeDev/O365-EmailPeek-iOS) deste repositório. <br>
<br>
Em geral, a postagem de perguntas sobre desenvolvimento do Office 365 deve ser feita na página [Stack Overflow](http://stackoverflow.com/questions/tagged/Office365+API). Não deixe de marcar as perguntas com \[Office365] e \[API].

## Solução de problemas
Com a atualização do Xcode 7.0, a Segurança de Transporte do Aplicativo está habilitada para simuladores e dispositivos que estão executando o iOS 9. Confira [App Transport Security Technote](https://developer.apple.com/library/prerelease/ios/technotes/App-Transport-Security-Technote/).

Para este exemplo, criamos uma exceção temporária para o seguinte domínio na plist:

- outlook.office365.com

Se essas exceções não estiverem incluídas, todas as chamadas na API do Office 365 falharão neste aplicativo se ele for implantado em um simulador de iOS 9 no Xcode.


## Recursos adicionais

* [Aplicativo de conexão do Office 365 para iOS](https://github.com/OfficeDev/O365-iOS-Connect)
* [Trechos de código do Office 365 para iOS](https://github.com/OfficeDev/O365-iOS-Snippets)
* [](https://github.com/OfficeDev/O365-iOS-Profile)Exemplo de perfil do Office 365 para iOS
* [Documentação de APIs do Office 365](http://msdn.microsoft.com/office/office365/howto/platform-development-overview)
* [Exemplos e vídeos de códigos das APIs do Office 365](https://msdn.microsoft.com/office/office365/howto/starter-projects-and-code-samples)
* [Centro de Desenvolvimento do Office](http://dev.office.com/)
* [Artigo médio no Email Peek](https://medium.com/office-app-development/why-read-email-when-you-can-peek-2af947d352dc)

## Direitos autorais

Copyright © 2015 Microsoft. Todos os direitos reservados.


Este projeto adotou o [Código de Conduta do Código Aberto da Microsoft](https://opensource.microsoft.com/codeofconduct/). Para saber mais, confira [Perguntas frequentes sobre o Código de Conduta](https://opensource.microsoft.com/codeofconduct/faq/) ou contate [opencode@microsoft.com](mailto:opencode@microsoft.com) se tiver outras dúvidas ou comentários.
