CLASS lhc_Doc DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Doc RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Doc RESULT result.


    METHODS Reconcile FOR MODIFY
      IMPORTING keys FOR ACTION Doc~Reconcile RESULT result.

ENDCLASS.

CLASS lhc_Doc IMPLEMENTATION.

  METHOD get_instance_authorizations.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<k>).
      APPEND VALUE #(
        %tky    = <k>-%tky
        %update = if_abap_behv=>auth-allowed
        %delete = if_abap_behv=>auth-allowed
      ) TO result.
    ENDLOOP.

  ENDMETHOD.

  METHOD get_global_authorizations.


  ENDMETHOD.


  METHOD Reconcile.

    " Leer cabeceras seleccionadas
    READ ENTITIES OF zc_fi_doc IN LOCAL MODE
      ENTITY Doc
      FIELDS ( doc_uuid doc_date company_code doc_no currency status )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_docs).

    IF lt_docs IS INITIAL.
      RETURN.
    ENDIF.

    " Leer items de esos documentos
    READ ENTITIES OF zc_fi_doc IN LOCAL MODE
      ENTITY Doc
      BY \_Items
      FIELDS ( doc_uuid amount )
      WITH CORRESPONDING #( lt_docs )
      RESULT DATA(lt_items).

    " Calculamos suma por doc_uuid
    TYPES: BEGIN OF ty_sum,
             doc_uuid   TYPE zfi_doc_h-doc_uuid,
             sum_amount TYPE decfloat34,
           END OF ty_sum.
    DATA lt_sum TYPE HASHED TABLE OF ty_sum WITH UNIQUE KEY doc_uuid.

    LOOP AT lt_items ASSIGNING FIELD-SYMBOL(<it>).
      ASSIGN lt_sum[ doc_uuid = <it>-doc_uuid ] TO FIELD-SYMBOL(<s>).
      IF sy-subrc <> 0.
        INSERT VALUE ty_sum( doc_uuid = <it>-doc_uuid sum_amount = 0 ) INTO TABLE lt_sum.
        ASSIGN lt_sum[ doc_uuid = <it>-doc_uuid ] TO <s>.
      ENDIF.
      <s>-sum_amount += CONV decfloat34( <it>-amount ).
    ENDLOOP.

    " Preparamos updates de status (B si sum = 0, E si no)
    DATA lt_update TYPE STANDARD TABLE OF zc_fi_doc WITH EMPTY KEY.

    LOOP AT lt_docs ASSIGNING FIELD-SYMBOL(<d>).
      DATA(lv_sum) = COND decfloat34(
        WHEN line_exists( lt_sum[ doc_uuid = <d>-doc_uuid ] )
        THEN lt_sum[ doc_uuid = <d>-doc_uuid ]-sum_amount
        ELSE 0 ).

      APPEND VALUE zc_fi_doc(
        doc_uuid = <d>-doc_uuid
        " Incluimos doc_date - Concurrencia
        doc_date = <d>-doc_date
        status   = COND #( WHEN lv_sum = 0 THEN 'B' ELSE 'E' )
      ) TO lt_update.
    ENDLOOP.

    " Actualizamos vía EML (LOCAL MODE, sin COMMIT)
    MODIFY ENTITIES OF zc_fi_doc IN LOCAL MODE
      ENTITY Doc
      UPDATE FIELDS ( status )
      WITH CORRESPONDING #( lt_update )
      FAILED DATA(failed_update)
      REPORTED DATA(reported__update).

    " Devolvemos $self para que Fiori refresque la fila / objeto
    result = VALUE #( FOR d IN lt_docs ( %tky = d-%tky ) ).

  ENDMETHOD.

ENDCLASS.
