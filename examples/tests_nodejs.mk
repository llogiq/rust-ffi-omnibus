include ${COMMON_TEST_RULES}

ifndef NODEJS_DEPENDENCIES

NODEJS_DEPENDENCIES := .nodejs-dependencies

${NODEJS_DEPENDENCIES}: package.json
	npm install
	touch $@

endif

NODEJS_BIN_DIR ?= $(shell npm bin)

.PHONY: nodejs-hint_${d}
nodejs-hint_${d}: ${d}/src/main.js ${NODEJS_DEPENDENCIES}
	${NODEJS_BIN_DIR}/jshint $<

.PHONY: nodejs-style_${d}
nodejs-style_${d}: ${d}/src/main.js ${NODEJS_DEPENDENCIES} .jscsrc
	${NODEJS_BIN_DIR}/jscs $<

${TEST_DIR_${d}}/nodejs-test: LIB_DIR := ${LIB_DIR_${d}}
${TEST_DIR_${d}}/nodejs-test: ${d}/src/main.js ${TEST_DIR_${d}} ${LIB_${d}} ${NODEJS_DEPENDENCIES}
	LD_LIBRARY_PATH=${LIB_DIR} node $< > $@

.PHONY: nodejs-test_${d}
nodejs-test_${d}: EXPECTED := ${d}/expected-output
nodejs-test_${d}: ${TEST_DIR_${d}}/nodejs-test
	diff -q ${EXPECTED} $<

nodejs: nodejs-test_${d} nodejs-hint_${d} nodejs-style_${d}
