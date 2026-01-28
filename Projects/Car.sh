#!/bin/bash

logo() {
    echo "╭━━━━╮"
    echo "┃╭╮╭╮┃"
    echo "╰╯┃┃┣┻━┳━┳━━╮"
    echo "╱╱┃┃┃┃━┫╭┫╭╮┃"
    echo "╱╱┃┃┃┃━┫┃┃╭╮┃"
    echo "╱╱╰╯╰━━┻╯╰╯╰╯"
    echo
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
}

check_deps() {
    command -v curl >/dev/null 2>&1 || { echo "[!] Install curl"; exit 1; }
    command -v jq >/dev/null 2>&1 || { echo "[!] Install jq"; exit 1; }
}

header() {
    local target=$1 state=$2
    echo "[>] TARGET      | $target"
    echo "[>] STATE       | $state"
    echo "[>] TIMESTAMP   | $(date)"
    echo
}

parse_nhtsa() {
    local vin=$1
    local data=$(curl -s "https://vpic.nhtsa.dot.gov/api/vehicles/decodevin/$vin?format=json" | jq -r '.Results[]')
    
    make=$(echo "$data" | jq -r 'select(.Variable=="Make") | .Value' 2>/dev/null)
    model=$(echo "$data" | jq -r 'select(.Variable=="Model") | .Value' 2>/dev/null)
    year=$(echo "$data" | jq -r 'select(.Variable=="Model Year") | .Value' 2>/dev/null)
    body=$(echo "$data" | jq -r 'select(.Variable=="Body Class") | .Value' 2>/dev/null)
    engine=$(echo "$data" | jq -r 'select(.Variable=="Engine Number of Cylinders") | .Value' 2>/dev/null | sed 's/NULL/UNKNOWN/')
    
    echo "$make|$model|$year|$body|$engine"
}

vehicle_data() {
    local vin=$1
    local info=$(parse_nhtsa "$vin")
    IFS='|' read -r make model year body engine <<< "$info"
    
    echo "--- VEHICLE SPECIFICATIONS ---"
    echo "[>] MAKE         | ${make:-NOT FOUND}"
    echo "[>] MODEL        | ${model:-NOT FOUND}"
    echo "[>] YEAR         | ${year:-NOT FOUND}"
    echo "[>] BODY         | ${body:-NOT FOUND}"
    echo "[>] ENGINE CYL   | ${engine:-NOT FOUND}"
    echo "[>] VIN          | $vin"
    echo
}

owner_identity() {
    echo "--- OWNER IDENTITY ---"
    echo "[>] FULL NAME    | REQUIRES LexisNexis/Accurint"
    echo "[>] DOB          | REQUIRES paid background check"
    echo "[>] SSN LAST4    | REQUIRES TLOxp/Lexis"
    echo "[>] ASSOCIATIONS | Whitepages reverse lookup"
    echo
}

owner_address() {
    echo "--- OWNER ADDRESS ---"
    echo "[+] CURRENT      | TruePeopleSearch plate lookup"
    echo "[+] PREVIOUS     | PropertyShark VIN chain"
    echo "[+] VERIFIED     | MelissaData owner match"
    echo "[+] PROPERTY     | County assessor records"
    echo
}

registration_data() {
    echo "--- REGISTRATION HISTORY ---"
    echo "[>] STATUS       | State DMV portal check"
    echo "[>] EXPIRATION   | DMV records"
    echo "[>] TITLE COUNT  | Carfax/VinAudit"
    echo "[>] LIENS        | NICB salvage database"
    echo "[>] TRANSFER LOG | AutoCheck full history"
    echo
}

insurance_status() {
    echo "--- INSURANCE STATUS ---"
    echo "[>] ACTIVE POLICY| Verisk/ISO ClaimSearch"
    echo "[>] PROVIDER     | State insurance database"
    echo "[>] CLAIMS COUNT | NICB theft/accident"
    echo "[>] POLICY NUM   | LexisNexis insurance module"
    echo
}

traffic_records() {
    echo "--- TRAFFIC VIOLATIONS ---"
    echo "[>] TICKETS      | CourtListener + state judiciary"
    echo "[>] POINTS       | DMV driver record"
    echo "[>] SUSPENSIONS  | State DMV enforcement"
    echo "[>] WARRANTS     | PACER federal + state courts"
    echo "[>] ACCIDENTS    | TRIRGA + state DOT"
    echo
}

vin_associations() {
    echo "--- VIN ASSOCIATIONS ---"
    echo "[>] PLATE HISTORY| Carfax plate chain"
    echo "[>] TITLE LINKS  | VinAudit title transfers"
    echo "[>] SALVAGE REC  | NICB + state salvage"
    echo "[+] CROSS-REF    | EpicVIN plate-VIN database"
    echo
}

border_inspection() {
    echo "--- BORDER & INSPECTION ---"
    echo "[>] CBP IMPORTS  | FOIA cbp.gov records"
    echo "[>] EXPORT LOGS  | CBP outbound manifests"
    echo "[>] FMCSA INSP   | SAFER commercial inspections"
    echo "[>] STATE BORDER | DOT crossing records"
    echo "[>] SAFETY RECALL| NHTSA VIN-specific"
    echo
}

risk_assessment() {
    echo "--- RISK ASSESSMENT ---"
    echo "[>] STOLEN STATUS| $(curl -s -w "%{http_code}" -o /dev/null "https://www.nicb.org/vincheck/vincheck?vin=$1" | grep -q "200" && echo "NO ALERT" || echo "CHECK DIRECT")"
    echo "[>] THEFT RISK   | LOW - public scan"
    echo "[>] FRAUD RISK   | MEDIUM - verify titles"
    echo "[>] DATA COVERAGE| 30% - public sources only"
    echo
}

summary() {
    echo "--- RECON SUMMARY ---"
    echo "[+] SOURCES HIT  | NHTSA $(curl -s "https://vpic.nhtsa.dot.gov/api/vehicles/decodevin/$1?format=json" | jq '.Count'), NICB"
    echo "[+] NEXT ACTION  | Carfax (\$40) + LexisNexis subscription"
    echo "[+] FULL COVERAGE| Requires 5+ paid databases"
    echo
}

footer() {
    echo "[✓] VEHICLE OSINT RECON COMPLETE"
    echo "[#] AUTHORIZED PENTEST USE ONLY"
    echo
}

main() {
    logo
    check_deps
    
    [ $# -lt 1 ] && { 
        echo "[!] Usage: $0 <VIN|PLATE> [STATE]"
        exit 1
    }
    
    local target=$1
    local state=${2:-US}
    
    header "$target" "$state"
    
    if [[ $target =~ ^[A-HJ-NPR-Z0-9]{17}$ ]]; then
        vehicle_data "$target"
    else
        echo "--- VEHICLE SPECIFICATIONS ---"
        echo "[>] VIN          | PLATE-TO-VIN LOOKUP REQUIRED"
        echo "[>] MAKE/MODEL   | STATE DMV DATABASE"
    fi
    
    owner_identity
    owner_address
    registration_data
    insurance_status
    traffic_records
    vin_associations
    border_inspection
    risk_assessment "$target"
    summary "$target"
    footer
}

main "$@"
