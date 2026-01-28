#!/bin/bash

# =========================
# FAKE VEHICLE OSINT DEMO
# =========================

logo() {
    echo "╭━━━━╮"
    echo "┃╭╮╭╮┃"
    echo "╰╯┃┃┣┻━┳━┳━━╮"
    echo "╱╱┃┃┃┃━┫╭┫╭╮┃"
    echo "╱╱┃┃┃┃━┫┃┃╭╮┃"
    echo "╱╱╰╯╰━━┻╯╰╯╰╯"
    echo
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo " LOOKUP VEHICLE OSINT • DEMO MODE"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
}

header() {
    echo "[>] TARGET      | $1"
    echo "[>] STATE       | ${2:-US}"
    echo "[>] TIMESTAMP   | $(date)"
    echo "[>] MODE        | API BY @fevber ON DISCORD"
    echo
}

fake_vehicle_data() {
    echo "--- VEHICLE SPECIFICATIONS ---"
    echo "[>] MAKE         | Shadow Motors"
    echo "[>] MODEL        | NightRunner X"
    echo "[>] YEAR         | 2019"
    echo "[>] BODY         | Coupe"
    echo "[>] ENGINE CYL   | V6"
    echo "[>] VIN          | $1"
    echo
}

fake_owner_identity() {
    echo "--- OWNER IDENTITY ---"
    echo "[>] FULL NAME    | Marcus Hale"
    echo "[>] DOB          | 1991-08-14"
    echo "[>] SSN LAST4    | 4832"
    echo "[>] ASSOCIATIONS | Hale Auto Group"
    echo
}

fake_owner_address() {
    echo "--- OWNER ADDRESS ---"
    echo "[+] CURRENT      | 742 Evergreen Ave, Phoenix AZ"
    echo "[+] PREVIOUS     | 1190 Redstone Rd, Tempe AZ"
    echo "[+] VERIFIED     | YES"
    echo "[+] PROPERTY     | Single-family residence"
    echo
}

fake_registration() {
    echo "--- REGISTRATION HISTORY ---"
    echo "[>] STATUS       | ACTIVE"
    echo "[>] EXPIRATION   | 2026-04"
    echo "[>] TITLE COUNT  | 2"
    echo "[>] LIENS        | NONE"
    echo "[>] TRANSFER LOG | Clean record"
    echo
}

fake_insurance() {
    echo "--- INSURANCE STATUS ---"
    echo "[>] ACTIVE POLICY| YES"
    echo "[>] PROVIDER     | IronShield Insurance"
    echo "[>] CLAIMS COUNT | 1 (minor)"
    echo "[>] POLICY NUM   | IS-449201-AZ"
    echo
}

fake_traffic() {
    echo "--- TRAFFIC VIOLATIONS ---"
    echo "[>] TICKETS      | 2 (speeding)"
    echo "[>] POINTS       | 3"
    echo "[>] SUSPENSIONS  | NONE"
    echo "[>] WARRANTS    | NONE"
    echo "[>] ACCIDENTS    | 1 (non-injury)"
    echo
}

fake_vin_links() {
    echo "--- VIN ASSOCIATIONS ---"
    echo "[>] PLATE HISTORY| 3 plates linked"
    echo "[>] TITLE LINKS  | No irregularities"
    echo "[>] SALVAGE REC  | CLEAR"
    echo "[+] CROSS-REF    | Internal demo DB"
    echo
}

fake_border() {
    echo "--- BORDER & INSPECTION ---"
    echo "[>] CBP IMPORTS  | NONE"
    echo "[>] EXPORT LOGS  | NONE"
    echo "[>] FMCSA INSP   | NOT APPLICABLE"
    echo "[>] STATE BORDER | Domestic only"
    echo "[>] SAFETY RECALL| 0 open recalls"
    echo
}

fake_risk() {
    echo "--- RISK ASSESSMENT ---"
    echo "[>] STOLEN STATUS| CLEAR"
    echo "[>] THEFT RISK   | LOW"
    echo "[>] FRAUD RISK   | LOW"
    echo "[>] DATA COVERAGE| 100% (SIMULATED)"
    echo
}

summary() {
    echo "--- RECON SUMMARY ---"
    echo "[+] SOURCES HIT  | Internal Simulation Engine"
    echo "[+] CONFIDENCE   | HIGH (DEMO DATA)"
    echo "[+] NOTICE       | NO REAL DATABASES USED"
    echo
}

footer() {
    echo "[✓] FAKE VEHICLE OSINT COMPLETE"
    echo "[#] DEMO / EDUCATIONAL USE ONLY"
    echo
}

main() {
    logo

    [ $# -lt 1 ] && {
        echo "[!] Usage: $0 <VIN|PLATE> [STATE]"
        exit 1
    }

    header "$1" "$2"
    fake_vehicle_data "$1"
    fake_owner_identity
    fake_owner_address
    fake_registration
    fake_insurance
    fake_traffic
    fake_vin_links
    fake_border
    fake_risk
    summary
    footer
}

main "$@"
