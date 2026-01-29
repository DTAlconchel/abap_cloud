CLASS zcl_fi_cds DEFINITION PUBLIC FINAL CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_fi_doc_repo .

  PROTECTED SECTION.

  PRIVATE SECTION.

ENDCLASS.

CLASS zcl_fi_cds IMPLEMENTATION.


  METHOD zif_fi_doc_repo~get_docs.

    SELECT FROM zc_fi_doc
        FIELDS doc_uuid, company_code, doc_no, doc_date,
             currency, status, created_at, created_by
        WHERE ( @i_company_code IS INITIAL OR company_code = @i_company_code )
        AND ( @i_date_from      IS INITIAL OR doc_date    >= @i_date_from )
        AND ( @i_date_to        IS INITIAL OR doc_date    <= @i_date_to )
      INTO TABLE @rt_docs.

  ENDMETHOD.


  METHOD zif_fi_doc_repo~get_items.

    SELECT FROM zc_fi_item
        FIELDS item_uuid, doc_uuid, line_no, gl_account,
             amount, currency_code, item_text, assigment
        WHERE ( doc_uuid = @i_doc_uuid  )
      INTO TABLE @rt_items.

  ENDMETHOD.

ENDCLASS.
