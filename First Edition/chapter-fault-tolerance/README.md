# LogProcessing

First of all—'Let is crash' approach is a bit different from what described in the book. You don't need to define strategies and handle lifecycle specifically. Crash and lifecycle mechanism is done by Swift throwing mechanism and memory management. 
Want to restart a process? Esclate it to supervisor and it will just recreate an instance of an actor by id.
Resume? Just skip an error.
Stop? Stop current through supervisor and procced to next or simply esaclate further to stop whole service (e.g. when it's DiskError).
An so on. 
