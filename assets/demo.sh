#!/usr/bin/env bash
# Illustrative demo used only to render assets/fusion-demo.gif via demo.tape.
# It is NOT a live capture — it reproduces the *shape* of a real Fusion answer
# (verdict first, then the audit trail), matching the example in the README.
set -u

# 24-bit truecolor accents (Dracula palette) so colors pop regardless of theme.
r=$'\e[0m'; b=$'\e[1m'; d=$'\e[38;2;98;114;164m'
grn=$'\e[38;2;80;250;123m'; cyan=$'\e[38;2;139;233;253m'
pink=$'\e[38;2;255;121;198m'; ylw=$'\e[38;2;241;250;140m'
red=$'\e[38;2;255;85;85m';  fg=$'\e[38;2;248;248;242m'

typeline() { local s="$1" i; for ((i=0; i<${#s}; i++)); do printf '%s' "${s:i:1}"; sleep 0.022; done; printf '\n'; }

printf '\033[2J\033[3J\033[H'      # wipe the bootstrap command line before recording starts
sleep 0.85

# 1) prompt, typed live
printf "%s❯%s %s" "$grn" "$r" "$fg"
typeline "/fusion  Single MQTT broker or a quorum for our edge control loop?"
printf "%s" "$r"
sleep 0.5

# 2) convene the panel
printf "\n  %s⚡ Fusion%s %sconvening panel%s  %sopus4.8-gpt5.5%s\n\n" "$pink$b" "$r" "$d" "$r" "$cyan" "$r"

# 3) animated spinners + ticking timer (panel thinking, blind)
sp=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏'); n=${#sp[@]}
printf "  %s%s%s Opus 4.8 ............  %sthinking%s   0.0s\n" "$cyan" "${sp[0]}" "$r" "$d" "$r"
printf "  %s%s%s GPT-5.5 (xhigh) .....  %sthinking%s   0.0s\n" "$pink" "${sp[0]}" "$r" "$d" "$r"
for ((i=1; i<=22; i++)); do
  f1=${sp[$((i % n))]}; f2=${sp[$(((i+5) % n))]}
  ms=$((i*110)); s=$((ms/1000)); ds=$(((ms/100)%10))
  printf '\033[2A'
  printf "\r\033[2K  %s%s%s Opus 4.8 ............  %sthinking%s   %d.%ds\n" "$cyan" "$f1" "$r" "$d" "$r" "$s" "$ds"
  printf "\r\033[2K  %s%s%s GPT-5.5 (xhigh) .....  %sthinking%s   %d.%ds\n" "$pink" "$f2" "$r" "$d" "$r" "$s" "$ds"
  sleep 0.11
done
# flip to done
printf '\033[2A'
printf "\r\033[2K  %s✓%s Opus 4.8 ............  %sdone%s       2.4s\n" "$grn" "$r" "$grn" "$r"
printf "\r\033[2K  %s✓%s GPT-5.5 (xhigh) .....  %sdone%s       2.4s\n" "$grn" "$r" "$grn" "$r"

# 4) judging, animated dots
printf "\n  %s◆ Fusion%s %sjudging → synthesizing%s" "$pink$b" "$r" "$d" "$r"
for ((i=0; i<7; i++)); do printf "%s.%s" "$d" "$r"; sleep 0.16; done
sleep 0.4

# 5) the verdict, revealed
printf "\n\n  %sRun the quorum.%s Every independent line of reasoning converged here:\n" "$b$grn" "$r"; sleep 0.18
printf "  a single broker is a point of failure your control loop can't survive,\n";       sleep 0.18
printf "  and the latency cost of consensus stays inside your 200 ms budget. One\n";       sleep 0.18
printf "  caveat no model could verify: failover under partition. Prove that first.\n";    sleep 0.45

# 6) the audit trail, building line by line
printf "  %s────────────────────────────────────────────────────────────────%s\n" "$d" "$r"; sleep 0.12
printf "  %s▸ Panel%s  opus4.8-gpt5.5   %s✓%s Opus 4.8   %s✓%s GPT-5.5 (xhigh)\n" "$fg$b" "$r" "$grn" "$r" "$grn" "$r"; sleep 0.2
printf "  %s✓%s %sConsensus%s       quorum for availability; latency fits 200 ms\n" "$grn" "$r" "$cyan" "$r"; sleep 0.2
printf "  %s↔%s %sContradiction%s   broker count 3 vs 5 → resolved to 3 on benchmark\n" "$ylw" "$r" "$cyan" "$r"; sleep 0.2
printf "  %s★%s %sUnique insight%s  GPT-5.5 caught split-brain on even-sized clusters\n" "$pink" "$r" "$cyan" "$r"; sleep 0.2
printf "  %s⚠%s %sBlind spot%s      failover-under-partition timing unverified\n" "$red" "$r" "$cyan" "$r"; sleep 0.5

# 7) the button
printf "\n  %sDeep Thought, with receipts.%s\n" "$d" "$r"
sleep 1.8
