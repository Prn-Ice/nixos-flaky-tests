#!/usr/bin/env bash
set -uo pipefail

CLI="/run/current-system/sw/bin/legion_cli"
EVIDENCE_ROOT="/var/log/legion-hibernate-diagnostics"
RUNTIME_ROOT="/run/legion-hibernate-diagnostics"

capture_snapshot() {
	local output=$1
	local phase=$2
	local started_at=$3

	install -d -m 0750 "$output" || return 1

	{
		printf 'phase=%s\n' "$phase"
		printf 'captured_at=%s\n' "$(date --iso-8601=ns)"
		printf 'started_at=%s\n' "$started_at"
		printf 'boot_id='
		cat /proc/sys/kernel/random/boot_id
		printf 'uptime='
		cat /proc/uptime
		printf 'power_disk='
		cat /sys/power/disk
		printf 'pm_debug_messages='
		cat /sys/power/pm_debug_messages
		printf 'pm_print_times='
		cat /sys/power/pm_print_times
		uname -a
	} >"$output/summary.txt" 2>&1

	if [[ "$phase" == "initial-preflight" && -x "$CLI" ]]; then
		if ! "$CLI" --donotexpecthwmon graphics-mode status --json \
			>"$output/graphics-status.json" 2>"$output/graphics-status.error"; then
			printf 'Graphics status capture failed during %s.\n' "$phase" \
				>>"$output/CAPTURE-WARNINGS"
		fi
	elif [[ "$phase" == "initial-preflight" ]]; then
		printf 'Validated CLI is unavailable at %s.\n' "$CLI" \
			>"$output/graphics-status.error"
		printf 'Graphics status capture was unavailable during %s.\n' "$phase" \
			>>"$output/CAPTURE-WARNINGS"
	else
		printf 'Skipped during the frozen transition to avoid userspace side effects.\n' \
			>"$output/graphics-status.skipped"
	fi

	{
		printf '=== Side-effect-free PCI presence ===\n'
		for device in 0000:00:01.1 0000:01:00.0 0000:01:00.1 0000:03:00.0; do
			device_path="/sys/bus/pci/devices/$device"
			if [[ -e "$device_path" ]]; then
				printf '%s present driver=%s\n' "$device" \
					"$(readlink -f "$device_path/driver" 2>/dev/null || printf 'none')"
			else
				printf '%s absent\n' "$device"
			fi
		done
	} >"$output/pci-and-graphics.txt" 2>&1

	{
		for path in \
			/sys/bus/pci/devices/0000:00:01.1/power/runtime_status \
			/sys/bus/pci/devices/0000:00:01.1/power/control \
			/sys/bus/pci/devices/0000:00:01.1/power/wakeup \
			/sys/bus/pci/devices/0000:00:01.1/power/wakeup_count \
			/sys/module/legion_laptop/drivers/platform:legion/*/gsync \
			/sys/module/legion_laptop/drivers/platform:legion/*/igpumode; do
			[[ -e "$path" ]] || continue
			printf '%s=' "$path"
			cat "$path"
		done
	} >"$output/power-and-firmware.txt" 2>&1

	for source in \
		/proc/acpi/wakeup \
		/sys/kernel/debug/wakeup_sources \
		/sys/power/pm_wakeup_irq \
		/sys/power/suspend_stats/success \
		/sys/power/suspend_stats/fail \
		/sys/power/suspend_stats/failed_step \
		/sys/power/suspend_stats/last_failed_dev \
		/sys/power/suspend_stats/last_failed_errno; do
		name=${source#/}
		name=${name//\//-}
		cat "$source" >"$output/$name.txt" 2>"$output/$name.error"
	done

	ps -eLo pid,tid,ppid,user,state,wchan:32,comm,args --sort=pid,tid \
		>"$output/processes.txt" 2>&1
	systemctl list-jobs --all --no-pager >"$output/systemd-jobs.txt" 2>&1
	systemctl --failed --no-pager >"$output/systemd-failed.txt" 2>&1
	journalctl -k -b --since "$started_at" --no-pager \
		>"$output/kernel-journal.txt" 2>&1
	journalctl -b --since "$started_at" --no-pager \
		-u systemd-hibernate.service -u systemd-logind.service \
		>"$output/systemd-journal.txt" 2>&1

	[[ -s "$output/summary.txt" ]]
}

start_capture() {
	local started_at=$1
	local phase=$2
	local boot_id run_id evidence_dir

	boot_id=$(</proc/sys/kernel/random/boot_id)
	run_id=${started_at//:/-}
	evidence_dir="$EVIDENCE_ROOT/$run_id-${boot_id:0:8}"

	install -d -m 0750 "$evidence_dir" || return 1
	printf '%s\n' "$evidence_dir" >"$RUNTIME_ROOT/current" || return 1
	printf '%s\n' "$evidence_dir" >"$RUNTIME_ROOT/latest" || return 1
	printf '%s\n' "$started_at" >"$evidence_dir/started-at" || return 1
	capture_snapshot "$evidence_dir/$phase" "$phase" "$started_at"
}

case ${1:-} in
arm | cancel) ;;
pre | post)
	[[ ${2:-} == "hibernate" ]] || exit 0
	;;
*) exit 0 ;;
esac

install -d -m 0750 "$EVIDENCE_ROOT" "$RUNTIME_ROOT" || exit 1

if [[ ${1:-} == "arm" ]]; then
	[[ $# -eq 2 ]] || exit 1
	rm -f "$RUNTIME_ROOT/current" "$RUNTIME_ROOT/latest"
	start_capture "$2" "initial-preflight" || exit 1
	journalctl --sync
	sync
	exit 0
fi

if [[ ${1:-} == "cancel" ]]; then
	if [[ -r "$RUNTIME_ROOT/current" ]]; then
		evidence_dir=$(<"$RUNTIME_ROOT/current")
		printf 'cancelled_at=%s\n' "$(date --iso-8601=ns)" >"$evidence_dir/CANCELLED"
	fi
	rm -f "$RUNTIME_ROOT/current"
	exit 0
fi

if [[ $1 == "pre" ]]; then
	if [[ ! -r "$RUNTIME_ROOT/current" ]]; then
		start_capture "$(date --iso-8601=seconds)" "initial-preflight" || exit 1
	fi
	evidence_dir=$(<"$RUNTIME_ROOT/current")
	started_at=$(<"$evidence_dir/started-at")
	if ! capture_snapshot "$evidence_dir/pre-hibernate" "pre-hibernate" "$started_at"; then
		printf 'Pre-hibernate capture failed.\n' >"$evidence_dir/CAPTURE-FAILED"
		exit 1
	fi

	if [[ $(</sys/power/disk) != *"[shutdown]"* ]]; then
		printf 'Expected shutdown hibernation mode, found: %s\n' "$(</sys/power/disk)" \
			>"$evidence_dir/UNSAFE-HIBERNATION-MODE"
	fi

	journalctl --sync
	sync
	exit 0
fi

if [[ ! -r "$RUNTIME_ROOT/current" ]]; then
	exit 0
fi

evidence_dir=$(<"$RUNTIME_ROOT/current")
started_at=$(<"$evidence_dir/started-at")
if ! capture_snapshot "$evidence_dir/post-hibernate" "post-hibernate" "$started_at"; then
	printf 'Post-hibernate capture failed.\n' >"$evidence_dir/CAPTURE-FAILED"
	exit 1
fi

journalctl --sync
sync
rm -f "$RUNTIME_ROOT/current"
