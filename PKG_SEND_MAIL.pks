CREATE OR REPLACE PACKAGE PKG_SEND_MAIL AS 

  TYPE attach_info IS RECORD (
        attach_name     VARCHAR2(40),
        data_type       VARCHAR2(40) DEFAULT 'text/plain',
        attach_content  CLOB DEFAULT ''
    );
    
  TYPE array_attachments IS TABLE OF attach_info;

  PROCEDURE SEND_MAIL (
        v_from_name    VARCHAR2,
        v_to_name      VARCHAR2,
        v_subject      VARCHAR2,
        v_message_body VARCHAR2,
        v_cc_name      VARCHAR2 DEFAULT '',
        attachments    array_attachments DEFAULT NULL,
        v_message_type VARCHAR2 DEFAULT 'text/plain'
    );
  
END;
