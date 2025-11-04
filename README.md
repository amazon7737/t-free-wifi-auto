# t-wifi-auto

macOS용 Wi-Fi 자동 복구 도구

네트워크 인터페이스 재시작 및 ping 모니터링으로 Wi-Fi 연결 문제를 자동 해결합니다.

## 실행 방법

```bash
chmod +x wifi-auto-recover.sh
./wifi-auto-recover.sh
```

## 동작

1. ping 8.8.8.8 모니터링 시작
2. 타임아웃 발생 시 자동 복구 또는 메뉴 표시
   - `1` 재시도: 네트워크 재시작 실행
   - `2` ping으로 돌아가기: ping 모니터링 재개

### 자동 복구

ping 모니터링 중 타임아웃 발생 시:
- 1차: 자동 재시도 (NONE → DHCP) → 40초 대기 → ping 재개
- 2차: 자동 재시도 (NONE → DHCP) → ping 재개
- 3차 이후: 메뉴로 복귀

종료: `Ctrl + C`

