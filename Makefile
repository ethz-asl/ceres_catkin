all: ceres

ceres:	
	./make.sh
	touch ceres
clean:
	rm -rf dependencies
	rm -rf ceres_src
	rm -rf build
	rm ceres
