# Turismo Curitiba

## Visão Geral

O **Turismo Curitiba** é um aplicativo completo de turismo que oferece uma experiência integrada para descobrir os melhores pontos turísticos, eventos e atrações da cidade de Curitiba. O projeto consiste em:

- **Aplicativo Mobile (Flutter)**: Disponível para Android e iOS
- **Painel Administrativo Web (Node.js)**: Sistema de gerenciamento de conteúdo
- **Backend Firebase**: Firestore para dados e Storage para imagens
- **Suporte Multilíngue**: Português, Inglês e Espanhol

### Funcionalidades Principais

#### Para Usuários (Mobile):
- 🏠 **Tela Home**: Categorias organizadas (Rotas Turísticas, Perto de Você, O que Fazer, Onde Comer, Onde Dormir)
- 📍 **Pontos Turísticos**: Listagem com filtros, imagens, descrições multilíngues e avaliações
- 🗺️ **Integração com Mapas**: Google Maps para localização e navegação
- 📅 **Eventos/Notícias**: Seção com destaques e eventos em destaque
- 👤 **Perfil do Usuário**: Configurações de idioma, favoritos e histórico de visitas
- 🌐 **GPS**: Localização de pontos próximos ao usuário
- ⭐ **Sistema de Avaliação**: Avaliações de 1 a 5 estrelas
- 📱 **Compartilhamento**: Integração com redes sociais

#### Para Administradores (Web):
- 🔐 **Sistema de Login**: Autenticação segura com Firebase Auth
- 📊 **Dashboard**: Visão geral com estatísticas e métricas
- ✏️ **CRUD Completo**: Gerenciamento de pontos turísticos, eventos e restaurantes
- 📸 **Upload de Mídia**: Sistema de upload para Firebase Storage
- 🔍 **Moderação**: Sistema de moderação de avaliações dos usuários
- 🌍 **Gestão Multilíngue**: Interface para gerenciar conteúdo em 3 idiomas

## Pré-requisitos

### Para Desenvolvimento Mobile (Flutter):
- Flutter SDK 3.0 ou superior
- Dart SDK 2.17 ou superior
- Android Studio / VS Code
- Android SDK (para Android)
- Xcode (para iOS - apenas macOS)

### Para Desenvolvimento Web (Node.js):
- Node.js 16.0 ou superior
- npm ou yarn
- Navegador web moderno

### Firebase:
- Conta Google/Firebase
- Projeto Firebase configurado
- Firestore Database habilitado
- Firebase Storage habilitado
- Firebase Authentication habilitado

## Configuração do Projeto

### 1. Clone o Repositório
```bash
git clone <repository-url>
cd TurismoCuritiba
```

### 2. Configuração do Firebase

#### 2.1. Criar Projeto Firebase
1. Acesse [Firebase Console](https://console.firebase.google.com/)
2. Clique em "Criar projeto"
3. Siga as instruções para criar o projeto

#### 2.2. Configurar Firestore
1. No console Firebase, vá para "Firestore Database"
2. Clique em "Criar banco de dados"
3. Escolha o modo de produção
4. Selecione a localização (preferencialmente us-central1)

#### 2.3. Configurar Storage
1. Vá para "Storage" no console Firebase
2. Clique em "Começar"
3. Configure as regras de segurança

#### 2.4. Configurar Authentication
1. Vá para "Authentication" no console Firebase
2. Na aba "Sign-in method", habilite "Anônimo"

### 3. Configuração do Aplicativo Mobile

#### 3.1. Instalar Dependências
```bash
cd mobile
flutter pub get
```

#### 3.2. Configurar Firebase para Flutter

**Para Android:**
1. No console Firebase, adicione um app Android
2. Use o package name: `com.turismocuritiba.app`
3. Baixe o arquivo `google-services.json`
4. Coloque o arquivo em `mobile/android/app/`

**Para iOS:**
1. No console Firebase, adicione um app iOS
2. Use o bundle ID: `com.turismocuritiba.app`
3. Baixe o arquivo `GoogleService-Info.plist`
4. Adicione o arquivo ao projeto iOS via Xcode

#### 3.3. Executar o Aplicativo
```bash
# Para Android
flutter run

# Para iOS (apenas macOS)
flutter run -d ios
```

### 4. Configuração do Painel Administrativo

#### 4.1. Instalar Dependências
```bash
cd admin
npm install
```

#### 4.2. Configurar Variáveis de Ambiente
Crie um arquivo `.env` na pasta `admin`:
```env
NODE_ENV=development
PORT=3000
SESSION_SECRET=turismo_curitiba_admin_secret_key_2024
```

#### 4.3. Executar o Servidor
```bash
# Modo desenvolvimento
npm run dev

# Modo produção
npm start
```

#### 4.4. Acessar o Painel
Abra o navegador e acesse: `http://localhost:3000`

**Credenciais padrão:**
- Email: `admin@turismocuritiba.com`
- Senha: `admin123`

## Telas e Fluxos

### 1. Aplicativo Mobile

#### 1.1. Tela de Seleção de Idioma
- **Funcionalidade**: Primeira tela do app para escolher idioma preferido
- **Idiomas**: Português (Brasil), English (US), Español (ES)
- **Fluxo**: Usuário seleciona idioma → Login anônimo automático → Redirecionamento para Home

#### 1.2. Tela Home
- **Layout**: Grid de categorias com ícones e títulos
- **Categorias**:
  - 🛣️ Rotas Turísticas
  - 📍 Perto de Você (baseado em GPS)
  - 🎯 O que Fazer
  - 🍽️ Onde Comer
  - 🏨 Onde Dormir
  - 📅 Eventos
- **Funcionalidades**:
  - Barra de pesquisa no topo
  - Seção "Perto de Você" (requer permissão de localização)
  - Seção "Destaques" com pontos turísticos em destaque
  - Navegação para perfil do usuário

#### 1.3. Tela de Detalhes do Ponto Turístico
- **Componentes**:
  - Carrossel de imagens com indicadores
  - Título e endereço
  - Sistema de avaliação (estrelas + número de avaliações)
  - Descrição completa
  - Informações de contato (telefone, website, horários)
  - Mapa integrado com marcador
  - Botões de ação: "Como Chegar", "Marcar como Visitado"
  - Botão de favoritar e compartilhar
  - Seção de avaliações dos usuários
- **Funcionalidades**:
  - Visualização de imagens em tela cheia
  - Integração com Google Maps para navegação
  - Sistema de avaliação (1-5 estrelas + comentário)
  - Compartilhamento em redes sociais

#### 1.4. Tela de Perfil do Usuário
- **Seções**:
  - Header com foto e informações do usuário
  - Configurações de idioma
  - Lista de favoritos
  - Histórico de visitas
  - Configurações gerais
- **Funcionalidades**:
  - Edição de perfil (nome, foto)
  - Troca de idioma em tempo real
  - Visualização e gerenciamento de favoritos
  - Histórico de locais visitados

#### 1.5. Tela de Eventos
- **Layout**: Lista de cards com abas (Destaques, Próximos, Todos)
- **Informações por evento**:
  - Imagem de capa
  - Título e descrição
  - Data e horário
  - Local do evento
  - Status (Em andamento, Próximo, Finalizado)
  - Badge de destaque (se aplicável)
- **Funcionalidades**:
  - Filtros por categoria e status
  - Detalhes do evento em modal
  - Link para compra de ingressos (se disponível)

### 2. Painel Administrativo Web

#### 2.1. Tela de Login
- **Layout**: Formulário centralizado com branding
- **Campos**: Email e senha
- **Funcionalidades**:
  - Validação de credenciais
  - Mensagens de erro/sucesso
  - Credenciais de demonstração visíveis

#### 2.2. Dashboard Principal
- **Componentes**:
  - Cards de estatísticas (Pontos Turísticos, Eventos, Usuários, Avaliações)
  - Seção de ações rápidas
  - Feed de atividade recente
  - Informações do sistema
- **Métricas exibidas**:
  - Total de pontos turísticos ativos
  - Total de eventos
  - Número de usuários registrados
  - Quantidade de avaliações

#### 2.3. Gerenciamento de Pontos Turísticos
- **Lista de Pontos**:
  - Tabela com imagem, nome, categoria, endereço e status
  - Filtros por categoria e status
  - Busca por nome/descrição
  - Paginação
  - Ações: Editar, Excluir
- **Formulário de Adição/Edição**:
  - Campos multilíngues (PT, EN, ES)
  - Upload múltiplo de imagens
  - Coordenadas GPS (latitude/longitude)
  - Informações de contato
  - Horários de funcionamento
  - Categoria e status

#### 2.4. Gerenciamento de Eventos
- **Lista de Eventos**:
  - Tabela com imagem, título, datas, local e status
  - Filtros por categoria, status e período
  - Badge para eventos em destaque
- **Formulário de Evento**:
  - Campos multilíngues
  - Datas de início e fim
  - Localização (endereço + coordenadas)
  - Opção "Evento Destaque"
  - URL para compra de ingressos
  - Upload de imagens

#### 2.5. Moderação de Avaliações
- **Funcionalidades**:
  - Lista de avaliações pendentes
  - Visualização de avaliação + contexto do ponto turístico
  - Ações: Aprovar, Rejeitar, Editar
  - Filtros por status e pontuação

#### 2.6. Gerenciamento de Usuários
- **Informações exibidas**:
  - Lista de usuários registrados
  - Estatísticas de uso (favoritos, visitas)
  - Data de registro e último acesso
  - Status da conta

## Estrutura do Banco de Dados (Firestore)

### Coleções Principais:

#### `pontos_turisticos`
```javascript
{
  id: "auto-generated",
  name: {
    pt: "Nome em Português",
    en: "Name in English", 
    es: "Nombre en Español"
  },
  description: {
    pt: "Descrição em Português",
    en: "Description in English",
    es: "Descripción en Español"
  },
  address: {
    pt: "Endereço em Português",
    en: "Address in English",
    es: "Dirección en Español"
  },
  latitude: -25.4284,
  longitude: -49.2733,
  category: "museu|parque|restaurante|hotel|atividade",
  imageUrls: ["url1", "url2", "url3"],
  rating: 4.5,
  reviewCount: 23,
  phone: "+55 41 1234-5678",
  website: "https://example.com",
  openingHours: {
    pt: "Seg-Sex: 9h-18h",
    en: "Mon-Fri: 9am-6pm",
    es: "Lun-Vie: 9h-18h"
  },
  isActive: true,
  createdAt: timestamp,
  updatedAt: timestamp,
  createdBy: "admin_id"
}
```

#### `eventos`
```javascript
{
  id: "auto-generated",
  title: {
    pt: "Título em Português",
    en: "Title in English",
    es: "Título en Español"
  },
  description: {
    pt: "Descrição em Português",
    en: "Description in English", 
    es: "Descripción en Español"
  },
  startDate: timestamp,
  endDate: timestamp,
  location: "Local do evento",
  latitude: -25.4284,
  longitude: -49.2733,
  category: "musica|arte|gastronomia|festival",
  imageUrls: ["url1", "url2"],
  isFeatured: true,
  ticketUrl: "https://tickets.com",
  isActive: true,
  createdAt: timestamp,
  updatedAt: timestamp,
  createdBy: "admin_id"
}
```

#### `usuarios`
```javascript
{
  id: "firebase_auth_uid",
  email: "user@example.com",
  name: "Nome do Usuário",
  photoUrl: "https://photo.url",
  preferredLanguage: "pt|en|es",
  favoritePoints: ["point_id1", "point_id2"],
  visitedPoints: ["point_id1", "point_id3"],
  createdAt: timestamp,
  updatedAt: timestamp
}
```

#### `avaliacoes`
```javascript
{
  id: "auto-generated",
  pointId: "tourist_point_id",
  userId: "user_id",
  rating: 5,
  comment: "Comentário do usuário",
  createdAt: timestamp,
  isApproved: true
}
```

## Como Adicionar Traduções

### 1. Estrutura de Tradução no Firestore

Todos os campos de texto que precisam de tradução seguem o padrão:
```javascript
{
  fieldName: {
    pt: "Texto em Português",
    en: "Text in English", 
    es: "Texto en Español"
  }
}
```

### 2. Adicionando Novas Traduções

#### No Aplicativo Mobile:
1. Localize o arquivo de idioma correspondente
2. Adicione as novas chaves de tradução
3. Use o `BlocBuilder<LanguageBloc>` para acessar o idioma atual
4. Implemente a lógica de fallback (PT → EN → ES)

#### No Painel Administrativo:
1. Adicione campos para cada idioma no formulário
2. Salve no formato de objeto multilíngue
3. Implemente validação para pelo menos um idioma obrigatório

### 3. Exemplo de Implementação

```dart
// Flutter - Obtendo texto localizado
String getLocalizedText(Map<String, String> translations, String languageCode) {
  return translations[languageCode] ?? 
         translations['pt'] ?? 
         translations.values.first;
}

// Uso
final name = getLocalizedText(touristPoint.name, currentLanguageCode);
```

## Deploy

### 1. Deploy do Aplicativo Mobile

#### Android (Google Play Store):
```bash
# Gerar APK de release
flutter build apk --release

# Gerar App Bundle (recomendado)
flutter build appbundle --release
```

#### iOS (App Store):
```bash
# Gerar arquivo IPA
flutter build ios --release
```

**Passos adicionais:**
1. Configure as chaves de assinatura
2. Atualize as informações do app (nome, ícone, versão)
3. Teste em dispositivos físicos
4. Siga as diretrizes das lojas (Google Play/App Store)

### 2. Deploy do Painel Administrativo

#### Opção 1: Firebase Hosting
```bash
# Instalar Firebase CLI
npm install -g firebase-tools

# Login no Firebase
firebase login

# Inicializar projeto
firebase init hosting

# Deploy
firebase deploy --only hosting
```

#### Opção 2: Heroku
```bash
# Instalar Heroku CLI
# Criar aplicação
heroku create turismo-curitiba-admin

# Configurar variáveis de ambiente
heroku config:set NODE_ENV=production
heroku config:set SESSION_SECRET=your-secret-key

# Deploy
git push heroku main
```

#### Opção 3: VPS/Cloud Server
1. Configure um servidor com Node.js
2. Use PM2 para gerenciamento de processos
3. Configure nginx como proxy reverso
4. Configure SSL com Let's Encrypt

### 3. Configurações de Produção

#### Variáveis de Ambiente (Produção):
```env
NODE_ENV=production
PORT=3000
SESSION_SECRET=your-super-secret-key-here
FIREBASE_PROJECT_ID=your-project-id
```

#### Segurança Firebase:
1. Configure regras de segurança do Firestore
2. Configure regras de segurança do Storage
3. Restrinja chaves de API por domínio/app

## Estrutura de Arquivos

```
TurismoCuritiba/
├── mobile/                          # Aplicativo Flutter
│   ├── lib/
│   │   ├── blocs/                   # Gerenciamento de estado (BLoC)
│   │   │   ├── auth/
│   │   │   ├── language/
│   │   │   └── tourist_points/
│   │   ├── models/                  # Modelos de dados
│   │   │   ├── tourist_point.dart
│   │   │   ├── event.dart
│   │   │   └── user.dart
│   │   ├── repository/              # Acesso aos dados
│   │   │   └── firebase_repository.dart
│   │   ├── screens/                 # Telas do aplicativo
│   │   │   ├── home_screen.dart
│   │   │   ├── tourist_point_detail.dart
│   │   │   ├── profile_screen.dart
│   │   │   └── events_screen.dart
│   │   ├── app.dart                 # Configuração do app
│   │   └── main.dart                # Ponto de entrada
│   ├── android/                     # Configurações Android
│   ├── ios/                         # Configurações iOS
│   └── pubspec.yaml                 # Dependências Flutter
├── admin/                           # Painel administrativo Node.js
│   ├── controllers/                 # Lógica de negócio
│   │   ├── authController.js
│   │   └── contentController.js
│   ├── routes/                      # Rotas da API
│   │   ├── auth.js
│   │   ├── content.js
│   │   └── dashboard.js
│   ├── views/                       # Templates EJS
│   │   ├── auth/
│   │   └── dashboard/
│   ├── public/                      # Arquivos estáticos
│   │   ├── css/
│   │   └── js/
│   ├── firebase-config.js           # Configuração Firebase
│   ├── server.js                    # Servidor Express
│   └── package.json                 # Dependências Node.js
└── README.md                        # Este arquivo
```

## Tecnologias Utilizadas

### Mobile (Flutter):
- **Flutter SDK**: Framework de desenvolvimento
- **Dart**: Linguagem de programação
- **BLoC**: Gerenciamento de estado
- **Firebase Core**: Integração com Firebase
- **Cloud Firestore**: Banco de dados
- **Google Maps Flutter**: Integração com mapas
- **Geolocator**: Serviços de localização
- **URL Launcher**: Abertura de URLs externas
- **Share Plus**: Compartilhamento de conteúdo
- **Cached Network Image**: Cache de imagens

### Web (Node.js):
- **Express.js**: Framework web
- **EJS**: Template engine
- **Firebase Admin**: SDK administrativo
- **Multer**: Upload de arquivos
- **BCrypt**: Hash de senhas
- **Express Session**: Gerenciamento de sessões
- **CORS**: Cross-Origin Resource Sharing

### Backend:
- **Firebase Firestore**: Banco de dados NoSQL
- **Firebase Storage**: Armazenamento de arquivos
- **Firebase Authentication**: Autenticação de usuários

## Contribuição

### Como Contribuir:
1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/nova-feature`)
3. Commit suas mudanças (`git commit -am 'Adiciona nova feature'`)
4. Push para a branch (`git push origin feature/nova-feature`)
5. Abra um Pull Request

### Padrões de Código:
- **Flutter**: Siga as convenções do Dart/Flutter
- **Node.js**: Use ESLint com configuração padrão
- **Commits**: Use mensagens descritivas em português
- **Documentação**: Mantenha o README atualizado

## Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

## Suporte

Para suporte técnico ou dúvidas sobre o projeto:

- **Email**: suporte@turismocuritiba.com
- **Issues**: Use o sistema de issues do GitHub
- **Documentação**: Consulte este README e os comentários no código

## Changelog

### Versão 1.0.0 (2024-01-XX)
- ✅ Lançamento inicial do aplicativo
- ✅ Aplicativo mobile Flutter completo
- ✅ Painel administrativo web
- ✅ Integração com Firebase
- ✅ Suporte a 3 idiomas
- ✅ Sistema de avaliações
- ✅ Integração com Google Maps
- ✅ Sistema de favoritos e histórico

---

**Desenvolvido com ❤️ para promover o turismo em Curitiba**
