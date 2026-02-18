# GitOps - Exemplo de Estrutura para Deploy, Gestão e Monitoramento de Containers

Este projeto demonstra um fluxo GitOps básico para aplicações containerizadas utilizando Go, Docker e GitHub Actions.

## Estrutura do Projeto

- **main.go**: Aplicação Go simples que serve "Hello, World!" na porta 8080.
- **Dockerfile**: Build multi-stage para gerar uma imagem mínima da aplicação.
- **.github/workflows/cd.yaml**: Pipeline de CD para build e push automático da imagem Docker para o Docker Hub.
- **go.mod**: Gerenciamento de dependências do Go.

## Passos Realizados até o Momento

### 1. Criação da Aplicação Go
Arquivo `main.go`:
```go
package main

import "net/http"

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("<h1>Hello, World!</h1>"))
	})
	http.ListenAndServe(":8080", nil)
}
```

### 2. Dockerfile Multi-stage
Arquivo `Dockerfile`:
```Dockerfile
FROM golang:1.25.6 AS build
WORKDIR /app
COPY . .
RUN go build -o server .

RUN CGO_ENABLED=0 GOOS=linux go build -o server .

FROM scratch
WORKDIR /app
COPY --from=build /app/server .
ENTRYPOINT [ "./server" ]
```

### 3. Pipeline de CD com GitHub Actions
Arquivo `.github/workflows/cd.yaml`:
- Checkout do código
- Login no Docker Hub
- Configuração do Docker Buildx
- Build e push da imagem para o Docker Hub com as tags `${{ github.sha }}` e `latest`

### 4. Configuração de Variáveis no GitHub
No repositório do GitHub, acesse **Settings > Secrets and variables > Actions** e adicione:
- `DOCKERHUB_USERNAME`: Seu usuário do Docker Hub
- `DOCKERHUB_TOKEN`: Token de acesso do Docker Hub (gere em https://hub.docker.com/settings/security)

### 5. Teste Local do Dockerfile
Para testar a geração da imagem localmente:

```sh
docker build -t gitops:local .
docker run --rm -p 8080:8080 gitops:local
```
Acesse [http://localhost:8080](http://localhost:8080) para ver a mensagem "Hello, World!".

---

<!-- Continuação do fluxo e instruções de monitoramento serão adicionadas posteriormente. -->

## 6. Instalação do Kind (Kubernetes in Docker)

Para criar clusters Kubernetes locais para testes, utilize o [Kind](https://kind.sigs.k8s.io/):

### Instalação do Kind

**Linux:**
```sh
curl -Lo ./kind "https://kind.sigs.k8s.io/dl/v0.23.0/kind-linux-amd64"
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```

**Verifique a instalação:**
```sh
kind --version
```

### Criando um cluster local
```sh
kind create cluster --name gitops
```

## 7. Instalação do Kustomize

O [Kustomize](https://kubectl.docs.kubernetes.io/installation/kustomize/) é utilizado para customizar manifestos Kubernetes de forma declarativa.

### Instalação do Kustomize

**Linux:**
```sh
curl -Lo kustomize "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv5.4.2/kustomize_v5.4.2_linux_amd64.tar.gz"
tar -xzvf kustomize_v5.4.2_linux_amd64.tar.gz
chmod +x kustomize
sudo mv kustomize /usr/local/bin/
```

**Verifique a instalação:**
```sh
kustomize version
```

---

<!-- Próximos passos: criação dos manifestos Kubernetes, uso do Kustomize e integração com o cluster Kind. -->
