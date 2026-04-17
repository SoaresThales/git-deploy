# Git Deploy 🚀

> Um script para automatizar deploys no GitHub de forma simples, fluida e à prova de esquecimentos.

---

## 📋 Sobre o Projeto
Desde a época em que eu fazia revisão de carros, aprendi que um bom checklist é essencial para organizar o fluxo e lembrar de todos os itens. Mesmo com anos de experiência, nem todos os dias estamos 100% afiados e atentos a cada detalhe. 

Trouxe essa mesma lógica para o desenvolvimento: criei esse script simples, mas poderoso, para não sofrermos mais com deploys ruins, commits confusos ou com a segurança comprometida (como esquecer de colocar o `.env` no `.gitignore`). O objetivo é manter a mente tranquila e o histórico de commits do GitHub sempre impecável.

## 🛠️ Tecnologias Utilizadas

As seguintes ferramentas foram usadas na construção deste script:

![Bash](https://img.shields.io/badge/BASH-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)
![Git](https://img.shields.io/badge/GIT-E44C30?style=for-the-badge&logo=git&logoColor=white)
![GitHub](https://img.shields.io/badge/GITHUB-181717?style=for-the-badge&logo=github&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)


## 🚀 Como Executar
Passo a passo rápido para quem baixar o projeto:
1. Clone o repositório.
2. Configure o seu `git-deploy.sh` na pasta raiz dos seus repositórios:
```bash
nano git-deploy.sh
```
3. Dê permissão de execução para o script:
```bash
chmod +x ~/pasta-raiz/git-deploy.sh
```
4. Edite o arquivo de configuração do seu terminal (Bash):
```bash
nano ~/.bashrc
```
5. crie o alias (digite lá na última linha):
```bash
alias gitsend='~/pasta-raiz/git-deploy.sh'
```
6. atualize o terminal:
```bash
source ~/.bashrc
```
O resultado final:

A partir de agora, você pode entrar em qualquer subpasta do seu servidor (ex: ~/pasta-raiz/repositorio-1 ou ~/pasta-raiz/repositorio-2) e, na hora de subir o código, é só digitar no terminal:
```bash
gitsend
```
Ele vai puxar o script do diretório pai, jogar o checklist de pré-voo na sua tela, confirmar os dados e empurrar tudo para o repositório correto de forma fluida e segura.

## 📌 Roadmap / Funcionalidades
[x] Automação de git push

[x] Checklist de segurança e boas práticas

[x] Padronização de mensagens de Commits

[x] Gerenciamento fácil de TAGs

[ ] Criação de template base para README.md


## 📄 Licença

Este projeto está sob a licença MIT - veja o arquivo LICENSE para mais detalhes.


Pode salvar e rodar o `gitsend` com tranquilidade! O seu repositório vai ficar com uma cara super profissional.
