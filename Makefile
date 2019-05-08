bootstrap-darwin: install-darwin symlink-darwin config-darwin

install-darwin:
	cd ./platforms/darwin && make install;

symlink-darwin:
	cd ./platforms/darwin && make symlink;

config-darwin:
	cd ./platforms/darwin && make config;
