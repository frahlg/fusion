#!/usr/bin/env bash
# Illustrative demo used only to render assets/fusion-demo.gif via demo.tape.
# It is NOT a live capture — it reproduces the *shape* of a real Fusion answer
# (verdict first, then the audit trail), matching the example in the README.
set -u

b=$'\e[1m'; d=$'\e[2m'; r=$'\e[0m'
cyan=$'\e[36m'; grn=$'\e[32m'; ylw=$'\e[33m'; mag=$'\e[35m'; gray=$'\e[90m'

printf '\033[2J\033[3J\033[H'   # wipe the bootstrap command line before recording starts
sleep 0.5
printf "%s❯%s /fusion Single MQTT broker or a quorum for our edge control loop?\n" "$grn" "$r"
sleep 0.9

printf "\n%sFusion%s %s· convening panel%s  %sopus4.8-gpt5.5%s\n" "$mag$b" "$r" "$d" "$r" "$cyan" "$r"
printf "  %s◐%s Opus 4.8 ............ %sanswering (blind)%s\n" "$ylw" "$r" "$d" "$r"
printf "  %s◐%s GPT-5.5 (xhigh) ..... %sanswering (blind)%s\n" "$ylw" "$r" "$d" "$r"
sleep 2.3

printf "  %s✓%s Opus 4.8             %s✓%s GPT-5.5 (xhigh)\n" "$grn" "$r" "$grn" "$r"
printf "%sFusion%s %s· judging → synthesizing%s\n" "$mag$b" "$r" "$d" "$r"
sleep 1.6

printf "\n%sRun the quorum.%s Every independent line of reasoning converged here: a single\n" "$b" "$r"
printf "broker is a single point of failure your control loop can't survive, and the\n"
printf "latency cost of consensus stays inside your 200 ms budget. One real caveat —\n"
printf "no panelist could verify failover under network partition, so prove that on\n"
printf "your hardware before you trust it in production.\n"
sleep 0.4
printf "%s──────────────────────────────────────────────────────────────%s\n" "$gray" "$r"
printf "%sPanel%s opus4.8-gpt5.5 — Opus 4.8 %s✓%s  ·  GPT-5.5 (xhigh) %s✓%s\n" "$b" "$r" "$grn" "$r" "$grn" "$r"
printf "%sConsensus%s      quorum for availability; latency fits the 200 ms budget\n" "$cyan" "$r"
printf "%sContradictions%s broker count 3 vs 5 — adjudicated to 3 on the cited benchmark\n" "$cyan" "$r"
printf "%sUnique insight%s GPT-5.5 flagged split-brain on even-sized clusters\n" "$cyan" "$r"
printf "%sBlind spots%s    failover-under-partition timing unverified by either panelist\n" "$cyan" "$r"
sleep 2.0
