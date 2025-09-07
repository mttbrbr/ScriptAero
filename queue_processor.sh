#!/bin/bash
# queue_processor.sh

# Configurazione
CASES_DIR="/home/user/cfd_cases"      # ← Cartella base dei case
QUEUE_DIR="queue"
RUNNING_DIR="running"
DONE_DIR="done"

mkdir -p $QUEUE_DIR $RUNNING_DIR $DONE_DIR

echo "Queue processor started"
echo "Cases directory: $CASES_DIR"

source /usr/lib/openfoam/openfoam2312/etc/bashrc            # percorso di openfoam da seguire

while true; do
    # Controlla se c'è già una simulazione in corso
    if [ "$(ls $RUNNING_DIR/*.job 2>/dev/null | wc -l)" -gt 0 ]; then
        echo "Simulazione in corso, aspetto..."
        sleep 10
        continue
    fi
    
    # Cerca prossimo job per priorità
    job_file=$(find $QUEUE_DIR -name "*.job" -exec sh -c '
        for file; do
            priority=$(head -n1 "$file")
            echo "$priority $file"
        done
    ' _ {} + | sort -n | head -n1 | cut -d" " -f2-)
    
    if [ -z "$job_file" ]; then
        echo "Nessun job in coda - $(date)"
        sleep 10
        continue
    fi
    
    # Leggi configurazione
    job_name=$(basename "$job_file")
    priority=$(sed -n '1p' "$job_file")
    case_name=$(sed -n '2p' "$job_file")        # ← Solo nome cartella
    command=$(sed -n '3p' "$job_file")
    description=$(sed -n '4p' "$job_file")
    
    # Costruisci path completo
    case_path="$CASES_DIR/$case_name"           # ← Combina base + nome
    
    # Verifica che il case esista
    if [ ! -d "$case_path" ]; then
        echo "ERRORE: Case non trovato: $case_path"
        mv "$job_file" "$DONE_DIR/ERROR_$(date +%Y%m%d_%H%M%S)_$job_name"
        continue
    fi
    
    # Muovi in running
    mv "$job_file" "$RUNNING_DIR/"
    
    echo "=== STARTING JOB ==="
    echo "Priority: $priority"
    echo "Description: $description"
    echo "Case: $case_name"
    echo "Full path: $case_path"
    echo "Command: ./$command"
    echo "Time: $(date)"
    echo "==================="
    
    cd "$case_path"
    chmod +x "$command"
    ./$command &
    job_pid=$!
    
    wait $job_pid
    
    echo "=== JOB COMPLETED ==="
    echo "Time: $(date)"
    echo "===================="
    
    mv "$RUNNING_DIR/$job_name" "$DONE_DIR/$(date +%Y%m%d_%H%M%S)_$job_name"
    sleep 2
done
