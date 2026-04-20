# Git Deploy

> A lightweight Git deployment script designed to automate commits, enforce best practices, and prevent common deployment mistakes.

![Version](https://img.shields.io/badge/version-1.1.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Shell](https://img.shields.io/badge/shell-bash-informational.svg)

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Shell](https://img.shields.io/badge/shell-bash-informational.svg)

---

## Overview

> This project was built around a simple principle: checklists prevent mistakes.
> In previous professional experiences, structured workflows proved essential for maintaining consistency and avoiding errors. The same concept applies to software development. Even experienced developers can forget small but critical steps during deployments.

> Git Deploy provides a simple but effective automation layer that helps:

- Prevent accidental commits
- Avoid pushing sensitive files such as .env
- Standardize commit messages
- Manage version tags
- Keep repositories clean and professional

> The goal is to create a reliable and safe deployment workflow while maintaining a clean Git history.

## 🛠️ Technologies

> This project is built using:

![Bash](https://img.shields.io/badge/BASH-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)
![Git](https://img.shields.io/badge/GIT-E44C30?style=for-the-badge&logo=git&logoColor=white)
![GitHub](https://img.shields.io/badge/GITHUB-181717?style=for-the-badge&logo=github&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)

## Installation

> Passo a passo rápido para quem baixar o projeto:

1. Clone o repositório.

```
git clone https://github.com/your-user/git-deploy.git
```

2. Move the script to your repositories root directory:

```
nano git-deploy.sh
```

3. Make the script executable:

```
chmod +x ~/pasta-raiz/git-deploy.sh
```

4. Create a Bash alias:

```
nano ~/.bashrc
```

5. Add the following line:

```
alias gitsend='~/pasta-raiz/git-deploy.sh'
```

6. Reload your shell:

```
source ~/.bashrc
```

Usage

> Navigate to any Git repository inside your root directory and run:

```
gitsend
```

> The script will:

- Detect repository
- Detect current branch
- Display modified files
- Ask for commit message
- Perform security checks
- Confirm deployment
- Push changes
- Optionally create version tags

## Roadmap

[X] Automated git push
[X] Interactive deployment checklist
[X] Commit message standardization
[X] Tag management
[X] .env security detection
[ ] AI-assisted version suggestion
[ ] Automatic changelog generation
[ ] Fast deploy mode
[ ] Silent deploy mode
[ ] Multi-repository support

---

## Example Workflow

```
gitsend
```

> Output:

```
Repository: secure-auth-api
Branch: main

Modified files:
- index.js
- docker-compose.yml

Commit message:
feat: improve authentication

Continue? (y/n)
```

---

## License

> This project is licensed under the MIT License. See the LICENSE file for details.

---

## Contribution

> Contributions, suggestions, and improvements are welcome.

> If you find this project useful, feel free to open an issue or submit a pull request.

---

## Contribution

> Contributions, suggestions, and improvements are welcome.

> If you find this project useful, feel free to open an issue or submit a pull request.
