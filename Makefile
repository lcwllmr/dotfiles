.PHONY: this
this:
	sudo nixos-rebuild switch --flake .#$(shell hostname)

.PHONY: cloud
cloud:
	nixos-rebuild switch --flake .#cloud --target-host root@10.0.0.3

.PHONY: gc
gc:
	nix-collect-garbage --delete-old
	$(MAKE) this

.PHONY: age
age:
	@test -n "$(key)"
	@test -e $(key)
	@ssh-to-age -private-key -i $(key) | age-keygen -y

.PHONY: install
install:
	test -n "${machine}"
	test -n "${ssh}"
	chmod +x ./scripts/nixos-anywhere
	./scripts/nixos-anywhere ${machine} ${ssh}

.PHONY: sops
sops:
	export SOPS_AGE_KEY_FILE=/var/lib/sops-nix/key.txt && sops ./misc/secrets.yaml

.PHONY: usb
usb:
	test -e "${device}"
	chmod +x ./scripts/write-most-recent-iso
	./scripts/write-most-recent-iso ${device}

.PHONY: test
test:
	
