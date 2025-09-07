#!/bin/bash
# dashboard.sh

CASES_DIR="/home/user/cfd_cases"

# Colori
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

while true; do
    clear
    
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                    🚀 CFD QUEUE DASHBOARD                    ║${NC}"
    echo -e "${CYAN}║                   $(date '+%Y-%m-%d %H:%M:%S')                        ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    # INFO SISTEMA
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
    ram_usage=$(free -m | awk '/Mem:/ { printf("%d/%d MB (%.1f%%)", $3, $2, $3/$2*100) }')
    disk_free=$(df -h / | awk 'NR==2 {print $4 " liberi su " $2}')

    echo -e "${YELLOW}🖥️  CPU: ${NC}$cpu_usage%   ${YELLOW}RAM: ${NC}$ram_usage   ${YELLOW}DISK: ${NC}$disk_free"
    echo ""
    
    # RUNNING
    echo -e "${GREEN}▶ RUNNING:${NC}"
    if [ "$(ls running/*.job 2>/dev/null | wc -l)" -gt 0 ]; then
        for job in running/*.job; do
            case_name=$(sed -n '2p' "$job")
            desc=$(sed -n '4p' "$job")
            command=$(sed -n '3p' "$job")
            
            # Cerca processo attivo
            if pgrep -f "$case_name" > /dev/null; then
                status="🟢 ACTIVE"
            else
                status="🔄 STARTING"
            fi
            
            echo -e "  ${status} ${YELLOW}$case_name${NC} ($command) - $desc"
        done
    else
        echo -e "  ${RED}Nothing running${NC}"
    fi
    
    echo ""
    
    # QUEUE
    echo -e "${BLUE}📋 QUEUE (ordered by priority):${NC}"
    if [ "$(ls queue/*.job 2>/dev/null | wc -l)" -gt 0 ]; then
        find queue -name "*.job" -exec sh -c '
            priority=$(sed -n "1p" "$1")
            case_name=$(sed -n "2p" "$1")
            command=$(sed -n "3p" "$1")
            desc=$(sed -n "4p" "$1")
            printf "  [%2d] %-20s (%s) - %s\n" "$priority" "$case_name" "$command" "$desc"
        ' _ {} \; | sort -n
    else
        echo -e "  ${RED}Queue empty${NC}"
    fi
    
    echo ""
    
    # COMPLETED
    echo -e "${CYAN}✅ RECENTLY COMPLETED:${NC}"
    if [ "$(ls done/*.job 2>/dev/null | wc -l)" -gt 0 ]; then
        ls -t done/*.job 2>/dev/null | head -5 | while read job; do
            if [ -n "$job" ]; then
                case_name=$(sed -n '2p' "$job" 2>/dev/null)
                timestamp=$(basename "$job" | sed 's/^\([0-9]*_[0-9]*\).*/\1/' | tr '_' ' ')
                echo -e "  ✓ ${GREEN}$case_name${NC} completed at $timestamp"
            fi
        done
    else
        echo -e "  ${RED}No completed jobs${NC}"
    fi
    
    echo ""
    echo -e "${YELLOW}Press Ctrl+C to exit dashboard${NC}"
    
    sleep 3  # Aggiorna ogni 3 secondi
done
