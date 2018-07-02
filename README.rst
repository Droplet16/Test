pg_stat_moddate
==============

Features
--------

Extension for saving main information about last updating of database objects.
It is provided for PostgreSQL 9.6/10.4.

Installation
============

Compiling
---------

The module can be built using the standard PGXS infrastructure.

Usage
=====

pg_stat_moddate create several objects.

gwi_stat_moddate table 
-------------------

+-------------+-----------------------------+-----------------------------------------------------+
| Name        | Type                        | Description                                         |
+=============+=============================+=====================================================+
| recdate     | timestamp without time zone | Object creating date                                |
+-------------+-----------------------------+-----------------------------------------------------+
| moddate     | timestamp without time zone | Object modify date                                  |
+-------------+-----------------------------+-----------------------------------------------------+
| user_name   | name                        | User name                                           |
+-------------+-----------------------------+-----------------------------------------------------+
| user_ip     | inet                        | User ip                                             |
+-------------+-----------------------------+-----------------------------------------------------+
| obj_type    | text                        | Type of creating/modify object                      |
+-------------+-----------------------------+-----------------------------------------------------+
| obj_name    | text                        | Name of creating/modify object                      |
+-------------+-----------------------------+-----------------------------------------------------+
| obj_schema  | text                        | Schema name                                         |
+-------------+-----------------------------+-----------------------------------------------------+

gwi_note_event_ddl_command_end function
-----------------------------

Inserts/Updates information about last change of object.

gwi_note_event_sql_drop function
-----------------------

Delete all information about deleted object.

Author
=======

pg_stat_moddate is an original development from Sergey Arkhipov.

License
=======

pg_stat_moddate is free software distributed under the PostgreSQL license.

Copyright (c) 2018, SArkhipov.

