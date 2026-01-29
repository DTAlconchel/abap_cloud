CLASS zcl_fi_job DEFINITION PUBLIC FINAL CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_apj_dt_exec_object.
    INTERFACES if_apj_rt_exec_object.

    DATA: mv_bukrs     TYPE c LENGTH 4,
          mv_date_from TYPE d,
          mv_date_to   TYPE d.

  PROTECTED SECTION.

  PRIVATE SECTION.

ENDCLASS.

CLASS zcl_fi_job IMPLEMENTATION.


  METHOD if_apj_dt_exec_object~get_parameters.

    " Definición BUKRS
    et_parameter_def   = VALUE #(
      ( selname        = 'BUKRS'
        kind           = if_apj_dt_exec_object=>parameter
        param_text     = 'Company Code'
        datatype       = 'C'
        length         = 4
        decimals       = 0
        mandatory_ind  = abap_false
        changeable_ind = abap_true )
     ).

    " Valor por defecto
    et_parameter_val = VALUE #(
     ( selname        = 'BUKRS'
       sign    = 'I'
       option  = 'EQ'
       low     = '1000' )
      ).

  ENDMETHOD.

  METHOD if_apj_rt_exec_object~execute.

    "------------------------------------------------------------
    " Entry point del job
    "------------------------------------------------------------

    DATA lv_bukrs TYPE zfi_doc_h-company_code.

    " Leemos parametro
    LOOP AT it_parameters INTO DATA(ls_p).
        IF ls_p-selname = 'BUKRS'.
            lv_bukrs = ls_p-low.
        ENDIF.
    ENDLOOP.

    " CDS & Use Case
    DATA(lo_repo) = NEW zcl_fi_cds( ).
    DATA(lo_uc)   = NEW zcl_fi_use_case( lo_repo ).

    " COMMIT
    lo_uc->execute(
        i_company_code = COND zfi_doc_h-company_code(
                            WHEN mv_bukrs IS INITIAL THEN VALUE #( )
                            ELSE CONV zfi_doc_h-company_code( mv_bukrs ) )
     ).


  ENDMETHOD.

ENDCLASS.
