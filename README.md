# ScriptAero
Utilizzo di queue_processor.sh
Questo script automatizza la gestione di una coda di simulazioni CFD. Funziona monitorando una cartella di job e avviando le simulazioni in ordine di priorità.

Struttura delle cartelle
queue/ — contiene i file dei job in attesa
running/ — contiene il job attualmente in esecuzione
done/ — contiene i job completati (o con errore)
Queste cartelle vengono create automaticamente all'avvio dello script.

Struttura di un file job (.job)
Ogni file nella cartella queue/ deve avere estensione .job e contenere, riga per riga:

Priorità (numero intero, più basso = maggiore priorità)
Nome della cartella del case (solo nome, senza path)
Comando da eseguire (es: Allrun)
Descrizione (testo libero)

Esempio di file queue/example.job:

1case
1Allrun
Simulazione di test


Avvio dello script
Esegui lo script dalla cartella principale:

./queue_processor.sh
Lo script controllerà periodicamente la coda e avvierà i job uno alla volta, spostandoli tra le cartelle in base allo stato.

Note
La variabile CASES_DIR va modificata nello script per puntare alla directory contenente i case CFD.
Se la cartella del case non esiste, il job viene spostato in done/ con prefisso ERROR_.
Solo un job viene eseguito alla volta.