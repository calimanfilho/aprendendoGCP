# Orçamento e Alertas no Faturamento na Google Cloud Platform

Repositório contento os _prints_ da configuração do Orçamento e Alertas no GCP, para essa configuração foi levado em consideração os seguintes pontos:

1. Valor do orçamento em R$20,00 mensais buscando manter a desepesa em um valor bastante pequeno.

2. Alertas em 50%, 90% e 100% do valor do orçamento para ser avisado de possíveis gastos não desejados.

# Exportação de Faturamento para o BigQuey

O `BigQuery Export` envia os dados de faturamento para um conjunto de dados do BigQuery. Para configurar a exportação deve ser feito os seguintes passos:

1. Acessar o serviço de `Billing` no Google Cloud Console.

2. Clicar em `Exportação de faturamento` no menu lateral.

3. Na nova tela, deve-se clicar em `EDITAR CONFIGURAÇÕES`.

4. Agora deverá ser selecionado o projeto onde os dados de faturamento são armazenados, e o conjunto de dados, que caso ainda não tenha sido criado, deverá ser selecionado `CRIAR NOVO CONJUNTO DE DADOS`.

5. Nessa etapa deverá ser selecionado novamente o projeto onde os dados de faturamento são armazenados, informar um código do conjunto de dados, a região ou zona de disponibilidade, informar se os dados da tabela irão expirar (se sim, qual o prazo em dias) e em opções avançadas, informar o tipo de criptografia que será utilizada e se será ativado a ordenação padrão, e por fim, clicar em `CRIAR CONJUNTO DE DADOS`.

6. Retornará a tela anterior, onde deverá ser selecionado o conjunto de dados criado anteriormente.

7. Clicar em `SALVAR` para finalizar a configuração da exportação do faturamento.