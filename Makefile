all: ceres

doc:
	mkdir -p ./docs/gen
	python ceres_src/scripts/make_docs.py ceres_src/ ./docs/gen      

ceres:	
	./make.sh
	touch ceres
clean:
	rm -rf dependencies
	rm -rf ceres_src
	rm -rf build
	rm ceres
