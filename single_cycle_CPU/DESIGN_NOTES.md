# 設計筆記（DESIGN NOTES）

給自己看的技術細節與「為什麼這樣設計」的記錄。README 講大方向，這裡講關鍵設計決策。

---

## 1. 控制訊號分兩層解碼（Main Decoder + ALU Decoder）

不用一個大 case 硬解全部，而是分成：
- **Main Decoder**：看 opcode，決定資料流向（要不要寫暫存器、ALU 第二輸入選 imm 還是 rs2、
  結果從哪來…）以及一個抽象的 `ALUOp`（2-bit）。
- **ALU Decoder**：看 `ALUOp` + funct3 + funct7[5]，決定 ALU 的實際運算。

`ALUOp` 的意義：`00` = 直接加（load/store 算位址、auipc/lui）、`01` = 減（此設計中預留）、
`10` = 看 funct（R-type / I-arith）、`11` = branch 家族。
好處是 R-type 和 I-arith 可以共用同一段 funct3 解碼邏輯，只差在 R-type 的 sub/sra 要看 funct7[5]、
而 I-arith 沒有 sub（`addi` 不看 funct7）。

---

## 2. Branch 家族用 funct3 + ALU 結果判斷

MIPS 只有 beq/bne，但這裡實作了完整六種。做法：branch 時 ALU 依 funct3 做對應運算，
control unit 再看結果決定跳不跳：

| 指令 | funct3 | ALU 做 | 判斷 taken 的條件 |
|------|:------:|--------|------------------|
| beq  | 000 | sub | `zero`（相等） |
| bne  | 001 | sub | `~zero` |
| blt  | 100 | slt（有號） | `alu_result[0]` |
| bge  | 101 | slt（有號） | `~alu_result[0]` |
| bltu | 110 | sltu（無號） | `alu_result[0]` |
| bgeu | 111 | sltu（無號） | `~alu_result[0]` |

最後 `PCSrc` 的優先序：jalr（用 ALU 算出的位址）> jump 或 branch taken（用 PCTarget）> PC+4。

---

## 3. Load / Store 的對齊處理

- **Store（`Data_Memory`）**：sb/sh 依位址低 2 位，只寫入對應的 byte/half lane，
  不動到同一個 word 的其他位元組。
- **Load（`Load_Unit`）**：先讀出整個 word，再依 funct3 + 位址低 2 位選出要的 byte/half，
  並做符號延伸（lb/lh）或零延伸（lbu/lhu）。lw 直接原樣輸出。

---

## 4. FPGA 單步執行 + 七段 debug

因為 FPGA 的 clock 太快，肉眼無法觀察每條指令的效果，所以：
- 用按鈕（去彈跳 + 邊緣偵測）產生 **step 脈衝**，一次只讓 PC 前進一條指令。
- Register File 開一個 debug 讀埠，用開關 `SW` 選要看哪個暫存器，值轉 BCD 後用七段顯示。
- 這樣可以一步一步按、一格一格檢查每條指令執行後暫存器的變化，方便上板驗證。

---

## 5. 自己刻 CLA 而非直接用 `+`

加法器用 4-bit carry-lookahead 手刻（generate/propagate 平行算進位），
而非直接寫 `A + B` 讓合成器自動生。目的是理解進位傳播的原理與延遲差異：
ripple carry 要一級一級等，CLA 平行算進位。

---

## 6. 與多週期版本的差異（延伸）

單週期一個 cycle 做完整條指令，所以需要**兩個 memory**、**多個加法器**。
多週期把指令拆成多個 cycle，同一單元分時複用，因此**一個 memory、一個 ALU** 就夠。
ALU 的 SLT 在多週期版改為「重用減法器 + overflow 修正」，
而此單週期版直接用 `$signed` 比較——這是後續的改進。
