<h1 align="center">Welcome to PSProjectManager 👋</h1>

<div align="center">
<p>
  <a href="https://github.com/jacquindev/commits/main"><img alt="Last Commit" src="https://img.shields.io/github/last-commit/jacquindev/PSProjectManager?style=for-the-badge&logo=github&logoColor=EBA0AC&label=Last%20Commit&labelColor=302D41&color=EBA0AC"></a>&nbsp;&nbsp;
  <a href="https://github.com/jacquindev/PSProjectManager/"><img src="https://img.shields.io/github/repo-size/jacquindev/PSProjectManager?style=for-the-badge&logo=hyprland&logoColor=F9E2AF&label=Size&labelColor=302D41&color=F9E2AF" alt="REPO SIZE"></a>&nbsp;&nbsp;
  <a href="https://github.com/jacquindev/PSProjectManager/LICENSE"><img src="https://img.shields.io/github/license/jacquindev/PSProjectManager?style=for-the-badge&logo=&color=CBA6F7&logoColor=CBA6F7&labelColor=302D41" alt="LICENSE"></a>&nbsp;&nbsp;
  <a href="https://github.com/jacquindev/PSProjectManager/stargazers"><img alt="Stargazers" src="https://img.shields.io/github/stars/jacquindev/PSProjectManager?style=for-the-badge&logo=starship&color=B7BDF8&logoColor=B7BDF8&labelColor=302D41"></a>&nbsp;&nbsp;
</p>
</div>

<br/>

<div align="center">
  <a href="#author"><kbd> <br> 👤 Author <br> </kbd></a>&ensp;&ensp;
  <a href="#contribute"><kbd> <br> 🤝 Contribute <br> </kbd></a>&ensp;&ensp;
  <a href="#features"><kbd> <br> ✨ Features <br> </kbd></a>&ensp;&ensp;
  <a href="#install"><kbd> <br> 🌷 Install <br> </kbd></a>&ensp;&ensp;
  <a href="#usage"><kbd> <br> 🙈 Usage <br> </kbd></a>&ensp;&ensp;
</div>

## ✨ Features

- **Use DevDrive**: The `New-Project` function will automatically set a folder named `projects` in your DevDrive location. If DevDrive is not found, it will be created at `$HOME/projects`.
- **CookieCutter**: A command line to initialize new project from [GitHub Repositories Templates](https://github.com/search?q=cookiecutter&type=repositories)
- **DotNet**: Provides multiple templates to choose from the [list](./lib/frameworks/dotnet/)
- **Node**:
  - Initializes new project with your preferred package manager **(bun|npm|pnpm|yarn)**.
  - Provides multiple WebFrameworks to choose from.
- **PHP**:
  - Web Frameworks available:
    - [CakePHP](https://cakephp.org/)
    - [CodeIgniter](https://codeigniter.com/)
    - [Laminas](https://getlaminas.org/)
    - [Laravel](https://laravel.com/docs/11.x)
    - [Slim](https://www.slimframework.com/)
    - [Symfony](https://symfony.com/doc/current/index.html)
    - [Yii](https://www.yiiframework.com/)
- **Python**:
  - Options to first setup your project's dependencies and frameworks.
  - Multiple addons available for each framework!
- **Rust**:
  - Include some Frontend/Backend Frameworks for Rust.
  - Simple `main.rs` [templates](./templates/) for framework
- Beautiful [README.md template](./templates/readme-template.md)
- Automatically generate LICENSE file for your project folder (use [Shresht7/gh-license](https://github.com/Shresht7/gh-license))

## 🌷 Install

Clone this project with `git`:

```bash
git clone https://github.com/jacquindev/PSProjectManager.git your_location
```

Execute [PSProjectManager.ps1](./PSProjectManager.ps1) in your PowerShell Profile

```pwsh
Add-Content $PROFILE ". your_location/PSProjectManager.ps1"
```

## 🙈 Usage

Create a new project:

```pwsh
New-Project -ProjectName [ProjectName] -Language [Language] -Github
```

Use cookiecutter:

```pwsh
New-Project -ProjectName [ProjectName] -CookieCutter
```

**Options available:**

- Language: _Choose a supported language_ (dotnet|node|php|python|rust|unknown)
- Github: (optional) Create a GitHub Repository
- CookieCutter: (optional) Create a project from CookieCutter's template. **_Note that when using this option, you do not need to specify the Language field_**

## 🤝 Contribute

Contributions, issues and feature requests are welcome!<br />
Feel free to check [issues page](https://github.com/jacquindev/PSProjectManager/issues).<br/>

## 👤 Author

**Jacquin Moon**

- GitHub: [@jacquindev](https://github.com/jacquindev)

## 📝 License

Copyright © 2024 [Jacquin Moon](https://github.com/jacquindev).<br />

This project is [MIT](https://github.com/jacquindev/PSProjectManager/blob/main/LICENSE) licensed.

## Show your support

Give a ⭐️ if this project helped you!
