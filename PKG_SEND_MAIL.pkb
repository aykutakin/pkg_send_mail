CREATE OR REPLACE PACKAGE BODY PKG_SEND_MAIL AS

/*
* Created By    : Aykut Akin
* Creation Date : 10.01.2013
*/

  PROCEDURE SEND_MAIL(
        v_from_name    VARCHAR2,
        v_to_name      VARCHAR2,
        v_subject      VARCHAR2,
        v_message_body VARCHAR2,
        v_cc_name      VARCHAR2 DEFAULT '',
        attachments    array_attachments DEFAULT NULL,
        v_message_type VARCHAR2 DEFAULT 'text/plain'
    ) AS
    v_smtp_server       VARCHAR2(14)  := '10.200.123.135';
    n_smtp_server_port  NUMBER        := 25;
    conn                utl_smtp.connection;
    v_boundry           VARCHAR2(20)  := 'SECBOUND';
    n_offset            NUMBER        := 0;
    n_amount            NUMBER        := 1900;
    v_final_to_name     CLOB          := '';
    v_final_cc_name     CLOB          := '';
    v_mail_address      VARCHAR2(100);
  BEGIN
    conn := utl_smtp.open_connection(v_smtp_server,n_smtp_server_port);
    utl_smtp.helo(conn, v_smtp_server);
    utl_smtp.mail(conn, v_from_name);
    
    -- Add all recipient
    v_final_to_name := v_to_name;
    v_final_to_name := replace(v_final_to_name, ' ');
    v_final_to_name := replace(v_final_to_name, ',', ';');
    LOOP
      n_offset := n_offset + 1;
      v_mail_address := regexp_substr(v_final_to_name, '[^;]+', 1, n_offset);
      EXIT WHEN v_mail_address IS NULL;
      utl_smtp.rcpt(conn, v_mail_address);
    END LOOP;

    -- Add all recipient
    v_final_cc_name := v_cc_name;
    v_final_cc_name := replace(v_final_cc_name, ' ');
    v_final_cc_name := replace(v_final_cc_name, ',', ';');
    n_offset := 0;
    LOOP
      n_offset := n_offset + 1;
      v_mail_address := regexp_substr(v_final_cc_name, '[^;]+', 1, n_offset);
      EXIT WHEN v_mail_address IS NULL;
      utl_smtp.rcpt(conn, v_mail_address);
    END LOOP;

  -- Open data
    utl_smtp.open_data(conn);
    
  -- Message info
    utl_smtp.write_data(conn, 'To: ' || v_final_to_name || UTL_TCP.crlf);
    utl_smtp.write_DATA(conn, 'Cc: ' || v_final_cc_name || UTL_TCP.crlf);
    utl_smtp.write_data(conn, 'Date: ' || to_char(sysdate, 'Dy, DD Mon YYYY hh24:mi:ss') || UTL_TCP.crlf);
    utl_smtp.write_data(conn, 'From: ' || v_from_name || UTL_TCP.crlf);
    utl_smtp.write_data(conn, 'Subject: ' || v_subject || UTL_TCP.crlf);
    utl_smtp.write_data(conn, 'MIME-Version: 1.0' || UTL_TCP.crlf);
    utl_smtp.write_data(conn, 'Content-Type: multipart/mixed; boundary="' || v_boundry || '"' || UTL_TCP.crlf || UTL_TCP.crlf);

  -- Message body
    utl_smtp.write_data(conn, '--' || v_boundry || UTL_TCP.crlf);
    utl_smtp.write_data(conn, 'Content-Type: ' || v_message_type || UTL_TCP.crlf || UTL_TCP.crlf);
    utl_smtp.write_data(conn, v_message_body || UTL_TCP.crlf);

  -- Attachment Part
    IF attachments IS NOT NULL 
    THEN
        FOR i IN attachments.FIRST .. attachments.LAST
        LOOP
        -- Attach info
            utl_smtp.write_data(conn, '--' || v_boundry || UTL_TCP.crlf);
            utl_smtp.write_data(conn, 'Content-Type: ' || attachments(i).data_type 
                                || ' name="'|| attachments(i).attach_name || '"' || UTL_TCP.crlf);
            utl_smtp.write_data(conn, 'Content-Disposition: attachment; filename="'
                                || attachments(i).attach_name || '"' || UTL_TCP.crlf || UTL_TCP.crlf);

        -- Attach body
            n_offset := 1;
            WHILE n_offset < dbms_lob.getlength(attachments(i).attach_content)
            LOOP
                utl_smtp.write_data(conn, dbms_lob.substr(attachments(i).attach_content, n_amount, n_offset));
                n_offset := n_offset + n_amount;
            END LOOP;
            utl_smtp.write_data(conn, '' || UTL_TCP.crlf);
        END LOOP;
    END IF;
  -- Last boundry
    utl_smtp.write_data(conn, '--' || v_boundry || '--' || UTL_TCP.crlf);

  -- Close data
    utl_smtp.close_data(conn);
    utl_smtp.quit(conn);

  END SEND_MAIL;

END;
