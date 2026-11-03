# Guarded next-boot Legion graphics

The ordinary host configuration opts into
`services.legionControl.nextBootGraphics`, alongside boot reconciliation. The
frontend input is updated to the implementation containing the typed authorized
request/cancel/status API and its terminal client.

This records requests on the desktop and applies them during a later boot before
normal user startup. It does not change graphics mode when the request is saved.
No request is queued by enabling the option itself.

For initial setup, build and install a reviewed committed generation with
`nixos-rebuild boot`, not a live switch. Reboot manually after saving work. This
first setup boot should retain Hybrid, because no iGPU-only request was queued.
Once back on the desktop, validate the new service/authentication before asking
for an actual mode transition.

The frontend's `tool/setup_next_boot_graphics.sh` is a logged, confirmation-gated
installer for one specific committed host revision. It uses an immutable Git
flake URL so it does not accidentally deploy unrelated uncommitted changes in
this checkout. In particular, the existing unrelated `view-beads` lock edit was
preserved and is not part of the setup commit. The installer does not switch the
running system, queue a mode, log out, or reboot.

Do not use the legacy `no-nvidia` or `nvidia-only` specialisations for this test:
their activation/PCI-removal behavior is not this guarded firmware flow. Keep a
known-good normal generation and BIOS Hybrid/Switchable recovery available.

The earlier dark-screen/power-LED incident occurred before this feature was
deployed. Logs strongly support a Hybrid hibernation restore, but do not rule out
a wake problem. It remains tracked separately as frontend issue `lllf-p4q`.

See the frontend's `docs/architecture/next-boot-graphics.md` for startup ordering,
evidence, recovery, known race limits, and test results. Deployment and actual
next-boot graphics validation remain tracked in `lllf-j9t.7.1`.
