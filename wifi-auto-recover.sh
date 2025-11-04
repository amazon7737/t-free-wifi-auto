#!/bin/bash

# Configuration
readonly PING_TARGET="8.8.8.8"
readonly NETWORK_INTERFACE="en0"

# Display banner
display_banner() {
    echo "╔═══════════════════════════════════════╗"
    echo "║                                       ║"
    echo "║         t-wifi-auto                   ║"
    echo "║                                       ║"
    echo "║    Automatic WiFi Recovery Tool       ║"
    echo "║                                       ║"
    echo "╚═══════════════════════════════════════╝"
    echo ""
}

# Reset network interface
reset_network() {
    echo ""
    echo "sudo ipconfig set ${NETWORK_INTERFACE} NONE"
    sudo ipconfig set "${NETWORK_INTERFACE}" NONE
    sleep 3
    
    echo "sudo ipconfig set ${NETWORK_INTERFACE} DHCP"
    sudo ipconfig set "${NETWORK_INTERFACE}" DHCP
    sleep 3
    echo ""
}

# Monitor ping with auto-recovery
monitor_ping() {
    local retry_count="${1:-0}"
    local consecutive_timeouts=0
    local timeout_file="/tmp/wifi-auto-timeout-$$"
    
    echo ""
    echo "Ping 모니터링 시작..."
    echo ""
    
    echo "0" > "$timeout_file"
    
    ping "${PING_TARGET}" 2>&1 | while read -r line; do
        echo "${line}"
        
        # Check for timeout
        if echo "${line}" | grep -qE "(Request timeout|sendto: No route to host|sendto: Host is down)"; then
            current_count=$(cat "$timeout_file")
            ((current_count++))
            echo "$current_count" > "$timeout_file"
            
            # Check if we hit 10 consecutive timeouts
            if [ "$current_count" -ge 10 ]; then
                # Kill ping process
                pkill -P $$ ping 2>/dev/null
                killall ping 2>/dev/null
                
                if [ ${retry_count} -eq 0 ]; then
                    echo ""
                    echo "⚠️  타임아웃 감지 - 자동 재시도 (1/2)"
                    rm -f "$timeout_file"
                    exit 100
                elif [ ${retry_count} -eq 1 ]; then
                    echo ""
                    echo "⚠️  타임아웃 감지 - 자동 재시도 (2/2)"
                    rm -f "$timeout_file"
                    exit 101
                else
                    echo ""
                    echo "⚠️  타임아웃 계속 발생 - 메뉴로 복귀"
                    rm -f "$timeout_file"
                    exit 102
                fi
            fi
        else
            # Reset timeout counter on successful ping
            if echo "${line}" | grep -q "bytes from ${PING_TARGET}"; then
                echo "0" > "$timeout_file"
            fi
        fi
    done
    
    local exit_code=$?
    rm -f "$timeout_file"
    return $exit_code
}

# Ping wrapper with retry logic
start_ping_monitoring() {
    local retry_count=0
    
    while true; do
        monitor_ping ${retry_count}
        local result=$?
        
        if [ $result -eq 100 ]; then
            # First retry
            reset_network
            echo "40초 대기 중..."
            sleep 40
            retry_count=1
        elif [ $result -eq 101 ]; then
            # Second retry
            reset_network
            retry_count=2
        elif [ $result -eq 102 ]; then
            # Return to menu
            return 1
        else
            # Normal exit or Ctrl+C
            return 0
        fi
    done
}

# Show menu
show_menu() {
    while true; do
        echo "선택하세요:"
        select option in "재시도" "ping으로 돌아가기"; do
            case $option in
                "재시도")
                    reset_network
                    break
                    ;;
                "ping으로 돌아가기")
                    start_ping_monitoring
                    # If start_ping_monitoring returns, go back to menu
                    break
                    ;;
                *)
                    echo "올바른 번호를 선택하세요 (1 또는 2)"
                    ;;
            esac
        done
    done
}

# Main execution
main() {
    display_banner
    
    # Start with ping monitoring directly
    start_ping_monitoring
    
    # If it returns, show menu
    show_menu
}

# Handle Ctrl+C gracefully
trap 'echo ""; echo "Exiting..."; exit 0' INT TERM

main

