# 💜 Pichuruco – Cofrinho Digital Compartilhado

![Flutter](https://img.shields.io/badge/Flutter-3.19-blue?logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-connected-orange?logo=firebase)
![Status](https://img.shields.io/badge/status-em%20desenvolvimento-yellow)

**Pichuruco** é um aplicativo de cofrinho digital compartilhado para casais. Com uma interface intuitiva, animações encantadoras e sincronização em tempo real, o app permite que duas pessoas acompanhem juntas o progresso em direção a uma meta de economia.

> Feito com Flutter e Firebase, o app também funciona offline e sincroniza automaticamente quando volta à internet. ❤️💰

---

## 🖼️ Preview

| Tela Inicial | Novo Depósito | Configuração |
|--------------|----------------|----------------|
| ![Home](prints/print2.jpeg) | ![Depósito](prints/print3.jpeg) | ![Configuração](prints/print3.jpeg) |

---

## 🚀 Funcionalidades

- ✅ Cofrinho compartilhado entre dois usuários (Yogas & Hay)
- ✅ Código secreto do casal
- ✅ Frase personalizada de incentivo
- ✅ Progresso animado com barra gradiente roxa
- ✅ Animação especial ao atingir a meta 🎉
- ✅ Histórico de depósitos
- ✅ Modo offline com Hive e sincronização automática
- ✅ Exportação para CSV (em breve)

---

## 🧱 Tecnologias Utilizadas

- Flutter 3.x
- Firebase Firestore & Authentication
- Hive (armazenamento local)
- `flutter_animated_background`
- `intl`, `animations`, `provider`

---

## 📦 Estrutura de Pastas

```
lib/
├── screens/           # Telas principais do app
│   ├── home_screen.dart
│   ├── login_screen.dart
│   ├── welcome_screen.dart
│   └── ...
├── widgets/           # Componentes reutilizáveis
├── services/          # Firebase, Hive e lógica de negócios
├── firebase_options.dart
```

---

## 🛠️ Como Rodar o Projeto Localmente

1. **Clone o repositório:**

```bash
git clone https://github.com/seu-usuario/pichuruco-app.git
cd pichuruco-app
```

2. **Instale as dependências:**

```bash
flutter pub get
```

3. **Configure o Firebase:**

- Coloque o arquivo `firebase_options.dart` gerado pelo `flutterfire configure` na pasta `lib/`.

Se ainda não tiver:

```bash
flutterfire configure
```

4. **Execute o app:**

```bash
flutter run
```

---

## 🤝 Contribuições

Este projeto ainda está em desenvolvimento, mas contribuições são muito bem-vindas!  
Você pode abrir uma *issue*, enviar um *pull request* ou apenas deixar um ⭐ no repositório.

---

## 📜 Licença

Distribuído sob a licença MIT. Veja `LICENSE` para mais informações.

---

## ✨ Autor

**Eduardo Alencar**  
Desenvolvedor apaixonado por experiências digitais encantadoras.  
Siga-me no GitHub: [@eduardoalencar](https://github.com/eduardoalencar)