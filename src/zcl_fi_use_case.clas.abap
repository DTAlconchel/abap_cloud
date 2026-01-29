CLASS zcl_fi_use_case DEFINITION PUBLIC FINAL CREATE PUBLIC .

  PUBLIC SECTION.

    "-----------------------------------------
    " Resultado (log del job)
    "----------------------------------------
    TYPES: BEGIN OF ty_result,
             doc_uuid     TYPE zfi_doc_h-doc_uuid,
             company_code TYPE zfi_doc_h-company_code,
             doc_no       TYPE zfi_doc_h-doc_no,
             doc_date     TYPE zfi_doc_h-doc_date,
             currency     TYPE zfi_doc_h-currency,
             sum_amount   TYPE decfloat34,
             is_balanced  TYPE abap_bool,
           END OF ty_result,
           tt_result TYPE STANDARD TABLE OF ty_result WITH EMPTY KEY.

    METHODS constructor
      IMPORTING io_repo TYPE REF TO zif_fi_doc_repo.

    METHODS run
      IMPORTING
        i_company_code TYPE zfi_doc_h-company_code OPTIONAL
      RETURNING
        VALUE(rt_result) TYPE tt_result.

    METHODS update_status_via_eml
      IMPORTING it_result TYPE tt_result.

    METHODS execute
      IMPORTING
        i_company_code TYPE zfi_doc_h-company_code OPTIONAL
      RETURNING
        VALUE(rt_result) TYPE tt_result.

  PROTECTED SECTION.

  PRIVATE SECTION.
    DATA mo_repo TYPE REF TO zif_fi_doc_repo.

ENDCLASS.


CLASS zcl_fi_use_case IMPLEMENTATION.

  METHOD constructor.

    mo_repo = io_repo.

  ENDMETHOD.

  METHOD run.

    " Obtenemos los documentos por sociedad
    DATA(lt_docs) = mo_repo->get_docs( i_company_code = i_company_code ).

    LOOP AT lt_docs ASSIGNING FIELD-SYMBOL(<d>).

      " Para cada doc (header) --> Obtenemos sus items
      DATA(lt_items) = mo_repo->get_items( i_doc_uuid = <d>-doc_uuid ).

      " Sumamos importes de items
      DATA(lv_sum) = CONV decfloat34( 0 ).
      LOOP AT lt_items ASSIGNING FIELD-SYMBOL(<i>).
        lv_sum += CONV decfloat34( <i>-amount ).
      ENDLOOP.

      " Construimos tabla salida
      APPEND VALUE ty_result(
        doc_uuid     = <d>-doc_uuid
        company_code = <d>-company_code
        doc_no       = <d>-doc_no
        doc_date     = <d>-doc_date
        currency     = <d>-currency
        sum_amount   = lv_sum
        is_balanced  = xsdbool( lv_sum = 0 ) " ABAP_TRUE si la suma total = 0
      ) TO rt_result.
    ENDLOOP.

  ENDMETHOD.

  METHOD update_status_via_eml.

    " JOB/BATCH

    MODIFY ENTITIES OF zc_fi_doc
      ENTITY Doc
        UPDATE FIELDS ( status )
        WITH VALUE #(
          FOR r IN it_result
          ( doc_uuid = r-doc_uuid
            doc_date  = r-doc_date
            status    = COND #( WHEN r-is_balanced = abap_true THEN 'B' ELSE 'E' ) )
        )
      FAILED   DATA(failed)
      REPORTED DATA(reported).

    COMMIT ENTITIES. " Actualizamos

  ENDMETHOD.

  METHOD execute.

    rt_result = run( i_company_code = i_company_code ).

    IF rt_result IS INITIAL.
      RETURN.
    ENDIF.

    update_status_via_eml( rt_result ).

  ENDMETHOD.

ENDCLASS.
