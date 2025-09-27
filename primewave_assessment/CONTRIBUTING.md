# Contributing to PrimeWave Assessment

Thank you for your interest in contributing to this Flutter assessment project! This document provides guidelines and information for contributors.

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.24.0)
- Dart SDK (>=3.8.1)
- Git
- IDE (VS Code, Android Studio, or IntelliJ IDEA)

### Setup

1. **Fork the repository**
2. **Clone your fork**
   ```bash
   git clone https://github.com/your-username/primewave-assessment.git
   cd primewave-assessment
   ```

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Run tests**
   ```bash
   flutter test
   ```

## 📝 Development Guidelines

### Code Style

- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `flutter format` to format your code
- Run `flutter analyze` to check for issues

### Testing

- Write tests for new features
- Maintain test coverage above 80%
- Use descriptive test names
- Follow the AAA pattern (Arrange, Act, Assert)

### Commit Messages

Use conventional commit format:

```
type(scope): description

[optional body]

[optional footer]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

Examples:
```
feat(api): add retry mechanism for failed requests
fix(ui): resolve infinite scroll loading issue
docs(readme): update installation instructions
```

## 🧪 Testing

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/models/user_test.dart

# Run tests with coverage
flutter test --coverage
```

### Test Structure

- Unit tests: `test/` directory
- Widget tests: `test/widgets/` directory
- Integration tests: `integration_test/` directory

## 🏗️ Architecture

This project follows clean architecture principles:

```
lib/
├── api/           # API client and network layer
├── config/        # App configuration and theming
├── models/        # Data models
├── repositories/  # Data access layer
├── screens/       # UI screens
├── services/      # Business logic services
├── utils/         # Utility functions
└── widgets/       # Reusable UI components
```

## 🔍 Code Review Process

1. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**
   - Write clean, readable code
   - Add tests for new functionality
   - Update documentation if needed

3. **Test your changes**
   ```bash
   flutter test
   flutter analyze
   flutter format --dry-run --set-exit-if-changed .
   ```

4. **Commit your changes**
   ```bash
   git add .
   git commit -m "feat(scope): your commit message"
   ```

5. **Push and create PR**
   ```bash
   git push origin feature/your-feature-name
   ```

## 📋 Pull Request Guidelines

### Before Submitting

- [ ] Code follows project style guidelines
- [ ] All tests pass
- [ ] Code is properly formatted
- [ ] No analysis issues
- [ ] Documentation is updated
- [ ] Commit messages are clear

### PR Description

Include:
- Description of changes
- Screenshots (if UI changes)
- Testing instructions
- Any breaking changes

## 🐛 Bug Reports

When reporting bugs, include:

1. **Environment**
   - Flutter version
   - Dart version
   - Platform (iOS/Android/Web)

2. **Steps to reproduce**
   - Clear, numbered steps
   - Expected vs actual behavior

3. **Additional context**
   - Screenshots
   - Error logs
   - Device information

## 💡 Feature Requests

For feature requests:

1. Check existing issues first
2. Provide clear description
3. Explain the use case
4. Consider implementation complexity

## 📚 Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Material Design Guidelines](https://material.io/design)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

## 📄 License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing! 🎉
