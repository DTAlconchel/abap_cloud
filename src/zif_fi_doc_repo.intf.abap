INTERFACE zif_fi_doc_repo PUBLIC .

  " Header
  TYPES: BEGIN OF ty_doc,
           doc_uuid      TYPE zfi_doc_h-doc_uuid,
           company_code  TYPE zfi_doc_h-company_code,
           doc_no        TYPE zfi_doc_h-doc_no,
           doc_date      TYPE zfi_doc_h-doc_date,
           currency      TYPE zfi_doc_h-currency,
           status        TYPE zfi_doc_h-status,
           created_at    TYPE zfi_doc_h-created_at,
           created_by    TYPE zfi_doc_h-created_by,
         END OF ty_doc,
         tt_doc TYPE STANDARD TABLE OF ty_doc WITH EMPTY KEY.

  " Item
  TYPES: BEGIN OF ty_item,
           item_uuid      TYPE zfi_doc_i-item_uuid,
           doc_uuid       TYPE zfi_doc_i-doc_uuid,
           line_no        TYPE zfi_doc_i-line_no,
           gl_account     TYPE zfi_doc_i-gl_account,
           amount         TYPE zfi_doc_i-amount,
           currency_code  TYPE zfi_doc_i-currency_code,
           item_text      TYPE zfi_doc_i-item_text,
           assigment      TYPE zfi_doc_i-assigment,
         END OF ty_item,
         tt_item TYPE STANDARD TABLE OF ty_item WITH EMPTY KEY.

" METODOS
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    METHODS get_docs
        IMPORTING
            i_company_code  TYPE zfi_doc_h-company_code OPTIONAL
            i_date_from     TYPE zfi_doc_h-doc_date OPTIONAL
            i_date_to       TYPE zfi_doc_h-doc_date OPTIONAL
         RETURNING
            VALUE(rt_docs)  TYPE tt_doc.

    METHODS get_items
        IMPORTING
            i_doc_uuid      TYPE zfi_doc_h-doc_uuid
        RETURNING
            VALUE(rt_items) TYPE tt_item.

ENDINTERFACE.
