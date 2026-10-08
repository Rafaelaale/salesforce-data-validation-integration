// Executa mesmo se o Queueable falhar de forma não tratada, evitando registros presos em "Pendente"
public with sharing class ValidacaoEnderecoFinalizer implements Finalizer {
    private Id registroId;

    public ValidacaoEnderecoFinalizer(Id registroId) {
        this.registroId = registroId;
    }

    public void execute(FinalizerContext ctx) {
        if (ctx.getResult() == ParentJobResult.SUCCESS) {
            return;
        }

        try {
            update new Endereco_Validado__c(
                Id = registroId,
                Status_Validacao__c = 'Erro',
                Mensagem_Erro__c = 'Falha inesperada no processamento assíncrono'
            );
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Finalizer não conseguiu atualizar o registro: ' + e.getMessage());
        }
    }
}
