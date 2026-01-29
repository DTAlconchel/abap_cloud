CLASS zcl_fi_test_exe DEFINITION PUBLIC FINAL CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .

  PROTECTED SECTION.

  PRIVATE SECTION.

    METHODS seed_if_empty.

ENDCLASS.



CLASS zcl_fi_test_exe IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    DELETE FROM zfi_doc_i.
    DELETE FROM zfi_doc_h.
    COMMIT WORK.

    " Crear datos si no hay nada
    seed_if_empty( ).

    " bEjecutar lógica batch - Como el JOB
    DATA(lo_repo) = NEW zcl_fi_cds( ).
    DATA(lo_uc)   = NEW zcl_fi_use_case( lo_repo ).

    DATA(lt_result) = lo_uc->execute( i_company_code = '1000' ).

    "Mostrar resultado en consola
    out->write( |Docs procesados: { lines( lt_result ) }| ).
    out->write( |DocNo       Sum           Balanced| ).
    out->write( |----------  ------------  --------| ).

    LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<r>).
      out->write(
        |{ <r>-doc_no WIDTH = 10 }  { <r>-sum_amount }  { COND string( WHEN <r>-is_balanced = abap_true THEN 'YES' ELSE 'NO' ) }|
      ).
    ENDLOOP.
  ENDMETHOD.
*
*
  METHOD seed_if_empty.
    " Si ya hay datos, no hace nada
    SELECT SINGLE FROM zc_fi_doc FIELDS doc_uuid INTO @DATA(lv_any).
    IF sy-subrc = 0.
      RETURN.
    ENDIF.

    " Crea 2 docs + items por EML
    MODIFY ENTITIES OF zc_fi_doc
        ENTITY Doc
          CREATE FIELDS ( company_code doc_no doc_date currency status )
          WITH VALUE #(
            ( %cid         = 'D1'
              company_code = '1000'
              doc_no       = 'TRIAL0001'
              doc_date     = sy-datum
              currency     = 'EUR'
              status       = 'N' )
            ( %cid         = 'D2'
              company_code = '1000'
              doc_no       = 'TRIAL0002'
              doc_date     = sy-datum
              currency     = 'EUR'
              status       = 'N' )
          )
        ENTITY Doc
          CREATE BY \_Items
          FIELDS ( line_no gl_account amount currency_code item_text assigment )
          WITH VALUE #(
            ( %cid_ref = 'D1'
              %target  = VALUE #(
                ( %cid = 'D1I1' line_no = '0001' gl_account = '400000' amount =  100  currency_code = 'EUR' item_text = 'Revenue' assigment = 'A1' )
                ( %cid = 'D1I2' line_no = '0002' gl_account = '110000' amount = -100  currency_code = 'EUR' item_text = 'Bank'    assigment = 'A1' )
              ) )
            ( %cid_ref = 'D2'
              %target  = VALUE #(
                ( %cid = 'D2I1' line_no = '0001' gl_account = '400000' amount =  200  currency_code = 'EUR' item_text = 'Revenue' assigment = 'A2' )
                ( %cid = 'D2I2' line_no = '0002' gl_account = '110000' amount =  -50  currency_code = 'EUR' item_text = 'Bank'    assigment = 'A2' )
              ) )
          )
      FAILED   DATA(failed)
      REPORTED DATA(reported).

    COMMIT ENTITIES.

  ENDMETHOD.
ENDCLASS.
