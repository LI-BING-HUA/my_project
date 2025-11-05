import os

# === 設定要掃描的根目錄 ===
BASE_DIR = "portfolio"
README_PATH = os.path.join(BASE_DIR, "README.md")

def generate_readme():
    lines = []
    lines.append("# 🧭 Portfolio\n")
    lines.append("This repository contains all coursework and projects for **NCKU M.S. Electrical Engineering (Control Division)**.\n")
    lines.append("---\n")

    for semester in sorted(os.listdir(BASE_DIR)):
        sem_path = os.path.join(BASE_DIR, semester)
        if not os.path.isdir(sem_path):
            continue

        lines.append(f"## 📂 {semester.replace('_', ' ').title()}\n")
        for folder in sorted(os.listdir(sem_path)):
            course_path = os.path.join(sem_path, folder)
            if os.path.isdir(course_path):
                emoji = "📘"
                if "vision" in folder: emoji = "👁️"
                elif "systemc" in folder: emoji = "⚙️"
                elif "machine" in folder: emoji = "🤖"
                elif "orchid" in folder: emoji = "🌿"
                lines.append(f"- {emoji} [{folder.replace('_', ' ').title()}]({semester}/{folder})\n")
        lines.append("\n")

    with open(README_PATH, "w", encoding="utf-8") as f:
        f.writelines(lines)
    print("✅ README.md updated successfully!")

if __name__ == "__main__":
    generate_readme()
