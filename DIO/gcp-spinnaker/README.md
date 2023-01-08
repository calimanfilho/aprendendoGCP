# Uso do Spinnaker no Google Cloud Platform

Neste exemplo, será realizado todos os passos para a instalação, configuração e utilização do Spinnaker, utilizando como referência o repositório [Spinnaker for GCP](https://github.com/GoogleCloudPlatform/spinnaker-for-gcp.git) do Google Cloud Platform.

> ℹ️ **_INFO_**  
> O Spinnaker no Google Cloud utiliza GKE, Memorystore, buckets do Cloud Storage e contas de serviço.


## Instalação e Configuração do Spinnaker

### 1. Clonando o Repositório [Spinnaker for GCP](https://github.com/GoogleCloudPlatform/spinnaker-for-gcp.git) do Google Cloud Platform

```shell
mkdir ~/cloudshell_open && cd ~/cloudshell_open
```

```shell
git clone https://github.com/GoogleCloudPlatform/spinnaker-for-gcp.git
```

```shell
cd spinnaker-for-gcp
```

### 2. Criando as Variáveis para Instalação do Spinnaker

```shell
./scripts/install/setup_properties.sh
```

### 3. Conferindo as Variáveis Geradas

```shell
cat ./scripts/install/properties
```

### 4. Aplicando as Variáveis no Sistema de Variáveis do Cloud Shell

```shell
source ./scripts/install/properties
```

### 5. Configurando o Git

```shell
git config --global user.email "USER@empresa.com"
git config --global user.name "USER"
```

### 6. Iniciando a Instalação

```shell
./scripts/install/setup.sh
```

> ℹ️ **_INFO_**  
> A instalação pode levar uma média de 15 minutos. Após a instalação terá um cluster criado no GKE chamado de Spinnaker-1

### 7. Conectando na Interface do Spinnaker

```shell
./scripts/manage/connect_unsecured.sh
```

Após o comando acima, para acessar o Spinnaker no Cloud Shell, basta clicar em `Visualização na Web` e depois em `Visualizar na porta 8080`.

## Inclusão do Segundo Cluster GKE

### 1. Configurando a Região do Cluster

```shell
APP_REGION=us-east1-b; gcloud config set compute/zone $APP_REGION
```

### 2. Criando o Cluster
```shell
gcloud container clusters create app-cluster --machine-type=n1-standard-2
```

### 3. Configurando o Spinnaker Cluster

```shell
./scripts/manage/add_gke_account.sh
```

```shell
kubectl config use-context gke_${PROJECT_ID}_${ZONE}_spinnaker-1
```

```shell
./scripts/manage/push_and_apply.sh
```


## Configurando o Pipeline de Exemplo

### 1. Acessa o Diretório _Samples_

```shell
cd ./samples/helloworldwebapp/
```

### 2. Salva Informações do Aplicativo com o Spin

```shell
~/spin app save --application-name helloworldwebapp \
    --cloud-providers kubernetes --owner-email $IAP_USER
```

### 3. Fazendo _Deploy_ do Pipeline de Stagging

```shell
cat templates/pipelines/deploystaging_json.template | envsubst  > templates/pipelines/deploystaging.json
```

```shell
~/spin pi save -f templates/pipelines/deploystaging.json
```

### 4. Salvando o Stagging Pipeline ID na Variável do SO

```shell
export DEPLOY_STAGING_PIPELINE_ID=$(~/spin pi get -a helloworldwebapp -n 'Deploy to Staging' | jq -r '.id')
```
### 5. Fazendo _Deploy_ do Pipeline de Prod

```shell
cat templates/pipelines/deployprod_json.template | envsubst  > templates/pipelines/deployprod.json
```

```shell
~/spin pi save -f templates/pipelines/deployprod.json
```


## Criando o Código Fonte da Aplicação para Exemplo

### 1. Criando a Pasta com o Código Fonte

```shell
mkdir -p ~/$PROJECT_ID/spinnaker-for-gcp-helloworldwebapp/
```

```shell
cp -r templates/repo/src ~/$PROJECT_ID/spinnaker-for-gcp-helloworldwebapp/
```

### 2. Copiando o Código Fonte da Aplicação

```shell
cp -r templates/repo/config ~/$PROJECT_ID/spinnaker-for-gcp-helloworldwebapp/
```

```shell
cp templates/repo/Dockerfile ~/$PROJECT_ID/spinnaker-for-gcp-helloworldwebapp/
```

```shell
cat templates/repo/cloudbuild_yaml.template | envsubst '$BUCKET_NAME' > ~/$PROJECT_ID/spinnaker-for-gcp-helloworldwebapp/cloudbuild.yaml
cat ~/$PROJECT_ID/spinnaker-for-gcp-helloworldwebapp/config/staging/replicaset_yaml.template | envsubst > ~/$PROJECT_ID/spinnaker-for-gcp-helloworldwebapp/config/staging/replicaset.yaml
rm ~/$PROJECT_ID/spinnaker-for-gcp-helloworldwebapp/config/staging/replicaset_yaml.template
cat ~/$PROJECT_ID/spinnaker-for-gcp-helloworldwebapp/config/prod/replicaset_yaml.template | envsubst > ~/$PROJECT_ID/spinnaker-for-gcp-helloworldwebapp/config/prod/replicaset.yaml
rm ~/$PROJECT_ID/spinnaker-for-gcp-helloworldwebapp/config/prod/replicaset_yaml.template
```


## Criando o Repositório Git com Google Cloud Source Repositories

### 1. Entrando no Diretório da Aplicação

```shell
cd ~/$PROJECT_ID/spinnaker-for-gcp-helloworldwebapp
```

### 2. Iniciando o Git, Adicionando Arquivos e Fazendo _Commit_

```shell
git init
git add .
git commit -m "Initial commit"
```

### 3. Criando o Repositório Git no GCP e se Autenticando

```shell
gcloud source repos create spinnaker-for-gcp-helloworldwebapp
git config credential.helper gcloud.sh
```

### 4. Adicionando o Repositório Remoto

```shell
git remote add origin https://source.developers.google.com/p/$PROJECT_ID/r/spinnaker-for-gcp-helloworldwebapp
```

### 5. Enviando os Arquivos para o Repositório Remoto

```shell
git push origin master
```


## Configure Cloud Build Triggers

### 1. Revisando os Passos do Cloud Build

```shell
cat ./cloudbuild.yaml
```
### 2. Criando o Cloud Build Trigger com gcloud sdk

```shell
gcloud beta builds triggers create cloud-source-repositories \
    --repo spinnaker-for-gcp-helloworldwebapp \
    --branch-pattern master \
    --build-config cloudbuild.yaml \
    --included-files "src/**,config/**"
```


## Compilando a Imagem da Aplicação
Será feito uma edição do código, commit e push para que a imagem seja compilada automaticamente.

### 1. Editando a Aplicação e Fazendo _Commit_

```shell
sed -i 's/Hello World/Hello World 1.0/g' ./src/main.go
git add .
git commit -a -m "Change to 1.0"
```

### 2. Enviando os Arquivos para o Repositório Remoto

```shell
git push origin master
```

Após essa etapa pode ser visto a compilação sendo executada no Cloud Build no console do GCP.


## Verificando o Spinnaker

Depois de toda a configuração anterior ter sido executada corretamente, os pipelines do Spinnaker poderão ser verificados no menu `Applications` na aplicação `hellowordwebapp`. Ainda no menu `Applications` > `Infrastructure` > `Load Balancers`, poderá ser obtido o IP público para acessar a aplicação. Ao fim do pipeline do _deploy_ para o _staging_, o Spinnaker aguardar o início manual (que pode ser feito de forma automatizada) para executar o pipeline do _deploy_ para _production_.