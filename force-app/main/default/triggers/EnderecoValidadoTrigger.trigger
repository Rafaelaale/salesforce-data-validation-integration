trigger EnderecoValidadoTrigger on Endereco_Validado__c (after insert) {
    for (Endereco_Validado__c registro : Trigger.new) {
        if (registro.Status_Validacao__c == 'Pendente' && String.isNotBlank(registro.Cep__c)) {
            System.enqueueJob(new ValidacaoEnderecoQueueable(registro.Cep__c, registro.Id));
        }
    }
}
