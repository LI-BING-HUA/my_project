# Multicycle RISC-V CPU (RV32I)

用 Verilog 從零實作的多週期 RISC-V 處理器，支援完整 RV32I 整數指令集。
繼單週期 CPU 之後的重刻版本，重點在理解「為什麼多週期能用更少的硬體」，並為之後的 pipeline 版本鋪路。

> 設計決策與「為什麼這樣接」的細節記在 [DESIGN_NOTES.md](DESIGN_NOTES.md)。

---

## 特色

- **完整 RV32I 指令集**：R / I / S / B / U / J 型共 37 條。
- **單一 memory、單一 ALU**：透過分 cycle 的時間多工，用比單週期更少的硬體完成同樣的指令集。
- **datapath / control 分離**：datapath 純資料通路，控制訊號全由 controller 的 FSM 產生，可各自獨立驗證。
- **繼承並改進單週期**：例如 ALU 的 SLT 由「直接 `$signed` 比較」改為「重用減法器 + overflow 修正」。

---

## 架構總覽

多週期：**一條指令拆成多個 cycle，每個 cycle 只做一件事**，同一時間機器裡只有一條指令。

```
Fetch → Decode → Execute → Memory → WriteBack
        （不同指令用剛好夠的 cycle 數：R-type 少、lw 多）
```

- **Datapath**：PC、單一 Memory、Register File、ALU、Extend，加上中間暫存器
  （IR / OldPC / A / B / ALUOut / MDR）與四個 mux（SrcA / SrcB / Result / Adr）。
- **Controller**（進行中）：FSM 依當前狀態產生控制訊號、決定狀態轉移。

---

## 模組

| 模組 | 功能 |
|------|------|
| `DataPath.v` | 資料路徑，串接所有零件與 mux；控制訊號為 input，狀態訊號（op/funct3/funct7b5/zero）為 output。 |
| `ALU.v` | 10 種運算，SLT 用減法器 + overflow 修正。 |
| `Register_File.v` | 32×32，2 讀 1 寫，x0 恆 0。 |
| `Extend.v` | 立即數產生，I/S/B/U/J 五種格式。 |
| `Memory.v` | 單一 memory（fetch 與 load/store 共用），byte-addressable。 |
| `register_en.v` | 帶 enable 的暫存器（PC / OldPC / IR）。 |
| `register_nen.v` | 無 enable 的暫存器（A / B / MDR / ALUOut）。 |
| `mux2.v` / `mux3.v` | 多工器。 |
| `Controller.v` | 控制 FSM（進行中）。 |

---

## 開發進度

- [x] 零件：ALU、Register File、Extend、Memory、中間暫存器
- [x] Datapath 接線 + 手動逐 cycle 驗證（addi 走完四個 cycle，暫存器正確寫回）
- [ ] Control FSM（進行中）
- [ ] Load / Store 延伸單元、整合測試

---

## 目標指令集：RV32I（37 條）

| 類型 | 指令 |
|------|------|
| R-type | add, sub, sll, slt, sltu, xor, srl, sra, or, and |
| I-type (ALU) | addi, slti, sltiu, xori, ori, andi, slli, srli, srai |
| I-type (load) | lb, lh, lw, lbu, lhu |
| I-type (jump) | jalr |
| S-type | sb, sh, sw |
| B-type | beq, bne, blt, bge, bltu, bgeu |
| U-type | lui, auipc |
| J-type | jal |

---

## 開發原則

- 介面與功能照 Harris《Digital Design and Computer Architecture, RISC-V Edition》，
  但每個設計決策都自己想過「為什麼」，記在 DESIGN_NOTES.md。
- 零件先各自寫好、獨立測試，再組裝。
- 先求功能正確，再考慮面積 / 時序優化。
