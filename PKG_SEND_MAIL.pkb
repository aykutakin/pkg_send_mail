CREATE OR REPLACE PACKAGE BODY PKG_SEND_MAIL AS

/**
 * MIT License
 *
 * Copyright (c) 2018 Aykut Akin
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

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
    v_smtp_server       VARCHAR2(14)  := 'XX.YOUR.SMTP.SERVER';
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
    utl_smtp.write_raw_data(conn, utl_raw.cast_to_raw('To: ' || v_final_to_name || UTL_TCP.crlf));
    utl_smtp.write_raw_data(conn, utl_raw.cast_to_raw('Cc: ' || v_final_cc_name || UTL_TCP.crlf));
    utl_smtp.write_raw_data(conn, utl_raw.cast_to_raw('Date: ' || to_char(sysdate, 'Dy, DD Mon YYYY hh24:mi:ss') || UTL_TCP.crlf));
    utl_smtp.write_raw_data(conn, utl_raw.cast_to_raw('From: ' || v_from_name || UTL_TCP.crlf));
    utl_smtp.write_raw_data(conn, utl_raw.cast_to_raw('Subject: ' || v_subject || UTL_TCP.crlf));
    utl_smtp.write_raw_data(conn, utl_raw.cast_to_raw('MIME-Version: 1.0' || UTL_TCP.crlf));
    utl_smtp.write_raw_data(conn, utl_raw.cast_to_raw('Content-Type: multipart/mixed; boundary="' || v_boundry || '"' || UTL_TCP.crlf || UTL_TCP.crlf));

  -- Message body
    utl_smtp.write_raw_data(conn, utl_raw.cast_to_raw('--' || v_boundry || UTL_TCP.crlf));
    utl_smtp.write_raw_data(conn, utl_raw.cast_to_raw('Content-Type: ' || v_message_type || UTL_TCP.crlf || UTL_TCP.crlf));
    utl_smtp.write_raw_data(conn, utl_raw.cast_to_raw(v_message_body || UTL_TCP.crlf));

  -- Attachment Part
    IF attachments IS NOT NULL 
    THEN
        FOR i IN attachments.FIRST .. attachments.LAST
        LOOP
        -- Attach info
            utl_smtp.write_raw_data(conn, utl_raw.cast_to_raw('--' || v_boundry || UTL_TCP.crlf));
            utl_smtp.write_raw_data(conn, utl_raw.cast_to_raw('Content-Type: ' || attachments(i).data_type 
                                || ' name="'|| attachments(i).attach_name || '"' || UTL_TCP.crlf));
            utl_smtp.write_raw_data(conn, utl_raw.cast_to_raw('Content-Disposition: attachment; filename="'
                                || attachments(i).attach_name || '"' || UTL_TCP.crlf || UTL_TCP.crlf));

        -- Attach body
            n_offset := 1;
            WHILE n_offset < dbms_lob.getlength(attachments(i).attach_content)
            LOOP
                utl_smtp.write_raw_data(conn, utl_raw.cast_to_raw(dbms_lob.substr(attachments(i).attach_content, n_amount, n_offset)));
                n_offset := n_offset + n_amount;
            END LOOP;
            utl_smtp.write_raw_data(conn, utl_raw.cast_to_raw('' || UTL_TCP.crlf));
        END LOOP;
    END IF;
  -- Last boundry
    utl_smtp.write_raw_data(conn, utl_raw.cast_to_raw('--' || v_boundry || '--' || UTL_TCP.crlf));

  -- Close data
    utl_smtp.close_data(conn);
    utl_smtp.quit(conn);

  END SEND_MAIL;

END;
