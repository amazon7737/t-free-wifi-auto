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
2. 10회 연속 타임아웃 감지 시 메뉴 표시
   - `1` 연결 재시도: 네트워크 재시작 (NONE → DHCP)
   - `2` ping으로 복귀: ping 모니터링 재개

종료: `Ctrl + C`

## 패치 노트

[패치노트 확인하러가기](./reactme.md) (2025-11-16 패치)
