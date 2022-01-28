# qb-billing
Company Billing script for QBCore 

Features
ok  Bill can be created by every employee to fill the company account
ok  The bill is stored in the table with date, issuer, reason, amount
ok  The bill can be payed immediately by the customer or sent by mail for later payment
ok  If customer is Boss, he can choose to pay the bill with company account
ok  Open bills can be consulted by every employee to cancel one or send dunning
ok  Dunning can be sent with (once) or without additionnal costs
ok  Money is transferred from customer configured account to company account
ok  Statistics can be consulted by employee
ok  All statistics can be consulted by job boss
ok  Open bills can be consulted by police (job in config) to RP the missing payments
Check if no bill is unpayed before creating a new one, else make the dunning     
To save database size, delete is made for old payed invoices and crafting
Ability to record every Player activity for the company (NPC jobs, Crafting)

Command /createbill     to create a bill for the company    ok
Command /showbills      to consult open bills               ok
Command /statbills      to consult personal statistics for the month
Command /statbills      to consult statistics by employee for the month (boss)
Command /unpayedbills   to consult unpayed bills for a person (police only)



Accounting table sample : 
Id              1
Reference       FINEIDX534202201141015  --Reference for quick access
Type            RP                      --Rp Invoice
Issuer          RADAR                   --Issuer (Automatic radar)
Job             police                  --Job account to pay
Customer        IDX534                  --Payer (Person)
Invoice Date    20220114                --Date
Status          2                       --Payment status (Dunned)
Amount          1000                    --Amount
Reason          Flash at 180km/h at location

Id              2
Reference       MECAIDX534202201141018
Type            RP
Issuer          ERF564                  --Issuer (Person)
Job             mechanic
Customer        IDX534
Invoice Date    20220114
Status          0                       --Payment status (Not Payed)
Amount          10000
Reason          Repair of car ESK-520

Id              2
Reference                               --No Reference needed
Type            NPC                     --NPC Entry
Issuer          IDX534
Job             mechanic
Customer        NPC                     --Payer (NPC)
Invoice Date    20220114
Status          1                       --Payment status (Payed)
Amount          200
Reason          NPC Tow mission

Id              3
Reference       MECAIDX53420220114      --Reference for the day
Type            CRA                     --Crafting Entry
Issuer          IDX534
Job             mechanic
Customer                                --No customer for crafting entry
Invoice Date    20220114
Status          9                       --Crafting
Amount          18                      --Total crafted today
Reason          Mechanic Kit            --Item name


