pkg_send_mail
=======================

Allows you to send mail with attachment to multiple mail addresses.

This package wraps the Oracle Utl_Smtp package and create a basic interface for sending mail.

Execute
-------
Open command window and follow this sqlplus commands

    C:\Users\aakin>sqlplus /nolog
    
    SQL*Plus: Release 11.2.0.2.0 Production on Sal Haz 18 08:49:39 2013
    
    Copyright (c) 1982, 2010, Oracle.  All rights reserved.
    
    SQL> con {username}/{password}
    Connected.
    
    SQL> get PKG_SEND_MAIL.pks NOLIST
     19
    SQL> /
    
    Package created.
    
    SQL> get PKG_SEND_MAIL.pkb NOLIST
    152
    SQL> /
    
    Package body created.
