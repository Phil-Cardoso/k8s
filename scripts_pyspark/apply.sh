#!/bin/bash

# Configurações iniciais
USUARIO_GITHUB="phil-cardoso"
NOME_IMAGEM="spark-pi"
TAG="latest"
IMAGEM="ghcr.io/${USUARIO_GITHUB}/${NOME_IMAGEM}:${TAG}"
ARQUIVO_YAML="spark-app.yaml"

# Verifica se o token está exportado
if [[ -z "$GHCR_TOKEN" ]]; then
  echo "Erro: variável de ambiente GHCR_TOKEN não encontrada."
  echo "Dica: exporte seu token antes de executar o script:"
  echo "      export GHCR_TOKEN=seu_token_gerado"
  exit 1
fi

echo "Iniciando processo de build, push e deploy..."
echo "Imagem: $IMAGEM"

# Build da imagem
echo "Buildando imagem Docker..."
docker build -t "$IMAGEM" .

# Login no GHCR
echo "Autenticando no GitHub Container Registry (GHCR)..."
echo "$GHCR_TOKEN" | docker login ghcr.io -u "$USUARIO_GITHUB" --password-stdin

# Push da imagem
echo "Enviando imagem para o GHCR..."
docker push "$IMAGEM"

# Remoção da imagem local
echo "Removendo imagem local para liberar espaço..."
docker rmi "$IMAGEM"

# Limpando cache do Docker
echo "Limpando recursos não utilizados..."
docker system prune -f

# Aplicando o YAML no cluster
echo "Aplicando arquivo YAML no cluster Kubernetes..."
kubectl apply -f "$ARQUIVO_YAML"

echo "Processo concluído com sucesso."
