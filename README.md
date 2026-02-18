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


## 8. Instalação do Argo CD

O [Argo CD](https://argo-cd.readthedocs.io/) é uma ferramenta declarativa de entrega contínua (CD) para Kubernetes baseada em GitOps.

### Instalação do Argo CD

Execute os comandos abaixo para instalar o Argo CD no seu cluster Kubernetes:

```sh
kubectl create namespace argocd
kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### Validação da Instalação


Para verificar se o Argo CD foi instalado corretamente e está rodando:

```sh
kubectl get all -n argocd
```
Você deve ver os pods, services e outros recursos do Argo CD listados como ativos no namespace `argocd`.

### Acessando o Dashboard do Argo CD

Para acessar a interface web do Argo CD localmente, faça o port-forward do serviço:

```sh
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Depois, acesse [https://localhost:8080](https://localhost:8080) no seu navegador.

### Obtendo a Senha do Usuário Admin

Em outro terminal, recupere a senha inicial do usuário `admin` com o comando:

```sh
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

Utilize o usuário `admin` e a senha obtida para fazer login na interface web do Argo CD.

---

## Criando uma Nova Aplicação no Argo CD

Após acessar o painel do Argo CD e realizar o login, siga os passos para criar uma nova aplicação:

1. Clique em **NEW APP** (Nova Aplicação).
2. Preencha os campos conforme o esboço abaixo (os campos de Git e Docker já estarão preenchidos ou ocultos):

| Campo         | Valor sugerido/exemplo                       |
|---------------|----------------------------------------------|
| **Name**      | goserve-gitops                              |
| **Project**   | default                                     |
| **Annotations** | (opcional)                                 |
| **Cluster**   | in-cluster (https://kubernetes.default.svc) |
| **Namespace** | default                                     |
| **Path**      | k8s                                         |
| **Sync Options** | (padrão)                                  |
| **Retry Options** | Retry disabled                           |

Após preencher, clique em **Create** para criar a aplicação.

Você poderá acompanhar o status, sincronização e saúde da aplicação pelo painel do Argo CD.
