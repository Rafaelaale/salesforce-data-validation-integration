# Salesforce Data Validation Integration

## Objetivo
Validar e completar endereços a partir do CEP, integrando o Salesforce com a API pública ViaCEP.

## Problema que resolve
Cadastros com endereço incompleto ou incorreto geram retrabalho. Este projeto valida o CEP automaticamente e preenche logradouro, bairro, cidade e estado a partir de uma fonte externa.

## Fluxo
```
Endereco_Validado__c (status = Pendente)
   -> Trigger after insert
   -> ValidacaoEnderecoQueueable (callout assíncrono)
   -> Named Credential "ViaCEP"
   -> API ViaCEP (https://viacep.com.br)
   -> Registro atualizado (status Sucesso/Erro + dados do endereço)
```

## Tecnologias
Apex · Queueable Apex (`Database.AllowsCallouts`) · HttpRequest/HttpResponse · Named Credential · Apex Trigger · HttpCalloutMock

## Componentes
- `Endereco_Validado__c`: objeto customizado com CEP, dados de endereço e status da validação
- `EnderecoValidadoTrigger`: dispara o processamento ao inserir um registro pendente
- `ValidacaoEnderecoQueueable`: faz o callout (via Named Credential, sem token exposto) e grava o resultado
- Named Credential `ViaCEP`: guarda o endpoint da API, sem credenciais no código

## Segurança
- Nenhum endpoint, token ou segredo fica hardcoded no Apex — o endereço da API está na Named Credential.
- Callout feito somente em contexto assíncrono (Queueable), fora do trigger.
- Erros de callout (CEP inválido, falha HTTP, exceção) são tratados e registrados no próprio registro, sem expor detalhes sensíveis.

## Testes
`ValidacaoEnderecoQueueableTest` usa `HttpCalloutMock` para simular a resposta da API e valida:
- Atualização dos campos de endereço quando a API responde com sucesso
- Gravação do status `Sucesso` após o callout

## Prints / demonstração
> Adicionar aqui print do registro antes e depois da validação, e do resultado dos testes Apex.

## Como executar / reproduzir
```powershell
sf project deploy start -o seuOrg
```
1. Configure a Named Credential `ViaCEP` apontando para `https://viacep.com.br/ws` (sem autenticação).
2. Crie um registro de `Endereco_Validado__c` com um CEP válido e status `Pendente`.
3. O trigger dispara o Queueable automaticamente e atualiza o registro.

## Decisões técnicas e desafios
- Escolhida a API ViaCEP por ser pública, gratuita e não exigir token — adequada para demonstrar o padrão de integração sem expor segredos.
- Processamento assíncrono via Queueable para permitir o callout fora do contexto do trigger.
- Principal desafio: tratar separadamente os cenários de CEP inexistente (API retorna `erro: true`) e falha de rede/HTTP.

## Próximas melhorias
- Reprocessamento automático em caso de falha temporária (retry)
- Suporte a outras fontes de dados (ex: validação de CNPJ)
- Log estruturado de tentativas de integração
