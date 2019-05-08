bootstrap-darwin: install-darwin symlink-darwin

install-darwin:
	cd ./platforms/darwin && make install;

symlink-darwin:
	cd ./platforms/darwin && make symlink;
