#!/bin/bash

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${YELLOW}--- Iniciando Automação de Push/Tag ---${NC}\n"

# 1. Verifica se estamos em um repositório git
if [ ! -d .git ]; then
    echo -e "${RED}Aviso: Você não está dentro de um repositório Git! (Pasta .git não encontrada)${NC}"
    echo -e "${GREEN}Deseja inicializar um repositório novo nesta pasta agora? (s/n)${NC}"
    read init_git
    
    if [ "$init_git" == "s" ]; then
        git init
        git branch -M main
        echo -e "${YELLOW}Repositório local inicializado com sucesso!${NC}"
        
        echo -e "${GREEN}Cole a URL do repositório remoto do GitHub (ex: https://github.com/seu-usuario/seu-repo.git) ou dê ENTER para pular:${NC}"
        read remote_url
        
        if [ ! -z "$remote_url" ]; then
            git remote add origin "$remote_url"
            echo -e "${YELLOW}Repositório remoto conectado!${NC}\n"
        else
            echo -e "${RED}Nenhum repositório remoto adicionado. O push final falhará se não houver um origin.${NC}\n"
        fi
    else
        echo -e "${RED}Operação abortada. Vá para uma pasta válida ou inicie o git manualmente.${NC}"
        exit 1
    fi
fi

# 2. Checklist de Pré-Voo (Os Lembretes)
echo -e "${CYAN}================ CHECKLIST PRÉ-DEPLOY =================${NC}"
echo -e "Antes de subir o código, verifique mentalmente:"
echo -e " [ ] ${YELLOW}.gitignore${NC} está configurado? (Ignorou node_modules, pastas do SO, etc?)"
echo -e " [ ] O arquivo ${YELLOW}.env${NC} real está protegido e ignorado?"
echo -e " [ ] O arquivo ${YELLOW}.env.example${NC} foi criado e está atualizado?"
echo -e " [ ] Lembrou de fazer/atualizar o ${YELLOW}README.md${NC}? (Seu eu do futuro agradece!)"
echo -e " [ ] Tirou os 'console.log' perdidos de teste?"
echo -e "${CYAN}=======================================================${NC}\n"

# Pausa dramática para o usuário confirmar
read -p "Tudo certo para o deploy? Pressione [ENTER] para continuar ou [CTRL+C] para abortar..."

# 3. Mostra o status atual para conferência
echo -e "\n${GREEN}Status atual dos arquivos:${NC}"
git status -s

# 4. Adiciona todos os arquivos
echo -e "\n${YELLOW}Adicionando arquivos no stage (git add .)...${NC}"
git add .

# 5. Pergunta a mensagem de commit
echo -e "${GREEN}Digite a mensagem do Commit (ou deixe em branco para data/hora atual):${NC}"
read commit_message

if [ -z "$commit_message" ]; then
    commit_message="Update automático: $(date +'%d/%m/%Y %H:%M')"
fi

# Executa o commit
git commit -m "$commit_message"

# 6. Gerenciamento de TAG
echo -e "\n${GREEN}Deseja criar uma TAG para este release? (s/n)${NC}"
read de_tag

if [ "$de_tag" == "s" ]; then
    echo -e "${GREEN}Digite o nome da TAG (ex: v1.0.2):${NC}"
    read tag_name
    if [ ! -z "$tag_name" ]; then
        git tag -a "$tag_name" -m "Release $tag_name"
        echo -e "${YELLOW}Tag $tag_name criada.${NC}"
    fi
fi

# 7. Push para o GitHub
echo -e "\n${YELLOW}Enviando para o GitHub...${NC}"
current_branch=$(git rev-parse --abbrev-ref HEAD)

git push origin "$current_branch"

# Se houver tag, envia ela também
if [ "$de_tag" == "s" ]; then
    git push origin --tags
fi

echo -e "\n${GREEN}--- Deploy concluído com sucesso! ---${NC}"
