@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS FI Item'
define view entity ZC_FI_ITEM as select from zfi_doc_i
    association to parent ZC_FI_DOC as _Doc // Relacion padre <-> hija
    on $projection.doc_uuid = _Doc.doc_uuid
{
      key item_uuid,
      key doc_uuid,
      line_no,
      gl_account,
      @Semantics.amount.currencyCode : 'currency_code'      
      amount,
      currency_code,
      item_text,
      assigment,
      _Doc
}
