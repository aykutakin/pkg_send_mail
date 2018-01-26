CREATE OR REPLACE PACKAGE PKG_SEND_MAIL AS 

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
