@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS FI Header'
define root view entity ZC_FI_DOC as select from zfi_doc_h
    composition [0..*] of ZC_FI_ITEM as _Items // Relacion padre <-> hija
{
      key doc_uuid,
      company_code,
      doc_no,
      doc_date,
      currency,
      status,
      created_at,
      created_by,
      _Items
}
