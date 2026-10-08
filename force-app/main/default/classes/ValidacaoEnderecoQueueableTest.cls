@isTest
private class ValidacaoEnderecoQueueableTest {
    private class ViaCepMockSucesso implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody('{"cep":"01001-000","logradouro":"Praça da Sé","bairro":"Sé","localidade":"São Paulo","uf":"SP"}');
            return res;
        }
    }

    private class ViaCepMockNaoEncontrado implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody('{"erro": true}');
            return res;
        }
    }

    @isTest
    static void testValidacaoComSucesso() {
        Endereco_Validado__c registro = new Endereco_Validado__c(Cep__c = '01001000', Status_Validacao__c = 'Pendente');
        insert registro;

        Test.setMock(HttpCalloutMock.class, new ViaCepMockSucesso());

        Test.startTest();
        System.enqueueJob(new ValidacaoEnderecoQueueable('01001000', registro.Id));
        Test.stopTest();

        Endereco_Validado__c atualizado = [SELECT Status_Validacao__c, Cidade__c, Estado__c FROM Endereco_Validado__c WHERE Id = :registro.Id];
        System.assertEquals('Sucesso', atualizado.Status_Validacao__c);
        System.assertEquals('São Paulo', atualizado.Cidade__c);
        System.assertEquals('SP', atualizado.Estado__c);
    }

    @isTest
    static void testCepNaoEncontrado() {
        Endereco_Validado__c registro = new Endereco_Validado__c(Cep__c = '00000000', Status_Validacao__c = 'Pendente');
        insert registro;

        Test.setMock(HttpCalloutMock.class, new ViaCepMockNaoEncontrado());

        Test.startTest();
        System.enqueueJob(new ValidacaoEnderecoQueueable('00000000', registro.Id));
        Test.stopTest();

        Endereco_Validado__c atualizado = [SELECT Status_Validacao__c, Mensagem_Erro__c FROM Endereco_Validado__c WHERE Id = :registro.Id];
        System.assertEquals('Erro', atualizado.Status_Validacao__c);
        System.assertEquals('CEP não encontrado', atualizado.Mensagem_Erro__c);
    }
}
