
# See https://github.com/enterprise-contract/hacks
HACKS_DIR=../hacks
RECORDINGS_DIR=$(HACKS_DIR)/provenance/recordings

run-for-recording-%:
	@opa eval data.main.main \
	  -i $(RECORDINGS_DIR)/$*/attestation.json \
	  -d main.rego \
	  -d lib/ \
	  -f pretty

run-01: run-for-recording-01-SLSA-v0-2-Pipeline-in-cluster
run-05: run-for-recording-05-SLSA-v1-0-tekton-build-type-Pipeline-in-cluster

run: run-01 run-05

compare:
	@-diff <($(MAKE) run-01) <($(MAKE) run-05)
