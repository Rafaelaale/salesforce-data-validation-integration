public with sharing class ValidacaoEnderecoQueueable implements Queueable, Database.AllowsCallouts {
    private String cep;
    private Id registroId;

    public ValidacaoEnderecoQueueable(String cep, Id registroId) {
        this.cep = cep;
        this.registroId = registroId;
    }

    public void execute(QueueableContext context) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:ViaCEP/' + cep + '/json/');
        req.setMethod('GET');
        req.setTimeout(10000);

        Http http = new Http();
        try {
            HttpResponse res = http.send(req);
            if (res.getStatusCode() != 200) {
                atualizarRegistro('Erro', 'Status HTTP ' + res.getStatusCode(), null);
                return;
            }

            Map<String, Object> dados = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            if (dados.containsKey('erro')) {
                atualizarRegistro('Erro', 'CEP não encontrado', null);
                return;
            }
            atualizarRegistro('Sucesso', null, dados);
        } catch (Exception e) {
            atualizarRegistro('Erro', e.getMessage(), null);
        }
    }

    private void atualizarRegistro(String status, String mensagemErro, Map<String, Object> dados) {
        Endereco_Validado__c registro = new Endereco_Validado__c(Id = registroId);
        registro.Status_Validacao__c = status;
        registro.Mensagem_Erro__c = mensagemErro;
        if (dados != null) {
            registro.Logradouro__c = (String) dados.get('logradouro');
            registro.Bairro__c = (String) dados.get('bairro');
            registro.Cidade__c = (String) dados.get('localidade');
            registro.Estado__c = (String) dados.get('uf');
        }
        update registro;
    }
}
