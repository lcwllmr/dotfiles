.PHONY: this
this:
	sudo nixos-rebuild switch --flake .#$(cat /etc/hostname)

.PHONY: cloud
cloud:
	nixos-rebuild switch --flake .#cloud --target-host 10.0.0.3 --use-remote-sudo

.PHONY: gc
gc:
	nix-collect-garbage --delete-old
	$(MAKE) this

