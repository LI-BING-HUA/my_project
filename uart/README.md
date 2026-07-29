# 自訂串列通訊協定與雙時脈跨時脈域設計

**邏輯設計實驗 — 期末專題結報**
平台：Basys3（Xilinx Artix-7, xc7a35tcpg236-1）／ Vivado 2025.2

> **Demo 影片**：[▶ 點此觀看實機展示](https://youtu.be/MBwwueiCtmo)
>
> 設計決策、CDC門檻推導、除錯歷程記在 [DESIGN_NOTES.md](DESIGN_NOTES.md)。

---

## 專題概述

在單一FPGA上實作一套**自訂的串列通訊協定**，以板內自我迴路（TX直接送進RX）驗證正確性。功能正常後，升級為**真正的雙時脈跨時脈域（CDC）架構**：TX/RX分別跑在兩個MMCM產生、頻率非整數倍關係的時脈下，並以`report_cdc`驗證跨域路徑安全性。

接收到的2-bit資料驅動四種展示模式（LED、RGB LED、七段顯示器）。

```
按鈕 → 防彈跳 → 脈衝產生 → TX編碼 ──(signal)──→ RX解碼 → 模式選擇 → 各展示模組
        └────── clk_tx 時脈域 ──────┘         └──── clk_rx 時脈域 ────┘
```

## 特色

- 自行設計通訊協定（參考NEC紅外線概念，以LOW長度區分0/1）
- 真雙時脈CDC：120MHz / 80MHz（非整數倍），兩級同步器 + `report_cdc`驗證 Safely Timed
- 四種展示模式即時切換，實機驗證通過
- 完整時序簽核（WNS為正、hold無違例）

## 模組清單

| 模組 | 功能 |
|------|------|
| COMM_TOP | 頂層整合、時脈域劃分、輸出mux |
| TX | 協定編碼FSM（6狀態） |
| RX | 協定解碼FSM + 兩級同步器 |
| clk_wiz_0 | MMCM，產生120/80MHz |
| Marquee / MC_TOP / Rainbow_Breathing_LED / mul_seg | 四種展示模組 |
| CLA4 / FA / CLG | 進位前瞻加法器（供乘法器使用） |

## 如何執行

1. Vivado建立專案，加入所有source檔案
2. 加入Basys3的XDC約束檔
3. 合成 → 實作 → 產生bitstream → 燒錄
4. 按鈕觸發傳輸，四種模式自動輪替展示
