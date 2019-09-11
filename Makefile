BACKUP_DIR=elpa-backups

reinstall_packages:
	$(eval target_dir := $(BACKUP_DIR)/$(shell cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1))
	@mkdir -p $(BACKUP_DIR)
	@echo "Backing up old packages to $(target_dir)..."
	@(test -d elpa && mv elpa $(target_dir)) || true
	@echo "Done."
	@echo "Installing packages..."
	@yes | emacs -q --batch --load init-package.el \
		--eval '(package-refresh-contents)' \
		--eval '(package-install-selected-packages)'
	@echo "All done."

install_external_tools:
	sudo apt install python3-pip git figlet shellcheck aspell-es

clean:
	rm -rf auto-save-list/ url/ tramp

time_startup:
	python3 -m timeit \
		-r 1 -n 5 \
		'__import__("subprocess").call("emacs --eval (kill-emacs)".split())'
