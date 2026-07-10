# France_RFE
Forum National de la Facture - Réforme Facture Electronique en France - 
Socle minimum - XP Z12-012, Z12-014

Validation Artefact for France CTC e-invoicing mandate

Sdandard XP_Z12-012 can be found on this link : https://www.boutique.afnor.org/fr-fr/norme/xp-z12012/formats-et-profils-des-messages-factures-et-statuts-de-cycle-de-vie-constit/fa301169/601641

Standard XP_Z12-014 (Use case for France CTC e-invoicing mandate reform in France) ca be found on this link : https://www.boutique.afnor.org/fr-fr/norme/xp-z12014/-cas-dusage-b2b-applicables-dans-le-cadre-la-reforme-facture-electronique-e/fa301171/601640

Standard XP_Z12-013 (standard API for last mile to connect Plateformes Agrées), on this link : https://www.boutique.afnor.org/fr-fr/norme/xp-z12013/api-pour-interfacer-les-systemes-dinformations-des-entreprises-avec-les-pla/fa301170/601639 

## Versionning
- The 2 first digit are related to the AFNOR XP Z12-012 version (to start : 1.4)
- The third digit is a minor version which implement some optimization or correct some issue which can wait a periodic version, ie 1.4.0 is the first version of schematron for 1.4 XP Z12-012.
- The fourth digits are a hotfix for correcting bugs in very specific situation and should be implemented asap but only if the corrected situation appears. First example is 1.4.0.01 for correcting BR-FREXT-CO-12 in UBL where a regression appear and need to be corrected for invoices which have document level charges and no document level allowances for UBL invoices in EXTENDED-CTC-FR profile.

## Change list
- 1.4.0.01 : done 2026 07 10, correct UBL EXTENDED-CTC-FR sch and xslt for BR-FREXT-CO-12, issue #6, see schematron for detail

