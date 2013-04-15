pkg_send_mail
=======================

Allows you to send mail with attachment to multiple mail addresses

---------------------Samples---------------------

BEGIN
 PKG_SEND_MAIL.SEND_MAIL('test@mailserver.com','test@mailserver.com','test','test');
END;

-----------------------------------------------

BEGIN
 PKG_SEND_MAIL.SEND_MAIL('test@mailserver.com','test@mailserver.com','test',
                         '<TITLE>10/01/2013 09:30:28</TITLE><H3 ALIGN="CENTER">My header</H3>' ||
                         '<TABLE  BORDER=1 ALIGN="CENTER" CELLPADDING=0><TR><TD ALIGN="CENTER">Simple Table</TD></TR></TABLE>',
                         NULL,'text/html');
END;

-----------------------------------------------

DECLARE
 attachments PKG_SEND_MAIL.ARRAY_ATTACHMENTS := PKG_SEND_MAIL.ARRAY_ATTACHMENTS();
BEGIN
 attachments.extend(3);
 FOR i IN 1..3
 LOOP
   SELECT 'test' || to_char(i) || '.txt','text/plain','test' || to_char(i)
   INTO attachments(i)
   FROM dual;
 END LOOP;
 PKG_SEND_MAIL.SEND_MAIL('test@mailserver.com','test@mailserver.com','test','test',attachments);
END;

-----------------------------------------------

DECLARE
 attachments PKG_SEND_MAIL.ARRAY_ATTACHMENTS := PKG_SEND_MAIL.ARRAY_ATTACHMENTS();
BEGIN
 attachments.extend(3);
 FOR i IN 1..3
 LOOP
   SELECT 'test' || to_char(i) || '.xls','text/plain',
          '<TITLE>10/01/2013 09:30:28</TITLE><H3 ALIGN="CENTER">My header</H3>' ||
          '<TABLE  BORDER=1 ALIGN="CENTER" CELLPADDING=0><TR><TD ALIGN="CENTER">Simple Table</TD></TR></TABLE>'
   INTO attachments(i)
   FROM dual;
 END LOOP;
 PKG_SEND_MAIL.SEND_MAIL('test@mailserver.com','test@mailserver.com','test','test',attachments);
END;

-----------------------------------------------
